@IsTest
public with sharing class QuoteSelectorTest {
	@IsTest
	private static void testGetQuotesWithLinesHavingProductWithDocumentIdentifierFromQuoteList() {
		Integer amountOfQuoteLines = 3;
		List<Account> accs = TestDataFactory.createAccountsForTests(1);
		List<Opportunity> opps = TestDataFactory.createOpportunitiesForAccounts(1, accs);
		List<SBQQ__Quote__c> quotes = new List<SBQQ__Quote__c>{TestDataFactory.createSingleQuote(accs[0].Id, opps[0].Id)};
		insert quotes;
		List<SBQQ__QuoteLine__c> quoteLines = TestDataFactory.createQuoteLineRecordsForQuote(
			null,
			quotes,
			amountOfQuoteLines,
			0,
			false
		);

		List<Product2> products = [
			SELECT
				Id,
				Document_Identifier__c
			FROM Product2
		];
		for(Product2 product : products) {
			product.Document_Identifier__c = 'Mobile Type Products';
		}
		update products;

		Test.startTest();
		List<SBQQ__Quote__c> queryResult = QuoteSelector.getQuotesWithLinesHavingProductWithDocumentIdentifierFromQuoteList(quotes);
		Test.stopTest();

		Assert.areEqual(1, queryResult.size(), 'Exactly 1 Quote should be returned');
		Assert.areEqual(amountOfQuoteLines, queryResult[0].SBQQ__LineItems__r.size(), 'Exactly ' + amountOfQuoteLines + ' Quote Lines should be returned');
	}

	@IsTest
	private static void testGetQuotesWithLinesWithinValidUntilByAccountIdsInStatuses() {
		Integer amountOfQuoteLines = 3;
		List<Account> accs = TestDataFactory.createAccountsForTests(1);
		List<Opportunity> opps = TestDataFactory.createOpportunitiesForAccounts(1, accs);
		SBQQ__Quote__c quote = TestDataFactory.createSingleQuote(accs[0].Id, opps[0].Id);
		quote.SBQQ__StartDate__c = System.today().addDays(10);
		insert quote;
		List<SBQQ__Quote__c> quotes = new List<SBQQ__Quote__c>{quote};
		List<SBQQ__QuoteLine__c> quoteLines = TestDataFactory.createQuoteLineRecordsForQuote(
			null,
			quotes,
			amountOfQuoteLines,
			0,
			false
		);

		List<Id> accountIds = new List<Id>(new Map<Id, Account>(accs).keySet());
		Set<String> statuses = new Set<String>{'Draft'};

		Test.startTest();
		List<SBQQ__Quote__c> queryResult = QuoteSelector.getQuotesWithLinesWithinValidUntilByAccountIdsInStatuses(accountIds, statuses);
		Test.stopTest();

		Assert.areEqual(1, queryResult.size(), 'Exactly 1 Quote should be returned');
		Assert.areEqual(amountOfQuoteLines, queryResult[0].SBQQ__LineItems__r.size(), 'Exactly ' + amountOfQuoteLines + ' Quote Lines should be returned');
	}

	@IsTest
	private static void testGetQuotesValidUntilYesterday() {
		List<Account> accs = TestDataFactory.createAccountsForTests(1);
		List<Opportunity> opps = TestDataFactory.createOpportunitiesForAccounts(1, accs);
		SBQQ__Quote__c quote = TestDataFactory.createSingleQuote(accs[0].Id, opps[0].Id);
		quote.SBQQ__StartDate__c = System.today();
		List<FormulaRecalcResult> results = Formula.recalculateFormulas(new List<SBQQ__Quote__c>{quote});
		
		Integer daysBetweenYesterdayAndValidUntil = System.today().addDays(-1).daysBetween(quote.Valid_Until__c);
		quote.SBQQ__StartDate__c = quote.SBQQ__StartDate__c.addDays(-daysBetweenYesterdayAndValidUntil);
		insert quote;

		Test.startTest();
		List<SBQQ__Quote__c> queryResult = QuoteSelector.getQuotesValidUntilYesterday();
		Test.stopTest();

		Assert.areEqual(1, queryResult.size(), 'Exactly 1 Quote should be returned');
		Assert.areEqual(quote.Id, queryResult[0].Id, 'The Id of the returned Quote should match');
	}
	
	@IsTest
	private static void testGetQuotesByIdsSingle() {
		List<Account> accs = TestDataFactory.createAccountsForTests(1);
		List<Opportunity> opps = TestDataFactory.createOpportunitiesForAccounts(1, accs);
		List<SBQQ__Quote__c> quotes = new List<SBQQ__Quote__c>{TestDataFactory.createSingleQuote(accs[0].Id, opps[0].Id)};
		insert quotes;

		Test.startTest();
		List<SBQQ__Quote__c> queryResult = QuoteSelector.getQuotesByIds(new Set<Id> {quotes[0].Id});
		Test.stopTest();

		Assert.areEqual(1, queryResult.size(), 'Exactly 1 Quote should be returned');
		Assert.areEqual(quotes[0].Id, queryResult[0].Id, 'Returned a wrong Quote');
	}
	
	@IsTest
	private static void testGetQuotesByIdsMultiple() {
		List<Account> accs = TestDataFactory.createAccountsForTests(1);
		List<Opportunity> opps = TestDataFactory.createOpportunitiesForAccounts(1, accs);

		// 2 test quotes
		List<SBQQ__Quote__c> quotes = new List<SBQQ__Quote__c>{
			TestDataFactory.createSingleQuote(accs[0].Id, opps[0].Id),
			TestDataFactory.createSingleQuote(accs[0].Id, opps[0].Id)
		};
		insert quotes;

		// set of ids of the quotes
		Set<Id> quoteIds = (new Map<Id, SBQQ__Quote__c>(quotes)).keySet();

		Test.startTest();
		List<SBQQ__Quote__c> queryResult = QuoteSelector.getQuotesByIds(quoteIds);
		Test.stopTest();

		Assert.areEqual(2, queryResult.size(), 'Exactly 2 Quotes should be returned');
		for (SBQQ__Quote__c quote : queryResult) {
			Assert.isTrue(quoteIds.contains(quote.Id), 'The Quote returned is wrong');
		}
	}
	
	@IsTest
	private static void testGetQuotesByAccountCVRs() {
		String testCvr = '12345678';
		List<Account> accs = TestDataFactory.createAccountsForTests(1);
		accs[0].CVR__c = testCvr;
		update accs;
		List<Opportunity> opps = TestDataFactory.createOpportunitiesForAccounts(1, accs);
		List<SBQQ__Quote__c> quotes = new List<SBQQ__Quote__c>{TestDataFactory.createSingleQuote(accs[0].Id, opps[0].Id)};
		insert quotes;

		Test.startTest();
		List<SBQQ__Quote__c> queryResult = QuoteSelector.getQuotesByAccountCVRs(new List<String> {testCvr});
		Test.stopTest();

		Assert.areEqual(1, queryResult.size(), 'Exactly 1 Quote should be returned');
		Assert.areEqual(testCvr, queryResult[0].SBQQ__Account__r.CVR__c, 'CVR is wrong on associated Account');
	}
}