/**
 * 
 * @author keh
 * @since 14-01-2025
 */
global class ActivationFulfilledQuoteLineAction {
    /**
     * The action is used from the flow Activation: Fulfilled - Create Activation Quote & QL and update AL
     * 
     * @see https://jira.atlassian.teliacompany.net/browse/DKT-30902
     * 
     * @param listOfInputVariables An activationQuote and a list of quote agreement lines
     * @return  `List<SBQQ__QuoteLine__c>`
     */
    @InvocableMethod(label='Set Quantity Of Activations On Quotelines')
    public static  List<OutputVariables> getActivationFulfilledQuoteLinesAction(List<InputVariables>  listOfInputVariables) {
        //A list of related activation quotelines which are used when setting the quantity
        List<SBQQ__QuoteLine__c> listOfAllQuoteLines = new List<SBQQ__QuoteLine__c>();
        for(InputVariables iv :listOfInputVariables){
            listOfAllQuoteLines.addAll(iv.listOfQuoteLines);
        }

        List<Id> listOfUsedQuoteLineProducts = new List<Id>();
        for(SBQQ__QuoteLine__c quoteLine : listOfAllQuoteLines){
            listOfUsedQuoteLineProducts.add(quoteLine.SBQQ__Product__c);
        }
        
        //Some quotelines have products which are activated with other products or
        //an Activation_Record_Type__c that indicates that no avtivation is needed. 
        //In both cases no activation lines are created, but we still need to add a quantity.
        List<Product2> listOfProductsWithActivateInfo = [
            SELECT Id, Activate_with_other_products__c, Activation_Record_Type__c
            FROM Product2
            WHERE Id IN :listOfUsedQuoteLineProducts];

        //Create a list of products that activates with other products, or where no activation is needed, and therefore do not have activation lines.    
        //We should not update the quantity of quotelines with these products as it is already correct.
        List<Id> listOfProductsWithoutActivationLines = new List<Id>();
        for(Product2 prod :listOfProductsWithActivateInfo){
            if(prod.Activate_with_other_products__c == true || prod.Activation_Record_Type__c.contains('No activation needed')){
                if(!listOfProductsWithoutActivationLines.contains(prod.Id)){
                    listOfProductsWithoutActivationLines.add(prod.Id);
                }
            }
        }    

        List<AggregateResult> listOfActivationLineCountsPrQuoteLine = [
            SELECT Quote_line__c,  COUNT(Id) quantity
            FROM activation_line__c
            WHERE Quote_line__c IN :listOfAllQuoteLines
            GROUP BY Quote_line__c];
           
        Map<Id, Integer> mapOfActivationLineCounts = new Map<Id, Integer>();
        for(AggregateResult relatedActivationLine : listOfActivationLineCountsPrQuoteLine) {
            Id quoteLineId = (Id)relatedActivationLine.get('quote_line__c');
            Integer activationLineQuantity = (Integer)relatedActivationLine.get('quantity');
            mapOfActivationLineCounts.put(quoteLineId, activationLineQuantity);
        }

       //The collection of new quotelines that will be returned from the apex action
       List<OutputVariables> listOfAddedQuoteLines = new List<OutputVariables>();
       for(InputVariables iv :listOfInputVariables){
           OutputVariables ov = new OutputVariables();
           for(SBQQ__QuoteLine__c quoteLine : iv.listOfQuoteLines){
               SBQQ__QuoteLine__c quoteLineClone = null;
               try{
                   //clone(preserveId, isDeepClone, preserveReadOnlyTimestamps, preserveAutoNumber)
                   quoteLineClone = quoteLine.clone(false, true, false, false); 
                   
                   quoteLineClone.SBQQ__Quote__c = iv.activationQuote.Id;
                   quoteLineClone.Original_Quote_Line__c = quoteLine.Id;
                   quoteLineClone.SBQQ__RequiredBy__c = null; 
                   quoteLineClone.Additional_Quantity__c = 0;
                                    
                    //If the product does not have activate with other products and if no activation is needed, 
                    //then update the quantity
                    if(!listOfProductsWithoutActivationLines.contains(quoteLine.SBQQ__Product__c)) {
                        if(mapOfActivationLineCounts.containsKey(quoteLine.Id)) {
                            Logger.logInfo('Quote line ID from ActivationLineCounts: ' + mapOfActivationLineCounts.get(quoteLine.Id));
                        }

                        if(mapOfActivationLineCounts.get(quoteLine.Id) != null && mapOfActivationLineCounts.get(quoteLine.Id) > 0){
                            //If the activation line count is not null, then set the quantity to the count
                            //If the activation line count is null, then set the quantity to 0
                            quoteLineClone.SBQQ__Quantity__c = mapOfActivationLineCounts.get(quoteLine.Id);
                        }         
                        else{
                            quoteLineClone.SBQQ__Quantity__c = 0;
                        }
                    }
               }
               catch(Exception ex){
                    Logger.logError('getActivationFulfilledQuoteLinesAction', ex);
               }

               if(quoteLineClone != null){
                   ov.listOfQuoteLines.add(quoteLineClone);
               }
           }
           listOfAddedQuoteLines.add(ov);
       }

       Logger.emit();

       return listOfAddedQuoteLines;
    }  

    /**
     * Input object for the invocable apex action activationFulfilledQuoteLineQtyAction
     */
    global class InputVariables {
        @InvocableVariable
        global SBQQ__Quote__c activationQuote;
    
        @InvocableVariable
        global List<SBQQ__QuoteLine__c> listOfQuoteLines;
    }

    global class OutputVariables {
        @InvocableVariable
        global List<SBQQ__QuoteLine__c> listOfQuoteLines;

        public OutputVariables(){
            listOfQuoteLines = new List<SBQQ__QuoteLine__c>();
        }   
    }
}