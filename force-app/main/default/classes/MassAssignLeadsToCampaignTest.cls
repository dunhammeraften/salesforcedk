@isTest
private class MassAssignLeadsToCampaignTest {

    @isTest
    static void testAssignLeads() {
        // Create test leads
        List<Lead> testLeads = new List<Lead>();
        for(Integer i=0; i<5; i++) {
            testLeads.add(new Lead(FirstName='Test', LastName='Lead '+i, Rationale__c='Testing', Company='Test ApS'));
        }
        insert testLeads;

        // Create test campaign
        Campaign testCampaign = new Campaign(Name='Test Campaign', IsActive=true);
        insert testCampaign;

        // Prepare test data for the invocable method
        MassAssignLeadsToCampaign.InputClass input = new MassAssignLeadsToCampaign.InputClass();
        input.leads = [SELECT Id FROM Lead LIMIT 5]; // Assuming we're taking 5 leads
        input.campaignId = testCampaign.Id;

        // Call the invocable method
        Test.startTest();
        MassAssignLeadsToCampaign.assignLeads(new List<MassAssignLeadsToCampaign.InputClass>{input});
        Test.stopTest();

        // Verify campaign members are inserted
        List<CampaignMember> campaignMembers = [SELECT Id, LeadId, CampaignId FROM CampaignMember WHERE CampaignId = :testCampaign.Id];
        System.assertEquals(5, campaignMembers.size(), 'Incorrect number of campaign members inserted');
    }
}