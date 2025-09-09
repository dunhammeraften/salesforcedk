/**
 * @description Test the batchUpdatePhoneNumberReservation batchjob
 * @author Kenneth Houkjær
 */
@isTest
private class batchUpdatePhoneNumberReservationsTest {
    @isTest
    static void testBatch() {
        // Create test data
        Account acc = new Account(Name = 'Test Account');
        acc.cvr__c = '12345678';
        insert acc;

       Account_Phone_Number_Series__c series = new Account_Phone_Number_Series__c(
            Account__c = acc.Id,
            Number_Group__c = 'P',
            Number_Location__c = 'EKC',
            Product_Type__c = 'GSM'
        );
        insert series;

        // Start the batch job
        Test.startTest();
        batchUpdatePhoneNumberReservations batch = new batchUpdatePhoneNumberReservations();
        batch.numberSyncService = new NumberSyncServiceMock();
        Database.executeBatch(batch);
        Test.stopTest();

        // Verify the results
        System.assertEquals(2, [SELECT count() FROM AsyncApexJob]);
    }
}