/**
 * @description This class implements the integration strategy for NorlysNow_Case__c records.
 *              It handles the logic for sending case data to the Norlys Now system via an API client.
 * @see INorlysNowIntegrationStrategy
 *
 * -----------------------------------------------------------------------------
 * @author Developer           Date            Description
 * -----------------------------------------------------------------------------
 * @author Esben Hovgaard        18/09/2025      Class, method, inline documentation and logging
 * -----------------------------------------------------------------------------
 */
public with sharing class NorlysNowCaseStrategy implements INorlysNowIntegrationStrategy {
	private final NorlysNowService norlysNowService;
	private final NorlysNowSelector norlysNowSelector;
	private final DatabaseService databaseService;
	private final NorlysNowClient norlysNowClient;

	/**
	 * @description Default constructor that initializes the required services using the SingletonFactory.
	 */
	public NorlysNowCaseStrategy() {
		this(SingletonFactory.getFactory());
	}

	/**
	 * @description Private constructor for dependency injection.
	 * @param singletonFactory The SingletonFactory instance to use for creating dependencies.
	 */
	private NorlysNowCaseStrategy(SingletonFactory singletonFactory) {
		this.norlysNowService = (NorlysNowService) singletonFactory.getOrRegisterSingleton(NorlysNowService.class);
		this.norlysNowSelector = (NorlysNowSelector) singletonFactory.getOrRegisterSingleton(NorlysNowSelector.class);
		this.norlysNowClient = (NorlysNowClient) singletonFactory.getOrRegisterSingleton(NorlysNowClient.class);
		this.databaseService = (DatabaseService) singletonFactory.getOrRegisterSingleton(DatabaseService.class);
	}

	/**
	 * @description Executes the logic to send NorlysNow_Case__c records to the Norlys Now system.
	 *              It iterates through the records from the event, calls the Norlys Now client,
	 *              and handles success, error, and retry scenarios.
	 * @param event The platform event containing the record Ids to process.
	 * @return A set of record Ids that failed and need to be retried.
	 */
	public Set<Id> toExecute(EventExecutor__e event) {
		Logger.logInfo(String.format('execute( {0} )', new List<Object>{ event }));

		NorlysNowService.Parameters params = norlysNowService.getParameters(event.Parameters__c);
		Set<Id> recordIds = params.recordIds;
		Map<Id, NorlysNow_Case__c> norlysNowCasesMap = norlysNowSelector.getNorlysNowCasesMap(recordIds);
		Map<Id, NorlysNow_Case__c> toUpdateNorlysNowCasesMap = new Map<Id, NorlysNow_Case__c>();
		List<NorlysNow_Case__c> processedCases = new List<NorlysNow_Case__c>();

		for (Id norlysNowCaseId : norlysNowCasesMap.keySet()) {
			NorlysNow_Case__c norlysNowCase = norlysNowCasesMap.get(norlysNowCaseId);

			// Create the request object for the API call.
			NorlysNowClientRequestDTO requestObject = norlysNowService.createCaseRequestObject(
				norlysNowCase.Id,
				'insert',
				norlysNowCase.Id,
				'Salesforce Inbound – Incident',
				'synchronous',
				'Salesforce',
				norlysNowCase.Id,
				null,
				norlysNowCase.Priority__c,
				norlysNowCase.Description__c,
				norlysNowCase.Title__c + ' - B2B',
				norlysNowCase.Type__c,
				norlysNowCase.Status__c,
				norlysNowCase.Request_Source__c,
				norlysNowCase.Category__c,
				norlysNowCase.Technology_Type__c,
				norlysNowCase.Technology__c,
				norlysNowCase.OneWorkFlow_Id__c,
				norlysNowCase.CreatedBy.Name
			);

			try {
				// Call the norlysNowClient to create or update the case in NorlysNow
				HttpResponse httpResponse = norlysNowClient.sentRequestNorlysNowCase(requestObject);
				Map<String, Object> raw = (Map<String, Object>) JSON.deserializeUntyped(httpResponse.getBody());
				Map<String, Object> result = (Map<String, Object>) raw.get('result');

				// If the case is new, capture the NorlysNow ID from the response.
				if (norlysNowCase.Status__c == 'New') {
					if (result.get('created record number') != null) {
						norlysNowCase.NorlysNow_Id__c = (String) result.get('created record number');
					} else {
						Logger.logError('No NorlysNow record number found for NorlysNow_Case__c Id: ' + norlysNowCase.Id);
					}
				}

				toUpdateNorlysNowCasesMap.put(norlysNowCase.Id, norlysNowService.setSuccessOnNorlysNowCase(norlysNowCase));
				processedCases.add(norlysNowCase);
				// Remove the successfully processed record from the list of Ids to retry.
				recordIds.remove(norlysNowCaseId);
			} catch (HTTPException ex) {
				// Handle HTTP exceptions
				switch on ex.getStatusCode() {
					when 500 {
						// A 500 error indicates a server-side issue, so we should retry the event later.
						Logger.logError(
							'HTTP 500 error for NorlysNow_Case__c Id: ' +
								norlysNowCase.Id +
								'. The event will be retried. Error: ' +
								ex.getMessage()
						);
					}
					when else {
						// For other HTTP errors, we log the error, mark the case as failed, and do not retry.
						Logger.logError(
							'HTTPException for NorlysNow_Case__c Id: ' + norlysNowCase.Id + '. Error: ' + ex.getMessage()
						);
						recordIds.remove(norlysNowCaseId);
						toUpdateNorlysNowCasesMap.put(
							norlysNowCase.Id,
							norlysNowService.setErrorOnNorlysNowCase(norlysNowCase, ex.getMessage())
						);
						processedCases.add(norlysNowCase);
					}
				}
			} catch (System.CalloutException ex) {
				// Handle callout exceptions (e.g., connection issues). Mark as failed and do not retry.
				Logger.logError(
					'CalloutException for NorlysNow_Case__c Id: ' + norlysNowCase.Id + '. Error: ' + ex.getMessage()
				);
				recordIds.remove(norlysNowCaseId);
				toUpdateNorlysNowCasesMap.put(
					norlysNowCase.Id,
					norlysNowService.setErrorOnNorlysNowCase(norlysNowCase, ex.getMessage())
				);
				processedCases.add(norlysNowCase);
			} catch (Exception ex) {
				// Handle callout exceptions (e.g., connection issues). Mark as failed and do not retry.
				Logger.logError('Exception for NorlysNow_Case__c Id: ' + norlysNowCase.Id + '. Error: ' + ex.getMessage());
				recordIds.remove(norlysNowCaseId);
				toUpdateNorlysNowCasesMap.put(
					norlysNowCase.Id,
					norlysNowService.setErrorOnNorlysNowCase(norlysNowCase, ex.getMessage())
				);
				processedCases.add(norlysNowCase);
			}
		}

		// Update the NorlysNowCases in the database
		try {
			if (!toUpdateNorlysNowCasesMap.isEmpty()) {
				databaseService.updateRecords(toUpdateNorlysNowCasesMap.values());
			}
		} catch (DmlException ex) {
			Logger.logError('DML error updating NorlysNow_Case__c records: ' + ex.getMessage());
			throw new NorlysNowCaseStrategyException('Error when updating NorlysNow_Case__c records: ' + ex.getMessage());
		}

		List<NorlysNow_Case__c> successCases = new List<NorlysNow_Case__c>();
		List<NorlysNow_Case__c> errorCases = new List<NorlysNow_Case__c>();

		for (NorlysNow_Case__c processedCase : processedCases) {
			if (processedCase.Sync_Status__c == 'Success') {
				successCases.add(processedCase);
			} else {
				errorCases.add(processedCase);
			}
		}

		if (!successCases.isEmpty()) {
			norlysNowService.sendNotifications(
				successCases,
				'NorlysNow Case delivered to NorlysNow',
				'NorlysNow Case has been successfully synced to NorlysNow'
			);
		}

		if (!errorCases.isEmpty()) {
			norlysNowService.createFollowUpTasks(
				errorCases,
				'NorlysNow Case not delivered to NorlysNow',
				'Please resent the NorlysNow case by setting Sync Status to Pending',
				Date.today()
			);
		}

		return recordIds;
	}

	/**
	 * @description Custom exception for the NorlysNowCaseStrategy class.
	 */
	public class NorlysNowCaseStrategyException extends Exception {
	}
}
