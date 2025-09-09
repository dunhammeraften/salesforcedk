@IsTest
public with sharing class TDF_QuoteUtils {
    public static SBQQ__Quote__c createSingleQuote(String accountId, String opportunityId) {
		SBQQ__Quote__c quote = new SBQQ__Quote__c(
			SBQQ__BillingFrequency__c = 'kvartalsvis.',
			SBQQ__PaymentTerms__c = '30',
			SBQQ__SubscriptionTerm__c = 36,
			SBQQ__Account__c = accountId,
			Invoice_Email__c = 'tuba@tuba.com',
			SBQQ__Opportunity2__c = opportunityId
		);
		return quote;
	}
}