/**
 * @description This class implements the integration strategy for FeedItem records.
 *              It handles the logic for sending new posts on NorlysNow_Case__c records
 *              to the Norlys Now system as comments.
 * @see INorlysNowIntegrationStrategy
 *
 * -----------------------------------------------------------------------------
 * @author Developer           Date            Description
 * -----------------------------------------------------------------------------
 * @author Esben Hovgaard        18/09/2025      Class, method, inline documentation and logging
 * -----------------------------------------------------------------------------
 */
public with sharing class NorlysNowFeedItemStrategy implements INorlysNowIntegrationStrategy {
	private final NorlysNowService norlysNowService;
	private final NorlysNowSelector norlysNowSelector;
	private final DatabaseService databaseService;
	private final NorlysNowClient norlysNowClient;

	/**
	 * @description Default constructor that initializes the required services using the SingletonFactory.
	 */
	public NorlysNowFeedItemStrategy() {
		this(SingletonFactory.getFactory());
	}

	/**
	 * @description Private constructor for dependency injection.
	 * @param singletonFactory The SingletonFactory instance to use for creating dependencies.
	 */
	private NorlysNowFeedItemStrategy(SingletonFactory singletonFactory) {
		this.norlysNowService = (NorlysNowService) singletonFactory.getOrRegisterSingleton(NorlysNowService.class);
		this.norlysNowSelector = (NorlysNowSelector) singletonFactory.getOrRegisterSingleton(NorlysNowSelector.class);
		this.norlysNowClient = (NorlysNowClient) singletonFactory.getOrRegisterSingleton(NorlysNowClient.class);
		this.databaseService = (DatabaseService) singletonFactory.getOrRegisterSingleton(DatabaseService.class);
	}

	/**
	 * @description Executes the logic to send FeedItem records to the Norlys Now system.
	 *              It iterates through the records from the event, calls the Norlys Now client,
	 *              and handles success, error, and retry scenarios.
	 * @param event The platform event containing the record Ids to process.
	 * @return A set of record Ids that failed and need to be retried.
	 */
	public Set<Id> toExecute(EventExecutor__e event) {
		Logger.logInfo(String.format('toExecute( {0} )', new List<Object>{ event }));

		NorlysNowService.Parameters params = norlysNowService.getParameters(event.Parameters__c);
		Set<Id> recordIds = params.recordIds;
		Map<Id, FeedItem> feedItemMap = new Map<Id, FeedItem>();

		try {
			// Retrieve the FeedItem records from the database
			feedItemMap = norlysNowSelector.getFeedItemMap(params.recordIds);
		} catch (QueryException ex) {
			// Log and throw an exception if there's an error querying the FeedItem
			Logger.logError('SOQL Error querying FeedItem records: ' + ex.getMessage());
			throw new NorlysNowFeedItemStrategyException('SQOL Error finding FeedItem: ' + ex.getMessage());
		}

		List<NorlysNow_Case__c> norlysNowCasesToUpdate = new List<NorlysNow_Case__c>();
		List<NorlysNow_Case__c> norlysNowCasesToNotify = new List<NorlysNow_Case__c>();

		for (Id feedItemId : feedItemMap.keySet()) {
			FeedItem fi = feedItemMap.get(feedItemId);
			// We don't need the full NorlysNow_Case__c record, just a reference to its Id for the update.
			NorlysNow_Case__c norlysNowCase = new NorlysNow_Case__c(Id = fi.ParentId);
			// Strip HTML tags from the comment body to get plain text for the API.
			String plainComment = fi.Body.replaceAll('<[^>]+>', '');

			// Create the request object for the API call.
			NorlysNowClientRequestDTO requestObject = norlysNowService.createCaseCommentRequestObject(
				norlysNowCase.Id,
				'insert',
				norlysNowCase.Id,
				'Salesforce Inbound – Incident',
				'synchronous',
				'Salesforce',
				norlysNowCase.Id,
				plainComment
			);

			try {
				norlysNowClient.sentRequestNorlysNowCase(requestObject);
				norlysNowCasesToUpdate.add(norlysNowService.setSuccessOnNorlysNowCase(norlysNowCase));
				// Success → remove id from retry set
				recordIds.remove(feedItemId);
			} catch (HTTPException ex) {
				// Handle HTTP exceptions
				switch on ex.getStatusCode() {
					when 500 {
						// A 500 error indicates a server-side issue, so we should retry the event later.
						Logger.logError(
							'HTTP 500 error for FeedItem Id: ' + feedItemId + '. The event will be retried. Error: ' + ex.getMessage()
						);
					}
					when else {
						// For other HTTP errors, we log the error, mark the case as failed, and do not retry.
						Logger.logError('HTTPException for FeedItem Id: ' + feedItemId + '. Error: ' + ex.getMessage());
						recordIds.remove(feedItemId);
						norlysNowCasesToUpdate.add(norlysNowService.setErrorOnNorlysNowCase(norlysNowCase, ex.getMessage()));
						norlysNowCasesToNotify.add(norlysNowCase);
					}
				}
			} catch (System.CalloutException ex) {
				// Handle callout exceptions (e.g., connection issues). Mark as failed and do not retry.
				Logger.logError('CalloutException for FeedItem Id: ' + feedItemId + '. Error: ' + ex.getMessage());
				recordIds.remove(feedItemId);
				norlysNowCasesToUpdate.add(norlysNowService.setErrorOnNorlysNowCase(norlysNowCase, ex.getMessage()));
				norlysNowCasesToNotify.add(norlysNowCase);
			}
		}

		// Update the related NorlysNow_Case__c records in the database
		try {
			if (!norlysNowCasesToUpdate.isEmpty()) {
				databaseService.updateRecords(norlysNowCasesToUpdate);
			}
		} catch (DmlException ex) {
			Logger.logError('DML error updating NorlysNow_Case__c records from FeedItemStrategy: ' + ex.getMessage());
			throw new NorlysNowFeedItemStrategyException(
				'Error when updating NorlysNow_Case__c from FeedItemStrategy: ' + ex.getMessage()
			);
		}

		// If any items failed permanently, create follow-up tasks for manual intervention.
		if (!norlysNowCasesToNotify.isEmpty()) {
			norlysNowService.createFollowUpTasks(
				norlysNowCasesToNotify,
				'NorlysNow Case Comment/Post not delivered to NorlysNow',
				'Please create a new Post to the NorlysNow case to resend the comment to NorlysNow',
				Date.today()
			);
		}

		return recordIds;
	}

	/**
	 * @description Custom exception for the NorlysNowFeedItemStrategy class.
	 */
	public class NorlysNowFeedItemStrategyException extends Exception {
	}
}
