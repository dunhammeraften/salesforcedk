public with sharing class ProductSelector {
    
    public static List<Product2> getAllActiveProductsOrderByName() {
        return [SELECT Name, Id, ProductAPI_Telia_Product_Id__c  FROM Product2 WHERE IsActive = true  ORDER BY Name];
    }

    public static List<Product2> getValueAddedServiceProducts() { // Only used in Activation_check_details ?
        return [SELECT Name, Id, ProductAPI_Telia_Product_Id__c  FROM Product2 WHERE IsActive = true AND activate_with_other_products__c = true AND Requires_Activation_Check__c = true];
    }

    public static List<Product2> getProductByPriceplanCode(String priceplanCode) {
        return [SELECT Name, Id, ProductAPI_Telia_Product_Id__c  FROM Product2 WHERE IsActive = true AND ProductAPI_Telia_Product_Id__c =: priceplanCode LIMIT 1];
    }
    
    /**
     * Get all products with the ProductAPI_Telia_Product_Id__c field populated
     * @return list of products
     */
    public static List<Product2> getAllProductsHavingTeliaProductId() {
        return [
            SELECT Id, Name, ProductAPI_Telia_Product_Id__c
            FROM Product2
            WHERE ProductAPI_Telia_Product_Id__c != null
            ORDER BY IsActive DESC, ProductAPI_Telia_Product_Id__c
        ];
    }
}