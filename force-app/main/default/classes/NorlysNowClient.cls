public with sharing class NorlysNowClient extends HTTPClient{

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

    public HttpResponse sentRequestNorlysNowCase(NorlysNowClientRequestDTO requestObject ) {
        Logger.logInfo(String.format('sentRequestNorlysNowCase( {0} )', new List<Object>{ requestObject }));

        String endpoint = '/api/x_autps_int_app/integration_app/CreateMessage';
        
        String body = JSON.serialize(requestObject);

        HttpResponse response = post(endpoint, body);

        if (response.getStatusCode() < 300) {
            Logger.logInfo('Create NorlysNow Case: ' + response.getBody());
            return response;
        }else{
            Logger.logError('Failed to create NorlysNow Case: ' + response.getBody());
            throw new HTTPException(response);
        }
        
    }
}