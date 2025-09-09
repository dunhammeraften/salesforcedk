@isTest
private class AccountServiceTest {

    private static final String TEST_CVR = '12345678';

    @isTest
    static void testCompanyAPIDataFetch() {

        Account acc = TDF_AccountUtils.createAccountWithCVR(TEST_CVR);
        insert acc;

        AccountService accountService = new AccountService();

        Test.startTest();
        Set<Id> result = accountService.CompanyAPIDataFetch(new List<Account>{ acc });
        Test.stopTest();

        Assert.isTrue(result.contains(acc.Id), 'Account Id should be sent to Company API update');
    }
    
    @isTest
    static void testContractAPIDataFetch() {

        Account acc = TDF_AccountUtils.createAccountWithCVR(TEST_CVR);
        acc.Send_Update_to_Contract_API__c = true;
        insert acc;

        AccountService accountService = new AccountService();

        Test.startTest();
        List<Id> result = accountService.ContractAPIDataFetch(new List<Account>{ acc });
        Test.stopTest();

        Assert.isTrue(result.contains(acc.Id), 'Account Id should be sent to Contract API update');
    }
}