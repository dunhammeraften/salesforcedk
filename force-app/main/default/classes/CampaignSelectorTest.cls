/**
 * 
 * @author 
 * @since 
 */
@IsTest
public with sharing class CampaignSelectorTest {
	
	/**
	 * makeData
	 */
	@TestSetup
	static void makeData() {
		List<Fokus_Campaign__c> campaigns = new List<Fokus_Campaign__c>();
		Fokus_Campaign__c campaign1 = new Fokus_Campaign__c(
			Campaign_Id__c = 'FI06HOF03',
			Campaign_Value__c = 0,
			Product_Id__c = 'FIBHOF03',
			Product_Campaign_Composite_Key__c = 'FIBHOF03.FI06HOF03'
		);
		campaigns.add(campaign1);

		Fokus_Campaign__c campaign2 = new Fokus_Campaign__c(
			Campaign_Id__c = 'FI06HOF02',
			Campaign_Value__c = 0,
			Product_Id__c = 'FIBHOF02',
			Product_Campaign_Composite_Key__c = 'FIBHOF02.FI06HOF02'
		);
		campaigns.add(campaign2);
		insert campaigns;
	}

	/**
	 * getCampaignByProductId_invalidCampaignId_returnsNull
	 */
	@IsTest
	static void getCampaignByProductId_invalidCampaignId_returnsNull() {
		//ARRANGE
				
		//ACT
		Test.startTest();
		Fokus_Campaign__c noCampaign = CampaignSelector.getCampaignByProductId('Test');
		Test.stopTest();

		//ASSERT
		Assert.isNull(noCampaign);
	}

	/**
	 * getCampaignByProductId_validCampaignId_returnsCampaign
	 */
	@IsTest
	static void getCampaignByProductId_validCampaignId_returnsCampaign() {
		//ARRANGE
		
		//ACT
		Test.startTest();
		Fokus_Campaign__c hasCampaign = CampaignSelector.getCampaignByProductId('FIBHOF03');
		Test.stopTest();

		//ASSERT
		Assert.isNotNull(hasCampaign);
	}

	/**
	 * getCampaignsByProductIds_validIds_returnsMapOfCampaigns
	 */
	@IsTest
	static void getCampaignsByProductIds_validIds_returnsMapOfCampaigns() {
		//ARRANGE
		List<String> productIds = new List<String>{ 'FIBHOF03', 'FIBHOF02' };

		//ACT
		Test.startTest();
		Map<String, Fokus_Campaign__c> campaigns = CampaignSelector.getCampaignsByProductIds(productIds);
		Test.stopTest();

		//ASSERT
		Assert.isTrue(campaigns.size() > 0);
	}
}