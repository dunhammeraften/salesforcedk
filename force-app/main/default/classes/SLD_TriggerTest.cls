@IsTest
public class SLD_TriggerTest {
    @IsTest
    static void dataSettingUp(){
 	Integer numberOfDifferentBundles = 2, numberOfDifferentCategories = 2, numberOfDifferentFeaturesPerBundle = 4, numberOfDifferentProductsPerFeature = 2, numberOfDifferentOptionsPerBundle = 5;

        List<Product2> testBundlesWithOptions = testDataFactory.createBundles( numberOfDifferentBundles, numberOfDifferentCategories, numberOfDifferentFeaturesPerBundle, numberOfDifferentProductsPerFeature, numberOfDifferentOptionsPerBundle );

        SBQQ.TriggerControl.disable();
        List<Account> testAccounts = testDataFactory.createAccountsForTests( 1 );

        List<Opportunity> testOpps = testDataFactory.createOpportunitiesForAccounts( 1, testAccounts );

        List<SBQQ__Quote__c> testQuote = testDataFactory.createQuotesForOpps( 1, testOpps );

        List<SBQQ__QuoteLine__c> testQL = testDataFactory.createQuoteLinesForBundle( testBundlesWithOptions, testQuote );
	
        Id standardPriceBookId = Test.getStandardPricebookId();
            
        Contract cr = new Contract(AccountId = testAccounts[0].Id,
                                   Total_Contract_value__c = 100,
                                   ContractTerm = 36,
                                   StartDate = Date.today().addDays(-1),
                                   Migrated_Contract__c = false,
                                   Pricebook2Id = standardPriceBookId,
                                   SBQQ__AmendmentPricebookId__c = standardPriceBookId,
                                   SBQQ__RenewalPricebookId__c = standardPriceBookId,
                                   SBQQ__AmendmentRenewalBehavior__c = 'Latest End Date',
                                   Product_s_in_scope__c = 'Voice',
                                   SBQQ__RenewalTerm__c = 36,
                                   Mobile_Part_of_Contract__c =  TRUE ,
                                   Fastnet_Part_of_Contract__c =  FALSE,
                                   Data_Part_of_Contract__c = FALSE
                                   ); 
        insert cr;
        Product2 pr = new Product2(ProductAPI_Telia_Product_Id__c='CORFRI10G', name = 'Corporate Fri tale EU 10 GB',
                                           SBQQ__SubscriptionType__c = 'Renewable', isActive=true, Activation_Record_Type__c ='Voice');
                insert pr;
        
            Product2 pr2 = new Product2(ProductAPI_Telia_Product_Id__c='CORFRI20G', name = 'Corporate Fri tale EU 20 GB',
                                           SBQQ__SubscriptionType__c = 'Renewable', isActive=true, Activation_Record_Type__c ='Voice');
                insert pr2;
        
         SBQQ__Subscription__c newSubscription = new SBQQ__Subscription__c(
        				SBQQ__Contract__c = cr.Id,
                         SBQQ__Product__c = pr.Id,
                         SBQQ__Quantity__c = 1, //TODO!!
                         SBQQ__Account__c = testAccounts[0].Id,
                         SBQQ__ProductSubscriptionType__c = 'Renewable',
                         SBQQ__SubscriptionType__c = 'Renewable',
                         SBQQ__RenewalQuantity__c = 1,   //TODO trigger
                         SBQQ__RenewalPrice__c = 100,
                         SBQQ__NetPrice__c = 100,
                         SBQQ__CustomerPrice__c = 100);
        insert newSubscription;
        
          SBQQ__Subscription__c newSubscription2 = new SBQQ__Subscription__c(
        				SBQQ__Contract__c = cr.Id,
                         SBQQ__Product__c = pr2.Id,
                         SBQQ__Quantity__c = 1, //TODO!!
                         SBQQ__Account__c = testAccounts[0].Id,
                         SBQQ__ProductSubscriptionType__c = 'Renewable',
                         SBQQ__SubscriptionType__c = 'Renewable',
                         SBQQ__RenewalQuantity__c = 1,   //TODO trigger
                         SBQQ__RenewalPrice__c = 100,
                         SBQQ__NetPrice__c = 100,
                         SBQQ__CustomerPrice__c = 100);
        insert newSubscription2;
        
        Subscription_Line_Detail__c newSLD = new Subscription_Line_Detail__c(
        			INSTANCE_KEY__c = '1234',
            		Subscription__c = newSubscription.Id,
                    Subscriber_Id__c =  newSubscription.Id,
                    First_name__c = 'Test',
                    Max_Monthly_Data_Used_MB__c = 100,
                    Manual_Product__c = pr.Id,
                    Fokus_SOC__c = 'CORFRI10',
                    Mobile_no__c = '12345678',
                    Installation_address__c = 'test address',
                    Email__c = 'test@test.com',
                    RCC_Owner_Control__c = FALSE,
                    TSRR_Owner_Control__c = FALSE,
                    Last_name__c = 'Test',
                    Invoice_Email__c = 'test@test.com',
                    Ekstra_Data_SIM_number__c = '251625173',
                    Calls_from_DK_to_EU_MIN__c =  100,
                    Fixed_no__c = '5273627',
                    NUA_Owner_Control__c = FALSE);
        
        
        List<Subscription_Line_Detail__c> testSLDList = new List<Subscription_Line_Detail__c>();
        Test.startTest();
        insert newSLD;
        
        newSLD.Subscription__c = newSubscription2.Id;        
        update newSLD;
        Test.stopTest();
          
    }
}