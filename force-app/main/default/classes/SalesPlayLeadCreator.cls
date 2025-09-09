public with sharing class SalesPlayLeadCreator {
    @TestVisible
    private static final String LEAD_STATUS = 'New';
    @TestVisible
    private static final String LEAD_SOURCE = 'Sales Play';

    @InvocableMethod(label='Create Leads' description='Returns leads for Sales Play!')
    public static List<List<Lead>> createLeads(List<InputClass> theList) {
        List<Lead> leads = new List<Lead>();       
        List<Lead> recalcedLeads = new List<Lead>();
        List<SObject> accounts = theList[0].accounts;
        String userId = theList[0].user;
        Id salesPlayRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Sales_Play').getRecordTypeId();

        for (SObject sObj : accounts) {
            Account account = (Account)sObj;
            Lead lead = new Lead();
            lead.Account__c = account.Id;
            lead.Sales_Note_1__c = account.Sales_Note_1__c;
            lead.Sales_Note_2__c = account.Sales_Note_2__c;
            lead.Sales_Note_3__c = account.Sales_Note_3__c;
            lead.Status = LEAD_STATUS;
            lead.Company = account.Name;
            lead.LeadSource = LEAD_SOURCE;
            lead.RecordTypeId = salesPlayRecordTypeId;
            lead.City = account.BillingCity;
            lead.Country = account.BillingCountry;
            lead.PostalCode = account.BillingPostalCode;
            lead.State = account.BillingState;
            lead.Street = account.BillingStreet;
            lead.Priority__c = theList[0].priority;
            lead.Sales_Play_Campaign_Name__c = theList[0].campaignName;
            
            lead.OwnerId = (userId == 'AccountOwner') ? account.OwnerId : userId;

            Contact contact = getContact(account.id);
            if (contact != null) {
                lead.FirstName = contact.FirstName;
                lead.LastName = contact.LastName;
                lead.Email = contact.Email;
                lead.Phone = contact.Phone;
                lead.MobilePhone = contact.MobilePhone;
                lead.Title = contact.Title;
                lead.Contact__c = contact.Id;
            } else {
                lead.LastName = 'Unknown';
            }
            
            leads.add(lead);
        }

        List<FormulaRecalcResult> results = Formula.recalculateFormulas(leads);

        for(FormulaRecalcResult result : results) {
            if(result.isSuccess()) {
                recalcedLeads.add((Lead)result.getSObject());
            }
        }

        List<List<Lead>> returnValue = new List<List<Lead>>();

        returnValue.add(recalcedLeads);

        return returnValue;
    }

    public static Contact getContact(String accountId) {
        Contact contact;
        try {
            contact = [SELECT id, FirstName, LastName, Email, Phone, MobilePhone, Title FROM Contact WHERE AccountId =: accountId WITH SECURITY_ENFORCED ORDER BY Primary_account_contact__c DESC, LastModifiedDate DESC LIMIT 1];
        } catch(Exception e) {
            contact = null;
        }
        return contact; 
    }

    public class InputClass {
        @InvocableVariable(required=true)
        public List<SObject> accounts;
        @InvocableVariable(required=true)
        public String user;
        @InvocableVariable(required=true)
        public String priority;
        @InvocableVariable(required=true)
        public String campaignName;
    }

}