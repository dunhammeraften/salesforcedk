/** 
 * Test Data Factory class used for generating test data for Home Office related scenario.
 * 
 * @author  Kirstine Nielsen
 * @since   07-05-2025
 * @see     https://jira.atlassian.teliacompany.net/browse/DKT-44508
 */
public with sharing class TDF_HomeOfficeUtils {
    
    /**
     * will create account(s). Will create one per account of:
     * - Opportunity
     * - Quote
     * - Quote Line
     * - Activation
     * - Activation Line
     * - Location Line
     * - Case
     * 
     * @param list of cvr
     */
    public static void makeDataFramework(List<String> cvrList) {

        List<Account> testAccounts = new List<Account>();
        for (String cvr : cvrList) {
            // create the Account
            Account testAccount = TDF_AccountUtils.createAccountWithCVR(cvr);
            testAccount.Status__c = 'Active';
            testAccounts.add(testAccount);
        }
        insert testAccounts;

        // we create 1 Opportunity per Account
        List<Opportunity> testOpportunities = TDF_OpportunityUtils.createHomeOfficeOpportunityForAccounts(
            testAccounts, 
            HomeOfficeConstants.AGREEMENT_TYPE_FRAMEWORK
        );
        Map<Id, Opportunity> opportunityMap = new Map<Id, Opportunity>(testOpportunities);

        Map<Id, List<Opportunity>> accountIdToOpportunitiesMap = new Map<Id, List<Opportunity>>();
        for (Opportunity testOpportunity : testOpportunities) {
            if (!accountIdToOpportunitiesMap.containsKey(testOpportunity.AccountId)) {
                List<Opportunity> opportunitiesPerAccount = new List<Opportunity>();
                opportunitiesPerAccount.add(testOpportunity);
                accountIdToOpportunitiesMap.put(testOpportunity.AccountId, opportunitiesPerAccount);
            } else {
                // key exists
                accountIdToOpportunitiesMap.get(testOpportunity.AccountId).add(testOpportunity);
            }
        }

        // create 1 Quote per opp
        List<SBQQ__Quote__c> testQuotes = new List<SBQQ__Quote__c>();        
        for (Account testAccount : testAccounts) {
            for (Opportunity opp : accountIdToOpportunitiesMap.get(testAccount.Id)) {
                SBQQ__Quote__c testQuote = TDF_QuoteUtils.createSingleQuote(testAccount.Id, opp.Id);
                testQuotes.add(testQuote);
            }
        }
        insert testQuotes;
        
        Map<Id, SBQQ__Quote__c> opportunityIdToQuoteMap = new Map<Id, SBQQ__Quote__c>();
        for (SBQQ__Quote__c testQuote : testQuotes) {
            if (!opportunityIdToQuoteMap.containsKey(testQuote.SBQQ__Opportunity2__c)) {
                opportunityIdToQuoteMap.put(testQuote.SBQQ__Opportunity2__c, testQuote);
            }
        }

        // set the primary quote field on the opp
        testOpportunities = [
            SELECT Id, AccountId, SBQQ__PrimaryQuote__c, SBQQ__PrimaryQuote__r.SBQQ__StartDate__c, Case__c 
            FROM Opportunity
        ];
        for (Opportunity testOpportunity : testOpportunities) {
            if (opportunityIdToQuoteMap.containsKey(testOpportunity.Id)) {
                testOpportunity.SBQQ__PrimaryQuote__c = opportunityIdToQuoteMap.get(testOpportunity.Id).Id;
            }
        }
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
            testQuotes, 
            false, 
            listOfProductsToUse, 
            mapOfProductToPricebookEntries
        );
        // need to requery to have the fields
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
        activationHeadersList = [
            SELECT Id, Name, Case_Account_ID__c, Case__r.Opportunity__r.Id, Recordtype.Developername 
            FROM Activation__c
        ];

        // create Location Line for each opp, then insert
        List<Location_Line__c> testLocationLines = new List<Location_Line__c>();
        for (Opportunity testOpportunity : testOpportunities) {
            Location_Line__c testLocationLine = TDF_LocationLineUtils.createLocationLineForOpportunity(
                testOpportunity, 
                HomeOfficeConstants.LOCATION_LINE_SUBSCRIPTION_PRODUCT_FIBHOF03,
                null
            );
            testLocationLine.OTC_product__c = HomeOfficeConstants.LOCATION_LINE_OTC_PRODUCT_CHXT02;
            testLocationLine.VAS_product__c = HomeOfficeConstants.LOCATION_LINE_VAS_PRODUCT_FASTIP;
            testLocationLines.add(testLocationLine);
        }
        insert testLocationLines;

        Map<Id, List<Location_Line__c>> opportunityIdToLocationLinesMap = new Map<Id, List<Location_Line__c>>();
        testLocationLines = [SELECT Id, Name, Quote_Line__c, Opportunity__r.Id, OTC_product__c FROM Location_Line__c];
        for (Location_Line__c locationLine : testLocationLines) {
            if (!opportunityIdToLocationLinesMap.containsKey(locationLine.Opportunity__r.Id)) {

                List<Location_Line__c> locationLines = new List<Location_Line__c>();
                locationLines.add(locationLine);
                opportunityIdToLocationLinesMap.put(locationLine.Opportunity__r.Id, locationLines);
            } else {
                opportunityIdToLocationLinesMap.get(locationLine.Opportunity__r.Id).add(locationLine);
            }
        }

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

        // opportunityIdToLocationLinesMap
        Set<Id> locationLineIdsUsed = new Set<Id>();

        // we need to populate activationLine.Location_Line__c, then update
        for (Activation_Line__c activationLine : activationLinesList) {
            for (Location_Line__c locationLine : opportunityIdToLocationLinesMap.get(activationLine.Opportunity_ID__c)) {
                if (!locationLineIdsUsed.contains(locationLine.Id)) {
                    activationLine.Location_Line__c = locationLine.Id;
                    locationLineIdsUsed.add(locationLine.Id);
                }
            }            
        }
        update activationLinesList;
    }
    
    /**
     * will create account(s). Will create one per account of:
     * - Opportunity
     * - Quote
     * - Quote Line
     * - Activation
     * - Activation Line
     * - Location Line
     * - Case
     * 
     * @param list of cvr
     */
    public static void makeDataSpecified(List<String> cvrList) {
        
        // create the Accounts
        List<Account> testAccounts = new List<Account>();
        for (String cvr : cvrList) {
            // create the Account
            Account testAccount = TDF_AccountUtils.createAccountWithCVR(cvr);
            testAccount.Status__c = 'Active';
            testAccounts.add(testAccount);
        }
        insert testAccounts;

        // we create 1 Opportunity per Account
        List<Opportunity> testOpportunities = TDF_OpportunityUtils.createHomeOfficeOpportunityForAccounts(
            testAccounts, 
            HomeOfficeConstants.AGREEMENT_TYPE_SPECIFIED
        );
        Map<Id, Opportunity> opportunityMap = new Map<Id, Opportunity>(testOpportunities);

        Map<Id, List<Opportunity>> accountIdToOpportunitiesMap = new Map<Id, List<Opportunity>>();
        for (Opportunity testOpportunity : testOpportunities) {
            if (!accountIdToOpportunitiesMap.containsKey(testOpportunity.AccountId)) {
                List<Opportunity> opportunitiesPerAccount = new List<Opportunity>();
                opportunitiesPerAccount.add(testOpportunity);
                accountIdToOpportunitiesMap.put(testOpportunity.AccountId, opportunitiesPerAccount);
            } else {
                // key exists
                accountIdToOpportunitiesMap.get(testOpportunity.AccountId).add(testOpportunity);
            }
        }

        // create 1 Quote per opp
        List<SBQQ__Quote__c> testQuotes = new List<SBQQ__Quote__c>();        
        for (Account testAccount : testAccounts) {
            for (Opportunity opp : accountIdToOpportunitiesMap.get(testAccount.Id)) {
                SBQQ__Quote__c testQuote = TDF_QuoteUtils.createSingleQuote(testAccount.Id, opp.Id);
                testQuotes.add(testQuote);
            }
        }
        insert testQuotes;
        
        Map<Id, SBQQ__Quote__c> opportunityIdToQuoteMap = new Map<Id, SBQQ__Quote__c>();
        for (SBQQ__Quote__c testQuote : testQuotes) {
            if (!opportunityIdToQuoteMap.containsKey(testQuote.SBQQ__Opportunity2__c)) {
                opportunityIdToQuoteMap.put(testQuote.SBQQ__Opportunity2__c, testQuote);
            }
        }

        // re-query opportunities because we need to set the SBQQ__PrimaryQuote__c
        testOpportunities = [
            SELECT Id, AccountId, SBQQ__PrimaryQuote__c, SBQQ__PrimaryQuote__r.SBQQ__StartDate__c, Case__c 
            FROM Opportunity
        ];
        // loop through opportunities and set the primary quote
        for(Opportunity opp : testOpportunities) {
            opp.SBQQ__PrimaryQuote__c = opportunityIdToQuoteMap.get(opp.Id).Id;
        }
        update testOpportunities;

        // we need Home Office Products, insert and return
        Integer numberOfDifferentProducts = 1;
        List<Product2> listOfProductsToUse = TDF_ProductUtils.createHomeOfficeProducts(numberOfDifferentProducts);        
        // we need to set the ProductAPI_Telia_Product_Id__c to HomeOfficeConstants.LOCATION_LINE_SUBSCRIPTION_PRODUCT_FIBHOF03
        listOfProductsToUse[0].ProductAPI_Telia_Product_Id__c = HomeOfficeConstants.LOCATION_LINE_SUBSCRIPTION_PRODUCT_FIBHOF03;
        update listOfProductsToUse;

        List<PricebookEntry> listOfPricebookEntries = TDF_ProductUtils.createStandardPricebookEntriesForProducts(listOfProductsToUse);
        Map<Id, PricebookEntry> mapOfProductToPricebookEntries = TDF_ProductUtils.createProductIdToPricebookEntryMap(
            listOfPricebookEntries, 
            listOfProductsToUse
        );

        // create Quote Lines for the Quotes (we will only get one quote line per quote, because numberOfDifferentProducts = 1)
        List<SBQQ__QuoteLine__c> testQuoteLines = TDF_QuoteLineUtils.createQuoteLinesForQuote(
            testQuotes, 
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
                SBQQ__Quote__r.SBQQ__Opportunity2__c,
                SBQQ__Quote__r.SBQQ__BillingCity__c 
            FROM SBQQ__QuoteLine__c
        ];
        // we want a map of Opportunity Id to Quote Line (we know that there are one quote line per quote (and opp), because numberOfDifferentProducts = 1)
        Map<Id, SBQQ__QuoteLine__c> opportunityIdToQuoteLineMap = new Map<Id, SBQQ__QuoteLine__c>();
        for (SBQQ__QuoteLine__c quoteLine : testQuoteLines) {
            if (!opportunityIdToQuoteLineMap.containsKey(quoteLine.SBQQ__Quote__r.SBQQ__Opportunity2__c)) {
                opportunityIdToQuoteLineMap.put(quoteLine.SBQQ__Quote__r.SBQQ__Opportunity2__c, quoteLine);
            }
        }
        
        // create Case that looks up to same Account as the Quote does, and looks up to the same Opportunity as the Quote does
        List<Case> testCases = TDF_CaseUtils.createCasesForOpportunitiesAndAssignThem(testOpportunities);

        // create activation on case and account
        List<Activation__c> activationHeadersList = TDF_ActivationUtils.createActivationHeadersForQuoteLines(
            testQuoteLines, 
            testOpportunities
        );
        activationHeadersList = [
            SELECT Id, Name, Case_Account_ID__c, Case__r.Opportunity__r.Id, Recordtype.Developername 
            FROM Activation__c
        ];
        
        // create Location Line for each opp, then insert
        List<Location_Line__c> testLocationLines = new List<Location_Line__c>();
        for (Opportunity testOpportunity : testOpportunities) {
            Location_Line__c testLocationLine = TDF_LocationLineUtils.createLocationLineForOpportunity(
                testOpportunity, 
                HomeOfficeConstants.LOCATION_LINE_SUBSCRIPTION_PRODUCT_FIBHOF03,
                opportunityIdToQuoteLineMap.get(testOpportunity.Id)
            );
            testLocationLine.OTC_product__c = 'CHXT02';
            testLocationLines.add(testLocationLine);
        }
        insert testLocationLines;

        // create and insert Activation Lines
        List<Activation_Line__c> activationLinesList = TDF_ActivationLineUtils.createActivationLines(testQuoteLines);         
    }
}