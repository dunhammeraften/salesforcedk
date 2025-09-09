public with sharing class LeadSelector {
    @TestVisible
	private static final String LEAD_STATUS_QUALIFIED = 'Qualified';
	@TestVisible
	private static final String LEAD_STATUS_UNQUALIFIED = 'Unqualified';
    @TestVisible
    private static final String LEAD_UNQUALIFIED_REASON_DEACTIVATED = 'Deactivated';
    
	private static final Set<String> LEAD_STATUSES_CLOSED = new Set<String>{
		LEAD_STATUS_QUALIFIED,
		LEAD_STATUS_UNQUALIFIED
	};

    public static List<Lead> getOrderedOpenOrClosedLeadsByAccountsAndCloseDate(List<Account> accounts, Date filterDate) {
        return [
			SELECT Id, Account__c, Status, Close_Date__c
			FROM Lead
			WHERE Account__c IN :accounts
                AND (Status != :LEAD_STATUS_UNQUALIFIED OR Unqualified_Reason__c != :LEAD_UNQUALIFIED_REASON_DEACTIVATED)                 
				AND (                    
					(Status NOT IN :LEAD_STATUSES_CLOSED) OR
					(Status IN :LEAD_STATUSES_CLOSED AND Close_Date__c > :filterDate)
				)
			ORDER BY Close_Date__c, Status
		];
    }
}