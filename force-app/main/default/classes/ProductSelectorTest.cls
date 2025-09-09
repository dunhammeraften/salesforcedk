@isTest
private class ProductSelectorTest {
	
    // This test class should be better. 
    // Lack of knowledge on the product setup is an issue.

    @testSetup
	static void setup() {
        // Create test data
        List<Product2> products = new List<Product2>();
        Product2 testProduct1 = new Product2(
            Name = 'Test Product Matching',
            ProductAPI_Telia_Product_Id__c = 'TestPriceplanCode1',
            activate_with_other_products__c = false,
            Requires_Activation_Check__c = false,
            IsActive = true
        );
        Product2 testProduct2 = new Product2(
            Name = 'Telia Product Matching',
            ProductAPI_Telia_Product_Id__c = 'TestPriceplanCode2',
            activate_with_other_products__c = true,
            Requires_Activation_Check__c = true,
            IsActive = true
        );

        products.add(testProduct1);
        products.add(testProduct2);
        insert products;
	}
    
    @isTest
    static void testGetValueAddedServiceProducts() {

        // Call the method being tested
        List<Product2> result = ProductSelector.getValueAddedServiceProducts();

        // Verify the result
        System.assertNotEquals(0, result.size(), 'Result should not be an empty list');
        System.assertEquals('Telia Product Matching', result[0].Name, 'Result name should match the test data');
        System.assertEquals('TestPriceplanCode2', result[0].ProductAPI_Telia_Product_Id__c, 'Result priceplanCode should match the test data');

    }

    @isTest
    static void testGetProductByPriceplanCode() {
  
        // Call the method being tested
        List<Product2> result = ProductSelector.getProductByPriceplanCode('TestPriceplanCode1');

        // Verify the result
        System.assertNotEquals(0, result.size(), 'Result should not be an empty list');
        System.assertEquals('Test Product Matching', result[0].Name, 'Result name should match the test data');
        System.assertEquals('TestPriceplanCode1', result[0].ProductAPI_Telia_Product_Id__c, 'Result priceplanCode should match the test data');
    }

    @IsTest
    static void testGetAllProductsHavingTeliaProductId() {
        // Create extra test data
        List<Product2> products = new List<Product2>();
        
        Product2 testProductWithoutTeliaProductId = new Product2(
            Name = 'Telia Product Without Telia Product Id',
            ProductAPI_Telia_Product_Id__c = null,
            activate_with_other_products__c = true,
            Requires_Activation_Check__c = true,
            IsActive = true
        );
        
        Product2 testProductWithTeliaProductId = new Product2(
            Name = 'Telia Product Without Telia Product Id',
            ProductAPI_Telia_Product_Id__c = 'TestPriceplanCodeX',
            activate_with_other_products__c = true,
            Requires_Activation_Check__c = true,
            IsActive = true
        );
        products.add(testProductWithoutTeliaProductId);
        products.add(testProductWithTeliaProductId);
        insert products;
  
        Test.startTest();

        // Call the method being tested
        List<Product2> result = ProductSelector.getAllProductsHavingTeliaProductId();
        
        Test.stopTest(); 
        
        // Verify the result
        System.assertEquals(3, result.size(), 'Result should return 3 products');
        for (Product2 product : result) {
            System.assertNotEquals(null, product.ProductAPI_Telia_Product_Id__c, 'Telia Product Id should not be null');
            System.assertNotEquals('', product.ProductAPI_Telia_Product_Id__c, 'Telia Product Id should not be blank');
        }

    }


}