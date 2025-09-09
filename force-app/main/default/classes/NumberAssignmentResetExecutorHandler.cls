/**
 * The NumberAssignmentResetExecutorHandler class is responsible resetting and unreserving numbers.
 * It is triggered by an activationline delete event and processes the assignments in batches.
 *  -----------------------------------------------------------------------------
 *  Developer            Date            Description
 *  -----------------------------------------------------------------------------
 *  Kenneth Houkjær         29/07/2025      Initial version
 *
 * @author Kenneth Houkjær
 * @date 29/07/2025
 */
public with sharing class NumberAssignmentResetExecutorHandler implements IEventExecutableHandler {
    private final NumberClient numberClient;
    private final DatabaseService databaseService;

    /**
     * @description Default constructor that initializes the NumberClient and DatabaseService using the SingletonFactory.
     */
    public NumberAssignmentResetExecutorHandler() {
        this(SingletonFactory.getFactory());
    }

    /**
     * @description Private constructor for dependency injection.
     * @param singletonFactory The SingletonFactory instance to use for creating dependencies.
     */
    private NumberAssignmentResetExecutorHandler(SingletonFactory singletonFactory) {
        this.numberClient = (NumberClient) singletonFactory.getOrRegisterSingleton(NumberClient.class);
        this.databaseService = (DatabaseService) singletonFactory.getOrRegisterSingleton(DatabaseService.class);
    }

    /**
     * @description Test-visible constructor for dependency injection during testing.
     * @param numberClient The NumberClient instance to use.
     * @param databaseService The DatabaseService instance to use.
     */
    @TestVisible
    private NumberAssignmentResetExecutorHandler(NumberClient numberClient, DatabaseService databaseService) {
        this.numberClient = numberClient;
        this.databaseService = databaseService;
    }

    /**
     * @description This method is called when an event is received. It processes the phone number assignments
     * @param event The event that triggered the handler.
     */
    public void execute(EventExecutor__e event) {
        Logger.logInfo(String.format('execute( {0} )', new List<Object>{ event }));

        Parameters params = new Parameters();

        //This caused lot of debug time, always remember to initiated the collection, its very hard to see what causes the error if not.
        params.activationLineIdToNumber = new Map<Id, String>();       

        params = getParameters(event.Parameters__c);

        Map<String, Account_Phone_Number_Assignment__c>  assignmentsFromPhoneMap;
        Map<String, Account_Phone_Number_Assignment__c>  assignmentsFromActivationLineMap;

        try {
            Logger.logInfo(params.activationLineIdToNumber);
            assignmentsFromPhoneMap = getAssignmentsPhoneMap(params.activationLineIdToNumber);
            assignmentsFromActivationLineMap = getAssignmentsActivationLineMap(params.activationLineIdToNumber);
        } 
        catch (QueryException ex) {
            Logger.logError('SOQL Error: ' + ex.getMessage());
            throw new NumberAssignmentResetExecutorHandlerException('SQOL Error finding assignment: ' + ex.getMessage());
        }
        
        List<Account_Phone_Number_Assignment__c> assignmentsToUpdate = new List<Account_Phone_Number_Assignment__c>();
        
        Map<Id, String> retryResetActivationLineIdToNumber = new Map<Id, String>();
        
        for(Id activationLineId : params.activationLineIdToNumber.keySet()){
            String phoneNumber = params.activationLineIdToNumber.get(activationLineId);
            
            Account_Phone_Number_Assignment__c assignment = null;
            Account_Phone_Number_Assignment__c phoneAssignment = assignmentsFromPhoneMap.get(phoneNumber);
            Account_Phone_Number_Assignment__c activationLineAssignment = assignmentsFromActivationLineMap.get(activationLineId);
  
            try{
                if(phoneAssignment != null)
                    assignment = phoneAssignment;
                else if (activationLineAssignment != null)
                    assignment = activationLineAssignment;
                else {
                    Logger.logInfo('No assignment found for activation line id ' + activationLineId);
                    continue;
                }  

                //we only need to unreserve numbers in the fixed series
                //TODO: look in custom metadata to find the open series
                String defaultOpenSeriesLocation = SFConstants.DEFAULT_OPENSERIES_NUMBERLOCATION;
                String defaultOpenSeriesGroup = SFConstants.DEFAULT_OPENSERIES_PRODUCTGROUP;
                Boolean isOpenSeries = assignment.Account_Phone_Number_Series__r.Number_Group__c == defaultOpenSeriesGroup 
                    && assignment.Account_Phone_Number_Series__r.Number_Location__c == defaultOpenSeriesLocation;

                if(assignment.CTN_Number_Status__c == 'AR' && !isOpenSeries) {
                    NumberClientResponseDTO.NumberDetail numberUnreserveResponse = numberClient.unreserveNumberDetailByMsisdn(
                    addCountryCodeToPhoneNumber(assignment.Phone_Number__c));
               
                    if (numberUnreserveResponse.data != null && numberUnreserveResponse.data.id != null) {
                        assignment = resetAssignment(assignment);
                        assignment.CTN_Number_Status__c = numberUnreserveResponse.data.numberStatus;
                    } else {
                        String errorMessage = String.format(
                            'numberUnreserveResponse( {0} ) response was not expected.',
                            new List<Object>{ numberUnreserveResponse }
                        );
                        //If we end up here something is really off! Better log it
                        Logger.logInfo(errorMessage);

                        assignment = setNumberUnreserveErrorOnAssignment(assignment, errorMessage);
                    }
                } 
                //if its an open series we just need to reset, the status is already AR
                else if (assignment.CTN_Number_Status__c == 'AR' && isOpenSeries) { 
                    assignment = resetAssignment(assignment);
                    Logger.logInfo('assignment ' + assignment);
                }
            }catch (HTTPException ex) {
                switch on ex.getStatusCode() {
                    when 500 {
                        if (event.RetryCount__c < EventExecutorFinalizer.MAX_RETRY_COUNT) {
                            //We add it to retry! 
                            retryResetActivationLineIdToNumber.put( activationLineId, assignment.Id);
                        } else {
                            Logger.logInfo(
                                String.format(
                                    'We reached a maximum of retry. Halt execution for {0}',
                                    new List<Object>{ event }
                                )
                            );
                            Logger.logError(ex);
                        }
                    }
                }
                
                assignment = setNumberUnreserveErrorOnAssignment(assignment, ex.getMessage());
            }

            assignmentsToUpdate.add(assignment);
        }
        
        databaseService.updateRecords(assignmentsToUpdate);
        
                
        if( !retryResetActivationLineIdToNumber.isEmpty() ){
            EventExecutor__e retryEventExecutor = new EventExecutor__e();
            Parameters retryParams = new Parameters();
            retryParams.activationLineIdToNumber = retryResetActivationLineIdToNumber;
            retryEventExecutor.Parameters__c = JSON.serialize(retryParams);
            retryEventExecutor.Executor__c = event.Executor__c;
            retryEventExecutor.RetryCount__c = event.RetryCount__c+1;
            retryEventExecutor.LastEventExecutorException__c = 'Events failed try to rerun!';
            retryEventExecutor.LastEventExecutorUuid__c = event.EventUuid;
            retryEventExecutor.LastEventExecutorReplayId__c = event.ReplayId;
            
        	EventBus.publish(retryEventExecutor);
        }
    }

    private String addCountryCodeToPhoneNumber(string phoneNumber){
        if(phoneNumber.length() == 8){
            return '45' + phoneNumber;
        }
        return phoneNumber;  
    } 
 
    private Account_Phone_Number_Assignment__c setNumberUnreserveErrorOnAssignment(Account_Phone_Number_Assignment__c assignment, String errorMessage) {
        Logger.logInfo(
            String.format(
                'setNumberUnreserveErrorOnAssignment( {0}, {1} )',
                new List<Object>{ assignment, errorMessage }
            )
        );
        
        return assignment;
    }  

    /**
     * @description This method resets various values on the assignment.
     * @param assignment The assignment to reset.
     * @return The reset assignment.
     */
    @TestVisible
    private Account_Phone_Number_Assignment__c resetAssignment(Account_Phone_Number_Assignment__c assignment) {
        Logger.logInfo(String.format('resetAssignment( {0} )', new List<Object>{ assignment }));
        if (assignment == null) {
            Logger.logError('Assignment is null.');
            return null;
        }

        assignment.Phone_Number_Reservation_Status__c = '';
        assignment.Phone_Number_Reservation_Error__c = null;
        assignment.Activation_line__c = null;
        assignment.Phone_Number_User__c = null;

        return assignment;
    }
    
    /**
     * @description Parses the provided JSON Parameters 
     */
    @testvisible
    public Parameters getParameters(String parameters) {
        Logger.logInfo(String.format('parseParameters( {0} )', new List<Object>{ parameters }));

        if (parameters == null) {
            throw new NumberAssignmentResetExecutorHandlerException('parameters cannot be null.');
        }
        
        try{
            Parameters params = (Parameters) System.JSON.deserialize(parameters, NumberAssignmentResetExecutorHandler.Parameters.class);

            if (params.activationLineIdToNumber.isEmpty())  {
                throw new NumberAssignmentResetExecutorHandlerException(
                    String.format('Both activationLineId and number cannot be blank, empty or null', new List<Object>{ params })
                );
            }
            
            if( params.activationLineIdToNumber.containsKey(null) ){
                throw new NumberAssignmentResetExecutorHandlerException(
                    String.format('activationLineId cannot null', new List<Object>{ params })
                );
            }
  
        	return params;
        }catch(Exception ex){
            Logger.logError('NumberAssignmentResetExecutorHandler', new List<Object>{ ex });
            throw ex;
        }
    }

    /**
     * @description This method gets a map of assignments from a map of activation line IDs to assignment IDs.
     * @param mapOfactivationLineIdToNumber A map of activation line IDs to assignment IDs.
     * @return A map of assignment IDs to assignments.
     */
    private Map<String, Account_Phone_Number_Assignment__c> getAssignmentsPhoneMap(Map<Id, String> mapOfactivationLineIdToNumber) {
 
        Map<String, Account_Phone_Number_Assignment__c> assignmentsMap = new Map<String, Account_Phone_Number_Assignment__c>();
        
        List<Account_Phone_Number_Assignment__c> listOfAssignments = [
            SELECT
                Phone_Number__c,
                Account__c,
                Account_Phone_Number_Series__c,
                Id,
                Phone_Number_Reservation_Status__c,
                Phone_Number_Reservation_Error__c,
                CTN_Number_Status__c,
                Account__r.cvr__c,
                Account_Phone_Number_Series__r.Product_Type__c,
                Account_Phone_Number_Series__r.Number_Group__c, 
                Account_Phone_Number_Series__r.Number_Location__c, 
                Activation_Line__c
            FROM Account_Phone_Number_Assignment__c
            WHERE Phone_Number__c IN :mapOfactivationLineIdToNumber.values()];

        for(Account_Phone_Number_Assignment__c assignment : listOfAssignments){
            assignmentsMap.put(assignment.Phone_Number__c, assignment);  
        }

        return assignmentsMap;
    }

    private Map<String, Account_Phone_Number_Assignment__c> getAssignmentsActivationLineMap(Map<Id, String> mapOfactivationLineIdToNumber) {
 
        Map<String, Account_Phone_Number_Assignment__c> assignmentsMap = new Map<String, Account_Phone_Number_Assignment__c>();
        
        List<Account_Phone_Number_Assignment__c> listOfAssignments = [
            SELECT
                Activation_line__c,
                Phone_Number__c,
                Account__c,
                Account_Phone_Number_Series__c,
                Id,
                Phone_Number_Reservation_Status__c,
                Phone_Number_Reservation_Error__c,
                CTN_Number_Status__c,
                Account__r.cvr__c,
                Account_Phone_Number_Series__r.Product_Type__c,
                Account_Phone_Number_Series__r.Number_Group__c, 
                Account_Phone_Number_Series__r.Number_Location__c    
            FROM Account_Phone_Number_Assignment__c
            WHERE Activation_line__c IN :mapOfactivationLineIdToNumber.keyset()];

        for(Account_Phone_Number_Assignment__c assignment :listOfAssignments){
            assignmentsMap.put(assignment.Activation_line__c, assignment);    
        }

        return assignmentsMap;
    }
  
    public class Parameters {
        public Map<Id, String> activationLineIdToNumber;
    }

     public class NumberAssignmentResetExecutorHandlerException extends Exception {
    }
}