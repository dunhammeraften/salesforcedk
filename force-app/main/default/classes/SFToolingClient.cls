/**
 * A client class for interacting with Salesforce APIs
 *
 * Extends HTTPClient for callouts.
 * - Using NamedCredential 'SF_API'
 */
public with sharing class SFToolingClient extends HTTPClient {
	/**
	 * Named credential used for authentication with Salesforce APIs
	 */
	private static final String NAMED_CREDENTIAL = 'ToolingAPI';

	/**
	 * Base endpoint URL for Tooling API SObject operations
	 *
	 * '/services/data/v63.0/tooling/sobjects/{0}'
	 */
	private static final String ENDPOINT_SOBJECT = OrgUtils.getCompanySettingsConfigurationValueByDeveloperName('endpointSFToolingClientSobjects');

	/**
	 * Base endpoint URL for Tooling API queries
	 *
	 * 'services/data/v63.0/tooling/query/?q='
	 */
	private static final String ENDPOINT_QUERY = OrgUtils.getCompanySettingsConfigurationValueByDeveloperName('endpointSFToolingClientQuery');

	/**
	 * Constructor that initializes the SFClient with the named credential
	 */
	public SFToolingClient() {
		super(NAMED_CREDENTIAL);
	}


	/**
	 * Deletes an SObject record using the Tooling API
	 *
	 * @param sobjectType Type of SObject to delete
	 * @param sobjectId Id of the record to delete
	 * @throws HTTPException If it returns unexpected result
	 */
	public void deleteSobjectById(String sobjectType, Id sobjectId) {
		Logger.logInfo(String.format('deleteSobjectById( {0}, {1} )', new List<Object>{ sobjectType, sobjectId }));
		
		String endpoint = String.format(ENDPOINT_SOBJECT, new List<Object>{ sobjectType });
		endpoint += '/' + sobjectId;
		
		HttpResponse response = del(endpoint);
		
		switch on response.getStatusCode() {
			when 204 {
				Logger.logInfo('Deleted: ' + sobjectId);
			}
			when else {
				throw new HTTPException('Unexpected Response code: ' + response.getStatusCode());
			}
		}
	}

	/**
	 * Executes a SOQL query against the Tooling API
	 *
	 * @param query The SOQL query string to execute
	 * @return Results of the query as a ToolingQueryResult object
	 * @throws HTTPException If it returns unexpected result
	 */
	public SFToolingClientResponseDTO.ToolingQuery query(String query) {
		Logger.logInfo(String.format('query( {0} )', new List<Object>{ query }));
		
		HttpResponse response = get(ENDPOINT_QUERY, query);
		
		switch on response.getStatusCode() {
			when 200 {
				return parseQueryResult(response.getBody());
			}
			when else {
				throw new HTTPException('Unexpected Response code: ' + response.getStatusCode());
			}
		}
	}

	/**
	 * Creates a Platform Event Subscriber Configuration record
	 *
	 * @param platformEventSubscriberConfig Record containing configuration settings
	 * @throws HTTPException If it returns unexpected result
	 */
	public void createPlatformEventSubscriberConfig(SFToolingClientRequestDTO.Record platformEventSubscriberConfig) {
		Logger.logInfo(
			String.format(
				'createPlatformEventSubscriberConfig( {0} )',
				new List<Object>{ platformEventSubscriberConfig }
			)
		);

		String endpoint = String.format(ENDPOINT_SOBJECT, new List<Object>{ 'PlatformEventSubscriberConfig' });
		String body = JSON.serialize(platformEventSubscriberConfig);
		
		HttpResponse response = post(endpoint, body);
		
		switch on response.getStatusCode() {
			when 201 {
				Logger.logInfo('Created: ' + response.getBody());
			}
			when else {
				throw new HTTPException('Unexpected Response code: ' + response.getStatusCode());
			}
		}
	}

	/**
	 * Parses JSON response from Tooling API queries into a structured format
	 *
	 * @param json The JSON string to parse
	 * @return Parsed ToolingQuery object
	 */
	private SFToolingClientResponseDTO.ToolingQuery parseQueryResult(String json) {
		return (SFToolingClientResponseDTO.ToolingQuery) System.JSON.deserialize(json, SFToolingClientResponseDTO.ToolingQuery.class);
	}
}