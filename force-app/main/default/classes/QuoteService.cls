public class QuoteService {
	@TestVisible
	private static final Id ACTIVATION_QUOTE_RECORD_TYPE_ID = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByDeveloperName()
		.get('Activation_Quote')
		.getRecordTypeId();
	@TestVisible
	private static final String TYPE_RENEWAL = 'Renewal';
	@TestVisible
	private static final String STATUS_READY_FOR_CUSTOMER_REVIEW = 'Ready_for_Customer_Review';
	@TestVisible
	private static final String STATUS_SIGNED = 'Signed';
	@TestVisible
	private static String qldFromAlCronId;
	@TestVisible
	private static String qldFromSldCronId;

	/**
	 * Gets a list of quotes that need to have their Document Identifier fields updated.
	 *
	 * @param quoteNewList Used to identify the current state of the quote.SBQQ__Status__c
	 * @param quoteOldMap Used to identify the previous state of the quote.SBQQ__Status__c
	 * @return A list of quotes that need to have their Document Identifier fields updated.
	 */
	public List<SBQQ__Quote__c> getQuotesForDocumentIdentifierUpdate(
		List<SBQQ__Quote__c> quoteNewList,
		Map<Id, SBQQ__Quote__c> quoteOldMap
	) {
		Logger.logInfo(
			String.format('getQuotesForDocumentIdentifierUpdate( {0}, {1} )', new List<Object>{ quoteNewList, quoteOldMap })
		);

		List<SBQQ__Quote__c> quotesForDocumentIdentifierUpdate = new List<SBQQ__Quote__c>();

		for (SBQQ__Quote__c quote : quoteNewList) {
			if (
				quote.SBQQ__Status__c == STATUS_READY_FOR_CUSTOMER_REVIEW &&
				quoteOldMap.get(quote.Id).SBQQ__Status__c != quote.SBQQ__Status__c &&
				quote.RecordTypeId != ACTIVATION_QUOTE_RECORD_TYPE_ID
			) {
				quotesForDocumentIdentifierUpdate.add(quote);
			}
		}

		return quotesForDocumentIdentifierUpdate;
	}

	/**
	 * Sets the Document Identifier fields on the quotes
	 *
	 * @param quotes A list of quotes that need to have their Document Identifier fields updated.
	 */
	public void setDocumentIdentifierFields(List<SBQQ__Quote__c> quotes) {
		Logger.logInfo(String.format('setDocumentIdentifierFields( {0} )', new List<Object>{ quotes }));

		List<SBQQ__Quote__c> quotesWithLines = QuoteSelector.getQuotesWithLinesHavingProductWithDocumentIdentifierFromQuoteList(
			quotes
		);

		Map<Id, Set<String>> quoteId2IdentifiersToTrue = new Map<Id, Set<String>>();
		for (SBQQ__Quote__c quote : quotesWithLines) {
			Set<String> identifierFieldsToTrue = new Set<String>();
			for (SBQQ__QuoteLine__c line : quote.SBQQ__LineItems__r) {
				//Document_Identifier__c is a multi-select picklist so needs splitting to compare each value with the metadata mappings
				identifierFieldsToTrue.addAll(line.SBQQ__Product__r.Document_Identifier__c.split(';'));
			}
			quoteId2IdentifiersToTrue.put(quote.Id, identifierFieldsToTrue);
		}

		List<Document_Identifier__mdt> documentIdentifierMappings = MetadataSelector.getDocumentIdentifierMappings();

		Map<String, String> documentIdentifier2QuoteField = new Map<String, String>();
		for (Document_Identifier__mdt record : documentIdentifierMappings) {
			documentIdentifier2QuoteField.put(record.Product_Document_Identifier__c, record.Label);
		}

		Map<Id, SBQQ__Quote__c> quoteId2QuoteToUpdate = new Map<Id, SBQQ__Quote__c>(quotes);
		for (Id key : quoteId2IdentifiersToTrue.keySet()) {
			SBQQ__Quote__c quote = quoteId2QuoteToUpdate.get(key);
			Set<String> identifierFieldsToTrue = quoteId2IdentifiersToTrue.get(key);
			for (String documentIdentifier : documentIdentifier2QuoteField.keySet()) {
				if (identifierFieldsToTrue.contains(documentIdentifier)) {
					quote.put(documentIdentifier2QuoteField.get(documentIdentifier), true);
				} else {
					quote.put(documentIdentifier2QuoteField.get(documentIdentifier), false);
				}
			}
		}
	}

	/**
	 * Gets a list of quotes that need to have their Document Identifier fields updated.
	 *
	 * @param quoteNewList Used to identify the current state of the quote.
	 * @param quoteOldMap Used to identify the previous state of the quote.
	 * @return A list of Account ids that need to be sent to the Contract API.
	 */
	public List<Id> getAccountIdsToSendToContractApi(
		List<SBQQ__Quote__c> quoteNewList,
		Map<Id, SBQQ__Quote__c> quoteOldMap
	) {
		Logger.logInfo(
			String.format('getAccountIdsToSendToContractApi( {0},{1} )', new List<Object>{ quoteNewList, quoteOldMap })
		);

		List<Id> accountIdsToSendToContractApi = new List<Id>();

		for (SBQQ__Quote__c quote : quoteNewList) {
			if (
				// if Status is changed to Signed
				quote.SBQQ__Status__c == STATUS_SIGNED &&
				quoteOldMap.get(quote.Id).SBQQ__Status__c != STATUS_SIGNED ||
				// if Status is changed away from Signed
				quote.SBQQ__Status__c != STATUS_SIGNED &&
				quoteOldMap.get(quote.Id).SBQQ__Status__c == STATUS_SIGNED ||
				// if Manual Valid Until is changed to the past from null, today or a future date
				quote.Manual_Valid_Until__c < System.today() &&
				(quoteOldMap.get(quote.Id).Manual_Valid_Until__c == null ||
				quoteOldMap.get(quote.Id).Manual_Valid_Until__c >= System.today()) ||
				// if Manual Valid Until is changed to today or a future date or null from a past date
				(quote.Manual_Valid_Until__c >= System.today() || quote.Manual_Valid_Until__c == null) &&
				quoteOldMap.get(quote.Id).Manual_Valid_Until__c < System.today()
			) {
				accountIdsToSendToContractApi.add(quote.SBQQ__Account__c);
			}
		}

		return accountIdsToSendToContractApi;
	}

	/**
	 * Gets a list of quotes that need to be processed for Quote Line Details creation from Activation Lines (AL).
	 *
	 * @param quoteNewList A list of quotes that need to be processed for Quote Line Details creation.
	 * @return A list of Quote Ids that need to be processed for Quote Line Details creation from AL (Activation Lines).
	 */
	public List<Id> getQuoteIdsForQldFromAlProcessing(List<SBQQ__Quote__c> quoteNewList) {
		Logger.logInfo(String.format('getQuoteIdsForQldFromAlProcessing( {0} )', new List<Object>{ quoteNewList }));

		List<Id> quoteIdsForQldFromAlProcessing = new List<Id>();

		for (SBQQ__Quote__c quote : quoteNewList) {
			if (quote.RecordTypeId == ACTIVATION_QUOTE_RECORD_TYPE_ID) {
				quoteIdsForQldFromAlProcessing.add(quote.Id);
			}
		}

		return quoteIdsForQldFromAlProcessing;
	}
	/**
	 * Gets a list of quotes that need to be processed for Quote Line Details creation from Subscription Lines (SL).
	 *
	 * @param quoteNewList A list of quotes that need to be processed for Quote Line Details creation.
	 * @return A list of Quote Ids that need to be processed for Quote Line Details creation from SL (Subscription Lines).
	 */
	public List<Id> getQuoteIdsForQldFromSldProcessing(List<SBQQ__Quote__c> quoteNewList) {
		Logger.logInfo(String.format('getQuoteIdsForQldFromSldProcessing( {0} )', new List<Object>{ quoteNewList }));

		List<Id> quoteIdsForQldFromSldProcessing = new List<Id>();

		for (SBQQ__Quote__c quote : quoteNewList) {
			if (
				quote.SBQQ__Type__c == TYPE_RENEWAL &&
				quote.Ghost_Quote__c == false &&
				quote.RecordTypeId != ACTIVATION_QUOTE_RECORD_TYPE_ID
			) {
				quoteIdsForQldFromSldProcessing.add(quote.Id);
			}
		}

		return quoteIdsForQldFromSldProcessing;
	}

	/**
	 * Creates Quote Line Details from Activation Lines (AL) for the given list of Quote Ids.
	 *
	 * @param quoteIds A list of Quote Ids for which Quote Line Details need to be created from AL.
	 */
	public void createQldFromAl(List<Id> quoteIds) {
		Logger.logInfo(String.format('createQldFromAl( {0} )', new List<Object>{ quoteIds }));

		Quote_line_detail_Create processBatch = new Quote_line_detail_Create();
		processBatch.recordsId = quoteIds;
		qldFromAlCronId = System.scheduleBatch(
			processBatch,
			'Creating quote line details from AL' + quoteIds + System.now(),
			3
		);
	}

	/**
	 * Creates Quote Line Details from Subscription Lines (SL) for the given list of Quote Ids.
	 *
	 * @param quoteIds A list of Quote Ids for which Quote Line Details need to be created from SL.
	 */
	public void createQldFromSld(List<Id> quoteIds) {
		Logger.logInfo(String.format('createQldFromSld( {0} )', new List<Object>{ quoteIds }));

		Quote_line_detail_Create_Subs processBatch = new Quote_line_detail_Create_Subs();
		processBatch.recordsId = quoteIds;
		qldFromSldCronId = System.scheduleBatch(
			processBatch,
			'Creating quote line details from SL' + quoteIds + System.now(),
			3
		);
	}

	/**
	 * Updates previous approval tracking fields for Discount and Subsidy independently.
	 */
	public void updateApprovalTrackingFields(List<SBQQ__Quote__c> newQuotes, Map<Id, SBQQ__Quote__c> oldQuotes) {
		for (SBQQ__Quote__c q : newQuotes) {
			SBQQ__Quote__c oldQ = oldQuotes.get(q.Id);
			if (oldQ == null)
				continue;

			Boolean requiresNewDiscountApproval = false;
			Boolean requiresNewSubsidyApproval = false;

			// --- DISCOUNT LOGIC ---
			if (q.Max_Discount_Approval_Level__c > oldQ.Max_Discount_Approval_Level__c) {
				requiresNewDiscountApproval = true;
			} else if (
				q.Max_Discount_Approval_Level__c == oldQ.Max_Discount_Approval_Level__c &&
				q.Discount_Approval_Level_Count__c > oldQ.Discount_Approval_Level_Count__c
			) {
				requiresNewDiscountApproval = true;
			}

			// --- SUBSIDY LOGIC ---
			if (q.Max_Subsidy_Approval_Level__c > oldQ.Max_Subsidy_Approval_Level__c) {
				requiresNewSubsidyApproval = true;
			} else if (
				q.Max_Subsidy_Approval_Level__c == oldQ.Max_Subsidy_Approval_Level__c &&
				q.Subsidy_Approval_Level_Count__c > oldQ.Subsidy_Approval_Level_Count__c
			) {
				requiresNewSubsidyApproval = true;
			}

			// Update previous fields
			q.Previous_Max_Discount_Approval_Level__c = oldQ.Max_Discount_Approval_Level__c;
			q.Previous_Discount_Approval_Level_Count__c = oldQ.Discount_Approval_Level_Count__c;

			q.Previous_Max_Subsidy_Approval_Level__c = oldQ.Max_Subsidy_Approval_Level__c;
			q.Previous_Subsidy_Approval_Level_Count__c = oldQ.Subsidy_Approval_Level_Count__c;

			// Set helper flags
			q.Requires_New_Discount_Approval__c = requiresNewDiscountApproval;
			q.Requires_New_Subsidy_Approval__c = requiresNewSubsidyApproval;
		}
	}
}
