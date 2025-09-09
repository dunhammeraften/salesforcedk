public with sharing class CampaignSelector {
	private static final String ERROR_ORIGIN = 'Apex';
	private static final String ERROR_ADDITIONAL_INFO = 'CampaignSelector';

	private static ErrorLogging errorLogging = new ErrorLogging(ERROR_ORIGIN);

	@auraenabled(cacheable=true)
	public static Fokus_Campaign__c getCampaignByProductId(String productId) {
		Fokus_Campaign__c[] campaigns = [
			SELECT Id, Campaign_Id__c, Campaign_Value__c, Product_Id__c
			FROM Fokus_Campaign__c
			WHERE Product_Id__c = :productId
		];

		if (campaigns.size() > 0) {
			return campaigns.get(0);
		}
		return null;
	}

	public static Map<String, Fokus_Campaign__c> getCampaignsByProductIds(List<String> productIds) {
		Map<String, Fokus_Campaign__c> campaingsByProductIds = new Map<String, Fokus_Campaign__c>();
		List<Fokus_Campaign__c> campaigns = [
			SELECT Id, Campaign_Id__c, Campaign_Value__c, Product_Id__c
			FROM Fokus_Campaign__c
			WHERE Product_Id__c IN :productIds
		];

		for(Fokus_Campaign__c campaign: campaigns) {
			campaingsByProductIds.put(campaign.Product_Id__c, campaign);
		}
		return campaingsByProductIds;
	}
}