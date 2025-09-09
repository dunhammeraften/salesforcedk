@isTest
private class QuoteToCaseTypesCalculatorTest {
//TODO: keh fix this test, the product and related info need to be voice, not home office as the things setup in productutils
//     @TestSetup
// 	static void createTestData() {
//         List<Account> accs = TDF_AccountUtils.createListOfAccountsWithCVRAndOwner(1);
//         insert accs;
        
//         List<Opportunity> opps = TDF_OpportunityUtils.createOpportunitiesForAccounts(1, accs);
//         Opportunity opp = opps.get(0);

//         SBQQ__Quote__c quote = TDF_QuoteUtils.createSingleQuote(accs[0].Id, opps[0].Id);
//         quote.SBQQ__StartDate__c = System.today().addDays(10);
//         quote.SBQQ__BillingCity__c = 'København';
//         quote.SBQQ__BillingCountry__c = 'Danmark';
//         insert quote;

//         opp.SBQQ__PrimaryQuote__c = quote.Id;
//         update opp;

//         opp = [SELECT Id, SBQQ__PrimaryQuote__c FROM Opportunity WHERE Id = :opp.Id LIMIT 1][0];

//         //Product2 product = new Product2(Name = 'test', ProductCode = 'Math', Delivery_Product_Group__c = 'Voice');
//         //insert product;

//         //List<Product2> listOfProducts = new List<Product2>{product};
//         Integer numberOfDifferentProducts = 1;
//         Integer numberOfNoActionProducts = 0;
//         List<Product2> listOfProducts = TDF_ProductUtils.createProductsForTestsWithType(numberOfDifferentProducts, TDF_Constants.VOICE, '12202');
//         //listOfProducts.addAll(TDF_ProductUtils.createNoActionProducts(numberOfNoActionProducts));
//         listOfProducts.addAll(TDF_ProductUtils.createVoiceProducts(numberOfNoActionProducts));

//         List<PricebookEntry> listOfPricebookEntries = TDF_ProductUtils.createStandardPricebookEntriesForProducts(listOfProducts);
//         Map<Id, PricebookEntry> mapOfProductToPricebookEntries = TDF_ProductUtils.createProductIdToPricebookEntryMap(
//             listOfPricebookEntries, 
//             listOfProducts);

//         List<SBQQ__QuoteLine__c> listOfQuoteLinesTmp = TDF_QuoteLineUtils.createQuoteLinesForQuote(
//             new List<SBQQ__Quote__c>{quote}, 
//             false, 
//             listOfProducts, 
//             mapOfProductToPricebookEntries);

//         List<SBQQ__QuoteLine__c> listOfQuoteLines = [
//             SELECT Id, 
//                 SBQQ__Quote__c, 
//                 SBQQ__Product__c, 
//                 SBQQ__PricebookEntryId__c, 
//                 SBQQ__Quantity__c, 
//                 SBQQ__NetPrice__c, 
//                 Activation_Record_Type__c,
//                 Activation__c,
//                 SBQQ__Quote__r.SBQQ__BillingCity__c,
//                 Original_Quote_Line__c,
//                 SBQQ__RequiredBy__c,
//                 Additional_Quantity__c,
//                 cross_sale__c,
//                 upsale__c
//             FROM SBQQ__QuoteLine__c
//             WHERE Id IN :listOfQuoteLinesTmp
//         ];
//     }

// @isTest
//     static void testGetQuoteTypes() {
//         List<List<String>> input = new List<List<String>>();

//         List<String> ids = new List<String>();

//         List<SBQQ__Quote__c> quotes = [SELECT Id, Name FROM SBQQ__Quote__c];
        
//         ids.add(quotes[0].Id);

//         input.add(ids);

//         List<List<String>> result = QuoteToCaseTypesCalculator.getQuoteTypes(input);
//         System.assertEquals('Voice', result[0][0], 'Product Group not set correctly');
//     }

}