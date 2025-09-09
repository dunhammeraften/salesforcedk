@IsTest
public with sharing class SubscriptionLineDetailTriggerHandlerTest {
    
    //@TestSetup
    static void dataSettingUp(){
        SBQQ.TriggerControl.disable();
        List<Account> testAccounts = testDataFactory.createAccountsForTests( 1 );

        List<Opportunity> testOpps = testDataFactory.createOpportunitiesForAccounts( 1, testAccounts );

        List<SBQQ__Quote__c> testQuote = testDataFactory.createQuotesForOpps( 1, testOpps );

        List<SBQQ__QuoteLine__c> testQuoteLines = testDataFactory.createQuoteLineRecordsForQuote( 1, testQuote, 1, 1 ,false);

        List<Quote_Line_Detail__c> testQuoteLineDetails = testDataFactory.createQuoteLineDetailsForQuoteLines( 1, testQuoteLines );

         Contract cr = new Contract(AccountId = testAccounts[0].Id,
                                                           Total_Contract_value__c = decimal.valueOf(6000),
                                                           Migrated_Contract__c = true,
                                                           Pricebook2Id = Test.getStandardPricebookId(),
                                                           SBQQ__AmendmentPricebookId__c = Test.getStandardPricebookId(),
                                                           SBQQ__RenewalPricebookId__c = Test.getStandardPricebookId(),
                                                           SBQQ__AmendmentRenewalBehavior__c = 'Latest End Date',
                                                           Product_s_in_scope__c = 'Voice',
                                                           SBQQ__RenewalTerm__c = 36,
                                                           Mobile_Part_of_Contract__c = true,
                                   						   SBQQ__RenewalForecast__c = false
                                                            ); 
        insert cr;
        
        cr.Status = 'Activated';
        cr.StartDate = Date.newInstance(2012, 12, 12);
        cr.SBQQ__RenewalForecast__c = false;
        cr.ContractTerm = 36;
        cr.Renewal_Opportunity_Creation_Date__c = Date.newInstance(2012, 12, 12);
        
        update cr;
                 SBQQ__Subscription__c newSubscription = new SBQQ__Subscription__c(
                         SBQQ__Contract__c = cr.Id,
                         SBQQ__Discount__c = 0,
                         SBQQ__Product__c = testQuoteLines[0].SBQQ__Product__c,
                         SBQQ__Quantity__c = 1, //TODO!!
                         SBQQ__Account__c = testAccounts[0].Id,
                         SBQQ__ProductSubscriptionType__c = 'Renewable',
                         SBQQ__SubscriptionType__c = 'Renewable',
                         SBQQ__RenewalQuantity__c = 1,   //TODO trigger
                         SBQQ__RenewalPrice__c = 0,
                         SBQQ__NetPrice__c = 0,
                         SBQQ__CustomerPrice__c = 0,
                         SBQQ__ListPrice__c = 0,
                         SBQQ__RegularPrice__c = 0,
                         SBQQ__SpecialPrice__c = 0,
         				 SBQQ__QuoteLine__c =testQuoteLines[0].Id );
         insert newSubscription;

        Subscription_Line_Detail__c SubscriptionLine = new Subscription_Line_Detail__c();
        
                    SubscriptionLine.Subscription__c =  newSubscription.Id;
                    SubscriptionLine.First_name__c = 'Test';
                    SubscriptionLine.Max_Monthly_Data_Used_MB__c =0;
                    SubscriptionLine.Manual_Product__c = testQuoteLines[0].SBQQ__Product__c;
                    SubscriptionLine.Fokus_SOC__c = 'CORP1';
                    SubscriptionLine.Mobile_no__c = '124578';
                    SubscriptionLine.Avg_Monthly_Data_Used_MB__c = 0;
                    SubscriptionLine.EAN_number__c = 0;
        
        insert SubscriptionLine;
    }

    @IsTest
    static void changeAdditionalQuantityTest(){
        dataSettingUp();

        List<SBQQ__Subscription__c> testQLList = [SELECT Id, SBQQ__Quantity__c, (SELECT Id FROM Subscription_Line_Details__r) FROM SBQQ__Subscription__c];
        
        for( SBQQ__Subscription__c singleQL: testQLList ){
            singleQL.SBQQ__Quantity__c  = 3;
        }

        update testQLList;

        List<SBQQ__Subscription__c> testQLListCompare = [SELECT Id, SBQQ__Quantity__c, (SELECT Id FROM Subscription_Line_Details__r) FROM SBQQ__Subscription__c];

        for( Integer i = 0 ; i<testQLList.size() ; ++i ){
            for( Integer j = 0 ; j<testQLListCompare.size() ; ++j ){
                if( testQLList[i].Id == testQLListCompare[j].Id ){
                    //System.assertEquals( testQLListCompare[j].Additional_Quantity__c + testQLListCompare[j].Quote_Line_Details__r.size(), testQLListCompare[j].SBQQ__Quantity__c, 'Quantity should be equal to number of QLD + additional quantity');
                    //System.assertNotEquals( testQLListCompare[j].SBQQ__Quantity__c, testQLList[i].SBQQ__Quantity__c, 'The value should update with change in Additional Quantity');
                    break;
                }
            }
        }
    }
}