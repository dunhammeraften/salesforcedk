public with sharing class NorlysNowContentDocumentLinkStrategy implements INorlysNowIntegrationStrategy {
    private final NorlysNowService norlysNowService;
    private final NorlysNowSelector norlysNowSelector;
    private final DatabaseService databaseService;
    private final NorlysNowClient norlysNowClient;

    public NorlysNowContentDocumentLinkStrategy() {
        this(SingletonFactory.getFactory());
    }

    private NorlysNowContentDocumentLinkStrategy(SingletonFactory singletonFactory) {
        this.norlysNowService = (NorlysNowService) singletonFactory.getOrRegisterSingleton(NorlysNowService.class);
        this.norlysNowSelector = (NorlysNowSelector) singletonFactory.getOrRegisterSingleton(NorlysNowSelector.class);
        this.norlysNowClient = (NorlysNowClient) singletonFactory.getOrRegisterSingleton(NorlysNowClient.class);
        this.databaseService = (DatabaseService) singletonFactory.getOrRegisterSingleton(DatabaseService.class);
    }

    @TestVisible
    private NorlysNowContentDocumentLinkStrategy(NorlysNowService norlysNowService, NorlysNowSelector norlysNowSelector, NorlysNowClient norlysNowClient, DatabaseService databaseService) {
        this.norlysNowService = norlysNowService;
        this.norlysNowSelector = norlysNowSelector;
        this.norlysNowClient = norlysNowClient;
        this.databaseService = databaseService;
    }

    public Set<Id> toExecute(EventExecutor__e event) {
        Logger.logInfo(String.format('toExecute( {0} )', new List<Object>{ event }));

        norlysNowService.Parameters params = norlysNowService.getParameters(event.Parameters__c);
        Set<Id> recordIds = params.recordIds;

        Map<Id, Id> fileToCaseMap = new Map<Id, Id>();
        for (ContentDocumentLink cdl : norlysNowSelector.getContentDocumentLinks(recordIds)) {
            fileToCaseMap.put(cdl.ContentDocumentId, cdl.LinkedEntityId);
        }

        Map<Id, ContentVersion> fileIdToVersion = norlysNowService.getFileIdToVersion(recordIds);

        //Is this needed - can you have a ContentDocumentLink without a ContentVersion?
        if (fileIdToVersion.isEmpty()) {
            Logger.logError('No ContentVersions found for recordIds: ' + recordIds);
            return new Set<Id>();
        }

        List<NorlysNow_Case__c> norlysNowCasesToUpdate = new List<NorlysNow_Case__c>();
        List<NorlysNow_Case__c> norlysNowCasesToNotify = new List<NorlysNow_Case__c>();

        for (Id fileId : fileIdToVersion.keySet()) {
            ContentVersion cv = fileIdToVersion.get(fileId);
            Id caseId = fileToCaseMap.get(fileId);

            NorlysNow_Case__c norlysNowCase = new NorlysNow_Case__c(Id = caseId);

            // Convert to a Base64 blob 
            String base64Data = EncodingUtil.base64Encode(cv.VersionData);

            // Build request
            NorlysNowClientRequestDTO requestObject = norlysNowService.createFileRequestObject(
                norlysNowCase.Id,
                'insert',     
                norlysNowCase.Id,
                'Salesforce Inbound – Attachment',
                'synchronous',
                'Salesforce',
                norlysNowCase.Id,
                base64Data,
                cv.PathOnClient
            );

            try {
                norlysNowClient.sentRequestNorlysNowCase(requestObject);
                
                norlysNowCasesToUpdate.add(norlysNowService.setSuccessOnNorlysNowCase(norlysNowCase));

                // Success → remove id from retry set
                recordIds.remove(fileId);
            } catch (HTTPException ex) {
                // Handle HTTP exceptions
                switch on ex.getStatusCode() {
                    when 500 {
                        Logger.logError(ex); // If reach this point then we want to retry this event
                    }when else{
                        Logger.logError('Error sending file to NorlysNow for fileId ' + fileId + ': ' + ex.getMessage());
                        recordIds.remove(fileId);
                        norlysNowCasesToUpdate.add(norlysNowService.setErrorOnNorlysNowCase(norlysNowCase, ex.getMessage()));
                        norlysNowCasesToNotify.add(norlysNowCase);
                    }
                }
            }catch (System.CalloutException ex) {
                // Handle callout exceptions
                Logger.logError(ex);
                recordIds.remove(fileId);
                norlysNowCasesToUpdate.add(norlysNowService.setErrorOnNorlysNowCase(norlysNowCase, ex.getMessage()));
                norlysNowCasesToNotify.add(norlysNowCase);   
            }
        }

        // Update the NorlysNowCase in the database
        try {
            databaseService.updateRecords(norlysNowCasesToUpdate);
        } catch (DmlException ex) {
            Logger.logError('DML error updating NorlysNowCase To Update: ' + ex.getMessage());
            throw new NorlysNowContentDocumentLinkStrategyException(
                'Error when updating NorlysNowCase: ' + ex.getMessage()
            );
        }

        if(!norlysNowCasesToNotify.isEmpty()){
            norlysNowService.createFollowUpTasks(norlysNowCasesToNotify, 'NorlysNow Case file or attachment not delivered to NorlysNow', 'Please remove and attached the file and reattach it to send it again', Date.today());
        }

        return recordIds; // to be retried
    }

    public class NorlysNowContentDocumentLinkStrategyException extends Exception {}
}
