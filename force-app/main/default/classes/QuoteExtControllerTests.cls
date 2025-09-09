@IsTest
private class QuoteExtControllerTests {
    private static final String TEST_CVR = '12345678';

    @TestSetup
    private static void makeData() {
        Account acc = TestDataFactory.createAccountWithCVR(TEST_CVR);
        acc.Status__c = 'Active';
        acc.Max_Quote_Amount__c = 100000;
        insert acc;

        Opportunity opp = TestDataFactory.createOpportunitiesForAccounts(1, new List<Account>{acc})[0];
        opp.Product_s_in_scope__c = '';
        update opp;

        SBQQ__Quote__c quote = TestDataFactory.createSingleQuote(acc.Id, opp.Id);
        quote.SBQQ__StartDate__c = System.today().addDays(10);
        insert quote;
    }
    
    @IsTest
    private static void testSubmit() {
        // get quote from makeDate;
        SBQQ__Quote__c quote = QuoteSelector.getQuotesByAccountCVRs(new List<String> {TEST_CVR})[0];
        
        Test.startTest();
        QuoteExtController con = new QuoteExtController(new ApexPages.StandardController(quote));
        con.onSubmit();
        Test.stopTest();

        quote = QuoteSelector.getQuotesByAccountCVRs(new List<String> {TEST_CVR})[0];

        // assert that status is approved
        Assert.areEqual('Approved', quote.ApprovalStatus__c, 'Approval Status on Quote should be Approved');
    }    
    
    @IsTest
    private static void testSubmitExceptionStartDateInThePast() {        
        // get quote from makeDate and update the start date to be in the past
        SBQQ__Quote__c quote = QuoteSelector.getQuotesByAccountCVRs(new List<String> {TEST_CVR})[0];
        quote.SBQQ__StartDate__c = System.today().addDays(-10);
        update quote;
        
        Test.startTest();
        QuoteExtController con = new QuoteExtController(new ApexPages.StandardController(quote));
        con.onSubmit();
        Test.stopTest();
        
        quote = QuoteSelector.getQuotesByAccountCVRs(new List<String> {TEST_CVR})[0];

        // assert that status is not approved
        Assert.areNotEqual('Approved', quote.ApprovalStatus__c, 'Approval Status on Quote should not be Approved');
    }

    
    @IsTest
    private static void testRecall() {
        // get quote from makeDate
        SBQQ__Quote__c quote = QuoteSelector.getQuotesByAccountCVRs(new List<String> {TEST_CVR})[0];
        
        Test.startTest();
        QuoteExtController con = new QuoteExtController(new ApexPages.StandardController(quote));
        con.onRecall();
        Test.stopTest();
        
        quote = QuoteSelector.getQuotesByAccountCVRs(new List<String> {TEST_CVR})[0];
        
        Assert.areEqual('Recalled', quote.ApprovalStatus__c, 'Approval Status on Quote should be Recalled');
    }
}