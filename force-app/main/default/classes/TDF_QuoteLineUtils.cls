@IsTest
public with sharing class TDF_QuoteLineUtils {
    public static List<SBQQ__QuoteLine__c> createQuoteLinesForQuote(	
		List<SBQQ__Quote__c> theQuotes,
		Boolean hasAdditionalDiscount,
        List<Product2> listOfProductsToUse,
        Map<Id, PricebookEntry> mapOfProductToPricebookEntry
	) {
		List<SBQQ__QuoteLine__c> result = new List<SBQQ__QuoteLine__c>();

		for (SBQQ__Quote__c singleQuote : theQuotes) {
			for (Integer i = 0; i < listOfProductsToUse.size(); ++i) {
				result.add(
					new SBQQ__QuoteLine__c(
						SBQQ__Quote__c = singleQuote.Id,
						SBQQ__Product__c = listOfProductsToUse[Math.mod(i, listOfProductsToUse.size())].Id,
						SBQQ__PricebookEntryId__c = mapOfProductToPricebookEntry.get(listOfProductsToUse[Math.mod(i, listOfProductsToUse.size())].Id).Id,
						SBQQ__Quantity__c = Integer.valueOf(Math.random() * 100),
						SBQQ__NetPrice__c = Integer.valueOf(Math.random() * 1000),
						SBQQ__AdditionalDiscountAmount__c = ((hasAdditionalDiscount && Math.mod(i, 2) == 0) ? 200 : 0),
					    cross_sale__c = true,
						upsale__c = false
					)
				);
			}
		}

		insert result;
		return result;
	}
}