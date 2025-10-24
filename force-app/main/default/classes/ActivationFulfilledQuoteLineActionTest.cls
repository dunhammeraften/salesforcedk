@IsTest
public with sharing class ActivationFulfilledQuoteLineActionTest {
	private static final String TEST_CVR = '12345678';
	private static final Integer AMOUNT_OF_DIFFERENT_PRODUCTS = 2;

	@IsTest
	static void testCorrectQuantityIsSet() {
		// Arrange
		Account acc = new Account(Name = 'Test Account', CVR__c = TEST_CVR);
		insert acc;

		Id pricebookId = Test.getStandardPricebookId();

		Opportunity opp = new Opportunity(
			Name = 'Test Opportunity',
			AccountId = acc.Id,
			StageName = 'Prospecting',
			CloseDate = System.today().addDays(30),
			Pricebook2Id = pricebookId
		);
		insert opp;

		Product2 product1 = new Product2(Name = 'Business Internet 5G', IsActive = true);
		Product2 product2 = new Product2(Name = 'Business Internet 5G 1TB', IsActive = true);
		insert new List<Product2>{ product1, product2 };

		SBQQ__Quote__c quote = new SBQQ__Quote__c(
			SBQQ__Opportunity2__c = opp.Id,
			SBQQ__Account__c = acc.Id,
			SBQQ__Primary__c = true
		);
		insert quote;

		SBQQ__QuoteLine__c quoteLine1 = new SBQQ__QuoteLine__c(
			SBQQ__Quote__c = quote.Id,
			SBQQ__Product__c = product1.Id,
			SBQQ__Quantity__c = 1
		);
		SBQQ__QuoteLine__c quoteLine2 = new SBQQ__QuoteLine__c(
			SBQQ__Quote__c = quote.Id,
			SBQQ__Product__c = product2.Id,
			SBQQ__Quantity__c = 1
		);
		insert new List<SBQQ__QuoteLine__c>{ quoteLine1, quoteLine2 };

		Case quoteCase = new Case(Status = 'New', Origin = 'Web', AccountId = acc.Id);
		insert quoteCase;

		Activation__c activation = new Activation__c(Case__c = quoteCase.Id);
		insert activation;

		Activation_line__c activationLine = new Activation_line__c(
			Quote_line__c = quoteLine2.Id,
			Manual_Product__c = product2.Id,
			Activation__c = activation.Id
		);
		insert activationLine;

		ActivationFulfilledQuoteLineAction.InputVariables input = new ActivationFulfilledQuoteLineAction.InputVariables();
		input.activationQuote = quote;
		input.listOfQuoteLines = new List<SBQQ__QuoteLine__c>{ quoteLine1, quoteLine2 };

		// Act
		Test.startTest();
		List<ActivationFulfilledQuoteLineAction.OutputVariables> result = ActivationFulfilledQuoteLineAction.getActivationFulfilledQuoteLinesAction(
			new List<ActivationFulfilledQuoteLineAction.InputVariables>{ input }
		);
		Test.stopTest();

		// Assert
		System.assertEquals(1, result.size(), 'The result should contain one output variable.');

		SBQQ__QuoteLine__c resultQuoteLine1;
		SBQQ__QuoteLine__c resultQuoteLine2;

		for (SBQQ__QuoteLine__c ql : result[0].listOfQuoteLines) {
			if (ql.Original_Quote_Line__c == quoteLine1.Id) {
				resultQuoteLine1 = ql;
			} else if (ql.Original_Quote_Line__c == quoteLine2.Id) {
				resultQuoteLine2 = ql;
			}
		}

		System.assertNotEquals(null, resultQuoteLine1, 'Quote line 1 should not be null.');
		System.assertNotEquals(null, resultQuoteLine2, 'Quote line 2 should not be null.');
		System.assertEquals(0, resultQuoteLine1.SBQQ__Quantity__c, 'The quantity for Business Internet 5G should be 0.');
		System.assertEquals(
			1,
			resultQuoteLine2.SBQQ__Quantity__c,
			'The quantity for Business Internet 5G 1TB should be 1.'
		);
	}

	@IsTest
	static void getActivationFulfilledQuoteLinesAction_ValidInput_SetsCorrectQuantity() {
		//ARRANGE
		//create account
		Account acc = TDF_AccountUtils.createAccountWithCVR(TEST_CVR);
		acc.Status__c = 'Active';
		insert acc;

		//create opp on account
		Opportunity opp = TDF_OpportunityUtils.createOpportunitiesForAccounts(1, new List<Account>{ acc })[0];

		//create quote on opp
		SBQQ__Quote__c quote = TDF_QuoteUtils.createSingleQuote(acc.Id, opp.Id);
		quote.SBQQ__StartDate__c = System.today().addDays(10);
		quote.SBQQ__BillingCity__c = 'København';
		quote.SBQQ__BillingCountry__c = 'Danmark';
		insert quote;

		opp.SBQQ__PrimaryQuote__c = quote.Id;
		update opp;

		opp = OpportunitySelector.getOpportunityWithPrimaryQuoteById(opp.Id);

		Integer numberOfDifferentProducts = 2;
		Integer numberOfNoActionProducts = 1;
		List<Product2> listOfProductsToUse = TDF_ProductUtils.createProductsForTests(numberOfDifferentProducts);
		listOfProductsToUse.addAll(TDF_ProductUtils.createNoActionProducts(numberOfNoActionProducts));
		listOfProductsToUse.addAll(TDF_ProductUtils.createHomeOfficeProducts(numberOfNoActionProducts));

		List<PricebookEntry> listOfPricebookEntries = TDF_ProductUtils.createStandardPricebookEntriesForProducts(
			listOfProductsToUse
		);
		Map<Id, PricebookEntry> mapOfProductToPricebookEntries = TDF_ProductUtils.createProductIdToPricebookEntryMap(
			listOfPricebookEntries,
			listOfProductsToUse
		);

		//create quotelines on quote
		List<SBQQ__QuoteLine__c> listOfQuoteLinesTmp = TDF_QuoteLineUtils.createQuoteLinesForQuote(
			new List<SBQQ__Quote__c>{ quote },
			false,
			listOfProductsToUse,
			mapOfProductToPricebookEntries
		);

		Test.startTest();

		List<SBQQ__QuoteLine__c> listOfQuoteLines = QuoteLineSelector.getQuoteLinesWithDetailsByIds(
			new List<Id>(new Map<Id, SObject>(listOfQuoteLinesTmp).keySet())
		);

		//create case on account
		Case quoteCase = TDF_CaseUtils.createCaseOnQuote(quote);
		opp.Case__c = quoteCase.Id;
		update opp;

		//create activation on case and account
		List<Activation__c> listOfActivations = TDF_ActivationUtils.createActivationHeadersForQuoteLines(
			listOfQuoteLines,
			new List<Opportunity>{ opp }
		);

		//create activation lines on activation
		List<Activation_Line__c> listOfActivationLines = TDF_ActivationLineUtils.createActivationlines(listOfQuoteLines);

		List<ActivationFulfilledQuoteLineAction.InputVariables> listOfInputVariables = new List<ActivationFulfilledQuoteLineAction.InputVariables>();
		ActivationFulfilledQuoteLineAction.InputVariables inputVariables = new ActivationFulfilledQuoteLineAction.InputVariables();
		inputVariables.activationQuote = quote;
		inputVariables.listOfQuoteLines = listOfQuoteLines;
		listOfInputVariables.add(inputVariables);

		//ACT
		List<ActivationFulfilledQuoteLineAction.OutputVariables> listOfActivationQuotes = ActivationFulfilledQuoteLineAction.getActivationFulfilledQuoteLinesAction(
			listOfInputVariables
		);
		Test.stopTest();

		//ASSERT
		Assert.isTrue(listOfActivationQuotes.size() > 0, 'An outPut variable should exist');
		Assert.isTrue(
			listOfActivationQuotes.get(0).listOfQuoteLines.get(0).SBQQ__Quantity__c > 0,
			'SBQQ__Quantity__c should be greater than 0'
		);
		Assert.isTrue(
			listOfActivationQuotes.get(0).listOfQuoteLines.get(0).cross_sale__c == true,
			'cross_sale__c should be true'
		);
		Assert.isTrue(
			listOfActivationQuotes.get(0).listOfQuoteLines.get(0).upsale__c == false,
			'upsale__c should be false'
		);
	}
}
