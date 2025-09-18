public with sharing class ContentDocumentLinkTriggerHandler extends TriggerHandler {
	@TestVisible
    private List<ContentDocumentLink> triggerNew;
	private final CaseService caseService;
	private final ContentDocumentLinkService contentDocumentLinkService;
    private final PermissionService permissionService;
    private final NorlysNowService norlysNowService;
    private final EventExecutorService eventExecutorService;

	public ContentDocumentLinkTriggerHandler() {
        this(SingletonFactory.getFactory());
    }

	private ContentDocumentLinkTriggerHandler(SingletonFactory singletonFactory) {
        this.contentDocumentLinkService = (ContentDocumentLinkService) singletonFactory.getOrRegisterSingleton(ContentDocumentLinkService.class);
       	this.caseService = (caseService) singletonFactory.getOrRegisterSingleton(CaseService.class);
        this.permissionService = (PermissionService) singletonFactory.getOrRegisterSingleton(PermissionService.class);
        this.eventExecutorService = (EventExecutorService) singletonFactory.getOrRegisterSingleton(EventExecutorService.class);
        this.norlysNowService = (NorlysNowService) singletonFactory.getOrRegisterSingleton(NorlysNowService.class);
		this.triggerNew = (List<ContentDocumentLink>) Trigger.new;
    }

	public override void afterInsert() {
		List<Id> caseIds = contentDocumentLinkService.getRelatedCasesByLinkedEntityIds(triggerNew);

		caseService.updateCustomerServiceCasesToAwaitingUser(caseIds);

        // Skipping the rest of the code if you don't have the permission set Customer_Support_Technical_NorlysNow_Requester
        if (!permissionService.hasPermissionSet(new List<String>{ 'Customer_Support_Technical_NorlysNow_Requester' })) {
            return;
        }

        List<Id> fileIds = new List<Id>();
        Set<Id> norlysNowCaseIds = new Set<Id>();
        for (ContentDocumentLink cdl : triggerNew) {
            if (cdl.LinkedEntityId.getSObjectType() == NorlysNow_Case__c.SObjectType) {
                fileIds.add(cdl.ContentDocumentId);
                norlysNowCaseIds.add(cdl.LinkedEntityId);
            }
        }

        if (!fileIds.isEmpty()) {
            List<EventExecutor__e> eventList = norlysNowService.chunkEventsInListsToBePublished(fileIds, 'ContentDocumentLink', 'NorlysNowExecutorHandler');
            if(eventList != null && !eventList.isEmpty() ){
                eventExecutorService.publishEvents(eventList);
            }
        }
	}
}