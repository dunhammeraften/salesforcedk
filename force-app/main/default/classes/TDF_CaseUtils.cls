@IsTest
public with sharing class TDF_CaseUtils {
    public static Case createCaseOnQuote(SBQQ__Quote__c quote){
        Case quoteCase = new Case(
            AccountId = quote.SBQQ__Account__c,
            Opportunity__c = quote.SBQQ__Opportunity2__c,
            Subject = 'Order_Fulfilment_Case',
            RecordTypeId = Schema.sObjectType.Case.getRecordTypeInfosByDeveloperName().get('Order_Fulfilment_Case').getRecordTypeId()
        );
        insert quoteCase;

        return quoteCase;
    }

    public static List<Case> createCasesForOpportunitiesAndAssignThem(List<Opportunity> opportunities) {
        List<Case> cases = new List<Case>();
        for(Opportunity opp : opportunities) {
            cases.add(
                new Case(
                    AccountId = opp.AccountId,
                    Origin = 'Quote',
                    Quote__c = opp.SBQQ__PrimaryQuote__c,
                    RecordTypeId = Schema.sObjectType.Case.getRecordTypeInfosByDeveloperName().get('Order_Fulfilment_Case').getRecordTypeId(),
                    Requested_delivery_date__c = opp.SBQQ__PrimaryQuote__r.SBQQ__StartDate__c,
                    Opportunity__c = opp.Id
                )
            );
        }
        insert cases;

        Map<Id, Opportunity> opportunityId2Opportunity = new Map<Id, Opportunity>(opportunities);
        for(Case cas : cases) {
            opportunityId2Opportunity.get(cas.Opportunity__c).Case__c = cas.Id;
        }
        update opportunityId2Opportunity.values();

        return cases;
    }

    public static List<Case> createCustomerServiceCasesForAccounts(List<Account> accounts) {
        List<Case> cases = new List<Case>();
        for(Account acc : accounts) {
            cases.add(
                new Case(
                    AccountId = acc.Id,
                    Status = 'New',
                    Origin = 'Web',
                    Subject = 'Customer Service Case',
                    RecordTypeId = Schema.sObjectType.Case.getRecordTypeInfosByDeveloperName().get('Customer_Service_Case').getRecordTypeId()
                )
            );
        }
        insert cases;

        return cases;
    }
}