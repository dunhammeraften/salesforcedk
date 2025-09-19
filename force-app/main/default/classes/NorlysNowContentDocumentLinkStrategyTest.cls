/**
 * @description Test class for the NorlysNowContentDocumentLinkStrategy. This class ensures that the strategy
 *              correctly processes ContentDocumentLink records, sends file data to the NorlysNow API,
 *              and handles both success and various error responses.
 * -----------------------------------------------------------------------------
 * @author Developer           Date            Description
 * -----------------------------------------------------------------------------
 * @author Jules               15/09/2025      Initial version.
 * @author Esben Hovgaard        18/09/2025      Added changeLine to documentation
 * -----------------------------------------------------------------------------
 */
@isTest
private class NorlysNowContentDocumentLinkStrategyTest {
	private static Mock norlysNowServiceMock;
	private static Mock norlysNowSelectorMock;
	private static Mock norlysNowClientMock;
	private static DatabaseService databaseServiceStub;

	/**
	 * @description Sets up the test environment by mocking all the necessary service dependencies.
	 *              This is called by each test method to ensure a clean and predictable state.
	 */
	private static void setupMocks() {
		// Create mocks for all service dependencies
		norlysNowServiceMock = Mock.forType(NorlysNowService.class);
		norlysNowSelectorMock = Mock.forType(NorlysNowSelector.class);
		norlysNowClientMock = Mock.forType(NorlysNowClient.class);
		databaseServiceStub = new DatabaseService().mockDmls();

		// Get the stub instances from the mocks
		NorlysNowService norlysNowServiceStub = (NorlysNowService) norlysNowServiceMock.stub;
		NorlysNowSelector norlysNowSelectorStub = (NorlysNowSelector) norlysNowSelectorMock.stub;
		NorlysNowClient norlysNowClientStub = (NorlysNowClient) norlysNowClientMock.stub;

		// Register all the singleton services with our stubs so the handler will use them
		SingletonFactory factory = SingletonFactory.getFactory();
		factory.registerSingleton(NorlysNowService.class, norlysNowServiceStub);
		factory.registerSingleton(NorlysNowSelector.class, norlysNowSelectorStub);
		factory.registerSingleton(NorlysNowClient.class, norlysNowClientStub);
		factory.registerSingleton(DatabaseService.class, databaseServiceStub);
	}

	@isTest
	static void toExecute_OnSuccess_ShouldUpdateCaseAndReturnEmptySet() {
		// Arrange
		setupMocks();
		norlysNowServiceMock.spyOn('createFileRequestObject')
			.returns(new NorlysNowClientRequestDTO());

		NorlysTestScenarios.ScenarioResult scenario = NorlysTestScenarios.newBuilder()
			.forNorlysNowCaseHandling()
			.withNorlysNowCases(1)
			.withAttachedFiles(1)
			.build();

		ContentDocumentLink testCdl = scenario.contentDocumentLinks[0];
		Set<Id> recordIds = new Set<Id>{ testCdl.ContentDocumentId };

		EventExecutor__e testEvent = new EventExecutor__e(
			Parameters__c = '{"recordIds":["' + testCdl.ContentDocumentId + '"]}'
		);

		// --- Mock Service Calls for the main execution path ---
		NorlysNowService.Parameters params = new NorlysNowService.Parameters();
		params.recordIds = recordIds;
		norlysNowServiceMock.spyOn('getParameters')
			.whenCalledWith(testEvent.Parameters__c)
			.thenReturn(params);

		List<ContentDocumentLink> cdlList = new List<ContentDocumentLink>{
			testCdl
		};
		norlysNowSelectorMock.spyOn('getContentDocumentLinks')
			.whenCalledWith(recordIds)
			.thenReturn(cdlList);

		ContentVersion mockCv = new ContentVersion(
			VersionData = Blob.valueOf('test data'),
			PathOnClient = 'test.txt'
		);
		Map<Id, ContentVersion> cvMap = new Map<Id, ContentVersion>{
			testCdl.ContentDocumentId => mockCv
		};
		norlysNowServiceMock.spyOn('getFileIdToVersion')
			.whenCalledWith(recordIds)
			.thenReturn(cvMap);

		norlysNowClientMock.spyOn('sentRequestNorlysNowCase')
			.whenCalledWith(Argument.any())
			.thenReturn(null);

		MethodSpy setSuccessSpy = norlysNowServiceMock.spyOn(
			'setSuccessOnNorlysNowCase'
		);
		setSuccessSpy.whenCalledWith(Argument.any())
			.thenReturn(new NorlysNow_Case__c());

		NorlysNowContentDocumentLinkStrategy strategy = new NorlysNowContentDocumentLinkStrategy();

		// Act
		Test.startTest();
		Set<Id> remainingIds = strategy.toExecute(testEvent);
		Test.stopTest();

		// Assert
		System.assertEquals(
			0,
			remainingIds.size(),
			'The returned set of IDs should be empty on success.'
		);
		System.assertEquals(
			1,
			databaseServiceStub.register.updated.size(),
			'The databaseService.updateRecords method should have been called once.'
		);
		System.assertEquals(
			1,
			setSuccessSpy.callLog.size(),
			'setSuccessOnNorlysNowCase should have been called once.'
		);
	}

	@isTest
	static void toExecute_OnHttpException_ShouldUpdateCaseAndCreateTask() {
		// Arrange
		setupMocks();
		norlysNowServiceMock.spyOn('createFileRequestObject')
			.returns(new NorlysNowClientRequestDTO());

		NorlysTestScenarios.ScenarioResult scenario = NorlysTestScenarios.newBuilder()
			.forNorlysNowCaseHandling()
			.withNorlysNowCases(1)
			.withAttachedFiles(1)
			.build();

		ContentDocumentLink testCdl = scenario.contentDocumentLinks[0];
		NorlysNow_Case__c parentCase = scenario.norlysNowCases[0];
		Set<Id> recordIds = new Set<Id>{ testCdl.ContentDocumentId };

		EventExecutor__e testEvent = new EventExecutor__e(
			Parameters__c = '{"recordIds":["' + testCdl.ContentDocumentId + '"]}'
		);

		// --- Mock Service Calls for the main execution path ---
		NorlysNowService.Parameters params = new NorlysNowService.Parameters();
		params.recordIds = recordIds;
		norlysNowServiceMock.spyOn('getParameters')
			.whenCalledWith(testEvent.Parameters__c)
			.thenReturn(params);

		List<ContentDocumentLink> cdlList = new List<ContentDocumentLink>{
			testCdl
		};
		norlysNowSelectorMock.spyOn('getContentDocumentLinks')
			.whenCalledWith(recordIds)
			.thenReturn(cdlList);

		ContentVersion mockCv = new ContentVersion(
			VersionData = Blob.valueOf('test data'),
			PathOnClient = 'test.txt'
		);
		Map<Id, ContentVersion> cvMap = new Map<Id, ContentVersion>{
			testCdl.ContentDocumentId => mockCv
		};
		norlysNowServiceMock.spyOn('getFileIdToVersion')
			.whenCalledWith(recordIds)
			.thenReturn(cvMap);

		// Use the project's custom HTTPException to simulate a non-500 error
		HTTPException testException = new HTTPException(
			'Not Found',
			404,
			'Not Found'
		);
		norlysNowClientMock.spyOn('sentRequestNorlysNowCase')
			.whenCalledWith(Argument.any())
			.thenThrow(testException);

		norlysNowServiceMock.spyOn('setErrorOnNorlysNowCase')
			.whenCalledWith(Argument.any(), testException.getMessage())
			.thenReturn(parentCase);
		MethodSpy createTasksSpy = norlysNowServiceMock.spyOn(
			'createFollowUpTasks'
		);
		createTasksSpy.whenCalledWith(
				Argument.any(),
				Argument.any(),
				Argument.any(),
				Argument.any()
			)
			.thenReturn(null);

		NorlysNowContentDocumentLinkStrategy strategy = new NorlysNowContentDocumentLinkStrategy();

		// Act
		Test.startTest();
		Set<Id> remainingIds = strategy.toExecute(testEvent);
		Test.stopTest();

		// Assert
		System.assertEquals(
			0,
			remainingIds.size(),
			'The returned set of IDs should be empty on a non-retryable error.'
		);
		System.assertEquals(
			1,
			databaseServiceStub.register.updated.size(),
			'The databaseService.updateRecords method should have been called once.'
		);
		System.assertEquals(
			1,
			createTasksSpy.callLog.size(),
			'The createFollowUpTasks method should have been called once.'
		);
	}

	@isTest
	static void toExecute_OnCalloutException_ShouldUpdateCaseAndCreateTask() {
		// Arrange
		setupMocks();
		norlysNowServiceMock.spyOn('createFileRequestObject')
			.returns(new NorlysNowClientRequestDTO());

		NorlysTestScenarios.ScenarioResult scenario = NorlysTestScenarios.newBuilder()
			.forNorlysNowCaseHandling()
			.withNorlysNowCases(1)
			.withAttachedFiles(1)
			.build();

		ContentDocumentLink testCdl = scenario.contentDocumentLinks[0];
		NorlysNow_Case__c parentCase = scenario.norlysNowCases[0];
		Set<Id> recordIds = new Set<Id>{ testCdl.ContentDocumentId };

		EventExecutor__e testEvent = new EventExecutor__e(
			Parameters__c = '{"recordIds":["' + testCdl.ContentDocumentId + '"]}'
		);

		// --- Mock Service Calls for the main execution path ---
		NorlysNowService.Parameters params = new NorlysNowService.Parameters();
		params.recordIds = recordIds;
		norlysNowServiceMock.spyOn('getParameters')
			.whenCalledWith(testEvent.Parameters__c)
			.thenReturn(params);

		List<ContentDocumentLink> cdlList = new List<ContentDocumentLink>{
			testCdl
		};
		norlysNowSelectorMock.spyOn('getContentDocumentLinks')
			.whenCalledWith(recordIds)
			.thenReturn(cdlList);

		ContentVersion mockCv = new ContentVersion(
			VersionData = Blob.valueOf('test data'),
			PathOnClient = 'test.txt'
		);
		Map<Id, ContentVersion> cvMap = new Map<Id, ContentVersion>{
			testCdl.ContentDocumentId => mockCv
		};
		norlysNowServiceMock.spyOn('getFileIdToVersion')
			.whenCalledWith(recordIds)
			.thenReturn(cvMap);

		System.CalloutException testException = new System.CalloutException(
			'Error'
		);
		norlysNowClientMock.spyOn('sentRequestNorlysNowCase')
			.whenCalledWith(Argument.any())
			.thenThrow(testException);

		norlysNowServiceMock.spyOn('setErrorOnNorlysNowCase')
			.whenCalledWith(Argument.any(), testException.getMessage())
			.thenReturn(parentCase);
		MethodSpy createTasksSpy = norlysNowServiceMock.spyOn(
			'createFollowUpTasks'
		);
		createTasksSpy.whenCalledWith(
				Argument.any(),
				Argument.any(),
				Argument.any(),
				Argument.any()
			)
			.thenReturn(null);

		NorlysNowContentDocumentLinkStrategy strategy = new NorlysNowContentDocumentLinkStrategy();

		// Act
		Test.startTest();
		Set<Id> remainingIds = strategy.toExecute(testEvent);
		Test.stopTest();

		// Assert
		System.assertEquals(
			0,
			remainingIds.size(),
			'The returned set of IDs should be empty on a callout exception.'
		);
		System.assertEquals(
			1,
			databaseServiceStub.register.updated.size(),
			'The databaseService.updateRecords method should have been called once.'
		);
		System.assertEquals(
			1,
			createTasksSpy.callLog.size(),
			'The createFollowUpTasks method should have been called once.'
		);
	}

	@isTest
	static void toExecute_OnHttp500Error_ShouldLogAndRetry() {
		// Arrange
		setupMocks();
		norlysNowServiceMock.spyOn('createFileRequestObject')
			.returns(new NorlysNowClientRequestDTO());

		NorlysTestScenarios.ScenarioResult scenario = NorlysTestScenarios.newBuilder()
			.forNorlysNowCaseHandling()
			.withNorlysNowCases(1)
			.withAttachedFiles(1)
			.build();

		ContentDocumentLink testCdl = scenario.contentDocumentLinks[0];
		Set<Id> recordIds = new Set<Id>{ testCdl.ContentDocumentId };

		EventExecutor__e testEvent = new EventExecutor__e(
			Parameters__c = '{"recordIds":["' + testCdl.ContentDocumentId + '"]}'
		);

		// --- Mock Service Calls for the main execution path ---
		NorlysNowService.Parameters params = new NorlysNowService.Parameters();
		params.recordIds = recordIds;
		norlysNowServiceMock.spyOn('getParameters')
			.whenCalledWith(testEvent.Parameters__c)
			.thenReturn(params);

		List<ContentDocumentLink> cdlList = new List<ContentDocumentLink>{
			testCdl
		};
		norlysNowSelectorMock.spyOn('getContentDocumentLinks')
			.whenCalledWith(recordIds)
			.thenReturn(cdlList);

		ContentVersion mockCv = new ContentVersion(
			VersionData = Blob.valueOf('test data'),
			PathOnClient = 'test.txt'
		);
		Map<Id, ContentVersion> cvMap = new Map<Id, ContentVersion>{
			testCdl.ContentDocumentId => mockCv
		};
		norlysNowServiceMock.spyOn('getFileIdToVersion')
			.whenCalledWith(recordIds)
			.thenReturn(cvMap);

		// Use the project's custom HTTPException to simulate a 500 error
		HTTPException testException = new HTTPException(
			'Internal Server Error',
			500,
			'Server Error'
		);
		norlysNowClientMock.spyOn('sentRequestNorlysNowCase')
			.whenCalledWith(Argument.any())
			.thenThrow(testException);

		MethodSpy setErrorSpy = norlysNowServiceMock.spyOn(
			'setErrorOnNorlysNowCase'
		);
		MethodSpy createTasksSpy = norlysNowServiceMock.spyOn(
			'createFollowUpTasks'
		);

		NorlysNowContentDocumentLinkStrategy strategy = new NorlysNowContentDocumentLinkStrategy();

		// Act
		Test.startTest();
		Set<Id> remainingIds = strategy.toExecute(testEvent);
		Test.stopTest();

		// Assert
		System.assertEquals(
			1,
			remainingIds.size(),
			'The ID should remain in the set for a retryable 500 error.'
		);
		System.assert(
			remainingIds.contains(testCdl.ContentDocumentId),
			'The correct ContentDocumentId should be in the retry set.'
		);
		System.assertEquals(
			0,
			databaseServiceStub.register.updated.size(),
			'DatabaseService should not be called for a 500 error.'
		);
		System.assertEquals(
			0,
			setErrorSpy.callLog.size(),
			'setErrorOnNorlysNowCase should not be called for a 500 error.'
		);
		System.assertEquals(
			0,
			createTasksSpy.callLog.size(),
			'createFollowUpTasks should not be called for a 500 error.'
		);
	}
}
