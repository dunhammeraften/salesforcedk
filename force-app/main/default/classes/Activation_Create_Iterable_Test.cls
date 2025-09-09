@IsTest
private class Activation_Create_Iterable_Test{
    private static final String CVR = '12345678';

    // @TestSetup
    static void dataPrepMethod(){
        Integer numOfAccounts = 1, numOfOppsPerAccount = 1, numOfQuotesPerOpp = 1, numOfQuoteLinesPerQuote = 1, numOfDiffProducts = 1, numOfNoActionProducts = 0;
        Profile prof = ProfileSelector.getProfileByProfileName(ProfileConstants.SYSTEM_ADMINISTRATOR);
		User usr = testDataFactory.createUser('standt', prof.Id);
		Account account = testDataFactory.createAccountWithCVR(CVR);
		account.OwnerId = usr.Id;
		insert account;
		List<Opportunity> listOfOpportunities = testDataFactory.createOpportunitiesForAccounts(1, new List<Account>{ account });
        List<SBQQ__Quote__c> listOfQuotes = testDataFactory.createQuotesForOpps( numOfQuotesPerOpp, listOfOpportunities );
        listOfOpportunities = [SELECT Id, AccountId, SBQQ__PrimaryQuote__c, SBQQ__PrimaryQuote__r.SBQQ__StartDate__c, Case__c FROM Opportunity];
        List<Case> theRelatedToOppCases = testDataFactory.createCasesForOpportunitiesAndAssignThem( listOfOpportunities ); // Should be called after Quote creation
        listOfOpportunities = [SELECT Id, AccountId, SBQQ__PrimaryQuote__c, SBQQ__PrimaryQuote__r.SBQQ__StartDate__c, Case__c FROM Opportunity];
        List<SBQQ__QuoteLine__c> listOfQuoteLines = testDataFactory.createQuoteLineRecordsForQuote( numOfQuoteLinesPerQuote, listOfQuotes, numOfDiffProducts, numOfNoActionProducts,false );
        listOfQuoteLines = [SELECT Id, Activation_Record_Type__c, SBQQ__Quote__c FROM SBQQ__QuoteLine__c];

        //create activation on case and account
        List<Activation__c> activationHeadersList = TDF_ActivationUtils.createActivationHeadersForQuoteLines(listOfQuoteLines, listOfOpportunities);
    }

    @IsTest
    static void querySelectorTest(){

        dataPrepMethod();

        List<SBQQ__Quote__c> quotesList = [SELECT Id FROM SBQQ__Quote__c];
        List<Id> quoteIdsList = new List<Id>();
        for( SBQQ__Quote__c singleQuote : quotesList ){
            quoteIdsList.add( singleQuote.Id );
        }

        Activation_Create_Iterable testedClass = new Activation_Create_Iterable();
        testedClass.recordId = quoteIdsList;

        Database.querylocator returnedQuery = testedClass.start( null );

        //System.assertEquals( 'SELECT Id,Activation_Record_Type__c from SBQQ__QuoteLine__c where SBQQ__Quote__c in :recordId and Activation_Record_Type__c <>\'No activation needed\'', returnedQuery.getQuery(), 'The query returned by start method is wrong.');

    }
    @IsTest
    static void functionalityTest(){

        dataPrepMethod();

        List<SBQQ__Quote__c> quotesList = [SELECT Id, SBQQ__Primary__c FROM SBQQ__Quote__c];
        List<Id> quoteIdsList = new List<Id>();
        for( SBQQ__Quote__c singleQuote : quotesList ){
            if( singleQuote.SBQQ__Primary__c ) quoteIdsList.add( singleQuote.Id );
        }

        Activation_Create_Iterable testedClass = new Activation_Create_Iterable();
        testedClass.recordId = quoteIdsList;

        Map<Id,SBQQ__QuoteLine__c> quoteLinesMap = new Map<Id,SBQQ__QuoteLine__c>( [SELECT Id, Activation__c, SBQQ__Quote__r.SBQQ__Primary__c FROM SBQQ__QuoteLine__c] );
        // We need to create Activation Headers for them 
        Test.startTest();
            Database.executeBatch(
                testedClass
            );
        Test.stopTest();
        Map<Id,SBQQ__QuoteLine__c> veryficationQuoteLineMap = new Map<Id,SBQQ__QuoteLine__c>( [SELECT Id, Activation__c FROM SBQQ__QuoteLine__c] );
        for( Id singleId : quoteLinesMap.keySet() ){
            If( quoteLinesMap.get( singleId ).SBQQ__Quote__r.SBQQ__Primary__c ) System.assertNotEquals( quoteLinesMap.get( singleId ).Activation__c, veryficationQuoteLineMap.get( singleId ).Activation__c, 'The Activation should be populated for Quote Lines from primay Quotes' );
            else System.assertEquals( quoteLinesMap.get( singleId ).Activation__c, veryficationQuoteLineMap.get( singleId ).Activation__c, 'The Activation should not be populated for Quote Lines from not primay Quotes' );
        }
    }
    
    @IsTest
    static void functionalityTest1(){

        dataPrepMethod();

        List<SBQQ__Quote__c> quotesList = [SELECT Id, SBQQ__Primary__c FROM SBQQ__Quote__c limit 1];
        List<Id> quoteIdsList = new List<Id>();
        quoteIdsList.add(quotesList[0].Id);
        
        List<SBQQ__QuoteLine__c> quoteLinesList = [SELECT Id,SBQQ__Product__c FROM SBQQ__QuoteLine__c where SBQQ__Quote__c =: quotesList[0].Id ];
       
        
        Quote_Line_Detail__c qld = new Quote_Line_Detail__c(
                            Quote_Line__c = quoteLinesList[0].Id,
            				Manual_Product__c  = quoteLinesList[0].SBQQ__Product__c,
                            Description__c = 'test');
        insert qld;

        Activation_Create_Iterable testedClass = new Activation_Create_Iterable();
        testedClass.recordId = quoteIdsList;

        Map<Id,SBQQ__QuoteLine__c> quoteLinesMap = new Map<Id,SBQQ__QuoteLine__c>( [SELECT Id, Activation__c, SBQQ__Quote__r.SBQQ__Primary__c FROM SBQQ__QuoteLine__c] );
        // We need to create Activation Headers for them 
        Test.startTest();
            Database.executeBatch(
                testedClass
            );
        Test.stopTest();


    }
    public class testException extends Exception {}
    @IsTest
    static void mailingTest(){

        dataPrepMethod();

        try{
            throw new testException('The test Error moessage');
        }catch( Exception e ){
            Apex_Error_email_address__c Activation_line_Settings = new Apex_Error_email_address__c(
                Email_Address__c = 'test1@test.test'
            );
            Activation_Create_Iterable testedClass = new Activation_Create_Iterable();
        }
    }
}