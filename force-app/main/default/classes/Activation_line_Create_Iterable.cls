public class Activation_line_Create_Iterable implements Database.Batchable<sObject> {
	public String query;
	public String recordId;
	public Database.querylocator start(Database.BatchableContext bc) {
		return Database.getQueryLocator(query);
	}

	public void execute(Database.BatchableContext bc, List<SBQQ__QuoteLine__c> scope) {
		List<Activation_line__c> activationLineCreateList = new List<Activation_line__c>();
		Activation_line__c activationLineRecord = new Activation_line__c();
		List<SBQQ__QuoteLine__c> updateQuoteLinewithActivated = new List<SBQQ__QuoteLine__c>();

		try {
						
			Map<String, Id> activationIdsPerRecordType = new Map<String, Id>();
			Map<String, Id> caseIdByActivationRecordType = new Map<String, Id>();

			for (Activation__c ac : [SELECT Id, RecordType.name, Type__c, Case__c FROM Activation__c WHERE Case__r.Quote__c = :recordId]) {
				activationIdsPerRecordType.put(ac.RecordType.name.remove(' activation') + '-' + ac.Type__c, ac.Id);
				caseIdByActivationRecordType.put(ac.RecordType.name.remove(' activation') + '-' + ac.Type__c, ac.Case__c);
			}

			for (SBQQ__QuoteLine__c s : scope) {
				for (Integer i = 1; i <= s.SBQQ__Quantity__c; i++) {							
					activationLineRecord = new Activation_line__c(
						Activation__c = activationIdsPerRecordType.get(s.Activation_Record_Type__c + '-New'),
						Case__c = caseIdByActivationRecordType.get(s.Activation_Record_Type__c + '-New'),
						Quote_line__c = s.Id,
						RecordTypeId = Schema.sObjectType.Activation_line__c.getRecordTypeInfosByName()
							.get(s.Activation_Record_Type__c + ' activation line')
							.getRecordTypeId(),
						Delivery_City__c = s.SBQQ__Quote__r.SBQQ__BillingCity__c,
						Delivery_Country__c = s.SBQQ__Quote__r.SBQQ__BillingCountry__c,
						Delivery_Street_and_number__c = s.SBQQ__Quote__r.SBQQ__BillingStreet__c,
						Postal_Code__c = s.SBQQ__Quote__r.SBQQ__BillingPostalCode__c,
						Manual_Product__c = s.SBQQ__Product__c,
						Company_Name__c = s.SBQQ__Quote__r.Account_Name__c
					);

					if (s.SBQQ__ProductCode__c == '11105') { //	TPX Corporate Fri Tale 
						activationLineRecord.VAS_UC_License__c = 'TPXSOFTP';
					}

					if (s.SBQQ__ProductCode__c == '26000') { //	DN Access 4G Backup - DK
						activationLineRecord.Case__c = caseIdByActivationRecordType.get('Fiber' + '-New');
					}

					activationLineCreateList.add(activationLineRecord);
				}
				
				updateQuoteLinewithActivated.add(new SBQQ__QuoteLine__c(Id = s.Id, Activation_Created__c = true));
			}
			
			insert activationLineCreateList;
			update updateQuoteLinewithActivated;

		} catch (Exception e) {
			System.debug('### Error Occured while creating activation lines : ' + e.getMessage());
			System_Log__c logerror = new System_Log__c(
				Origin__c = 'Apex',
				Error_Body__c = e.getMessage() + ' LineNumber: ' + e.getLineNumber(),
				Additional_Information__c = 'Activation_line_Create_Iterable'
			);
			insert logerror;
		}
	}

	public void finish(Database.BatchableContext bc) {
		List<Id> records = new List<Id>();
		list<SBQQ__Quote__c> quoteList = [
			SELECT Id, SBQQ__Opportunity2__r.SBQQ__Renewal__c, SBQQ__Opportunity2__r.SBQQ__AmendedContract__c
			FROM SBQQ__Quote__c
			WHERE Id = :recordId
		];
		//Find out if the quote is renewal
		if (quoteList[0].SBQQ__Opportunity2__r.SBQQ__Renewal__c == true) {
			records.add(recordId);
			Activation_line_CreateRenewal.Activation_line_Create(records);
		}

		//Find out if the quote is amendment
		if (quoteList[0].SBQQ__Opportunity2__r.SBQQ__AmendedContract__c != null) {
			records.add(recordId);
			Activation_lineCreateAmendment.Activation_line_Create(records);
		}
	}
}