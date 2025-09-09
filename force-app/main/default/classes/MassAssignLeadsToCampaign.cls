public with sharing class MassAssignLeadsToCampaign {
    @InvocableMethod(label='Assign Leads' description='Assign leads to a Campaign!')
    public static void assignLeads(List<InputClass> theList) {
        
        List<Lead> leads = (List<Lead>)theList[0].leads;
        List<CampaignMember> cms = new List<CampaignMember>();

        for (Lead lead : leads) {
            CampaignMember cm = new CampaignMember();
            cm.LeadId = lead.Id;
            cm.CampaignId = theList[0].campaignId;
            cms.add(cm);
        }

        insert cms;
    }

    public class InputClass {
        @InvocableVariable(required=true)
        public List<SObject> leads;
        @InvocableVariable(required=true)
        public String campaignId;
    }
}