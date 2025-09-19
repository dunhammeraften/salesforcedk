/**
 * @description This class implements the integration strategy for ContentDocumentLink records.
 *              It handles the logic for sending new files attached to NorlysNow_Case__c records
 *              to the Norlys Now system.
 * @see INorlysNowIntegrationStrategy
 *
 * -----------------------------------------------------------------------------
 * @author Developer           Date            Description
 * -----------------------------------------------------------------------------
 * @author Esben Hovgaard        18/09/2025      Class, method, inline documentation and logging
 * -----------------------------------------------------------------------------
 */
public with sharing class NorlysNowContentDocumentLinkStrategy implements INorlysNowIntegrationStrategy {
	private final NorlysNowService norlysNowService;
	private final NorlysNowSelector norlysNowSelector;
	private final DatabaseService databaseService;
	private final NorlysNowClient norlysNowClient;

	/**
	 * @description Default constructor that initializes the required services using the SingletonFactory.
	 */
	public NorlysNowContentDocumentLinkStrategy() {
		this(SingletonFactory.getFactory());
	}

	/**
	 * @description Private constructor for dependency injection.
	 * @param singletonFactory The SingletonFactory instance to use for creating dependencies.
	 */
	private NorlysNowContentDocumentLinkStrategy(
		SingletonFactory singletonFactory
	) {
		this.norlysNowService = (NorlysNowService) singletonFactory.getOrRegisterSingleton(
			NorlysNowService.class
		);
		this.norlysNowSelector = (NorlysNowSelector) singletonFactory.getOrRegisterSingleton(
			NorlysNowSelector.class
		);
		this.norlysNowClient = (NorlysNowClient) singletonFactory.getOrRegisterSingleton(
			NorlysNowClient.class
		);
		this.databaseService = (DatabaseService) singletonFactory.getOrRegisterSingleton(
			DatabaseService.class
		);
	}

	/**
	 * @description Test-visible constructor for dependency injection during testing.
	 */
	@TestVisible
	private NorlysNowContentDocumentLinkStrategy(
		NorlysNowService norlysNowService,
		NorlysNowSelector norlysNowSelector,
		NorlysNowClient norlysNowClient,
		DatabaseService databaseService
	) {
		this.norlysNowService = norlysNowService;
		this.norlysNowSelector = norlysNowSelector;
		this.norlysNowClient = norlysNowClient;
		this.databaseService = databaseService;
	}

	/**
	 * @description Executes the logic to send file attachments to the Norlys Now system.
	 *              It iterates through the records from the event, calls the Norlys Now client,
	 *              and handles success, error, and retry scenarios.
	 * @param event The platform event containing the ContentDocument Ids to process.
	 * @return A set of ContentDocument Ids that failed and need to be retried.
	 */
	public Set<Id> toExecute(EventExecutor__e event) {
		Logger.logInfo(
			String.format('toExecute( {0} )', new List<Object>{ event })
		);

		norlysNowService.Parameters params = norlysNowService.getParameters(
			event.Parameters__c
		);
		Set<Id> recordIds = params.recordIds;

		// Create a map of ContentDocumentId to the LinkedEntityId (the NorlysNow_Case__c Id).
		Map<Id, Id> fileToCaseMap = new Map<Id, Id>();
		for (
			ContentDocumentLink cdl : norlysNowSelector.getContentDocumentLinks(
				recordIds
			)
		) {
			fileToCaseMap.put(cdl.ContentDocumentId, cdl.LinkedEntityId);
		}

		// Get the latest version of the content files.
		Map<Id, ContentVersion> fileIdToVersion = norlysNowService.getFileIdToVersion(
			recordIds
		);

		// This check is a safeguard. A ContentDocumentLink should always have a corresponding ContentVersion.
		if (fileIdToVersion.isEmpty()) {
			Logger.logError(
				'No ContentVersions found for ContentDocumentIds: ' + recordIds
			);
			return new Set<Id>();
		}

		List<NorlysNow_Case__c> norlysNowCasesToUpdate = new List<NorlysNow_Case__c>();
		List<NorlysNow_Case__c> norlysNowCasesToNotify = new List<NorlysNow_Case__c>();

		for (Id fileId : fileIdToVersion.keySet()) {
			ContentVersion cv = fileIdToVersion.get(fileId);
			Id caseId = fileToCaseMap.get(fileId);

			// We don't need the full NorlysNow_Case__c record, just a reference to its Id for the update.
			NorlysNow_Case__c norlysNowCase = new NorlysNow_Case__c(Id = caseId);

			// Convert the file data to a Base64 encoded string for the API payload.
			String base64Data = EncodingUtil.base64Encode(cv.VersionData);

			// Build the request object for the API call.
			NorlysNowClientRequestDTO requestObject = norlysNowService.createFileRequestObject(
				norlysNowCase.Id,
				'insert',
				norlysNowCase.Id,
				'Salesforce Inbound – Attachment',
				'synchronous',
				'Salesforce',
				norlysNowCase.Id,
				base64Data,
				cv.PathOnClient
			);

			try {
				norlysNowClient.sentRequestNorlysNowCase(requestObject);

				norlysNowCasesToUpdate.add(
					norlysNowService.setSuccessOnNorlysNowCase(norlysNowCase)
				);

				// Success → remove id from retry set
				recordIds.remove(fileId);
			} catch (HTTPException ex) {
				// Handle HTTP exceptions
				switch on ex.getStatusCode() {
					when 500 {
						// A 500 error indicates a server-side issue, so we should retry the event later.
						Logger.logError(
							'HTTP 500 error for ContentDocumentId: ' +
								fileId +
								'. The event will be retried. Error: ' +
								ex.getMessage()
						);
					}
					when else {
						// For other HTTP errors, we log the error, mark the case as failed, and do not retry.
						Logger.logError(
							'HTTPException for ContentDocumentId ' +
								fileId +
								': ' +
								ex.getMessage()
						);
						recordIds.remove(fileId);
						norlysNowCasesToUpdate.add(
							norlysNowService.setErrorOnNorlysNowCase(
								norlysNowCase,
								ex.getMessage()
							)
						);
						norlysNowCasesToNotify.add(norlysNowCase);
					}
				}
			} catch (System.CalloutException ex) {
				// Handle callout exceptions (e.g., connection issues). Mark as failed and do not retry.
				Logger.logError(
					'CalloutException for ContentDocumentId ' +
						fileId +
						': ' +
						ex.getMessage()
				);
				recordIds.remove(fileId);
				norlysNowCasesToUpdate.add(
					norlysNowService.setErrorOnNorlysNowCase(
						norlysNowCase,
						ex.getMessage()
					)
				);
				norlysNowCasesToNotify.add(norlysNowCase);
			}
		}

		// Update the related NorlysNow_Case__c records in the database.
		try {
			if (!norlysNowCasesToUpdate.isEmpty()) {
				databaseService.updateRecords(norlysNowCasesToUpdate);
			}
		} catch (DmlException ex) {
			Logger.logError(
				'DML error updating NorlysNow_Case__c records from ContentDocumentLinkStrategy: ' +
				ex.getMessage()
			);
			throw new NorlysNowContentDocumentLinkStrategyException(
				'Error when updating NorlysNow_Case__c from ContentDocumentLinkStrategy: ' +
				ex.getMessage()
			);
		}

		// If any files failed to send permanently, create follow-up tasks for manual intervention.
		if (!norlysNowCasesToNotify.isEmpty()) {
			norlysNowService.createFollowUpTasks(
				norlysNowCasesToNotify,
				'NorlysNow Case file or attachment not delivered to NorlysNow',
				'Please remove and attached the file and reattach it to send it again',
				Date.today()
			);
		}

		return recordIds; // to be retried
	}

	/**
	 * @description Custom exception for the NorlysNowContentDocumentLinkStrategy class.
	 */
	public class NorlysNowContentDocumentLinkStrategyException extends Exception {
	}
}
