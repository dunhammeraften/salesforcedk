@IsTest
public with sharing class TDF_ActivationUtils {
    public static List<Activation__c> createActivationHeadersForQuoteLines(List<SBQQ__QuoteLine__c> listOfQuoteLines, List<Opportunity> listOfRelatedOpportunities) {
		Map<SBQQ__QuoteLine__c, Activation__c> mapOfQuoteLineToActivation = new Map<SBQQ__QuoteLine__c, Activation__c>();
        List<Activation__c> result = new List<Activation__c>();
		Map<Id, Opportunity> quoteIdToParentOpportunity = new Map<Id, Opportunity>();
		for (Opportunity singleOpp : listOfRelatedOpportunities) {
			quoteIdToParentOpportunity.put(singleOpp.SBQQ__PrimaryQuote__c, singleOpp);
		}
		List<String> activationTypeList = new List<String>();
		for (SBQQ__QuoteLine__c singleLine : listOfQuoteLines) {
			if ((!activationTypeList.contains(singleLine.Activation_Record_Type__c)) && quoteIdToParentOpportunity.containsKey(singleLine.SBQQ__Quote__c)) {
				String tmpName = singleLine.Activation_Record_Type__c;
				Id tmpQuote = singleLine.SBQQ__Quote__c;
				Opportunity tmpOpp = quoteIdToParentOpportunity.get(singleLine.SBQQ__Quote__c);
				Id tmpCase = tmpOpp.Case__c; //casen er på account og ikke opp?
				String tmpActivationRecordType = singleLine.Activation_Record_Type__c + ' activation';
                String noActivationNeeded = TDF_Constants.NO_ACTIVATION_NEEDED;

                if (!tmpActivationRecordType.contains(noActivationNeeded)){
                    Id tmpRecordTypeId = Schema.sObjectType.Activation__c.getRecordTypeInfosByName()
                    .get(tmpActivationRecordType)
                    .getRecordTypeId();

                    try{
                        Activation__c newActivation = new Activation__c(
                            Name = tmpName,
                            Case__c = tmpCase,
                            RecordTypeId = tmpRecordTypeId  
                        );

                        mapOfQuoteLineToActivation.put(singleLine, newActivation);
                    }
                    catch (Exception ex){
                        //System.debug('Error creating Activation Header.  Line: ' + ex);
                    }
                }
			}
		}

        insert mapOfQuoteLineToActivation.values();

        for (SBQQ__QuoteLine__c singleLine :listOfQuoteLines) {
            if (mapOfQuoteLineToActivation.containsKey(singleLine)) {
                singleLine.Activation__c = mapOfQuoteLineToActivation.get(singleLine).Id;
            }
        }

        update listOfQuoteLines;

		return result;
	}
}