public class CaseTriggerHandler extends TriggerHandler {

	private CaseService caseService;

    /**
     * Collection of newly inserted EventExecutor records from the trigger context
     */
    private List<Case> triggerNew;
    private Map<Id, Case> oldCaseMap;


	public CaseTriggerHandler() {
        this(SingletonFactory.getFactory());
	}
    
    public CaseTriggerHandler(SingletonFactory singletonFactory) {
        this.triggerNew = (List<Case>) Trigger.new;
        this.oldCaseMap = (Map<Id, Case>) Trigger.oldMap;

		this.caseService = (CaseService) singletonFactory.getOrRegisterSingleton(CaseService.class);
	}

	protected override void afterInsert() {
		insert caseService.createTeamMember(triggerNew, 'Case Originator');
		
        insert caseService.getNewCaseStatusChangeRecords(triggerNew, null);
	}

	protected override void afterUpdate() {
        //Set the Change_Time__c for the existing Case_Change_Status record
        List<Case_Status_Change__c> changes = caseService.getCurrentCaseStatusChangeRecords( new Map<Id, Case>(triggerNew), oldCaseMap);

        //Create new Case_Change_Status__c record
        changes.addAll( caseService.getNewCaseStatusChangeRecords(triggerNew, oldCaseMap) );

        upsert changes;
	}
}