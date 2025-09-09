/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
@IsTest
private class dlrs_SBQQ_QuoteLineTest
{
    @IsTest
    private static void testTrigger()
    {
        // Force the dlrs_SBQQ_QuoteLineTrigger to be invoked, fails the test if org config or other Apex code prevents this.
        dlrs.RollupService.testHandler(new SBQQ__QuoteLine__c());

        Account testAccount = new Account(  Name = 'Test Account1',
                                            CVR__c = '1' + Datetime.now().format('HHmmSSS'),
                                            BillingCity = 'Banská Bystrica'
                                        );   
            insert testAccount;
    
            Contact testContact = new Contact(  AccountId = testAccount.Id,
                                                FirstName = 'TestFirstName',
                                                LastName = 'TestLastName',
                                                Email = 'TestEmail@test.com',
                                                Phone = '99999999',
                                                MobilePhone = '88888888'
                                            );
            
            insert testContact;

            Product2 pr = new Product2( ProductAPI_Telia_Product_Id__c='CORFRI10G',
                                        name = 'Corporate Fri tale EU 10 GB',
                                        Requires_Activation_Check__c = true,
                                        SBQQ__SubscriptionType__c = 'Renewable', 
                                        isActive = true,
                                        Family = 'Mobile Subscription',
                                        Activation_Record_Type__c ='Voice');
            insert pr;

            Id standardPriceBookId = Test.getStandardPricebookId();

            PricebookEntry pbe = new PricebookEntry(Pricebook2Id = standardPriceBookId,
                                                    isActive=true,
                                                    UnitPrice =22,
                                                    Product2Id = pr.Id,
                                                    UseStandardPrice = false);
            insert pbe;

            Opportunity opp = new Opportunity(AccountId = testAccount.Id, 
                                                Name = 'Test',
                                                StageName='Qualification',
                                                recordTypeId = '0121i0000009J3tAAE',
                                                CloseDate = Date.Today(),
                                                Pricebook2Id = standardPriceBookId );
            insert opp;

            OpportunityLineItem oppit = new OpportunityLineItem(Product2Id =pr.Id, 
                                                                OpportunityId = opp.Id, 
                                                                Quantity =1, 
                                                                TotalPrice  =22,
                                                                PriceBookEntryId=pbe.Id);
            insert oppit;
            
            SBQQ__Quote__c quo = new SBQQ__Quote__c(
                SBQQ__BillingFrequency__c= 'kvartalsvis.',
                SBQQ__PaymentTerms__c = '3',
                SBQQ__SubscriptionTerm__c = 36,
                SBQQ__Account__c= testAccount.Id,Invoice_Email__c = 'tuba@tuba.com',
                SBQQ__Opportunity2__c = opp.Id);
            insert quo;  
                  
        
            SBQQ__QuoteLine__c quoline = new SBQQ__QuoteLine__c(
                SBQQ__Discount__c = 5,
                SBQQ__Quote__c =  quo.Id,
                SBQQ__Product__c = pr.Id);
            
            insert quoline;
            delete quoline;
    }
}