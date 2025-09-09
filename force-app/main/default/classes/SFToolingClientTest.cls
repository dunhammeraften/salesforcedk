@IsTest(IsParallel=true)
public with sharing class SFToolingClientTest {
	@IsTest
	static void query_WithResponseCode200_yieldsToolingQueryResult() {
		//Arrange
		String responsBody = '{\"size\":1,\"totalSize\":1,\"done\":true,\"queryLocator\":null,\"entityTypeName\":\"PlatformEventSubscriberConfig\",\"records\":[{\"attributes\":{\"type\":\"PlatformEventSubscriberConfig\",\"url\":\"/services/data/v63.0/tooling/sobjects/PlatformEventSubscriberConfig/3JKRR000001I7Gz4AK\"},\"Id\":\"3JKRR000001I7Gz4AK\"}]}';
		HttpResponseMock mock = new HttpResponseMock(200, 'OK', responsBody, new Map<String, String>());
		Test.setMock(HttpCalloutMock.class, mock);

		String query = 'SELECT Id FROM PlatformEventSubscriberConfig WHERE DeveloperName =  \'EventExecutorTriggerConfig\'';

		//Act
		Test.startTest();
		SFToolingClient toolingClient = new SFToolingClient();
		SFToolingClientResponseDTO.ToolingQuery result = toolingClient.query(query);
		Test.stopTest();

		//Assert
		Assert.areEqual('3JKRR000001I7Gz4AK', result.records.get(0).Id, 'The Id returned should be parsed');
	}

	@IsTest
	static void query_WithResponseCode404_throwsException() {
		//Arrange
		String responsBody = '{\"size\":1,\"totalSize\":1,\"done\":true,\"queryLocator\":null,\"entityTypeName\":\"PlatformEventSubscriberConfig\",\"records\":[{\"attributes\":{\"type\":\"PlatformEventSubscriberConfig\",\"url\":\"/services/data/v63.0/tooling/sobjects/PlatformEventSubscriberConfig/3JKRR000001I7Gz4AK\"},\"Id\":\"3JKRR000001I7Gz4AK\"}]}';
		HttpResponseMock mock = new HttpResponseMock(404, 'OK', responsBody, new Map<String, String>());
		Test.setMock(HttpCalloutMock.class, mock);

		String query = 'SELECT Id FROM PlatformEventSubscriberConfig WHERE DeveloperName =  \'EventExecutorTriggerConfig\'';

		Exception apiException = null;

		//Act
		Test.startTest();
		SFToolingClient SFToolingClient = new SFToolingClient();
		try {
			SFToolingClientResponseDTO.ToolingQuery result = SFToolingClient.query(query);
		} catch (Exception ex) {
			apiException = ex;
		}
		Test.stopTest();

		//Assert
		Assert.isNotNull(apiException);
		Assert.isTrue(apiException.getMessage().contains('404'), 'The message contains the response code');
	}

	@IsTest
	static void deleteSobjectById_WithResponseCode204_isNotThrowingException() {
		//Arrange
		HttpResponseMock mock = new HttpResponseMock(204, 'OK', 'OK', new Map<String, String>());
		Test.setMock(HttpCalloutMock.class, mock);

		Exception apiException = null;

		//Act
		Test.startTest();
		SFToolingClient toolingClient = new SFToolingClient();
		try {
			toolingClient.deleteSobjectById('PlatformEventSubscriberConfig', '3JKRR000001I7Gz4AK');
		} catch (Exception ex) {
			apiException = ex;
		}
		Test.stopTest();

		//Assert
		Assert.isNull(apiException);
	}

	@IsTest
	static void deleteSobjectById_WithResponseCode404_throwsException() {
		//Arrange
		HttpResponseMock mock = new HttpResponseMock(404, 'OK', 'OK', new Map<String, String>());
		Test.setMock(HttpCalloutMock.class, mock);

		Exception apiException = null;

		//Act
		Test.startTest();
		SFToolingClient toolingClient = new SFToolingClient();
		try {
			toolingClient.deleteSobjectById('PlatformEventSubscriberConfig', '3JKRR000001I7Gz4AK');
		} catch (Exception ex) {
			apiException = ex;
		}
		Test.stopTest();

		//Assert
		Assert.isNotNull(apiException);
	}

	@IsTest
	static void createPlatformEventSubscriberConfig_WithResponseCode404_throwsException() {
		//Arrange
		HttpResponseMock mock = new HttpResponseMock(404, 'OK', 'OK', new Map<String, String>());
		Test.setMock(HttpCalloutMock.class, mock);

		SFToolingClientRequestDTO.Record platformEventConfig = new SFToolingClientRequestDTO.Record();
		platformEventConfig.UserId = UserInfo.getUserId(); //SELECT STATEMENT ON USER THAT IS INTEGRATION_USER
		platformEventConfig.MasterLabel = 'EventExecutorTriggerConfig';
		platformEventConfig.DeveloperName = 'EventExecutorTriggerConfig';
		platformEventConfig.BatchSize = 45;
		platformEventConfig.PlatformEventConsumerId = '01qRR0000050WYAYA2'; //[SELECT Id from ApexTrigger where name = 'EventExecutorTrigger' LIMIT 1].Id;

		Exception apiException = null;

		//Act
		Test.startTest();
		SFToolingClient toolingClient = new SFToolingClient();
		try {
			toolingClient.createPlatformEventSubscriberConfig(platformEventConfig);
		} catch (Exception ex) {
			apiException = ex;
		}
		Test.stopTest();

		//Assert
		Assert.isNotNull(apiException);
	}

	@IsTest
	static void createPlatformEventSubscriberConfig_WithResponseCode201_doNotthrowException() {
		//Arrange
		HttpResponseMock mock = new HttpResponseMock(201, 'OK', 'OK', new Map<String, String>());
		Test.setMock(HttpCalloutMock.class, mock);

		SFToolingClientRequestDTO.Record platformEventConfig = new SFToolingClientRequestDTO.Record();
		platformEventConfig.UserId = UserInfo.getUserId(); //SELECT STATEMENT ON USER THAT IS INTEGRATION_USER
		platformEventConfig.MasterLabel = 'EventExecutorTriggerConfig';
		platformEventConfig.DeveloperName = 'EventExecutorTriggerConfig';
		platformEventConfig.BatchSize = 45;
		platformEventConfig.PlatformEventConsumerId = '01qRR0000050WYAYA2'; //[SELECT Id from ApexTrigger where name = 'EventExecutorTrigger' LIMIT 1].Id;

		Exception apiException = null;

		//Act
		Test.startTest();
		SFToolingClient toolingClient = new SFToolingClient();
		try {
			toolingClient.createPlatformEventSubscriberConfig(platformEventConfig);
		} catch (Exception ex) {
			apiException = ex;
		}
		Test.stopTest();

		//Assert
		Assert.isNull(apiException);
	}
}