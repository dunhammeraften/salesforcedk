@isTest
public class ProductStatusSummaryDescriptorTest {
	@isTest
	static void testProductStatusSummaryDescriptor() {
		// Create an instance of ProductStatusSummaryDescriptor
		ProductStatusSummaryDescriptor descriptor = new ProductStatusSummaryDescriptor();

		// Set values for the properties
		descriptor.product = 'Sample Product';
		descriptor.phoneNoStatus = 'Active';
		descriptor.count = 10;

		// Verify that the properties are correctly exposed and initialized
		System.assertEquals('Sample Product', descriptor.product, 'Product name should be "Sample Product"');
		System.assertEquals('Active', descriptor.phoneNoStatus, 'Phone number status should be "Active"');
		System.assertEquals(10, descriptor.count, 'Count should be 10');
	}
}