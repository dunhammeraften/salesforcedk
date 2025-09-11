public with sharing class NorlysNowCaseTriggerHandler extends TriggerHandler {
    private final NorlysNowService norlysNowService;
    private final NorlysNowSelector norlysNowSelector;
    private final DatabaseService databaseService;
    private final PermissionService permissionService;
    private final EventExecutorService eventExecutorService;

    @TestVisible
    private Map<Id, NorlysNow_Case__c> triggerNewMap;
    @TestVisible
    private List<NorlysNow_Case__c> triggerNew;
    
    public NorlysNowCaseTriggerHandler() {
        this(SingletonFactory.getFactory());
    }

    private NorlysNowCaseTriggerHandler(SingletonFactory singletonFactory) {
        this.norlysNowService = (NorlysNowService) singletonFactory.getOrRegisterSingleton(NorlysNowService.class);
        this.norlysNowSelector = (NorlysNowSelector) singletonFactory.getOrRegisterSingleton(NorlysNowSelector.class);
        this.databaseService = (DatabaseService) singletonFactory.getOrRegisterSingleton(DatabaseService.class);
        this.permissionService = (PermissionService) singletonFactory.getOrRegisterSingleton(PermissionService.class);
        this.eventExecutorService = (EventExecutorService) singletonFactory.getOrRegisterSingleton(EventExecutorService.class);
        this.triggerNewMap = (Map<Id, NorlysNow_Case__c>) Trigger.newMap;
        this.triggerNew = (List<NorlysNow_Case__c>) Trigger.new;
    }

    @TestVisible
    private NorlysNowCaseTriggerHandler(NorlysNowService norlysNowService, NorlysNowSelector norlysNowSelector, DatabaseService databaseService, PermissionService permissionService, EventExecutorService eventExecutorService) {
        this.norlysNowService = norlysNowService;
        this.norlysNowSelector = norlysNowSelector;
        this.databaseService = databaseService;
        this.permissionService = permissionService;
        this.eventExecutorService = eventExecutorService;
    }

    public override void afterUpdate() {

        Map<Id, NorlysNow_Case__c> norlysNowCaseMap = norlysNowSelector.getNorlysNowCasesMap(triggerNewMap.keySet());

        if(!norlysNowCaseMap.isEmpty()){

            //Close parent cases in case NorlysNow_Case__c status is updated
            List<Case> parentCasesToClose = norlysNowService.closeParentCases(norlysNowCaseMap.values());

            if (!parentCasesToClose.isEmpty() ) {
                databaseService.updateRecords(parentCasesToClose);
            }

            // Skipping the rest of the code if you don't have the permission set Customer_Support_Technical_NorlysNow_Requester
            if (!permissionService.hasPermissionSet(new List<String>{ 'Customer_Support_Technical_NorlysNow_Requester' }) ) {
                return;
            }

            // Create a list of string instead of set string to make chunkListOfStrings happy
            List<Id> norlysNowCaseToBeSentIds = new List<Id> ();
            for(NorlysNow_Case__c norlysNowCase : norlysNowCaseMap.values()){
                if(norlysNowCase.Status__c == 'Withdrawn' || norlysNowCase.Sync_Status__c == 'Pending' ){
                    norlysNowCaseToBeSentIds.add(norlysNowCase.Id);
                }
            }
            
            List<EventExecutor__e> eventList = new List<EventExecutor__e>();
            if(!norlysNowCaseToBeSentIds.isEmpty()){
                eventList = norlysNowService.chunkEventsInListsToBePublished(norlysNowCaseToBeSentIds, 'NorlysNow_Case__c', 'NorlysNowExecutorHandler');
            }
            
            if(!eventList.isEmpty() ){
                eventExecutorService.publish(eventList);
            }
        }
    }

    public override void beforeUpdate() {

        norlysNowService.CheckParentCaseIsClosed(triggerNew);

    }

    public override void beforeInsert() {

        norlysNowService.CheckParentCaseIsClosed(triggerNew);

    }

    public override void afterInsert() {

        // exist if you don't have the permission set Customer_Support_Technical_NorlysNow_Requester
        if (!permissionService.hasPermissionSet(new List<String>{ 'Customer_Support_Technical_NorlysNow_Requester' })) {
            return;
        }

        Map<Id, NorlysNow_Case__c> norlysNowCaseMap = norlysNowSelector.getNorlysNowCasesMap(triggerNewMap.keySet());

        if(!norlysNowCaseMap.isEmpty()){

            // Create a list of string instead of set string to make chunkListOfStrings happy
            List<Id> norlysNowCaseToBeSentIds = new List<Id> ();
            for(NorlysNow_Case__c norlysNowCase : norlysNowCaseMap.values()){
                norlysNowCaseToBeSentIds.add(norlysNowCase.Id);
            }

            List<EventExecutor__e> eventList = norlysNowService.chunkEventsInListsToBePublished(norlysNowCaseToBeSentIds, 'NorlysNow_Case__c', 'NorlysNowExecutorHandler');

            if(!eventList.isEmpty()){
                eventExecutorService.publish(eventList);
            }
        }
    }
}