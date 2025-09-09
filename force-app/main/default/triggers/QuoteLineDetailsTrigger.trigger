trigger QuoteLineDetailsTrigger on Quote_Line_Detail__c ( before insert, after insert, before update, after update, after delete, after undelete ) {
    new QuoteLineDetailsTriggerHandler().run();
}