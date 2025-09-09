@IsTest
public with sharing class QuoteLineSelectorTest {
	private static final String CVR = '12345678';
	
	//@TestSetup
	static void makeData() {
		Account acct = testDataFactory.createCVRAccountWithBillingAddress(CVR);
		List<Opportunity> listOfOpportunities = testDataFactory.createOpportunitiesForAccounts(1, new List<Account>{ acct });

		Integer numOfAccounts = 1,
			numOfOppsPerAccount = 1,
			numOfQuotesPerOpp = 1,
			numOfQuoteLinesPerQuote = 2,
			numOfDiffProducts = 2,
			numOfNoActionProducts = 0;

		List<SBQQ__Quote__c> listOfQuotes = testDataFactory.createQuotesForOpps(numOfQuotesPerOpp, listOfOpportunities);
		listOfOpportunities = [SELECT Id, AccountId, SBQQ__PrimaryQuote__c, SBQQ__PrimaryQuote__r.SBQQ__StartDate__c, Case__c FROM Opportunity];
		List<Case> theRelatedToOppCases = testDataFactory.createCasesForOpportunitiesAndAssignThem(listOfOpportunities); // Should be called after Quote creation
		listOfOpportunities = [SELECT Id, AccountId, SBQQ__PrimaryQuote__c, SBQQ__PrimaryQuote__r.SBQQ__StartDate__c, Case__c FROM Opportunity];
		List<SBQQ__QuoteLine__c> listOfQuoteLines = testDataFactory.createQuoteLineRecordsForQuote(
			numOfQuoteLinesPerQuote,
			listOfQuotes,
			numOfDiffProducts,
			numOfNoActionProducts,
			true
		);

		Product2 pr = new Product2(
			ProductAPI_Telia_Product_Id__c = 'HBOBTB4',
			name = 'HBO Max',
			SBQQ__SubscriptionType__c = 'Renewable',
			isActive = true,
			Activation_Record_Type__c = 'Voice',
			activate_with_other_products__c = true,
			Requires_Activation_Check__c = true,
			Delivery_Product_Group__c = 'Voice',
			Onboarding_Configuration__c = 'ShowInValueAddedServicesSummary'	
		);
		insert pr;

		Activation__c activation = new Activation__c(
			Case__c = theRelatedToOppCases[0].Id,
			RecordTypeId = Schema.sObjectType.Activation__c.getRecordTypeInfosByName().get('Voice activation').getRecordTypeId()
		);
		insert activation;

		for (SBQQ__QuoteLine__c quoteLine : listOfQuoteLines) {
			quoteLine.SBQQ__Product__c = pr.Id;
			quoteLine.Activation__c = activation.Id;
		}
		update listOfQuoteLines;
	}

	@IsTest
	static void getValueAddedServiceProductByQuote_quoteWithLines_returnsQuoteLines() {
		makeData();

		//ARRANGE
		SBQQ__Quote__c quote = [SELECT Id FROM SBQQ__Quote__c LIMIT 1];

		//ACT
		Test.startTest();
		List<SBQQ__QuoteLine__c> quotelines = QuoteLineSelector.getValueAddedServiceProductByQuote(quote.Id);
		Test.stopTest();

		//ASSERT
		Assert.isTrue(quotelines.size() > 0);
	}

	@IsTest
	static void getValueAddedServiceProductByQuote_invalidQuote_returnsNoQuoteLines() {
		makeData();

		//ARRANGE

		//ACT
		Test.startTest();
		List<SBQQ__QuoteLine__c> quotelinesNullQuote = QuoteLineSelector.getValueAddedServiceProductByQuote(null);
		List<SBQQ__QuoteLine__c> quotelinesEmptyStringQuote = QuoteLineSelector.getValueAddedServiceProductByQuote('');
		List<SBQQ__QuoteLine__c> quotelinesNonExistingQuote = QuoteLineSelector.getValueAddedServiceProductByQuote('123');
		Test.stopTest();

		//ASSERT
		Assert.isTrue(quotelinesNullQuote.size() == 0);
		Assert.isTrue(quotelinesEmptyStringQuote.size() == 0);
		Assert.isTrue(quotelinesNonExistingQuote.size() == 0);
	}

	@IsTest
	static void getVASByActivationAndQuote_validActivation_returnsQuoteLines() {
		makeData();

		//ARRANGE
		Activation__c activation = [SELECT Id FROM Activation__c LIMIT 1];

		//ACT
		Test.startTest();
		List<SBQQ__QuoteLine__c> quotelines = QuoteLineSelector.getVASByActivationAndQuote(activation.Id);
		Test.stopTest();

		//ASSERT
		Assert.isTrue(quotelines.size() > 0);
	}

	@IsTest
	static void getVasWithOnboardingConfiguration_validQuoteLines_returnsQuoteLines() {
		makeData();

		//ARRANGE
		SBQQ__Quote__c quote = [SELECT Id FROM SBQQ__Quote__c LIMIT 1];

		List<SBQQ__QuoteLine__c> quoteLines = QuoteLineSelector.getValueAddedServiceProductByQuote(quote.Id);

		//ACT
		Test.startTest();
		List<SBQQ__QuoteLine__c> quoteLinesWithOnboarding = QuoteLineSelector.getVasWithOnboardingConfiguration(quoteLines);
		Test.stopTest();

		//ASSERT
		Assert.isTrue(quoteLinesWithOnboarding.size() > 0);
	}

	@isTest
    static void getDeliveryProductGroups_validQuoteAndTypes_returnsQuoteLines() {
		makeData();
		
        //ARRANGE
		SBQQ__Quote__c testQuote = [SELECT Id FROM SBQQ__Quote__c LIMIT 1];
        Set<Id> quoteIds = new Set<Id>{testQuote.Id};
        Set<String> existingTypes = new Set<String>{'Existing Group'};

		//ACT
        Test.startTest();
        List<SBQQ__QuoteLine__c> quotelines = QuoteLineSelector.getDeliveryProductGroups(quoteIds, existingTypes);
        Test.stopTest();

		//ASSERT
		Assert.isTrue(quotelines.size() > 0, 'Expected to have at least one quote line');
        Assert.areEqual('Voice', quotelines[0].SBQQ__Product__r.Delivery_Product_Group__c, 'Incorrect product group retrieved');
    }

	@IsTest
    static void testGetQuoteLinesByOpportunityIds() {
		makeData();
		
        // ARRANGE
		Map<Id, Opportunity> opportunityMap = new Map<Id, Opportunity>([SELECT Id FROM Opportunity]);

		// ACT
        Test.startTest();

		List<SBQQ__QuoteLine__c> quoteLines = QuoteLineSelector.getQuoteLinesByOpportunityIds(
			opportunityMap.keySet()
		);

        Test.stopTest();

		// ASSERT
		Assert.areEqual(2, quoteLines.size(), 'Expected 2 Quote Lines');
		Assert.areEqual(1, opportunityMap.size(), 'Expected 1 Opportunity in map');

		for (SBQQ__QuoteLine__c quoteLine : quoteLines) {			
			Assert.isNotNull(quoteLine.Activation__c, 'Expected Activation field to be populated');
			Assert.isTrue(
				opportunityMap.keySet().contains(quoteLine.SBQQ__Quote__r.SBQQ__Opportunity2__r.Id), 
				'Opportunity Id is incorrect'
			);
		}
	}

}