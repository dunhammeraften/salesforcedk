public without sharing class Activation_Create {
	private static final String NO_ACTIVATION_NEEDED = 'No activation needed';
	private static final String TYPE_NEW = 'New';
	private static final String TYPE_RENEW_EXISTING = 'Renew Existing';

	@InvocableMethod(label='Create activations' description='Creating activations for a Quote')
	public static void Activation_Create(List<RequestDAO> requestDAO) {
		List<Activation__c> activationCreateList = new List<Activation__c>();
		List<AggregateResult> quoteLines = new List<AggregateResult>();
		String caseId = '';
		List<Id> recordId = new List<Id>{requestDAO.get(0).recordId};
		System.debug('recordId = ' + recordId);
		Map<String, Case> caseByProductType = mapCaseByProductType(requestDAO.get(0).cases);
		System.debug('caseByProductType = ' + caseByProductType);
		
		try {
			List<SBQQ__Quote__c> quotes = [
				SELECT Id, SBQQ__Opportunity2__r.SBQQ__Renewal__c, SBQQ__Opportunity2__r.SBQQ__AmendedContract__c, SBQQ__Opportunity2__r.Case__c
				FROM SBQQ__Quote__c
				WHERE Id = :recordId
				LIMIT 1
			];
			caseId = quotes.get(0).SBQQ__Opportunity2__r.Case__c;
			System.debug('caseId = ' + caseId);
			System.debug('Print Quote List ' + quotes.get(0));
			
			if (quotes.size() > 0) {
				for (AggregateResult quoteLine : [
					SELECT SBQQ__Product__r.Delivery_Product_Group__c, SBQQ__Quote__r.SBQQ__Opportunity2__r.Case__c
					FROM SBQQ__QuoteLine__c
					WHERE
						SBQQ__Quote__c = :recordId
						AND SBQQ__Product__r.Activation_Record_Type__c != :NO_ACTIVATION_NEEDED
						AND SBQQ__EffectiveQuantity__c > 0
					GROUP BY SBQQ__Product__r.Delivery_Product_Group__c, SBQQ__Quote__r.SBQQ__Opportunity2__r.Case__c
				]) {
					quoteLines.add(quoteLine);
				}
			}
			
			if (quoteLines.size() > 0) {
				system.debug('quoteLines Found');
				for (AggregateResult ql : quoteLines) {
					String caseProductType = String.valueOf(ql.get('Delivery_Product_Group__c'));	
					String caseType = caseByProductType.get(caseProductType).Type;			
					if(caseType == caseProductType) {
						activationCreateList.add(
							new Activation__c(
								Case__c = caseByProductType.get(caseProductType).Id,
								RecordTypeId = Schema.sObjectType.Activation__c.getRecordTypeInfosByName()
									.get(String.valueOf(ql.get('Delivery_Product_Group__c')) + ' activation')
									.getRecordTypeId(),
								Name = String.valueOf(ql.get('Delivery_Product_Group__c') + ' - New'),
								Type__c = TYPE_NEW
							)
						);
					}
				}
			}
			
			// Creating and executing batch (Activation_Create_Iterable)
			if (activationCreateList != null) {
				calculateActivationProgressValue(activationCreateList, 'New', quotes.get(0).Id);
				System.debug('activationCreateList = ' + activationCreateList);
				insert activationCreateList;
				Activation_Create_Iterable ProcessBatch = new Activation_Create_Iterable();
				ProcessBatch.recordId = recordId;
				ID batchprocessid = Database.executeBatch(ProcessBatch);
			}

		} catch (Exception e) {
			System.debug('### Error Occured while creating activations : ' + e.getMessage() + ' LineNumber: ' + e.getLineNumber());
			System_Log__c logerror = new System_Log__c(
				Origin__c = 'Apex',
				Error_Body__c = e.getMessage() + ' LineNumber: ' + e.getLineNumber(),
				Additional_Information__c = 'Activation_Create'
			);
			insert logerror;
		}
	
	
	
	}
	
	/**
	 * Helper method used to calculate the value of Activation_progress__c on Activation__c.
	 * Priority of values:
	 * 1. Special Handling
	 * 2. UC Specification
	 * 3. Onboarding Portal
	 */
	@TestVisible
	private static void calculateActivationProgressValue(List<Activation__c> activations, String activationType, Id quoteId) {
		Boolean isSpecialHandling =
			[
				SELECT COUNT()
				FROM SBQQ__QuoteLine__c
				WHERE SBQQ__Quote__c = :quoteId AND (product_group__c IN ('ACE', 'ACE Cloud') OR Telia_Product_Code__c = 'FIX2MOBIL')
			] > 0;
		Boolean isUCSpecification = [SELECT COUNT() FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c = :quoteId AND product_group__c = 'TPX'] > 0;
		Boolean isOnboardingPortal =
			[SELECT COUNT() FROM SBQQ__Quote__c WHERE Id = :quoteId AND SBQQ__Account__r.Owner.UserRole.Name IN ('Managed Accounts', 'Business Accounts')] > 0;
		String activationProgress = null;
		if (isSpecialHandling) {
			activationProgress = 'Special Handling';
		} else if (isUCSpecification) {
			activationProgress = 'UC Specification';
		} else if (isOnboardingPortal) {
			activationProgress = 'Onboarding Portal';
		} else {
			activationProgress = null; // Let default be handled by default setting of Picklist
		}

		for (Activation__c theActivation : activations) {
			if (
				!String.isBlank(activationProgress) &&
				!String.isBlank(theActivation.Type__c) &&
				theActivation.Type__c.equalsIgnoreCase(activationType) &&
				theActivation.Name == 'Voice - New'
			) {
				theActivation.Activation_Progress__c = activationProgress;
			}
		}
	}
	private static Map<String, Case> mapCaseByProductType(List<Case> cases) {
		Map<String, Case> csByProductType = new Map<String, Case>();
		for(Case cs: cases) {
			csByProductType.put(cs.Type, cs);
		}
		return csByProductType;
	}

	public class RequestDAO {
		@InvocableVariable
		public String recordId; // The record ID of the Quote
		@InvocableVariable
		public List<Case> cases;
	}
}