@isTest
public class ApexUtils_Test {
//@TestSetup 
    static void TestSetup()
    {
        Account acct = new Account(Name='TestAccount', BillingCity='CP',BillingPostalCode = '2000',BillingCountry = 'DK'
                                           ,BillingStreet = 'Holmbladsgade 133', Phone = '111', CVR__c ='12345678');
        insert acct;
                
        Product2 pr = new Product2(ProductAPI_Telia_Product_Id__c='CORFRI10G', 
                                    Telia_Product_Code__c  ='CORFRI10G',
                                    name = 'Corporate Fri tale EU 10 GB',
                                    SBQQ__SubscriptionType__c = 'Renewable', isActive=true, 
                                    Activation_Record_Type__c ='Voice');
        insert pr;
                
        /*
        PriceBook2 pb2Standard = new Pricebook2(name='Pricebo');
        insert pb2Standard;
        
        Pricebook2 pb2Standard = [select id from Pricebook2 where isStandard=true];
        Id standardPriceBookId = pb2Standard.Id;
        */                
 
        Id standardPriceBookId = Test.getStandardPricebookId();
        
        Pricebook2 customPB = new Pricebook2(Name='Custom Pricebook', isActive=true);
        insert customPB;
        
        PricebookEntry pbe = new PricebookEntry(Pricebook2Id = standardPriceBookId ,isActive=true,UnitPrice =22,Product2Id = pr.Id,
                                                UseStandardPrice = false);
        insert pbe;        

        PricebookEntry customPrice = new PricebookEntry(
            Pricebook2Id = customPB.Id, Product2Id = pr.Id,
            UnitPrice = 12, IsActive = true);
        insert customPrice;
                
        Long startTime;
        Long finalTime;
        Long millisecondsToWait;                
        //WAIT for 1 seconds
        startTime = DateTime.now().getTime();
        finalTime = DateTime.now().getTime();
        millisecondsToWait = 1000; // vary this depending on your "sleep" needs
        while (finalTime - startTime < millisecondsToWait) {
        finalTime = DateTime.now().getTime();}
                 
        Opportunity opp = new Opportunity(AccountId = acct.Id, Name = 'Test',StageName='Qualification', CloseDate =Date.Today(),
                                            Pricebook2Id =standardPriceBookId );
        insert opp;
        
        OpportunityLineItem oppit = new OpportunityLineItem(Product2Id =pr.Id, OpportunityId = opp.Id, Quantity =1, TotalPrice  =22,
                                                            PriceBookEntryId=pbe.Id);
        insert oppit;
                
        //WAIT for 3 seconds
        startTime = DateTime.now().getTime();
        finalTime = DateTime.now().getTime();
        millisecondsToWait = 3000; // vary this depending on your "sleep" needs
        while (finalTime - startTime < millisecondsToWait) {
        finalTime = DateTime.now().getTime();}
                
        SBQQ__Quote__c quo = new SBQQ__Quote__c(
            SBQQ__BillingFrequency__c= 'kvartalsvis.',
            SBQQ__PaymentTerms__c = '3',
            SBQQ__SubscriptionTerm__c = 36,
            SBQQ__Account__c=acct.Id,Invoice_Email__c = 'tuba@tuba.com',
        SBQQ__Opportunity2__c = opp.Id,
        RecordTypeId =  Schema.sObjectType.SBQQ__Quote__c.getRecordTypeInfosByName().get('Draft Quote').getRecordTypeId());
        
        insert quo;  
        
        Case cs = new case(Root_BAN__c = '232312345',Quote__c = quo.Id,AccountId = acct.Id,
                            RecordTypeId =  Schema.sObjectType.Case.getRecordTypeInfosByName().get('Order Fulfilment Case').getRecordTypeId());
        insert cs;
        system.debug('case out' +cs);                
   } 
    
    @isTest 
    static void Test()
    {
        TestSetup();
         
        Test.startTest();
        ApexUtils testcl = new ApexUtils();
        testcl.GetVASColumnNamesfromActivationLines();
        ApexUtils.sendMail('mailMessage','mailSubject', 'test@test.com');
        testcl.CheckIgnoreProducts();
        testcl.CheckDSLProducts();
        testcl.LoadSubscriptionProductCodeList();
        testcl.LoadSubscriptionProductList();
        testcl.LoadProductList();
        testcl.LoadProductContractGroups();
        Test.stopTest();
    }
}