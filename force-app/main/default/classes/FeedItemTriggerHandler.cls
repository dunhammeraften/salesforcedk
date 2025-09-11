public with sharing class FeedItemTriggerHandler extends TriggerHandler {
    private final NorlysNowService norlysNowService;
    private final PermissionService permissionService;
    private final NorlysNowSelector norlysNowSelector;
    private final EventExecutorService eventExecutorService;

    @TestVisible
    private Map<Id, FeedItem> triggerNewMap;
    @TestVisible
    private List<FeedItem> triggerNew;

    public FeedItemTriggerHandler() {
        this(SingletonFactory.getFactory());
    }

    private FeedItemTriggerHandler(SingletonFactory singletonFactory) {
        this.norlysNowSelector = (NorlysNowSelector) singletonFactory.getOrRegisterSingleton(NorlysNowSelector.class);
        this.permissionService = (PermissionService) singletonFactory.getOrRegisterSingleton(PermissionService.class);
        this.eventExecutorService = (EventExecutorService) singletonFactory.getOrRegisterSingleton(EventExecutorService.class);
        this.norlysNowService = (NorlysNowService) singletonFactory.getOrRegisterSingleton(NorlysNowService.class);
        this.triggerNewMap = (Map<Id, FeedItem>) Trigger.newMap;
        this.triggerNew = (List<FeedItem>) Trigger.new;
    }

    @TestVisible
    private FeedItemTriggerHandler(NorlysNowSelector norlysNowSelector, PermissionService permissionService, EventExecutorService eventExecutorService, NorlysNowService norlysNowService) {
        this.norlysNowSelector = norlysNowSelector;
        this.permissionService = permissionService;
        this.eventExecutorService = eventExecutorService;
        this.norlysNowService = norlysNowService;
    }

    public override void afterInsert() {

        // Skipping the rest of the code if you don't have the permission set Customer_Support_Technical_NorlysNow_Requester
        if (!permissionService.hasPermissionSet(new List<String>{ 'Customer_Support_Technical_NorlysNow_Requester' })) {
            return;
        }

        // Collect ParentIds for NorlysNow_Case__c
        Set<Id> norlysNowCaseIds = new Set<Id>();
        for (FeedItem fi : triggerNewMap.values()) {
            if (fi.ParentId != null && fi.ParentId.getSObjectType() == NorlysNow_Case__c.SObjectType) {
                norlysNowCaseIds.add(fi.ParentId);
            }
        }

        if (!norlysNowCaseIds.isEmpty()) {

            Map<Id, NorlysNow_Case__c> norlysNowCaseMap = norlysNowSelector.getNorlysNowCasesMap(norlysNowCaseIds);
            
            if (norlysNowCaseMap.isEmpty()) {
                return;
            }

            // Collect FeedItem Ids for events
            List<Id> feedItemIds = new List<Id>();
            for (FeedItem fi : triggerNewMap.values()) {
                if (norlysNowCaseMap.containsKey(fi.ParentId)) {
                    feedItemIds.add(fi.Id);
                }
            }

            List<EventExecutor__e> eventList = norlysNowService.chunkEventsInListsToBePublished(feedItemIds, 'FeedItem', 'NorlysNowExecutorHandler');

            if(!eventList.isEmpty()){
                eventExecutorService.publish(eventList);
            }
        }
    }
}