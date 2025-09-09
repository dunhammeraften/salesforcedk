public with sharing class QuoteSelector {
	public static List<SBQQ__Quote__c> getQuotesWithLinesHavingProductWithDocumentIdentifierFromQuoteList(List<SBQQ__Quote__c> quotes) {
		return [
			SELECT
				Id,
				(SELECT 
					Id,
					SBQQ__Product__r.Document_Identifier__c
				FROM SBQQ__LineItems__r
				WHERE SBQQ__Product__r.Document_Identifier__c != null)
			FROM SBQQ__Quote__c
			WHERE Id IN :quotes
		];
	}

	public static List<SBQQ__Quote__c> getQuotesWithLinesWithinValidUntilByAccountIdsInStatuses(List<Id> accountIds, Set<String> statuses) {
		return [
			SELECT Id, SBQQ__Account__c, SBQQ__StartDate__c, SBQQ__SubscriptionTerm__c, Valid_Until__c, Manual_Valid_Until__c, SBQQ__Status__c,
				(SELECT Id, SBQQ__Product__c, SBQQ__Product__r.Name, SBQQ__Product__r.ProductAPI_Telia_Product_Id__c, Telia_Net_Unit_Price__c
				FROM SBQQ__LineItems__r)
			FROM SBQQ__Quote__c
			WHERE SBQQ__Account__c IN :accountIds
				AND SBQQ__Status__c IN :statuses
				AND (
					Manual_Valid_Until__c >= :System.today()
					OR 
					(
						Manual_Valid_Until__c = null
						AND Valid_Until__c >= :System.today()
					)
				)
		];
	}

	public static List<SBQQ__Quote__c> getQuotesValidUntilYesterday() {
		return [
			SELECT Id, SBQQ__Account__c
			FROM SBQQ__Quote__c
			WHERE Manual_Valid_Until__c = YESTERDAY
			OR 
			(
				Manual_Valid_Until__c = null
				AND Valid_Until__c = YESTERDAY
			)
			ORDER BY SBQQ__Account__c
		];
	}

	public static List<SBQQ__Quote__c> getQuotesByIds(Set<Id> quoteIds) {
        return [
            SELECT SBQQ__Opportunity2__c
            FROM SBQQ__Quote__c
            WHERE Id IN :quoteIds
            WITH SECURITY_ENFORCED
        ];
    }

	public static List<SBQQ__Quote__c> getQuotesByAccountCVRs(List<String> cvrList) {
		return [
			SELECT 
				Id, 
				SBQQ__Account__c,
				ApprovalStatus__c, 
				SBQQ__StartDate__c, 
				SBQQ__Status__c, 
				SBQQ__SubscriptionTerm__c, 
				Valid_Until__c,
				SBQQ__Account__r.CVR__c
			FROM SBQQ__Quote__c
			WHERE SBQQ__Account__r.CVR__c IN :cvrList
			ORDER BY SBQQ__Account__c
		];
	}

	public static List<SBQQ__Quote__c> getQuotesWithQLs(Set<Id> quoteIds) {

    	List<SBQQ__Quote__c> quotes = new Query('SBQQ__Quote__c')
        .selectFields(new List<String>{
            'Id',
            'Quote_Preparation_Lock__c'
        })
        .addSubquery(
            Query.subquery('SBQQ__LineItems__r')
                .selectFields(new List<String>{
                    'Id',
                    'SBQQ__AdditionalDiscountAmount__c',
                    'SBQQ__RenewedSubscription__r.SBQQ__Discount__c'
                })
                .addConditionGt('SBQQ__AdditionalDiscountAmount__c', 0)
        )
		.addConditionIn('Id', quoteIds).fetchAll();
		
		return quotes;
	}
}