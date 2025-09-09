@isTest
private class LocationLineUploadToolTest {

    @isTest
    static void testUploadLocationLines() {
        Account acc = TDF_AccountUtils.creatActiveAccountWithCVRAndOwner();
        insert acc;

        // Create test data
        Opportunity testOpportunity = new Opportunity(Name = 'Test Opportunity', StageName = 'Prospecting', CloseDate = System.today(), AccountId = acc.Id);
        insert testOpportunity;

        List<Location_Line__c> testLines = new List<Location_Line__c>();
        testLines.add(new Location_Line__c(Opportunity__c = testOpportunity.Id, Street_Name__c = 'Line 1'));

        String jsonData = JSON.serialize(testLines);
        String oppId = testOpportunity.Id;

        // Call the method to be tested
        Test.startTest();
        LocationLineUploadTool.uploadLocationLines(jsonData, oppId);
        Test.stopTest();

        // Verify the results
        List<Location_Line__c> insertedLines = [SELECT Id, Name, Opportunity__c FROM Location_Line__c WHERE Id NOT IN :testLines];

        System.assertEquals(1, insertedLines.size(), 'One line without an ID should be inserted');
        System.assertEquals(testOpportunity.Id, insertedLines[0].Opportunity__c, 'Inserted line should have the correct Opportunity__c value');

    }

    @isTest
    static void testUploadLocationLineAndReturnRecord() {
        Account acc = TDF_AccountUtils.creatActiveAccountWithCVRAndOwner();
        insert acc;

        // Create test data
        Opportunity testOpportunity = new Opportunity(Name = 'Test Opportunity', StageName = 'Prospecting', CloseDate = System.today(), AccountId = acc.Id);
        insert testOpportunity;

        Location_Line__c line = new Location_Line__c(Opportunity__c = testOpportunity.Id, Street_Name__c = 'Line 1');

        String jsonData = JSON.serialize(line);
        String oppId = testOpportunity.Id;

        // Call the method to be tested
        Test.startTest();
        Location_Line__c resultLine = LocationLineUploadTool.uploadLocationLineAndReturnRecord(jsonData, oppId);
        Test.stopTest();

        // Add assertions here if needed
        System.assertNotEquals(null, resultLine, 'The returned Location Line should not be null');
        System.assertEquals(oppId, resultLine.Opportunity__c, 'Opportunity Id should match');
    }
}