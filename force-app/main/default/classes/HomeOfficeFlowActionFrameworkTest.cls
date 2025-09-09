/** 
 * Testing HomeOfficeFlowAction class
 * 
 * @author  Kirstine Nielsen
 * @since   07-05-2025
 * @see     https://jira.atlassian.teliacompany.net/browse/DKT-44508
 */
@IsTest 
private with sharing class HomeOfficeFlowActionFrameworkTest {

    /**
     * Single opportunity for framework
     */
    @IsTest  
    private static void singleOpportunity_Framework() {
        // ARRANGE
        List<String> cvrList = new List<String>{'12345678'};
        TDF_HomeOfficeUtils.makeDataFramework(cvrList);

        // get the opportunity that was created in TestSetup
        Opportunity testOpportunity = [SELECT Id, Agreement_Type__c FROM Opportunity LIMIT 1];
        
        List<SBQQ__QuoteLine__c> testQuoteLines = [
            SELECT 
                Id, 
                SBQQ__Product__c
            FROM SBQQ__QuoteLine__c
        ];

        // prep your inputVariables object and add to inputVariablesList
        HomeOfficeFlowAction.InputVariables inputVariables = new HomeOfficeFlowAction.InputVariables();
        inputVariables.inputOpportunity = testOpportunity;
        List<HomeOfficeFlowAction.InputVariables> inputVariablesList = new List<HomeOfficeFlowAction.InputVariables>{inputVariables};

        // prep portal user run as data
        Account testAccount = [SELECT Id, Name, CVR__c FROM Account LIMIT 1];
        User testPortalUser = getTestOnboardingPortalUser(testAccount);

        List<HomeOfficeFlowAction.OutputVariables> testOutputVariablesList;

        // ACT
        Test.startTest();
            
        System.runAs(testPortalUser) {
            testOutputVariablesList = HomeOfficeFlowAction.getHomeOfficeRelatedRecordsToActOn(inputVariablesList);            
        }

        Test.stopTest();

        // ASSERT
        Assert.areEqual(1, testOutputVariablesList.size(), 'We expected 1 OutputVarables');
        // loop the outputVariables and compare the results with your expected variables
        for (HomeOfficeFlowAction.OutputVariables testOutputVariables : testOutputVariablesList) {
            Assert.areEqual(1, testOutputVariables.activationLinesToUpdate.size(), 'We expected 1 Activation Line to update');
            // since Framework, we expect Location Line should be updated (the Quote Line field is set)
            Assert.areEqual(1, testOutputVariables.locationLinesToUpdate.size(), 'We expected 1 Location Line to update');
            Assert.areEqual(1, testOutputVariables.quoteLinesToUpdate.size(), 'We expected 1 Quote Line to update');
            Assert.areEqual(0, testOutputVariables.activationLinesToDelete.size(), 'We expected 0 Activation Lines to delete');
            Assert.areEqual(1, testOutputVariables.activationToUpdate.No_of_Location_Lines__c, 'We expected No_of_Location_Lines__c on Activation to be 1');
            Assert.areEqual(testOpportunity.Id, testOutputVariables.activationLinesToUpdate[0].Opportunity_ID__c, 
                'Opportunity Id should match Opportunity Id on Activation Line');
            Assert.isTrue(testOutputVariables.quoteLinesToUpdate[0].Activation_Created__c, 'Expected Activation_Created__c to be true');
            Assert.areEqual(
                testOutputVariables.locationLinesToUpdate[0].Active_Blocking_Line_Present__c, 
                testOutputVariables.activationLinesToUpdate[0].Active_Blocking_Line_Present__c, 
                'Active_Blocking_Line_Present__c not matching.'
            );
            Assert.areEqual(
                testOutputVariables.locationLinesToUpdate[0].Employee_ID__c, 
                testOutputVariables.activationLinesToUpdate[0].Employee_Number__c, 
                'Employee_ID__c not matching.'
            );
            Assert.areEqual(
                testOutputVariables.locationLinesToUpdate[0].OTC_product__c, 
                testOutputVariables.activationLinesToUpdate[0].Home_Office_OTC_Product__c, 
                'Home_Office_OTC_Product__c not matching.'
            );
            Assert.areEqual(
                testOutputVariables.locationLinesToUpdate[0].VAS_product__c, 
                testOutputVariables.activationLinesToUpdate[0].Home_Office_VAS_Product__c, 
                'Home_Office_VAS_Product__c not matching.'
            );
            Assert.areEqual(
                testOutputVariables.locationLinesToUpdate[0].Address__c, 
                testOutputVariables.activationLinesToUpdate[0].Installation_address__c, 
                'Installation Address should match Address on the Location Line'
            );
            Assert.areEqual(
                testOutputVariables.locationLinesToUpdate[0].Id, 
                testOutputVariables.activationLinesToUpdate[0].Location_Line__c, 
                'Location_Line__c not matching.'
            );
            Assert.areEqual(
                testOutputVariables.locationLinesToUpdate[0].Municipality_Code__c, 
                testOutputVariables.activationLinesToUpdate[0].Municipality_Code__c, 
                'Municipality_Code__c not matching.'
            );
            Assert.areEqual(
                testOutputVariables.locationLinesToUpdate[0].Plug_Technician_Required__c, 
                testOutputVariables.activationLinesToUpdate[0].Plug_Technician_Required__c, 
                'Plug_Technician_Required__c not matching.'
            );
            Assert.areEqual(
                testOutputVariables.locationLinesToUpdate[0].plugPresentPositiveValidation__c, 
                testOutputVariables.activationLinesToUpdate[0].plugPresentPositiveValidation__c, 
                'plugPresentPositiveValidation__c not matching.'
            );
            Assert.areEqual(
                testOutputVariables.locationLinesToUpdate[0].Street_Code__c, 
                testOutputVariables.activationLinesToUpdate[0].Street_Code__c, 
                'Street_Code__c not matching.'
            );
            // since testLocationLine.OTC_product__c = 'CHXT02' then we expect the VAS_CHXT02__c flagged as true
            Assert.isTrue(testOutputVariables.activationLinesToUpdate[0].VAS_CHXT02__c, 'VAS_CHXT02__c should be true');
            Assert.areEqual(
                testQuoteLines[0].Id, 
                testOutputVariables.activationLinesToUpdate[0].Quote_line__c, 
                'Quote_line__c not matching.'
            );
            Assert.areEqual(
                testQuoteLines[0].SBQQ__Product__c, 
                testOutputVariables.activationLinesToUpdate[0].Manual_Product__c, 
                'Manual_Product__c not matching.'
            );
        }
    }

    /**
     * Bulk 2 opportunities for framework
     */
    @IsTest  
    private static void bulkOpportunity_Framework() {
        // ARRANGE
        List<String> cvrList = new List<String>{'12345678', '87654321'};
        TDF_HomeOfficeUtils.makeDataFramework(cvrList);

        // get the opportunities that were created in TestSetup
        List<Opportunity> testOpportunities = [SELECT Id, Agreement_Type__c FROM Opportunity];

        // prep your inputVariables object and add to inputVariablesList
        List<HomeOfficeFlowAction.InputVariables> inputVariablesList = new List<HomeOfficeFlowAction.InputVariables>();
        // for each opp, create a new inputVariables object and add to inputVariablesList
        for (Opportunity testOpportunity : testOpportunities) {
            HomeOfficeFlowAction.InputVariables inputVariables = new HomeOfficeFlowAction.InputVariables();
            inputVariables.inputOpportunity = testOpportunity;
            inputVariablesList.add(inputVariables);
        }

        // ACT
        Test.startTest();
        
        List<HomeOfficeFlowAction.OutputVariables> testOutputVariablesList = 
            HomeOfficeFlowAction.getHomeOfficeRelatedRecordsToActOn(inputVariablesList);

        Test.stopTest();
        
        // ASSERT
        Assert.areEqual(2, testOutputVariablesList.size(), 'We expected 1 OutputVarables');
        // loop the outputVariables and compare the results with your expected variables
        for (Integer i = 0; i < testOutputVariablesList.size(); i++) {
            HomeOfficeFlowAction.OutputVariables testOutputVariables = testOutputVariablesList[i];
            Assert.areEqual(1, testOutputVariables.activationLinesToUpdate.size(), 'We expected 1 Activation Line to update');
            // since Framework, we expect Location Line should be updated (the Quote Line field is set)
            Assert.areEqual(1, testOutputVariables.locationLinesToUpdate.size(), 'We expected 1 Location Line to update');
            Assert.areEqual(1, testOutputVariables.quoteLinesToUpdate.size(), 'We expected 1 Quote Line to update');
            Assert.areEqual(0, testOutputVariables.activationLinesToDelete.size(), 'We expected 0 Activation Lines to delete');
            Assert.areEqual(1, testOutputVariables.activationToUpdate.No_of_Location_Lines__c, 'We expected No_of_Location_Lines__c on Activation to be 1');
            Assert.areEqual(inputVariablesList[i].inputOpportunity.Id, testOutputVariables.activationLinesToUpdate[0].Opportunity_ID__c, 
                'Opportunity Id should match Opportunity Id on Activation Line');
        }
    }

    /**
     * Framework - more location lines than activation lines
     * 2 location lines
     * 1 activation line
     * Ensure that only one location line is being updated
     */
    @IsTest 
    private static void moreLocationLinesThanActivationLines_Framework() {
        // ARRANGE
        List<String> cvrList = new List<String>{'12345678'};
        TDF_HomeOfficeUtils.makeDataFramework(cvrList);
        
        // get the opportunity that was created in TestSetup
        Opportunity testOpportunity = [SELECT Id, Agreement_Type__c FROM Opportunity LIMIT 1];
        
        // create one more Location Line for opp, then insert (we change the zip code, city, number, street name)
        Location_Line__c testLocationLineExtra = TDF_LocationLineUtils.createLocationLineForOpportunity(
            testOpportunity, 
            HomeOfficeConstants.LOCATION_LINE_SUBSCRIPTION_PRODUCT_FIBHOF03,
            null
        );
        testLocationLineExtra.ZIP_Code__c = '7700';
        testLocationLineExtra.City__c = 'Thisted';
        testLocationLineExtra.Number__c = '30';
        testLocationLineExtra.Street_Name__c = 'Asylgade';
        insert testLocationLineExtra;

        List<Location_Line__c> testLocationLines = [
            SELECT Id 
            FROM Location_Line__c 
            WHERE Opportunity__c = :testOpportunity.Id
        ];
        Map<Id, Location_Line__c> locationLineMap = new Map<Id, Location_Line__c>(testLocationLines);

        // prep your inputVariables object and add to inputVariablesList
        HomeOfficeFlowAction.InputVariables inputVariables = new HomeOfficeFlowAction.InputVariables();
        inputVariables.inputOpportunity = testOpportunity;
        List<HomeOfficeFlowAction.InputVariables> inputVariablesList = new List<HomeOfficeFlowAction.InputVariables>{inputVariables};

        // prep portal user run as data
        Account testAccount = [SELECT Id, Name, CVR__c FROM Account LIMIT 1];
        User testPortalUser = getTestOnboardingPortalUser(testAccount);

        List<HomeOfficeFlowAction.OutputVariables> testOutputVariablesList;

        // ACT
        Test.startTest();
            
        System.runAs(testPortalUser) {
            testOutputVariablesList = HomeOfficeFlowAction.getHomeOfficeRelatedRecordsToActOn(inputVariablesList);            
        }

        Test.stopTest();
        
        // ASSERT
        Assert.areEqual(1, testOutputVariablesList.size(), 'We expected 1 OutputVarables');
        // loop the outputVariables and compare the results with your expected variables
        for (HomeOfficeFlowAction.OutputVariables testOutputVariables : testOutputVariablesList) {
            Assert.areEqual(1, testOutputVariables.activationLinesToUpdate.size(), 'We expected 1 Activation Line to update');

            // since Framework, we expect Location Line should be updated (the Quote Line field is set)
            Assert.areEqual(1, testOutputVariables.locationLinesToUpdate.size(), 'We expected 1 Location Line to update');
            Assert.areEqual(1, testOutputVariables.quoteLinesToUpdate.size(), 'We expected 1 Quote Line to update');
            Assert.areEqual(0, testOutputVariables.activationLinesToDelete.size(), 'We expected 0 Activation Lines to delete');
            Assert.areEqual(2, testOutputVariables.activationToUpdate.No_of_Location_Lines__c, 'We expected No_of_Location_Lines__c on Activation to be 2');
            Assert.areEqual(testOpportunity.Id, testOutputVariables.activationLinesToUpdate[0].Opportunity_ID__c, 
                'Opportunity Id should match Opportunity Id on Activation Line');
            Assert.areEqual(
                testOutputVariables.locationLinesToUpdate[0].Address__c, 
                testOutputVariables.activationLinesToUpdate[0].Installation_address__c, 
                'Installation Address should match Address on the Location Line'
            );
        }
    }

    /**
     * Framework - fewer location lines than activation lines
     * 1 Location Line, and 2 Activation Lines
     * Ensure only 1 Activation Line is being updated.
     */
    @IsTest 
    private static void fewerLocationLinesThanActivationLines_Framework() {
        // ARRANGE
        List<String> cvrList = new List<String>{'12345678'};
        TDF_HomeOfficeUtils.makeDataFramework(cvrList);
        
        // get the opportunity that was created in TestSetup
        Opportunity testOpportunity = [SELECT Id, Agreement_Type__c FROM Opportunity LIMIT 1];

        List<SBQQ__QuoteLine__c> testQuoteLines = [
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

        // create and insert extra Activation Lines, then re-query
        List<Activation_Line__c> activationLinesExtraList = TDF_ActivationLineUtils.createActivationLines(testQuoteLines);

        // prep your inputVariables object and add to inputVariablesList
        HomeOfficeFlowAction.InputVariables inputVariables = new HomeOfficeFlowAction.InputVariables();
        inputVariables.inputOpportunity = testOpportunity;
        List<HomeOfficeFlowAction.InputVariables> inputVariablesList = new List<HomeOfficeFlowAction.InputVariables>{inputVariables};

        // prep portal user run as data
        Account testAccount = [SELECT Id, Name, CVR__c FROM Account LIMIT 1];
        User testPortalUser = getTestOnboardingPortalUser(testAccount);

        List<HomeOfficeFlowAction.OutputVariables> testOutputVariablesList;

        // ACT
        Test.startTest();
            
        System.runAs(testPortalUser) {
            testOutputVariablesList = HomeOfficeFlowAction.getHomeOfficeRelatedRecordsToActOn(inputVariablesList);            
        }

        Test.stopTest();
        
        // ASSERT
        Assert.areEqual(1, testOutputVariablesList.size(), 'We expected 1 OutputVarables');
        // loop the outputVariables and compare the results with your expected variables
        for (HomeOfficeFlowAction.OutputVariables testOutputVariables : testOutputVariablesList) {
            Assert.areEqual(1, testOutputVariables.activationLinesToUpdate.size(), 'We expected 1 Activation Line to update');
            // since Framework, we expect Location Line should be updated (the Quote Line field is set)
            Assert.areEqual(1, testOutputVariables.locationLinesToUpdate.size(), 'We expected 1 Location Line to update');
            Assert.areEqual(1, testOutputVariables.quoteLinesToUpdate.size(), 'We expected 1 Quote Line to update');
            Assert.areEqual(0, testOutputVariables.activationLinesToDelete.size(), 'We expected 0 Activation Lines to delete');
            Assert.areEqual(1, testOutputVariables.activationToUpdate.No_of_Location_Lines__c, 'We expected No_of_Location_Lines__c on Activation to be 1');
        }
    }

    /**
     * locationLine.Subscription_product__c null then it should be deleted
     */
    @IsTest
    private static void subscriptionProductOnLocationLineIsNull_Framework() {   
        // ARRANGE
        List<String> cvrList = new List<String>{'12345678'};
        TDF_HomeOfficeUtils.makeDataFramework(cvrList);

        // get the opportunity that was created in TestSetup
        Opportunity testOpportunity = [SELECT Id, Agreement_Type__c FROM Opportunity LIMIT 1];

        // we need to remove Subscription_product__c from the location line
        List<Location_Line__c> testLocationLines = [
            SELECT Id, Subscription_product__c 
            FROM Location_Line__c 
            WHERE Opportunity__c = :testOpportunity.Id
        ];
        for (Location_Line__c testLocationLine : testLocationLines) {
            testLocationLine.Subscription_product__c = null;
        }
        update testLocationLines;

        // prep your inputVariables object and add to inputVariablesList
        HomeOfficeFlowAction.InputVariables inputVariables = new HomeOfficeFlowAction.InputVariables();
        inputVariables.inputOpportunity = testOpportunity;
        List<HomeOfficeFlowAction.InputVariables> inputVariablesList = new List<HomeOfficeFlowAction.InputVariables>{inputVariables};

        // prep portal user run as data
        Account testAccount = [SELECT Id, Name, CVR__c FROM Account LIMIT 1];
        User testPortalUser = getTestOnboardingPortalUser(testAccount);

        List<HomeOfficeFlowAction.OutputVariables> testOutputVariablesList;

        // ACT        
        Test.startTest();
            
        System.runAs(testPortalUser) {
            testOutputVariablesList = HomeOfficeFlowAction.getHomeOfficeRelatedRecordsToActOn(inputVariablesList);            
        }

        Test.stopTest();

        // ASSERT
        Assert.areEqual(1, testOutputVariablesList.size(), 'We expected 1 OutputVarables');
        // loop the outputVariables and compare the results with your expected variables
        for (HomeOfficeFlowAction.OutputVariables testOutputVariables : testOutputVariablesList) {
            Assert.areEqual(0, testOutputVariables.activationLinesToUpdate.size(), 'We expected 0 Activation Line to update');
            // since subscription product is missing on location line we don't update location line
            Assert.areEqual(0, testOutputVariables.locationLinesToUpdate.size(), 'We expected 0 Location Line to update');
            Assert.areEqual(0, testOutputVariables.quoteLinesToUpdate.size(), 'We expected 0 Quote Line to update');
            Assert.areEqual(1, testOutputVariables.activationLinesToDelete.size(), 'We expected 1 Activation Lines to delete');
            Assert.isNull(testOutputVariables.activationToUpdate.No_of_Location_Lines__c, 'We expected No_of_Location_Lines__c on Activation to be null');
        }
    }

    /**
     * Manual Product on the Activation Line is null, so we expect the Product Id from the Product record where its 
     * teliaProductId (ProductAPI_Telia_Product_Id__c) matches the Subscription_product__c on the Location Line.
     * Quote Line on the Activation Line is also null, so we expect the Quote Line Id is found from the Quote Line 
     * that matches based on Activation Line's Activation Id and Product Id from the Product that matches on the 
     * teliaProductId (ProductAPI_Telia_Product_Id__c) with the Subscription_product__c on the Location Line.
     * 
     * Ensure the right Quote Line is assigned to the Location Line.
     * Ensure the right Quote Line is the one being updated.
     */
    @IsTest
    private static void manualProductOnActivationLineIsNull_Framework() {   
        // ARRANGE
        List<String> cvrList = new List<String>{'12345678'};
        TDF_HomeOfficeUtils.makeDataFramework(cvrList);

        // get the opportunity that was created in TestSetup
        Opportunity testOpportunity = [SELECT Id, Agreement_Type__c FROM Opportunity LIMIT 1];

        // we need to remove Quote_line__c and manual product from activation line
        List<Activation_Line__c> activationLinesList = [SELECT Id, Manual_Product__c, Quote_line__c, Activation__c FROM Activation_Line__c];
        activationLinesList[0].Quote_line__c = null;
        activationLinesList[0].Manual_Product__c = null;
        update activationLinesList;
        
        // we change the Subscription_product__c on the location line to something different than the makeData (makeData uses LOCATION_LINE_SUBSCRIPTION_PRODUCT_FIBHOF03)
        List<Location_Line__c> testLocationLines = [
            SELECT Id, Subscription_product__c, Quote_Line__c 
            FROM Location_Line__c 
            WHERE Opportunity__c = :testOpportunity.Id
        ];
        testLocationLines[0].Subscription_product__c = HomeOfficeConstants.LOCATION_LINE_SUBSCRIPTION_PRODUCT_FIBHOF15;
        update testLocationLines;

        // we need an extra Home Office Product, insert and return
        Integer numberOfDifferentProducts = 1;
        List<Product2> listOfProductsToUse = TDF_ProductUtils.createHomeOfficeProducts(numberOfDifferentProducts);
        // we need to set the ProductAPI_Telia_Product_Id__c to HomeOfficeConstants.LOCATION_LINE_SUBSCRIPTION_PRODUCT_FIBHOF15
        listOfProductsToUse[0].ProductAPI_Telia_Product_Id__c = HomeOfficeConstants.LOCATION_LINE_SUBSCRIPTION_PRODUCT_FIBHOF15;
        update listOfProductsToUse;

        List<PricebookEntry> listOfPricebookEntries = TDF_ProductUtils.createStandardPricebookEntriesForProducts(
            listOfProductsToUse
        );
        Map<Id, PricebookEntry> mapOfProductToPricebookEntries = TDF_ProductUtils.createProductIdToPricebookEntryMap(
            listOfPricebookEntries, 
            listOfProductsToUse
        );
        
        // we need the product where ProductAPI_Telia_Product_Id__c matches the Subscription_product__c 
        // this is the product that should be found (HomeOfficeConstants.LOCATION_LINE_SUBSCRIPTION_PRODUCT_FIBHOF15)
        List<Product2> products = [
            SELECT Id, ProductAPI_Telia_Product_Id__c 
            FROM Product2 
            WHERE ProductAPI_Telia_Product_Id__c = :testLocationLines[0].Subscription_product__c 
            ORDER BY IsActive DESC, ProductAPI_Telia_Product_Id__c
        ];

        // query quote lines that matches activation
        List<SBQQ__QuoteLine__c> testQuoteLines = [
            SELECT Id, SBQQ__Product__c
            FROM SBQQ__QuoteLine__c
            WHERE Activation__c = :activationLinesList[0].Activation__c
        ];
        // update the quote line to be asssociated with the extra product
        // this will be the quote line that are assigned to the location line
        // this will be the quote line that is updated
        testQuoteLines[0].SBQQ__Product__c = products[0].Id;
        update testQuoteLines;

        // prep your inputVariables object and add to inputVariablesList
        HomeOfficeFlowAction.InputVariables inputVariables = new HomeOfficeFlowAction.InputVariables();
        inputVariables.inputOpportunity = testOpportunity;
        List<HomeOfficeFlowAction.InputVariables> inputVariablesList = new List<HomeOfficeFlowAction.InputVariables>{inputVariables};

        // prep portal user run as data
        Account testAccount = [SELECT Id, Name, CVR__c FROM Account LIMIT 1];
        User testPortalUser = getTestOnboardingPortalUser(testAccount);

        List<HomeOfficeFlowAction.OutputVariables> testOutputVariablesList;

        // ACT        
        Test.startTest();
            
        System.runAs(testPortalUser) {
            testOutputVariablesList = HomeOfficeFlowAction.getHomeOfficeRelatedRecordsToActOn(inputVariablesList);            
        }

        Test.stopTest();

        // ASSERT
        Assert.areEqual(1, testOutputVariablesList.size(), 'We expected 1 OutputVarables');
        // loop the outputVariables and compare the results with your expected variables
        for (HomeOfficeFlowAction.OutputVariables testOutputVariables : testOutputVariablesList) {            
            Assert.areEqual(1, testOutputVariables.activationLinesToUpdate.size(), 'We expected 1 Activation Line to update');
            // since Framework, we expect Location Line should be updated (the Quote Line field is set)
            Assert.areEqual(1, testOutputVariables.locationLinesToUpdate.size(), 'We expected 1 Location Line to update');
            Assert.areEqual(1, testOutputVariables.quoteLinesToUpdate.size(), 'We expected 1 Quote Line to update');
            Assert.areEqual(0, testOutputVariables.activationLinesToDelete.size(), 'We expected 0 Activation Lines to delete');
            Assert.areEqual(1, testOutputVariables.activationToUpdate.No_of_Location_Lines__c, 'We expected No_of_Location_Lines__c on Activation to be 1');
            Assert.areEqual(testOpportunity.Id, testOutputVariables.activationLinesToUpdate[0].Opportunity_ID__c, 
                'Opportunity Id should match Opportunity Id on Activation Line');
            // we need to check that quote line on the location line matches the test quote line 
            Assert.areEqual(testQuoteLines[0].Id, testOutputVariables.locationLinesToUpdate[0].Quote_Line__c, 'Quote Line on the Location Line is incorrect');
            // check the quote line to update matches the test quote line
            Assert.areEqual(testQuoteLines[0].Id, testOutputVariables.quoteLinesToUpdate[0].Id, 'Quote Line to update is incorrect');
        }
    }

    private static User getTestOnboardingPortalUser(Account testAccount) {        
        Contact testContact = new Contact(
            FirstName = 'Test', 
            LastName = 'Tester', 
            Email = 'test@companytesting.com', 
            AccountId = testAccount.Id);
        insert testContact;

        String onboardingProfileName = 'Telia Onboarding Portal User';
        String onboardingUserAlias = 'tcode';
        Id onboardingProfileId = ProfileSelector.getProfileByProfileName(onboardingProfileName).Id;
        User testUser = TDF_UserUtils.createUserForContact(testContact.Id, onboardingUserAlias, onboardingProfileId);

        return testUser;
    }

}