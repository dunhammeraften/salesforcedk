public without sharing class OpportunitySelector {
	public List<Location_Line__c> getLocationLinesByOpportunityIds(List<String> opportunityIds) {
        Logger.logInfo(String.format('getLocationLinesByOpportunityIds( {0} )', new List<Object>{opportunityIds}));

		return [
			SELECT Id
			FROM Location_Line__c
			WHERE Opportunity__c IN :opportunityIds
			ORDER BY Id
		];
	}

	public static Opportunity getById(String oppId) {
		Opportunity opp = [SELECT Name, StageName, Description, IsWon FROM Opportunity WHERE Id = :oppId LIMIT 1];
		return opp;
	}

	public static Opportunity getHomeOfficeOppByOppContactRoleAndContact(String contactId) {
		List<Opportunity> opps = [
			SELECT Id, (SELECT OpportunityId FROM OpportunityContactRoles)
			FROM Opportunity
			WHERE
				Id IN (
					SELECT OpportunityId
					FROM OpportunityContactRole
					WHERE ContactId = :contactId AND Role = 'Sales Contact'
				)
				AND ((StageName IN ('Needs Analysis', 'Closed Won')
				AND Agreement_Type__c = 'Specified')
				OR (StageName = 'Closed Won'
				AND Agreement_Type__c = 'Framework'))
				AND Product_s_in_scope__c INCLUDES ('Home Office')
		];
		return opps.size() > 0 ? opps.get(0) : null;
	}

	public static Opportunity getByAccountId(String accountId) {
		return [
			SELECT Id, AccountId, Name, StageName, Description, IsWon, SBQQ__PrimaryQuote__c, Original_Primary_Quote__c
			FROM Opportunity
			WHERE AccountId = :accountId
			LIMIT 1
		];
	}

	public static List<Opportunity> getOrderedOpenOrClosedOpportunitiesByAccountsAndCloseDate(
		List<Account> accounts,
		Date filterDate
	) {
		return [
			SELECT Id, AccountId, IsClosed, IsWon
			FROM Opportunity
			WHERE AccountId IN :accounts AND (IsClosed = FALSE OR (IsClosed = TRUE AND CloseDate > :filterDate))
			ORDER BY IsClosed, IsWon DESC
		];
	}
}