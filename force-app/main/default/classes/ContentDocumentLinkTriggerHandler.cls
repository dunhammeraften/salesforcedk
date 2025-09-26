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
	private final NorlysNowSelector norlysNowSelector;

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
		this.norlysNowSelector = (NorlysNowSelector) singletonFactory.getOrRegisterSingleton(NorlysNowSelector.class);
		this.triggerNew = (List<ContentDocumentLink>) Trigger.new;
	}

	/**
	 * @description This method is called after a ContentDocumentLink record is inserted.
	 *              It updates the status of related cases and publishes an event to send the
	 *              file to Norlys Now if it's linked to a NorlysNow_Case__c.
	 */
	public override void afterInsert() {
		// Update status on standard cases
		List<Id> caseIds = contentDocumentLinkService.getRelatedCasesByLinkedEntityIds(triggerNew);
		caseService.updateCustomerServiceCasesToAwaitingUser(caseIds);

		// Pre-filter for links related to NorlysNow_Case__c
		List<ContentDocumentLink> norlysNowLinks = new List<ContentDocumentLink>();
		Set<Id> norlysNowCaseIds = new Set<Id>();
		for (ContentDocumentLink cdl : triggerNew) {
			if (cdl.LinkedEntityId.getSObjectType() == NorlysNow_Case__c.SObjectType) {
				norlysNowLinks.add(cdl);
				norlysNowCaseIds.add(cdl.LinkedEntityId);
			}
		}

		if (norlysNowLinks.isEmpty()) {
			return;
		}
		// Get all necessary parent case data in a single query
		Map<Id, NorlysNow_Case__c> norlysNowCaseMap = norlysNowSelector.getNorlysNowCasesMap(norlysNowCaseIds);
		if (norlysNowCaseMap.isEmpty()) {
			Logger.logDebug('norlysNowCaseMap is empty for the given Parent Ids.');
			return;
		}

		// Handle notifications for the integration user
		if (UserInfo.getUserEmail() == 'norlysnowintegration@norlys.dk') {
			List<NorlysNow_Case__c> casesToNotify = new List<NorlysNow_Case__c>();
			for (ContentDocumentLink cdl : norlysNowLinks) {
				NorlysNow_Case__c parentCase = norlysNowCaseMap.get(cdl.LinkedEntityId);
				if (parentCase != null && parentCase.CreatedById != UserInfo.getUserId()) {
					casesToNotify.add(parentCase);
				}
			}
			if (!casesToNotify.isEmpty()) {
				norlysNowService.sendNotifications(
					casesToNotify,
					'New File on Your Case',
					'A new file has been attached to your case by the Norlys Now Integration User.'
				);
			}
		}

		// Handle event publishing for users with the correct permission
		if (permissionService.hasPermissionSet(new List<String>{ 'Customer_Support_Technical_NorlysNow_Requester' })) {
			List<Id> fileIdsToPublish = new List<Id>();
			for (ContentDocumentLink cdl : norlysNowLinks) {
				fileIdsToPublish.add(cdl.ContentDocumentId);
			}

			if (!fileIdsToPublish.isEmpty()) {
				List<EventExecutor__e> eventList = norlysNowService.chunkEventsInListsToBePublished(
					fileIdsToPublish,
					'ContentDocumentLink',
					'NorlysNowExecutorHandler'
				);
				if (eventList != null && !eventList.isEmpty()) {
					eventExecutorService.publishEvents(eventList);
				}
			}
		}
	}
}
