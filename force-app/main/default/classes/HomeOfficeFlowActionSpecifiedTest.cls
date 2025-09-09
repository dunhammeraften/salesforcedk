/** 
 * Testing HomeOfficeFlowAction class
 * 
 * @author  Kirstine Nielsen
 * @since   07-05-2025
 * @see     https://jira.atlassian.teliacompany.net/browse/DKT-44508
 */
@IsTest 
private with sharing class HomeOfficeFlowActionSpecifiedTest {    
    
    @IsTest  
    private static void singleOpportunity_Specified() {
        // ARRANGE     
        List<String> cvrList = new List<String>{'87654321'};   
        TDF_HomeOfficeUtils.makeDataSpecified(cvrList);  
        
        // get the opportunity and Location Line that was created in TestSetup
        Opportunity testOpportunity = [SELECT Id, Agreement_Type__c FROM Opportunity LIMIT 1];        
        List<Location_Line__c> testLocationLines = [SELECT Id, Address__c FROM Location_Line__c WHERE Opportunity__c = :testOpportunity.Id];

        List<Activation__c> testActivations = [SELECT Id FROM Activation__c];
        
        List<SBQQ__Quote__c> testQuotes = [SELECT Id FROM SBQQ__Quote__c];
        List<Product2> listOfProductsToUse = [SELECT Id FROM Product2];
        List<PricebookEntry> listOfPricebookEntries = [SELECT Id, Product2Id FROM PricebookEntry];
        Map<Id, PricebookEntry> mapOfProductToPricebookEntries = TDF_ProductUtils.createProductIdToPricebookEntryMap(
            listOfPricebookEntries, 
            listOfProductsToUse
        );

        // create extra quote line under same quote (to test multiple quote lines under same quote works)
        List<SBQQ__QuoteLine__c> testQuoteLines1 = TDF_QuoteLineUtils.createQuoteLinesForQuote(
            testQuotes, 
            false, 
            listOfProductsToUse, 
            mapOfProductToPricebookEntries
        );     
        testQuoteLines1[0].Activation__c = testActivations[0].Id;
        update testQuoteLines1;

        // prep your inputVariables object and add to inputVariablesList
        HomeOfficeFlowAction.InputVariables inputVariables = new HomeOfficeFlowAction.InputVariables();
        inputVariables.inputOpportunity = testOpportunity;
        List<HomeOfficeFlowAction.InputVariables> inputVariablesList = new List<HomeOfficeFlowAction.InputVariables>{inputVariables};

        // ACT
        Test.startTest();
        
        List<HomeOfficeFlowAction.OutputVariables> testOutputVariablesList = 
            HomeOfficeFlowAction.getHomeOfficeRelatedRecordsToActOn(inputVariablesList);

        Test.stopTest();
        
        // ASSERT
        Assert.areEqual(1, testOutputVariablesList.size(), 'We expected 1 OutputVarables');
        // loop the outputVariables and compare the results with your expected variables
        for (HomeOfficeFlowAction.OutputVariables testOutputVariables : testOutputVariablesList) {
            Assert.areEqual(1, testOutputVariables.activationLinesToUpdate.size(), 'We expected 1 Activation Line to update');
            // we don't expect location lines to be updated since they already have their quote line lookup field set
            Assert.areEqual(0, testOutputVariables.locationLinesToUpdate.size(), 'We expected 0 Location Line to update');
            Assert.areEqual(0, testOutputVariables.quoteLinesToUpdate.size(), 'We expected 0 Quote Line to update');
            Assert.areEqual(0, testOutputVariables.activationLinesToDelete.size(), 'We expected 0 Activation Lines to delete');
            Assert.areEqual(1, testOutputVariables.activationToUpdate.No_of_Location_Lines__c, 'We expected No_of_Location_Lines__c on Activation to be 1');
            Assert.areEqual(testOpportunity.Id, testOutputVariables.activationLinesToUpdate[0].Opportunity_ID__c, 
                'Opportunity Id should match Opportunity Id on Activation Line');
            Assert.areEqual(
                testLocationLines[0].Address__c, 
                testOutputVariables.activationLinesToUpdate[0].Installation_address__c, 
                'Installation Address should match Address on the Location Line'
            );
        }
    }

    /**
     * Bulk 2 opportunities for specified
     */
    @IsTest
    private static void bulkOpportunity_Specified() {
        // ARRANGE     
        List<String> cvrList = new List<String>{'12345678', '87654321'};   
        TDF_HomeOfficeUtils.makeDataSpecified(cvrList);   
        
        // get the opportunities that were created in TestSetup
        List<Opportunity> testOpportunities = [SELECT Id, Agreement_Type__c FROM Opportunity];      
        List<Location_Line__c> testLocationLines = [SELECT Id, Address__c FROM Location_Line__c WHERE Opportunity__c IN :testOpportunities];

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
        Assert.areEqual(2, testOutputVariablesList.size(), 'We expected 2 OutputVarables');
        // loop the outputVariables and compare the results with your expected variables
        for (Integer i = 0; i < testOutputVariablesList.size(); i++) {
            HomeOfficeFlowAction.OutputVariables testOutputVariables = testOutputVariablesList[i];
            Assert.areEqual(1, testOutputVariables.activationLinesToUpdate.size(), 'We expected 1 Activation Line to update');

            // we don't expect location lines to be updated since they already have their quote line lookup field set
            Assert.areEqual(0, testOutputVariables.locationLinesToUpdate.size(), 'We expected 0 Location Line to update');
            Assert.areEqual(0, testOutputVariables.quoteLinesToUpdate.size(), 'We expected 0 Quote Line to update');
            Assert.areEqual(0, testOutputVariables.activationLinesToDelete.size(), 'We expected 0 Activation Lines to delete');
            Assert.areEqual(1, testOutputVariables.activationToUpdate.No_of_Location_Lines__c, 'We expected No_of_Location_Lines__c on Activation to be 1');
            Assert.areEqual(inputVariablesList[i].inputOpportunity.Id, testOutputVariables.activationLinesToUpdate[0].Opportunity_ID__c, 
                'Opportunity Id should match Opportunity Id on Activation Line');
        }
    }
    
    /**
     * test quote line on activation line is null
     * We have 3 location lines
     * We have 3 activation lines, but where one has quote line set to null
     * Ensure there are only 2 activation lines to update, since the third has quote line as null.
     */
    @IsTest  
    private static void quoteLineOnActivationLineIsNull_Specified() {
        // ARRANGE     
        List<String> cvrList = new List<String>{'87654321'};   
        TDF_HomeOfficeUtils.makeDataSpecified(cvrList);  
        
        // get the opportunity and Location Line that was created in TestSetup
        Opportunity testOpportunity = [SELECT Id, Agreement_Type__c FROM Opportunity LIMIT 1];

        // we have one quote line
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
                SBQQ__Quote__r.SBQQ__Opportunity2__c,
                SBQQ__Quote__r.SBQQ__BillingCity__c 
            FROM SBQQ__QuoteLine__c
        ];

        Integer extraCount = 2;
        // create extra location line, then insert    
        List<Location_Line__c> testExtraLocationLines = new List<Location_Line__c>();
        for (Integer i = 0; i < extraCount; i++) {
            Location_Line__c testExtraLocationLine = TDF_LocationLineUtils.createLocationLineForOpportunity(
                testOpportunity, 
                HomeOfficeConstants.LOCATION_LINE_SUBSCRIPTION_PRODUCT_FIBHOF03,
                testQuoteLines[0]
            );
            testExtraLocationLine.OTC_product__c = 'CHXT02';
            testExtraLocationLines.add(testExtraLocationLine);
        }
        insert testExtraLocationLines;

        // create extra activation lines for same quote line, and set quote line to null on one of them
        List<Activation_Line__c> activationLinesExtraList1 = TDF_ActivationLineUtils.createActivationLines(testQuoteLines);
        activationLinesExtraList1[0].Quote_Line__c = null;
        update activationLinesExtraList1;
        List<Activation_Line__c> activationLinesExtraList2 = TDF_ActivationLineUtils.createActivationLines(testQuoteLines);

        // prep your inputVariables object and add to inputVariablesList
        HomeOfficeFlowAction.InputVariables inputVariables = new HomeOfficeFlowAction.InputVariables();
        inputVariables.inputOpportunity = testOpportunity;
        List<HomeOfficeFlowAction.InputVariables> inputVariablesList = new List<HomeOfficeFlowAction.InputVariables>{inputVariables};

        // ACT
        Test.startTest();
        
        List<HomeOfficeFlowAction.OutputVariables> testOutputVariablesList = 
            HomeOfficeFlowAction.getHomeOfficeRelatedRecordsToActOn(inputVariablesList);

        Test.stopTest();
        
        // ASSERT
        Assert.areEqual(1, testOutputVariablesList.size(), 'We expected 1 OutputVarables');
        // loop the outputVariables and compare the results with your expected variables
        for (HomeOfficeFlowAction.OutputVariables testOutputVariables : testOutputVariablesList) {
            Assert.areEqual(2, testOutputVariables.activationLinesToUpdate.size(), 'We expected 2 Activation Line to update');
            // we don't expect location lines to be updated since they already have their quote line lookup field set
            Assert.areEqual(0, testOutputVariables.locationLinesToUpdate.size(), 'We expected 0 Location Line to update');
            Assert.areEqual(0, testOutputVariables.quoteLinesToUpdate.size(), 'We expected 0 Quote Line to update');
            Assert.areEqual(0, testOutputVariables.activationLinesToDelete.size(), 'We expected 0 Activation Lines to delete');
            Assert.areEqual(3, testOutputVariables.activationToUpdate.No_of_Location_Lines__c, 'We expected No_of_Location_Lines__c on Activation to be 3');
            for (Activation_Line__c activationLine : testOutputVariables.activationLinesToUpdate) {
                Assert.areEqual(
                    testOpportunity.Id, 
                    activationLine.Opportunity_ID__c, 
                    'Opportunity Id should match Opportunity Id on Activation Line'
                );
            }
        }
    }

    /**
     * specified Quote Line on the Location Line is null.
     * Ensure that activationLinesToUpdate is empty because there is no match because Quote Line is null.
     */
    @IsTest
    private static void quoteLineOnLocationLineIsNull_Specified() {        
        // ARRANGE     
        List<String> cvrList = new List<String>{'87654321'};   
        TDF_HomeOfficeUtils.makeDataSpecified(cvrList);
        
        // get the opportunity and Location Line that was created in TestSetup
        Opportunity testOpportunity = [SELECT Id, Agreement_Type__c FROM Opportunity LIMIT 1];      
        List<Activation_Line__c> activationLinesList = [SELECT Id, Manual_Product__c, Quote_line__c, Activation__c FROM Activation_Line__c];  
        List<Location_Line__c> testLocationLines = [SELECT Id, Address__c, Quote_Line__c FROM Location_Line__c WHERE Opportunity__c = :testOpportunity.Id];

        // update the Quote Line field on the Location Line to null
        testLocationLines[0].Quote_Line__c = null;
        update testLocationLines;

        // query quote lines (there is one) that matches activation, this should be the one that eventually gets assigned ot location line
        List<SBQQ__QuoteLine__c> testQuoteLines = [
            SELECT Id, SBQQ__Product__c
            FROM SBQQ__QuoteLine__c
            WHERE Activation__c = :activationLinesList[0].Activation__c
        ];

        // prep your inputVariables object and add to inputVariablesList
        HomeOfficeFlowAction.InputVariables inputVariables = new HomeOfficeFlowAction.InputVariables();
        inputVariables.inputOpportunity = testOpportunity;
        List<HomeOfficeFlowAction.InputVariables> inputVariablesList = new List<HomeOfficeFlowAction.InputVariables>{inputVariables};

        // ACT
        Test.startTest();
        
        List<HomeOfficeFlowAction.OutputVariables> testOutputVariablesList = 
            HomeOfficeFlowAction.getHomeOfficeRelatedRecordsToActOn(inputVariablesList);

        Test.stopTest();
        
        // ASSERT
        Assert.areEqual(1, testOutputVariablesList.size(), 'We expected 1 OutputVarables');
        // loop the outputVariables and compare the results with your expected variables
        for (HomeOfficeFlowAction.OutputVariables testOutputVariables : testOutputVariablesList) {
            Assert.areEqual(0, testOutputVariables.activationLinesToUpdate.size(), 'We expected 0 Activation Line to update');
            // we don't expect location lines to be updated since they already have their quote line lookup field set
            Assert.areEqual(0, testOutputVariables.locationLinesToUpdate.size(), 'We expected 0 Location Line to update');
            Assert.areEqual(0, testOutputVariables.quoteLinesToUpdate.size(), 'We expected 0 Quote Line to update');
            Assert.areEqual(0, testOutputVariables.activationLinesToDelete.size(), 'We expected 0 Activation Lines to delete');
            Assert.isNull(testOutputVariables.activationToUpdate.No_of_Location_Lines__c, 'We expected No_of_Location_Lines__c on Activation to be null');
        }
    }

    /**
     * Multiple (2) Location and Activation Lines
     */
    @IsTest 
    private static void multipleLocationAndActivationLine_Specified() {
        // ARRANGE
        List<String> cvrList = new List<String>{'12345678'};
        TDF_HomeOfficeUtils.makeDataSpecified(cvrList);

        Opportunity testOpportunity = [SELECT Id, Agreement_Type__c FROM Opportunity LIMIT 1];    

        // we want to create more activation lines and location lines under the quote line (in this scenario there is one Quote Line)
        // requery to have the fields
        SBQQ__QuoteLine__c testQuoteLine = [
            SELECT 
                Id, 
                Activation__c, 
                Activation_Created__c,
                Activation_Record_Type__c, 
                SBQQ__Product__c,
                SBQQ__Product__r.Name,
                SBQQ__Quote__c,
                SBQQ__Quote__r.Name,
                SBQQ__Quote__r.SBQQ__Opportunity2__c,
                SBQQ__Quote__r.SBQQ__BillingCity__c 
            FROM SBQQ__QuoteLine__c
            LIMIT 1
        ];

        // create extra Location Line for opp, then insert
        Location_Line__c testLocationLineExtra = TDF_LocationLineUtils.createLocationLineForOpportunity(
            testOpportunity, 
            HomeOfficeConstants.LOCATION_LINE_SUBSCRIPTION_PRODUCT_FIBHOF03,
            testQuoteLine
        );
        testLocationLineExtra.OTC_product__c = 'CHXT02';
        // adjust address
        testLocationLineExtra.ZIP_Code__c = '7700';
        testLocationLineExtra.City__c = 'Thisted';
        testLocationLineExtra.Number__c = '30';
        testLocationLineExtra.Street_Name__c = 'Asylgade';
        insert testLocationLineExtra;

        List<Location_Line__c> testLocationLines = [SELECT Id, Address__c, OTC_product__c FROM Location_Line__c];
        // make map of the location lines 
        Map<Id, Location_Line__c> testLocationLineMap = new Map<Id, Location_Line__c>(testLocationLines);

        // create and insert extra Activation Line for opp,
        List<Activation_Line__c> activationLinesExtraList = TDF_ActivationLineUtils.createActivationLines(new List<SBQQ__QuoteLine__c>{testQuoteLine});
        
        // prep your inputVariables object and add to inputVariablesList
        HomeOfficeFlowAction.InputVariables inputVariables = new HomeOfficeFlowAction.InputVariables();
        inputVariables.inputOpportunity = testOpportunity;
        List<HomeOfficeFlowAction.InputVariables> inputVariablesList = new List<HomeOfficeFlowAction.InputVariables>{inputVariables};

        // ACT
        Test.startTest();
        
        List<HomeOfficeFlowAction.OutputVariables> testOutputVariablesList = 
            HomeOfficeFlowAction.getHomeOfficeRelatedRecordsToActOn(inputVariablesList);

        Test.stopTest();
        
        // ASSERT
        Set<Id> usedLocationLineIdSet = new Set<Id>();

        Assert.areEqual(1, testOutputVariablesList.size(), 'We expected 1 OutputVarables');
        // loop the outputVariables and compare the results with your expected variables
        for (HomeOfficeFlowAction.OutputVariables testOutputVariables : testOutputVariablesList) {
            Assert.areEqual(2, testOutputVariables.activationLinesToUpdate.size(), 'We expected 2 Activation Line to update');
            // we don't expect location lines to be updated since they already have their quote line lookup field set
            Assert.areEqual(0, testOutputVariables.locationLinesToUpdate.size(), 'We expected 0 Location Line to update');
            Assert.areEqual(0, testOutputVariables.quoteLinesToUpdate.size(), 'We expected 0 Quote Line to update');
            Assert.areEqual(0, testOutputVariables.activationLinesToDelete.size(), 'We expected 0 Activation Lines to delete');
            Assert.areEqual(2, testOutputVariables.activationToUpdate.No_of_Location_Lines__c, 'We expected No_of_Location_Lines__c on Activation to be 2');
            // check the id for each activation line
            for (Activation_Line__c activationLine : testOutputVariables.activationLinesToUpdate) {
                Assert.areEqual(
                    testOpportunity.Id, 
                    activationLine.Opportunity_ID__c, 
                    'Opportunity Id should match Opportunity Id on Activation Line'
                );
                // 
                if (!usedLocationLineIdSet.contains(activationLine.Location_Line__c)) {
                    // not used yet
                    Location_Line__c locationLine = testLocationLineMap.get(activationLine.Location_Line__c);
                    Assert.areEqual(
                        locationLine.Address__c, 
                        activationLine.Installation_address__c, 
                        'Installation Address should match Address on the Location Line'
                    );
                    // add to set to keep track of used location lines
                    usedLocationLineIdSet.add(activationLine.Location_Line__c);
                }
            }
            // sanity check that you have used two location lines
            Assert.areEqual(2, usedLocationLineIdSet.size(), 'Expected 2 location lines used');
        }
    }

}