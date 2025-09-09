public with sharing class ActivationSelector {
	public static final String RECORD_TYPE_HOME_OFFICE_ACTIVATION = 'Home_office_activation';

	public static List<Activation__c> getActivationsByCaseId(String caseId) {
		return [
			SELECT Id, Case__r.Root_BAN__c, Case__r.Quote__c, Case__r.Account.Customer_has_Touchpoint__c, UC_Activation_Date__c
			FROM Activation__c
			WHERE Case__c = :caseId
		];
	}

	public static List<Activation__c> getActivationsByCases(List<Case> cases) {
		return [
			SELECT Id, Sort_by__c, Sort_order__c
			FROM Activation__c
			WHERE Case__c IN :cases
		];
	}

	public static Activation__c getActivationById(Id id) {
		Activation__c[] activations = [SELECT Bill_To_Name__c, Billing_Frequency__c, Case__c FROM Activation__c WHERE Id = :id];
		if (activations.size() > 0) {
			return activations.get(0);
		}
		return null;
	}
	
	@AuraEnabled(cacheable=true)
	public static Activation__c getActivationByCaseId(String caseId) {
		return [
			SELECT Id, Case__c
			FROM Activation__c
			WHERE Case__c =: caseId
			LIMIT 1
		];
	}

	/**
	 * Get Activation by Id of record type Home_Office_Activation
	 * 
	 * @param Set<Id> activationIdSet
	 * @return List<Activation__c>
	 */
	public static List<Activation__c> getHomeOfficeActivationByIds(Set<Id> activationIdSet) {
		return [
			SELECT Id, Name, No_of_Location_Lines__c
			FROM Activation__c
			WHERE RecordType.DeveloperName = :RECORD_TYPE_HOME_OFFICE_ACTIVATION
			AND Id IN :activationIdSet
		];
	}

}