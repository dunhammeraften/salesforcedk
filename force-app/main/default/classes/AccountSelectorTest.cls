/**
 * 
 * @author 
 * @since 
 */
@IsTest
private class AccountSelectorTest {
	private static final String CVR = '12345678';

	@TestSetup
    private static void makeData() {
        Account acc = testDataFactory.createAccountWithCVR(CVR);
        insert acc;

        // Create a Case linked to the Account
        Case caseRecord = new Case(
            AccountId = acc.Id,
            Subject = 'Test Case',
            Status = 'New'
        );
        insert caseRecord;
    }

    /**
     * Test whether getByCvr returns an account when given a valid CVR
     */
	@IsTest
	private static void getbyCvr_validCvr_returnsAccount() {
        //ARRANGE

        //ACT
		Test.startTest();
		Account acc = AccountSelector.getByCVR(CVR);
		Test.stopTest();
		
        //ASSERT
        Assert.isNotNull(acc, 'The account should be found');
	}

    /**
     * getAccountsByIds_validAccountIds_returnsSingleAccountWithCorrectCvr
     */
	@IsTest
	private static void getAccountsByIds_validAccountIds_returnsSingleAccountWithCorrectCvr() {
		//ARRANGE
        Account acc = AccountSelector.getByCVR(CVR);

        //ACT
		Test.startTest();
		List<Account> accounts = AccountSelector.getAccountsByIds(new List<Id>{acc.Id});
		Test.stopTest();

        //ASSERT
		Assert.areEqual(1, accounts.size(), 'Returned List should contain a sinlge Account');
		Assert.areEqual(CVR, accounts[0].CVR__c, 'The returned Accounts CVR should match');
	}

	@IsTest
	private static void getAccountByCaseId_validCaseId_returnsCorrectAccount() {
		//ARRANGE
        Account acc = AccountSelector.getByCVR(CVR);

		Case testCase = new Case(
			AccountId = acc.Id,
			Status = 'New',
			Origin = 'Email'
		);
		insert testCase;

        //ACT
		Test.startTest();
		Account returnedAccount = AccountSelector.getAccountByCaseId(testCase.Id);
		Test.stopTest();

        //ASSERT
        Assert.areEqual(acc.Id, returnedAccount.Id);
	}

    @IsTest
    private static void testGetAccountByCaseIdNoCase() {
        // Create a valid Case ID
        Case testCase = new Case(Subject = 'Test Case');
        insert testCase;
        Id validCaseId = testCase.Id;
        
        // Delete the Case to simulate a non-existent record
        delete testCase;
    
        Test.startTest();
        Id accountId = AccountSelector.getAccountByCaseId(validCaseId)?.Id;
        Test.stopTest();
    
        // Assert no Account is returned for a deleted (non-existent) Case ID
        Assert.isNull(accountId, 'No account.Id should be returned for a non-existent Case ID');
    }
    

    @IsTest
    private static void testGetAccountByCaseIdNoAccountLinked() {
        // Create a Case without an Account
        Case caseWithoutAccount = new Case(
            Subject = 'Unlinked Case',
            Status = 'New'
        );
        insert caseWithoutAccount;

        Test.startTest();
        Account retrievedAccount = AccountSelector.getAccountByCaseId(caseWithoutAccount.Id);
        Test.stopTest();

        Assert.isNull(retrievedAccount, 'No account should be returned for a case not linked to an account');
    }
}