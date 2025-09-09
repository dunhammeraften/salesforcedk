/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
trigger dlrs_SBQQ_QuoteLineTrigger on SBQQ__QuoteLine__c
    (before delete, before insert, before update, after delete, after insert, after undelete, after update)
{
    if(Trigger.isAfter && Trigger.isDelete){

        Map<String, Object> params = new Map<String, Object>();
        
        params.put('QuoteID', trigger.old[0].SBQQ__Quote__c );
        Flow.Interview.Quote_Line_DLRS DummyFlow = new Flow.Interview.Quote_Line_DLRS(params);
            DummyFlow.start();
    }else {
        dlrs.RollupService.triggerHandler(SBQQ__QuoteLine__c.SObjectType);
    }
}