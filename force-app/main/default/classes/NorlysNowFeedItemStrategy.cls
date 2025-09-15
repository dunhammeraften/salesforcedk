public class NorlysNowFeedItemStrategy implements INorlysNowIntegrationStrategy{
    private final NorlysNowService norlysNowService;
    private final NorlysNowSelector norlysNowSelector;
    private final DatabaseService databaseService;
    private final NorlysNowClient norlysNowClient;
    
    public NorlysNowFeedItemStrategy() {
        this(SingletonFactory.getFactory());
    }

    private NorlysNowFeedItemStrategy(SingletonFactory singletonFactory) {
        this.norlysNowService = (NorlysNowService) singletonFactory.getOrRegisterSingleton(NorlysNowService.class);
        this.norlysNowSelector = (NorlysNowSelector) singletonFactory.getOrRegisterSingleton(NorlysNowSelector.class);
        this.norlysNowClient = (NorlysNowClient) singletonFactory.getOrRegisterSingleton(NorlysNowClient.class);
        this.databaseService = (DatabaseService) singletonFactory.getOrRegisterSingleton(DatabaseService.class);
    }

    public Set<Id> toExecute(EventExecutor__e event) {
        Logger.logInfo(String.format('toExecute( {0} )', new List<Object>{ event }));

        NorlysNowService.Parameters params = norlysNowService.getParameters(event.Parameters__c);

        Set<Id> recordIds = params.recordIds;
       
        Map<Id, FeedItem> feedItemMap = new Map<Id, FeedItem>();

        try {
            // Retrieve the FeedItem from the database
            feedItemMap = norlysNowSelector.getFeedItemMap(params.recordIds);
        } catch (QueryException ex) {
            // Log and throw an exception if there's an error querying the FeedComment
            Logger.logError('SOQL Error: ' + ex.getMessage());
            throw new NorlysNowFeedItemStrategyException('SQOL Error finding FeedComment: ' + ex.getMessage());
        }

        List<NorlysNow_Case__c> norlysNowCasesToUpdate = new List<NorlysNow_Case__c>();
        List<NorlysNow_Case__c> norlysNowCasesToNotify = new List<NorlysNow_Case__c>();

        for(Id feedItemId : feedItemMap.keySet()){

            FeedItem fi = feedItemMap.get(feedItemId);

            NorlysNow_Case__c norlysNowCase = new NorlysNow_Case__c(Id = fi.ParentId);

            String plainComment = fi.Body.replaceAll('<[^>]+>', ''); // Strip HTML tags to get plain text

            NorlysNowClientRequestDTO requestObject = norlysNowService.createCaseCommentRequestObject(
                    norlysNowCase.Id, 
                    'insert',
                    norlysNowCase.Id,
                    'Salesforce Inbound – Incident',
                    'synchronous',
                    'Salesforce',
                    norlysNowCase.Id,
                    plainComment
                );
            
            try {              
                norlysNowClient.sentRequestNorlysNowCase(requestObject);

                norlysNowCasesToUpdate.add(norlysNowService.setSuccessOnNorlysNowCase(norlysNowCase));
                
                // Success → remove id from retry set
                recordIds.remove(feedItemId);
            } catch (HTTPException ex) {
                // Handle HTTP exceptions
                switch on ex.getStatusCode() {
                    when 500 {
                        Logger.logError(ex);
                    }when else{
                        Logger.logError('HTTPException error updating NorlysNowCases To Update: ' + ex.getMessage());
                        recordIds.remove(feedItemId);
                        norlysNowCasesToUpdate.add(norlysNowService.setErrorOnNorlysNowCase(norlysNowCase, ex.getMessage()));
                        norlysNowCasesToNotify.add(norlysNowCase);   
                    }
                }
            } catch (System.CalloutException ex) {
                // Handle callout exceptions
                Logger.logError(ex);
                recordIds.remove(feedItemId);
                norlysNowCasesToUpdate.add(norlysNowService.setErrorOnNorlysNowCase(norlysNowCase, ex.getMessage()));
                norlysNowCasesToNotify.add(norlysNowCase);   
            }
        }

        // Update the NorlysNowCase in the database
        try {
            databaseService.updateRecords(norlysNowCasesToUpdate);
        } catch (DmlException ex) {
            Logger.logError('DML error updating NorlysNowCase To Update: ' + ex.getMessage());
            throw new NorlysNowFeedItemStrategyException(
                'Error when updating NorlysNowCase: ' + ex.getMessage()
            );
        }

        if(!norlysNowCasesToNotify.isEmpty()){
            norlysNowService.createFollowUpTasks(norlysNowCasesToNotify, 'NorlysNow Case Comment/Post not delivered to NorlysNow', 'Please create a new Post to the NorlysNow case to resend the comment to NorlysNow', Date.today());
        }

        return recordIds;
    }

    public class NorlysNowFeedItemStrategyException extends Exception {}

}
