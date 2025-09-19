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
		this.norlysNowSelector = (NorlysNowSelector) singletonFactory.getOrRegisterSingleton(
			NorlysNowSelector.class
		);
		this.permissionService = (PermissionService) singletonFactory.getOrRegisterSingleton(
			PermissionService.class
		);
		this.eventExecutorService = (EventExecutorService) singletonFactory.getOrRegisterSingleton(
			EventExecutorService.class
		);
		this.norlysNowService = (NorlysNowService) singletonFactory.getOrRegisterSingleton(
			NorlysNowService.class
		);
		this.triggerNewMap = (Map<Id, FeedItem>) Trigger.newMap;
		this.triggerNew = (List<FeedItem>) Trigger.new;
	}

	/**
	 * @description After a FeedItem is inserted, this method checks if it's related to a NorlysNow_Case__c.
	 *              If so, and if the user has the correct permissions, it publishes an event to send the
	 *              FeedItem to Norlys Now.
	 */
	public override void afterInsert() {
		// The following logic should only be executed by users with the correct permission set.
		if (
			!permissionService.hasPermissionSet(
				new List<String>{ 'Customer_Support_Technical_NorlysNow_Requester' }
			)
		) {
			return;
		}

		// Collect ParentIds that are NorlysNow_Case__c records.
		Set<Id> norlysNowCaseIds = new Set<Id>();
		for (FeedItem fi : triggerNewMap.values()) {
			if (
				fi.ParentId != null &&
				fi.ParentId.getSObjectType() == NorlysNow_Case__c.SObjectType
			) {
				norlysNowCaseIds.add(fi.ParentId);
			}
		}

		// If any FeedItems are related to NorlysNow_Case__c, proceed.
		if (!norlysNowCaseIds.isEmpty()) {
			// Get the full NorlysNow_Case__c records from the database.
			Map<Id, NorlysNow_Case__c> norlysNowCaseMap = norlysNowSelector.getNorlysNowCasesMap(
				norlysNowCaseIds
			);

			if (norlysNowCaseMap.isEmpty()) {
				return;
			}

			// Collect the Ids of the FeedItems that are related to the fetched NorlysNow_Case__c records.
			List<Id> feedItemIds = new List<Id>();
			for (FeedItem fi : triggerNewMap.values()) {
				if (norlysNowCaseMap.containsKey(fi.ParentId)) {
					feedItemIds.add(fi.Id);
				}
			}

			// Chunk the FeedItem Ids into events and publish them to the event bus.
			List<EventExecutor__e> eventList = norlysNowService.chunkEventsInListsToBePublished(
				feedItemIds,
				'FeedItem',
				'NorlysNowExecutorHandler'
			);

			if (eventList != null && !eventList.isEmpty()) {
				eventExecutorService.publishEvents(eventList);
			}
		}
	}
}
