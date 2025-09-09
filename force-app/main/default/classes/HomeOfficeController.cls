public without sharing class HomeOfficeController {
	@AuraEnabled
	public static void updateProduct(String locationLine, String productCode) {
		Location_Line__c line = [
			SELECT Id, Subscription_product__c, OTC_product__c, VAS_product__c, POQ_ProductOfferingId__c, POQ_ProductOfferingQualificationItemId__c
			FROM Location_Line__c
			WHERE Id = :locationLine
			LIMIT 1
		];

		POQ_item__c item = [
			SELECT Id, ProductOfferingId__c, ProductOfferingQualificationItemId__c
			FROM POQ_Item__c
			WHERE priceplanCode__c = :productCode AND Location_Line__c = :line.Id
			LIMIT 1
		];

		line.OTC_product__c = null;

		line.POQ_ProductOfferingId__c = item.ProductOfferingId__c;

		line.POQ_ProductOfferingQualificationItemId__c = item.ProductOfferingQualificationItemId__c;

		line.Subscription_product__c = productCode;

		line.VAS_product__c = null;

		System.debug('line = ' + line);

		update line;
	}

	@AuraEnabled
	public static void updateVAS(String locationLine, Boolean staticIP) {
		Location_Line__c line = [SELECT Id, VAS_product__c FROM Location_Line__c WHERE Id = :locationLine LIMIT 1];

		line.VAS_product__c = null;

		if (staticIP == true) {
			line.VAS_product__c = 'FASTIP';
		}

		update line;
	}
}