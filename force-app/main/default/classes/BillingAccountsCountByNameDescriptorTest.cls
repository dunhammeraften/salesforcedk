@isTest
public class BillingAccountsCountByNameDescriptorTest {
	@isTest
	static void testBillingAccountsCountByNameDescriptor() {
		// Create an instance of BillingAccountsCountByNameDescriptor
		BillingAccountsCountByNameDescriptor descriptor = new BillingAccountsCountByNameDescriptor();

		// Set values for the properties
		descriptor.billingAccountName = 'Sample Account';
		descriptor.numberOfSubscriptions = '42';

		// Verify that the properties are correctly exposed
		System.assertEquals('Sample Account', descriptor.billingAccountName, 'Billing account name should be "Sample Account"');
		System.assertEquals('42', descriptor.numberOfSubscriptions, 'Number of subscriptions should be "42"');
	}
}