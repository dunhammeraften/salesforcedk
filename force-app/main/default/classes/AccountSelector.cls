/**
 * Selector class for Account
 */
public with sharing class AccountSelector {
	public static Account getByCVR(String cvr) {
		return [
			SELECT
				Id,
				Name,
				BillingPostalCode,
				Billing_Street_Name__c,
				Billing_Street_Number__c,
				Billing_Floor_Number__c,
				Billing_Door_Number__c,
				Billing_Street_Number_Suffix__c,
				BillingCity,
				BillingCountry,
				CVR__c,
				Phone,
				OwnerId,
				Sales_Play_Vesting_Reason__c
			FROM Account
			WHERE CVR__c = :cvr
			LIMIT 1
		];
	}

	public static List<Account> getAccountsByIds(List<Id> accountIds) {
		return [
	            SELECT Id, CVR__c
	            FROM Account
	            WHERE Id IN :accountIds
	        ];
	}
    
	@AuraEnabled(cacheable=true)
	public static Account getAccountByCaseId(String caseId) {
		List<Account> accounts = [SELECT Id FROM Account WHERE Id IN (SELECT AccountId FROM Case WHERE Id = :caseId)];
		if(!accounts.isEmpty()) {
			return accounts[0];
		}
		
		return null;
	}
}