public class NorlysNowCaseStrategy implements INorlysNowIntegrationStrategy{
    private final NorlysNowService norlysNowService;
    private final NorlysNowSelector norlysNowSelector;
    private final DatabaseService databaseService;
    private final NorlysNowClient norlysNowClient;
    
    public NorlysNowCaseStrategy() {
        this(SingletonFactory.getFactory());
    }

    private NorlysNowCaseStrategy(SingletonFactory singletonFactory) {
        this.norlysNowService = (NorlysNowService) singletonFactory.getOrRegisterSingleton(NorlysNowService.class);
        this.norlysNowSelector = (NorlysNowSelector) singletonFactory.getOrRegisterSingleton(NorlysNowSelector.class);
        this.norlysNowClient = (NorlysNowClient) singletonFactory.getOrRegisterSingleton(NorlysNowClient.class);
        this.databaseService = (DatabaseService) singletonFactory.getOrRegisterSingleton(DatabaseService.class);
    }

    public Set<Id> toExecute(EventExecutor__e event) {
        Logger.logInfo(String.format('execute( {0} )', new List<Object>{ event }));

        NorlysNowService.Parameters params = norlysNowService.getParameters(event.Parameters__c);
        Set<Id> recordIds = params.recordIds;
        Map<Id, NorlysNow_Case__c>  norlysNowCasesMap = norlysNowSelector.getNorlysNowCasesMap(recordIds);
        Map<Id, NorlysNow_Case__c> toUpdateNorlysNowCasesMap = new Map<Id, NorlysNow_Case__c>();
        List<NorlysNow_Case__c> norlysNowCasesToNotify = new List<NorlysNow_Case__c>();

        for(Id norlysNowCaseId : norlysNowCasesMap.keySet()){
            NorlysNow_Case__c norlysNowCase = norlysNowCasesMap.get(norlysNowCaseId);

            NorlysNowClientRequestDTO requestObject = norlysNowService.createCaseRequestObject(
                norlysNowCase.Id, 
                'insert',
                norlysNowCase.Id,
                'Salesforce Inbound – Incident',
                'synchronous',
                'Salesforce',
                norlysNowCase.Id,
                null,
                norlysNowCase.Priority__c,
                norlysNowCase.Description__c,
                norlysNowCase.Title__c,
                norlysNowCase.Type__c,
                norlysNowCase.Status__c,
                norlysNowCase.Request_Source__c,
                norlysNowCase.Category__c,
                norlysNowCase.Technology_Type__c,
                norlysNowCase.Technology__c
            );

            try {
                // Call the norlysNowClient to create or update the case in NorlysNow
                HttpResponse httpResponse = norlysNowClient.sentRequestNorlysNowCase(requestObject);
                Map<String, Object> raw = (Map<String, Object>) JSON.deserializeUntyped(httpResponse.getBody());
                Map<String, Object> result = (Map<String, Object>) raw.get('result');

                if(norlysNowCase.Status__c == 'New' ) {                     
                    if (result.get('created record number') != null) {
                        norlysNowCase.NorlysNow_Id__c = (String) result.get('created record number');
                    }else{
                        Logger.logError('No NorlysNow record number found: ' + norlysNowCase.Id);
                    }
                }                        
                             
                toUpdateNorlysNowCasesMap.put(norlysNowCase.Id, norlysNowService.setSuccessOnNorlysNowCase(norlysNowCase));
                // Remove the norlysNowCase from the list of pending norlysNowCases
                recordIds.remove(norlysNowCaseId);
            } catch (HTTPException ex) {
                // Handle HTTP exceptions
                switch on ex.getStatusCode() {
                    when 500 {
                        Logger.logError(ex); // If reach this point then we want to retry this event
                    }when else{
                        Logger.logError('HTTPException error updating NorlysNowCases To Update: ' + ex.getMessage());
                        recordIds.remove(norlysNowCaseId);
                        toUpdateNorlysNowCasesMap.put(norlysNowCase.Id, norlysNowService.setErrorOnNorlysNowCase(norlysNowCase, ex.getMessage()));
                        norlysNowCasesToNotify.add(norlysNowCase);
                    }
                }
            } catch (System.CalloutException ex) {
                // Handle callout exceptions
                Logger.logError(ex);
                recordIds.remove(norlysNowCaseId);
                toUpdateNorlysNowCasesMap.put(norlysNowCase.Id, norlysNowService.setErrorOnNorlysNowCase(norlysNowCase, ex.getMessage()));
                norlysNowCasesToNotify.add(norlysNowCase);
            }
        }

        // Update the NorlysNowCases in the database
        try {
            if(!toUpdateNorlysNowCasesMap.isEmpty()){
                databaseService.updateRecords(toUpdateNorlysNowCasesMap.values());
            }
        } catch (DmlException ex) {
            Logger.logError('DML error updating NorlysNowCases or ParentCases to Update: ' + ex.getMessage());
            throw new NorlysNowCaseStrategyException(
                'Error when updating NorlysNowCases or ParentCases: ' + ex.getMessage()
            );
        }

        if(!norlysNowCasesToNotify.isEmpty()){
            norlysNowService.createFollowUpTasks(norlysNowCasesToNotify, 'NorlysNow Case not delivered to NorlysNow', 'Please resent the NorlysNow case by setting Sync Status to Pending', Date.today());
        }

        return recordIds;
    }

    public class NorlysNowCaseStrategyException extends Exception {}

}
