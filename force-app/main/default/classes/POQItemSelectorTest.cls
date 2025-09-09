@IsTest
private class POQItemSelectorTest {
	private static final String CVR = '23456789';

	@TestSetup
	static void makeData() {
		Account acct = testDataFactory.createCVRAccountWithBillingAddress(CVR);
		List<Opportunity> opportunities = testDataFactory.createOpportunitiesForAccounts(1, new List<Account>{ acct });
		Location_Line__c location = testDataFactory.createLocationLine('FIBHOF02');
		location.Opportunity__c = opportunities.get(0).Id;
		insert location;
		List<POQ_Item__c> poqItems = testDataFactory.createPOQItems(new List<Location_Line__c>{ location });
	}

	@IsTest
	private static void testGetPOQItemsByLocationIds() {
		Location_Line__c line = [SELECT Id FROM Location_Line__c WHERE Subscription_product__c = 'FIBHOF02' LIMIT 1];

		Test.startTest();

		List<POQ_Item__c> items = POQItemSelector.getPOQItemsByLocationIds(new Set<Id>{ line.Id });

		Test.stopTest();

		Assert.isTrue(items.size() > 0);
	}
}