public class QuoteLineTriggerHandler extends TriggerHandler {
    /**
     * Singleton instance of the QuoteLineService
     */
	private final QuoteLineService quoteLineService;
    
    /**
     * Collection of trigger records from the trigger context
     */
    private Map<Id, SBQQ__QuoteLine__c> oldMap;
	private Map<Id, SBQQ__QuoteLine__c> newMap;
	private List<SBQQ__QuoteLine__c> newList;
	private List<SBQQ__QuoteLine__c> oldList;

	/**
	 * Constructor for QuoteLineTriggerHandler that accepts a QuoteLineService instance.
	 *
	 * @param quoteLineService The QuoteLineService instance to be used by this handler.
	 */
	@TestVisible
    private QuoteLineTriggerHandler(QuoteLineService quoteLineService) {
        this.quoteLineService = quoteLineService;
    }
	
    /**
     * Constructor for QuoteLineTriggerHandler that initializes the quoteLineService
     * and sets the trigger context variables.
     */
	public QuoteLineTriggerHandler() {
        this(SingletonFactory.getFactory());
    }
    
    /**
     * Constructor for QuoteLineTriggerHandler that accepts a SingletonFactory
     * to retrieve the QuoteLineService instance.
     *
     * @param singletonFactory The factory to retrieve the QuoteLineService instance.
     */
    private QuoteLineTriggerHandler(SingletonFactory singletonFactory) {
		Logger.logInfo(String.format('QuoteLineTriggerHandler( {0} )', new List<Object>{ singletonFactory }));
		Logger.logDebug('Trigger.new: ' + Trigger.new);
		Logger.logDebug('Trigger.old: ' + Trigger.old);
		this.newList = (List<SBQQ__QuoteLine__c>) Trigger.new;
		this.oldList = (List<SBQQ__QuoteLine__c>) Trigger.old;
        this.newMap = (Map<Id, SBQQ__QuoteLine__c>) Trigger.newMap;
        this.oldMap = (Map<Id, SBQQ__QuoteLine__c>) Trigger.oldMap;
		
        this.quoteLineService = (QuoteLineService) singletonFactory.getOrRegisterSingleton(QuoteLineService.class);
    }

	protected override void beforeUpdate() {
		// Change of Quantity on renewal
		quoteLineService.qlQuantityChangeProcessing(newList, oldList);		
		
		// Change of Quantity on renewal end
		quoteLineService.qlQuantityCounting(oldMap, newMap);
	}

	protected override void beforeInsert() {
		quoteLineService.onQLInsertRenewalQuoteMoveQuantityToAdditionalQ(newList);
	}

	protected override void afterInsert() {
		// Update parent quotes to have the checkbox checked
		Set<Id> quotesIds = quoteLineService.getQuotesIds(newList);
		
		quoteLineService.updateQuotePreparationLockFieldOQuotes(quotesIds);

		quoteLineService.callfutureQuoteLineAmountDiscountCleaning(quotesIds); // Do we still need that ? does it work ?
	}

	protected override void afterUpdate() {
		quoteLineService.unCheckRenewalQuantityEditCheck(newList);
	}
}