/**
 * @description Test class for NorlysNowFeedItemStrategy.
 *              This class ensures that the strategy correctly processes FeedItem records,
 *              sends them as comments to the NorlysNow API, and handles both
 *              success and error responses gracefully.
 * -----------------------------------------------------------------------------
 * Developer            Date            Description
 * -----------------------------------------------------------------------------
 * Jules                2025-09-15      Initial version.
 */
@isTest
private class NorlysNowFeedItemStrategyTest {
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
        // Default mock for triggers
        norlysNowServiceMock.spyOn('createCaseCommentRequestObject').returns(new NorlysNowClientRequestDTO());

        NorlysTestScenarios.ScenarioResult scenario = NorlysTestScenarios.newBuilder()
            .forNorlysNowCaseHandling()
            .withNorlysNowCases(1)
            .withFeedItems(1)
            .build();
        
        FeedItem testFeedItem = scenario.feedItems[0];
        Set<Id> recordIds = new Set<Id>{ testFeedItem.Id };

        EventExecutor__e testEvent = new EventExecutor__e(
            Parameters__c = '{"recordIds":["' + testFeedItem.Id + '"]}'
        );

        // --- Mock Service Calls for the main execution path ---
        NorlysNowService.Parameters params = new NorlysNowService.Parameters();
        params.recordIds = recordIds;
        norlysNowServiceMock.spyOn('getParameters').whenCalledWith(testEvent.Parameters__c).thenReturn(params);

        Map<Id, FeedItem> feedItemMap = new Map<Id, FeedItem>{ testFeedItem.Id => testFeedItem };
        norlysNowSelectorMock.spyOn('getFeedItemMap').whenCalledWith(recordIds).thenReturn(feedItemMap);

        norlysNowClientMock.spyOn('sentRequestNorlysNowCase').whenCalledWith(Argument.any()).thenReturn(null);

        MethodSpy setSuccessSpy = norlysNowServiceMock.spyOn('setSuccessOnNorlysNowCase');
        setSuccessSpy.whenCalledWith(Argument.any()).thenReturn(new NorlysNow_Case__c());

        NorlysNowFeedItemStrategy strategy = new NorlysNowFeedItemStrategy();

        // Act
        Test.startTest();
        Set<Id> remainingIds = strategy.toExecute(testEvent);
        Test.stopTest();

        // Assert
        System.assertEquals(0, remainingIds.size(), 'The returned set of IDs should be empty on success.');
        System.assertEquals(1, databaseServiceStub.register.updated.size(), 'The databaseService.updateRecords method should have been called once.');
        System.assertEquals(1, setSuccessSpy.callLog.size(), 'setSuccessOnNorlysNowCase should have been called once.');
    }

    @isTest
    static void toExecute_OnHttpException_ShouldUpdateCaseAndCreateTask() {
        // Arrange
        setupMocks();
        // Default mock for triggers
        norlysNowServiceMock.spyOn('createCaseCommentRequestObject').returns(new NorlysNowClientRequestDTO());

        NorlysTestScenarios.ScenarioResult scenario = NorlysTestScenarios.newBuilder()
            .forNorlysNowCaseHandling()
            .withNorlysNowCases(1)
            .withFeedItems(1)
            .build();
        
        FeedItem testFeedItem = scenario.feedItems[0];
        Set<Id> recordIds = new Set<Id>{ testFeedItem.Id };
        NorlysNow_Case__c parentCase = scenario.norlysNowCases[0];

        EventExecutor__e testEvent = new EventExecutor__e(
            Parameters__c = '{"recordIds":["' + testFeedItem.Id + '"]}'
        );

        // --- Mock Service Calls for the main execution path ---
        NorlysNowService.Parameters params = new NorlysNowService.Parameters();
        params.recordIds = recordIds;
        norlysNowServiceMock.spyOn('getParameters').whenCalledWith(testEvent.Parameters__c).thenReturn(params);

        Map<Id, FeedItem> feedItemMap = new Map<Id, FeedItem>{ testFeedItem.Id => testFeedItem };
        norlysNowSelectorMock.spyOn('getFeedItemMap').whenCalledWith(recordIds).thenReturn(feedItemMap);

        HttpResponse errorResponse = new HttpResponse();
        errorResponse.setStatusCode(404);
        errorResponse.setBody('{"error":"Not Found"}');
        HTTPException testException = new HTTPException(errorResponse);
        norlysNowClientMock.spyOn('sentRequestNorlysNowCase').whenCalledWith(Argument.any()).thenThrow(testException);
        
        norlysNowServiceMock.spyOn('setErrorOnNorlysNowCase').whenCalledWith(Argument.any(), testException.getMessage()).thenReturn(parentCase);
        MethodSpy createTasksSpy = norlysNowServiceMock.spyOn('createFollowUpTasks');
        createTasksSpy.whenCalledWith(Argument.any(), Argument.any(), Argument.any(), Argument.any()).thenReturn(null);

        NorlysNowFeedItemStrategy strategy = new NorlysNowFeedItemStrategy();

        // Act
        Test.startTest();
        Set<Id> remainingIds = strategy.toExecute(testEvent);
        Test.stopTest();

        // Assert
        System.assertEquals(0, remainingIds.size(), 'The returned set of IDs should be empty on a non-retryable error.');
        System.assertEquals(1, databaseServiceStub.register.updated.size(), 'The databaseService.updateRecords method should have been called once.');
        System.assertEquals(1, createTasksSpy.callLog.size(), 'The createFollowUpTasks method should have been called once.');
    }

    @isTest
    static void toExecute_OnCalloutException_ShouldUpdateCaseAndCreateTask() {
        // Arrange
        setupMocks();
        // Default mock for triggers
        norlysNowServiceMock.spyOn('createCaseCommentRequestObject').returns(new NorlysNowClientRequestDTO());
        
        NorlysTestScenarios.ScenarioResult scenario = NorlysTestScenarios.newBuilder()
            .forNorlysNowCaseHandling()
            .withNorlysNowCases(1)
            .withFeedItems(1)
            .build();
        
        FeedItem testFeedItem = scenario.feedItems[0];
        Set<Id> recordIds = new Set<Id>{ testFeedItem.Id };
        NorlysNow_Case__c parentCase = scenario.norlysNowCases[0];

        EventExecutor__e testEvent = new EventExecutor__e(
            Parameters__c = '{"recordIds":["' + testFeedItem.Id + '"]}'
        );

        // --- Mock Service Calls for the main execution path ---
        NorlysNowService.Parameters params = new NorlysNowService.Parameters();
        params.recordIds = recordIds;
        norlysNowServiceMock.spyOn('getParameters').whenCalledWith(testEvent.Parameters__c).thenReturn(params);

        Map<Id, FeedItem> feedItemMap = new Map<Id, FeedItem>{ testFeedItem.Id => testFeedItem };
        norlysNowSelectorMock.spyOn('getFeedItemMap').whenCalledWith(recordIds).thenReturn(feedItemMap);

        System.CalloutException testException = new System.CalloutException('Error');
        norlysNowClientMock.spyOn('sentRequestNorlysNowCase').whenCalledWith(Argument.any()).thenThrow(testException);
        
        norlysNowServiceMock.spyOn('setErrorOnNorlysNowCase').whenCalledWith(Argument.any(), Argument.any()).thenReturn(parentCase);
        MethodSpy createTasksSpy = norlysNowServiceMock.spyOn('createFollowUpTasks');
        createTasksSpy.whenCalledWith(Argument.any(), Argument.any(), Argument.any(), Argument.any()).thenReturn(null);

        NorlysNowFeedItemStrategy strategy = new NorlysNowFeedItemStrategy();

        // Act
        Test.startTest();
        Set<Id> remainingIds = strategy.toExecute(testEvent);
        Test.stopTest();

        // Assert
        System.assertEquals(0, remainingIds.size(), 'The returned set of IDs should be empty on a callout exception.');
        System.assertEquals(1, databaseServiceStub.register.updated.size(), 'The databaseService.updateRecords method should have been called once.');
        System.assertEquals(1, createTasksSpy.callLog.size(), 'The createFollowUpTasks method should have been called once.');
    }

    @isTest
    static void toExecute_OnHttp500Error_ShouldLogAndRetry() {
        // Arrange
        setupMocks();
        // Default mock for triggers
        norlysNowServiceMock.spyOn('createCaseCommentRequestObject').returns(new NorlysNowClientRequestDTO());
        
        NorlysTestScenarios.ScenarioResult scenario = NorlysTestScenarios.newBuilder()
            .forNorlysNowCaseHandling()
            .withNorlysNowCases(1)
            .withFeedItems(1)
            .build();
        
        FeedItem testFeedItem = scenario.feedItems[0];
        Set<Id> recordIds = new Set<Id>{ testFeedItem.Id };
        NorlysNow_Case__c parentCase = scenario.norlysNowCases[0];

        EventExecutor__e testEvent = new EventExecutor__e(
            Parameters__c = '{"recordIds":["' + testFeedItem.Id + '"]}'
        );

        // --- Mock Service Calls for the main execution path ---
        NorlysNowService.Parameters params = new NorlysNowService.Parameters();
        params.recordIds = recordIds;
        norlysNowServiceMock.spyOn('getParameters').whenCalledWith(testEvent.Parameters__c).thenReturn(params);

        Map<Id, FeedItem> feedItemMap = new Map<Id, FeedItem>{ testFeedItem.Id => testFeedItem };
        norlysNowSelectorMock.spyOn('getFeedItemMap').whenCalledWith(recordIds).thenReturn(feedItemMap);

        HttpResponse errorResponse = new HttpResponse();
        errorResponse.setStatusCode(500);
        errorResponse.setBody('{"error":"Internal Server Error"}');
        HTTPException testException = new HTTPException(errorResponse);
        norlysNowClientMock.spyOn('sentRequestNorlysNowCase').whenCalledWith(Argument.any()).thenThrow(testException);
        
        MethodSpy setErrorSpy = norlysNowServiceMock.spyOn('setErrorOnNorlysNowCase');
        MethodSpy createTasksSpy = norlysNowServiceMock.spyOn('createFollowUpTasks');

        NorlysNowFeedItemStrategy strategy = new NorlysNowFeedItemStrategy();

        // Act
        Test.startTest();
        Set<Id> remainingIds = strategy.toExecute(testEvent);
        Test.stopTest();

        // Assert
        System.assertEquals(1, remainingIds.size(), 'The ID should remain in the set for a retryable 500 error.');
        System.assertEquals(testFeedItem.Id, remainingIds.iterator().next(), 'The correct ID should be in the retry set.');
        System.assertEquals(0, databaseServiceStub.register.updated.size(), 'DatabaseService should not be called for a 500 error.');
        System.assertEquals(0, setErrorSpy.callLog.size(), 'setErrorOnNorlysNowCase should not be called for a 500 error.');
        System.assertEquals(0, createTasksSpy.callLog.size(), 'createFollowUpTasks should not be called for a 500 error.');
    }
}
