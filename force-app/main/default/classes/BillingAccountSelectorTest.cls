@IsTest
private class BillingAccountSelectorTest {

    @testSetup
    static void setup() {
        
        // Create test data
        Account testAccount = new Account(
            Name = 'Test Account',
            Rationale__c = 'Testing'
        );
        insert testAccount;
        
        Billing_Account__c testBillingAccount = new Billing_Account__c(
            Account__c = testAccount.Id,
            Billing_Account_Type__c = 'Home Office',
            Default_Billing_Account__c = true
        );
        insert testBillingAccount;
        
        Case testCase = new Case(
            Subject = 'Test Case',
            Status = 'New',
            AccountId = testAccount.Id
        );
        insert testCase;

    }

    @IsTest
    static void testGetDefaultBanByAccountAndType() {
        // Retrieve test data
        Account testAccount = [SELECT Id FROM Account WHERE Name = 'Test Account'];
        Test.startTest();
        Billing_Account__c resultBillingAccount = BillingAccountSelector.getDefaultBanByAccountAndType(testAccount.Id, 'Home Office');
        Test.stopTest();
        System.assertEquals(true, resultBillingAccount!= null, 'Billing Account should be retrieved');
    }

    @IsTest
    static void testGetBansByAccountAndType() {
        // Retrieve test data
        Account testAccount = [SELECT Id FROM Account WHERE Name = 'Test Account'];
        Test.startTest();
        List<Billing_Account__c> result = BillingAccountSelector.getBansByAccountAndType(testAccount.Id, 'Home Office');
        Test.stopTest();
        System.assertEquals(1, result.size(), 'Expected only one billing account');
    }

    @IsTest
    static void testGetBansByCaseAndType() {
        // Retrieve test data
        Case testCase = [SELECT Id FROM Case WHERE Subject = 'Test Case'];
        Account testAccount = [SELECT Id FROM Account WHERE Name = 'Test Account'];
        Test.startTest();
        List<Billing_Account__c> result = BillingAccountSelector.getBansByCaseAndType(testCase.Id, 'Home Office');
        Test.stopTest();
        System.assertEquals(1, result.size(), 'Expected only one billing account');
    }
}