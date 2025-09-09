/**
 * The NumberActivationLinesExecutorAction class is an invocable action that assigns phone numbers to activation lines.
 * It is used in a flow to process a list of activation lines and assign phone numbers to them.
 *  -----------------------------------------------------------------------------
 *  Developer            Date            Description
 *  -----------------------------------------------------------------------------
 *  Kenneth Houkjær         27/07/2025      Initial version
 *
 * @author Kenneth Houkjær
 * @date 27/07/2025
 */
public with sharing class NumberActivationLinesExecutorAction {

    /**
     * @description This method is called from a flow to assign phone numbers to activation lines.
     * @param inputVariables A list of input variables from the flow.
     * @return A list of output variables containing the published events and a success flag.
     */
	@InvocableMethod(category='Number' label='Assign Numbers To ActivationLines' description='Uses available assignment numbers to set phonenumber on activation lines.')
    public static List<OutputVariables> assignNumbersToActivationLines(List<InputVariables> inputVariables) {        
        OutputVariables output = new OutputVariables();
        
        try{
            InputVariables vars = inputVariables.get(0);
            
            Map<Id, String> activationLineIdToAssignementIdMap = new Map<Id, String>();
            for(IdToString its : vars.activationLineIdToAssignementId){
                activationLineIdToAssignementIdMap.put(its.key, its.value);
            }
            
            List<Object> activationLineIdToAssignementIdList = new List<Object>();
            for(Id activationLineId : activationLineIdToAssignementIdMap.keySet()){
                Map<Id, String> activationLineIdToAssignementId = new Map<Id, String>();
                activationLineIdToAssignementId.put(activationLineId, activationLineIdToAssignementIdMap.get(activationLineId));
                activationLineIdToAssignementIdList.add(activationLineIdToAssignementId);
            }

            List<List<Object>> chunkedActivationLineIdToAssignementIdList = orgUtils.chunkList(vars.chunkSize, activationLineIdToAssignementIdList);
            
            List<EventExecutor__e> eventExecutors = new List<EventExecutor__e>();
            for(List<Object> activationLineIdToAssignementIdChunk : chunkedActivationLineIdToAssignementIdList){
                EventExecutor__e executor = new EventExecutor__e();
				executor.Executor__c = SFConstants.NUMBER_ACTIVATION_LINES_EXECUTOR_HANDLER;
                
                NumberActivationLinesExecutorHandler.parameters params = new NumberActivationLinesExecutorHandler.parameters();
                params.activationLineIdToAssignementId = new Map<Id, String>();
                for(Object activationLineIdToAssignementId : activationLineIdToAssignementIdChunk){
                    params.activationLineIdToAssignementId.putAll((Map<Id, String>)activationLineIdToAssignementId);
                }
                executor.Parameters__c = JSON.serialize(params);
                
                eventExecutors.add(executor);
            }
            
            EventBus.publish(eventExecutors);
            
            output.publishedEvents = eventExecutors;
            output.isSuccess = true;
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
		public List<IdToString> activationLineIdToAssignementId;
	}

	public class OutputVariables {
        @InvocableVariable
        public List<EventExecutor__e> publishedEvents;
        
        @InvocableVariable
        public Boolean isSuccess = false;
	}
}