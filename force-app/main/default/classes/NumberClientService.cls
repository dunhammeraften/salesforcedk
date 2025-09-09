/**
 * @author Kenneth Houkjær
 * @date 25/07/2024
 * @description A service class for the numberclient API
 */
public with sharing class NumberClientService {
    private final NumberClient numberClient;
    private final DatabaseService databaseService;

     public NumberClientService() {
        this(SingletonFactory.getFactory());
    }

    private NumberClientService(SingletonFactory singletonFactory) {
        this.numberClient = (NumberClient) singletonFactory.getOrRegisterSingleton(NumberClient.class);
        this.databaseService = (DatabaseService) singletonFactory.getOrRegisterSingleton(DatabaseService.class);
    }

    @TestVisible
    private NumberClientService(NumberClient numberClient, DatabaseService databaseService) {
        this.numberClient = numberClient;
        this.databaseService = databaseService;
    }

    /**
     * @description resets account_phone_number_assignments and unreserves the number if needed.
     * The method will look at assignments matched on both number and activationlineid, theyre probably the same so the 
     * method will only do the first match on each set.
     * If the assignment is a fixed series, i.e., one assigned to the customer, then the number will have been reserved when 
     * it was assigned to the activationline. In this case the number is unreserved to AA.
     * If the assignment is an open series, the number is just reset, but the status remains AR.
     * @param chunkSize How many operations per transaction
     * @param mapOfActivationLineIdToNumberToReset Map of activation line id to phone number to reset
     */
    public Boolean resetPhoneNumberAssignments(Integer chunkSize, Map<Id, String> mapOfActivationLineIdToNumberToReset) {
        try{

            List<Object> activationLineIdToNumberList = new List<Object>();
            for(Id activationLineId : mapOfActivationLineIdToNumberToReset.keySet()){
                Map<Id, String> activationLineIdToNumber = new Map<Id, String>();
                activationLineIdToNumber.put(activationLineId, mapOfActivationLineIdToNumberToReset.get(activationLineId));
                activationLineIdToNumberList.add(activationLineIdToNumber);
            }

            List<List<Object>> chunkedActivationLineIdToNumberList = OrgUtils.chunkList(chunkSize, activationLineIdToNumberList);
            
            List<EventExecutor__e> eventExecutors = new List<EventExecutor__e>();

            for(List<Object> activationLineIdToNumberChunk : chunkedActivationLineIdToNumberList){
                EventExecutor__e executor = new EventExecutor__e();
				executor.Executor__c = SFConstants.NUMBER_ASSIGNMENT_RESET_EXECUTOR_HANDLER;
                
                NumberAssignmentResetExecutorHandler.parameters params = new NumberAssignmentResetExecutorHandler.parameters();
                params.activationLineIdToNumber = new Map<Id, String>();
                for(Object activationLineToNumber : activationLineIdToNumberChunk){
                    params.activationLineIdToNumber.putAll((Map<Id, String>)activationLineToNumber);
                }
                executor.Parameters__c = JSON.serialize(params);
                
                eventExecutors.add(executor);
            }
            
            EventBus.publish(eventExecutors);

            return true;
        }
        catch(Exception ex){
            Logger.logError(ex);
            Logger.emit();
            throw ex;
        }
	}
}