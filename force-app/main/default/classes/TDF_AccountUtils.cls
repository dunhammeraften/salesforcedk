@IsTest
public with sharing class TDF_AccountUtils {
    public static Account createAccountWithCVR(String cvr) {
		Account account = new Account();
		account.Name = StringUtils.makeRandomStringNoNumerics(20);
		account.BillingCity = 'CP';
		account.BillingPostalCode = '2000';
		account.NumberOfEmployees = 10;
		account.BillingCountry = 'DK';
		account.BillingStreet = 'Holmbladsgade 133';
		account.Phone = '111';
		account.CVR__c = cvr;
		return account;
	}

	public static Account creatActiveAccountWithCVRAndOwner(){
		return creatActiveAccountWithCVRAndOwner('12345678');
	}

	public static Account creatActiveAccountWithCVRAndOwner(String cvr) {
		Profile prof = ProfileSelector.getProfileByProfileName(ProfileConstants.SYSTEM_ADMINISTRATOR);
        User usr = testDataFactory.createUser('standt', prof.Id);

		Account account = new Account();
		account.Name = StringUtils.makeRandomStringNoNumerics(20);
		account.BillingCity = 'CP';
		account.BillingPostalCode = '2000';
		account.BillingCountry = 'DK';
		account.BillingStreet = 'Holmbladsgade 133';
		account.Phone = '111';
		account.NumberOfEmployees = 10;
		account.CVR__c = cvr;
		account.Status__c = 'Active';
		account.OwnerId = usr.Id;
		return account;
	}

	public static List<Account> createListOfAccountsWithCVRAndOwner(Integer numberOfAccountsInList){
		List<Account> listOfAccounts = new List<Account>();

		Integer testCvr = 12345100;

		for(Integer i = 0; i < numberOfAccountsInList; i++){
			Account acc = createAccountWithCVR(testCvr + i + '');
			acc.Name = 'TEST ' + i;
			listOfAccounts.add(acc);
		}
		return listOfAccounts;
	}
}