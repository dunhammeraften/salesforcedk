@IsTest
private with sharing class LeadSelectorTest {
    private static final String CVR = '23232323';
    private static final String LEAD_STATUS_UNQUALIFIED = 'Unqualified';

    @IsTest
    private static void testGetOrderedOpenOrClosedLeadsByAccountsAndCloseDate() {
        Account acc = TestDataFactory.createAccountWithCVR(CVR);
        List<Lead> leads = TestDataFactory.createSalesPlayLeadsForAccounts(2, new List<Account>{acc});
        leads[0].Status = LEAD_STATUS_UNQUALIFIED;
        leads[0].Unqualified_Reason__c = Lead.Unqualified_Reason__c.getDescribe().getPicklistValues()[0].getValue();
        update leads[0];

        Test.startTest();
        List<LEad> orderedLeads = LeadSelector.getOrderedOpenOrClosedLeadsByAccountsAndCloseDate(
            new List<Account>{acc},
            System.today().addDays(-180)
        );
        Test.stopTest();

        Assert.areEqual(2, orderedLeads.size(), '2 Leads should be returned');
    }
}