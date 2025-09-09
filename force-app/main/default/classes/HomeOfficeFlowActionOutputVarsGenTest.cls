@IsTest
private with sharing class HomeOfficeFlowActionOutputVarsGenTest {
    
    @TestSetup
    private static void makeDataFramework() {
        String cvr = '12345678';
        // create the Account
        Account testAccount = TDF_AccountUtils.createAccountWithCVR(cvr);
        testAccount.Status__c = 'Active';
        insert testAccount;

        // we create 1 Opportunity for Account
        List<Opportunity> testOpportunities = TDF_OpportunityUtils.createHomeOfficeOpportunityForAccounts(
            new List<Account>{testAccount}, 
            HomeOfficeConstants.AGREEMENT_TYPE_FRAMEWORK
        );

        // create 1 Quote for opp
        SBQQ__Quote__c testQuote = TDF_QuoteUtils.createSingleQuote(testAccount.Id, testOpportunities[0].Id);
        insert testQuote;

        // set the primary quote field on the opp
        testOpportunities = [
            SELECT Id, AccountId, SBQQ__PrimaryQuote__c, SBQQ__PrimaryQuote__r.SBQQ__StartDate__c, Case__c 
            FROM Opportunity
        ];
        testOpportunities[0].SBQQ__PrimaryQuote__c = testQuote.Id;
        update testOpportunities;

        // we need Home Office Products, insert and return
        Integer numberOfDifferentProducts = 1;
        List<Product2> listOfProductsToUse = TDF_ProductUtils.createHomeOfficeProducts(numberOfDifferentProducts);
        // we need to set the ProductAPI_Telia_Product_Id__c to HomeOfficeConstants.LOCATION_LINE_SUBSCRIPTION_PRODUCT_FIBHOF03
        listOfProductsToUse[0].ProductAPI_Telia_Product_Id__c = HomeOfficeConstants.LOCATION_LINE_SUBSCRIPTION_PRODUCT_FIBHOF03;
        update listOfProductsToUse;

        List<PricebookEntry> listOfPricebookEntries = TDF_ProductUtils.createStandardPricebookEntriesForProducts(
            listOfProductsToUse
        );
        Map<Id, PricebookEntry> mapOfProductToPricebookEntries = TDF_ProductUtils.createProductIdToPricebookEntryMap(
            listOfPricebookEntries, 
            listOfProductsToUse
        );

        // create Quote Lines for the Quotes
        List<SBQQ__QuoteLine__c> testQuoteLines = TDF_QuoteLineUtils.createQuoteLinesForQuote(
            new List<SBQQ__Quote__c>{testQuote}, 
            false, 
            listOfProductsToUse, 
            mapOfProductToPricebookEntries
        );
        // requery to have the fields
        testQuoteLines = [
            SELECT 
                Id, 
                Activation__c, 
                Activation_Created__c,
                Activation_Record_Type__c, 
                SBQQ__Product__c,
                SBQQ__Product__r.Name,
                SBQQ__Quote__c,
                SBQQ__Quote__r.Name,
                SBQQ__Quote__r.SBQQ__BillingCity__c 
            FROM SBQQ__QuoteLine__c
        ];

        // create Case that looks up to same Account as the Quote does, and looks up to the same Opportunity as the Quote does
        List<Case> testCases = TDF_CaseUtils.createCasesForOpportunitiesAndAssignThem(testOpportunities);

        // create activation on case and account
        List<Activation__c> activationHeadersList = TDF_ActivationUtils.createActivationHeadersForQuoteLines(
            testQuoteLines, 
            testOpportunities
        );

        // create Location Line opp, then insert
        Location_Line__c testLocationLine = TDF_LocationLineUtils.createLocationLineForOpportunity(
            testOpportunities[0], 
            HomeOfficeConstants.LOCATION_LINE_SUBSCRIPTION_PRODUCT_FIBHOF03,
            null
        );
        testLocationLine.OTC_product__c = 'CHXT02';
        insert testLocationLine;

        // create and insert Activation Lines, then re-query
        List<Activation_Line__c> activationLinesList = TDF_ActivationLineUtils.createActivationLines(testQuoteLines);
        activationLinesList = [
            SELECT 
                Id, 
                Installation_address__c, 
                Location_Line__c, 
                Location_Line__r.Name, 
                Opportunity_ID__c,
                Quote_Line__c, 
                Quote_Line__r.SBQQ__Quote__c 
            FROM Activation_Line__c
        ];

        activationLinesList[0].Location_Line__c = testLocationLine.Id;
        update activationLinesList;      
    }

    @IsTest
    private static void testExceptionAgreementTypeMissing() {
        // ARRANGE
        // get the opportunity
        Opportunity testOpportunity = [SELECT Id, Agreement_Type__c FROM Opportunity LIMIT 1];     
        testOpportunity.Agreement_Type__c = '';
        update testOpportunity;

        // ACT and ASSERT
        Test.startTest();

        try {
            HomeOfficeFlowActionOutputVarsGenerator.generateListOfOutputVars(new List<Opportunity>{testOpportunity});
            Assert.fail('DmlException Expected');
        } catch (Exception e) {
            Assert.areEqual(HomeOfficeConstants.ERROR_MESSAGE_AGREEMENT_TYPE, e.getMessage(), 'Exception message is not correct');
        }        

        Test.stopTest();
    }

    @IsTest  
    private static void activationLineVasCHXT01() {
        // ARRANGE
        String otcProductValue = HomeOfficeConstants.LOCATION_LINE_OTC_PRODUCT_CHXT01;

        // get the activation line that was created in TestSetup
        Activation_Line__c testActivationLine = [SELECT Id FROM Activation_Line__c LIMIT 1];  

        // ACT
        Test.startTest();

        HomeOfficeFlowActionOutputVarsGenerator.switchActivationLineVasChxtFieldsToTrueOnMatch(testActivationLine, otcProductValue);

        Test.stopTest();
        update testActivationLine;

        // ASSERT
        testActivationLine = [
            SELECT 
                Id, 
                VAS_CHXT01__c,
                VAS_CHXT02__c,
                VAS_CHXT03__c,
                VAS_CHXT04__c,
                VAS_CHXT05__c,
                VAS_CHXT06__c,
                VAS_CHXT07__c,
                VAS_CHXT08__c,
                VAS_CHXT11__c,
                VAS_CHXT12__c
            FROM Activation_Line__c 
            LIMIT 1
        ]; 

        Assert.isTrue(testActivationLine.VAS_CHXT01__c, 'VAS_CHXT01__c should be true.');
        // sanity check the others are false
        Assert.isFalse(testActivationLine.VAS_CHXT02__c, 'VAS_CHXT02__c should be false.');
        Assert.isFalse(testActivationLine.VAS_CHXT03__c, 'VAS_CHXT03__c should be false.');
        Assert.isFalse(testActivationLine.VAS_CHXT04__c, 'VAS_CHXT04__c should be false.');
        Assert.isFalse(testActivationLine.VAS_CHXT05__c, 'VAS_CHXT05__c should be false.');
        Assert.isFalse(testActivationLine.VAS_CHXT06__c, 'VAS_CHXT06__c should be false.');
        Assert.isFalse(testActivationLine.VAS_CHXT07__c, 'VAS_CHXT07__c should be false.');
        Assert.isFalse(testActivationLine.VAS_CHXT08__c, 'VAS_CHXT08__c should be false.');
        Assert.isFalse(testActivationLine.VAS_CHXT11__c, 'VAS_CHXT11__c should be false.');
        Assert.isFalse(testActivationLine.VAS_CHXT12__c, 'VAS_CHXT12__c should be false.');
    }

    @IsTest  
    private static void activationLineVasCHXT02() {
        // ARRANGE
        String otcProductValue = HomeOfficeConstants.LOCATION_LINE_OTC_PRODUCT_CHXT02;

        // get the activation line that was created in TestSetup
        Activation_Line__c testActivationLine = [SELECT Id FROM Activation_Line__c LIMIT 1];  

        // ACT
        Test.startTest();

        HomeOfficeFlowActionOutputVarsGenerator.switchActivationLineVasChxtFieldsToTrueOnMatch(testActivationLine, otcProductValue);

        Test.stopTest();
        update testActivationLine;

        // ASSERT
        testActivationLine = [
            SELECT 
                Id, 
                VAS_CHXT01__c,
                VAS_CHXT02__c,
                VAS_CHXT03__c,
                VAS_CHXT04__c,
                VAS_CHXT05__c,
                VAS_CHXT06__c,
                VAS_CHXT07__c,
                VAS_CHXT08__c,
                VAS_CHXT11__c,
                VAS_CHXT12__c
            FROM Activation_Line__c 
            LIMIT 1
        ]; 

        Assert.isTrue(testActivationLine.VAS_CHXT02__c, 'VAS_CHXT02__c should be true.');
        // sanity check the others are false
        Assert.isFalse(testActivationLine.VAS_CHXT01__c, 'VAS_CHXT01__c should be false.');
        Assert.isFalse(testActivationLine.VAS_CHXT03__c, 'VAS_CHXT03__c should be false.');
        Assert.isFalse(testActivationLine.VAS_CHXT04__c, 'VAS_CHXT04__c should be false.');
        Assert.isFalse(testActivationLine.VAS_CHXT05__c, 'VAS_CHXT05__c should be false.');
        Assert.isFalse(testActivationLine.VAS_CHXT06__c, 'VAS_CHXT06__c should be false.');
        Assert.isFalse(testActivationLine.VAS_CHXT07__c, 'VAS_CHXT07__c should be false.');
        Assert.isFalse(testActivationLine.VAS_CHXT08__c, 'VAS_CHXT08__c should be false.');
        Assert.isFalse(testActivationLine.VAS_CHXT11__c, 'VAS_CHXT11__c should be false.');
        Assert.isFalse(testActivationLine.VAS_CHXT12__c, 'VAS_CHXT12__c should be false.');
    }

    @IsTest  
    private static void activationLineVasCHXT03() {
        // ARRANGE
        String otcProductValue = HomeOfficeConstants.LOCATION_LINE_OTC_PRODUCT_CHXT03;

        // get the activation line that was created in TestSetup
        Activation_Line__c testActivationLine = [SELECT Id FROM Activation_Line__c LIMIT 1];  

        // ACT
        Test.startTest();

        HomeOfficeFlowActionOutputVarsGenerator.switchActivationLineVasChxtFieldsToTrueOnMatch(testActivationLine, otcProductValue);

        Test.stopTest();
        update testActivationLine;

        // ASSERT
        testActivationLine = [
            SELECT 
                Id, 
                VAS_CHXT01__c,
                VAS_CHXT02__c,
                VAS_CHXT03__c,
                VAS_CHXT04__c,
                VAS_CHXT05__c,
                VAS_CHXT06__c,
                VAS_CHXT07__c,
                VAS_CHXT08__c,
                VAS_CHXT11__c,
                VAS_CHXT12__c
            FROM Activation_Line__c 
            LIMIT 1
        ]; 

        Assert.isTrue(testActivationLine.VAS_CHXT03__c, 'VAS_CHXT03__c should be true.');
        // sanity check the others are false
        Assert.isFalse(testActivationLine.VAS_CHXT01__c, 'VAS_CHXT01__c should be false.');
        Assert.isFalse(testActivationLine.VAS_CHXT02__c, 'VAS_CHXT02__c should be false.');
        Assert.isFalse(testActivationLine.VAS_CHXT04__c, 'VAS_CHXT04__c should be false.');
        Assert.isFalse(testActivationLine.VAS_CHXT05__c, 'VAS_CHXT05__c should be false.');
        Assert.isFalse(testActivationLine.VAS_CHXT06__c, 'VAS_CHXT06__c should be false.');
        Assert.isFalse(testActivationLine.VAS_CHXT07__c, 'VAS_CHXT07__c should be false.');
        Assert.isFalse(testActivationLine.VAS_CHXT08__c, 'VAS_CHXT08__c should be false.');
        Assert.isFalse(testActivationLine.VAS_CHXT11__c, 'VAS_CHXT11__c should be false.');
        Assert.isFalse(testActivationLine.VAS_CHXT12__c, 'VAS_CHXT12__c should be false.');
    }

    @IsTest  
    private static void activationLineVasCHXT04() {
        // ARRANGE
        String otcProductValue = HomeOfficeConstants.LOCATION_LINE_OTC_PRODUCT_CHXT04;

        // get the activation line that was created in TestSetup
        Activation_Line__c testActivationLine = [SELECT Id FROM Activation_Line__c LIMIT 1];  

        // ACT
        Test.startTest();

        HomeOfficeFlowActionOutputVarsGenerator.switchActivationLineVasChxtFieldsToTrueOnMatch(testActivationLine, otcProductValue);

        Test.stopTest();
        update testActivationLine;

        // ASSERT
        testActivationLine = [
            SELECT 
                Id, 
                VAS_CHXT01__c,
                VAS_CHXT02__c,
                VAS_CHXT03__c,
                VAS_CHXT04__c,
                VAS_CHXT05__c,
                VAS_CHXT06__c,
                VAS_CHXT07__c,
                VAS_CHXT08__c,
                VAS_CHXT11__c,
                VAS_CHXT12__c
            FROM Activation_Line__c 
            LIMIT 1
        ]; 

        Assert.isTrue(testActivationLine.VAS_CHXT04__c, 'VAS_CHXT04__c should be true.');
        // sanity check the others are false
        Assert.isFalse(testActivationLine.VAS_CHXT01__c, 'VAS_CHXT01__c should be false.');
        Assert.isFalse(testActivationLine.VAS_CHXT02__c, 'VAS_CHXT02__c should be false.');
        Assert.isFalse(testActivationLine.VAS_CHXT03__c, 'VAS_CHXT03__c should be false.');
        Assert.isFalse(testActivationLine.VAS_CHXT05__c, 'VAS_CHXT05__c should be false.');
        Assert.isFalse(testActivationLine.VAS_CHXT06__c, 'VAS_CHXT06__c should be false.');
        Assert.isFalse(testActivationLine.VAS_CHXT07__c, 'VAS_CHXT07__c should be false.');
        Assert.isFalse(testActivationLine.VAS_CHXT08__c, 'VAS_CHXT08__c should be false.');
        Assert.isFalse(testActivationLine.VAS_CHXT11__c, 'VAS_CHXT11__c should be false.');
        Assert.isFalse(testActivationLine.VAS_CHXT12__c, 'VAS_CHXT12__c should be false.');
    }

    @IsTest  
    private static void activationLineVasCHXT05() {
        // ARRANGE
        String otcProductValue = HomeOfficeConstants.LOCATION_LINE_OTC_PRODUCT_CHXT05;

        // get the activation line that was created in TestSetup
        Activation_Line__c testActivationLine = [SELECT Id FROM Activation_Line__c LIMIT 1];  

        // ACT
        Test.startTest();

        HomeOfficeFlowActionOutputVarsGenerator.switchActivationLineVasChxtFieldsToTrueOnMatch(testActivationLine, otcProductValue);

        Test.stopTest();
        update testActivationLine;

        // ASSERT
        testActivationLine = [
            SELECT 
                Id, 
                VAS_CHXT01__c,
                VAS_CHXT02__c,
                VAS_CHXT03__c,
                VAS_CHXT04__c,
                VAS_CHXT05__c,
                VAS_CHXT06__c,
                VAS_CHXT07__c,
                VAS_CHXT08__c,
                VAS_CHXT11__c,
                VAS_CHXT12__c
            FROM Activation_Line__c 
            LIMIT 1
        ]; 

        Assert.isTrue(testActivationLine.VAS_CHXT05__c, 'VAS_CHXT05__c should be true.');
        // sanity check the others are false
        Assert.isFalse(testActivationLine.VAS_CHXT01__c, 'VAS_CHXT01__c should be false.');
        Assert.isFalse(testActivationLine.VAS_CHXT02__c, 'VAS_CHXT02__c should be false.');
        Assert.isFalse(testActivationLine.VAS_CHXT03__c, 'VAS_CHXT03__c should be false.');
        Assert.isFalse(testActivationLine.VAS_CHXT04__c, 'VAS_CHXT04__c should be false.');
        Assert.isFalse(testActivationLine.VAS_CHXT06__c, 'VAS_CHXT06__c should be false.');
        Assert.isFalse(testActivationLine.VAS_CHXT07__c, 'VAS_CHXT07__c should be false.');
        Assert.isFalse(testActivationLine.VAS_CHXT08__c, 'VAS_CHXT08__c should be false.');
        Assert.isFalse(testActivationLine.VAS_CHXT11__c, 'VAS_CHXT11__c should be false.');
        Assert.isFalse(testActivationLine.VAS_CHXT12__c, 'VAS_CHXT12__c should be false.');
    }

    @IsTest  
    private static void activationLineVasCHXT06() {
        // ARRANGE
        String otcProductValue = HomeOfficeConstants.LOCATION_LINE_OTC_PRODUCT_CHXT06;

        // get the activation line that was created in TestSetup
        Activation_Line__c testActivationLine = [SELECT Id FROM Activation_Line__c LIMIT 1];  

        // ACT
        Test.startTest();

        HomeOfficeFlowActionOutputVarsGenerator.switchActivationLineVasChxtFieldsToTrueOnMatch(testActivationLine, otcProductValue);

        Test.stopTest();
        update testActivationLine;

        // ASSERT
        testActivationLine = [
            SELECT 
                Id, 
                VAS_CHXT01__c,
                VAS_CHXT02__c,
                VAS_CHXT03__c,
                VAS_CHXT04__c,
                VAS_CHXT05__c,
                VAS_CHXT06__c,
                VAS_CHXT07__c,
                VAS_CHXT08__c,
                VAS_CHXT11__c,
                VAS_CHXT12__c
            FROM Activation_Line__c 
            LIMIT 1
        ]; 

        Assert.isTrue(testActivationLine.VAS_CHXT06__c, 'VAS_CHXT06__c should be true.');
        // sanity check the others are false
        Assert.isFalse(testActivationLine.VAS_CHXT01__c, 'VAS_CHXT01__c should be false.');
        Assert.isFalse(testActivationLine.VAS_CHXT02__c, 'VAS_CHXT02__c should be false.');
        Assert.isFalse(testActivationLine.VAS_CHXT03__c, 'VAS_CHXT03__c should be false.');
        Assert.isFalse(testActivationLine.VAS_CHXT04__c, 'VAS_CHXT04__c should be false.');
        Assert.isFalse(testActivationLine.VAS_CHXT05__c, 'VAS_CHXT05__c should be false.');
        Assert.isFalse(testActivationLine.VAS_CHXT07__c, 'VAS_CHXT07__c should be false.');
        Assert.isFalse(testActivationLine.VAS_CHXT08__c, 'VAS_CHXT08__c should be false.');
        Assert.isFalse(testActivationLine.VAS_CHXT11__c, 'VAS_CHXT11__c should be false.');
        Assert.isFalse(testActivationLine.VAS_CHXT12__c, 'VAS_CHXT12__c should be false.');
    }

    @IsTest  
    private static void activationLineVasCHXT07() {
        // ARRANGE
        String otcProductValue = HomeOfficeConstants.LOCATION_LINE_OTC_PRODUCT_CHXT07;

        // get the activation line that was created in TestSetup
        Activation_Line__c testActivationLine = [SELECT Id FROM Activation_Line__c LIMIT 1];  

        // ACT
        Test.startTest();

        HomeOfficeFlowActionOutputVarsGenerator.switchActivationLineVasChxtFieldsToTrueOnMatch(testActivationLine, otcProductValue);

        Test.stopTest();
        update testActivationLine;

        // ASSERT
        testActivationLine = [
            SELECT 
                Id, 
                VAS_CHXT01__c,
                VAS_CHXT02__c,
                VAS_CHXT03__c,
                VAS_CHXT04__c,
                VAS_CHXT05__c,
                VAS_CHXT06__c,
                VAS_CHXT07__c,
                VAS_CHXT08__c,
                VAS_CHXT11__c,
                VAS_CHXT12__c
            FROM Activation_Line__c 
            LIMIT 1
        ]; 

        Assert.isTrue(testActivationLine.VAS_CHXT07__c, 'VAS_CHXT07__c should be true.');
        // sanity check the others are false
        Assert.isFalse(testActivationLine.VAS_CHXT01__c, 'VAS_CHXT01__c should be false.');
        Assert.isFalse(testActivationLine.VAS_CHXT02__c, 'VAS_CHXT02__c should be false.');
        Assert.isFalse(testActivationLine.VAS_CHXT03__c, 'VAS_CHXT03__c should be false.');
        Assert.isFalse(testActivationLine.VAS_CHXT04__c, 'VAS_CHXT04__c should be false.');
        Assert.isFalse(testActivationLine.VAS_CHXT05__c, 'VAS_CHXT05__c should be false.');
        Assert.isFalse(testActivationLine.VAS_CHXT06__c, 'VAS_CHXT06__c should be false.');
        Assert.isFalse(testActivationLine.VAS_CHXT08__c, 'VAS_CHXT08__c should be false.');
        Assert.isFalse(testActivationLine.VAS_CHXT11__c, 'VAS_CHXT11__c should be false.');
        Assert.isFalse(testActivationLine.VAS_CHXT12__c, 'VAS_CHXT12__c should be false.');
    }

    @IsTest  
    private static void activationLineVasCHXT08() {
        // ARRANGE
        String otcProductValue = HomeOfficeConstants.LOCATION_LINE_OTC_PRODUCT_CHXT08;

        // get the activation line that was created in TestSetup
        Activation_Line__c testActivationLine = [SELECT Id FROM Activation_Line__c LIMIT 1];  

        // ACT
        Test.startTest();

        HomeOfficeFlowActionOutputVarsGenerator.switchActivationLineVasChxtFieldsToTrueOnMatch(testActivationLine, otcProductValue);

        Test.stopTest();
        update testActivationLine;

        // ASSERT
        testActivationLine = [
            SELECT 
                Id, 
                VAS_CHXT01__c,
                VAS_CHXT02__c,
                VAS_CHXT03__c,
                VAS_CHXT04__c,
                VAS_CHXT05__c,
                VAS_CHXT06__c,
                VAS_CHXT07__c,
                VAS_CHXT08__c,
                VAS_CHXT11__c,
                VAS_CHXT12__c
            FROM Activation_Line__c 
            LIMIT 1
        ]; 

        Assert.isTrue(testActivationLine.VAS_CHXT08__c, 'VAS_CHXT08__c should be true.');
        // sanity check the others are false
        Assert.isFalse(testActivationLine.VAS_CHXT01__c, 'VAS_CHXT01__c should be false.');
        Assert.isFalse(testActivationLine.VAS_CHXT02__c, 'VAS_CHXT02__c should be false.');
        Assert.isFalse(testActivationLine.VAS_CHXT03__c, 'VAS_CHXT03__c should be false.');
        Assert.isFalse(testActivationLine.VAS_CHXT04__c, 'VAS_CHXT04__c should be false.');
        Assert.isFalse(testActivationLine.VAS_CHXT05__c, 'VAS_CHXT05__c should be false.');
        Assert.isFalse(testActivationLine.VAS_CHXT06__c, 'VAS_CHXT06__c should be false.');
        Assert.isFalse(testActivationLine.VAS_CHXT07__c, 'VAS_CHXT07__c should be false.');
        Assert.isFalse(testActivationLine.VAS_CHXT11__c, 'VAS_CHXT11__c should be false.');
        Assert.isFalse(testActivationLine.VAS_CHXT12__c, 'VAS_CHXT12__c should be false.');
    }

    @IsTest  
    private static void activationLineVasCHXT11() {
        // ARRANGE
        String otcProductValue = HomeOfficeConstants.LOCATION_LINE_OTC_PRODUCT_CHXT11;

        // get the activation line that was created in TestSetup
        Activation_Line__c testActivationLine = [SELECT Id FROM Activation_Line__c LIMIT 1];  

        // ACT
        Test.startTest();

        HomeOfficeFlowActionOutputVarsGenerator.switchActivationLineVasChxtFieldsToTrueOnMatch(testActivationLine, otcProductValue);

        Test.stopTest();
        update testActivationLine;

        // ASSERT
        testActivationLine = [
            SELECT 
                Id, 
                VAS_CHXT01__c,
                VAS_CHXT02__c,
                VAS_CHXT03__c,
                VAS_CHXT04__c,
                VAS_CHXT05__c,
                VAS_CHXT06__c,
                VAS_CHXT07__c,
                VAS_CHXT08__c,
                VAS_CHXT11__c,
                VAS_CHXT12__c
            FROM Activation_Line__c 
            LIMIT 1
        ]; 

        Assert.isTrue(testActivationLine.VAS_CHXT11__c, 'VAS_CHXT11__c should be true.');
        // sanity check the others are false
        Assert.isFalse(testActivationLine.VAS_CHXT01__c, 'VAS_CHXT01__c should be false.');
        Assert.isFalse(testActivationLine.VAS_CHXT02__c, 'VAS_CHXT02__c should be false.');
        Assert.isFalse(testActivationLine.VAS_CHXT03__c, 'VAS_CHXT03__c should be false.');
        Assert.isFalse(testActivationLine.VAS_CHXT04__c, 'VAS_CHXT04__c should be false.');
        Assert.isFalse(testActivationLine.VAS_CHXT05__c, 'VAS_CHXT05__c should be false.');
        Assert.isFalse(testActivationLine.VAS_CHXT06__c, 'VAS_CHXT06__c should be false.');
        Assert.isFalse(testActivationLine.VAS_CHXT07__c, 'VAS_CHXT07__c should be false.');
        Assert.isFalse(testActivationLine.VAS_CHXT08__c, 'VAS_CHXT08__c should be false.');
        Assert.isFalse(testActivationLine.VAS_CHXT12__c, 'VAS_CHXT12__c should be false.');
    }

    @IsTest  
    private static void activationLineVasCHXT12() {
        // ARRANGE
        String otcProductValue = HomeOfficeConstants.LOCATION_LINE_OTC_PRODUCT_CHXT12;

        // get the activation line that was created in TestSetup
        Activation_Line__c testActivationLine = [SELECT Id FROM Activation_Line__c LIMIT 1];  

        // ACT
        Test.startTest();

        HomeOfficeFlowActionOutputVarsGenerator.switchActivationLineVasChxtFieldsToTrueOnMatch(testActivationLine, otcProductValue);

        Test.stopTest();
        update testActivationLine;

        // ASSERT
        testActivationLine = [
            SELECT 
                Id, 
                VAS_CHXT01__c,
                VAS_CHXT02__c,
                VAS_CHXT03__c,
                VAS_CHXT04__c,
                VAS_CHXT05__c,
                VAS_CHXT06__c,
                VAS_CHXT07__c,
                VAS_CHXT08__c,
                VAS_CHXT11__c,
                VAS_CHXT12__c
            FROM Activation_Line__c 
            LIMIT 1
        ]; 

        Assert.isTrue(testActivationLine.VAS_CHXT12__c, 'VAS_CHXT12__c should be true.');
        // sanity check the others are false
        Assert.isFalse(testActivationLine.VAS_CHXT01__c, 'VAS_CHXT01__c should be false.');
        Assert.isFalse(testActivationLine.VAS_CHXT02__c, 'VAS_CHXT02__c should be false.');
        Assert.isFalse(testActivationLine.VAS_CHXT03__c, 'VAS_CHXT03__c should be false.');
        Assert.isFalse(testActivationLine.VAS_CHXT04__c, 'VAS_CHXT04__c should be false.');
        Assert.isFalse(testActivationLine.VAS_CHXT05__c, 'VAS_CHXT05__c should be false.');
        Assert.isFalse(testActivationLine.VAS_CHXT06__c, 'VAS_CHXT06__c should be false.');
        Assert.isFalse(testActivationLine.VAS_CHXT07__c, 'VAS_CHXT07__c should be false.');
        Assert.isFalse(testActivationLine.VAS_CHXT08__c, 'VAS_CHXT08__c should be false.');
        Assert.isFalse(testActivationLine.VAS_CHXT11__c, 'VAS_CHXT11__c should be false.');
    }
}