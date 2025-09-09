/**
 * The NumberReservationExecutorAction class is responsible for initiating the reservation of phone number assignments.
 * It takes a list of phone number assignments, chunks them, and publishes events to be handled by the NumberReservationExecutorHandler.
 *  -----------------------------------------------------------------------------
 *  Developer            Date            Description
 *  -----------------------------------------------------------------------------
 *  Kenneth Houkjær         27/07/2025      Initial version
 * 
 * @author Kenneth Houkjær
 * @date 27/07/2025
 */
public with sharing class NumberReservationExecutorAction {

    /**
     * This method takes a list of input variables, containing phone number assignments and a chunk size,
     * and publishes events to reserve the phone numbers.
     * @param inputVariables A list of InputVariables objects, each containing a list of phone number assignments and a chunk size.
     * @return A list of OutputVariables objects, each containing the list of published events.
     */
	@InvocableMethod(category='Number' label='Get the numbers for phone series' description='Fetch numbers with numberclient with data request information provided by the number serie.')
    public static List<OutputVariables> reservePhoneNumberAssignments(List<InputVariables> inputVariables) {        
        OutputVariables output = new OutputVariables();
        
        try{
            InputVariables vars = inputVariables.get(0);
            
            List<List<String>> chunkedPhoneNumberAssignments = (List<List<String>>) orgUtils.chunkListOfStrings(vars.chunkSize, vars.phoneNumberAssignments, List<List<String>>.class);
            
            List<EventExecutor__e> eventExecutors = new List<EventExecutor__e>();
            for(List<String> phoneNumberAssignmentList : chunkedPhoneNumberAssignments){
                EventExecutor__e executor = new EventExecutor__e();
				executor.Executor__c = SFConstants.NUMBER_RESERVATION_EXECUTOR_HANDLER;
                
                NumberReservationExecutorHandler.parameters params = new NumberReservationExecutorHandler.parameters();
                params.assignmentIds = new Set<String>(phoneNumberAssignmentList);
                executor.Parameters__c = JSON.serialize(params);
                
                eventExecutors.add(executor);
            }
            
            EventBus.publish(eventExecutors);
            
            output.publishedEvents = eventExecutors;
        }catch(Exception ex){
            Logger.logError(ex);
            Logger.emit();
            throw ex;
        }
        
        return new List<OutputVariables>{output};
	}
    
	public class InputVariables {
        @InvocableVariable
        public Integer chunkSize;
		@InvocableVariable
		public List<String> phoneNumberAssignments;
	}

	public class OutputVariables {
        @InvocableVariable
        public List<EventExecutor__e> publishedEvents;
        
        @InvocableVariable
        public Boolean isSuccess;
	}
}