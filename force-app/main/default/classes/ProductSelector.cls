public with sharing class ProductSelector {
	@AuraEnabled(cacheable=true)
	public static List<Product2> getBusinessInternetProducts() {
		return [SELECT Name, Id FROM Product2 WHERE IsActive = TRUE AND ProductCode IN ('37000', '37001') ORDER BY Name];
	}

	public static List<Product2> getAllActiveProductsOrderByName() {
		return [SELECT Name, Id, ProductAPI_Telia_Product_Id__c FROM Product2 WHERE IsActive = TRUE ORDER BY Name];
	}

	public static List<Product2> getValueAddedServiceProducts() {
		// Only used in Activation_check_details ?
		return [
			SELECT Name, Id, ProductAPI_Telia_Product_Id__c
			FROM Product2
			WHERE IsActive = TRUE AND activate_with_other_products__c = TRUE AND Requires_Activation_Check__c = TRUE
		];
	}

	public static List<Product2> getProductByPriceplanCode(String priceplanCode) {
		return [
			SELECT Name, Id, ProductAPI_Telia_Product_Id__c
			FROM Product2
			WHERE IsActive = TRUE AND ProductAPI_Telia_Product_Id__c = :priceplanCode
			LIMIT 1
		];
	}

	/**
	 * Get all products with the ProductAPI_Telia_Product_Id__c field populated
	 * @return list of products
	 */
	public static List<Product2> getAllProductsHavingTeliaProductId() {
		return [
			SELECT Id, Name, ProductAPI_Telia_Product_Id__c
			FROM Product2
			WHERE ProductAPI_Telia_Product_Id__c != NULL
			ORDER BY IsActive DESC, ProductAPI_Telia_Product_Id__c
		];
	}
}
