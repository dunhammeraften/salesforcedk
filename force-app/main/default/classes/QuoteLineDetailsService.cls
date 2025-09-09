public class QuoteLineDetailsService {
    public static Boolean disableQuantityCounting = false; // This variable disables qunatity summerisation logic from QLD to QL

    @TestVisible
    private final DatabaseService dataBaseService;
    @TestVisible
    private final QuoteLineSelector quoteLineSelector;

    /**
     * Default constructor for QuoteLineDetailsService.
     * Uses SingletonFactory to get instances of DatabaseService and QuoteLineSelector.
     */
    public QuoteLineDetailsService() {
        this(SingletonFactory.getFactory());
    }

    /**
     * Constructor for QuoteLineDetailsService that allows passing a SingletonFactory.
     * This is useful for testing purposes to inject mock services.
     *
     * @param singletonFactory The SingletonFactory instance to use for retrieving services.
     */
    private QuoteLineDetailsService(SingletonFactory singletonFactory) {
        this.dataBaseService = (DatabaseService) singletonFactory.getOrRegisterSingleton(DatabaseService.class);

        this.quoteLineSelector = (QuoteLineSelector) singletonFactory.getOrRegisterSingleton(QuoteLineSelector.class);
    }

    /**
     * Saves the available monthly data limit from the original product to the Quote_Line_Detail__c records.
     * This method retrieves the related Quote Lines and updates the Original_Available_Monthly_Data_MB__c field
     * for each Quote_Line_Detail__c in the provided list.
     *
     * @param newList The list of Quote_Line_Detail__c records to update.
     */
    public void saveDataLimitFromOriginalProduct(List<Quote_Line_Detail__c> newList) {
        Logger.logInfo(String.format('saveDataLimitFromOriginalProduct( {0} )', new List<Object>{ newList }));
        Set<Id> qlIds = new Set<Id>();
        for (Quote_Line_Detail__c singleQLD : newList) {
            qlIds.add(singleQLD.Quote_Line__c);
        }

        Map<Id, SBQQ__QuoteLine__c> relatedQLsMap = new Map<Id, SBQQ__QuoteLine__c>(
            quoteLineSelector.getQuoteLinesByIds(qlIds)
        );

        for (Quote_Line_Detail__c singleQLD : newList) {
            singleQLD.Original_Available_Monthly_Data_MB__c = relatedQLsMap.get(singleQLD.Quote_Line__c)
                .SBQQ__Product__r.Available_Monthly_Data_MB__c;
        }
    }

    /**
     * Updates the quantity of Quote Lines based on the provided Quote Line IDs.
     * This method calculates the total quantity from related Quote_Line_Detail__c records
     * and updates the SBQQ__Quantity__c field on the SBQQ__QuoteLine__c records.
     *
     * @param quoteLineIdsToUpdate The set of Quote Line IDs to update.
     */
    public void updateQuoteLineQuantity( Set<Id> quoteLineIds ) {
        Logger.logInfo(String.format('updateQuoteLineQuantity( {0} )', new List<Object>{ quoteLineIds }));

        if (!disableQuantityCounting) {
            List<SBQQ__QuoteLine__c> quoteLinesToUpdate = new List<SBQQ__QuoteLine__c>();

            for ( AggregateResult r : quoteLineSelector.getQuantityOnQuoteLineDetailsByQuoteLineId(quoteLineIds) ) {
                Decimal recalculatedQuantity = 0;
                Decimal currentQuantity = 0;
                Id quoteLineId = (Id) r.get('Quote_Line__c');

                if(r.get('RecalculatedQuantity') != null){
                    recalculatedQuantity = (Decimal) r.get('RecalculatedQuantity');
                }else{
                    recalculatedQuantity = (Decimal) r.get('Counted');
                }

                if(r.get('CurrentQuantity') != null){
                    currentQuantity = (Decimal) r.get('CurrentQuantity');
                }

                if( quoteLineId != null && currentQuantity != recalculatedQuantity ){
                    quoteLinesToUpdate.add(
                        new SBQQ__QuoteLine__c(
                            Id = quoteLineId,
                            SBQQ__Quantity__c = recalculatedQuantity,
                            Renewal_Quantity_Proper_Change_Indicator__c = true
                        )
                    );
                }
            }

            dataBaseService.updateRecords(quoteLinesToUpdate);
        }
    }
}