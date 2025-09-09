/**
 * The NumberSeriesRefreshActionTest class is responsible for testing the NumberSeriesRefreshAction class.
 *  -----------------------------------------------------------------------------
 *  Developer            Date            Description
 *  -----------------------------------------------------------------------------
 *  Kenneth Houkjær         27/07/2025      Initial version
 *
 * @author Kenneth Houkjær
 * @date 27/07/2025
 */
@IsTest
private with sharing class NumberSeriesRefreshActionTest {
    private static final List<String> CVR_LIST = new List<String>{
        '12345678',
        '87654321'
    };

    /**
     * @description Sets up the test data.
     */
    @TestSetup
    static void makeData() {
        // create the Accounts
        List<Account> testAccounts = new List<Account>();
        for (String cvr : CVR_LIST) {
            // create the Account
            Account testAccount = TDF_AccountUtils.createAccountWithCVR(cvr);
            testAccount.Status__c = 'Active';
            testAccounts.add(testAccount);
        }
        insert testAccounts;
        
        // TODO we need phone number series 
        // TODO we need phone number assignments
    }

    /**
     * @description Tests the refreshPhoneNumberSeries method.
     */
    @IsTest  
    private static void testRefreshPhoneNumberSeries() {
        // ARRANGE
        // re-query the accounts
        List<Account> testAccounts = [SELECT Id FROM Account WHERE CVR__c IN :CVR_LIST];        

        List<NumberSeriesRefreshAction.InputVariables> inputVariablesList = new List<NumberSeriesRefreshAction.InputVariables>();
        List<NumberSeriesRefreshAction.OutputVariables> outputVariables = new List<NumberSeriesRefreshAction.OutputVariables>();

        // for each account we create phone number series refresh action input variables
        for (Account testAccount : testAccounts) {
            NumberSeriesRefreshAction.InputVariables inputVariables = new NumberSeriesRefreshAction.InputVariables();
            inputVariables.inputAccount = testAccount;
            inputVariablesList.add(inputVariables);
        }

        // ACT
        Test.startTest();

        List<NumberSeriesRefreshAction.OutputVariables> outputVariablesListResult = NumberSeriesRefreshAction.refreshPhoneNumberSeries(inputVariablesList);

        Test.stopTest();

        // ASSERT
        Assert.areEqual(
            CVR_LIST.size(), 
            outputVariablesListResult.size(), 
            'We expected ' + CVR_LIST.size() + ' output variables to be returned'
        );

    }
}