@IsTest
private class UpdateLocationLineTest {
	private static final String CVR = '23456789';

	private static List<String> productIds = new List<String>{
		'FIBHOF09',
		'FIBHOF08',
		'FIBHOF06',
		'FIBHOF05',
		'FIBHOF03',
		'FIBHOF02',
		'COAHOF03',
		'COAHOF02',
		'DSLHOF01'
	};

	@TestSetup
	static void makeData() {
		Account acct = testDataFactory.createCVRAccountWithBillingAddress(CVR);
		List<Opportunity> opportunities = testDataFactory.createOpportunitiesForAccounts(1, new List<Account>{ acct });

		List<Location_Line__c> locations = new List<Location_Line__c>();
		for (String productId : productIds) {
			Location_Line__c location = testDataFactory.createLocationLine(productId);
			location.Opportunity__c = opportunities.get(0).Id;
			locations.add(location);
		}
		insert locations;

		List<POQ_Item__c> poqItems = testDataFactory.createPOQItems(locations);
	}

	@IsTest
	private static void testFinalUpdate() {
		Account acc = AccountSelector.getByCVR(CVR);
		Opportunity opp = OpportunitySelector.getByAccountId(acc.Id);
		List<String> otcProducts = new List<String>();
		Map<Id, POQ_Item__c> itemsToUpdate = new Map<Id, POQ_Item__c>();
		Test.startTest();

		// Test when plugTechnicianRequired__c = true and DIGGING_NEEDED__c = false
		Map<Id, Location_Line__c> locations = new Map<Id, Location_Line__c>(
			[SELECT Id, Name, Subscription_product__c FROM Location_Line__c WHERE Opportunity__c = :opp.Id]
		);
		List<POQ_Item__c> poqItems = POQItemSelector.getPOQItemsByLocationIds(locations.keySet());
		for (POQ_Item__c item : poqItems) {
			item.plugTechnicianRequired__c = true;
			item.DIGGING_NEEDED__c = false;
			itemsToUpdate.put(item.Id, item);
		}
		update itemsToUpdate.values();
		UpdateLocationLines.finalUpdate(new List<Opportunity>{ opp });
		for (Location_Line__c line : [SELECT Id, OTC_product__c FROM Location_Line__c WHERE Opportunity__c = :opp.Id]) {
			otcProducts.add(line.OTC_product__c);
		}
		Assert.areEqual(9, otcProducts.size());

		// Test when plugTechnicianRequired__c = false and DIGGING_NEEDED__c = true
		itemsToUpdate.clear();
		otcProducts.clear();
		Map<Id, Location_Line__c> locations1 = new Map<Id, Location_Line__c>(
			[SELECT Id, Name, Subscription_product__c FROM Location_Line__c WHERE Opportunity__c = :opp.Id]
		);
		List<POQ_Item__c> poqItems1 = POQItemSelector.getPOQItemsByLocationIds(locations1.keySet());
		for (POQ_Item__c item : poqItems1) {
			item.plugTechnicianRequired__c = false;
			item.DIGGING_NEEDED__c = true;
			itemsToUpdate.put(item.Id, item);
		}
		update itemsToUpdate.values();
		UpdateLocationLines.finalUpdate(new List<Opportunity>{ opp });
		for (Location_Line__c line : [SELECT Id, OTC_product__c FROM Location_Line__c WHERE Opportunity__c = :opp.Id]) {
			otcProducts.add(line.OTC_product__c);
		}
		Assert.areEqual(9, otcProducts.size());

		// Test when plugTechnicianRequired__c = true and DIGGING_NEEDED__c = true
		itemsToUpdate.clear();
		otcProducts.clear();
		Map<Id, Location_Line__c> locations2 = new Map<Id, Location_Line__c>(
			[SELECT Id, Name, Subscription_product__c FROM Location_Line__c WHERE Opportunity__c = :opp.Id]
		);
		List<POQ_Item__c> poqItems2 = POQItemSelector.getPOQItemsByLocationIds(locations2.keySet());
		for (POQ_Item__c item : poqItems2) {
			item.plugTechnicianRequired__c = true;
			item.DIGGING_NEEDED__c = true;
			itemsToUpdate.put(item.Id, item);
		}
		update itemsToUpdate.values();
		UpdateLocationLines.finalUpdate(new List<Opportunity>{ opp });
		for (Location_Line__c line : [SELECT Id, OTC_product__c FROM Location_Line__c WHERE Opportunity__c = :opp.Id]) {
			otcProducts.add(line.OTC_product__c);
		}
		Assert.areEqual(9, otcProducts.size());

		Test.stopTest();
	}
}