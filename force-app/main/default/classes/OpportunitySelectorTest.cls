@IsTest
private with sharing class OpportunitySelectorTest {
	private static final String CVR = '23232323';

	@TestSetup
	private static void makeData() {
		Account acc = TestDataFactory.createAccountWithCVR(CVR);
		insert acc;
	}

	@IsTest
	private static void testGetById() {
		Account acc = AccountSelector.getByCVR(CVR);

		Opportunity opp1 = new Opportunity(
			Name = 'Opp1',
			StageName = 'Needs Analysis',
			AccountId = acc.Id,
			Agreement_Type__c = 'Specified',
			Product_s_in_scope__c = 'Home Office',
			CloseDate = Date.today() + 30
		);
		insert opp1;

		Test.startTest();
		Opportunity oppById = OpportunitySelector.getById(opp1.Id);
		Test.stopTest();

		Assert.areEqual('Opp1', oppById.Name, 'Opportunity Name should match');
	}

	@IsTest
	private static void testGetHomeOfficeOppByOppContactRoleAndContact() {
		Account acc = AccountSelector.getByCVR(CVR);

		Contact contct = new Contact(LastName = 'LastName', FirstName = 'FirstName', Email = 'contact@email.com', AccountId = acc.Id);
		insert contct;

		Opportunity opp1 = new Opportunity(
			Name = 'Opp1',
			StageName = 'Needs Analysis',
			AccountId = acc.Id,
			ContactId = contct.Id,
			Agreement_Type__c = 'Specified',
			Product_s_in_scope__c = 'Home Office',
			CloseDate = Date.today() + 30
		);
		insert opp1;

		OpportunityContactRole opCtRole = new OpportunityContactRole();
		opCtRole.OpportunityId = opp1.Id;
		opCtRole.Contactid = contct.Id;
		opCtRole.Role = 'Sales Contact';
		insert opCtRole;

		Test.startTest();
		Opportunity opp = OpportunitySelector.getHomeOfficeOppByOppContactRoleAndContact(contct.Id);
		Test.stopTest();

		Assert.isNotNull(opp, 'An opportunity should be returned');
	}

	@IsTest
	private static void testGetByAccountId() {
		Account acc = AccountSelector.getByCVR(CVR);

		Opportunity opp1 = new Opportunity(
			Name = 'Opp1',
			StageName = 'Needs Analysis',
			AccountId = acc.Id,
			Agreement_Type__c = 'Specified',
			Product_s_in_scope__c = 'Home Office',
			CloseDate = Date.today() + 30
		);
		insert opp1;

		Test.startTest();
		Opportunity opp = OpportunitySelector.getByAccountId(acc.Id);
		Test.stopTest();

		Assert.isNotNull(opp, 'An opportunity should be returned');
	}

	@IsTest
	private static void testGetOrderedOpenOrClosedOpportunitiesByAccountsAndCloseDate() {
		Account acc = AccountSelector.getByCVR(CVR);

		List<Opportunity> opportunities = TestDataFactory.createOpportunitiesForAccounts(2, new List<Account>{acc});
		opportunities[0].StageName = 'Closed Lost';
		opportunities[0].Loss_Reason__c = 'Opgivet';
		update opportunities[0];

		Test.startTest();
		List<Opportunity> orderedOpportunities = OpportunitySelector.getOrderedOpenOrClosedOpportunitiesByAccountsAndCloseDate(
			new List<Account>{acc},
			System.today().addDays(-180)
		);
		Test.stopTest();

		Assert.areEqual(2, orderedOpportunities.size(), '2 Opportunities should be returned');
	}
}