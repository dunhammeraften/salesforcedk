@IsTest
public with sharing class LocationLineSelectorTest {
	private static final String CVR = '12345678';

	@TestSetup
	static void makeData() {
		Account account = testDataFactory.createAccountWithCVR(CVR);
		insert account;
		List<Opportunity> listOfOpportunities = testDataFactory.createOpportunitiesForAccounts(1, new List<Account>{ account });
	}

	@IsTest
	static void testGetLocationLinesByIds() {
		Account account = AccountSelector.getByCVR(CVR);
		Opportunity opp = [SELECT Id FROM Opportunity WHERE AccountId = :account.Id LIMIT 1];

		Location_Line__c location = testDataFactory.createLocationLine('FIBHOF03');
		location.Opportunity__c = opp.Id;
		insert location;

		Test.startTest();
		Map<Id, Location_Line__c> locationsById = LocationLineSelector.getLocationLinesByIds(new List<Id>{ location.Id });
		Assert.isNotNull(locationsById);

		Test.stopTest();
	}

	@IsTest
	static void testGetValidLocationLinesByOpportunityId() {
		Account account = AccountSelector.getByCVR(CVR);
		Opportunity opp = [SELECT Id FROM Opportunity WHERE AccountId = :account.Id LIMIT 1];

		Location_Line__c location = testDataFactory.createLocationLine('FIBHOF03');
		location.Opportunity__c = opp.Id;
		insert location;

		Test.startTest();
		List<Location_Line__c> locationByOppId = LocationLineSelector.getValidLocationLinesByOpportunityId(opp.Id);
		Test.stopTest();
		Assert.isNotNull(locationByOppId);
	}

	/**
	 * Test that getValidLocationLinesByOpportunityIds() returns a list of Location_Line__c objects that has a Address_Wash_Status__c of 'Valid'
	 */
	@IsTest
	static void testGetValidLocationLinesByOpportunityIds() {
		Account account = AccountSelector.getByCVR(CVR);
		Opportunity opp = [SELECT Id FROM Opportunity WHERE AccountId = :account.Id LIMIT 1];

		List<Location_Line__c> testLocationLines = new List<Location_Line__c>();

		Location_Line__c location = TDF_LocationLineUtils.createLocationLine('FIBHOF03');
		location.Opportunity__c = opp.Id;
		location.Address_Wash_Status__c = LocationLineSelector.ADDRESS_WASH_STATUS_NOT_VALID;
		testLocationLines.add(location);

		Location_Line__c location2 = TDF_LocationLineUtils.createLocationLine('FIBHOF03');
		location2.Opportunity__c = opp.Id;
		testLocationLines.add(location2);

		insert testLocationLines;

		Test.startTest();

		List<Location_Line__c> locationLines = LocationLineSelector.getValidLocationLinesByOpportunityIds(new List<Id>{opp.Id});
		
		Test.stopTest();

		Assert.areEqual(1, locationLines.size(), 'Expected 1 Location Line');
		Assert.areEqual(opp.Id, locationLines[0].Opportunity__c, 'Opportunity Id is not matching on the Location Line');
		Assert.areEqual(LocationLineSelector.ADDRESS_WASH_STATUS_VALID, locationLines[0].Address_Wash_Status__c, 'Address Wash Status should be Valid');
	}

	@IsTest
	static void testGetLocationLinesByOpportunityId() {
		Account account = AccountSelector.getByCVR(CVR);
		Opportunity opp = [SELECT Id FROM Opportunity WHERE AccountId = :account.Id LIMIT 1];

		Location_Line__c location = testDataFactory.createLocationLine('FIBHOF03');
		location.Opportunity__c = opp.Id;
		insert location;

		Test.startTest();
		List<Location_Line__c> locationByOppId = LocationLineSelector.getLocationLinesByOpportunityId(opp.Id);
		Test.stopTest();
		Assert.isNotNull(locationByOppId);
	}

	@IsTest
	static void testGetLocationLinesByAccountId() {
		Account account = AccountSelector.getByCVR(CVR);
		Opportunity opp = [SELECT Id FROM Opportunity WHERE AccountId = :account.Id LIMIT 1];

		Location_Line__c location = testDataFactory.createLocationLine('FIBHOF03');
		location.Opportunity__c = opp.Id;
		insert location;

		Test.startTest();
		List<Location_Line__c> locationByOppId = LocationLineSelector.getLocationLinesByAccountId();
		Test.stopTest();
		Assert.isNotNull(locationByOppId);
	}
}