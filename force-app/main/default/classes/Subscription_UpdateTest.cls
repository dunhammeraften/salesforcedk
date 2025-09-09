@IsTest
public class Subscription_UpdateTest {
   @TestSetup
    static void dataPrepMethod(){
 
        Account acct = new Account(Name='TestAccount', BillingCity='CP',BillingPostalCode = '2000',BillingCountry = 'DK'
                                           ,BillingStreet = 'Holmbladsgade 133', Phone = '111',
                                   AccountSource  = 'Manual' , Rationale__c  = 'test' );
        insert acct;
        
        acct.Status__c = 'Active';
        update acct;
                
                Product2 pr = new Product2(ProductAPI_Telia_Product_Id__c='CORFRI10G', 
                                           Telia_Product_Code__c  ='CORFRI10G',
                                           name = 'Corporate Fri tale EU 10 GB',
                                           SBQQ__SubscriptionType__c = 'Renewable', isActive=true, 
                                           Activation_Record_Type__c ='Voice');
                insert pr;
        
        		Product2 pr2 = new Product2(ProductAPI_Telia_Product_Id__c='CORFRI20G', 
                                           Telia_Product_Code__c  ='CORFRI20G',
                                           name = 'Corporate Fri tale EU 20 GB',
                                           SBQQ__SubscriptionType__c = 'Renewable', isActive=true, 
                                           Activation_Record_Type__c ='Voice');
                insert pr2;
                
                 
                Id standardPriceBookId = Test.getStandardPricebookId();
                
				Pricebook2 customPB = new Pricebook2(Name='Custom Pricebook', isActive=true);
                insert customPB;
                
                PricebookEntry pbe = new PricebookEntry(Pricebook2Id = standardPriceBookId ,isActive=true,UnitPrice =22,Product2Id = pr.Id,
                                                       UseStandardPrice = false);
                insert pbe;

                
Long startTime;
Long finalTime;
Long millisecondsToWait; 

//WAIT for 1 seconds
startTime = DateTime.now().getTime();
finalTime = DateTime.now().getTime();
millisecondsToWait = 1000; // vary this depending on your "sleep" needs
while (finalTime - startTime < millisecondsToWait) {
finalTime = DateTime.now().getTime();}
    
        	    Opportunity opp = new Opportunity (AccountId =acct.Id,
                                                  Amount  = 10,
                                                   Type = 'New Business',
                                                  CloseDate = Date.today(),
                                                  StageName = 'Qualification',
                                                  name = 'Test',
                                                   Pricebook2Id = standardPriceBookId );	
                
                insert opp;
        
        //WAIT for 1 seconds
startTime = DateTime.now().getTime();
finalTime = DateTime.now().getTime();
millisecondsToWait = 2000; // vary this depending on your "sleep" needs
while (finalTime - startTime < millisecondsToWait) {
finalTime = DateTime.now().getTime();}
        
                SBQQ__Quote__c quo = new SBQQ__Quote__c(
                    SBQQ__BillingFrequency__c= 'kvartalsvis.',
                    SBQQ__PaymentTerms__c = '3',
                    SBQQ__SubscriptionTerm__c = 36,
                    SBQQ__Opportunity2__c = opp.id,
                    SBQQ__Account__c=acct.Id,Invoice_Email__c = 'tuba@tuba.com',
                    SBQQ__PriceBook__c =standardPriceBookId,
                    SBQQ__PricebookId__c =standardPriceBookId ,
                RecordTypeId =  Schema.sObjectType.SBQQ__Quote__c.getRecordTypeInfosByName().get('Draft Quote').getRecordTypeId());
                
                insert quo; 
        
          Case cs = new case(Root_BAN__c = '232312345',Quote__c = quo.Id,AccountId = acct.Id,
                                  RecordTypeId =  Schema.sObjectType.Case.getRecordTypeInfosByName().get('Order Fulfilment Case').getRecordTypeId());
                insert cs;
        
        Activation__c acti = new Activation__c(Case__c = cs.Id,
                                                       RecordTypeId =  Schema.sObjectType.Activation__c.getRecordTypeInfosByName().get('Fiber activation').getRecordTypeId());
                insert acti;
        
        List<Id> quoteIdsList = new List<Id>();
        quoteIdsList.add( quo.Id );
        
        
        SBQQ__ProductOption__c prOp = new SBQQ__ProductOption__c(
                SBQQ__OptionalSKU__c = pr.Id,
          	    SBQQ__ConfiguredSKU__c = pr2.Id,
                SBQQ__Number__c = 1);    
                
                insert prOp;
        
        SBQQ__QuoteLine__c quoline = new SBQQ__QuoteLine__c(
                    SBQQ__Quantity__c  = 0,
                    SBQQ__Quote__c = quo.Id,
                    SBQQ__Product__c=pr.Id,
            Activation__c = acti.Id,
        SBQQ__ProductOption__c = prOp.Id
        			);    
                
                insert quoline;
        
        SBQQ__QuoteLine__c quoline2 = new SBQQ__QuoteLine__c(
                    SBQQ__Quantity__c  = 1,
                    SBQQ__Quote__c = quo.Id,
             Activation__c = acti.Id,
                    SBQQ__Product__c=pr2.Id);    
                
                insert quoline2;
        
        DateTime dT = System.now();
		Date d = Date.newInstance(dT.year(), dT.month(), dT.day());
        
        Schema.Order ord = new Schema.Order (Case__c = cs.Id, Pricebook2Id = standardPriceBookId, 
                                             OpportunityId = opp.Id, AccountId = acct.Id,
                                             SBQQ__PaymentTerm__c ='30', Status = 'Draft ',
                                            EffectiveDate = Date.newInstance(2012, 12, 12));
                insert ord;
        
 
        Contract cr = new Contract(AccountId = acct.Id,
                                                           Total_Contract_value__c = decimal.valueOf(6000),
                                                           ContractTerm = 36,
                                                           StartDate = Date.today().addDays(-1),
                                                           Migrated_Contract__c = true,
                                                           Pricebook2Id = standardPriceBookId,
                                                           SBQQ__AmendmentPricebookId__c = standardPriceBookId,
                                                           SBQQ__RenewalPricebookId__c = standardPriceBookId,
                                                           SBQQ__AmendmentRenewalBehavior__c = 'Latest End Date',
                                                           Product_s_in_scope__c = 'Voice',
                                                           SBQQ__RenewalTerm__c = 36,
                                                           Mobile_Part_of_Contract__c = true,
                                   						   SBQQ__RenewalForecast__c = false
                                                            ); 
        insert cr;
        
        cr.Status = 'Activated';
        cr.SBQQ__RenewalForecast__c = false;
        cr.Renewal_Quote_Creation_date__c = Date.newInstance(2012, 12, 12);
        cr.Renewal_Opportunity_Creation_Date__c = Date.newInstance(2012, 12, 12);
        update cr;
        
        cr.Status = 'Activated';
        update cr;
        

       SBQQ__Subscription__c newSubscription = new SBQQ__Subscription__c(
                         SBQQ__Contract__c = cr.Id,
                         SBQQ__Discount__c = 0,
                         SBQQ__Product__c = quoline.SBQQ__Product__c,
                         SBQQ__Quantity__c = 1, //TODO!!
                         SBQQ__Account__c = acct.Id,
                         SBQQ__ProductSubscriptionType__c = 'Renewable',
                         SBQQ__SubscriptionType__c = 'Renewable',
                         SBQQ__RenewalQuantity__c = 1,   //TODO trigger
                         SBQQ__RenewalPrice__c = 0,
                         SBQQ__NetPrice__c = 0,
                         SBQQ__CustomerPrice__c = 0,
                         SBQQ__ListPrice__c = 0,
                         SBQQ__RegularPrice__c = 0,
                         SBQQ__SpecialPrice__c = 0,
         				 SBQQ__QuoteLine__c =quoline.Id );
         insert newSubscription;

        
    }
    
    @IsTest
    static void functionalityTest(){
        Test.startTest();

        List<Contract> contractListRecords = [SELECT Id FROM Contract];
        List<Id> contractList = new List<Id>();
        contractList.add(contractListRecords[0].Id );
       

        Subscription_Update.Subscription_Bundle_Update(contractList);

        Test.stopTest();
        }
}