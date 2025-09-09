/**
 * 
 * @author keh
 * @since 14032025
 */
@IsTest
private class VoiceFlowSummaryActionTest {
	private static final String CVR = '12345678';

	/**
	 * makeData
	 */
	@TestSetup
	static void makeData() {
		Test.startTest();
		Profile prof = ProfileSelector.getProfileByProfileName(ProfileConstants.SYSTEM_ADMINISTRATOR);
		User usr = testDataFactory.createUser('standt', prof.Id);
		Account account = testDataFactory.createAccountWithCVR(CVR);
		account.OwnerId = usr.Id;
		insert account;

		Billing_Account__c billingAccount = new Billing_Account__c(
			BAN_Number__c = 123456789,
			Billing_Name__c = 'Test company',
			Name = 'Invoice Name',
			Account__c = account.Id
		);
		insert billingAccount;

		List<Opportunity> listOfOpportunities = testDataFactory.createOpportunitiesForAccounts(1, new List<Account>{ account });

		Integer numOfQuotesPerOpp = 1,
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
			ProductAPI_Telia_Product_Id__c = 'CORFRI1TB',
			name = 'Corporate Fri tale 1TB',
			SBQQ__SubscriptionType__c = 'Renewable',
			isActive = true,
			Activation_Record_Type__c = 'Voice',
			activate_with_other_products__c = false,
			ProductCode = '11106',
			Onboarding_Configuration__c = 'ShowInBillingAccountSummary;ShowInValueAddedServicesSummary;ShowInSubscriptionSummary'	
		);
		insert new List<Product2>{pr, pr2};

		List<SBQQ__QuoteLine__c> quoteLinesList = [SELECT Id, SBQQ__Product__c FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c = :quotesList[0].Id];
		quoteLinesList[0].Additional_Quantity__c = 3;
		quoteLinesList[0].SBQQ__Product__c = pr.Id;
		quoteLinesList[0].SBQQ__SegmentIndex__c = 1;
		quoteLinesList[0].SBQQ__Quantity__c = 1;
		quoteLinesList[0].Consumed_Quantity__c = 1;
		quoteLinesList[0].Address_filled_on_activation_lines__c = false;

		quoteLinesList[1].Additional_Quantity__c = 3;
		quoteLinesList[1].SBQQ__Product__c = pr2.Id;
		quoteLinesList[1].SBQQ__SegmentIndex__c = 1;
		quoteLinesList[1].SBQQ__Quantity__c = 1;
		quoteLinesList[1].Consumed_Quantity__c = 1;
		quoteLinesList[1].Address_filled_on_activation_lines__c = false;

		update new list<SBQQ__QuoteLine__c>{quoteLinesList[0], quoteLinesList[1]};

		Activation__c activation = new Activation__c(
			Case__c = caseList[0].Id,
			RecordTypeId = Schema.sObjectType.Activation__c.getRecordTypeInfosByName().get('Voice activation').getRecordTypeId()
		);
		insert activation;

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
	 * getVoiceFlowSummary_ValidRequest_ReturnsValidRespons
	 */
	@IsTest
	private static void getVoiceFlowSummary_ValidRequest_ReturnsValidRespons() {
		//ARRANGE
		Activation__c activation = [SELECT Id FROM Activation__c LIMIT 1];
		
		List<Activation_line__c> listOfActivationLines = [SELECT Id, Product__c, Phone_no_Status__c, Billing_Account__c FROM Activation_line__c];
		List<SBQQ__Quote__c> listOfQuotes = [SELECT Id FROM SBQQ__Quote__c];
		List<SBQQ__QuoteLine__c> listOfQuoteLines = [SELECT Id, SBQQ__Product__c FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c = :listOfQuotes.get(0).Id];

		VoiceFlowSummaryAction.Request request = new VoiceFlowSummaryAction.Request();
		request.activation = activation;
		request.activationLines = listOfActivationLines;
		request.quoteLines = listOfQuoteLines;

		//ACT
		Test.startTest();

		List<VoiceFlowSummaryAction.Result> response = (List<VoiceFlowSummaryAction.Result>)VoiceFlowSummaryAction.getVoiceFlowSummary(new List<VoiceFlowSummaryAction.Request>{ request });

		Test.stopTest();

		//ASSERT
		Assert.isTrue(response.get(0).billingAccountSummary.size() > 0);
		Assert.isTrue(response.get(0).productSummary.size() > 0);
		Assert.isTrue(response.get(0).vasSummary.size() > 0);
	}
}