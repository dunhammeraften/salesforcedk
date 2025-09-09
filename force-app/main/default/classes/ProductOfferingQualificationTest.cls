@isTest
private class ProductOfferingQualificationTest {
	@testSetup
	static void setup() {
		POQ_batch_chunks__c chunkValues = new POQ_batch_chunks__c();
		chunkValues.Full_Qualification_Batch_Size__c = 50;
		chunkValues.Basic_Qualification_Batch_Size__c = 5;
		insert chunkValues;
		Account acc = new Account(
				Name = 'Test Account POQ',
				Rationale__c = 'Testing'
		);
		insert acc;
	
		Opportunity opp = new Opportunity();
		opp.Name = 'Test Opportunity POQ';
		opp.StageName = 'Qualification';
		opp.CloseDate = Date.newInstance(2024, 12, 31);
		opp.AccountId = acc.Id;
		insert opp;
		System.debug(opp);

		Location_Line__c ll = new Location_Line__c();
		ll.Opportunity__c = opp.Id;
		ll.Street_Name__c = 'Risbystræde';
		ll.Number__c = '19';
		ll.ZIP_Code__c = '2620';
		ll.City__c = 'Albertslund';

		insert ll;
		System.debug(ll);

		Product2 p = new Product2();
		p.ProductAPI_Telia_Product_Id__c = 'FIBHOF02';
		p.ProductCode = '330';
		p.Name = 'Test Product';

		insert p;
		System.debug(p);

		Case c = new Case(
			Subject = 'TestCase'
		);
		insert c;
		Activation__c a = new Activation__c(
			Name = 'TestActivation',
			Case__c = c.Id
		);
		insert a;
		
		Activation_line__c  al = new Activation_line__c();
		al.Street_Name__c = 'street';
		al.Number__c = '1';
		al.ZIP_Code__c = '1000';
		al.Floor__c = '';
		al.Door__c = '';
		al.Activation__c = a.Id;
		al.Case__c = c.Id;
		insert al;
	}

	@IsTest
	private static void testMainWithFullQualification() {
		Opportunity opp = [SELECT Id FROM Opportunity WHERE Name = 'Test Opportunity POQ' LIMIT 1];
		Location_Line__c line = [
			SELECT
				Address__c,
				Street_Name__c,
				Opportunity__c,
				Number__c,
				Floor__c,
				Door__c,
				City__c,
				ZIP_Code__c,
				POQ_ProductOfferingId__c,
				POQ_ProductOfferingQualificationItemId__c
			FROM Location_Line__c
			WHERE Opportunity__c = :opp.Id
			LIMIT 1
		];
		line.POQ_ProductOfferingId__c = '12345';
		line.POQ_ProductOfferingQualificationItemId__c = '12345';
		update line;

		POQ_Item__c poqItem = new POQ_Item__c(
			Name = 'HomeOffice Fiber B 300 Mbit/s',
			Location_Line__c = line.Id,
			DIGGING_NEEDED__c = true,
			NETWORK_PROVIDER_NOT_SUPPORTED__c = false,
			NEW_ROUTER_NEEDED__c = false,
			NOT_SALEABLE__c = false,
			Pseudo_Product__c = 'Fiber 300',
			Rank__c = 400,
			plugPresentPositiveValidation__c = true,
			plugTechnicianRequired__c = false,
			priceplanCode__c = 'FIBHOF05',
			Active_Blocking_Line_Present__c = false
		);
		insert poqItem;

		List<Location_Line__c> innerList = new List<Location_Line__c>();
		innerList.add(line);
		List<List<Location_Line__c>> outerList = new List<List<Location_Line__c>>();
		outerList.add(innerList);

		Test.startTest();

		Test.setMock(HttpCalloutMock.class, new AuthorizationWrapperMock());
		Test.setMock(HttpCalloutMock.class, new ProductOfferingQualificationMock());

		ProductOfferingQualification.qualifyProducts(outerList);
		Test.stopTest();
	}

	@isTest
	static void callThePOQTest() {
		Opportunity opp = [SELECT Id FROM Opportunity WHERE Name = 'Test Opportunity POQ' LIMIT 1];
		Case c = new Case(
			Subject = 'TestCase'
		);
		insert c;
		Activation__c a = new Activation__c(
			Name = 'TestActivation',
			Case__c = c.Id
		);
		insert a;
		Activation_line__c al = new Activation_line__c(
			Activation__c = a.Id,
			Number__c = '1'
		);
		insert al;
		Location_Line__c line = [
			SELECT
				Address__c,
				Street_Name__c,
				Opportunity__c,
				Id,
				Number__c,
				Floor__c,
				Door__c,
				City__c,
				ZIP_Code__c,
				POQ_ProductOfferingId__c,
				POQ_ProductOfferingQualificationItemId__c
			FROM Location_Line__c
			WHERE Opportunity__c = :opp.Id
			LIMIT 1
		];
		POQ_Item__c poqItem = new POQ_Item__c(
			Name = 'HomeOffice Fiber B 300 Mbit/s',
			Location_Line__c = line.Id,
			DIGGING_NEEDED__c = true,
			NETWORK_PROVIDER_NOT_SUPPORTED__c = false,
			NEW_ROUTER_NEEDED__c = false,
			NOT_SALEABLE__c = false,
			Pseudo_Product__c = 'Fiber 300',
			Rank__c = 400,
			plugPresentPositiveValidation__c = true,
			plugTechnicianRequired__c = false,
			priceplanCode__c = 'FIBHOF05',
			Active_Blocking_Line_Present__c = false
		);
		insert poqItem;
		List<Location_Line__c> innerList = new List<Location_Line__c>();
		innerList.add(line);
		List<List<Location_Line__c>> outerList = new List<List<Location_Line__c>>();
		outerList.add(innerList);

		Test.startTest();

		Test.setMock(HttpCalloutMock.class, new AuthorizationWrapperMock());
		Test.setMock(HttpCalloutMock.class, new ProductOfferingQualificationMock());

		ProductOfferingQualification.main(outerList, true);

		Test.stopTest();
	}

	@isTest
	static void testException() {
		Opportunity opp = [SELECT Id FROM Opportunity WHERE Name = 'Test Opportunity POQ' LIMIT 1];
		Location_Line__c line = [
			SELECT
				Address__c,
				Street_Name__c,
				Opportunity__c,
				Id,
				Number__c,
				Floor__c,
				Door__c,
				City__c,
				ZIP_Code__c,
				POQ_ProductOfferingId__c,
				POQ_ProductOfferingQualificationItemId__c
			FROM Location_Line__c
			WHERE Opportunity__c = :opp.Id
			LIMIT 1
		];
		List<Location_Line__c> innerList = new List<Location_Line__c>();
		innerList.add(line);
		List<List<Location_Line__c>> outerList = new List<List<Location_Line__c>>();
		outerList.add(innerList);

		Test.startTest();

		ProductOfferingQualification.main(outerList, true);

		Test.stopTest();
	}

	@IsTest
	static void testCreatePOQItem() {
		// Create a sample ProductOfferingQualificationItem
		ProductOfferingQualification.ProductOfferingQualificationItem item = new ProductOfferingQualification.ProductOfferingQualificationItem();
		item.productOffering = new ProductOfferingQualification.ProductOffering();
		item.productOffering.name = 'Sample Product';
		item.productOffering.priceplanCode = '12345';

		// Specify a location line ID
		Location_Line__c line = [SELECT id FROM Location_Line__c WHERE Street_Name__c = 'Risbystræde'];

		// Call the method being tested
		POQ_Item__c result = ProductOfferingQualification.createPOQItem(item, line.id);

		// Assert the expected values
		System.assertEquals('Sample Product', result.Name);
		System.assertEquals('12345', result.priceplanCode__c);
		System.assertEquals(line.id, result.Location_Line__c);
		System.assertEquals('Noname', result.Pseudo_Product__c);
		System.assertEquals('Noname', result.Pseudo_Product_DA__c);
	}

	@IsTest
	static void testUpdatePOQItemWithNotes() {
		// Create a sample POQ_Item__c record
		POQ_Item__c poqItem = new POQ_Item__c();

		// Create sample Note records
		ProductOfferingQualification.Note note1 = new ProductOfferingQualification.Note();
		note1.type = 'ConsequenceNote';
		note1.code = 'NEW_ROUTER_NEEDED';

		ProductOfferingQualification.Note note2 = new ProductOfferingQualification.Note();
		note2.type = 'LineAttributesNote';

		List<ProductOfferingQualification.Note> notes = new List<ProductOfferingQualification.Note>{ note1, note2 };

		// Call the method being tested
		ProductOfferingQualification.updatePOQItemWithNotes(poqItem, notes);

		// Assert the expected values
		System.assertEquals(true, poqItem.NEW_ROUTER_NEEDED__c);
		// Assert other values based on your implementation of updateLineAttributes method
	}

	@IsTest
	static void testSleep() {
		// Set up
		Integer millisecondsToWait = 1000; // Change this value as needed

		// Call the method under test
		Test.startTest();
		ProductOfferingQualification.sleep(millisecondsToWait);
		Test.stopTest();

		// Verify
		// Add your verification assertions here, if applicable
	}

	@IsTest
	static void testGetLocationLineIds() {
		// Set up
		List<Location_Line__c> locationLines = [SELECT id FROM Location_Line__c WHERE Street_Name__c = 'Risbystræde'];
		// Create Location_Line__c records and add them to the list

		// Call the method under test
		List<Id> result = ProductOfferingQualification.getLocationLineIds(locationLines);

		// Verify
		System.assertEquals(locationLines.size(), result.size(), 'Size of result should match the size of input list');

		Set<Id> expectedIds = new Set<Id>();
		for (Location_Line__c line : locationLines) {
			expectedIds.add(line.Id);
		}

		Set<Id> actualIds = new Set<Id>(result);
		System.assertEquals(expectedIds, actualIds, 'Returned Ids should match the Ids of input list');
	}

	@IsTest
	static void testUpdateAddressStatus() {
		// Set up
		List<ProductOfferingQualification.POQres> resList = new List<ProductOfferingQualification.POQres>();
		// Create POQres records and add them to the resList

		List<Location_Line__c> locationLines = new List<Location_Line__c>();
		// Create Location_Line__c records and add them to the locationLines list

		// Associate POQres records with Location_Line__c records by setting the appropriate id values

		ProductOfferingQualification.POQresBatch batch = new ProductOfferingQualification.POQresBatch();
		batch.batch = resList;

		// Call the method under test
		Test.startTest();
		List<Location_Line__c> result = ProductOfferingQualification.enrichAddresses(batch);
		Test.stopTest();

		// Verify
		System.assertEquals(locationLines.size(), result.size(), 'Size of result should match the size of input list');

		Map<String, String> expectedStatuses = new Map<String, String>();
		for (ProductOfferingQualification.POQres res : resList) {
			String code = res.code == null ? null : res.code;
			String locationLineId = res.id == null ? null : res.id;

			if (code == 'SERVICE_LOCATION_NOT_FOUND') {
				expectedStatuses.put(locationLineId, 'Not Valid');
			} else {
				expectedStatuses.put(locationLineId, 'Valid');
			}
		}

		for (Location_Line__c line : result) {
			String expectedStatus = expectedStatuses.get(line.Id);
			System.assertEquals(expectedStatus, line.Address_Wash_Status__c, 'Address wash status should match the expected value');
		}
	}

	@isTest
	static void testUpdatePOQItemWithEligibilityReasons() {
		// Create a test POQ_Item__c record
		POQ_Item__c poqItem = new POQ_Item__c();

		// Create a list of eligibilityUnavailabilityReasons
		List<ProductOfferingQualification.eligibilityUnavailabilityReason> reasons = new List<ProductOfferingQualification.eligibilityUnavailabilityReason>();

		// Add a reason with code 'NETWORK_PROVIDER_NOT_SUPPORTED'
		ProductOfferingQualification.eligibilityUnavailabilityReason reason1 = new ProductOfferingQualification.eligibilityUnavailabilityReason();
		reason1.code = 'NETWORK_PROVIDER_NOT_SUPPORTED';
		reasons.add(reason1);

		// Add a reason with code 'NOT_SALEABLE'
		ProductOfferingQualification.eligibilityUnavailabilityReason reason2 = new ProductOfferingQualification.eligibilityUnavailabilityReason();
		reason2.code = 'NOT_SALEABLE';
		reasons.add(reason2);

		// Call the method to update the POQ_Item__c record
		ProductOfferingQualification.updatePOQItemWithEligibilityReasons(poqItem, reasons);

		// Assert that the fields have been updated correctly
		System.assertEquals(true, poqItem.NETWORK_PROVIDER_NOT_SUPPORTED__c);
		System.assertEquals(true, poqItem.NOT_SALEABLE__c);
	}

	@isTest
	static void testNullCleaning() {
		String input = null;

		Test.startTest();
		String cleanHouseNumberResult = ProductOfferingQualification.cleanHouseNumber(input);
		String cleanFloorResult = ProductOfferingQualification.cleanFloor(input);
		String cleanHouseLetterResult = ProductOfferingQualification.cleanHouseLetter(input);
		Test.stopTest();

		System.assertEquals(null, cleanHouseNumberResult, 'HouseNumber not null');
		System.assertEquals(null, cleanFloorResult, 'Floor not null');
		System.assertEquals(null, cleanHouseLetterResult, 'HouseLetter not null');
	}

	@isTest
	static void testActivationLineQualification() {
		Activation__c a = [SELECT id FROM Activation__c WHERE Name = 'TestActivation'];
		List<Id> activationIds = new List<Id>();
		activationIds.add(a.Id);

		Test.startTest();
		ProductOfferingQualification.activationLineQualification(activationIds);
		Test.stopTest();
	}
}