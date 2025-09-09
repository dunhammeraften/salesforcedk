/**
 * The NumberReservationExecutorHandler class is responsible for handling the reservation of phone numbers.
 * It implements the IEventExecutableHandler interface and is triggered by an EventExecutor__e event.
 *  -----------------------------------------------------------------------------
 *  Developer            Date            Description
 *  -----------------------------------------------------------------------------
 *  Kenneth Houkjær         27/07/2025      Initial version
 *
 * @author Kenneth Houkjær
 * @date 27/07/2025
 */
public with sharing class NumberReservationExecutorHandler implements IEventExecutableHandler {
    private final NumberClient numberClient;
    private final DatabaseService databaseService;

    /**
     * Default constructor that initializes the NumberClient and DatabaseService using the SingletonFactory.
     */
    public NumberReservationExecutorHandler() {
        this(SingletonFactory.getFactory());
    }

    /**
     * Private constructor for dependency injection.
     * @param singletonFactory The SingletonFactory instance to use for creating dependencies.
     */
    private NumberReservationExecutorHandler(SingletonFactory singletonFactory) {
        this.numberClient = (NumberClient) singletonFactory.getOrRegisterSingleton(NumberClient.class);
        this.databaseService = (DatabaseService) singletonFactory.getOrRegisterSingleton(DatabaseService.class);
    }

    /**
     * Test-visible constructor for dependency injection during testing.
     * @param numberClient The NumberClient instance to use.
     * @param databaseService The DatabaseService instance to use.
     */
    @TestVisible
    private NumberReservationExecutorHandler(NumberClient numberClient, DatabaseService databaseService) {
        this.numberClient = numberClient;
        this.databaseService = databaseService;
    }

    /**
     * Executes the event handling logic. This method is called when an EventExecutor__e event is received.
     * It processes the phone number assignments, reserves them using the NumberClient, and updates their status.
     * @param event The EventExecutor__e event that triggered the handler.
     */
    public void execute(EventExecutor__e event) {
        // Log the execution start
        Logger.logInfo(String.format('execute( {0} )', new List<Object>{ event }));

        // Get the parameters from the event
        Parameters params = getParameters(event.Parameters__c);

        Map<Id, Account_Phone_Number_Assignment__c>  assignmentsMap;

        try {
            // Retrieve the phone number assignments from the database
            assignmentsMap = getAssignmentsMap(params.assignmentIds);
        } catch (QueryException ex) {
            // Log and throw an exception if there's an error querying the assignments
            Logger.logError('SOQL Error: ' + ex.getMessage());
            throw new NumberReservationExecutorHandlerException('SQOL Error finding assignment: ' + ex.getMessage());
        }

        // Iterate over each assignment and attempt to reserve the phone number
        for(String assignmentId : assignmentsMap.keySet()){
            Account_Phone_Number_Assignment__c assignment = assignmentsMap.get(assignmentId);
            
            try {
                // Call the NumberClient to reserve the phone number
                NumberClientResponseDTO.NumberDetail numberReservationResponse = numberClient.reserveNumberDetailByMsisdnAndCVR(
                    assignment.Phone_Number__c, 
                    assignment.Account__r.Cvr__c, 
                    assignment.Account_Phone_Number_Series__r?.Product_Type__c);

                // Check the response and update the assignment status accordingly
                if (numberReservationResponse.data != null &&
                    numberReservationResponse.data.id != null) {
                        assignment = setSuccessOnAssignment(assignment);
                } 
                else {
                    // Handle unexpected response
                    String errorMessage = String.format(
                        'numberReservationResponse( {0} , {1} ) response was not expected.' +
                        (assignmentsMap == null ? ' assignmentsMap is NULL.' : ''),
                        new List<Object>{ numberReservationResponse, assignmentsMap }
                    );

                    Logger.logInfo(errorMessage);

                    assignment = setErrorOnAssignment(assignment, errorMessage);
                }

                // Remove the assignment from the list of pending assignments
                params.assignmentIds.remove(assignmentId);
            } catch (HTTPException ex) {
                // Handle HTTP exceptions
                switch on ex.getStatusCode() {
                    when 500 {
                        Logger.logError(ex);
                    }when else{
                        params.assignmentIds.remove(assignmentId);
                    }
                }
                assignment = setErrorOnAssignment(assignment, ex.getMessage());
            } catch (System.CalloutException e) {
                // Handle callout exceptions
                Logger.logError(e);

                params.assignmentIds.remove(assignmentId);
                
                assignment = setErrorOnAssignment(assignment, e.getMessage());
            }
        }

        // Update the assignments in the database
        try {
            databaseService.updateRecords(assignmentsMap.values());
        } catch (DmlException ex) {
            Logger.logError('DML error updating assignmentToUpdate: ' + ex.getMessage());
            throw new NumberReservationExecutorHandlerException(
                'Error when updating assignmentToUpdate: ' + ex.getMessage()
            );
        }
        
        // If there are any remaining assignments, retry the process
        if(!params.assignmentIds.isEmpty() ){
            EventExecutor__e retryEventExecutor = new EventExecutor__e();
            retryEventExecutor.Parameters__c = JSON.serialize(params);
            retryEventExecutor.Executor__c = event.Executor__c;
            retryEventExecutor.RetryCount__c = event.RetryCount__c+1;
            retryEventExecutor.LastEventExecutorException__c = 'Events failed try to rerun!';
            retryEventExecutor.LastEventExecutorUuid__c = event.EventUuid;
            retryEventExecutor.LastEventExecutorReplayId__c = event.ReplayId;
            
        	EventBus.publish(retryEventExecutor);
        }
    }

    /**
     * Parses the JSON parameters from the event into a Parameters object.
     * @param parameters The JSON string containing the parameters.
     * @return A Parameters object.
     * @throws NumberReservationExecutorHandlerException if the parameters are invalid.
     */
    @testvisible
    private Parameters getParameters(String parameters) {
        Logger.logInfo(String.format('parseParameters( {0} )', new List<Object>{ parameters }));

        if (parameters == null) {
            throw new NumberReservationExecutorHandlerException('parameters cannot be null.');
        }

        Parameters params;
        
        try {
            // Attempt to deserialize the parameters into the Parameters class
            params = (Parameters) System.JSON.deserialize(parameters, Parameters.class);
        } catch (System.JSONException ex) {
            // Handle JSONException by throwing a custom handler exception
            Logger.logError('NumberReservationExecutorHandler', 'Failed to parse JSON parameters.' + ex);
            throw new NumberReservationExecutorHandlerException('Failed to parse JSON parameters.', ex);
        }

        // Validate that assignmentIds list is filled properly
        for (String assignId : params.assignmentIds) {
            if (String.isBlank(assignId)) {
                throw new NumberReservationExecutorHandlerException(
                    'assignmentIds is a required parameter and cannot be blank, empty, or null'
                );
            }
        }

        return params;
    }


    /**
     * Sets the assignment status to 'Success'.
     * @param assignment The assignment to update.
     * @return The updated assignment.
     */
    @TestVisible
    private Account_Phone_Number_Assignment__c setSuccessOnAssignment(Account_Phone_Number_Assignment__c assignment) {
        Logger.logInfo(String.format('setSuccessOnAssignment( {0} )', new List<Object>{ assignment }));
        if (assignment == null) {
            Logger.logError('Assignment is null.');
            return null;
        }

        assignment.Phone_Number_Reservation_Status__c = SFConstants.SUCCESS;
        assignment.Phone_Number_Reservation_Error__c = null;
        assignment.CTN_Number_Status__c = SFConstants.ASSIGNED_RESERVED;
        
        return assignment;
    }

    /**
     * Sets the assignment status to 'Error' and records the error message.
     * @param assignment The assignment to update.
     * @param errorMessage The error message to record.
     * @return The updated assignment.
     */
    @TestVisible
    private Account_Phone_Number_Assignment__c setErrorOnAssignment(Account_Phone_Number_Assignment__c assignment, String errorMessage) {
        if (assignment == null) {
            Logger.logError('Assignment is null. Cannot set error: ' + errorMessage);
            return null;
        }
        Logger.logInfo(
            String.format(
                'setErrorOnAssignment( {0}, {1} )',
                new List<Object>{ assignment, errorMessage }
            )
        );

        assignment.Phone_Number_Reservation_Status__c = SFConstants.ERROR;
        assignment.Phone_Number_Reservation_Error__c = errorMessage;
        
        return assignment;
    }

    /**
     * Retrieves a map of phone number assignments from the database.
     * @param assignmentIds A set of assignment IDs to retrieve.
     * @return A map of assignment IDs to Account_Phone_Number_Assignment__c objects.
     */
    private Map<Id, Account_Phone_Number_Assignment__c> getAssignmentsMap(Set<String> assignmentIds) {
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
                Account_Phone_Number_Series__r.Product_Type__c
            FROM Account_Phone_Number_Assignment__c
            WHERE Id  IN : assignmentIds
        ]);

        return assignmentsMap;
    }

    public class NumberReservationExecutorHandlerException extends Exception {}
    
    public class Parameters {
        public Set<String> assignmentIds;
    }
}