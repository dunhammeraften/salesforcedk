@isTest
public with sharing class ActivationLineExportControllerTest {
     
    @IsTest
    static void getProductCodes_oneValidProduct_returnsCorrectResult(){
        
        //ARRANGE
        List<VTPX_User_Datatable_Products__mdt> mockedMetadata = new List<VTPX_User_Datatable_Products__mdt>();
        
        mockedMetadata.add(createMockedProduct('12345', false));

        MetadataSelector.setMock(new MetadataSelectorMock(mockedMetadata));
        
        //ACT
        Test.startTest();

		set<String> setOfProductCodes = ActivationLineExportController.getProductCodes();

        Test.stopTest();

        //ASSERT
        Assert.areEqual(1, setOfProductCodes.size(), 'Exactly one productCode should be found');

    }
    
    static VTPX_User_Datatable_Products__mdt createMockedProduct(String productCode, Boolean hide){
 
        VTPX_User_Datatable_Products__mdt product = new VTPX_User_Datatable_Products__mdt();
        product.Hide__c = hide;
        product.Product_Code__c = productCode;
 
        return product;
    }
    
    
    
    // private static final String TEST_CVR = '12345678';
    // private static final Integer AMOUNT_OF_DIFFERENT_PRODUCTS = 2;
    
    /*@IsTest
    static void getActivationLineExportControllerRecords() {
        Case myCase = new Case();
        myCase.Subject = 'Test Case for Activation Line Export';
        insert myCase;
    Test.startTest();
           List<Activation_line__c> listOfActivationLinesFromController = 
           ActivationLineExportController.getActivationLinesAllProducts(myCase.Id);
    Test.stopTest();

    //Assert
    Assert.isFalse(listOfActivationLinesFromController.size() > 0, 'There should be activation lines returned from the controller');
    }*/

    // @IsTest
    // static void getActivationLineExportControllerRecords() {
    //     //ARRANGE
    //     //create account
    //     Account acc = TDF_AccountUtils.createAccountWithCVR(TEST_CVR);
    //     acc.Status__c = 'Active';
    //     insert acc;

    //     //create opp on account
    //     Opportunity opp = TDF_OpportunityUtils.createOpportunitiesForAccounts(1, new List<Account>{acc})[0];

        
    //     //create quote on opp
    //     SBQQ__Quote__c quote = TDF_QuoteUtils.createSingleQuote(acc.Id, opp.Id);
    //     quote.SBQQ__StartDate__c = System.today().addDays(10);
    //     quote.SBQQ__BillingCity__c = 'København';
    //     quote.SBQQ__BillingCountry__c = 'Danmark';
    //     insert quote;
    //     System.debug('hello world: ');

    //     opp.SBQQ__PrimaryQuote__c = quote.Id;
    //     update opp;
    //     System.debug('quoteid: ' + quote.Id);

    //     System.debug('opp.SBQQ__PrimaryQuote__c: ' + opp.SBQQ__PrimaryQuote__c);

        

    //   //  opp = [SELECT Id, SBQQ__PrimaryQuote__c FROM Opportunity WHERE Id = :opp.Id LIMIT 1][0];

    //     Integer numberOfDifferentProducts = 2;
    //     Integer numberOfNoActionProducts = 1;
    //     List<Product2> listOfProductsToUse = TDF_ProductUtils.createProductsForTests(numberOfDifferentProducts);
    //     listOfProductsToUse.addAll(TDF_ProductUtils.createNoActionProducts(numberOfNoActionProducts));
    //     listOfProductsToUse.addAll(TDF_ProductUtils.createHomeOfficeProducts(numberOfNoActionProducts));
       
    //     List<VTPX_User_Datatable_Products__mdt> vtpxUserDatatableProducts = createmockedVTPXDataTableProducts(listOfProductsToUse);


    //     List<PricebookEntry> listOfPricebookEntries = TDF_ProductUtils.createStandardPricebookEntriesForProducts(listOfProductsToUse);
    //     Map<Id, PricebookEntry> mapOfProductToPricebookEntries = TDF_ProductUtils.createProductIdToPricebookEntryMap(
    //         listOfPricebookEntries, 
    //         listOfProductsToUse);
      
    //     //create quotelines on quote
    //     List<SBQQ__QuoteLine__c> listOfQuoteLinesTmp = TDF_QuoteLineUtils.createQuoteLinesForQuote(
    //         new List<SBQQ__Quote__c>{quote}, 
    //         false, listOfProductsToUse, 
    //         mapOfProductToPricebookEntries);

    //     List<SBQQ__QuoteLine__c> listOfQuoteLines = [
    //         SELECT Id, 
    //             SBQQ__Quote__c, 
    //             SBQQ__Product__c, 
    //             SBQQ__PricebookEntryId__c, 
    //             SBQQ__Quantity__c, 
    //             SBQQ__NetPrice__c, 
    //             Activation_Record_Type__c,
    //             Activation__c,
    //             SBQQ__Quote__r.SBQQ__BillingCity__c,
    //             Original_Quote_Line__c,
    //             SBQQ__RequiredBy__c,
    //             Additional_Quantity__c,
    //             cross_sale__c,
    //             upsale__c
    //         FROM SBQQ__QuoteLine__c
    //         WHERE Id IN :listOfQuoteLinesTmp
    //     ];

    //     //create case on account
    //     Case quoteCase = TDF_CaseUtils.createCaseOnQuote(quote);

    //     opp.Case__c = quoteCase.Id;
    //     update opp;

    //     //create activation on case and account
    //     List<Activation__c> listOfActivations = TDF_ActivationUtils.createActivationHeadersForQuoteLines(listOfQuoteLines, new List<Opportunity>{opp});
        
        

    //     //create activation lines on activation
    //     List<Activation_Line__c> listOfActivationLines = TDF_ActivationLineUtils.createActivationlinesWithCase(listOfQuoteLines, quoteCase);

    //     List<ActivationFulfilledQuoteLineAction.InputVariables> listOfInputVariables = new List<ActivationFulfilledQuoteLineAction.InputVariables>();
    //     ActivationFulfilledQuoteLineAction.InputVariables inputVariables = new ActivationFulfilledQuoteLineAction.InputVariables();
    //     inputVariables.activationQuote = quote;
    //     inputVariables.listOfQuoteLines = listOfQuoteLines;
    //     listOfInputVariables.add(inputVariables);


    //     //ACT
    //     Test.startTest();
    //        List<Activation_line__c> listOfActivationLinesFromController = 
    //        ActivationLineExportController.getActivationLinesAllProducts(quoteCase.Id);
    //        System.debug('pancake' + listOfActivationLinesFromController);
       
    
    //    // List<ActivationFulfilledQuoteLineAction.OutputVariables> listOfActivationQuotes = ActivationFulfilledQuoteLineAction.getActivationFulfilledQuoteLinesAction(listOfInputVariables);
    //     Test.stopTest();

    //     //ASSERT

    //     //Assert.isTrue(1==2, 'hello' + listOfActivationLinesFromController);
    //     Assert.isTrue(listOfActivationLinesFromController.size() == 2, 'There should be activation lines returned from the controller');
    //     // Assert.isTrue(listOfActivationQuotes.size() > 0, 'An outPut variable should exist');
    //     // Assert.isTrue(listOfActivationQuotes.get(0).listOfQuoteLines.get(0).SBQQ__Quantity__c > 0, 'SBQQ__Quantity__c should be greater than 0');
    //     // Assert.isTrue(listOfActivationQuotes.get(0).listOfQuoteLines.get(0).cross_sale__c == true, 'cross_sale__c should be true');
    //     // Assert.isTrue(listOfActivationQuotes.get(0).listOfQuoteLines.get(0).upsale__c == false, 'upsale__c should be false');   
    // }

    
    // static List<VTPX_User_Datatable_Products__mdt> createMockedVTPXDataTableProducts(List<Product2> listOfProductsToUse){
    //     List<VTPX_User_Datatable_Products__mdt> mockedMetadata = new List<VTPX_User_Datatable_Products__mdt>();
    //     VTPX_User_Datatable_Products__mdt vtpxUserDatatableProduct1 = new VTPX_User_Datatable_Products__mdt();
	// 	vtpxUserDatatableProduct1.Product_Code__c = listOfProductsToUse[0].ProductCode;
    //     vtpxUserDatatableProduct1.Hide__c = true;
	// 	mockedMetadata.add(vtpxUserDatatableProduct1);

    //     VTPX_User_Datatable_Products__mdt vtpxUserDatatableProduct2 = new VTPX_User_Datatable_Products__mdt();
	// 	vtpxUserDatatableProduct2.Product_Code__c = listOfProductsToUse[1].ProductCode;
    //     vtpxUserDatatableProduct1.Hide__c = false;
	// 	mockedMetadata.add(vtpxUserDatatableProduct2);

    //     MetadataSelector.setMock(new MetadataSelectorMock(mockedMetadata));
    //     return mockedMetadata;
    //  }
}