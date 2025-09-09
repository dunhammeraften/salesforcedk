@IsTest
public with sharing class TDF_UserUtils {
    public static User createUser(String alias, String profileId) {
		User user = new User();
		user.Alias = alias;
		user.Email = 'standarduser@testorg.com';
		user.EmailEncodingKey = 'UTF-8';
		user.LastName = 'Testing';
		user.LanguageLocaleKey = 'en_US';
		user.LocaleSidKey = 'en_US';
		user.ProfileId = profileId;
		user.TimeZoneSidKey = 'America/Los_Angeles';
		user.UserName = StringUtils.makeRandomStringNoNumerics(10) + '@' + StringUtils.makeRandomStringNoNumerics(5) + '.com';
		user.Dealer_Code__c = 1234;
		user.Sales_Agent_Code__c = '12345';
		user.FederationIdentifier = StringUtils.makeRandomStringNoNumerics(7);
		insert user;
		return user;
	}

	public static User createUserForContact(String contactId, String alias, String profileId) {
		User user = new User();
		user.Alias = alias;
		user.Email = 'standarduser@testorg.com';
		user.EmailEncodingKey = 'UTF-8';
		user.LastName = 'Testing';
		user.LanguageLocaleKey = 'en_US';
		user.LocaleSidKey = 'en_US';
		user.ProfileId = profileId;
		user.TimeZoneSidKey = 'America/Los_Angeles';
		user.UserName = StringUtils.makeRandomStringNoNumerics(10) + '@' + StringUtils.makeRandomStringNoNumerics(5) + '.com';
		user.Dealer_Code__c = 1234;
		user.Sales_Agent_Code__c = '12345';
		user.FederationIdentifier = StringUtils.makeRandomStringNoNumerics(7);
		user.ContactId = contactId;
		insert user;
		return user;
	}
}