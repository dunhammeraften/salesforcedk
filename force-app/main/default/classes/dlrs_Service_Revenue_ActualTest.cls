/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
@IsTest
private class dlrs_Service_Revenue_ActualTest
{
    @IsTest
    private static void testTrigger()
    {
        Account acct = new Account(Name='TestAccount', BillingCity='CP',BillingPostalCode = '2000',BillingCountry = 'DK'
                                           ,BillingStreet = 'Holmbladsgade 133', Phone = '111', CVR__c ='12345678');
        insert acct;
               
        // Force the dlrs_Service_Revenue_ActualTrigger to be invoked, fails the test if org config or other Apex code prevents this.
        dlrs.RollupService.testHandler(new Service_Revenue_Actual__c(Account__c = acct.Id));
    }
}