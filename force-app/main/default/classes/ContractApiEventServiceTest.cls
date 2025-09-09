@IsTest
public with sharing class ContractApiEventServiceTest {
    private static final String TEST_CVR = '12345678';
    private static final Integer AMOUNT_OF_DIFFERENT_PRODUCTS = 2;
    private static final Integer EXTENDED_TERM = Integer.valueOf(Contract_API_Event_Setting__mdt.getInstance('Default').Extended_Term__c);

    //@TestSetup
    private static void makeData() {
        SBQQ.TriggerControl.disable();

        Account acc = TDF_AccountUtils.createAccountWithCVR(TEST_CVR);
        acc.Status__c = 'Active';
        insert acc;

        Opportunity opp = TDF_OpportunityUtils.createOpportunitiesForAccounts(1, new List<Account>{acc})[0];

        SBQQ__Quote__c quote = TDF_QuoteUtils.createSingleQuote(acc.Id, opp.Id);
        quote.SBQQ__StartDate__c = System.today().addDays(10);
        insert quote;

        opp.Original_Primary_Quote__c = quote.Id;
        opp.SBQQ__PrimaryQuote__c = quote.Id; //this is actually supposed to be the Activation Quote, but we don't need that for testing here
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
        
        
        SBQQ.TriggerControl.enable();

    }

    @IsTest
    private static void createEvents_InputsSignedQuoteWithinDateScope_ResultPublishedPlatformEventWithProducts() {
        //ARRANGE
        makeData();

        Account acc = AccountSelector.getByCVR(TEST_CVR);
        List<Id> accountIds = new List<Id>{acc.Id};

        //ACT
        Test.startTest();
        ContractApiEventService.createEvents(accountIds);
        List<AccountWithProducts__e> events = ContractApiEventService.events;
        Test.getEventBus().deliver();
        List<Database.SaveResult> publishResults = ContractApiEventService.publishResults;
        Test.stopTest();

        //ASSERT
        Assert.areEqual(1, events.size(), 'Exactly 1 event should be created.');
        ContractApiEventService.Payload innerJSON = (ContractApiEventService.Payload) JSON.deserialize(events[0].JSON_AccountWithProducts__c, ContractApiEventService.Payload.class);
        Assert.areEqual(TEST_CVR, innerJSON.account.cvr, 'The CVR should match');
        Assert.areEqual(AMOUNT_OF_DIFFERENT_PRODUCTS, innerJSON.quotes[0].products.size(), 'Amount of Products should match');

        for (Database.SaveResult publishResult : publishResults) {
            Assert.isTrue(publishResult.isSuccess(), 'Publish should be successful: ' + publishResult.getErrors());
        }
    }

    @IsTest
    private static void createEvents_InputsSignedQuoteOutsideDateScope_ResultPublishedPlatformEventWithoutProducts() {
        //ARRANGE
        makeData();

        Account acc = AccountSelector.getByCVR(TEST_CVR);
        List<Id> accountIds = new List<Id>{acc.Id};

        SBQQ__Quote__c quote = QuoteSelector.getQuotesByAccountCVRs(new List<String>{TEST_CVR})[0];
        quote.SBQQ__StartDate__c = System.today().addMonths(-36-EXTENDED_TERM).addDays(-1);
        update quote;

        //ACT
        Test.startTest();
        ContractApiEventService.createEvents(accountIds);
        List<AccountWithProducts__e> events = ContractApiEventService.events;
        Test.getEventBus().deliver();
        List<Database.SaveResult> publishResults = ContractApiEventService.publishResults;
        Test.stopTest();

        //ASSERT
        Assert.areEqual(1, events.size(), 'Exactly 1 event should be created.');
        ContractApiEventService.Payload innerJSON = (ContractApiEventService.Payload) JSON.deserialize(events[0].JSON_AccountWithProducts__c, ContractApiEventService.Payload.class);
        Assert.areEqual(TEST_CVR, innerJSON.account.cvr, 'The CVR should match');
        Assert.isTrue(innerJSON.quotes.isEmpty(), 'No quotes should be returned when not in the date scope');

        for (Database.SaveResult publishResult : publishResults) {
            Assert.isTrue(publishResult.isSuccess(), 'Publish should be successful: ' + publishResult.getErrors());
        }
    }

    @IsTest
    private static void createEvents_InputsTwoSignedQuoteWithinDateScope_ResultPublishedPlatformEventWithTwoQuotes() {
        //ARRANGE
        makeData();

        Account acc = AccountSelector.getByCVR(TEST_CVR);
        List<Id> accountIds = new List<Id>{acc.Id};

        Opportunity oppTwo = TDF_OpportunityUtils.createOpportunitiesForAccounts(1, new List<Account>{acc})[0];

        SBQQ__Quote__c quoteTwo = TDF_QuoteUtils.createSingleQuote(acc.Id, oppTwo.Id);
        quoteTwo.SBQQ__StartDate__c = System.today().addDays(10);
        insert quoteTwo;

        oppTwo.Original_Primary_Quote__c = quoteTwo.Id;
        oppTwo.SBQQ__PrimaryQuote__c = quoteTwo.Id; //this is actually supposed to be the Activation Quote, but we don't need that for testing here
        update oppTwo;

        List<Product2> listOfProductsToUse = TDF_ProductUtils.createProductsForTests(AMOUNT_OF_DIFFERENT_PRODUCTS);
        List<PricebookEntry> listOfPricebookEntries = TDF_ProductUtils.createStandardPricebookEntriesForProducts(listOfProductsToUse);
        Map<Id, PricebookEntry> mapOfProductToPricebookEntries = TDF_ProductUtils.createProductIdToPricebookEntryMap(
            listOfPricebookEntries, 
            listOfProductsToUse
        );

        TDF_QuoteLineUtils.createQuoteLinesForQuote(
            new List<SBQQ__Quote__c>{quoteTwo},
            false,
            listOfProductsToUse,
            mapOfProductToPricebookEntries
        );

        quoteTwo.SBQQ__Status__c = 'Signed';
        update quoteTwo;

        //ACT
        Test.startTest();
        ContractApiEventService.createEvents(accountIds);
        List<AccountWithProducts__e> events = ContractApiEventService.events;
        Test.getEventBus().deliver();
        List<Database.SaveResult> publishResults = ContractApiEventService.publishResults;
        Test.stopTest();

        //ASSERT
        Assert.areEqual(1, events.size(), 'Exactly 1 event should be created.');
        ContractApiEventService.Payload innerJSON = (ContractApiEventService.Payload) JSON.deserialize(events[0].JSON_AccountWithProducts__c, ContractApiEventService.Payload.class);
        Assert.areEqual(TEST_CVR, innerJSON.account.cvr, 'The CVR should match');
        Assert.areEqual(2, innerJSON.quotes.size(), 'Two Quotes should be returned');
        for (ContractApiEventService.QuoteDetail quote : innerJSON.quotes) {
            Assert.areEqual(AMOUNT_OF_DIFFERENT_PRODUCTS, quote.products.size(), 'Amount of Products should match');
        }

        for (Database.SaveResult publishResult : publishResults) {
            Assert.isTrue(publishResult.isSuccess(), 'Publish should be successful: ' + publishResult.getErrors());
        }
    }

    //TODO: khp fix unittest
    @IsTest
    private static void createEvents_InputsTwoSignedQuoteWithinAndOutsideDateScope_ResultPublishedPlatformEventWithOneQuote() {
        //ARRANGE
        makeData();

        Account acc = AccountSelector.getByCVR(TEST_CVR);
        List<Id> accountIds = new List<Id>{acc.Id};

        Opportunity oppOutdated = TDF_OpportunityUtils.createOpportunitiesForAccounts(1, new List<Account>{acc})[0];

        SBQQ__Quote__c quoteOutdated = TDF_QuoteUtils.createSingleQuote(acc.Id, oppOutdated.Id);
        // Cannot set a past Start Date here, as it will trigger Validation Rule Check_For_Past_Start_Date when Status is set to Signed later
        quoteOutdated.SBQQ__StartDate__c = System.today().addDays(10);
        insert quoteOutdated;

        oppOutdated.Original_Primary_Quote__c = quoteOutdated.Id;
        oppOutdated.SBQQ__PrimaryQuote__c = quoteOutdated.Id; //this is actually supposed to be the Activation Quote, but we don't need that for testing here
        update oppOutdated;

        List<Product2> listOfProductsToUse = TDF_ProductUtils.createProductsForTests(AMOUNT_OF_DIFFERENT_PRODUCTS);
        List<PricebookEntry> listOfPricebookEntries = TDF_ProductUtils.createStandardPricebookEntriesForProducts(listOfProductsToUse);
        Map<Id, PricebookEntry> mapOfProductToPricebookEntries = TDF_ProductUtils.createProductIdToPricebookEntryMap(
            listOfPricebookEntries, 
            listOfProductsToUse
        );

        TDF_QuoteLineUtils.createQuoteLinesForQuote(
            new List<SBQQ__Quote__c>{quoteOutdated},
            false,
            listOfProductsToUse,
            mapOfProductToPricebookEntries
        );

        quoteOutdated.SBQQ__Status__c = 'Signed';
        update quoteOutdated;

        // Updating Start Date to the past after seting Status = Signed to avoid hitting Validation Rule Check_For_Past_Start_Date
        quoteOutdated.SBQQ__StartDate__c = System.today().addMonths(-36-EXTENDED_TERM).addDays(-1);
        update quoteOutdated;

        //ACT
        Test.startTest();
        ContractApiEventService.createEvents(accountIds);
        List<AccountWithProducts__e> events = ContractApiEventService.events;
        Test.getEventBus().deliver();
        List<Database.SaveResult> publishResults = ContractApiEventService.publishResults;
        Test.stopTest();

        //ASSERT
        Assert.areEqual(1, events.size(), 'Exactly 1 event should be created.');
        ContractApiEventService.Payload innerJSON = (ContractApiEventService.Payload) JSON.deserialize(events[0].JSON_AccountWithProducts__c, ContractApiEventService.Payload.class);
        Assert.areEqual(TEST_CVR, innerJSON.account.cvr, 'The CVR should match');
        Assert.areEqual(1, innerJSON.quotes.size(), 'Only one Quote should be returned');
        Assert.areEqual(AMOUNT_OF_DIFFERENT_PRODUCTS, innerJSON.quotes[0].products.size(), 'Amount of Products should match');

        for(Database.SaveResult publishResult : publishResults) {
            Assert.isTrue(publishResult.isSuccess(), 'Publish should be successful: ' + publishResult.getErrors());
        }
    }
}