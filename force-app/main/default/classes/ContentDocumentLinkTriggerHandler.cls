/**
 * @description Trigger handler for ContentDocumentLink objects. This class is responsible for
 *              handling logic when files are attached to records.
 *
 * -----------------------------------------------------------------------------
 * @author Developer           Date            Description
 * -----------------------------------------------------------------------------
 * @author Esben Hovgaard        18/09/2025      Class, method and inline documentation
 * -----------------------------------------------------------------------------
 */
public with sharing class ContentDocumentLinkTriggerHandler extends TriggerHandler {
	@TestVisible
	private List<ContentDocumentLink> triggerNew;
	private final CaseService caseService;
	private final ContentDocumentLinkService contentDocumentLinkService;
	private final PermissionService permissionService;
	private final NorlysNowService norlysNowService;
	private final EventExecutorService eventExecutorService;

	/**
	 * @description Default constructor that initializes the required services using the SingletonFactory.
	 */
	public ContentDocumentLinkTriggerHandler() {
		this(SingletonFactory.getFactory());
	}

	/**
	 * @description Private constructor for dependency injection.
	 * @param singletonFactory The SingletonFactory instance to use for creating dependencies.
	 */
	private ContentDocumentLinkTriggerHandler(SingletonFactory singletonFactory) {
		this.contentDocumentLinkService = (ContentDocumentLinkService) singletonFactory.getOrRegisterSingleton(
			ContentDocumentLinkService.class
		);
		this.caseService = (caseService) singletonFactory.getOrRegisterSingleton(CaseService.class);
		this.permissionService = (PermissionService) singletonFactory.getOrRegisterSingleton(PermissionService.class);
		this.eventExecutorService = (EventExecutorService) singletonFactory.getOrRegisterSingleton(
			EventExecutorService.class
		);
		this.norlysNowService = (NorlysNowService) singletonFactory.getOrRegisterSingleton(NorlysNowService.class);
		this.triggerNew = (List<ContentDocumentLink>) Trigger.new;
	}

	/**
	 * @description This method is called after a ContentDocumentLink record is inserted.
	 *              It updates the status of related cases and publishes an event to send the
	 *              file to Norlys Now if it's linked to a NorlysNow_Case__c.
	 */
	public override void afterInsert() {
		// When a file is attached, get the Ids of any related Case records.
		List<Id> caseIds = contentDocumentLinkService.getRelatedCasesByLinkedEntityIds(triggerNew);

		// If the file was attached to a Case, update the case status.
		caseService.updateCustomerServiceCasesToAwaitingUser(caseIds);

		// The following logic should only be executed by users with the correct permission set.
		if (!permissionService.hasPermissionSet(new List<String>{ 'Customer_Support_Technical_NorlysNow_Requester' })) {
			Logger.logWarning('User does not have the required permission set. Exiting.');
			return;
		}

		// If the file was attached to a NorlysNow_Case__c, collect the file and case Ids.
		List<Id> fileIds = new List<Id>();
		Set<Id> norlysNowCaseIds = new Set<Id>();
		for (ContentDocumentLink cdl : triggerNew) {
			if (cdl.LinkedEntityId.getSObjectType() == NorlysNow_Case__c.SObjectType) {
				fileIds.add(cdl.ContentDocumentId);
				norlysNowCaseIds.add(cdl.LinkedEntityId);
			}
		}
		// If any files were attached to a NorlysNow_Case__c, publish an event to send them to Norlys Now.
		if (!fileIds.isEmpty()) {
			Logger.logDebug('fileIds: ' + fileIds);
			List<EventExecutor__e> eventList = norlysNowService.chunkEventsInListsToBePublished(
				fileIds,
				'ContentDocumentLink',
				'NorlysNowExecutorHandler'
			);
			if (eventList != null && !eventList.isEmpty()) {
				Logger.logDebug('eventList: ' + eventList);
				eventExecutorService.publishEvents(eventList);
			}
		}
	}
}
