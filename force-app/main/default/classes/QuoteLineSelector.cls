public inherited sharing class QuoteLineSelector {
	private static final String QUOTE_RECORD_TYPE_DEVELOPER_NAME_ACTIVATION_QUOTE = 'Activation_Quote';
	private static final String TERMINATION_VERIFIER_NO = 'No';

	public static List<SBQQ__QuoteLine__c> getValueAddedServiceProductByQuote(String quoteId) {
		if (String.isBlank(quoteId)) {
			return new List<SBQQ__QuoteLine__c>();
		}

		List<SBQQ__QuoteLine__c> returnList = [
			SELECT
				SBQQ__ProductName__c,
				SBQQ__Product__c,
				SBQQ__Product__r.ProductAPI_Telia_Product_Id__c,
				SBQQ__Product__r.Activation_Record_Type__c,
				SBQQ__Quantity__c
			FROM SBQQ__QuoteLine__c
			WHERE SBQQ__Quote__c = :quoteId AND SBQQ__Product__r.Requires_Activation_Check__c = TRUE
		];

		return returnList;
	}

	public static List<SBQQ__QuoteLine__c> getVasWithOnboardingConfiguration(List<SBQQ__QuoteLine__c> quoteLines) {
		if (quoteLines == null || quoteLines.isEmpty()) {
			return new List<SBQQ__QuoteLine__c>();
		}

		List<SBQQ__QuoteLine__c> returnList = [
			SELECT
				id,
				SBQQ__Product__r.Onboarding_Configuration__c,
				SBQQ__ProductName__c,
				SBQQ__Quantity__c,
				Consumed_Quantity__c
			FROM SBQQ__QuoteLine__c
			WHERE
				id IN :quoteLines
				AND SBQQ__Product__r.Onboarding_Configuration__c INCLUDES ('ShowInValueAddedServicesSummary')
		];

		return returnList;
	}

	public static List<SBQQ__QuoteLine__c> getVASByActivationAndQuote(String activationId) {
		if (String.isBlank(activationId)) {
			return new List<SBQQ__QuoteLine__c>();
		}

		List<SBQQ__QuoteLine__c> returnList = [
			SELECT
				SBQQ__ProductName__c,
				SBQQ__Product__c,
				Telia_Product_Code__c,
				SBQQ__Quantity__c,
				SBQQ__ProductFamily__c,
				Product_Group__c
			FROM SBQQ__QuoteLine__c
			WHERE Activation__c = :activationId AND Activate_with_other_products__c = TRUE
		];

		return returnList;
	}

	public static List<SBQQ__QuoteLine__c> getDeliveryProductGroups(Set<Id> quoteIds, Set<String> existingTypes) {
		List<SBQQ__QuoteLine__c> returnList = [
			SELECT SBQQ__Product__r.Delivery_Product_Group__c
			FROM SBQQ__QuoteLine__c
			WHERE SBQQ__Quote__c IN :quoteIds AND SBQQ__Product__r.Delivery_Product_Group__c NOT IN :existingTypes
			WITH SECURITY_ENFORCED
		];

		return returnList;
	}

	/**
	 * Retrieve and return Quote Lines by Opportunity Ids where:
	 * - both Activation__c and SBQQ__Product__c are not null
	 * - parent Quote is not of record type Activation Quote
	 *
	 * @param Set<Id> opportunityIdSet
	 * @return List<SBQQ__QuoteLine__c>
	 */
	public static List<SBQQ__QuoteLine__c> getQuoteLinesByOpportunityIds(Set<Id> opportunityIdSet) {
		List<SBQQ__QuoteLine__c> returnList = [
			SELECT Id, Name, Activation__c, SBQQ__Product__c, SBQQ__Quote__r.SBQQ__Opportunity2__r.Id
			FROM SBQQ__QuoteLine__c
			WHERE
				SBQQ__Quote__r.SBQQ__Opportunity2__r.Id IN :opportunityIdSet
				AND Activation__c != NULL
				AND SBQQ__Product__c != NULL
				AND SBQQ__Quote__r.RecordType.DeveloperName != :QUOTE_RECORD_TYPE_DEVELOPER_NAME_ACTIVATION_QUOTE
		];

		return returnList;
	}

	/**
	 * Retrieve Quote Lines by their IDs, including related Quote Line Details.
	 * This method filters out Quote Line Details where Termination_verifier__c is set to 'No'.
	 * @param quoteLineIds Set of Quote Line IDs to retrieve.
	 * @return List of SBQQ__QuoteLine__c records with related Quote Line Details.
	 */
	public List<SBQQ__QuoteLine__c> getQuoteLinesByIdsWithQLD(Set<Id> quoteLineIds) {
		List<SBQQ__QuoteLine__c> returnList = [
			SELECT
				Id,
				Additional_Quantity__c,
				(
					SELECT Id, Quantity__c
					FROM Quote_Line_Details__r
					WHERE Termination_verifier__c = :TERMINATION_VERIFIER_NO
				)
			FROM SBQQ__QuoteLine__c
			WHERE Id IN :quoteLineIds
		];

		return returnList;
	}

	/**
	 * Retrieve Quote Lines by their IDs without related Quote Line Details.
	 * This method is used when only the Quote Line information is needed without the details.
	 * @param quoteLineIds Set of Quote Line IDs to retrieve.
	 * @return List of SBQQ__QuoteLine__c records.
	 * @deprecated Might use getQuoteLinesByIdsWithQLD instead for consistency and to include Quote Line Details.
	 */
	public List<SBQQ__QuoteLine__c> getQuoteLinesByIds(Set<Id> quoteLineIds) {
		List<SBQQ__QuoteLine__c> returnList = [
			SELECT Id, SBQQ__Product__r.Available_Monthly_Data_MB__c
			FROM SBQQ__QuoteLine__c
			WHERE Id IN :quoteLineIds
		];

		return returnList;
	}

	/**
	 * Retrieve Quote Lines with changed Additional Quantity.
	 * This method is used to get Quote Lines that have had their Additional Quantity changed.
	 * @param qlWithChangedAddQuantity Set of Quote Line IDs with changed Additional Quantity.
	 * @return List of SBQQ__QuoteLine__c records with related Quote Line Details.
	 */
	public List<SBQQ__QuoteLine__c> getQLWithChangedAddQuantity(Set<Id> qlWithChangedAddQuantity) {
		List<SBQQ__QuoteLine__c> returnList = [
			SELECT Id, (SELECT Id, Quantity__c FROM Quote_Line_Details__r WHERE Termination_verifier__c = 'No')
			FROM SBQQ__QuoteLine__c
			WHERE Id IN :qlWithChangedAddQuantity
		];

		return returnList;
	}

	public List<AggregateResult> getQuantityOnQuoteLineDetailsByQuoteLineId(Set<Id> quoteLineIds) {
		List<AggregateResult> returnList = [
			SELECT
				COUNT(Id) Counted,
				SUM(Quantity__c) RecalculatedQuantity,
				Quote_Line__c,
				MAX(Quote_Line__r.SBQQ__Quantity__c) CurrentQuantity
			FROM Quote_Line_Detail__c
			WHERE Quote_Line__c IN :quoteLineIds AND Termination_verifier__c = :TERMINATION_VERIFIER_NO
			GROUP BY ROLLUP(Quote_Line__c)
		];

		return returnList;
	}

	/**
	 * Retrieve and return Quote Lines by Case Id where:
	 * - both Activation__c and SBQQ__Product__c are not null
	 * - parent Quote is not of record type Activation Quote
	 *
	 * @param Id caseId
	 * @return SBQQ__QuoteLine__c
	 */
	@AuraEnabled(cacheable=true)
	public static SBQQ__QuoteLine__c getQuoteLineByCaseId(String caseId) {
		try {
			List<SBQQ__QuoteLine__c> listOfQuotelines = [
				SELECT Id
				FROM SBQQ__QuoteLine__c
				WHERE
					SBQQ__Quote__c IN (SELECT Quote__c FROM Case WHERE Id = :caseId)
					AND Product_Group__c = 'Business_Internet'
				LIMIT 1
			];

			if (listOfQuotelines.isEmpty()) {
				return null;
			}
			return listOfQuotelines.get(0);
		} catch (Exception e) {
			Logger.logDebug(e);
			Logger.emit();
			return null;
		}
	}

	public static List<SBQQ__QuoteLine__c> getQuoteLinesWithDetailsByIds(List<Id> listOfQuoteLineIds) {
		return (List<SBQQ__QuoteLine__c>) new Query('SBQQ__QuoteLine__c')
			.selectFields(
				new List<String>{
					'Id',
					'SBQQ__Quote__c',
					'SBQQ__Product__c',
					'SBQQ__PricebookEntryId__c',
					'SBQQ__Quantity__c',
					'SBQQ__NetPrice__c',
					'Activation_Record_Type__c',
					'Activation__c',
					'SBQQ__Quote__r.SBQQ__BillingCity__c',
					'Original_Quote_Line__c',
					'SBQQ__RequiredBy__c',
					'Additional_Quantity__c',
					'cross_sale__c',
					'upsale__c'
				}
			)
			.addConditionIn('Id', listOfQuoteLineIds)
			.run();
	}
}
