trigger NorlysNowCaseTrigger on NorlysNow_Case__c (before insert, after insert, after update, before update) {
    new NorlysNowCaseTriggerHandler().run();
}