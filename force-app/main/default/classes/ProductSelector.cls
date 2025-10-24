public with sharing class ProductSelector {
	@AuraEnabled(cacheable=true)
	public static List<Product2> getBusinessInternetProducts() {
		return new Query('Product2')
			.selectFields('Name, Id')
			.addConditionEq('IsActive', true)
			.addConditionIn('ProductCode', new List<String>{ '37000', '37001' })
			.orderBy('Name')
			.run();
	}

	public static List<Product2> getAllActiveProductsOrderByName() {
		return new Query('Product2')
			.selectFields('Name, Id, ProductAPI_Telia_Product_Id__c')
			.addConditionEq('IsActive', true)
			.orderBy('Name')
			.run();
	}

	public static List<Product2> getValueAddedServiceProducts() {
		// Only used in Activation_check_details ?
		return new Query('Product2')
			.selectFields('Name, Id, ProductAPI_Telia_Product_Id__c')
			.addConditionEq('IsActive', true)
			.addConditionEq('activate_with_other_products__c', true)
			.addConditionEq('Requires_Activation_Check__c', true)
			.run();
	}

	public static List<Product2> getProductByPriceplanCode(String priceplanCode) {
		return new Query('Product2')
			.selectFields('Name, Id, ProductAPI_Telia_Product_Id__c')
			.addConditionEq('IsActive', true)
			.addConditionEq('ProductAPI_Telia_Product_Id__c', priceplanCode)
			.setLimit(1)
			.run();
	}

	/**
	 * Get all products with the ProductAPI_Telia_Product_Id__c field populated
	 * @return list of products
	 */
	public static List<Product2> getAllProductsHavingTeliaProductId() {
		return new Query('Product2')
			.selectFields('Id, Name, ProductAPI_Telia_Product_Id__c')
			.addConditionNotNull('ProductAPI_Telia_Product_Id__c')
			.orderBy('IsActive', 'DESC')
			.orderBy('ProductAPI_Telia_Product_Id__c')
			.run();
	}

	public static List<Product2> getProductsWithActivationInfoByIds(List<Id> listOfProductIds) {
		return (List<Product2>) new Query('Product2')
			.selectFields(new List<String>{ 'Id', 'Activate_with_other_products__c', 'Activation_Record_Type__c' })
			.addConditionIn('Id', listOfProductIds)
			.run();
	}
}
