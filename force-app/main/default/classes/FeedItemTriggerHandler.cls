/**
 * @description Trigger handler for the FeedItem object.
 *
 * -----------------------------------------------------------------------------
 * @author Developer           Date            Description
 * -----------------------------------------------------------------------------
 * @author Esben Hovgaard        18/09/2025      Class, method and inline documentation
 * -----------------------------------------------------------------------------
 */
public with sharing class FeedItemTriggerHandler extends TriggerHandler {
	private final NorlysNowService norlysNowService;
	private final PermissionService permissionService;
	private final NorlysNowSelector norlysNowSelector;
	private final EventExecutorService eventExecutorService;

	@TestVisible
	private Map<Id, FeedItem> triggerNewMap;
	@TestVisible
	private List<FeedItem> triggerNew;

	/**
	 * @description Default constructor that initializes the required services using the SingletonFactory.
	 */
	public FeedItemTriggerHandler() {
		this(SingletonFactory.getFactory());
	}

	/**
	 * @description Private constructor for dependency injection.
	 * @param singletonFactory The SingletonFactory instance to use for creating dependencies.
	 */
	private FeedItemTriggerHandler(SingletonFactory singletonFactory) {
		this.norlysNowSelector = (NorlysNowSelector) singletonFactory.getOrRegisterSingleton(NorlysNowSelector.class);
		this.permissionService = (PermissionService) singletonFactory.getOrRegisterSingleton(PermissionService.class);
		this.eventExecutorService = (EventExecutorService) singletonFactory.getOrRegisterSingleton(
			EventExecutorService.class
		);
		this.norlysNowService = (NorlysNowService) singletonFactory.getOrRegisterSingleton(NorlysNowService.class);
		this.triggerNewMap = (Map<Id, FeedItem>) Trigger.newMap;
		this.triggerNew = (List<FeedItem>) Trigger.new;
	}

	/**
	 * @description After a FeedItem is inserted, this method checks if it's related to a NorlysNow_Case__c.
	 *              If so, and if the user has the correct permissions, it publishes an event to send the
	 *              FeedItem to Norlys Now.
	 */
	public override void afterInsert() {
		// Step 1: Pre-filter FeedItems related to NorlysNow_Case__c to avoid multiple loops
		List<FeedItem> norlysNowFeedItems = new List<FeedItem>();
		Set<Id> norlysNowCaseIds = new Set<Id>();
		for (FeedItem fi : triggerNew) {
			if (fi.ParentId != null && fi.ParentId.getSObjectType() == NorlysNow_Case__c.SObjectType) {
				norlysNowFeedItems.add(fi);
				norlysNowCaseIds.add(fi.ParentId);
			}
		}

		if (norlysNowFeedItems.isEmpty()) {
			return;
		}

		// Step 2: Get all necessary parent case data in a single query
		Map<Id, NorlysNow_Case__c> norlysNowCaseMap = norlysNowSelector.getNorlysNowCasesMap(norlysNowCaseIds);
		if (norlysNowCaseMap.isEmpty()) {
			Logger.logDebug('norlysNowCaseMap is empty for the given Parent Ids.');
			return;
		}

		// Step 3: Handle internal notification for the integration user
		if (UserInfo.getUserEmail() == 'norlysnowintegration@norlys.dk') {
			List<NorlysNow_Case__c> casesToNotify = new List<NorlysNow_Case__c>();
			for (FeedItem fi : norlysNowFeedItems) {
				NorlysNow_Case__c parentCase = norlysNowCaseMap.get(fi.ParentId);
				// Ensure parent case exists and the creator is not the integration user itself
				if (parentCase != null && parentCase.CreatedById != UserInfo.getUserId()) {
					casesToNotify.add(parentCase);
				}
			}
			if (!casesToNotify.isEmpty()) {
				norlysNowService.sendNotifications(
					casesToNotify,
					'New Comment on Your Case',
					'A new comment has been added to your case by the Norlys Now Integration User.'
				);
			}
		}

		// Step 4: Handle external event publishing for users with the correct permission
		if (permissionService.hasPermissionSet(new List<String>{ 'Customer_Support_Technical_NorlysNow_Requester' })) {
			List<Id> feedItemIdsToPublish = new List<Id>();
			for (FeedItem fi : norlysNowFeedItems) {
				feedItemIdsToPublish.add(fi.Id);
			}

			if (!feedItemIdsToPublish.isEmpty()) {
				List<EventExecutor__e> eventList = norlysNowService.chunkEventsInListsToBePublished(
					feedItemIdsToPublish,
					'FeedItem',
					'NorlysNowExecutorHandler'
				);
				if (eventList != null && !eventList.isEmpty()) {
					eventExecutorService.publishEvents(eventList);
				}
			}
		}
	}
}
