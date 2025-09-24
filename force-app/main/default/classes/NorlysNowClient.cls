/**
 * The NorlysNowClient class is a client for interacting with the ServiceNow API services.
 * It handles NorlysNow_Case__c operations, like updating/creating NorlysNow_Case__c, FeedItems and Files.
 *
 * -----------------------------------------------------------------------------
 * @author Developer           Date            Description
 * -----------------------------------------------------------------------------
 * @author Esben Hovgaard        18/09/2025      Class and method documentation
 * -----------------------------------------------------------------------------
 */
public with sharing class NorlysNowClient extends HTTPClient {
	/**
	 * Named credential used for authentication with Salesforce APIs
	 */
	private static final String NAMED_CREDENTIAL = 'NorlysNow';

	/**
	 * Constructor that initializes the NorlysNowClient with the named credential
	 */
	public NorlysNowClient() {
		super(NAMED_CREDENTIAL);
	}

	/**
	 * Retrieves detailed information about a specific phone number
	 * @param requestObject The NorlysNowClientRequestDTO object containing the NorlysNow_Case__c details
	 * @return HttpResponse containing the response from the ServiceNow API
	 * @throws HTTPException if the API returns an error status (400, 404, 406, 500)
	 */
	public HttpResponse sentRequestNorlysNowCase(NorlysNowClientRequestDTO requestObject) {
		Logger.logInfo(String.format('sentRequestNorlysNowCase( {0} )', new List<Object>{ requestObject }));

		String endpoint = '/api/x_autps_int_app/integration_app/CreateMessage';
		Logger.logDebug('endpoint: ' + endpoint);

		String body = JSON.serialize(requestObject);

		HttpResponse response = post(endpoint, body);
		Logger.logDebug('response: ' + response);

		if (response.getStatusCode() < 300) {
			Logger.logInfo('Create NorlysNow Case: ' + response.getBody());
			return response;
		} else {
			Logger.logError(
				'NorlysNowClient',
				'Failed to create NorlysNow Case: ' + response.getBody(),
				response.getStatusCode().toString()
			);
			throw new HTTPException(response);
		}
	}
}
