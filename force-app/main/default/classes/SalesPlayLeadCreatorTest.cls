@IsTest
private class SalesPlayLeadCreatorTest {
    @IsTest
    private static void testCreateLeads() {
        // Create test account
		Account testAccount = TestDataFactory.createAccountWithCVR('13371337');
        testAccount.Sales_Note_1__c = 'Sales Note 1';
        testAccount.Sales_Note_2__c = 'Sales Note 2';
        testAccount.Sales_Note_3__c = 'Sales Note 3';
        insert testAccount;

        // Create test contact
        Contact testContact = TestDataFactory.createContact(testAccount.Id);

        // Create input parameters
        SalesPlayLeadCreator.InputClass input = new SalesPlayLeadCreator.InputClass();
        input.accounts = new List<SObject>{testAccount};
        input.user = UserInfo.getUserId();
        input.priority = 'High';

        Test.startTest();

        // Call the method under test
        List<List<Lead>> createdLeads = SalesPlayLeadCreator.createLeads(new List<SalesPlayLeadCreator.InputClass>{input});

        Test.stopTest();

        // Assertions
        Assert.isNotNull(createdLeads, 'List of created leads should not be null');
        Assert.isFalse(createdLeads.isEmpty(), 'List of List of created leads should not be empty');
        List<Lead> leads = createdLeads[0];
        Assert.isFalse(leads.isEmpty(), 'List of created leads should not be empty');

        // Check the first created lead
        Lead createdLead = leads[0];
        Assert.areEqual(testAccount.Id, createdLead.Account__c, 'Lead Account should match test account Id');
        Assert.areEqual(testAccount.Sales_Note_1__c, createdLead.Sales_Note_1__c, 'Sales Note 1 should match');
        Assert.areEqual(testAccount.Sales_Note_2__c, createdLead.Sales_Note_2__c, 'Sales Note 2 should match');
        Assert.areEqual(testAccount.Sales_Note_3__c, createdLead.Sales_Note_3__c, 'Sales Note 3 should match');
        Assert.areEqual(SalesPlayLeadCreator.LEAD_STATUS, createdLead.Status, 'Lead Status should be New');
        Assert.areEqual(testAccount.Name, createdLead.Company, 'Lead Company should match test account Name');
        Assert.areEqual(SalesPlayLeadCreator.LEAD_SOURCE, createdLead.LeadSource, 'Lead LeadSource should be Sales Play');
        Assert.areEqual(input.priority, createdLead.Priority__c, 'Lead Priority should be High');

        // Check lead owner
        Assert.areEqual(UserInfo.getUserId(), createdLead.OwnerId, 'Lead Owner should match the current user');

        // Check contact details
        Assert.areEqual(testContact.FirstName, createdLead.FirstName, 'Lead FirstName should match test contact FirstName');
        Assert.areEqual(testContact.LastName, createdLead.LastName, 'Lead LastName should match test contact LastName');
        Assert.areEqual(testContact.Email, createdLead.Email, 'Lead Email should match test contact Email');
        Assert.areEqual(testContact.Phone, createdLead.Phone, 'Lead Phone should match test contact Phone');
        Assert.areEqual(testContact.MobilePhone, createdLead.MobilePhone, 'Lead MobilePhone should match test contact MobilePhone');
        Assert.areEqual(testContact.Title, createdLead.Title, 'Lead Title should match test contact Title');
        Assert.areEqual(testContact.Id, createdLead.Contact__c, 'Lead should be related to the Contact it was created from');
    }
}