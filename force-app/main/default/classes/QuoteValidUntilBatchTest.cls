@IsTest
private with sharing class QuoteValidUntilBatchTest {
    private static final String TEST_CVR = '12345678';
    private static final Integer AMOUNT_OF_DIFFERENT_PRODUCTS = 2;

    //@TestSetup
    private static void makeData() {
        Account acc = TDF_AccountUtils.createAccountWithCVR(TEST_CVR);
        acc.Status__c = 'Active';
        insert acc;

        Opportunity opp = TDF_OpportunityUtils.createOpportunitiesForAccounts(1, new List<Account>{acc})[0];

        SBQQ__Quote__c quote = TDF_QuoteUtils.createSingleQuote(acc.Id, opp.Id);
        quote.SBQQ__StartDate__c = System.today().addDays(10);
        insert quote;

        opp.Original_Primary_Quote__c = quote.Id;
        opp.SBQQ__PrimaryQuote__c = quote.Id; // this is actually supposed to be the Activation Quote, but we don't need that for testing here
        update opp;

        List<Product2> listOfProductsToUse = TDF_ProductUtils.createProductsForTests(AMOUNT_OF_DIFFERENT_PRODUCTS);
        List<PricebookEntry> listOfPricebookEntries = TDF_ProductUtils.createStandardPricebookEntriesForProducts(listOfProductsToUse);
        Map<Id, PricebookEntry> mapOfProductToPricebookEntries = TDF_ProductUtils.createProductIdToPricebookEntryMap(
            listOfPricebookEntries, 
            listOfProductsToUse
        );

        TDF_QuoteLineUtils.createQuoteLinesForQuote(
            new List<SBQQ__Quote__c>{quote},
            false,
            listOfProductsToUse,
            mapOfProductToPricebookEntries
        );

        quote.SBQQ__Status__c = 'Signed';
        update quote;
    }

    @IsTest
    private static void execute_InputsQuoteValidUntilYesterday_ResultAccountIsProcessed() {
        //ARRANGE
        makeData();

        SBQQ__Quote__c quote = QuoteSelector.getQuotesByAccountCVRs(new List<String>{TEST_CVR})[0];

        /* 
        If today is 2024-11-28, and quote.SBQQ__StartDate__c is 2023-10-21, and quote.Valid_Until__c is 2027-10-21
            then daysBetweenYesterdayAndValidUntil is: 1058
        When substracting 1058 from quote.SBQQ__StartDate__c 2023-10-21 we get 2020-11-27
            As quote.Valid_Until__c is a formula field based on quote.SBQQ__StartDate__c then it will be changed accordingly 1058 days back in time
            which is then 2024-11-27
        As 2024-11-27 is yesterday if today is 2024-11-28, then we test correctly against yesterday
        As this calculation is dynamic based on System.today() and so it will work for any date
        */
        Integer daysBetweenYesterdayAndValidUntil = System.today().addDays(-1).daysBetween(quote.Valid_Until__c);
        quote.SBQQ__StartDate__c = quote.SBQQ__StartDate__c.addDays(-daysBetweenYesterdayAndValidUntil);
        update quote;

        //ACT
        Test.startTest();
        QuoteValidUntilBatch batch = new QuoteValidUntilBatch();
        Database.executeBatch(batch);
        Test.stopTest();

        //ASSERT
        Assert.isTrue(QuoteValidUntilBatch.processedAccountIds.contains(quote.SBQQ__Account__c), 'The Account of the Quote should be processed');
    }

    @IsTest
    private static void execute_InputsQuoteValidUntilFutureDate_ResultNoAccountsProcessed() {
        //ARRANGE
        makeData();

        //ACT
        Test.startTest();
        QuoteValidUntilBatch batch = new QuoteValidUntilBatch();
        Database.executeBatch(batch);
        Test.stopTest();

        //ASSERT
        Assert.isTrue(QuoteValidUntilBatch.processedAccountIds.isEmpty(), 'No Account should be processed');
    }

    @IsTest
    private static void execute_InputsQuoteManualValidUntilYesterday_ResultAccountIsProcessed() {
        //ARRANGE
        makeData();

        SBQQ__Quote__c quote = QuoteSelector.getQuotesByAccountCVRs(new List<String>{TEST_CVR})[0];
        quote.Manual_Valid_Until__c = System.today().addDays(-1);
        update quote;

        //ACT
        Test.startTest();
        QuoteValidUntilBatch batch = new QuoteValidUntilBatch();
        Database.executeBatch(batch);
        Test.stopTest();

        //ASSERT
        Assert.isTrue(QuoteValidUntilBatch.processedAccountIds.contains(quote.SBQQ__Account__c), 'The Account of the Quote should be processed');
    }
}