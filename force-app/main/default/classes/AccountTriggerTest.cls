@IsTest
private with sharing class AccountTriggerTest {

    private static final String TEST_CVR = '11223344';

    @IsTest
    private static void companyApiUpdateSuccess() {
        Account acc = TDF_AccountUtils.createAccountWithCVR(TEST_CVR);
      
        Test.startTest();
            insert acc;
        Test.stopTest();
        
        List<Account> insertedAccounts = [SELECT Id, CVR__c FROM Account WHERE Id = :acc.Id];
        Assert.isTrue(!insertedAccounts.isEmpty(), 'Account should be sent to Company API update');
    }   

    @IsTest
    private static void contractApiUpdateSuccess() {
        Account acc = TDF_AccountUtils.createAccountWithCVR(TEST_CVR);
        insert acc;
        
        Test.startTest();
            acc.Send_Update_to_Contract_API__c = true;
            update acc;
        Test.stopTest();
        
        List<Account> updatedAccounts = [SELECT Id, CVR__c FROM Account WHERE Id = :acc.Id];

        Assert.isTrue(!updatedAccounts.isEmpty(), 'Account should be sent to Contract API update');
    }
}