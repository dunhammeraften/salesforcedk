/**
 * 
 * @author keh
 * @since 10032025
 */
@isTest
private class HomeOfficeControllerTest {

	private static final String TEST_CVR = '12345678';

	/**
	 * setup
	 */
	@testSetup
	static void setup() {
		Profile prof = ProfileSelector.getProfileByProfileName(ProfileConstants.SYSTEM_ADMINISTRATOR);
		User usr = testDataFactory.createUser('standt', prof.Id);

		Account acc = TDF_AccountUtils.createAccountWithCVR(TEST_CVR);
        acc.Status__c = 'Active';
		acc.OwnerId = usr.Id;
        insert acc;

		Opportunity opp = new Opportunity();
		opp.Name = 'Testclass Opportunity';
		opp.StageName = 'Needs Analysis';
		opp.Agreement_Type__c = 'Framework';
		opp.Product_s_in_scope__c = 'Home Office';
		opp.CloseDate = Date.newInstance(2024, 12, 31);
		opp.AccountId = acc.Id;
		insert opp;

		Location_Line__c ll = new Location_Line__c();
		ll.Opportunity__c = opp.Id;
		ll.Street_Name__c = 'Risbystræde';
		ll.Number__c = '19';
		ll.ZIP_Code__c = '2620';
		ll.City__c = 'Albertslund';
		ll.Subscription_product__c = 'FIBHOF03';
		insert ll;

		Location_Line__c ll1 = new Location_Line__c();
		ll1.Opportunity__c = opp.Id;
		ll1.Street_Name__c = 'Fiskefjæs';
		ll1.Number__c = '19';
		ll1.ZIP_Code__c = '2620';
		ll1.City__c = 'Albertslund';
		ll1.Subscription_product__c = 'FIBHOF09';
		insert ll1;

		Location_Line__c ll2 = new Location_Line__c();
		ll2.Opportunity__c = opp.Id;
		ll2.Street_Name__c = 'Berlingo';
		ll2.Number__c = '19';
		ll2.ZIP_Code__c = '2620';
		ll2.City__c = 'Albertslund';
		ll2.Subscription_product__c = 'FIBHOF06';
		insert ll2;

		POQ_item__c pi1 = new POQ_item__c();
		pi1.DIGGING_NEEDED__c = true;
		pi1.priceplanCode__c = 'FIBHOF03';
		pi1.Location_Line__c = ll.Id;
		insert pi1;

		POQ_item__c pi2 = new POQ_item__c();
		pi2.DIGGING_NEEDED__c = false;
		pi2.priceplanCode__c = 'FIBHOF06';
		pi2.Location_Line__c = ll.Id;
		insert pi2;

		POQ_item__c pi3 = new POQ_item__c();
		pi3.DIGGING_NEEDED__c = true;
		pi3.priceplanCode__c = 'FIBHOF09';
		pi3.Location_Line__c = ll.Id;
		insert pi3;

		POQ_item__c pi4 = new POQ_item__c();
		pi4.DIGGING_NEEDED__c = true;
		pi4.priceplanCode__c = 'FIBHOF09';
		pi4.Location_Line__c = ll1.Id;
		insert pi4;

		POQ_item__c pi5 = new POQ_item__c();
		pi5.DIGGING_NEEDED__c = true;
		pi5.priceplanCode__c = 'FIBHOF06';
		pi5.Location_Line__c = ll2.Id;
		insert pi5;
	}

	/**
	 * updateProduct_validInput_changesSubscriptionProduct
	 */
	@isTest
	static void updateProduct_validInput_changesSubscriptionProduct() {
		//ARRANGE
		List<Location_Line__c> ll = [SELECT Id, Subscription_product__c FROM Location_Line__c WHERE Street_Name__c = 'Risbystræde' LIMIT 1];

		//ACT
		HomeOfficeController.updateProduct(ll[0].Id, 'FIBHOF03');
		HomeOfficeController.updateProduct(ll[0].Id, 'FIBHOF06');
		HomeOfficeController.updateProduct(ll[0].Id, 'FIBHOF09');
		ll = [SELECT Id, Subscription_product__c FROM Location_Line__c WHERE Street_Name__c = 'Risbystræde' LIMIT 1];
		
		//ASSERT
		System.assertEquals('FIBHOF09', ll[0].Subscription_product__c);
	
	}

	/**
	 * updateVas_nonStaticIp_setsVasProductToNull
	 */
	@isTest
	static void updateVas_nonStaticIp_setsVasProductToNull() {
		//ARRANGE
		List<Location_Line__c> ll = [SELECT Id FROM Location_Line__c WHERE Street_Name__c = 'Risbystræde' LIMIT 1];

		//ACT
		HomeOfficeController.updateVAS(ll[0].Id, false);
		ll = [SELECT Id, VAS_product__c FROM Location_Line__c WHERE Street_Name__c = 'Risbystræde' LIMIT 1];

		//ASSERT
		System.Assert.areEqual(null, ll[0].VAS_Product__c);


	}

	/**
	 * updateVas_staticIp_setsVasProductToFASTIP
	 */
	@isTest
	static void updateVas_staticIp_setsVasProductToFASTIP() {
		//ARRANGE
		List<Location_Line__c> ll = [SELECT Id FROM Location_Line__c WHERE Street_Name__c = 'Risbystræde' LIMIT 1];

		//ACT
		HomeOfficeController.updateVAS(ll[0].Id, true);
		ll = [SELECT Id, VAS_product__c FROM Location_Line__c WHERE Street_Name__c = 'Risbystræde' LIMIT 1];

		//ASSERT
		System.Assert.areEqual('FASTIP', ll[0].VAS_Product__c);
	}
}