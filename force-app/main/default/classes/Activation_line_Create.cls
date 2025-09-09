public without sharing class Activation_line_Create {
	@InvocableMethod(label='Create activation lines' description='Creating activation lines for a Quote')
	public static void Activation_line_Create(list<id> recordId) {
		Activation_line_Create_Iterable ProcessBatch = new Activation_line_Create_Iterable();
		String batchQuery =
			'SELECT Id,Activation_Record_Type__c,Activation__c, SBQQ__Quote__r.SBQQ__BillingCity__c , ' +
			'SBQQ__Quote__r.SBQQ__BillingPostalCode__c, SBQQ__Quote__r.SBQQ__BillingStreet__c, SBQQ__Quote__c, SBQQ__Quantity__c , ' +
			'SBQQ__Quote__r.SBQQ__BillingCountry__c,SBQQ__Product__c, Additional_Quantity__c, ' +
			'SBQQ__ProductCode__c, Address_filled_on_activation_lines__c, SBQQ__SegmentIndex__c,' +
			' SBQQ__Quote__r.SBQQ__Opportunity2__r.Case__c, SBQQ__Product__r.address_required__c,SBQQ__Quote__r.Account_Name__c, ' +
			' SBQQ__Quote__r.SBQQ__Opportunity2__r.SBQQ__Renewal__c, SBQQ__Quote__r.SBQQ__Opportunity2__r.SBQQ__AmendedContract__c ' +
			' from SBQQ__QuoteLine__c ' +
			' where Activation_Record_Type__c <>\'No activation needed\'' +
			' and SBQQ__EffectiveQuantity__c >0 and SBQQ__Quote__c =\'' +
			recordId.get(0) +
			'\' and SBQQ__Product__r.activate_with_other_products__c = false' +
			' order by SBQQ__Product__c desc';
			System.debug('Activation_line_Create batchQuery = ' + batchQuery);
		ProcessBatch.query = batchQuery;
		ProcessBatch.recordId = String.valueOf(recordId.get(0));
		ID batchprocessid = Database.executeBatch(ProcessBatch);
	}
}