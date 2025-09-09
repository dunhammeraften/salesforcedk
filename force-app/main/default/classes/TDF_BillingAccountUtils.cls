@IsTest
public with sharing class TDF_BillingAccountUtils {

    public static Billing_Account__c CreateBillingAccount(Account acc) {

        Billing_Account__c billingAccount = new Billing_Account__c();
		billingAccount.BAN_Number__c = 123456789;
		billingAccount.Billing_Name__c = 'Test company';
		billingAccount.Name = 'Invoice Name';
		billingAccount.Account__c = acc.Id;

		insert billingAccount;
        
        return billingAccount;
    }
}