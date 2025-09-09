public class QuoteLineDetailsTriggerHandler extends TriggerHandler {
    private QuoteLineDetailsService quoteLineDetailsService;

    /**
     * Collection of newly inserted records from the trigger context
     */
    private List<Quote_Line_Detail__c> oldList;
    private List<Quote_Line_Detail__c> newList;

    public QuoteLineDetailsTriggerHandler() {
        this(SingletonFactory.getFactory());
    }

    public QuoteLineDetailsTriggerHandler(SingletonFactory singletonFactory) {
        this.oldList = (List<Quote_Line_Detail__c>) Trigger.old;
        this.newList = (List<Quote_Line_Detail__c>) Trigger.new;
        this.quoteLineDetailsService = (QuoteLineDetailsService) singletonFactory.getOrRegisterSingleton(
            QuoteLineDetailsService.class
        );
    }

    protected override void beforeInsert() {
        Set<Id> quoteLineIds = new Set<Id>(
            SObjectCollectionUtil.of(newList).pluckIds(Quote_Line_Detail__c.Quote_Line__c)
        );

        quoteLineDetailsService.saveDataLimitFromOriginalProduct(newList);
    }

    protected override void afterInsert() {
        Set<Id> quoteLineIds = new Set<Id>(
            SObjectCollectionUtil.of(newList).pluckIds(Quote_Line_Detail__c.Quote_Line__c)
        );

        quoteLineDetailsService.updateQuoteLineQuantity(quoteLineIds);
    }

    protected override void afterDelete() {
        Set<Id> quoteLineIds = new Set<Id>(
            SObjectCollectionUtil.of(oldList).pluckIds(Quote_Line_Detail__c.Quote_Line__c)
        );

        quoteLineDetailsService.updateQuoteLineQuantity(quoteLineIds);
    }

    protected override void afterUpdate() {
        Set<Id> quoteLineIds = new Set<Id>();
        quoteLineIds.addAll(SObjectCollectionUtil.of(newList).pluckIds(Quote_Line_Detail__c.Quote_Line__c));
        quoteLineIds.addAll(SObjectCollectionUtil.of(oldList).pluckIds(Quote_Line_Detail__c.Quote_Line__c));

        quoteLineDetailsService.updateQuoteLineQuantity(quoteLineIds);
    }
}