/**
 * 
 * @author 
 * @since 
 */
@IsTest
public with sharing class ActivationSelectorTest {
	private static final String CVR = '12345678';

	/**
	 * makeData
	 */
	static void makeData() {
        SBQQ.TriggerControl.disable();
		Profile prof = ProfileSelector.getProfileByProfileName(ProfileConstants.SYSTEM_ADMINISTRATOR);
		User usr = testDataFactory.createUser('standt', prof.Id);
		Account account = testDataFactory.createAccountWithCVR(CVR);
		account.OwnerId = usr.Id;
		insert account;
		List<Opportunity> listOfOpportunities = testDataFactory.createOpportunitiesForAccounts(1, new List<Account>{ account });

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
		listOfQuoteLines = [SELECT Id, Activation_Record_Type__c, SBQQ__Quote__c, SBQQ__Quantity__c, SBQQ__Product__c, Sales_Type__c FROM SBQQ__QuoteLine__c];

		List<SBQQ__Quote__c> quotesList = [SELECT Id FROM SBQQ__Quote__c];
		List<Id> quoteIdsList = new List<Id>();

		quoteIdsList.add(quotesList[0].Id);

		List<Case> caseListMain = [SELECT id FROM case LIMIT 1];
		caseListMain[0].Quote__c = quotesList[0].Id;
		update caseListMain[0];

		List<Case> caseList = [SELECT id FROM case WHERE Quote__c = :quotesList[0].Id];

		Product2 pr = new Product2(
			ProductAPI_Telia_Product_Id__c = 'CORFRI10G',
			name = 'Corporate Fri tale EU 10 GB',
			SBQQ__SubscriptionType__c = 'Renewable',
			isActive = true,
			Activation_Record_Type__c = 'Voice',
			activate_with_other_products__c = false
		);
		insert pr;

		Product2 pr2 = new Product2(
			ProductAPI_Telia_Product_Id__c = 'CORFRI20G',
			name = 'Home office',
			SBQQ__SubscriptionType__c = 'Renewable',
			isActive = true,
			Activation_Record_Type__c = 'Home office',
			activate_with_other_products__c = false,
			ProductCode = '3100',
			address_required__c = true
		);
		insert pr2;

		List<SBQQ__QuoteLine__c> quoteLinesList = [SELECT Id, SBQQ__Product__c FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c = :quotesList[0].Id];
		quoteLinesList[0].Additional_Quantity__c = 3;
		quoteLinesList[0].SBQQ__Product__c = pr.Id;
		quoteLinesList[0].SBQQ__SegmentIndex__c = 1;
		quoteLinesList[0].Address_filled_on_activation_lines__c = false;
		update quoteLinesList[0];

		quoteLinesList[1].Additional_Quantity__c = 3;
		quoteLinesList[1].SBQQ__Product__c = pr2.Id;
		quoteLinesList[1].SBQQ__SegmentIndex__c = 1;
		quoteLinesList[1].Address_filled_on_activation_lines__c = false;
		update quoteLinesList[1];

		Activation__c activation = new Activation__c(
			Case__c = caseList[0].Id,
			RecordTypeId = Schema.sObjectType.Activation__c.getRecordTypeInfosByName().get('Home office activation').getRecordTypeId()
		);
		insert activation;
        SBQQ.TriggerControl.enable();
	}

	/**
	 * getActivationsByCaseId_validCaseId_returnsListOfActivations
	 */
	@IsTest
	static void getActivationsByCaseId_validCaseId_returnsListOfActivations() {
		makeData();

		//ARRANGE
		Case cs = [SELECT id FROM case LIMIT 1];

		//ACT
		Test.startTest();
		List<Activation__c> activations = ActivationSelector.getActivationsByCaseId(cs.Id);
		Test.stopTest();

		//ASSERT
		Assert.isTrue(activations.size() > 0);
	}

	/**
	 * getActivationsByCases_validListOfCases_returnsListOfActivations
	 */
	@IsTest
	static void getActivationsByCases_validListOfCases_returnsListOfActivations() {
		makeData();
		
		//ARRANGE
		List<Case> cases = [SELECT id FROM case];

		//ACT
		Test.startTest();
		List<Activation__c> activations = ActivationSelector.getActivationsByCases(cases);
		Test.stopTest();

		//ASSERT
		Assert.isTrue(activations.size() > 0);
	}

	/**
	 * getActivationById_validActivationId_returnsActivation
	 */
	@IsTest
	static void getActivationById_validActivationId_returnsActivation() {
		makeData();

		//ARRANGE
		Account account = AccountSelector.getByCVR(CVR);
		Activation__c activation = [SELECT Id FROM Activation__c WHERE Case_Account_ID__c = :account.Id LIMIT 1];

		//ACT
		Test.startTest();
		Activation__c activationById = ActivationSelector.getActivationById(activation.Id);
		Test.stopTest();
		
		//ASSERT
		Assert.isNotNull(activationById);
	}

	/**
	 * getActivationByCaseId_validCaseRecordId_ReturnsActivationWithSameCase
	 */
	@isTest
    static void getActivationByCaseId_validCaseRecordId_ReturnsActivationWithSameCase() {
		makeData();
		
		//ARRANGE
		Case caseRecord = [SELECT id FROM case LIMIT 1];

		//ACT
		Test.startTest();
		Activation__c activation = ActivationSelector.getActivationByCaseId(caseRecord.Id);
		Test.stopTest();

		//ASSERT
        System.assertEquals(caseRecord.Id, activation.Case__c, 'should be equal');
    }

	@IsTest
    static void testGetHomeOfficeActivationByIds() {
		makeData();
		
		// ARRANGE
		// re-query the home office activation from make data
		List<Activation__c> testActivations = [SELECT Id FROM Activation__c];

		// ACT
		Test.startTest();

		List<Activation__c> testActivationsResult = ActivationSelector.getHomeOfficeActivationByIds(new Set<Id> {testActivations[0].Id});

		Test.stopTest();

		// ASSERT
		Assert.areEqual(1, testActivationsResult.size(), 'Expect 1 Activation record');
	}

}