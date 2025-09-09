trigger QuoteTrigger on SBQQ__Quote__c (after insert, before update, after update) {
    new QuoteTriggerHandler().run();
}