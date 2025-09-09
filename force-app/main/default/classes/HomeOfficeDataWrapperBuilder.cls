/** 
 * Helper class for building a map of opportunity ids to HomeOfficeDataWrapper.
 * Used in the Home Office solution to ensure that Activation Lines are updated with data from Location Lines.
 * 
 * @author  Kirstine Nielsen
 * @since   07-05-2025
 * @see     https://jira.atlassian.teliacompany.net/browse/DKT-44508
 */
public with sharing class HomeOfficeDataWrapperBuilder {

    HomeOfficeFlowActionDAO homeOfficeFlowActionDAO;

    /**
     * Constructor accepting a HomeOfficeFlowActionDAO instance.
     */
    public HomeOfficeDataWrapperBuilder(HomeOfficeFlowActionDAO homeOfficeFlowActionDAO) {
        this.homeOfficeFlowActionDAO = homeOfficeFlowActionDAO;
    }

    /**
     * For each Opportunity we create HomeOfficeDataWrapper and populate lists, sets and maps properties, then we add
     * it to the instance map opportunityIdToHomeOfficeDataMap.
     */
    public Map<Id, HomeOfficeDataWrapper> buildOpportunityIdToHomeOfficeDataMap() {
        // map containing key: Opportunity Id and value: homeOfficeData
        Map<Id, HomeOfficeDataWrapper> opportunityIdToHomeOfficeDataMap = new Map<Id, HomeOfficeDataWrapper>();

        // we need a home office data wrapper for each Opportunity
        for (Id currentOpportunityId : homeOfficeFlowActionDAO.opportunityMap.keySet()) {
            Opportunity currentOpportunity = homeOfficeFlowActionDAO.opportunityMap.get(currentOpportunityId);
            HomeOfficeDataWrapper homeOfficeData = buildHomeOfficeDataWrapperForOpportunity(currentOpportunity);           

            // add opportunity id and map it to its corresponding homeOfficeDate
            opportunityIdToHomeOfficeDataMap.put(currentOpportunityId, homeOfficeData);
        }
        return opportunityIdToHomeOfficeDataMap;
    }  

    /**
     * Takes an opportunity as argument and from records related to it, it builds and returns a HomeOfficeDataWrapper.
     * 
     * @param currentOpportunity an Opportunity
     * @return HomeOfficeDataWrapper
     */
    private HomeOfficeDataWrapper buildHomeOfficeDataWrapperForOpportunity(Opportunity currentOpportunity) {
        Id currentOpportunityId = currentOpportunity.Id;
        HomeOfficeDataWrapper homeOfficeData = new HomeOfficeDataWrapper();

        // Quote Lines
        homeOfficeData.quoteLineMap = getQuoteLinesForSpecificOpportunityMap(currentOpportunityId);  
        homeOfficeData.concatenatedIdsToQuoteLinesMap = getConcatenatedIdsToQuoteLinesMap(homeOfficeData.quoteLineMap.values());               

        // activation lines
        homeOfficeData.activationLineMap = getActivationLinesForSpecificOpportunityMap(currentOpportunityId);  

        // activation
        homeOfficeData.activationMap = getActivationMap(homeOfficeData.activationLineMap.values());  

        // Location Line
        homeOfficeData.locationLineMap = getLocationLineForSpecificOpportunityMap(currentOpportunityId);  

        if (currentOpportunity.Agreement_Type__c.equalsIgnoreCase(HomeOfficeConstants.AGREEMENT_TYPE_FRAMEWORK)) {
            // Location Line to Activation Line (Framework)
            homeOfficeData.locationLineIdToActivationLineMap = getLocationLineIdToActivationLineMapFramework(
                homeOfficeData.activationLineMap.values(),   
                homeOfficeData.locationLineMap.keySet()  
            );       
        } else if (currentOpportunity.Agreement_Type__c.equalsIgnoreCase(HomeOfficeConstants.AGREEMENT_TYPE_SPECIFIED)) {
            // Location Line to Activation Line (Specified)
            homeOfficeData.quoteLineIdToActivationLinesMap = getQuoteLineIdToActivationLinesMap(homeOfficeData.activationLineMap.values());  
            
            homeOfficeData.locationLineIdToActivationLineMap = getLocationLineIdToActivationLinePairedViaQuoteLineMapSpecified(
                homeOfficeData.locationLineMap.values(),  
                homeOfficeData.quoteLineIdToActivationLinesMap
            );
        }   
        return homeOfficeData;
    }     

    /**
     * Returns a map of activations based on activations related to the activation lines passed in
     * 
     * @param List<Id> activation lines
     * @return Map<Id, Activation__c> activationMap
     */
    private Map<Id, Activation__c> getActivationMap(List<Activation_Line__c> activationLines) {
        Set<Id> activationIdSet = homeOfficeFlowActionDAO.getActivationIdSetFromActivationLines(activationLines);
        List<Activation__c> activations = filterAndGetActivationsFromSetOfActivationIds(activationIdSet);
        Map<Id, Activation__c> activationMap = new Map<Id, Activation__c>(activations);

        return activationMap;
    }

    /**
     * Go through list of Activation Lines and add to a map if its Location Line is populated. Use Location Line Id as
     * the key and the Activation Line record as the value.
     * (Activation Line is 1:1 to Location Line, meaning each Location Line can have one Activation Line
     * (not enforced on DB level)).
     * 
     * @param List<Activation_Line__c> activationLines
     * @param Set<Id> locationLineIdSet
     * @return Map<Id, Activation_Line__c> locationLineIdToActivationLineMap
     */
    private Map<Id, Activation_Line__c> getLocationLineIdToActivationLineMapFramework(
        List<Activation_Line__c> activationLines,
        Set<Id> locationLineIdSet) {

        Map<Id, Activation_Line__c> locationLineIdToActivationLineMap = new Map<Id, Activation_Line__c>();

        // loop the Activation Lines and if it has a Location Line lookup value, then we want to map it
        for (Activation_Line__c activationLine : activationLines) {            
            if (activationLine.Location_Line__c == null) {
                // we are not interested in this Activation Line if the Location Line is null 
                continue;  // go to the next Activation Line in the list
            }

            if (locationLineIdSet.contains(activationLine.Location_Line__c)) {
                locationLineIdToActivationLineMap.put(activationLine.Location_Line__c, activationLine);
            }
        }

        return locationLineIdToActivationLineMap;
    }      

    /**
     * Get a map of Location Line Ids to Activation Line.
     * It is built by comparing the Quote Line field on both Location Line and Activation Line, and if there is a match
     * then we add to the map. Meaning the Activation Line is not yet linked to the Location Line via the lookup field 
     * on Activation Line.
     * 
     * @param List<Activation_Line__c> activationLines
     * @param Map<Id, List<Activation_Line__c>>
     */
    private Map<Id, Activation_Line__c> getLocationLineIdToActivationLinePairedViaQuoteLineMapSpecified(
        List<Location_Line__c> locationLines,
        Map<Id, List<Activation_Line__c>> quoteLineIdToActivationLinesMap) {

        Map<Id, Activation_Line__c> locationLineIdToActivationLinePairedViaQuoteLineMapMap = new Map<Id, Activation_Line__c>();

        Set<Id> usedActivationLineIdSet = new Set<Id>();

        for (Location_Line__c locationLine : locationLines) {
            // check if Location Line has its lookup field populated
            if (locationLine.Quote_Line__c == null) {
                continue;
            }

            if (quoteLineIdToActivationLinesMap.containsKey(locationLine.Quote_Line__c)) {
                for (Activation_Line__c activationLine : quoteLineIdToActivationLinesMap.get(locationLine.Quote_Line__c)) {
                    // check that it is not a 'used' Activation Line
                    if (usedActivationLineIdSet.contains(activationLine.Id)) {
                        continue;
                    }
                    
                    locationLineIdToActivationLinePairedViaQuoteLineMapMap.put(locationLine.Id, activationLine);

                    // we have now used it, so add to the Set usedActivationLineIdSet
                    usedActivationLineIdSet.add(activationLine.Id);

                    break;
                }
            }
        } 
        return locationLineIdToActivationLinePairedViaQuoteLineMapMap;
    }

    /**
     * Get Map of Location Lines for a specific Opportunity.
     * @param opportunityId
     * @return Map<Id, Location_Line__c>
     */
    private Map<Id, Location_Line__c> getLocationLineForSpecificOpportunityMap(Id opportunityId) {
        Map<Id, Location_Line__c> locationLineForSpecificOpportunityMap = new Map<Id, Location_Line__c>();
        // loop the location lines and only add those where opportunity id matches
        for (Location_Line__c locationLine : homeOfficeFlowActionDAO.locationLinesAll) {
            if (locationLine.Opportunity__c == opportunityId) {
                // add to map
                locationLineForSpecificOpportunityMap.put(locationLine.Id, locationLine);
            }
        }
        return locationLineForSpecificOpportunityMap;
    } 

    /**
     * Return a subset of Activations that are in the set of Activation Ids.
     * @param activationIdSet
     * @return List<Activation__c>
     */
    private List<Activation__c> filterAndGetActivationsFromSetOfActivationIds(Set<Id> activationIdSet) {
        List<Activation__c> activations = new List<Activation__c>();
        for (Activation__c activation : homeOfficeFlowActionDAO.activationAllMap.values()) {  
            if (activationIdSet.contains(activation.Id)) {
                activations.add(activation);
            }
        }
        return activations;
    }

    /**
     * Return a subset of Activation Lines that are in the list of all Activation Lines.
     * @param opportunityId
     * @return List<Activation_Line__c>
     */
    private Map<Id, Activation_Line__c> getActivationLinesForSpecificOpportunityMap(Id opportunityId) {
        Map<Id, Activation_Line__c> activationLinesForSpecificOpportunityMap = new Map<Id, Activation_Line__c>();

        // loop the activation lines and only add those where opportunity id matches
        for (Activation_Line__c activationLine : homeOfficeFlowActionDAO.activationLineAllMap.values()) {
            // check if Activation Line has the opportunity id
            if (activationLine.Opportunity_ID__c == opportunityId) {
                // add to map
                activationLinesForSpecificOpportunityMap.put(activationLine.Id, activationLine);
            }
        }
        return activationLinesForSpecificOpportunityMap;
    }

    /**
     * Return a map of Quote Lines that is a subset of Quote Lines that are in the list of all Quote Lines.
     * @param opportunityId
     * @return Map<Id, SBQQ__QuoteLine__c>
     */
    private Map<Id, SBQQ__QuoteLine__c> getQuoteLinesForSpecificOpportunityMap(Id opportunityId) {
        Map<Id, SBQQ__QuoteLine__c> quoteLinesForSpecificOpportunityMap = new Map<Id, SBQQ__QuoteLine__c>();

        // loop the quotelines and only add those where opportunity id matches
        for (SBQQ__QuoteLine__c quoteLine : homeOfficeFlowActionDAO.quoteLineAllMap.values()) {  
            // check if Quote Line is associated with the opportunity id
            if (quoteLine.SBQQ__Quote__r.SBQQ__Opportunity2__r.Id == opportunityId) {
                // add to map
                quoteLinesForSpecificOpportunityMap.put(quoteLine.Id, quoteLine);
            }
        }
        return quoteLinesForSpecificOpportunityMap;
    }

    /**
     * Return a map of concatenated Ids to Quote Lines.
     * We concatenate Activation__c + '_' + SBQQ__Product__c from a Quote Line and put as key
     * 
     * @param quoteLines
     * @return Map<String, List<SBQQ__QuoteLine__c>>
     */
    private Map<String, List<SBQQ__QuoteLine__c>> getConcatenatedIdsToQuoteLinesMap(List<SBQQ__QuoteLine__c> quoteLines) {
        Map<String, List<SBQQ__QuoteLine__c>> concatenatedIdsToQuoteLinesMapToReturn = new Map<String, List<SBQQ__QuoteLine__c>>();

        for (SBQQ__QuoteLine__c quoteLine : quoteLines) {
            if (quoteLine.Activation__c == null || quoteLine.SBQQ__Product__c == null) {
                continue;
            }

            // make the key by concatenating Activation__c and SBQQ__Product__c
            String concatenatedId = quoteLine.Activation__c + '_' + quoteLine.SBQQ__Product__c;
            
            if (!concatenatedIdsToQuoteLinesMapToReturn.containsKey(concatenatedId)) {
                // make empty list
                List<SBQQ__QuoteLine__c> quoteLinesList = new List<SBQQ__QuoteLine__c>();
                // add the first item
                quoteLinesList.add(quoteLine);

                // put in map
                concatenatedIdsToQuoteLinesMapToReturn.put(concatenatedId, quoteLinesList);
            } else {
                // already exists, add to existing list
                concatenatedIdsToQuoteLinesMapToReturn.get(concatenatedId).add(quoteLine);
            }
        }
        return concatenatedIdsToQuoteLinesMapToReturn;
    } 

    /**
     * Return a map of Quote Line Ids to a list of associated Activation Lines, using the Activation Lines passed in
     * and their Quote Line lookup field.
     * 
     * @param activationLines
     * @return Map<Id, List<Activation_Line__c>>
     */
    public Map<Id, List<Activation_Line__c>> getQuoteLineIdToActivationLinesMap(List<Activation_Line__c> activationLines) {
        Map<Id, List<Activation_Line__c>> quoteLineIdToActivationLinesMap = new Map<Id, List<Activation_Line__c>>();

        for (Activation_Line__c activationLine : activationLines) {
            // we are only interested in Activation Lines where their Quote Line lookup field is populated
            if (activationLine.Quote_Line__c == null) {
                continue;
            }           

            // put in map if not there
            if (!quoteLineIdToActivationLinesMap.containsKey(activationLine.Quote_Line__c)) {
                List<Activation_Line__c> activationLineList = new List<Activation_Line__c>();  // new list to add to map
                activationLineList.add(activationLine);  // add Activation Line to list
                quoteLineIdToActivationLinesMap.put(activationLine.Quote_Line__c, activationLineList);
            } else {
                // key already exists, add Activation Line to list
                quoteLineIdToActivationLinesMap.get(activationLine.Quote_Line__c).add(activationLine);
            }
        }

        return quoteLineIdToActivationLinesMap;        
    } 
}