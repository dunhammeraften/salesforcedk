/**
 * @description Trigger handler for NorlysNow_Case__c objects.
 *              This class is responsible for orchestrating services to close parent cases,
 *              send case data to Norlys Now, and prevent updates on closed parent cases.
 * @see INorlysNowIntegrationStrategy
 *
 * -----------------------------------------------------------------------------
 * @author Developer           Date            Description
 * -----------------------------------------------------------------------------
 * @author Esben Hovgaard        18/09/2025      Class, method and inline documentation
 * -----------------------------------------------------------------------------
 */
public with sharing class NorlysNowCaseTriggerHandler extends TriggerHandler {
	private final NorlysNowService norlysNowService;
	private final NorlysNowSelector norlysNowSelector;
	private final DatabaseService databaseService;
	private final PermissionService permissionService;
	private final EventExecutorService eventExecutorService;

	@TestVisible
	private Map<Id, NorlysNow_Case__c> triggerNewMap;
	@TestVisible
	private Map<Id, NorlysNow_Case__c> triggerOldMap;
	@TestVisible
	private List<NorlysNow_Case__c> triggerNew;

	/**
	 * @description Default constructor that initializes the required services using the SingletonFactory.
	 */
	public NorlysNowCaseTriggerHandler() {
		this(SingletonFactory.getFactory());
	}

	/**
	 * @description Private constructor for dependency injection.
	 * @param singletonFactory The SingletonFactory instance to use for creating dependencies.
	 */
	private NorlysNowCaseTriggerHandler(SingletonFactory singletonFactory) {
		this.norlysNowService = (NorlysNowService) singletonFactory.getOrRegisterSingleton(NorlysNowService.class);
		this.norlysNowSelector = (NorlysNowSelector) singletonFactory.getOrRegisterSingleton(NorlysNowSelector.class);
		this.databaseService = (DatabaseService) singletonFactory.getOrRegisterSingleton(DatabaseService.class);
		this.permissionService = (PermissionService) singletonFactory.getOrRegisterSingleton(PermissionService.class);
		this.eventExecutorService = (EventExecutorService) singletonFactory.getOrRegisterSingleton(
			EventExecutorService.class
		);
		this.triggerNewMap = (Map<Id, NorlysNow_Case__c>) Trigger.newMap;
		this.triggerOldMap = (Map<Id, NorlysNow_Case__c>) Trigger.oldMap;
		this.triggerNew = (List<NorlysNow_Case__c>) Trigger.new;
	}

	/**
	 * @description This method is called after a NorlysNow_Case__c record is updated.
	 *              It closes the parent case if the NorlysNow_Case__c status is updated,
	 *              and publishes an event to send the case to Norlys Now.
	 */
	public override void afterUpdate() {
		List<NorlysNow_Case__c> closedCases = new List<NorlysNow_Case__c>();
		List<Id> norlysNowCaseToBeSentIds = new List<Id>();
		List<NorlysNow_Case__c> statusChangedCases = new List<NorlysNow_Case__c>();

		for (NorlysNow_Case__c norlysNowCase : triggerNewMap.values()) {
			NorlysNow_Case__c oldCase = triggerOldMap.get(norlysNowCase.Id);

			// Check for status change to 'Closed'
			if (norlysNowCase.Status__c == 'Closed' && oldCase.Status__c != 'Closed') {
				closedCases.add(norlysNowCase);
			}

			// Check for cases to be sent to Norlys Now
			if (norlysNowCase.Status__c == 'Withdrawn' || norlysNowCase.Sync_Status__c == 'Pending') {
				norlysNowCaseToBeSentIds.add(norlysNowCase.Id);
			}

			// Check for status changes that require a notification
			if (norlysNowCase.Status__c != oldCase.Status__c && norlysNowCase.Status__c != 'Withdrawn') {
				statusChangedCases.add(norlysNowCase);
			}
		}

		// Close parent cases if needed
		if (!closedCases.isEmpty()) {
			List<Case> parentCasesToClose = norlysNowService.closeParentCases(closedCases);
			if (!parentCasesToClose.isEmpty()) {
				databaseService.updateRecords(parentCasesToClose);
			}
		}

		// Send notifications for status changes
		if (!statusChangedCases.isEmpty()) {
			norlysNowService.sendNotifications(
				statusChangedCases,
				'Case Status Changed',
				'The status of your case has been updated.'
			);
		}

		// The following logic should only be executed by users with the correct permission set
		if (!permissionService.hasPermissionSet(new List<String>{ 'Customer_Support_Technical_NorlysNow_Requester' })) {
			Logger.logWarning('User does not have the required permission set. Exiting.');
			return;
		}

		// Publish events for cases to be sent to Norlys Now
		if (!norlysNowCaseToBeSentIds.isEmpty()) {
			Logger.logDebug('norlysNowCaseToBeSentIds: ' + norlysNowCaseToBeSentIds);
			List<EventExecutor__e> eventList = norlysNowService.chunkEventsInListsToBePublished(
				norlysNowCaseToBeSentIds,
				'NorlysNow_Case__c',
				'NorlysNowExecutorHandler'
			);
			if (eventList != null && !eventList.isEmpty()) {
				Logger.logDebug('eventList: ' + eventList);
				eventExecutorService.publishEvents(eventList);
			}
		}
	}

	/**
	 * @description This method is called before a NorlysNow_Case__c record is updated.
	 *              It checks if the parent case is closed and prevents the update if it is.
	 */
	public override void beforeUpdate() {
		norlysNowService.CheckParentCaseIsClosed(triggerNew);
	}

	/**
	 * @description This method is called before a NorlysNow_Case__c record is inserted.
	 *              It checks if the parent case is closed and prevents the insert if it is.
	 */
	public override void beforeInsert() {
		norlysNowService.CheckParentCaseIsClosed(triggerNew);
	}

	/**
	 * @description This method is called after a NorlysNow_Case__c record is inserted.
	 *              It publishes an event to send the case to Norlys Now.
	 */
	public override void afterInsert() {
		// Exit if the user doesn't have the required permission set
		if (!permissionService.hasPermissionSet(new List<String>{ 'Customer_Support_Technical_NorlysNow_Requester' })) {
			Logger.logWarning('User does not have the required permission set.');
			return;
		}

		//Set Parent case status to 'Redirected'
		List<Case> parentCasesToUpdate = new List<Case>();
		for (NorlysNow_Case__c norlysNowCase : triggerNewMap.values()) {
			if (norlysNowCase.Parent_Case__c != null) {
				Case parentCase = new Case(Id = norlysNowCase.Parent_Case__c, Status = 'Redirected');
				parentCasesToUpdate.add(parentCase);
			}
		}

		// Update parent cases
		if (!parentCasesToUpdate.isEmpty()) {
			Logger.logDebug('parentCasesToUpdate: ' + parentCasesToUpdate);
			databaseService.updateRecords(parentCasesToUpdate);
		}

		// Collect Ids of NorlysNowCases to be sent to NorlysNow
		List<Id> norlysNowCaseToBeSentIds = new List<Id>();
		for (NorlysNow_Case__c norlysNowCase : triggerNewMap.values()) {
			norlysNowCaseToBeSentIds.add(norlysNowCase.Id);
		}

		// Chunk the Ids into events to be published
		List<EventExecutor__e> eventList = norlysNowService.chunkEventsInListsToBePublished(
			norlysNowCaseToBeSentIds,
			'NorlysNow_Case__c',
			'NorlysNowExecutorHandler'
		);

		// Publish the events to the event bus
		if (eventList != null && !eventList.isEmpty()) {
			Logger.logDebug('eventList: ' + eventList);
			eventExecutorService.publishEvents(eventList);
		}
	}
}
