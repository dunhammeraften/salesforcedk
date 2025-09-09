@isTest
public class ServicesSummaryDescriptorTest {
    @isTest
    static void testServicesSummaryDescriptor() {
        // Create a new instance of ServicesSummaryDescriptor
        ServicesSummaryDescriptor summaryDescriptor = new ServicesSummaryDescriptor();
        
        // Set values for the fields
        summaryDescriptor.productName = 'Test Product';
        summaryDescriptor.availableQuantity = 10;
        summaryDescriptor.assignedQuantity = 5;
        
        // Verify that the values were set correctly
        System.assertEquals('Test Product', summaryDescriptor.productName, 'Product name should match');
        System.assertEquals(10, summaryDescriptor.availableQuantity, 'Available quantity should match');
        System.assertEquals(5, summaryDescriptor.assignedQuantity, 'Assigned quantity should match');
    }
}