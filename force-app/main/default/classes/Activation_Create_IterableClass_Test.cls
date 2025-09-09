@IsTest
public class Activation_Create_IterableClass_Test {

    @TestSetup
    static void dataPrepMethod(){
        Integer numOfAccounts = 1, numOfOppsPerAccount = 1, numOfQuotesPerOpp = 1, numOfQuoteLinesPerQuote = 2, numOfDiffProducts = 2, numOfNoActionProducts = 0;
        Account theAccount = testDataFactory.createSingleAccountForTests();
        List<Opportunity> listOfOpportunities = testDataFactory.createOpportunitiesForAccounts( numOfOppsPerAccount , new List<Account>{ theAccount } );
        List<SBQQ__Quote__c> listOfQuotes = testDataFactory.createQuotesForOpps( numOfQuotesPerOpp, listOfOpportunities );
        listOfOpportunities = [SELECT Id, AccountId, SBQQ__PrimaryQuote__c, SBQQ__PrimaryQuote__r.SBQQ__StartDate__c, Case__c FROM Opportunity];
        List<Case> theRelatedToOppCases = testDataFactory.createCasesForOpportunitiesAndAssignThem( listOfOpportunities ); // Should be called after Quote creation
        listOfOpportunities = [SELECT Id, AccountId, SBQQ__PrimaryQuote__c, SBQQ__PrimaryQuote__r.SBQQ__StartDate__c, Case__c FROM Opportunity];
        List<SBQQ__QuoteLine__c> listOfQuoteLines = testDataFactory.createQuoteLineRecordsForQuote( numOfQuoteLinesPerQuote, listOfQuotes, numOfDiffProducts, numOfNoActionProducts,true );
        listOfQuoteLines = [SELECT Id, Activation_Record_Type__c, SBQQ__Quote__c,SBQQ__Quantity__c,SBQQ__Product__c,Sales_Type__c FROM SBQQ__QuoteLine__c];
       
           

    }

    @IsTest
    static void querySelectorTest(){

        List<SBQQ__Quote__c> quotesList = [SELECT Id FROM SBQQ__Quote__c];
        List<Id> quoteIdsList = new List<Id>();
        
        quoteIdsList.add(quotesList[0].Id);
       
        List<Case> caseListMain = [select id from case limit 1 ];
        caseListMain[0].Quote__c = quotesList[0].Id;
        update caseListMain[0];
        
        List<Case> caseList = [select id from case where Quote__c =:quotesList[0].Id ];
       
        Product2 pr = new Product2(ProductAPI_Telia_Product_Id__c='CORFRI10G', name = 'Corporate Fri tale EU 10 GB',
                                           SBQQ__SubscriptionType__c = 'Renewable', isActive=true, Activation_Record_Type__c ='Voice',
                                            activate_with_other_products__c = false);
        insert pr;
        
        Product2 pr2 = new Product2(ProductAPI_Telia_Product_Id__c='CORFRI20G', name = 'Home office',
                                           SBQQ__SubscriptionType__c = 'Renewable', isActive=true, 
                                            Activation_Record_Type__c ='Home office',
                                            activate_with_other_products__c = false, ProductCode = '3100',
                                            address_required__c = true);
        insert pr2;
        
        List<SBQQ__QuoteLine__c> quoteLinesList = [SELECT Id,SBQQ__Product__c FROM SBQQ__QuoteLine__c where SBQQ__Quote__c =: quotesList[0].Id ];
        quoteLinesList[0].Additional_Quantity__c = 3;
        quoteLinesList[0].SBQQ__Product__c = pr.Id;
        quoteLinesList[0].SBQQ__SegmentIndex__c =1;
        quoteLinesList[0].Address_filled_on_activation_lines__c = false;
        update quoteLinesList[0];
        
        quoteLinesList[1].Additional_Quantity__c = 3;
        quoteLinesList[1].SBQQ__Product__c = pr2.Id;
        quoteLinesList[1].SBQQ__SegmentIndex__c =1;
        quoteLinesList[1].Address_filled_on_activation_lines__c = false;
        update quoteLinesList[1];
        
        Activation__c acti = new Activation__c(Case__c = caseList[0].Id,
                                               RecordTypeId =  Schema.sObjectType.Activation__c.getRecordTypeInfosByName().get('Voice activation').getRecordTypeId());
        insert acti;
        
       
        String strRecordTypeId = [Select Id From RecordType Where SobjectType = 'Activation_line__c' and developername = 'Voice_activation_line'].Id;


        Activation_line__c actiline = new Activation_line__c( Activation__c = acti.Id, Case__c = caseList[0].Id, Quote_line__c = quoteLinesList[0].Id,
                                                                    RecordTypeId=strRecordTypeId, Manual_Product__c = quoteLinesList[0].SBQQ__Product__c,
                                                                     Invoice_Email__c='tuba@tuba.com', Not_to_Activation__c = false);
        insert actiline; 
      

         Test.startTest();
        
         Activation_Create_Iterable ProcessBatch = new Activation_Create_Iterable();
          ProcessBatch.recordId = quoteIdsList;
          ID batchprocessid = Database.executeBatch(ProcessBatch);
        
        
        Test.stopTest();
   }
    }