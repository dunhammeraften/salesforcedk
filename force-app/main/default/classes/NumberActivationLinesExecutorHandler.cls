/**
 * The NumberActivationLinesExecutorHandler class is responsible for handling the assignment of phone numbers to activation lines.
 * It is triggered by an event and processes the assignments in batches.
 *  -----------------------------------------------------------------------------
 *  Developer            Date            Description
 *  -----------------------------------------------------------------------------
 *  Kenneth Houkjær         27/07/2025      Initial version
 *
 * @author Kenneth Houkjær
 * @date 27/07/2025
 */
public with sharing class NumberActivationLinesExecutorHandler implements IEventExecutableHandler {
    private final NumberClient numberClient;
    private final DatabaseService databaseService;

    /**
     * @description Default constructor that initializes the NumberClient and DatabaseService using the SingletonFactory.
     */
    public NumberActivationLinesExecutorHandler() {
        this(SingletonFactory.getFactory());
    }

    /**
     * @description Private constructor for dependency injection.
     * @param singletonFactory The SingletonFactory instance to use for creating dependencies.
     */
    private NumberActivationLinesExecutorHandler(SingletonFactory singletonFactory) {
        this.numberClient = (NumberClient) singletonFactory.getOrRegisterSingleton(NumberClient.class);
        this.databaseService = (DatabaseService) singletonFactory.getOrRegisterSingleton(DatabaseService.class);
    }

    /**
     * @description Test-visible constructor for dependency injection during testing.
     * @param numberClient The NumberClient instance to use.
     * @param databaseService The DatabaseService instance to use.
     */
    @TestVisible
    private NumberActivationLinesExecutorHandler(NumberClient numberClient, DatabaseService databaseService) {
        this.numberClient = numberClient;
        this.databaseService = databaseService;
    }

    /**
     * @description This method is called when an event is received. It processes the phone number assignments, reserves them using the NumberClient, and updates their status.
     * @param event The event that triggered the handler.
     */
    public void execute(EventExecutor__e event) {
        Logger.logInfo(String.format('execute( {0} )', new List<Object>{ event }));

        Parameters params = new Parameters();

        //This caused lot of debug time, always remember to initiated the collection, its very hard to see what causes the error if not.
        params.activationLineIdToAssignementId = new Map<Id, String>();       

        params = getParameters(event.Parameters__c);

        Map<Id, Account_Phone_Number_Assignment__c>  assignmentsMap;
        Map<Id, Activation_Line__c>  activationLineMap;

        try {
            Logger.logInfo(params.activationLineIdToAssignementId);
            assignmentsMap = getAssignmentsMap(params.activationLineIdToAssignementId);
            activationLineMap = getActivationLineMap(params.activationLineIdToAssignementId);
        } 
        catch (QueryException ex) {
            Logger.logError('SOQL Error: ' + ex.getMessage());
            throw new NumberActivationLinesExecutorHandlerException('SQOL Error finding assignment: ' + ex.getMessage());
        }
        
        List<Activation_line__c> activationLinesToUpdate = new List<Activation_line__c>();
        List<Account_Phone_Number_Assignment__c> assignmentsToUpdate = new List<Account_Phone_Number_Assignment__c>();
        
        Map<Id, String> retryActivationLineIdToAssignmentId = new Map<Id, String>();
        
        for(Id activationLineId : params.activationLineIdToAssignementId.keySet()){
            String assignmentId = params.activationLineIdToAssignementId.get(activationLineId);
            
            Activation_line__c activationLine = activationLineMap.get(activationLineId); //new Activation_line__c(Id = activationLineId);
            Account_Phone_Number_Assignment__c assignment = assignmentsMap.get(assignmentId);

            try{
                //we only need to reserve numbers not already reserved, i.e., from a non-open series which are AA
                if(assignment.CTN_Number_Status__c != SFConstants.ASSIGNED_RESERVED) {
                    NumberClientResponseDTO.NumberDetail numberReservationResponse = numberClient.reserveNumberDetailByMsisdnAndCVR(
                        assignment.Phone_Number__c, 
                        assignment.Account__r.Cvr__c, 
                        assignment.Account_Phone_Number_Series__r?.Product_Type__c);
               
                    if (numberReservationResponse.data != null && numberReservationResponse.data.id != null) {
                        activationLine = setMobileNumberOnActivationLine(activationLine, this.stripCountryCodeFromPhoneNumber(numberReservationResponse.data.id));
                        assignment = setSuccessOnAssignment(assignment, activationLine);
                    } else {
                        String errorMessage = String.format(
                            'numberReservationResponse( {0} ) response was not expected.',
                            new List<Object>{ numberReservationResponse }
                        );
                        //If we end up here something is really off! Better log it
                        Logger.logInfo(errorMessage);
        
                        activationLine = setNumberReservationErrorOnActivationLine(activationLine, errorMessage);
                        assignment = setNumberReservationErrorOnAssignment(assignment, errorMessage);
                    }
                } 
                //if its an open series its already reserved, we just need to set the activationline on the assignment
                else { 
                    activationLine = setMobileNumberOnActivationLine(activationLine, this.stripCountryCodeFromPhoneNumber(assignment.Phone_Number__c));
                    Logger.logInfo('activationline ' + activationLine);
                    assignment = setSuccessOnAssignment(assignment, activationLine);
                    Logger.logInfo('assignment ' + assignment);
                }
            }catch (HTTPException ex) {
                switch on ex.getStatusCode() {
                    when 500 {
                        if (event.RetryCount__c < EventExecutorFinalizer.MAX_RETRY_COUNT) {
                            //We add it to retry! 
                            retryActivationLineIdToAssignmentId.put( activationLineId, assignment.Id);
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
                
                activationLine = setNumberReservationErrorOnActivationLine(activationLine, ex.getMessage());
                assignment = setNumberReservationErrorOnAssignment(assignment, ex.getMessage());
            }
            
            activationLinesToUpdate.add(activationLine);
            assignmentsToUpdate.add(assignment);
        }
        
        //If we reach this point we have an activation line with the following properties set:
        //Phone_Number_Reservation_Status__c is SUCCESS OR ERROR
        //Phone_Number_Reservation_Error__c is set if ERROR status
        //Mobile_No__c is null if error else it is set to numberReservationResponse.data.id returned from numberclient
        databaseService.updateRecords(activationLinesToUpdate);
        databaseService.updateRecords(assignmentsToUpdate);
        
                
        if( !retryActivationLineIdToAssignmentId.isEmpty() ){
            EventExecutor__e retryEventExecutor = new EventExecutor__e();
            Parameters retryParams = new Parameters();
            retryParams.activationLineIdToAssignementId = retryActivationLineIdToAssignmentId;
            retryEventExecutor.Parameters__c = JSON.serialize(retryParams);
            retryEventExecutor.Executor__c = event.Executor__c;
            retryEventExecutor.RetryCount__c = event.RetryCount__c+1;
            retryEventExecutor.LastEventExecutorException__c = 'Events failed try to rerun!';
            retryEventExecutor.LastEventExecutorUuid__c = event.EventUuid;
            retryEventExecutor.LastEventExecutorReplayId__c = event.ReplayId;
            
        	EventBus.publish(retryEventExecutor);
        }
    }

    private String stripCountryCodeFromPhoneNumber(string phoneNumber){
        if(phoneNumber.length() == 10){
            return phoneNumber.substring(2, phoneNumber.length());
        }
        return phoneNumber;  
    } 
    
    /**
     * @description This method sets the number reservation error on the activation line.
     * @param activationLine The activation line to update.
     * @param errorMessage The error message to set.
     * @return The updated activation line.
     */
    private Activation_line__c setNumberReservationErrorOnActivationLine(Activation_line__c activationLine, String errorMessage) {
        Logger.logInfo(
            String.format(
                'setNumberReservationErrorOnActivationLine( {0}, {1} )',
                new List<Object>{ activationLine, errorMessage }
            )
        );

        activationLine.Phone_Number_Reservation_Status__c = 'ERROR';
        activationLine.Phone_Number_Reservation_Error__c = errorMessage;
        activationLine.Mobile_No__c = null;
        
        return activationLine;

    }

    private Account_Phone_Number_Assignment__c setNumberReservationErrorOnAssignment(Account_Phone_Number_Assignment__c assignment, String errorMessage) {
        Logger.logInfo(
            String.format(
                'setNumberReservationErrorOnAssignment( {0}, {1} )',
                new List<Object>{ assignment, errorMessage }
            )
        );

        assignment.Activation_Line__c = null;
        assignment.Phone_Number_User__c = null;     
        
        return assignment;
    }
    
    /**
     * @description This method sets the mobile number on the activation line.
     * @param activationLine The activation line to update.
     * @param phoneNumber The phone number to set.
     * @return The updated activation line.
     */
    private Activation_line__c setMobileNumberOnActivationLine(Activation_line__c activationLine, String phoneNumber) {
        Logger.logInfo(
            String.format(
                'setMobileNumberOnActivationLine( {0}, {1} )',
                new List<Object>{ activationLine, phoneNumber }
            )
        );

        activationLine.Phone_Number_Reservation_Status__c = 'SUCCESS';
        activationLine.Phone_Number_Reservation_Error__c = null;
        activationLine.Mobile_No__c = phoneNumber;
        
        return activationLine;
    }

    /**
     * @description This method sets the status of the assignment to success.
     * @param assignment The assignment to update.
     * @param activationLine The activation line to associate with the assignment.
     * @return The updated assignment.
     */
    @TestVisible
    private Account_Phone_Number_Assignment__c setSuccessOnAssignment(Account_Phone_Number_Assignment__c assignment, Activation_Line__c activationLine) {
        Logger.logInfo(String.format('setSuccessOnAssignment( {0} )', new List<Object>{ assignment }));
        if (assignment == null) {
            Logger.logError('Assignment is null.');
            return null;
        }

        assignment.Phone_Number_Reservation_Status__c = 'Success';
        assignment.Phone_Number_Reservation_Error__c = null;
        assignment.CTN_Number_Status__c = SFConstants.ASSIGNED_RESERVED;
        assignment.Activation_line__c = activationLine.Id;
        
        if(!string.isBlank(activationLine.first_Name__c) && !string.isBlank(activationLine.last_Name__c))
            assignment.Phone_Number_User__c = activationLine.first_Name__c + ' ' + activationLine.last_Name__c;
        
        if(!string.isBlank(activationLine.email__c) && !string.isBlank(activationLine.first_Name__c))
            assignment.Phone_Number_User__c = assignment.Phone_Number_User__c + ', ' + activationLine.email__c;
        else
            assignment.Phone_Number_User__c = activationLine.email__c;

        return assignment;
    }
    
    public class NumberActivationLineExecutorHandlerException extends Exception {
    }
    
    /**
     * @description Parses the provided JSON Parameters 
     */
    public Parameters getParameters(String parameters) {
        Logger.logInfo(String.format('parseParameters( {0} )', new List<Object>{ parameters }));

        if (parameters == null) {
            throw new NumberActivationLineExecutorHandlerException('parameters cannot be null.');
        }
        
        try{
            Parameters params = (Parameters) System.JSON.deserialize(parameters, NumberActivationLinesExecutorHandler.Parameters.class);

            if (params.activationLineIdToAssignementId.isEmpty())  {
                throw new NumberActivationLineExecutorHandlerException(
                    String.format('Both activationLineIdToMSISDN cannot be blank, empty or null', new List<Object>{ params })
                );
            }
            
            if( params.activationLineIdToAssignementId.containsKey(null) ){
                throw new NumberActivationLineExecutorHandlerException(
                    String.format('activationLineId cannot null', new List<Object>{ params })
                );
            }


            //validate that the key is a valid id.
            //This is not possible as '' is identified a not being a key!!! - if( params.activationLineIdToAssignementId.containsKey('') ){
            
        	return params;
        }catch(Exception ex){
            Logger.logInfo(ex);

            throw ex;
        }
    }

    /**
     * @description This method gets a map of assignments from a map of activation line IDs to assignment IDs.
     * @param mapOfActivationLineIdToAssignementId A map of activation line IDs to assignment IDs.
     * @return A map of assignment IDs to assignments.
     */
    private Map<Id, Account_Phone_Number_Assignment__c> getAssignmentsMap(Map<Id, String> mapOfActivationLineIdToAssignementId) {
       
        List<String> assignmentIds = mapOfActivationLineIdToAssignementId.values();
        Logger.logInfo(String.format('getAssignmentsMap( {0} )', new List<Object>{ assignmentIds }));
        
        Map<Id, Account_Phone_Number_Assignment__c> assignmentsMap = new Map<Id, Account_Phone_Number_Assignment__c> ([
            SELECT
                Id,
                Account__c,
                Account_Phone_Number_Series__c,
                Phone_Number__c,
                Phone_Number_Reservation_Status__c,
                Phone_Number_Reservation_Error__c,
                CTN_Number_Status__c,
                Account__r.cvr__c,
                Account_Phone_Number_Series__r.Product_Type__c,
                Activation_Line__c
            FROM Account_Phone_Number_Assignment__c
            WHERE Id  IN : assignmentIds
        ]);

        return assignmentsMap;
    }

    private Map<Id, Activation_Line__c> getActivationLineMap(Map<Id, String> mapOfActivationLineIdToAssignementId) {
       
        Set<Id> activationLineIds = mapOfActivationLineIdToAssignementId.keySet();
        Logger.logInfo(String.format('getActivationLineMap( {0} )', new List<Object>{ activationLineIds }));
        
        Map<Id, Activation_Line__c> activationLineMap = new Map<Id, Activation_Line__c> ([
            SELECT
                Id,
                first_Name__c,
                last_Name__c,
                email__c,
                Phone_Number_Reservation_Status__c, 
                Phone_Number_Reservation_Error__c,
                Mobile_No__c
            FROM Activation_Line__c
            WHERE Id IN :activationLineIds
        ]);

        return activationLineMap;
    }
    

    public class NumberActivationLinesExecutorHandlerException extends Exception {}
    
    public class Parameters {
        public Map<Id, String> activationLineIdToAssignementId;
    }
}