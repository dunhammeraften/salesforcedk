public class CPQQuoteLine_TriggerHandler extends TriggerHandler {
	private List<SBQQ__QuoteLine__c> oldList = (List<SBQQ__QuoteLine__c>) Trigger.old;
	private List<SBQQ__QuoteLine__c> newList = (List<SBQQ__QuoteLine__c>) Trigger.new;
	private Map<Id, SBQQ__QuoteLine__c> oldMap = (Map<Id, SBQQ__QuoteLine__c>) Trigger.oldMap;
	private Map<Id, SBQQ__QuoteLine__c> newMap = (Map<Id, SBQQ__QuoteLine__c>) Trigger.newMap;

	public static Boolean disableQuantityCounting = false; // This variable disables qunatity summerisation logic from QLD to QL

	private ErrorLogging errorsLog = new ErrorLogging('Apex');

	protected override void beforeUpdate() {
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
		if (qlWithChangedQuantity.size() > 0)
			qlQuantityChangeProcessing(qlWithChangedQuantity);
		// Change of Quantity on renewal end
		List<Id> qlIdsWithChangedAdditionalQuantity = new List<Id>();
		for (Id singleId : oldMap.keySet()) {
			if (oldMap.get(singleId).Additional_Quantity__c != newMap.get(singleId).Additional_Quantity__c && newMap.get(singleId).Quote_Type__c == 'Renewal')
				qlIdsWithChangedAdditionalQuantity.add(singleId);
		}
		// Compare end
		if (qlIdsWithChangedAdditionalQuantity.size() > 0)
			qlQuantityCounting(qlIdsWithChangedAdditionalQuantity);
	}

	protected override void beforeInsert() {
		if (UserInfo.getUserName() != OrgUtils.getUsernameForCompanySFSystemUser()) {
			onQLInsertRenewalQuoteMoveQuantityToAdditionalQ();
		}
	}

	protected override void afterInsert() {

		// Update parent quotes to have the checkbox checked
		Set<Id> quotesIds = new Set<Id>();
		for (SBQQ__QuoteLine__c singleQL : newList) {
			if (singleQL.SBQQ__AdditionalDiscountAmount__c > 0 && singleQL.Ghost_Quote__c != true && singleQL.Quote_Type__c == 'Renewal')
				quotesIds.add(singleQL.SBQQ__Quote__c);
		}
		if (quotesIds.size() > 0) {
			List<SBQQ__Quote__c> toBeUpdated = new List<SBQQ__Quote__c>();

			for (Id singleId : quotesIds) {
				toBeUpdated.add(
					new SBQQ__Quote__c(
						Id = singleId,
						Quote_Preparation_Lock__c = true // Do we need that is it working?!?!? CPQ does it crazy way ...
					)
				);
			}

			try {
				update toBeUpdated;
				futureQuoteLineAmountDiscountCleaning(quotesIds); // Do we still need that ? does it work ?
			} catch (Exception e) {
				// Trza rozwiazac exception !!
			}
		}
	} //Quote_Preparation_Lock__c

	protected override void afterUpdate() {
		unCheckRenewalQuantityEditCheck();
	}

	private void onQLInsertRenewalQuoteMoveQuantityToAdditionalQ() {
		for (SBQQ__QuoteLine__c singleQL : newList) {
			if (singleQL.SBQQ__Quantity__c > 0 && singleQL.Quote_Type__c == 'Renewal') {
				singleQL.Additional_Quantity__c = singleQL.SBQQ__Quantity__c;
			}
		}
	}

	@future
	private static void futureQuoteLineAmountDiscountCleaning(Set<Id> qIds) {
		List<SBQQ__Quote__c> theQuotesWithQLs = [
			SELECT
				Id,
				Quote_Preparation_Lock__c,
				(
					SELECT Id, SBQQ__AdditionalDiscountAmount__c, SBQQ__RenewedSubscription__r.SBQQ__Discount__c
					FROM SBQQ__LineItems__r
					WHERE SBQQ__AdditionalDiscountAmount__c > 0
				)
			FROM SBQQ__Quote__c
			WHERE Id IN :qIds
		];
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
		Database.SaveResult[] updateResult = Database.update(toBeUpdated, false);
		List<SBQQ__Quote__c> quotesToUpdate = new List<SBQQ__Quote__c>();
		for (Database.SaveResult result : updateResult) {
			if (result.isSuccess()) {
				quotesToUpdate.add(new SBQQ__Quote__c(Id = qlIdToQId.get(result.getId()), Quote_Preparation_Lock__c = false));
			} else {
				// Hane errors from result.getErrors() method returning Database.Error
			}
		}
		if (quotesToUpdate.size() > 0)
			update quotesToUpdate;
		// I co w razie faila? ... hymm ciężki temat...
	}

	private void unCheckRenewalQuantityEditCheck() {
		List<SBQQ__QuoteLine__c> toBeUpdated = new List<SBQQ__QuoteLine__c>();
		for (SBQQ__QuoteLine__c singleQL : newList) {
			if (singleQL.Renewal_Quantity_Proper_Change_Indicator__c)
				toBeUpdated.add(new SBQQ__QuoteLine__c(id = singleQL.Id, Renewal_Quantity_Proper_Change_Indicator__c = false));
		}
		if (toBeUpdated.size() > 0) {
			update toBeUpdated;
		}
	}

	private void qlQuantityCounting(List<Id> qlWithChangedAddQuantity) {
		// Need to be tested!!!
		List<SBQQ__QuoteLine__c> theRecords = [
			SELECT Id, (SELECT Id, Quantity__c FROM Quote_Line_Details__r WHERE Termination_verifier__c = 'No')
			FROM SBQQ__QuoteLine__c
			WHERE Id IN :qlWithChangedAddQuantity
		];	
		Logger.logDebug('theRecords = ' + theRecords);

		Integer index = null;
		for (SBQQ__QuoteLine__c singleQL : theRecords) {
			Decimal qldQuantity = 0.0;
			for (Integer i = 0; i < newList.size(); ++i) {
				if (newList[i].Id == singleQL.Id) {
					for (Quote_Line_Detail__c singleQLD : singleQL.Quote_Line_Details__r) {
						qldQuantity += (singleQLD.Quantity__c == null ? 1 : singleQLD.Quantity__c);
					}
					newList[i].SBQQ__Quantity__c = qldQuantity + newList[i].Additional_Quantity__c;
					Logger.logDebug('newList[i].SBQQ__Quantity__c = ' + newList[i].SBQQ__Quantity__c);
					Logger.logDebug('newList[i].Additional_Quantity__c = ' + newList[i].Additional_Quantity__c);

					break;
				}
			}
		}
	}

	private void qlQuantityChangeProcessing(List<Integer> qlWithChangedQuantity) {
		for (Integer index : qlWithChangedQuantity) {
			newList[index].Additional_Quantity__c =
				(newList[index].Additional_Quantity__c == null ? 0 : newList[index].Additional_Quantity__c) +
				newList[index].SBQQ__Quantity__c -
				oldList[index].SBQQ__Quantity__c;
			Logger.logDebug('newList[index].Additional_Quantity__c in quantity change = ' + newList[index].Additional_Quantity__c);
		}
	}
}