public with sharing class POQItemSelector {
	public static List<POQ_Item__c> getPOQItemsByLocationIds(Set<Id> locationIds) {
		return [
			SELECT
				Id,
				DIGGING_NEEDED__c,
				Location_Line__c,
				priceplanCode__c,
				plugPresentPositiveValidation__c,
				plugTechnicianRequired__c,
				Active_Blocking_Line_Present__c
			FROM POQ_Item__c
			WHERE Location_Line__c IN :locationIds
		];
	}
}