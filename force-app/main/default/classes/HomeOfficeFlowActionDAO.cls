/** 
 * DAO class that helps provide the necessary data for the Home Office Flow Action.
 * Used in the Home Office solution to ensure that Activation Lines are updated with data from Location Lines.
 * 
 * @author  Kirstine Nielsen
 * @since   07-05-2025
 * @see     https://jira.atlassian.teliacompany.net/browse/DKT-44508
 */
public without sharing class HomeOfficeFlowActionDAO {    
    
    // we are only interested in products where 'Telia Product Id' (ProductAPI_Telia_Product_Id__c) is not null
    public static List<Product2> products = ProductSelector.getAllProductsHavingTeliaProductId();
    // map of teliaProductIdString and product
    public static Map<String, Product2> teliaProductIdStringToProductMap = getTeliaProductIdStringToProductMap(products);

    // Opportunities
    public Map<Id, Opportunity> opportunityMap;

    // Quote Lines
    public Map<Id, SBQQ__QuoteLine__c> quoteLineAllMap = new Map<Id, SBQQ__QuoteLine__c>();

    // Activation Lines
    public Map<Id, Activation_Line__c> activationLineAllMap =  new Map<Id, Activation_Line__c>();

    // Activation
    public Map<Id, Activation__c> activationAllMap = new Map<Id, Activation__c>();

    // Location Lines
    public List<Location_Line__c> locationLinesAll = new List<Location_Line__c>();
    
    /**
     * constructor accepting a list of opportunities
     */
    public HomeOfficeFlowActionDAO(List<Opportunity> opportunities) {
        // opportunity
        this.opportunityMap = new Map<Id, Opportunity>(opportunities);

        // quote lines
        this.quoteLineAllMap = getQuoteLineMap(this.opportunityMap.keySet());

        // activation lines
        this.activationLineAllMap = getActivationLineMap(this.opportunityMap.keySet());        

        // activations
        this.activationAllMap = getActivationMap(this.activationLineAllMap.values());

        // Location Lines
        this.locationLinesAll = retrieveLocationLines(this.opportunityMap.keySet());
    } 

    /**
     * Returns a map of activations based on activations related to the activation lines passed in
     * 
     * @param List<Id> activation lines
     * @return Map<Id, Activation__c> activationMap
     */
    private Map<Id, Activation__c> getActivationMap(List<Activation_Line__c> activationLines) {
        Set<Id> activationIdSet = getActivationIdSetFromActivationLines(activationLines);
        List<Activation__c> activations = new List<Activation__c>();
        activations = ActivationSelector.getHomeOfficeActivationByIds(activationIdSet);
        Map<Id, Activation__c> activationMapToReturn = new Map<Id, Activation__c>(activations);
        return activationMapToReturn;
    }

    /**
     * Returns Activation Line Map of records where the opportunity id matches an opportunity id in set passed in.
     * @param opportunityIdSet 
     * @return map of activation lines
     */
    private Map<Id, Activation_Line__c> getActivationLineMap(Set<Id> opportunityIdSet) {
        List<Activation_Line__c> activationLines = new List<Activation_Line__c>();
        activationLines = ActivationLineSelector.getHomeOfficeActivationLinesByOpportunityIds(opportunityIdSet);
        Map<Id, Activation_Line__c> activationLinesToReturnMap = new Map<Id, Activation_Line__c>(activationLines);
        return activationLinesToReturnMap;
    }

    /**
     * Returns set of activation Ids from list of Activation Lines
     * @param activationLines
     * @return set of activation Ids
     */
    public Set<Id> getActivationIdSetFromActivationLines(List<Activation_Line__c> activationLines) {
        Set<Id> activationIdSetToReturn = new Set<Id>();

        for (Activation_Line__c activationLine : activationLines) {
            // put in set
            activationIdSetToReturn.add(activationLine.Activation__c);
        }
        return activationIdSetToReturn;
    }

    /**
     * Retrieve Location Lines from DB that matches the Opportunity Id's in the set
     * passed to method, and that has valid address wash status.
     * 
     * @param opportunityIdSet
     * @return List<Location_Line__c>
     */
    private List<Location_Line__c> retrieveLocationLines(Set<Id> opportunityIdSet) {
        List<Id> opportunityIdList = new List<Id>(opportunityIdSet);    
        List<Location_Line__c> locationLinesToReturn = LocationLineSelector.getValidLocationLinesByOpportunityIds(
            opportunityIdList
        );
        return locationLinesToReturn;
    }

    /**
     * Returns Quote Line Map of records:
     * - that matches the Opportunity Id's in the set passed to method
     * - where both Activation and Product are populated
     * - of record type Activation Quote
     * 
     * @param opportunityIdSet
     * @return Map<Id, SBQQ__QuoteLine__c>
     */
    private Map<Id, SBQQ__QuoteLine__c> getQuoteLineMap(Set<Id> opportunityIdSet) { 
        List<SBQQ__QuoteLine__c> quoteLines = new List<SBQQ__QuoteLine__c>();
        quoteLines = QuoteLineSelector.getQuoteLinesByOpportunityIds(opportunityIdSet);
        Map<Id, SBQQ__QuoteLine__c> quoteLineMapToReturn = new Map<Id, SBQQ__QuoteLine__c>(quoteLines);
        return quoteLineMapToReturn;
    }

    /**
     * Returns map where ProductAPI_Telia_Product_Id__c is the key and the Product is the value
     * 
     * @param products
     * @return Map<String, Product2>
     */
    private static Map<String, Product2> getTeliaProductIdStringToProductMap(List<Product2> products) {
        Map<String, Product2> teliaProductIdStringToProductMap = new Map<String, Product2>();

        for (Product2 product : products) {
            // sanity check that ProductAPI_Telia_Product_Id__c is not empty and that the map doesn't already contain this key
            if (String.isNotEmpty(product.ProductAPI_Telia_Product_Id__c) && 
                !teliaProductIdStringToProductMap.containsKey(product.ProductAPI_Telia_Product_Id__c)) {
                teliaProductIdStringToProductMap.put(product.ProductAPI_Telia_Product_Id__c, product);
            }
        }

        return teliaProductIdStringToProductMap;
    }
}