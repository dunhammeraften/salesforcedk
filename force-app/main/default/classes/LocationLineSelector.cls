public without sharing class LocationLineSelector {
	private static final String ERROR_ORIGIN = 'Apex';
	private static final String ERROR_ADDITIONAL_INFO = 'LocationLineSelector';
	public static final String ADDRESS_WASH_STATUS_VALID = 'Valid';
	public static final String ADDRESS_WASH_STATUS_NOT_VALID = 'Not Valid';

	private static ErrorLogging errorLogging = new ErrorLogging(ERROR_ORIGIN);

	@AuraEnabled(cacheable=true)
	public static List<Location_Line__c> getLocationLinesByAccountId() {
		return [
			SELECT Name, Id, Employee_ID__c, Street_Name__c, Number__c, Floor__c, Door__c, City__c, ZIP_Code__c
			FROM Location_Line__c
			// WHERE  Address_Line__c.Case__c =:accountId AND Not_to_Activation__c = false
		];
	}

	@AuraEnabled(cacheable=true)
	public static List<Location_Line__c> getLocationLinesByOpportunityId(String oppId) {
		return [
			SELECT
				Name,
				Id,
				Employee_ID__c,
				Street_Name__c,
				Number__c,
				Floor__c,
				Door__c,
				City__c,
				ZIP_Code__c,
				Address__c,
				OTC_product__c,
				Subscription_product__c,
				plugPresentPositiveValidation__c,
				Plug_Technician_Required__c,
				Active_Blocking_Line_Present__c
			FROM Location_Line__c
			WHERE Opportunity__c = :oppId
		];
	}

	@AuraEnabled(cacheable=true)
	public static List<Location_Line__c> getValidLocationLinesByOpportunityId(String oppId) {
		return [
			SELECT Name, Id, Employee_ID__c, Street_Name__c, Number__c, Floor__c, Door__c, City__c, ZIP_Code__c, Address__c
			FROM Location_Line__c
			WHERE Opportunity__c = :oppId AND Address_Wash_Status__c = 'Valid'
		];
	}

	/**
	 * Get all valid location lines by opportunity ids
	 * @param oppIdList
	 * @return List<Location_Line__c>
	 */
	public static List<Location_Line__c> getValidLocationLinesByOpportunityIds(List<Id> oppIdList) {
		return [
			SELECT 
				Id,
				Name,
				Active_Blocking_Line_Present__c,
				Address__c,
				Address_Wash_Status__c,
				City__c,
				Door__c,
				Employee_ID__c,
				Floor__c,
				Municipality_Code__c,
				Number__c,
				Opportunity__c,
				OTC_product__c,
				Plug_Technician_Required__c,
				plugPresentPositiveValidation__c,
				Quote_Line__c,
				Street_Code__c,
				Street_Name__c,
				Subscription_product__c,
				VAS_product__c,
				ZIP_Code__c
			FROM Location_Line__c
			WHERE Opportunity__c IN :oppIdList 
			AND Address_Wash_Status__c = :ADDRESS_WASH_STATUS_VALID
		];
	}

	@AuraEnabled(cacheable=true)
	public static Map<Id, Location_Line__c> getLocationLinesByIds(List<Id> locationLineIds) {
		return new Map<Id, Location_Line__c>(
			[
				SELECT
					Name,
					Id,
					Employee_ID__c,
					Street_Name__c,
					Number__c,
					Floor__c,
					Door__c,
					City__c,
					ZIP_Code__c,
					Address__c,
					VAS_product__c,
					Subscription_product__c,
					OTC_product__c,
					AddressRefId__c,
					SiteId__c,
					lineConnectionStatus__c,
					lineProvider__c,
					VendorProductCode__c,
					VendorProductCatalogId__c
				FROM Location_Line__c
				WHERE Id IN :locationLineIds
			]
		);
	}
}