@IsTest
private with sharing class SalesPlayManagementGetAccountsActionTest {
	private static final String TEST_CVR = '12345678';
	private static final Integer AMOUNT_OF_MONTHS_DATE_FILTER = 6;
	private static final List<String> FORMATTING_ARGUMENTS = new List<String>{String.valueOf(AMOUNT_OF_MONTHS_DATE_FILTER)};

	//@TestSetup
	private static void makeData() {
		Account acc = TestDataFactory.createAccountWithCVR(TEST_CVR);
		acc.Status__c = 'Active';
		insert acc;
	}

	@IsTest
	private static void testAccountWithNoOpportunityOrLead() {
		makeData();

		Account acc = AccountSelector.getByCVR(TEST_CVR);
		
		SalesPlayManagementGetAccountsAction.Request request = new SalesPlayManagementGetAccountsAction.Request();
		request.amountOfMonthsForDateFilter = AMOUNT_OF_MONTHS_DATE_FILTER;
		request.accounts = new List<Account>{acc};

		Test.startTest();
		List<SalesPlayManagementGetAccountsAction.Response> responses = SalesPlayManagementGetAccountsAction.getAccountCollections(
			new List<SalesPlayManagementGetAccountsAction.Request>{request}
		);
		Test.stopTest();

		Assert.areEqual(1, responses.size(), 'One response should be returned');

		SalesPlayManagementGetAccountsAction.Response response = responses[0];
		Assert.areEqual(1, response.accountsNotInVestingPeriod.size(), 'One Account not in vesting period should be returned');
		Assert.isTrue(response.accountsInVestingPeriod.isEmpty(), 'No Accounts in vesting period should be returned');
	}

	@IsTest
	private static void testOneAccountNotInVestingPeriodAndTwoInVestingPeriod() {
		makeData();

		Account accNotInVestingPeriod = AccountSelector.getByCVR(TEST_CVR);

		Account accWithLead = TestDataFactory.createAccountWithCVR('12348765');
		insert accWithLead;
		TestDataFactory.createSalesPlayLeadsForAccounts(1, new List<Account>{accWithLead});

		Account accWithOpportunity = TestDataFactory.createAccountWithCVR('43215678');
		insert accWithOpportunity;
		TestDataFactory.createOpportunitiesForAccounts(1, new List<Account>{accWithOpportunity});

		SalesPlayManagementGetAccountsAction.Request request = new SalesPlayManagementGetAccountsAction.Request();
		request.amountOfMonthsForDateFilter = AMOUNT_OF_MONTHS_DATE_FILTER;
		request.accounts = new List<Account>{accNotInVestingPeriod, accWithLead, accWithOpportunity};

		Test.startTest();
		List<SalesPlayManagementGetAccountsAction.Response> responses = SalesPlayManagementGetAccountsAction.getAccountCollections(
			new List<SalesPlayManagementGetAccountsAction.Request>{request}
		);
		Test.stopTest();

		Assert.areEqual(1, responses.size(), 'One response should be returned');

		SalesPlayManagementGetAccountsAction.Response response = responses[0];
		Assert.areEqual(1, response.accountsNotInVestingPeriod.size(), 'One Account not in vesting period should be returned');
		Assert.areEqual(2, response.accountsInVestingPeriod.size(), 'Two Accounts in vesting period should be returned');
	}

	@IsTest
	private static void testAccountWithOpenAndClosedLostOpportunities() {
		makeData();

		Account acc = AccountSelector.getByCVR(TEST_CVR);
		List<Opportunity> opportunities = TestDataFactory.createOpportunitiesForAccounts(2, new List<Account>{acc});
		opportunities[0].StageName = 'Closed Lost';
		opportunities[0].Loss_Reason__c = 'Opgivet';
		update opportunities[0];

		SalesPlayManagementGetAccountsAction.Request request = new SalesPlayManagementGetAccountsAction.Request();
		request.amountOfMonthsForDateFilter = AMOUNT_OF_MONTHS_DATE_FILTER;
		request.accounts = new List<Account>{acc};

		Test.startTest();
		List<SalesPlayManagementGetAccountsAction.Response> responses = SalesPlayManagementGetAccountsAction.getAccountCollections(
			new List<SalesPlayManagementGetAccountsAction.Request>{request}
		);
		Test.stopTest();

		Assert.areEqual(1, responses.size(), 'One response should be returned');

		SalesPlayManagementGetAccountsAction.Response response = responses[0];
		Assert.isTrue(response.accountsNotInVestingPeriod.isEmpty(), 'No Account not in vesting period should be returned');
		Assert.areEqual(1, response.accountsInVestingPeriod.size(), 'One Account in vesting period should be returned');
		
		String vestingReason = response.accountsInVestingPeriod[0].Sales_Play_Vesting_Reason__c;
		Assert.isTrue(
			vestingReason.contains(SalesPlayManagementGetAccountsAction.VESTING_REASON_ACTIVE_OPPORTUNITY),
			'Vesting reason should contain active Opportunity text'
		);
		Assert.isTrue(
			vestingReason.contains(String.format(SalesPlayManagementGetAccountsAction.VESTING_REASON_OPPORTUNITY_LOST_N_MONTHS, FORMATTING_ARGUMENTS)),
			'Vesting reason should contain closed lost Opportunity text'
		);
	}

	@IsTest
	private static void testAccountWithOpenAndUnqualifiedLeads() {
		makeData();

		Account acc = AccountSelector.getByCVR(TEST_CVR);
		List<Lead> leads = TestDataFactory.createSalesPlayLeadsForAccounts(2, new List<Account>{acc});
		leads[0].Status = SalesPlayManagementGetAccountsAction.LEAD_STATUS_UNQUALIFIED;
		leads[0].Unqualified_Reason__c = Lead.Unqualified_Reason__c.getDescribe().getPicklistValues()[0].getValue();
		update leads[0];

		SalesPlayManagementGetAccountsAction.Request request = new SalesPlayManagementGetAccountsAction.Request();
		request.amountOfMonthsForDateFilter = AMOUNT_OF_MONTHS_DATE_FILTER;
		request.accounts = new List<Account>{acc};

		Test.startTest();
		List<SalesPlayManagementGetAccountsAction.Response> responses = SalesPlayManagementGetAccountsAction.getAccountCollections(
			new List<SalesPlayManagementGetAccountsAction.Request>{request}
		);
		Test.stopTest();

		Assert.areEqual(1, responses.size(), 'One response should be returned');

		SalesPlayManagementGetAccountsAction.Response response = responses[0];
		Assert.isTrue(response.accountsNotInVestingPeriod.isEmpty(), 'No Account not in vesting period should be returned');
		Assert.areEqual(1, response.accountsInVestingPeriod.size(), 'One Account in vesting period should be returned');
		String vestingReason = response.accountsInVestingPeriod[0].Sales_Play_Vesting_Reason__c;
		Assert.isTrue(
			vestingReason.contains(SalesPlayManagementGetAccountsAction.VESTING_REASON_OPEN_LEAD),
			'Vesting reason should contain open Lead text'
		);
		Assert.isTrue(
			vestingReason.contains(String.format(SalesPlayManagementGetAccountsAction.VESTING_REASON_LEAD_UNQUALIFIED_N_MONTHS, FORMATTING_ARGUMENTS)),
			'Vesting reason should contain unqualified Lead text'
		);
	}

	//TODO: khp fix unittest IMPORTANT FLOW INVOLVED
	// @IsTest
	// private static void testAccountWithQualifiedLeadAndClosedWonOpportunity() {
	// 	makeData();

	// 	Account acc = AccountSelector.getByCVR(TEST_CVR);
	// 	Lead lead = TestDataFactory.createSalesPlayLeadsForAccounts(1, new List<Account>{acc})[0];
	// 	lead.Status = SalesPlayManagementGetAccountsAction.LEAD_STATUS_QUALIFIED;
	// 	update lead;

	// 	Opportunity opp = TestDataFactory.createOpportunitiesForAccounts(1, new List<Account>{acc})[0];

	// 	SBQQ__Quote__c quote = TestDataFactory.createSingleQuote(acc.Id, opp.Id);
	// 	quote.SBQQ__StartDate__c = System.today().addDays(10);
	// 	insert quote;

	// 	TestDataFactory.createQuoteLineRecordsForQuote(1, new List<SBQQ__Quote__c>{quote}, 1, 1, false);

	// 	opp.SBQQ__PrimaryQuote__c = quote.Id;
	// 	opp.StageName = 'Closed Won';
	// 	update opp;

	// 	SalesPlayManagementGetAccountsAction.Request request = new SalesPlayManagementGetAccountsAction.Request();
	// 	request.amountOfMonthsForDateFilter = AMOUNT_OF_MONTHS_DATE_FILTER;
	// 	request.accounts = new List<Account>{acc};

	// 	Test.startTest();
	// 	List<SalesPlayManagementGetAccountsAction.Response> responses = SalesPlayManagementGetAccountsAction.getAccountCollections(
	// 		new List<SalesPlayManagementGetAccountsAction.Request>{request}
	// 	);
	// 	Test.stopTest();

	// 	Assert.areEqual(1, responses.size(), 'One response should be returned');

	// 	SalesPlayManagementGetAccountsAction.Response response = responses[0];
	// 	Assert.isTrue(response.accountsNotInVestingPeriod.isEmpty(), 'No Account not in vesting period should be returned');
	// 	Assert.areEqual(1, response.accountsInVestingPeriod.size(), 'One Account in vesting period should be returned');
	// 	String vestingReason = response.accountsInVestingPeriod[0].Sales_Play_Vesting_Reason__c;
	// 	Assert.isTrue(
	// 		vestingReason.contains(String.format(SalesPlayManagementGetAccountsAction.VESTING_REASON_LEAD_QUALIFIED_N_MONTHS, FORMATTING_ARGUMENTS)),
	// 		'Vesting reason should contain qualified Lead text'
	// 	);
	// 	Assert.isTrue(
	// 		vestingReason.contains(String.format(SalesPlayManagementGetAccountsAction.VESTING_REASON_OPPORTUNITY_WON_N_MONTHS, FORMATTING_ARGUMENTS)),
	// 		'Vesting reason should contain closed won Opportunity text'
	// 	);
	// }
}