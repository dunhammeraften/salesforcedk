public class CaseService {
 
    private static String caseTeamRoleOriginatorName = 'Case Originator';

    private CaseSelector caseSelector;

    @TestVisible
    private CaseService(CaseSelector caseSelector) {
        this.caseSelector = caseSelector;
    }

    public CaseService(){
        this(SingletonFactory.getFactory());
    }

    private CaseService(SingletonFactory singletonFactory){
        this.caseSelector = (CaseSelector) singletonFactory.getOrRegisterSingleton(CaseSelector.class);
    }

    public List<Case> updateCustomerServiceCasesToAwaitingUser(List<Id> caseIds) {
        Logger.logInfo(String.format('updateCustomerServiceCasesToAwaitingUser( {0} )', new List<Object>{ caseIds }));

        if (caseIds.isEmpty()) {
            return new List<Case>();
        }
        
	    List<Case> customerServiceCases = caseSelector.getCustomerServiceCasesByIds(caseIds);	
		
		for (Case cas : customerServiceCases) {
			cas.Awaiting_user__c = true;
		}

		update customerServiceCases;

        return customerServiceCases;
	}

	/**
     * Creates team members for specified cases based on the provided team role
     * @param cases List of Cases to create team members for
     * @param teamRoleName Name of the team role to assign
     * @return List of newly created CaseTeamMember records
     * @throws Exception if team role does not exist
     */
	public List<CaseTeamMember> createTeamMember(List<Case> cases, String teamRoleName) {
		Logger.logInfo(String.format('createTeamMember( {0} )', new List<Object>{ cases }));

		List<CaseTeamMember> teamMembers = new List<CaseTeamMember>();

		if (cases.isEmpty()) {
			return teamMembers;
		}

		Id originatorTeamRoleId = caseSelector.getCaseTeamRoleIdByName(teamRoleName);

		for (Case caseIter : cases) {
            
			if (
				caseIter.OwnerId.getSobjectType() != User.getSObjectType() &&
				caseIter.OwnerId.getSobjectType() != Contact.getSObjectType()
			) {
				Logger.logInfo(String.format('OwnerId is not a contact or a user for: ( {0} )', new List<Object>{ cases }));
				//The ownerId of a case is somethimes a group
				//CaseTeamMember.MemberId cannot point to groups.
				continue;
			}

			CaseTeamMember teamMember = new CaseTeamMember();
			teamMember.ParentId = caseIter.Id;
			teamMember.MemberId = caseIter.OwnerId;
			teamMember.TeamRoleId = originatorTeamRoleId;

			teamMembers.add(teamMember);
		}

		return teamMembers;
	}

	/**
     * Generates new Case Status Change records for new cases or cases with updated statuses 
     * @param cases List of Case records to check for status changes
     * @param oldObjectMap Map containing previous versions of Case records
     * @return List of new Case_Status_Change__c records representing status changes
     */
	public List<Case_Status_Change__c> getNewCaseStatusChangeRecords(List<Case> cases, Map<Id, Case> oldObjectMap) {
		hasPermissionToCaseStatusChange();

		List<Case_Status_Change__c> statusChanges = new List<Case_Status_Change__c>();

		if (cases.isEmpty()) {
			return statusChanges;
		}

		for (Case newCase : cases) {
			Case oldCase = null;

			if (oldObjectMap != null) {
				oldCase = oldObjectMap.get(newCase.Id);
			}

			if (oldCase != null && newCase.Status == oldCase.Status) {
				continue; // we don't have a status change just continue
			}

			Case_Status_Change__c statusChange = new Case_Status_Change__c();

			if (oldCase == null) {
				//We have a new case i.e. create with new name
				statusChange.Name = newCase.CaseNumber + ' status: ' + newCase.Status;
			} else {
				statusChange.Name = newCase.CaseNumber + ' from ' + oldCase.Status + ' to ' + newCase.Status;
				statusChange.Status_From__c = oldCase.Status;
			}
			statusChange.Case__c = newCase.Id;
			statusChange.Status_Name__c = newCase.Status;
			statusChange.Current_Case_Owner__c = newCase.Case_Owner__c;
			statusChange.Set_Time__c = Datetime.now();

			statusChanges.add(statusChange);
		}

		return statusChanges;
	}

	/**
     * Updates existing Case Status Change records with calculated durations
     * @param newCaseMap Map of new Case records
     * @param oldCaseMap Map of old Case records
     * @return List of Case_Status_Change__c records with updated field values
     */
	public List<Case_Status_Change__c> getCurrentCaseStatusChangeRecords(Map<Id, Case> newCaseMap, Map<Id, Case> oldCaseMap) {
		hasPermissionToCaseStatusChange();

		List<Case_Status_Change__c> caseStatusChangesToUpdate = new List<Case_Status_Change__c>();

		//Fetch current case status change where Change_Time__c is null
		List<Case_Status_Change__c> caseStatusChanges = caseSelector.getCurrentCaseChangeStatus(newCaseMap.keySet());

		//BusinessHours is a configuration object and will not be null inside test.
		BusinessHours bh = [SELECT Id FROM BusinessHours WHERE IsDefault = TRUE LIMIT 1];

		//Loops through each of the change and set Change_Time__c, Age and
		for (Case_Status_Change__c caseStatusChange : caseStatusChanges) {
			Case newCase = newCaseMap.get(caseStatusChange.Case__c);
			Case oldCase = oldCaseMap.get(caseStatusChange.Case__c);

			if (newCase.Status != oldCase.status) {
				// calculate business hours
				caseStatusChange.Change_Time__c = Datetime.now();

				Double milliseconds = BusinessHours.diff(
					bh.Id,
					caseStatusChange.Set_Time__c,
					caseStatusChange.Change_Time__c
				);
				caseStatusChange.Status_Time__c = (Decimal.valueOf(milliseconds)).Divide((60 * 60 * 1000), 2);
				caseStatusChange.Age__c = getAge(milliseconds);

				caseStatusChangesToUpdate.add(caseStatusChange);
			}
		}

		return caseStatusChangesToUpdate;
	}

    /**
     * Converts milliseconds into human-readable age format
     * @param milliseconds Time duration in milliseconds
     * @return Formatted string showing days, hours, minutes, and seconds
     */
	private String getAge(Double milliseconds) {
		Double duration = milliseconds;
		Double d = Math.floor(duration / 86400000); //Get whole days
		duration -= d * 86400000;
		Double h = Math.floor(duration / 3600000); //Get whole hours
		duration -= h * 3600000;
		Double m = Math.floor(duration / 60000);
		duration -= m * 60000;
		Double s = Math.floor(duration / 1000);
		return d.format() + ' days ' + h.format() + ' hours ' + m.format() + ' minutes ' + s.format() + ' seconds';
	}

    /**
     * Verifies user permissions for case status change operations
     * @throws DMLException if insufficient permissions exist
     */
	public Boolean hasPermissionToCaseStatusChange() {
		//check if user has permission to create/update to Case_Status_Change__c records
		if (
			!Schema.sObjectType.Case.isAccessible() ||
			!Schema.sObjectType.Case.fields.CaseNumber.isAccessible() ||
			!Schema.sObjectType.User.isAccessible() ||
			!Schema.sObjectType.User.fields.Name.isAccessible() ||
			!Schema.sObjectType.BusinessHours.isAccessible() ||
			!Schema.sObjectType.Case_Status_Change__c.isAccessible() ||
			!Schema.sObjectType.Case_Status_Change__c.fields.Name.isAccessible() ||
			!Schema.sObjectType.Case_Status_Change__c.fields.Name.isCreateable() ||
			!Schema.sObjectType.Case_Status_Change__c.fields.Name.isUpdateable() ||
			!Schema.sObjectType.Case_Status_Change__c.fields.Case__c.isCreateable() ||
			!Schema.sObjectType.Case_Status_Change__c.fields.Case__c.isUpdateable() ||
			!Schema.sObjectType.Case_Status_Change__c.fields.Status_Name__c.isCreateable() ||
			!Schema.sObjectType.Case_Status_Change__c.fields.Status_Name__c.isUpdateable() ||
			!Schema.sObjectType.Case_Status_Change__c.fields.Current_Case_Owner__c.isCreateable() ||
			!Schema.sObjectType.Case_Status_Change__c.fields.Current_Case_Owner__c.isUpdateable() ||
			!Schema.sObjectType.Case_Status_Change__c.fields.Set_Time__c.isAccessible() ||
			!Schema.sObjectType.Case_Status_Change__c.fields.Set_Time__c.isCreateable() ||
			!Schema.sObjectType.Case_Status_Change__c.fields.Set_Time__c.isUpdateable() ||
			!Schema.sObjectType.Case_Status_Change__c.fields.Status_From__c.isUpdateable() ||
			!Schema.sObjectType.Case_Status_Change__c.fields.Status_From__c.isCreateable() ||
			!Schema.sObjectType.Case_Status_Change__c.fields.Change_Time__c.isUpdateable() ||
			!Schema.sObjectType.Case_Status_Change__c.fields.Status_Time__c.isUpdateable() ||
			!Schema.sObjectType.Case_Status_Change__c.fields.Age__c.isUpdateable()
		) {
			throw new DmlException('Insufficient permissions for Case Status Change');
		}

		return true;
	}
}