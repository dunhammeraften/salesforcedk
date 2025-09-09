@IsTest
public with sharing class TDF_OpportunityUtils {
    public static List<Opportunity> createOpportunitiesForAccounts(Integer numOfOppsPerAccount, List<Account> theAccounts) {
		List<Opportunity> result = new List<Opportunity>();
		for (Account singleAccount : theAccounts) {
			for (Integer i = 0; i < numOfOppsPerAccount; ++i) {
				result.add(
					new Opportunity(
						Name = 'Test Opp for Account:' + singleAccount.Name + ' num:' + i,
						AccountId = singleAccount.Id,
						Type = 'New Business',
						CloseDate = Date.Today() + 5,
						StageName = 'Proposal',
						Product_s_in_scope__c = 'M2M;MBB',
						Pricebook2Id = Test.getStandardPricebookId()
					)
				);
			}
		}
		insert result;
		return result;
	}
	
	/**
	 * Creates and inserts opportunity for given accounts agreement type decided by what is passed in as agreementType
	 * 
	 * @param theAccounts - Accounts the opp should be linked to
	 * @param agreementType
	 * @return list of opportunities
	 */
    public static List<Opportunity> createHomeOfficeOpportunityForAccounts(List<Account> theAccounts, String agreementType) {
		List<Opportunity> result = new List<Opportunity>();
		for (Account singleAccount : theAccounts) {
			result.add(
				new Opportunity(
					Name = 'Test Opp for Account:' + singleAccount.Name,
					AccountId = singleAccount.Id,
					Type = 'New Business',
					CloseDate = Date.Today() + 5,
					StageName = 'Proposal',
					Agreement_Type__c = agreementType,
					Product_s_in_scope__c = HomeOfficeConstants.PRODUCTS_IN_SCOPE_HOME_OFFICE,
					Pricebook2Id = Test.getStandardPricebookId()
				)
			);
		}
		insert result;
		return result;
	}
}