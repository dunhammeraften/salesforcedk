public with sharing class QuoteToCaseTypesCalculator {

    @InvocableMethod(Label='Calculate Case Types' category='Quote')
    public static List<List<String>> getQuoteTypes(List<Request> requests) {
        
        List<String> quoteIdsInput = requests.get(0).quoteIds;
                
        Set<Id> quoteIds = new Set<Id>();
        for (String str : quoteIdsInput) {
            quoteIds.add(Id.valueOf(str));
        }

        Set<String> uniqueProductGroups = new Set<String>();

        Set<String> existingTypes = new Set<String>();

        if (requests.get(0).checkForExistingCases) {
            List<SBQQ__Quote__c> quotes = QuoteSelector.getQuotesByIds(quoteIds);
        
            Set<Id> opportunityIds = new Set<Id>();
            
            for (SBQQ__Quote__c q : quotes) {
                opportunityIds.add(q.SBQQ__Opportunity2__c);
            }

            List<Case> caseRecords = CaseSelector.getCasesByOpportunityIds(opportunityIds);
            for (Case c : caseRecords) {
                existingTypes.add(c.Type);
            }

        }

        List<SBQQ__QuoteLine__c> quoteLines = QuoteLineSelector.getDeliveryProductGroups(quoteIds, existingTypes);

        // Add non-blank delivery product groups to the set
        for (SBQQ__QuoteLine__c quoteLine : quoteLines) {
            String productGroup = quoteLine.SBQQ__Product__r.Delivery_Product_Group__c;
            if (!String.isBlank(productGroup)) {
                uniqueProductGroups.add(productGroup);
            }
        }

        // Convert the set of unique product groups to a list
        List<String> productGroupList = new List<String>(uniqueProductGroups);

        // Wrap the list in another list (to match invocable method requirements)
        return new List<List<String>> { productGroupList };
    }

    public class Request {
		@InvocableVariable
		public List<String> quoteIds; // InvocableVariable fields do not support type of Set<Id>
		@InvocableVariable
		public Boolean checkForExistingCases;
	}

}