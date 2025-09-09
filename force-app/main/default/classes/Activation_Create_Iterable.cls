public class Activation_Create_Iterable implements Database.Batchable<sObject> {
	public String query;
	public List<Id> recordId;
	public Database.querylocator start(Database.BatchableContext BC) {
		String squery =
			'SELECT Id,Activation_Record_Type__c,SBQQ__Quote__r.SBQQ__Opportunity2__r.Case__c,Additional_Quantity__c,' +
			' SBQQ__RenewedSubscription__c,SBQQ__ProductOption__r.SBQQ__Feature__r.SBQQ__Category__c ' +
			' from SBQQ__QuoteLine__c where SBQQ__Quote__c in :recordId' +
			' and SBQQ__EffectiveQuantity__c >0 and Activation_Record_Type__c <>\'No activation needed\'';
			System.debug('Activation_Create_Iterable squery = ' + squery);
		return Database.getQueryLocator(squery);
	}

	public void execute(Database.BatchableContext BC, List<SBQQ__QuoteLine__c> scope) {
		System.debug('Activation_Create_Iterable execute called with scope = ' + scope);
		List<Activation__c> ActivationList = [
			SELECT Id, RecordType.name, Type__c, TP_X_Upsell__c
			FROM Activation__c
			WHERE Case__r.Quote__c IN :recordId
		];
		System.debug('ActivationList$ = ' + ActivationList);

		List<Quote_Line_Detail__c> QLDList = [
			SELECT Id, Quote_Line__c
			FROM Quote_Line_Detail__c
			WHERE Quote_Line__r.SBQQ__Quote__c IN :recordId
		];
		System.debug('QLDList = ' + QLDList);

		Map<String, Integer> QLDCount = new Map<String, Integer>();
		boolean TPUpsell = false;

		if (QLDList != null && QLDList.size() > 0) {
			for (Quote_Line_Detail__c qld : QLDList) {
				if (!QLDCount.containsKey(String.valueOf(qld.Quote_Line__c))) {
					QLDCount.put(String.valueOf(qld.Quote_Line__c), 1);
				}
			}
		}
		Map<String, Id> ActivationIdsPerRecordType = new Map<String, Id>(); //Voice-New,XXXX
		try {
			for (Activation__c ac : ActivationList) {
				ActivationIdsPerRecordType.put(ac.RecordType.name.remove(' activation') + ' - ' + ac.Type__c, ac.Id);
				if (ac.TP_X_Upsell__c) {
					TPUpsell = true;
				}
			}
			system.debug('ActivationIdsPerRecordType + ' + ActivationIdsPerRecordType);

			List<SBQQ__QuoteLine__c> updateQuoteLineList = new List<SBQQ__QuoteLine__c>();
			string typeCheck;
			for (SBQQ__QuoteLine__c s : scope) {
		
		
				// DISABLED 30/07/2024 - PROJECT CASE MANAGEMENT
				// //if there is TPupsell, activation type will be New for Voice activations
				// if (s.Activation_Record_Type__c == 'Voice' && TPUpsell == true) {
				// 	typeCheck = 'New';
				// } else if (
				// 	QLDCount.containsKey(String.valueOf(s.Id)) ==
				// 	true //If QLD exists mark as renew Existing
				// ) {
				// 	typeCheck = 'Renew Existing';
				// } else {
				// 	typeCheck = 'New';
				// }
				typeCheck = 'New';

				system.debug('typeCheck = ' + typeCheck);

				// DISABLED CASE MANAGEMENT
				system.debug(s.Activation_Record_Type__c);
				if (ActivationIdsPerRecordType.get(s.Activation_Record_Type__c + ' - ' + typeCheck) == null) {
					System.debug('Not found!');
					Activation__c NewActivation = new Activation__c(
						Case__c = s.SBQQ__Quote__r.SBQQ__Opportunity2__r.Case__c,
						RecordTypeId = Schema.sObjectType.Activation__c.getRecordTypeInfosByName()
							.get(s.Activation_Record_Type__c + ' activation')
							.getRecordTypeId(),
						Name = s.Activation_Record_Type__c + ' - ' + typeCheck,
						Type__c = typeCheck
					);
					System.debug(Schema.sObjectType.Activation__c.getRecordTypeInfosByName().get(s.Activation_Record_Type__c + ' activation').getRecordTypeId());
					insert NewActivation;
					System.debug('NewActivation = ' + NewActivation);
					ActivationIdsPerRecordType.put(s.Activation_Record_Type__c + ' - ' + typeCheck, NewActivation.Id);
				}
				updateQuoteLineList.add(
					new SBQQ__QuoteLine__c(Id = s.Id, Activation__c = ActivationIdsPerRecordType.get(s.Activation_Record_Type__c + ' - ' + typeCheck))
				);
			}
			System.debug('updateQuoteLineList = ' + updateQuoteLineList);
			update updateQuoteLineList;
		} catch (Exception e) {
			System.debug('### Error Occured while updateing Quote lines with activations : ' + e.getMessage());
			System_Log__c logerror = new System_Log__c(
				Origin__c = 'Apex',
				Error_Body__c = e.getMessage() + ' LineNumber: ' + e.getLineNumber(),
				Additional_Information__c = 'Activation_Create_Iterable'
			);
			insert logerror;
		}
	}
	public void finish(Database.BatchableContext BC) {
		Activation_line_Create.Activation_line_Create(recordId);
	}
}