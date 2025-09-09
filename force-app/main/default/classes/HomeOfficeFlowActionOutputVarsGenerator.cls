/** 
 * Class that generates Home Office Flow Action OutputVars.
 * 
 * @author  Kirstine Nielsen
 * @since   07-05-2025
 * @see     https://jira.atlassian.teliacompany.net/browse/DKT-44508
 */
public with sharing class HomeOfficeFlowActionOutputVarsGenerator {

    /**
     * Generates a list of outputVars for the HomeOfficeFlowAction, one for each opportunity in the list passed to the
     * method.
     * 
     * @param  opportunities List of Opportunity records.
     * @return list of HomeOfficeFlowAction.OutputVariables
     */
    public static List<HomeOfficeFlowAction.OutputVariables> generateListOfOutputVars(List<Opportunity> opportunities) {
		List<HomeOfficeFlowAction.OutputVariables> outputVarsList = new List<HomeOfficeFlowAction.OutputVariables>();

        // we need instance of HomeOfficeFlowActionDAO   
        HomeOfficeFlowActionDAO homeOfficeFlowActionDAO = new HomeOfficeFlowActionDAO(opportunities);

        // now get an instance of HomeOfficeDataWrapperBuilder
        HomeOfficeDataWrapperBuilder homeOfficeDataWrapperBuilder = new HomeOfficeDataWrapperBuilder(homeOfficeFlowActionDAO);

        // build the opportunity id to HomeOfficeDataWrapper map
        Map<Id, HomeOfficeDataWrapper> opportunityIdToHomeOfficeDataMap = homeOfficeDataWrapperBuilder.buildOpportunityIdToHomeOfficeDataMap();

		for (Opportunity inputOpportunity : opportunities) {
            // we check that the Agreement Type is either Framework or Specified, else we are not happy
            if (String.isEmpty(inputOpportunity.Agreement_Type__c) || 
                (!inputOpportunity.Agreement_Type__c.equalsIgnoreCase(HomeOfficeConstants.AGREEMENT_TYPE_FRAMEWORK) && 
                !inputOpportunity.Agreement_Type__c.equalsIgnoreCase(HomeOfficeConstants.AGREEMENT_TYPE_SPECIFIED))) {
                // when neither Framework nor Specified   
                throw new HomeOfficeFlowActionOutputVarsGeneratorException(HomeOfficeConstants.ERROR_MESSAGE_AGREEMENT_TYPE);
            }

            // we want the HomeOfficeDataWrapper instance for the specific Opportunity Id 
            HomeOfficeDataWrapper homeOfficeData = opportunityIdToHomeOfficeDataMap.get(inputOpportunity.Id);
            
            // prep outputVars for current Opportunity
            HomeOfficeFlowAction.OutputVariables outputVars = new HomeOfficeFlowAction.OutputVariables();

            // check if there are any Location Lines associated with current Opportunity
            if (homeOfficeData.locationLineMap.size() > 0) {
                outputVars = modifyLocationLinesAndActivationLines(homeOfficeData);                
            }

            outputVarsList.add(outputVars);
		}
        return outputVarsList;
    }

    /**
     * Modifies the Activation Line, Location Line, associated Quote Lines, and Activation and adds them to lists on the
     * OutputVariables to be returned.
     * 
     * @param locationLineMap
     * @param locationLineIdToActivationLineMap
     * @return HomeOfficeFlowAction.OutputVariables
     */
    private static HomeOfficeFlowAction.OutputVariables modifyLocationLinesAndActivationLines(HomeOfficeDataWrapper homeOfficeData) {

        // build an OutputVariables per Opportunity
        HomeOfficeFlowAction.OutputVariables outputVars = new HomeOfficeFlowAction.OutputVariables();

        Set<Id> quoteLineIdSet = new Set<Id>();  // to keep track

        // for each Location Line associated to one specific Opportunity we want to 'work' on the matching Activation Line
        for (Location_Line__c locationLine : homeOfficeData.locationLineMap.values()) {

            // we continue to next item in Location Line list if there is no Activation Line pair
            if (!homeOfficeData.locationLineIdToActivationLineMap.containsKey(locationLine.Id)) {
                continue;  // go to next item in Location Line list
            }

            // a matching Activation Line is found 
            Activation_Line__c activationLine = homeOfficeData.locationLineIdToActivationLineMap.get(locationLine.Id);
            // check if picklist field Subscription_product__c on the Location Line is blank or null
            if (String.isEmpty(locationLine.Subscription_product__c)) {                
                outputVars.activationLinesToDelete.add(activationLine);  // eventually we want to delete the Activation Line
                continue;  // go to next item in Location Line list
            }
            
            // We are now sure that the locationLine.Subscription_product__c has a value like i.e. 'FIBHOF10'

            // Set OTC (one time charge) fields to false and wipe Home_Office_OTC_Product__c
            resetActivationLineFields(activationLine);                    
            switchActivationLineVasChxtFieldsToTrueOnMatch(activationLine, locationLine.OTC_product__c);  // switch checkboxes on match

            Id productId = getProductId(activationLine, locationLine);  // we will eventually assign it to activationLine.Manual_Product__c
            Id quoteLineId = getQuoteLineId(activationLine, productId, homeOfficeData);  // we will eventually assign it to activationLine.Quote_line__c

            HomeOfficeParamHelper paramHelper = new HomeOfficeParamHelper(locationLine, activationLine, productId, quoteLineId, homeOfficeData);

            // assign the values to Activation Line
            assignLocationLineValuesToActivationLine(paramHelper);

            outputVars.activationLinesToUpdate.add(activationLine);  // add to list we later pass back to caller

            // if lookup field Quote_Line__c on Location Line is not populated
            if (locationLine.Quote_Line__c == null) {
                // populate Quote Line
                updateQuoteLineOnLocationLine(paramHelper, quoteLineIdSet, outputVars);
            }

            // we only need to set Activation record once
            if (outputVars.activationToUpdate == null && homeOfficeData.activationMap.containsKey(activationLine.Activation__c)) {                    
                outputVars.activationToUpdate = setNumberOfLocationLinesOnActivationRecord(homeOfficeData, activationLine);
            }

        }        
        return outputVars;
    }

    /**
     * Update the Location Line in the paramHelper with the Quote Line from the paramHelper.
     * Additionally set the Quote Line's Activation_Created__ to true.
     * Then add these lines to the outputVars.locationLinesToUpdate and outputVars.quoteLinesToUpdate.
     * 
     * @param paramHelper 
     * @param quoteLineIdSet 
     * @param outputVars
     */
    private static void updateQuoteLineOnLocationLine(
        HomeOfficeParamHelper paramHelper, 
        Set<Id> quoteLineIdSet, 
        HomeOfficeFlowAction.OutputVariables outputVars) {

        paramHelper.locationLine.Quote_Line__c = paramHelper.quoteLineId;  // populate

        // Save Location Line for later update
        outputVars.locationLinesToUpdate.add(paramHelper.locationLine);

        if (!quoteLineIdSet.contains(paramHelper.quoteLineId)) {
            // Save quoteLineId in Set
            quoteLineIdSet.add(paramHelper.quoteLineId);

            // Activation Requested for Quote Line
            if (paramHelper.homeOfficeData.quoteLineMap.containsKey(paramHelper.quoteLineId)) {
                paramHelper.homeOfficeData.quoteLineMap.get(paramHelper.quoteLineId).Activation_Created__c = true;
                // Save Quote Line in list
                outputVars.quoteLinesToUpdate.add(paramHelper.homeOfficeData.quoteLineMap.get(paramHelper.quoteLineId));
            }
        }
    }

    /**
     * Return the Manual_Product__c from the Activation Line passed in if the Manual_Product__c is not null, 
     * else find a Product record where its teliaProductId (ProductAPI_Telia_Product_Id__c) matches the 
     * Subscription_product__c on the Location Line passed in, and return the Product Id.
     * 
     * @param activationLine Activation Line record to find the Manual_Product__c for.
     * @param locationLine Location Line record from which we use its Subscription_product__c to find Product.
     * @return productId
     */
    private static Id getProductId(Activation_Line__c activationLine, Location_Line__c locationLine) {
        Id productId = activationLine.Manual_Product__c;
        // check whether Manual_Product__c lookup field on the Activation Line is populated Activation Line
        if (productId == null) {
            // find a Product where its ProductAPI_Telia_Product_Id__c matches the locationLine.Subscription_product__c
            if (HomeOfficeFlowActionDAO.teliaProductIdStringToProductMap.containsKey(locationLine.Subscription_product__c)) {
                productId = HomeOfficeFlowActionDAO.teliaProductIdStringToProductMap.get(locationLine.Subscription_product__c).Id;
                
            }
        }
        return productId;
    }

    /**
     * Returns the Quote_line__c found on the Activation Line passed in if its Quote_line__c is not null, 
     * else find a Quote Line record where:
     *  - its Activation__c matches the Activation__c on the Activation Line passed in AND
     *  - its SBQQ__Product__c matches the productId passed in
     * and return its Id.
     * 
     * @param activationLine Activation Line record to find the Quote Line for.
     * @param productId Product Id to find the Quote Line for.
     * @return Quote Line Id.
     */
    private static Id getQuoteLineId(Activation_Line__c activationLine, Id productId, HomeOfficeDataWrapper homeOfficeData) {
        Id quoteLineId = activationLine.Quote_line__c;

        if (quoteLineId == null && productId != null) {            
            String concatenationStringToFind = String.valueof(activationLine.Activation__c) + '_' + String.valueof(productId);

            // we want to find the Quote Line Id from the concatenatedIdsToQuoteLinesMap
            if (homeOfficeData.concatenatedIdsToQuoteLinesMap.containsKey(concatenationStringToFind)
                && !homeOfficeData.concatenatedIdsToQuoteLinesMap.get(concatenationStringToFind).isEmpty()) {
                // use the first item in the list of Quote Lines
                quoteLineId = homeOfficeData.concatenatedIdsToQuoteLinesMap.get(concatenationStringToFind).get(0).Id;
            }
        } 
        return quoteLineId;
    }

    /**
     * TODO at a later stage consider moving this to custom metadata in a new ticket, not in the bug fix ticket.
     * 
     * Set Activation Line VAS_CHXTxx checkbox fields to false and wipe Home_Office_OTC_Product__c field.
     * @param activationLine Activation_Line__c record that we want to reset fields on.
     */
    private static void resetActivationLineFields(Activation_Line__c activationLine) {
        activationLine.VAS_CHXT01__c = false;  // (Installation DSL)
        activationLine.VAS_CHXT02__c = false;  // (Installation Fiber Area A incl Digging)
        activationLine.VAS_CHXT03__c = false;  // (Installation Fiber Area A)
        activationLine.VAS_CHXT04__c = false;  // (Installation Fiber Area B incl Digging)
        activationLine.VAS_CHXT05__c = false;  // (Installation Fiber Area B)
        activationLine.VAS_CHXT06__c = false;  // (Installation Fiber Area C incl Digging)
        activationLine.VAS_CHXT07__c = false;  // (Installation Fiber Area C)
        activationLine.VAS_CHXT08__c = false;  // (Installation Coax)
        activationLine.VAS_CHXT11__c = false;  // (Installation Fiber Area D incl Digging)
        activationLine.VAS_CHXT12__c = false;  // (Installation Fiber Area D)
        activationLine.Home_Office_OTC_Product__c = '';  // (Home Office OTC Product)
    }

    /**
     * TODO at a later stage consider moving this to custom metadata in a new ticket, not in the bug fix ticket.
     * 
     * Set Activation Line VAS_CHXTxx checkbox fields to true on match with otcProductValue.
     * (locationLine.OTC_product__c)
     * @param activationLine Activation_Line__c record that we want to reset fields on.
     * @param otcProductValue String that holds the value we want to switch on.
     */
    @TestVisible
    private static void switchActivationLineVasChxtFieldsToTrueOnMatch(Activation_Line__c activationLine, String otcProductValue) {
        switch on otcProductValue {
            when 'CHXT01' {
                activationLine.VAS_CHXT01__c = true;  // (Installation DSL)
            }
            when 'CHXT02' {
                activationLine.VAS_CHXT02__c = true;  // (Installation Fiber Area A incl Digging)
            }
            when 'CHXT03' {
                activationLine.VAS_CHXT03__c = true;  // (Installation Fiber Area A)
            }
            when 'CHXT04' {
                activationLine.VAS_CHXT04__c = true;  // (Installation Fiber Area B incl Digging)
            }
            when 'CHXT05' {
                activationLine.VAS_CHXT05__c = true;  // (Installation Fiber Area B)
            }
            when 'CHXT06' {
                activationLine.VAS_CHXT06__c = true;  // (Installation Fiber Area C incl Digging)
            }
            when 'CHXT07' {
                activationLine.VAS_CHXT07__c = true;  // (Installation Fiber Area C)
            }
            when 'CHXT08' {
                activationLine.VAS_CHXT08__c = true;  // (Installation Coax)
            }
            when 'CHXT11' {
                activationLine.VAS_CHXT11__c = true;  // (Installation Fiber Area D incl Digging)
            }
            when 'CHXT12' {
                activationLine.VAS_CHXT12__c = true;  // (Installation Fiber Area D)
            }
        }
    }    

    /**
     * Assign values to Activation Line record, using values from the Location Line record.
     * 
     * @param paramHelper holding activationLine, locationLine, productId and quoteLineId.
     */
    private static void assignLocationLineValuesToActivationLine(HomeOfficeParamHelper paramHelper) {            
        paramHelper.activationLine.Active_Blocking_Line_Present__c = paramHelper.locationLine.Active_Blocking_Line_Present__c;  // (Active Blocking Line Present)
        paramHelper.activationLine.Employee_Number__c = paramHelper.locationLine.Employee_ID__c;  // (Employee Number)
        paramHelper.activationLine.Home_Office__c = true;  // (Home_Office__c)
        paramHelper.activationLine.Home_Office_OTC_Product__c = paramHelper.locationLine.OTC_product__c;  // (Home Office OTC Product)
        paramHelper.activationLine.Home_Office_VAS_Product__c = paramHelper.locationLine.VAS_product__c;  // (Home Office VAS Product)
        paramHelper.activationLine.Installation_address__c = paramHelper.locationLine.Address__c;  // (Installation address)
        paramHelper.activationLine.Location_Line__c = paramHelper.locationLine.Id;  // (Location Line)

        /* productId comes either from ActivationLine.Manual_Product__c, or the Product record where its 
        ProductAPI_Telia_Product_Id__c matches paramHelper.locationLine.Subscription_product__c */
        paramHelper.activationLine.Manual_Product__c = paramHelper.productId;  // (Manual Product) 

        paramHelper.activationLine.Municipality_Code__c = paramHelper.locationLine.Municipality_Code__c;  // (Municipality Code)
        paramHelper.activationLine.Plug_Technician_Required__c = paramHelper.locationLine.Plug_Technician_Required__c;  // (Plug Technician Required)
        paramHelper.activationLine.plugPresentPositiveValidation__c = paramHelper.locationLine.plugPresentPositiveValidation__c;  // (plugPresentPositiveValidation)

        /* quoteLineId comes either from ActivationLine.Quote_Line__c, or the Quote Line record where its Activation__c 
        matches ActivationLine.Activation__c AND its SBQQ__Product__c matches the productId */
        paramHelper.activationLine.Quote_line__c = paramHelper.quoteLineId;  // (Quote Line)

        paramHelper.activationLine.Street_Code__c = paramHelper.locationLine.Street_Code__c;  // (Street Code)
        // VAS_product__c is a picklist field on Location Line and the only active value is 'Home Office Fast IP adresse' with API Name 'FASTIP'
        paramHelper.activationLine.VAS_FASTIP__c = String.isEmpty(paramHelper.locationLine.VAS_product__c) ? false : true;  // (Fixed IP)
    }

    /**
     * Set the number of Location Lines on the Activation record and return it.
     *
     * @param homeOfficeData 
     * @param activationLine from which we find the Activation to update the number of Location Lines on
     * @return Activation__c
     */
    private static Activation__c setNumberOfLocationLinesOnActivationRecord(
        HomeOfficeDataWrapper homeOfficeData, 
        Activation_Line__c activationLine) {

        Integer numberOfLocationLines = homeOfficeData.locationLineMap.size();

        if (homeOfficeData.activationMap.containsKey(activationLine.Activation__c)) {
            // yes, the activation is found in map, so set the No_of_Location_Lines__c and return the activation record
            Activation__c activationToUpdate = homeOfficeData.activationMap.get(activationLine.Activation__c);
            activationToUpdate.No_of_Location_Lines__c = numberOfLocationLines;
            return activationToUpdate;
        } else {
            // activation is not found in map, so return null
            return null;
        }
    }

    /**
     * Helper class to hold the parameters needed for assigning values to:
     * - Activation Line record
     * - Location Line record 
     * - productId 
     * - quoteLineId
     */
    private class HomeOfficeParamHelper {
        Activation_Line__c activationLine;
        Location_Line__c locationLine;
        Id productId;
        Id quoteLineId;
        HomeOfficeDataWrapper homeOfficeData;

        public HomeOfficeParamHelper(
            Location_Line__c locationLine, 
            Activation_Line__c activationLine, 
            Id productId, 
            Id quoteLineId,
            HomeOfficeDataWrapper homeOfficeData) {

            this.locationLine = locationLine;
            this.activationLine = activationLine;
            this.productId = productId;
            this.quoteLineId = quoteLineId;
            this.homeOfficeData = homeOfficeData;
        }
    }

    public class HomeOfficeFlowActionOutputVarsGeneratorException extends Exception {
    }

}