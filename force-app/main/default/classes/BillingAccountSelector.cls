public with sharing class BillingAccountSelector {
    
    @AuraEnabled(cacheable=true)
    public static Billing_Account__c getDefaultBanByAccountAndType(String accountId, String type) {
		return [
			SELECT Id, Name
			FROM Billing_Account__c
			WHERE Account__c =: accountId AND Billing_Account_Type__c =: type AND Default_Billing_Account__c = true
			LIMIT 1
		];
	}

	@AuraEnabled(cacheable=true)
    public static List<Billing_Account__c> getBansByAccountAndType(String accountId, String type) {
		return [
			SELECT Id, Name, Default_Billing_Account__c
			FROM Billing_Account__c
			WHERE Account__c =: accountId AND Billing_Account_Type__c =: type
		];
	}

	@AuraEnabled(cacheable=true)
	public static List<Billing_Account__c> getBansByCaseAndType(String caseId, String type) {
		return [
			SELECT Id, Name, Default_Billing_Account__c
			FROM Billing_Account__c
			WHERE Account__c IN (
				SELECT AccountId
				FROM Case
				WHERE Id = :caseId
			)
			AND Billing_Account_Type__c = :type
		];
	}

}