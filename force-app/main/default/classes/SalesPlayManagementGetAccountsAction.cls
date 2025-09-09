public with sharing class SalesPlayManagementGetAccountsAction {
	@TestVisible
	private static final String LEAD_STATUS_QUALIFIED = 'Qualified';
	@TestVisible
	private static final String LEAD_STATUS_UNQUALIFIED = 'Unqualified';
	private static final Set<String> LEAD_STATUSES_CLOSED = new Set<String>{
		LEAD_STATUS_QUALIFIED,
		LEAD_STATUS_UNQUALIFIED
	};
	private static final String SEPERATOR = '\n';
	@TestVisible
	private static final String VESTING_REASON_OPEN_LEAD = 'Open Lead';
	@TestVisible
	private static final String VESTING_REASON_LEAD_QUALIFIED_N_MONTHS = 'Lead qualified {0}M';
	@TestVisible
	private static final String VESTING_REASON_LEAD_UNQUALIFIED_N_MONTHS = 'Lead unqualified {0}M';
	@TestVisible
	private static final String VESTING_REASON_ACTIVE_OPPORTUNITY = 'Active Opportunity';
	@TestVisible
	private static final String VESTING_REASON_OPPORTUNITY_WON_N_MONTHS = 'Opportunity won {0}M';
	@TestVisible
	private static final String VESTING_REASON_OPPORTUNITY_LOST_N_MONTHS = 'Opportunity lost {0}M';

	private static List<String> reasonFormattingArguments = new List<String>();

	@InvocableMethod(label='Sales Play Management: Get Filtered Account Collections')
	public static List<Response> getAccountCollections(List<Request> requests) {
		// only works for one request at a time
		Request request = requests[0];
		reasonFormattingArguments.add(String.valueOf(request.amountOfMonthsForDateFilter));
		Date filterDate = System.today().addMonths(-request.amountOfMonthsForDateFilter);
		List<Opportunity> opportunities = OpportunitySelector.getOrderedOpenOrClosedOpportunitiesByAccountsAndCloseDate(request.accounts, filterDate);
		List<Lead> leads = LeadSelector.getOrderedOpenOrClosedLeadsByAccountsAndCloseDate(request.accounts, filterDate);

		// using a Set as it allows for easy removal of elements using removeAll()
		Set<Account> accounts = new Set<Account>(request.accounts);

		Response response = new Response();
		response.accountsNotInVestingPeriod = getAccountsNotInVestingPeriod(accounts, opportunities, leads);
		accounts.removeAll(response.accountsNotInVestingPeriod);

		response.accountsInVestingPeriod = getAccountsInVestingPeriod(accounts, opportunities, leads);

		return new List<Response>{response};
	}

	private static List<Account> getAccountsNotInVestingPeriod(Set<Account> accounts, List<Opportunity> opportunities, List<Lead> leads) {
		Map<Id, Account> accountId2Account = new Map<Id, Account>(new List<Account>(accounts));
		for(Opportunity opp : opportunities) {
			if(accountId2Account.keySet().contains(opp.AccountId)) {
				accountId2Account.remove(opp.AccountId);
			}
		}

		for(Lead lead : leads) {
			if(accountId2Account.keySet().contains(lead.Account__c)) {
				accountId2Account.remove(lead.Account__c);
			}
		}

		return accountId2Account.values();
	}

	private static List<Account> getAccountsInVestingPeriod(Set<Account> accounts, List<Opportunity> opportunities, List<Lead> leads) {
		Map<Id, Account> accountId2Account = new Map<Id, Account>(new List<Account>(accounts));
		accountId2Account.putAll(getAccountsWithVestingReasonFromLeads(accountId2Account, leads));
		accountId2Account.putAll(getAccountsWithVestingReasonFromOpportunities(accountId2Account, opportunities));

		return accountId2Account.values();
	}

	private static Map<Id, Account> getAccountsWithVestingReasonFromLeads(Map<Id, Account> accountId2Account, List<Lead> leads) {
		Map<Id, Account> accountId2accountsInFilteredScopeWithReason = new Map<Id, Account>();

		for(Lead lead : leads) {
			Account acc = getCorrectAccountFromMaps(lead.Account__c, accountId2Account, accountId2accountsInFilteredScopeWithReason);
			Set<String> vestingReasons = getVestingReasonsFromAccount(acc);

			if(!LEAD_STATUSES_CLOSED.contains(lead.Status)) {
				vestingReasons.add(VESTING_REASON_OPEN_LEAD);
			}
			if(lead.Status == LEAD_STATUS_QUALIFIED) {
				vestingReasons.add(String.format(VESTING_REASON_LEAD_QUALIFIED_N_MONTHS, reasonFormattingArguments));
			}
			if(lead.Status == LEAD_STATUS_UNQUALIFIED) {
				vestingReasons.add(acc.Sales_Play_Vesting_Reason__c = String.format(VESTING_REASON_LEAD_UNQUALIFIED_N_MONTHS, reasonFormattingArguments));
			}
			acc.Sales_Play_Vesting_Reason__c = String.join(vestingReasons, SEPERATOR);
			accountId2accountsInFilteredScopeWithReason.put(acc.Id, acc);
		}

		return accountId2accountsInFilteredScopeWithReason;
	}

	private static Map<Id, Account> getAccountsWithVestingReasonFromOpportunities(Map<Id, Account> accountId2Account, List<Opportunity> opportunities) {
		Map<Id, Account> accountId2accountsInFilteredScopeWithReason = new Map<Id, Account>();

		for(Opportunity opp : opportunities) {
			Account acc = getCorrectAccountFromMaps(opp.AccountId, accountId2Account, accountId2accountsInFilteredScopeWithReason);
			Set<String> vestingReasons = getVestingReasonsFromAccount(acc);

			if(!opp.IsClosed) {
				vestingReasons.add(VESTING_REASON_ACTIVE_OPPORTUNITY);
			}
			if(opp.IsClosed && opp.IsWon) {
				vestingReasons.add(String.format(VESTING_REASON_OPPORTUNITY_WON_N_MONTHS, reasonFormattingArguments));
			}
			if(opp.IsClosed && !opp.IsWon) {
				vestingReasons.add(String.format(VESTING_REASON_OPPORTUNITY_LOST_N_MONTHS, reasonFormattingArguments));
			}
			acc.Sales_Play_Vesting_Reason__c = String.join(vestingReasons, SEPERATOR);
			accountId2accountsInFilteredScopeWithReason.put(acc.Id, acc);
		}

		return accountId2accountsInFilteredScopeWithReason;
	}

	private static Account getCorrectAccountFromMaps(Id accountId, Map<Id, Account> accountId2Account, Map<Id, Account> accountId2accountsInFilteredScopeWithReason) {
		Account acc;
		if(accountId2accountsInFilteredScopeWithReason.containsKey(accountId)) {
			acc = accountId2accountsInFilteredScopeWithReason.get(accountId);
		} else {
			acc = accountId2Account.get(accountId);
		}

		return acc;
	}

	private static Set<String> getVestingReasonsFromAccount(Account acc) {
		Set<String> vestingReasons = new Set<String>();
		if(String.isNotBlank(acc.Sales_Play_Vesting_Reason__c)) {
			vestingReasons.addAll(acc.Sales_Play_Vesting_Reason__c?.split(SEPERATOR));
		}

		return vestingReasons;
	}

	public class Request {
		@InvocableVariable(label='Amount of Months for Filter' required=true)
		public Integer amountOfMonthsForDateFilter;
		@InvocableVariable(label='All Accounts' required=true)
		public List<Account> accounts;
	}

	public class Response {
		@InvocableVariable(label='Accounts without Opportunity and Lead in date filtered')
		public List<Account> accountsNotInVestingPeriod = new List<Account>();
		@InvocableVariable(label='Accounts with Opportunity or Lead in date filtered')
		public List<Account> accountsInVestingPeriod = new List<Account>();
	}
}