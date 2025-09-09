public with sharing class QuoteValidUntilBatch implements Database.Batchable<SBQQ__Quote__c>, Database.Stateful {
    @TestVisible
    private static List<Id> processedAccountIds = new List<Id>();
    private ErrorLogging errorLogs = new ErrorLogging('Apex');

    public List<SBQQ__Quote__c> start(Database.BatchableContext bc) {
        return QuoteSelector.getQuotesValidUntilYesterday();
    }

    public void execute(Database.BatchableContext bc, List<SBQQ__Quote__c> scope) {
        try {
            List<Id> accountIds = new List<Id>();
            for(SBQQ__Quote__c quote : scope) {
                accountIds.add(quote.SBQQ__Account__c);
            }
            ContractApiEventService.createEvents(accountIds);
            processedAccountIds.addAll(accountIds);
        } catch (Exception ex) {
            Logger.logError(QuoteValidUntilBatch.class.getName(), ex);
        }
    }

    public void finish(Database.BatchableContext bc) {
        Logger.emit();
    }
}