public class QuoteTriggerHandler extends TriggerHandler {
    
    private QuoteService quoteService;
    
    /**
     * Collection of trigger records from the trigger context
     */
    private List<SBQQ__Quote__c> triggerNew;
    private Map<Id, SBQQ__Quote__c> oldQuoteMap;

    /**
     * Constructor for QuoteTriggerHandler that initializes the quoteService
     * and sets the trigger context variables.
     */
	public QuoteTriggerHandler() {
        this(SingletonFactory.getFactory());
	}
    
    /**
     * Constructor for QuoteTriggerHandler that accepts a SingletonFactory
     * to retrieve the QuoteService instance.
     *
     * @param singletonFactory The factory to retrieve the QuoteService instance.
     */
    public QuoteTriggerHandler(SingletonFactory singletonFactory) {
        this.triggerNew = (List<SBQQ__Quote__c>) Trigger.new;
        this.oldQuoteMap = (Map<Id, SBQQ__Quote__c>) Trigger.oldMap;

		this.quoteService = (QuoteService) singletonFactory.getOrRegisterSingleton(QuoteService.class);
	}

    /**
     * Handles the before update trigger event for SBQQ__Quote__c records.
     * This method updates the Document Identifier fields for quotes that need it.
     * It checks the current and previous states of the quotes to determine if an update is necessary.
     */
    protected override void beforeUpdate () {
        List<SBQQ__Quote__c> quotesForDocumentIdentifierUpdate = quoteService.getQuotesForDocumentIdentifierUpdate(triggerNew, oldQuoteMap);
        
        if (!quotesForDocumentIdentifierUpdate.isEmpty()) {
            quoteService.setDocumentIdentifierFields(quotesForDocumentIdentifierUpdate);
        }
    }

    /**
     * Handles the after update trigger event for SBQQ__Quote__c records.
     * This method checks if any accounts need to be sent to the Contract API
     * based on the updated quotes and creates events accordingly.
     */
    protected override void afterUpdate () {
        List<Id> accountIdsToSendToContractApi = quoteService.getAccountIdsToSendToContractApi(triggerNew, oldQuoteMap);

        if (!accountIdsToSendToContractApi.isEmpty()) {
            ContractApiEventService.createEvents(accountIdsToSendToContractApi);
        }
    }

    /**
     * Handles the after insert trigger event for SBQQ__Quote__c records.
     * This method processes quotes that require QLD creation from AL and SL processing.
     */
    protected override void afterInsert () {
        List<Id> quoteIdsForQldFromAlProcessing = quoteService.getQuoteIdsForQldFromAlProcessing(triggerNew);
        List<Id> quoteIdsForQldFromSldProcessing = quoteService.getQuoteIdsForQldFromSldProcessing(triggerNew);

        if (!quoteIdsForQldFromAlProcessing.isEmpty()) {
            quoteService.createQldFromAl(quoteIdsForQldFromAlProcessing);
        }
        if (!quoteIdsForQldFromSldProcessing.isEmpty()) {
            quoteService.createQldFromSld(quoteIdsForQldFromSldProcessing);
        }
    }
}