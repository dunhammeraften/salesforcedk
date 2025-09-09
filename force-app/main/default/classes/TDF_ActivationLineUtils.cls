@IsTest
public with sharing class TDF_ActivationLineUtils {
    public static List<Activation_line__c> createActivationlines(List<SBQQ__QuoteLine__c> theLines) {
		List<Activation_line__c> result = new List<Activation_line__c>();
		List<String> activationTypeList = new List<String>();
		for (SBQQ__QuoteLine__c singleLine : theLines) {
            Id tmpActivation = singleLine.Activation__c;
            Id tmpQuoteLine = singleLine.Id;
            String tmpRecordTypeName = singleLine.Activation_Record_Type__c + ' activation line';
            String tmpBillingCity = singleLine.SBQQ__Quote__r.SBQQ__BillingCity__c;
            Id tmpProduct = singleLine.SBQQ__Product__c;
            String noActivationNeeded = TDF_Constants.NO_ACTIVATION_NEEDED;

            if(!tmpRecordTypeName.contains(noActivationNeeded)) {
                result.add(
                    new Activation_line__c(
                        Activation__c = tmpActivation,
                        Quote_line__c = tmpQuoteLine,
                        RecordTypeId = Schema.sObjectType.Activation_line__c.getRecordTypeInfosByName()
                            .get(tmpRecordTypeName)
                            .getRecordTypeId(),
                        Delivery_City__c = tmpBillingCity,
                        Manual_Product__c = tmpProduct
                    )
                );
            }
		}
		insert result;
		return result;
	}
}