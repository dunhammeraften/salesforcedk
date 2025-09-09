@isTest
private class QuoteTriggerHandlerTest {

    private static final String TEST_CVR = '11223344';
    private static final Integer AMOUNT_OF_DIFFERENT_PRODUCTS = 2;

    //@TestSetup
    private static void dataSetup() {
        Account acc = TDF_AccountUtils.createAccountWithCVR(TEST_CVR);
        acc.Status__c = 'Active';
        insert acc;
        TDF_OpportunityUtils.createOpportunitiesForAccounts(1, new List<Account>{acc});
    }

    @isTest
    private static void testCreateQldFromAl_InputsActivationQuote_ResultJobScheduled() {
        //ARRANGE
        dataSetup();

        Account acc = AccountSelector.getByCVR(TEST_CVR);
        Opportunity opp = OpportunitySelector.getByAccountId(acc.Id);

        SBQQ__Quote__c originalQuote = TDF_QuoteUtils.createSingleQuote(acc.Id, opp.Id);
        originalQuote.SBQQ__Type__c = QuoteService.TYPE_RENEWAL;
        originalQuote.Ghost_Quote__c = false;
        insert originalQuote;

        opp.Original_Primary_Quote__c = originalQuote.Id;
        update opp;

        SBQQ__Quote__c quote = TDF_QuoteUtils.createSingleQuote(acc.Id, opp.Id);
        quote.RecordTypeId = QuoteService.ACTIVATION_QUOTE_RECORD_TYPE_ID;

        //ACT
        String cronId;
        Test.startTest();
        insert quote;
        cronId = QuoteService.qldFromAlCronId;
        Test.stopTest();

        //ASSERT
        Assert.isNotNull(cronId, 'A job should be scheduled');
    }

    @isTest
    private static void testCreateQldFromSld_InputsRenewalQuote_ResultJobScheduled() {
        //ARRANGE
        dataSetup();

        Account acc = AccountSelector.getByCVR(TEST_CVR);
        Opportunity opp = OpportunitySelector.getByAccountId(acc.Id);
        update opp;

        SBQQ__Quote__c quote = TDF_QuoteUtils.createSingleQuote(acc.Id, opp.Id);
        quote.SBQQ__Type__c = QuoteService.TYPE_RENEWAL;
        quote.Ghost_Quote__c = false;

        //ACT
        Test.startTest();
        insert quote;
        String cronId = QuoteService.qldFromSldCronId;
        Test.stopTest();

        //ASSERT
        Assert.isNotNull(cronId, 'A job should be scheduled');
    }

    @isTest
    private static void testSetDocumentIdentifierFields_InputsValidDocumentIdentifier_ResultQuoteFieldUpdated() {
        //ARRANGE
        dataSetup();

        String mobileTypeProducts = 'Mobile Type Products';

        Account acc = AccountSelector.getByCVR(TEST_CVR);
        acc.Max_Quote_Amount__c = 1000000;
        update acc;

        Contact con = TDF_ContactUtils.createContact(acc);
        insert con;
        
        Opportunity opp = OpportunitySelector.getByAccountId(acc.Id);

        SBQQ__Quote__c quote = TDF_QuoteUtils.createSingleQuote(acc.Id, opp.Id);
        quote.Authorised_to_Sign__c = con.Id;
        quote.Send_Contract_to__c = con.Id;
        insert quote;

        List<Product2> listOfProductsToUse = TDF_ProductUtils.createProductsForTests(AMOUNT_OF_DIFFERENT_PRODUCTS);
        List<PricebookEntry> listOfPricebookEntries = TDF_ProductUtils.createStandardPricebookEntriesForProducts(listOfProductsToUse);
        Map<Id, PricebookEntry> mapOfProductToPricebookEntry = TDF_ProductUtils.createProductIdToPricebookEntryMap(
            listOfPricebookEntries, 
            listOfProductsToUse
        );

        TDF_QuoteLineUtils.createQuoteLinesForQuote(
            new List<SBQQ__Quote__c>{quote}, 
            false,
            listOfProductsToUse, 
            mapOfProductToPricebookEntry
        );

        for (Product2 product : listOfProductsToUse) {
            product.Document_Identifier__c = mobileTypeProducts;
        }
        update listOfProductsToUse;

        //ACT
        Test.startTest();
        quote.SBQQ__Status__c = QuoteService.STATUS_READY_FOR_CUSTOMER_REVIEW;
        update quote;
        Test.stopTest();

        //ASSERT
        List<Document_Identifier__mdt> documentIdentifierMappings = MetadataSelector.getDocumentIdentifierMappings();
        String quoteFieldApiName = '';
        for (Document_Identifier__mdt mapping : documentIdentifierMappings) {
            if (mapping.Product_Document_Identifier__c.equalsIgnoreCase(mobileTypeProducts)) {
                quoteFieldApiName = mapping.Label;
                break;
            }
        }

        String queryString = 'SELECT ' + quoteFieldApiName +
            ' FROM SBQQ__Quote__c' +
            ' WHERE Id = \'' + quote.Id + '\'' +
            ' LIMIT 1';

        SBQQ__Quote__c resultQuote = Database.query(queryString);
        Assert.isTrue((Boolean)resultQuote.get(quoteFieldApiName), 'The mapped field on Quote should be set to true');
    }

    @isTest
    private static void testSetDocumentIdentifierFields_InputsInvalidFieldMapping_ResultExceptionLoggedAsError() {
        //ARRANGE
        dataSetup();

        String mobileTypeProducts = 'Mobile Type Products';

        Account acc = AccountSelector.getByCVR(TEST_CVR);
        acc.Max_Quote_Amount__c = 1000000;
        update acc;

        Contact con = TDF_ContactUtils.createContact(acc);
        insert con;
        
        Opportunity opp = OpportunitySelector.getByAccountId(acc.Id);

        SBQQ__Quote__c quote = TDF_QuoteUtils.createSingleQuote(acc.Id, opp.Id);
        quote.Authorised_to_Sign__c = con.Id;
        quote.Send_Contract_to__c = con.Id;
        insert quote;

        List<Product2> listOfProductsToUse = TDF_ProductUtils.createProductsForTests(AMOUNT_OF_DIFFERENT_PRODUCTS);
        List<PricebookEntry> listOfPricebookEntries = TDF_ProductUtils.createStandardPricebookEntriesForProducts(listOfProductsToUse);
        Map<Id, PricebookEntry> mapOfProductToPricebookEntry = TDF_ProductUtils.createProductIdToPricebookEntryMap(
            listOfPricebookEntries, 
            listOfProductsToUse
        );

        TDF_QuoteLineUtils.createQuoteLinesForQuote(
            new List<SBQQ__Quote__c>{quote}, 
            false,
            listOfProductsToUse, 
            mapOfProductToPricebookEntry
        );

        for (Product2 product : listOfProductsToUse) {
            product.Document_Identifier__c = mobileTypeProducts;
        }
        update listOfProductsToUse;

        List<Document_Identifier__mdt> mockedMappings = new List<Document_Identifier__mdt>();
        Document_Identifier__mdt mockedMapping = new Document_Identifier__mdt();
        mockedMapping.Label = 'Invalid_Custom_Field__c';
        mockedMapping.Product_Document_Identifier__c = mobileTypeProducts;
        mockedMappings.add(mockedMapping);

        MetadataSelector.setMock(new MetadataSelectorMock(mockedMappings));

        //ACT
        Test.startTest();
        quote.SBQQ__Status__c = QuoteService.STATUS_READY_FOR_CUSTOMER_REVIEW;
        try {
            update quote;
            System.assert(false, 'Expected exception was not thrown');
        } catch (Exception ex) {
            System.assert(
                ex.getMessage().contains('Invalid field'),
                'Exception should be about invalid field'
            );
        }
        Test.stopTest();
    }

    @isTest
    private static void testCreateContractApiEvent_InputsSignedQuote_ResultPlatformEventCreatedQuoteWithProducts() {
        //ARRANGE
        dataSetup();

        Account acc = AccountSelector.getByCVR(TEST_CVR);
        Opportunity opp = TDF_OpportunityUtils.createOpportunitiesForAccounts(1, new List<Account>{acc})[0];

        SBQQ__Quote__c quote = TDF_QuoteUtils.createSingleQuote(acc.Id, opp.Id);
        quote.SBQQ__StartDate__c = System.today().addDays(10);
        insert quote;

        opp.Original_Primary_Quote__c = quote.Id;
        opp.SBQQ__PrimaryQuote__c = quote.Id; // this is actually supposed to be the Activation Quote, but we don't need that for testing here
        update opp;

        List<Product2> listOfProductsToUse = TDF_ProductUtils.createProductsForTests(AMOUNT_OF_DIFFERENT_PRODUCTS);
        List<PricebookEntry> listOfPricebookEntries = TDF_ProductUtils.createStandardPricebookEntriesForProducts(listOfProductsToUse);
        Map<Id, PricebookEntry> mapOfProductToPricebookEntry = TDF_ProductUtils.createProductIdToPricebookEntryMap(
            listOfPricebookEntries, 
            listOfProductsToUse
        );

        TDF_QuoteLineUtils.createQuoteLinesForQuote(
            new List<SBQQ__Quote__c>{quote}, 
            false,
            listOfProductsToUse, 
            mapOfProductToPricebookEntry
        );

        //ACT
        Test.startTest();
        quote.SBQQ__Status__c = QuoteService.STATUS_SIGNED;
        update quote;
        List<AccountWithProducts__e> events = ContractApiEventService.events;
        Test.getEventBus().deliver();
        List<Database.SaveResult> publishResults = ContractApiEventService.publishResults;
        Test.stopTest();

        //ASSERT
        Assert.areEqual(1, events.size(), 'Exactly 1 event should be created.');

        ContractApiEventService.Payload innerJSON = (ContractApiEventService.Payload) JSON.deserialize(events[0].JSON_AccountWithProducts__c, ContractApiEventService.Payload.class);
        Assert.areEqual(TEST_CVR, innerJSON.account.cvr, 'The CVR should match');
        Assert.areEqual(2, innerJSON.quotes[0].products.size(), 'Amount of Products should match');

        for (Database.SaveResult publishResult : publishResults) {
            Assert.isTrue(publishResult.isSuccess(), 'Publish should be successful: ' + publishResult.getErrors());
        }
    }

    @isTest
    private static void testCreateContractApiEvent_InputsUnsignedQuote_ResultPlatformEventCreatedNoQuotes() {
        //ARRANGE
        dataSetup();
        
        Account acc = AccountSelector.getByCVR(TEST_CVR);
        Opportunity opp = TDF_OpportunityUtils.createOpportunitiesForAccounts(1, new List<Account>{acc})[0];

        SBQQ__Quote__c quote = TDF_QuoteUtils.createSingleQuote(acc.Id, opp.Id);
        quote.SBQQ__StartDate__c = System.today().addDays(10);
        insert quote;

        opp.Original_Primary_Quote__c = quote.Id;
        opp.SBQQ__PrimaryQuote__c = quote.Id; // this is actually supposed to be the Activation Quote, but we don't need that for testing here
        update opp;

        List<Product2> listOfProductsToUse = TDF_ProductUtils.createProductsForTests(AMOUNT_OF_DIFFERENT_PRODUCTS);
        List<PricebookEntry> listOfPricebookEntries = TDF_ProductUtils.createStandardPricebookEntriesForProducts(listOfProductsToUse);
        Map<Id, PricebookEntry> mapOfProductToPricebookEntry = TDF_ProductUtils.createProductIdToPricebookEntryMap(
            listOfPricebookEntries, 
            listOfProductsToUse
        );

        TDF_QuoteLineUtils.createQuoteLinesForQuote(
            new List<SBQQ__Quote__c>{quote}, 
            false,
            listOfProductsToUse, 
            mapOfProductToPricebookEntry
        );

        quote.SBQQ__Status__c = QuoteService.STATUS_SIGNED;
        update quote;

        //ACT
        Test.startTest();
        quote.SBQQ__Status__c = 'Draft';
        update quote;
        List<AccountWithProducts__e> events = ContractApiEventService.events;
        Test.getEventBus().deliver();
        List<Database.SaveResult> publishResults = ContractApiEventService.publishResults;
        Test.stopTest();

        //ASSERT
        Assert.areEqual(1, events.size(), 'Exactly 1 event should be created.');

        ContractApiEventService.Payload innerJSON = (ContractApiEventService.Payload) JSON.deserialize(events[0].JSON_AccountWithProducts__c, ContractApiEventService.Payload.class);
        Assert.areEqual(TEST_CVR, innerJSON.account.cvr, 'The CVR should match');
        Assert.areEqual(0, innerJSON.quotes.size(), 'As quote is no longer Signed no products should be included');

        for (Database.SaveResult publishResult : publishResults) {
            Assert.isTrue(publishResult.isSuccess(), 'Publish should be successful: ' + publishResult.getErrors());
        }
    }

    @isTest
    private static void testCreateContractApiEvent_InputQuoteWithManualValidUntilYesterday_ResultPlatformEventCreatedNoQuotes() {
        //ARRANGE
        dataSetup();
        
        Account acc = AccountSelector.getByCVR(TEST_CVR);
        Opportunity opp = TDF_OpportunityUtils.createOpportunitiesForAccounts(1, new List<Account>{acc})[0];

        SBQQ__Quote__c quote = TDF_QuoteUtils.createSingleQuote(acc.Id, opp.Id);
        quote.SBQQ__StartDate__c = System.today().addDays(10);
        insert quote;

        opp.Original_Primary_Quote__c = quote.Id;
        opp.SBQQ__PrimaryQuote__c = quote.Id; // this is actually supposed to be the Activation Quote, but we don't need that for testing here
        update opp;

        List<Product2> listOfProductsToUse = TDF_ProductUtils.createProductsForTests(AMOUNT_OF_DIFFERENT_PRODUCTS);
        List<PricebookEntry> listOfPricebookEntries = TDF_ProductUtils.createStandardPricebookEntriesForProducts(listOfProductsToUse);
        Map<Id, PricebookEntry> mapOfProductToPricebookEntry = TDF_ProductUtils.createProductIdToPricebookEntryMap(
            listOfPricebookEntries, 
            listOfProductsToUse
        );

        TDF_QuoteLineUtils.createQuoteLinesForQuote(
            new List<SBQQ__Quote__c>{quote}, 
            false,
            listOfProductsToUse, 
            mapOfProductToPricebookEntry
        );

        quote.SBQQ__Status__c = QuoteService.STATUS_SIGNED;
        update quote;

        //ACT
        Test.startTest();
        quote.Manual_Valid_Until__c = System.today().addDays(-1);
        update quote;
        List<AccountWithProducts__e> events = ContractApiEventService.events;
        Test.getEventBus().deliver();
        List<Database.SaveResult> publishResults = ContractApiEventService.publishResults;
        Test.stopTest();

        //ASSERT
        ContractApiEventService.Payload innerJSON = (ContractApiEventService.Payload) JSON.deserialize(events[0].JSON_AccountWithProducts__c, ContractApiEventService.Payload.class);
        Assert.areEqual(TEST_CVR, innerJSON.account.cvr, 'The CVR should match');
        Assert.areEqual(0, innerJSON.quotes.size(), 'As quote is no valid no products should be included');

        for (Database.SaveResult publishResult : publishResults) {
            Assert.isTrue(publishResult.isSuccess(), 'Publish should be successful: ' + publishResult.getErrors());
        }
    }

    @isTest
    private static void testCreateContractApiEvent_InputQuoteWithManualValidChangedToToday_ResultPlatformEventCreatedQuoteWithProducts() {
        //ARRANGE
        dataSetup();
        
        Account acc = AccountSelector.getByCVR(TEST_CVR);
        Opportunity opp = TDF_OpportunityUtils.createOpportunitiesForAccounts(1, new List<Account>{acc})[0];

        SBQQ__Quote__c quote = TDF_QuoteUtils.createSingleQuote(acc.Id, opp.Id);
        quote.SBQQ__StartDate__c = System.today().addDays(10);
        insert quote;

        opp.Original_Primary_Quote__c = quote.Id;
        opp.SBQQ__PrimaryQuote__c = quote.Id; // this is actually supposed to be the Activation Quote, but we don't need that for testing here
        update opp;

        List<Product2> listOfProductsToUse = TDF_ProductUtils.createProductsForTests(AMOUNT_OF_DIFFERENT_PRODUCTS);
        List<PricebookEntry> listOfPricebookEntries = TDF_ProductUtils.createStandardPricebookEntriesForProducts(listOfProductsToUse);
        Map<Id, PricebookEntry> mapOfProductToPricebookEntry = TDF_ProductUtils.createProductIdToPricebookEntryMap(
            listOfPricebookEntries, 
            listOfProductsToUse
        );

        TDF_QuoteLineUtils.createQuoteLinesForQuote(
            new List<SBQQ__Quote__c>{quote},
            false,
            listOfProductsToUse,
            mapOfProductToPricebookEntry
        );

        quote.SBQQ__Status__c = QuoteService.STATUS_SIGNED;
        // setting Manual_Valid_Until__c to yesterday to not have products sent to Contract API initially
        quote.Manual_Valid_Until__c = System.today().addDays(-1);
        update quote;

        //ACT
        Test.startTest();
        // setting Manual_Valid_Until__c to today to have products sent to Contract API after update
        quote.Manual_Valid_Until__c = System.today();
        update quote;
        List<AccountWithProducts__e> events = ContractApiEventService.events;
        Test.getEventBus().deliver();
        List<Database.SaveResult> publishResults = ContractApiEventService.publishResults;
        Test.stopTest();

        //ASSERT
        ContractApiEventService.Payload innerJSON = (ContractApiEventService.Payload) JSON.deserialize(events[0].JSON_AccountWithProducts__c, ContractApiEventService.Payload.class);
        Assert.areEqual(TEST_CVR, innerJSON.account.cvr, 'The CVR should match');
        Assert.areEqual(AMOUNT_OF_DIFFERENT_PRODUCTS, innerJSON.quotes[0].products.size(), 'Amount of Products should match');
        Assert.areEqual(quote.Manual_Valid_Until__c, innerJSON.quotes[0].validUntil, 'Valid Until should match Manual Valid Until from Quote');

        for (Database.SaveResult publishResult : publishResults) {
            Assert.isTrue(publishResult.isSuccess(), 'Publish should be successful: ' + publishResult.getErrors());
        }
    }
}