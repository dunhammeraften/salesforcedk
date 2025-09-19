/**
 * @description Test class for NorlysNowClientTest.
 *              This class verifies that the client sends requests and returns responses correctly.
 * -----------------------------------------------------------------------------
 * @author Developer           Date            Description
 * -----------------------------------------------------------------------------
 * @author Esben Hovgaard        18/09/2025      Initial version.
 * -----------------------------------------------------------------------------
 */
@isTest
private class NorlysNowClientTest {
	@isTest
	static void sentRequestNorlysNowCase_Success() {
		// Arrange
		NorlysTestScenarios.ScenarioResult scenario = NorlysTestScenarios.newBuilder()
			.forNorlysNowCaseHandling()
			.withNorlysNowCases(1)
			.build();

		Test.setMock(HttpCalloutMock.class, new HttpResponseMock(200, 'OK', '{"success": true}'));

		NorlysNowClient client = new NorlysNowClient();
		NorlysNowClientRequestDTO requestObject = new NorlysNowClientRequestDTO();
		requestObject.integrationmode = 'test';
		requestObject.integrationPartner = 'Salesforce';
		requestObject.correlation_id = '12345';
		requestObject.external_action = 'create';
		requestObject.external_reference = scenario.norlysNowCases[0].Id;
		requestObject.message_type = 'case';

		requestObject.payload = new NorlysNowClientRequestDTO.Payload();
		requestObject.payload.title = 'Test Title';
		requestObject.payload.description = 'Test Description';
		requestObject.payload.priority = 'High';
		requestObject.payload.status = 'New';
		requestObject.payload.requestSource = 'Internal';
		requestObject.payload.category = 'Test Category';
		requestObject.payload.technologyType = 'Test Tech Type';
		requestObject.payload.technology = 'Test Tech';
		requestObject.payload.salesforceId = scenario.norlysNowCases[0].Id;
		requestObject.payload.type = 'Test Type';

		// Act
		Test.startTest();
		HttpResponse response = client.sentRequestNorlysNowCase(requestObject);
		Test.stopTest();

		// Assert
		System.assertNotEquals(null, response, 'Response should not be null');
		System.assertEquals(200, response.getStatusCode(), 'Status code should be 200');
	}

	@isTest
	static void sentRequestNorlysNowCase_Error() {
		// Arrange
		NorlysTestScenarios.ScenarioResult scenario = NorlysTestScenarios.newBuilder()
			.forNorlysNowCaseHandling()
			.withNorlysNowCases(1)
			.build();

		Test.setMock(
			HttpCalloutMock.class,
			new HttpResponseMock(500, 'Server Error', '{"error": "Internal Server Error"}')
		);

		NorlysNowClient client = new NorlysNowClient();
		NorlysNowClientRequestDTO requestObject = new NorlysNowClientRequestDTO();
		requestObject.integrationmode = 'test';
		requestObject.integrationPartner = 'Salesforce';
		requestObject.correlation_id = '12345';
		requestObject.external_action = 'create';
		requestObject.external_reference = scenario.norlysNowCases[0].Id;
		requestObject.message_type = 'case';

		requestObject.payload = new NorlysNowClientRequestDTO.Payload();
		requestObject.payload.title = 'Test Title';
		requestObject.payload.description = 'Test Description';
		requestObject.payload.priority = 'High';
		requestObject.payload.status = 'New';
		requestObject.payload.requestSource = 'Internal';
		requestObject.payload.category = 'Test Category';
		requestObject.payload.technologyType = 'Test Tech Type';
		requestObject.payload.technology = 'Test Tech';
		requestObject.payload.salesforceId = scenario.norlysNowCases[0].Id;
		requestObject.payload.type = 'Test Type';

		// Act
		Test.startTest();
		HTTPException thrownException = null;
		try {
			client.sentRequestNorlysNowCase(requestObject);
		} catch (HTTPException e) {
			thrownException = e;
		}
		Test.stopTest();

		// Assert
		System.assertNotEquals(null, thrownException, 'An HTTPException should have been thrown');
		System.assertEquals(
			'{"error": "Internal Server Error"}',
			thrownException.getMessage(),
			'The exception message should be the response body.'
		);
	}
}
