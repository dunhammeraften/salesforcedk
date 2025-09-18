public with sharing class NorlysNowExecutorHandler implements IEventExecutableHandler {
    private final NorlysNowService norlysNowService;
    private final EventExecutorService eventExecutorService;
    private final Map<String, INorlysNowIntegrationStrategy> strategies;
    
    public NorlysNowExecutorHandler() {
        this(SingletonFactory.getFactory());
    }

    private NorlysNowExecutorHandler(SingletonFactory singletonFactory) {
        this.norlysNowService = (NorlysNowService) singletonFactory.getOrRegisterSingleton(NorlysNowService.class);
        this.eventExecutorService = (EventExecutorService) singletonFactory.getOrRegisterSingleton(EventExecutorService.class);
        this.strategies = new Map<String, INorlysNowIntegrationStrategy>{
            'NorlysNow_Case__c' => (NorlysNowCaseStrategy) singletonFactory.getOrRegisterSingleton(NorlysNowCaseStrategy.class),
            'FeedItem' => (NorlysNowFeedItemStrategy) singletonFactory.getOrRegisterSingleton(NorlysNowFeedItemStrategy.class),
            'ContentDocumentLink' => (NorlysNowContentDocumentLinkStrategy) singletonFactory.getOrRegisterSingleton(NorlysNowContentDocumentLinkStrategy.class)
        };
    }

    public void execute(EventExecutor__e event) {
        Logger.logInfo(String.format('execute( {0} )', new List<Object>{ event }));
        norlysNowService.Parameters params = norlysNowService.getParameters(event.Parameters__c);
        String type = params.type;
        INorlysNowIntegrationStrategy strategy = strategies.get(type);

        if (strategy != null) {
            Set<Id> recordIds = strategy.toExecute(event);
        
            // If there are any remaining assignments, retry the process
            if(!recordIds.isEmpty() ){
                params.recordIds = recordIds;
                EventExecutor__e retryEventExecutor = new EventExecutor__e();
                retryEventExecutor.Parameters__c = JSON.serialize(params);
                retryEventExecutor.Executor__c = event.Executor__c;
                retryEventExecutor.RetryCount__c = event.RetryCount__c+1;
                retryEventExecutor.LastEventExecutorException__c = 'Events failed try to rerun!';
                retryEventExecutor.LastEventExecutorUuid__c = event.EventUuid;
                retryEventExecutor.LastEventExecutorReplayId__c = event.ReplayId;
                
                eventExecutorService.publish(retryEventExecutor);
            }else{
                Logger.logInfo('No recordIds found: ' + recordIds);
            }
        } else {
            Logger.logError('No strategy found for type: ' + type);
        }
    }
}