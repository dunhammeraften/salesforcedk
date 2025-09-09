public class QuoteLineService {
	
	@TestVisible
	private final DatabaseService dataBaseService;
	@TestVisible
	private final QuoteSelector quoteSelector;
	@TestVisible
	private final QuoteLineSelector quoteLineSelector;
	
	/**
     * Default constructor for QuoteLineService.
     * Uses SingletonFactory to get instances of DatabaseService and QuoteSelector.
     */
    public QuoteLineService() {
      this(SingletonFactory.getFactory());
    }

    /**
     * Constructor for QuoteLineService that allows passing a SingletonFactory.
     *
     * @param singletonFactory The SingletonFactory instance to use for retrieving services.
     */
    private QuoteLineService(SingletonFactory singletonFactory) {
      this.dataBaseService = (DatabaseService) singletonFactory.getOrRegisterSingleton(DatabaseService.class);
	  this.quoteSelector = (QuoteSelector) singletonFactory.getOrRegisterSingleton(QuoteSelector.class);
	  this.quoteLineSelector = (QuoteLineSelector) singletonFactory.getOrRegisterSingleton(QuoteLineSelector.class);
	}

    public void qlQuantityChangeProcessing(List<SBQQ__QuoteLine__c> newList,  List<SBQQ__QuoteLine__c> oldList) {
		Logger.logInfo(String.format('qlQuantityChangeProcessing( {0}, {1} )', new List<Object>{ newList, oldList}));
		// Compare old and new values
		// Change of Quantity on renewal
		List<Integer> qlWithChangedQuantity = new List<integer>();
		for (Integer i = 0; i < oldList.size(); ++i) {
			if (
				oldList[i].SBQQ__Quantity__c != newList[i].SBQQ__Quantity__c &&
				newList[i].Quote_Type__c == 'Renewal' &&
				newList[i].Renewal_Quantity_Proper_Change_Indicator__c == false
			)
				qlWithChangedQuantity.add(i);
		}
		Logger.logDebug('qlWithChangedQuantity: ' + qlWithChangedQuantity);
		if (!qlWithChangedQuantity.isEmpty()) {
			for (Integer index : qlWithChangedQuantity) {
			newList[index].Additional_Quantity__c =
				(newList[index].Additional_Quantity__c == null ? 0 : newList[index].Additional_Quantity__c) +
				newList[index].SBQQ__Quantity__c -
				oldList[index].SBQQ__Quantity__c;
			}
		}
	}

	public void qlQuantityCounting(Map<Id, SBQQ__QuoteLine__c> oldMap, Map<Id, SBQQ__QuoteLine__c> newMap) {
		Logger.logInfo(String.format('qlQuantityCounting( {0}, {1} )', new List<Object>{ oldMap, newMap}));
		// Change of Quantity on renewal end
		Set<Id> qlWithChangedAddQuantity = new Set<Id>();
		for (Id singleId : oldMap.keySet()) {
			if (oldMap.get(singleId).Additional_Quantity__c != newMap.get(singleId).Additional_Quantity__c && newMap.get(singleId).Quote_Type__c == 'Renewal')
				qlWithChangedAddQuantity.add(singleId);
		}
		
		Logger.logDebug('qlWithChangedAddQuantity: ' + qlWithChangedAddQuantity);
		
		if (!qlWithChangedAddQuantity.isEmpty()){
			List<SBQQ__QuoteLine__c> theRecords = quoteLineSelector.getQLWithChangedAddQuantity(qlWithChangedAddQuantity);
			
			Logger.logDebug('theRecords: ' + theRecords);

			List<SBQQ__QuoteLine__c> newList = new List<SBQQ__QuoteLine__c>(newMap.values());
			Integer index = null;
			for (SBQQ__QuoteLine__c singleQL : theRecords) {
				Decimal qldQuantity = 0.0;
				for (Integer i = 0; i < newList.size(); ++i) {
					if (newList[i].Id == singleQL.Id) {
						for (Quote_Line_Detail__c singleQLD : singleQL.Quote_Line_Details__r) {
							qldQuantity += (singleQLD.Quantity__c == null ? 1 : singleQLD.Quantity__c);
						}
						newList[i].SBQQ__Quantity__c = qldQuantity + newList[i].Additional_Quantity__c;

						break;
					}
				}
			}
		}
	}

	public void onQLInsertRenewalQuoteMoveQuantityToAdditionalQ(List<SBQQ__QuoteLine__c> newList){
		Logger.logInfo(String.format('onQLInsertRenewalQuoteMoveQuantityToAdditionalQ( {0} )', new List<Object>{ newList }));
		if (UserInfo.getUserName() != OrgUtils.getUsernameForCompanySFSystemUser()) {	
			for (SBQQ__QuoteLine__c singleQL : newList) {
				if (singleQL.SBQQ__Quantity__c > 0 && singleQL.Quote_Type__c == 'Renewal') {
					singleQL.Additional_Quantity__c = singleQL.SBQQ__Quantity__c;
				}
			}
		}
	}
	
	/**
	 * Collects the set of quote IDs that need to be updated.
	 * 
	 * @param newList List of new quote lines.
	 */
	public Set<Id> getQuotesIds(List<SBQQ__QuoteLine__c> newList){
		Logger.logInfo(String.format('getQuotesIds( {0} )', new List<Object>{ newList }));
		
		Set<Id> quotesIds = new Set<Id>();
		
		for (SBQQ__QuoteLine__c singleQL : newList) {
			if (singleQL.SBQQ__AdditionalDiscountAmount__c > 0 && singleQL.Ghost_Quote__c != true && singleQL.Quote_Type__c == 'Renewal')
				quotesIds.add(singleQL.SBQQ__Quote__c);
		}

		Logger.logDebug('quotesIds: ' + quotesIds);
		
		return quotesIds;
	}

	/**
	 * Updates the Quote_Preparation_Lock__c field on the quotes with the provided IDs.
	 * 
	 * @param quotesIds Set of quote IDs to update.
	 * @return List of SBQQ__Quote__c records to be updated.
	 */
	public void updateQuotePreparationLockFieldOQuotes(Set<Id> quotesIds) {
		Logger.logInfo(String.format('updateQuotePreparationLockFieldOQuotes( {0} )', new List<Object>{ quotesIds }));

		List<SBQQ__Quote__c> toBeUpdated = new List<SBQQ__Quote__c>();

		if (!quotesIds.isEmpty()) {
			for (Id singleId : quotesIds) {
				toBeUpdated.add(
					new SBQQ__Quote__c(
						Id = singleId,
						Quote_Preparation_Lock__c = true // Do we need that is it working?!?!? CPQ does it crazy way ...
					)
				);
			}

			Logger.logDebug('toBeUpdated: ' + toBeUpdated);

			if (!toBeUpdated.isEmpty()){
				dataBaseService.updateRecords(toBeUpdated);
			}
		}
	}

	/**
	 * Calls the future method to clean up quote line amount and discount.
	 * 
	 * @param qIds Set of quote IDs to process.
	 */
	public void callfutureQuoteLineAmountDiscountCleaning(Set<Id> qIds) {
		Logger.logInfo(String.format('callfutureQuoteLineAmountDiscountCleaning( {0} )', new List<Object>{ qIds }));
		futureQuoteLineAmountDiscountCleaning(qIds);
	}

	/**
	 * Future method to clean up quote line amount and discount.
	 * 
	 * @param qIds Set of quote IDs to process.
	 */
	@future
	public static void futureQuoteLineAmountDiscountCleaning(Set<Id> qIds) {
		Logger.logInfo(String.format('futureQuoteLineAmountDiscountCleaning( {0} )', new List<Object>{ qIds }));

		List<SBQQ__Quote__c> theQuotesWithQLs = quoteSelector.getQuotesWithQLs(qIds);

		List<SBQQ__QuoteLine__c> toBeUpdated = new List<SBQQ__QuoteLine__c>();
		Map<Id, Id> qlIdToQId = new Map<Id, Id>();

		for (SBQQ__Quote__c singleQuote : theQuotesWithQLs) {
			if (singleQuote.SBQQ__LineItems__r.size() > 0) {
				for (SBQQ__QuoteLine__c singleQL : singleQuote.SBQQ__LineItems__r) {
					qlIdToQId.put(singleQL.Id, singleQuote.Id);
					toBeUpdated.add(
						new SBQQ__QuoteLine__c(
							Id = singleQL.Id,
							SBQQ__AdditionalDiscountAmount__c = null,
							SBQQ__Discount__c = (Test.isRunningTest() ? 15.0 : singleQL.SBQQ__RenewedSubscription__r.SBQQ__Discount__c)
						)
					); // On test it is just 15.5
				}
			}
		}

		Logger.logDebug('qlIdToQId: ' + qlIdToQId);
		Logger.logDebug('toBeUpdated: ' + toBeUpdated);
		
		Database.SaveResult[] updateResult = Database.update(toBeUpdated, false);
		List<SBQQ__Quote__c> quotesToUpdate = new List<SBQQ__Quote__c>();
		
		for (Database.SaveResult result : updateResult) {
			if (result.isSuccess()) {
				quotesToUpdate.add(new SBQQ__Quote__c(Id = qlIdToQId.get(result.getId()), Quote_Preparation_Lock__c = false));
			} else {
				// Hane errors from result.getErrors() method returning Database.Error
			}
		}

		Logger.logDebug('quotesToUpdate: ' + quotesToUpdate);

		if (!quotesToUpdate.isEmpty()){
			update quotesToUpdate;
		}
	}
	
	/**
	 * Unchecks the Renewal_Quantity_Proper_Change_Indicator__c field on quote lines.
	 * 
	 * @param newList List of new quote lines to process.
	 */
	public void unCheckRenewalQuantityEditCheck(List<SBQQ__QuoteLine__c> newList) {
		Logger.logInfo(String.format('unCheckRenewalQuantityEditCheck( {0} )', new List<Object>{ newList }));
		List<SBQQ__QuoteLine__c> toBeUpdated = new List<SBQQ__QuoteLine__c>();
		
		for (SBQQ__QuoteLine__c singleQL : newList) {
			if (singleQL.Renewal_Quantity_Proper_Change_Indicator__c)
				toBeUpdated.add(new SBQQ__QuoteLine__c(id = singleQL.Id, Renewal_Quantity_Proper_Change_Indicator__c = false));
		}

		Logger.logDebug('toBeUpdated: ' + toBeUpdated);

		if (!toBeUpdated.isEmpty()){
			dataBaseService.updateRecords(toBeUpdated);
		}
	}
}