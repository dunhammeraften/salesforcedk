/**
 * 
 * @author keh
 * @since 14032025
 */
@IsTest
private class ActivationLineSelectorTest {
	private static final String CVR = '23456789';
	private static final String ACTIVATION_RECORD_TYPE_HOME_OFFICE = 'Home office';

	/**
	 * makeData
	 */
	@TestSetup
	static void makeData() {
        Test.startTest();
		Account acct = testDataFactory.createCVRAccountWithBillingAddress(CVR);
		List<Opportunity> listOfOpportunities = testDataFactory.createOpportunitiesForAccounts(1, new List<Account>{ acct });

		Billing_Account__c billingAccount = new Billing_Account__c(
			BAN_Number__c = 123456789,
			Billing_Name__c = 'Test company',
			Name = 'Invoice Name',
			Account__c = acct.Id
		);
		insert billingAccount;

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

		List<SBQQ__Quote__c> quotesList = [SELECT Id, SBQQ__BillingCity__c FROM SBQQ__Quote__c];
		List<Id> quoteIdsList = new List<Id>();

		quoteIdsList.add(quotesList[0].Id);

		List<Case> caseListMain = [SELECT Id FROM Case LIMIT 1];
		caseListMain[0].Quote__c = quotesList[0].Id;
		update caseListMain[0];

		List<Case> caseList = [SELECT Id FROM Case WHERE Quote__c = :quotesList[0].Id];

		Product2 pr = new Product2(
			ProductAPI_Telia_Product_Id__c = 'CORFRI10G',
			name = 'Corporate Fri tale EU 10 GB',
			SBQQ__SubscriptionType__c = 'Renewable',
			isActive = true,
			Activation_Record_Type__c = 'Voice',
			activate_with_other_products__c = false,
			Onboarding_Configuration__c = 'ShowInBillingAccountSummary;ShowInValueAddedServicesSummary;ShowInSubscriptionSummary'	
		);

		Product2 pr2 = new Product2(
			ProductAPI_Telia_Product_Id__c = 'CORFRI20G',
			name = 'Home office',
			SBQQ__SubscriptionType__c = 'Renewable',
			isActive = true,
			Activation_Record_Type__c = ACTIVATION_RECORD_TYPE_HOME_OFFICE,
			activate_with_other_products__c = false,
			ProductCode = '3100',
			address_required__c = true,
			Onboarding_Configuration__c = 'ShowInBillingAccountSummary;ShowInValueAddedServicesSummary;ShowInSubscriptionSummary'	
		);
        insert new List<Product2>{ pr, pr2};

		List<SBQQ__QuoteLine__c> quoteLinesList = [
			SELECT Id, SBQQ__Product__c, Activation__c, Activation_Record_Type__c, SBQQ__Quote__r.SBQQ__BillingCity__c
			FROM SBQQ__QuoteLine__c
			WHERE SBQQ__Quote__c = :quotesList[0].Id
		];
		quoteLinesList[0].Additional_Quantity__c = 3;
		quoteLinesList[0].SBQQ__Product__c = pr.Id;
		quoteLinesList[0].SBQQ__SegmentIndex__c = 1;
		quoteLinesList[0].Address_filled_on_activation_lines__c = false;

		quoteLinesList[1].Additional_Quantity__c = 3;
		quoteLinesList[1].SBQQ__Product__c = pr2.Id;
		quoteLinesList[1].SBQQ__SegmentIndex__c = 1;
		quoteLinesList[1].Address_filled_on_activation_lines__c = false;
        update new List<SBQQ__QuoteLine__c>{quoteLinesList[0], quoteLinesList[1] };

		Activation__c activation = new Activation__c(
			Case__c = caseList[0].Id,
			RecordTypeId = Schema.sObjectType.Activation__c.getRecordTypeInfosByName().get('Home office activation').getRecordTypeId()
		);
		insert activation;

		quoteLinesList.get(0).Activation__c = activation.Id;
		quoteLinesList.get(1).Activation__c = activation.Id;
		// update quoteLinesList;

		List<Activation_line__c> activationLines = new List<Activation_line__c>();
		Activation_line__c activationLine = new Activation_line__c(
			RecordTypeId = Schema.sObjectType.Activation_line__c.getRecordTypeInfosByName().get('Voice activation line').getRecordTypeId(),
			Activation__c = activation.Id,
			BAN__c = '123456789',
			Case__c = caseListMain[0].Id,
			Installation_address__c = 'Daglykkevej 5, 2650 Hvidovre',
			Quote_line__c = quoteLinesList[1].Id,
			Company_Name__c = 'JENSEN BØFHUS A/S',
			Delivery_City__c = 'Odense M',
			Delivery_Country__c = 'Denmark',
			Delivery_Street_and_number__c = 'Læssøegade 215',
			Postal_Code__c = '5230',
			Employee_Number__c = '13',
			Activation_Fulfilled__c = false,
			Email__c = 'test@test.com',
			Quantity__c = 1,
			Manual_Product__c = pr2.Id,
			Phone_no_Status__c = 'Nyt nummer',
			Billing_Account__c = billingAccount.Id
		);
		activationLines.add(activationLine);
		insert activationLines;
        
        Test.stopTest();
	}

	/**
	 * getActivationLinesByCaseId_validCase_returnsActivationLines
	 */
	@IsTest
	static void getActivationLinesByCaseId_validCase_returnsActivationLines() {
		//ARRANGE

		Account acc = AccountSelector.getByCVR(CVR);
		Opportunity opp = OpportunitySelector.getByAccountId(acc.Id);
		Case cs = [SELECT Id FROM Case WHERE Opportunity__c = :opp.Id LIMIT 1];

		//ACT
		Test.startTest();

		List<Activation_line__c> activationLines = ActivationLineSelector.getActivationLinesByCaseId(cs.Id);

		Test.stopTest();

		//ASSERT
		Assert.isTrue(activationLines.size() > 0);
	}

	/**
	 * getActivationLinesByCaseId_caseIdWithColumns_ReturnsActivationLines
	 */
	@IsTest
	static void getActivationLinesByCaseId_caseIdWithColumns_ReturnsActivationLines() {
		//ARRANGE
		Account acc = AccountSelector.getByCVR(CVR);
		Opportunity opp = OpportunitySelector.getByAccountId(acc.Id);
		Case cs = [SELECT Id FROM Case WHERE Opportunity__c = :opp.Id LIMIT 1];

		//ACT
		Test.startTest();

		List<Activation_line__c> activationLines = ActivationLineSelector.getActivationLinesByCaseId(cs.Id, 'VAS_CHXT01__c, VAS_CHXT02__c');

		Test.stopTest();

		//ASSERT
		Assert.isTrue(activationLines.size() > 0);
	}

	/**
	 * getBillingAccountsBySubscriptionCount_activationWithValidLines_returnsCorrectResult
	 */
	@IsTest
	static void getBillingAccountsBySubscriptionCount_activationWithValidLines_returnsCorrectResult() {
		//ARRANGE
		Account account = [SELECT Id FROM Account LIMIT 1];
		Activation__c activation = [SELECT Id FROM Activation__c LIMIT 1];
		
		//ACT
		Test.startTest();
		List<AggregateResult> activationLineCountByBillingAccount = ActivationLineSelector.getBillingAccountsBySubscriptionCount(activation.Id);
		Test.stopTest();

		//ASSERT
		Assert.isTrue(activationLineCountByBillingAccount.size() > 0);
	}

	/**
	 * getMapOfVoiceProductStatusLines_activationWithValidLines_returnsCorrectResult
	 */
	@IsTest
	static void getMapOfVoiceProductStatusLines_activationWithValidLines_returnsCorrectResult() {
		//ARRANGE
		Account account = [SELECT Id FROM Account LIMIT 1];
		Activation__c activation = [SELECT Id FROM Activation__c LIMIT 1];
		List<Activation_line__c> listOfActivationLines = [SELECT Id FROM Activation_line__c WHERE Activation__c = :activation.Id];
		
		//ACT
		Test.startTest();
		Map<Id, Activation_line__c> mapOfActivationLines = ActivationLineSelector.getMapOfVoiceProductStatusLines(listOfActivationLines);
		Test.stopTest();

		//ASSERT
		Assert.isTrue(mapOfActivationLines.size() > 0);
	}

	/**	
	 * getActivationLinesByActivationId_activationWithLines_returnsActivationLines
	 */
	@IsTest
	static void getActivationLinesByActivationId_activationWithLines_returnsActivationLines() {
		//ARRANGE
		Activation__c activation = [SELECT Id FROM Activation__c LIMIT 1];

		//ACT
		Test.startTest();
		List<Activation_line__c> activationLines = ActivationLineSelector.getActivationLinesByActivationId(activation.Id);
		Test.stopTest();

		//ASSERT
		Assert.isTrue(activationLines.size() > 0);
	}
	
	/**
	 * getBusinessInternetActivationLinesByCaseId_validInput_ReturnsCorrectLines
	 */
	@isTest
    static void getBusinessInternetActivationLinesByCaseId_validInput_ReturnsCorrectLines() {
		//ARRANGE
		Account acc = AccountSelector.getByCVR(CVR);
		Opportunity opp = OpportunitySelector.getByAccountId(acc.Id);
		Case caseRecord = [SELECT Id FROM Case WHERE Opportunity__c = :opp.Id LIMIT 1];
        
		//ACT
		List<Activation_line__c> activationLines = ActivationLineSelector.getBusinessInternetActivationLinesByCaseId(
            caseRecord.Id
        );

		//ASSERT
        System.assertEquals(1, activationLines.size(), 'Unexpected number of activation lines');
    }
	
	@IsTest
	static void testGetHomeOfficeActivationLinesByOpportunityIds() {
		// ARRANGE
		Account acc = AccountSelector.getByCVR(CVR);
		Opportunity opp = OpportunitySelector.getByAccountId(acc.Id);
		Set<Id> opportunityIdSet = new Set<Id>();
		opportunityIdSet.add(opp.Id);

		Id recordTypeId = Schema.sObjectType.Activation_line__c.getRecordTypeInfosByDeveloperName().get(ActivationLineSelector.RECORD_TYPE_HOME_OFFICE_ACTIVATION_LINE).getRecordTypeId();

		Billing_Account__c billingAccount = [SELECT Id FROM Billing_Account__c LIMIT 1];
		Activation__c activation = [SELECT Id FROM Activation__c LIMIT 1];
		SBQQ__Quote__c quote = [SELECT Id, SBQQ__BillingCity__c FROM SBQQ__Quote__c LIMIT 1];
		List<Case> caseListMain = [SELECT Id FROM Case WHERE Opportunity__c = :opp.Id];
		SBQQ__QuoteLine__c quoteLine = [SELECT Id FROM SBQQ__QuoteLine__c LIMIT 1];
		Product2 pr2 = [SELECT Id FROM Product2 WHERE Activation_Record_Type__c = :ACTIVATION_RECORD_TYPE_HOME_OFFICE LIMIT 1];

		// create another activation line that is of record type 'home office activation line'
		Activation_line__c activationLine = new Activation_line__c(
			RecordTypeId = recordTypeId,
			Activation__c = activation.Id,
			BAN__c = '123456789',
			Case__c = caseListMain[0].Id,
			Installation_address__c = 'Daglykkevej 5, 2650 Hvidovre',
			Quote_line__c = quoteLine.Id,
			Company_Name__c = 'JENSEN BØFHUS A/S',
			Delivery_City__c = 'Odense M',
			Delivery_Country__c = 'Denmark',
			Delivery_Street_and_number__c = 'Læssøegade 215',
			Postal_Code__c = '5230',
			Employee_Number__c = '13',
			Activation_Fulfilled__c = false,
			Email__c = 'test@test.com',
			Quantity__c = 1,
			Manual_Product__c = pr2.Id,
			Phone_no_Status__c = 'Nyt nummer',
			Billing_Account__c = billingAccount.Id
		);
		insert activationLine;

		// ACT
		Test.startTest();

		List<Activation_line__c> activationLines = ActivationLineSelector.getHomeOfficeActivationLinesByOpportunityIds(opportunityIdSet);

		Test.stopTest();

		// ASSERT
		Assert.areEqual(1, activationLines.size(), 'Unexpected number of activation lines');
		Assert.areEqual(activationLine.Id, activationLines[0].Id, 'Activation Line is not the expected one');
	}
}