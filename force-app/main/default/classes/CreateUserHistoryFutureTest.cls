@IsTest
private class CreateUserHistoryFutureTest {
    private static final Integer numberOfUserHistoryRecordsToCreate = 5;

    @IsTest
    static void createRecord() {
        // Create Test Data
        List<User> testUsers = testDataFactory.createTeliaEnterpriseSalesUsers(numberOfUserHistoryRecordsToCreate);
        List<User_History__c> userHistoryRecords = testDataFactory.createUserHistory(testUsers);
            
        // Validate Starting Point
        System.assertEquals(0, [SELECT Id FROM User_History__c].size());
        
        // Begin Test
        Test.startTest();
        
        CreateUserHistoryFuture.createRecord(userHistoryRecords);
        
        // End Test
        Test.stopTest();
        
        // Validate Results
        System.assertEquals(numberOfUserHistoryRecordsToCreate, [SELECT Id FROM User_History__c].size());
    }
}