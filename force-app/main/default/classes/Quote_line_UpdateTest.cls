@IsTest
public class Quote_line_UpdateTest {
    /*
 @TestSetup
    static void dataPrepMethod(){
        Integer numOfAccounts = 1, numOfOppsPerAccount = 1, numOfQuotesPerOpp = 2, numOfQuoteLinesPerQuote = 1, numOfDiffProducts = 5, numOfNoActionProducts = 4;
        Account theAccount = testDataFactory.createSingleAccountForTests();
        List<Opportunity> listOfOpportunities = testDataFactory.createOpportunitiesForAccounts( numOfOppsPerAccount , new List<Account>{ theAccount } );
        List<SBQQ__Quote__c> listOfQuotes = testDataFactory.createQuotesForOpps( numOfQuotesPerOpp, listOfOpportunities );
        listOfOpportunities = [SELECT Id, AccountId, SBQQ__PrimaryQuote__c, SBQQ__PrimaryQuote__r.SBQQ__StartDate__c, Case__c FROM Opportunity];
        List<Case> theRelatedToOppCases = testDataFactory.createCasesForOpportunitiesAndAssignThem( listOfOpportunities ); // Should be called after Quote creation
        listOfOpportunities = [SELECT Id, AccountId, SBQQ__PrimaryQuote__c, SBQQ__PrimaryQuote__r.SBQQ__StartDate__c, Case__c FROM Opportunity];
		List<SBQQ__QuoteLine__c> listOfQuoteLines = testDataFactory.createQuoteLineRecordsForQuote( numOfQuoteLinesPerQuote, listOfQuotes, numOfDiffProducts, numOfNoActionProducts );
        listOfQuoteLines = [SELECT Id, Activation_Record_Type__c,Activation__c,SBQQ__Quote__r.SBQQ__BillingCity__c,SBQQ__Quote__c,SBQQ__Quantity__c,SBQQ__Product__c,Sales_Type__c FROM SBQQ__QuoteLine__c];
       
    }

    @IsTest
    static void querySelectorTest(){

        List<SBQQ__Quote__c> quotesList = [SELECT Id FROM SBQQ__Quote__c];
        List<Id> quoteIdsList = new List<Id>();
        for( SBQQ__Quote__c singleQuote : quotesList ){
            quoteIdsList.add( singleQuote.Id );
        }
        
        
      
        Quote_line_Update testedClass = new Quote_line_Update();
        testedClass.recordsId = quoteIdsList;
        Quote_line_Update.Quote_line_Bundle_Update(quoteIdsList);
        //Database.querylocator returnedQuery = testedClass.start( null );
		//System.assertEquals( 'SELECT Id,Activation_Record_Type__c from SBQQ__QuoteLine__c where SBQQ__Quote__c in :recordId and Activation_Record_Type__c <>\'No activation needed\'', returnedQuery.getQuery(), 'The query returned by start method is wrong.');

    }
*/
    @IsTest
    static void functionalityTest(){
        
        Account acct = TDF_AccountUtils.creatActiveAccountWithCVRAndOwner();
        //new Account(Name='TestAccount', BillingCity='CP',BillingPostalCode = '2000',BillingCountry = 'DK'                                           ,BillingStreet = 'Holmbladsgade 133', Phone = '111', CVR__c ='12345678');
                insert acct;
                
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
                
                SBQQ__Quote__c quo = new SBQQ__Quote__c(
                    SBQQ__BillingFrequency__c= 'kvartalsvis.',
                    SBQQ__PaymentTerms__c = '3',
                    SBQQ__SubscriptionTerm__c = 36,
                    SBQQ__Opportunity2__c = opp.id,
                    SBQQ__Account__c=acct.Id,Invoice_Email__c = 'tuba@tuba.com',
                RecordTypeId =  Schema.sObjectType.SBQQ__Quote__c.getRecordTypeInfosByName().get('Draft Quote').getRecordTypeId());
               
                insert quo; 
        
          Case cs = new case(Root_BAN__c = '232312345',Quote__c = quo.Id,AccountId = acct.Id,
                                  RecordTypeId =  Schema.sObjectType.Case.getRecordTypeInfosByName().get('Order Fulfilment Case').getRecordTypeId());
                insert cs;
        

        
        List<Id> quoteIdsList = new List<Id>();
        quoteIdsList.add( quo.Id );
        
        
        SBQQ__ProductOption__c prOp = new SBQQ__ProductOption__c(
                SBQQ__OptionalSKU__c = pr2.Id,
          	    SBQQ__ConfiguredSKU__c = pr.Id,
                SBQQ__Number__c = 1);    
                
                insert prOp;
        
        SBQQ__QuoteLine__c quoline = new SBQQ__QuoteLine__c(
                    SBQQ__Quantity__c  = 0,
                    SBQQ__Quote__c = quo.Id,
                    SBQQ__Product__c=pr.Id,
        SBQQ__ProductOption__c = prOp.Id
        			);    
        insert quoline;
        
        SBQQ__QuoteLine__c quoline2 = new SBQQ__QuoteLine__c(
                    SBQQ__Quantity__c  = 1,
                    SBQQ__Quote__c = quo.Id,
                    SBQQ__Product__c=pr2.Id);    
                
                insert quoline2;
         
        Quote_line_Update testedClass = new Quote_line_Update();
        testedClass.recordsId = quoteIdsList;
        
        
        Test.startTest();

        Quote_line_Update.Quote_line_Bundle_Update(quoteIdsList);

        Test.stopTest();
      

    }
    public class testException extends Exception {}
  
}