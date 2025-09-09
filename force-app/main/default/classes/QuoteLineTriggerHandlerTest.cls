@isTest
private class QuoteLineTriggerHandlerTest {

    @TestSetup
    static void dataSettingUp(){
        SBQQ.TriggerControl.disable();
        
        String quoteTypeRenewal = 'Renewal';
        List<Account> testAccounts = TDF_AccountUtils.createListOfAccountsWithCVRAndOwner(1);
        insert testAccounts;

        List<Opportunity> testOpps = TDF_OpportunityUtils.createOpportunitiesForAccounts(1, testAccounts);

        List<SBQQ__Quote__c> testQuotes = new List<SBQQ__Quote__c>();
        SBQQ__Quote__c testQuote = TDF_QuoteUtils.createSingleQuote(testAccounts[0].Id, testOpps[0].Id);
        testQuotes.add(testQuote);
        insert testQuotes;

        for (SBQQ__Quote__c singleQ : testQuotes) {
            singleQ.SBQQ__Type__c = quoteTypeRenewal;
        }
        update testQuotes;

        Test.startTest();
        List<SBQQ__QuoteLine__c> testQuoteLines = testDataFactory.createQuoteLineRecordsForQuote( 3, testQuotes, 2, 2, true );
        Test.stopTest();

        List<Quote_Line_Detail__c> testQuoteLineDetails = testDataFactory.createQuoteLineDetailsForQuoteLines( 2, testQuoteLines );
        SBQQ.TriggerControl.enable();
    }

    @IsTest
    static void amountDiscountTest(){
        // Prepare some QL with 
        
        List<SBQQ__QuoteLine__c> theQL = [SELECT Id, SBQQ__AdditionalDiscountAmount__c, SBQQ__Discount__c FROM SBQQ__QuoteLine__c];

        for( SBQQ__QuoteLine__c singleQL : theQL ){
            System.assertEquals( 0, (singleQL.SBQQ__AdditionalDiscountAmount__c == null ? 0 : singleQL.SBQQ__AdditionalDiscountAmount__c) , 'The amount discount should always be 0' );
            if( singleQL.SBQQ__Discount__c != 0.0 && singleQL.SBQQ__Discount__c != null ) System.assertEquals( 15.0, singleQL.SBQQ__Discount__c, 'The discount should be 15 after removing additional discoutn amount' );
        }
    }

    /**
     * Test of quote line additional quantity when on a Renewal quote
     */
    @IsTest
    static void quantityToAdditionalQuantityOnQLInsertRenewalQuote() {
        // get the test quote
        List<SBQQ__Quote__c> testQuotes = [SELECT Id FROM SBQQ__Quote__c LIMIT 1];
        
        Integer numberOfDifferentProducts = 1;
        List<Product2> listOfProductsToUse = TDF_ProductUtils.createProductsForTests(numberOfDifferentProducts);

        List<PricebookEntry> listOfPricebookEntries = TDF_ProductUtils.createStandardPricebookEntriesForProducts(listOfProductsToUse);
        Map<Id, PricebookEntry> mapOfProductToPricebookEntries = TDF_ProductUtils.createProductIdToPricebookEntryMap(
            listOfPricebookEntries, 
            listOfProductsToUse
        );
      
        Test.startTest();

        // create quotelines on quote
        List<SBQQ__QuoteLine__c> testQuoteLinesList = TDF_QuoteLineUtils.createQuoteLinesForQuote(
            testQuotes, 
            false, listOfProductsToUse, 
            mapOfProductToPricebookEntries
        );
        
        Test.stopTest();

        List<SBQQ__QuoteLine__c> listOfQuoteLines = [
            SELECT Id, 
                SBQQ__Quantity__c, 
                Additional_Quantity__c
            FROM SBQQ__QuoteLine__c
            WHERE Id IN :testQuoteLinesList
        ];
        Assert.areEqual(listOfQuoteLines[0].SBQQ__Quantity__c, listOfQuoteLines[0].Additional_Quantity__c, 'Additional Quantity should be equal to quantity');
    }
}