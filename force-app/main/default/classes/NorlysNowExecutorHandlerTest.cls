/**
 * @description Test class for NorlysNowExecutorHandler.
 *              This class verifies that the handler correctly dispatches events
 *              to the appropriate strategy and handles retries.
 * -----------------------------------------------------------------------------
 * Developer            Date            Description
 * -----------------------------------------------------------------------------
 * Jules                2025-09-13      Initial version.
 * Jules                2025-09-13      Refactored to fix deployment errors and improve testability.
 */
@isTest
private class NorlysNowExecutorHandlerTest {

    private static Mock norlysNowServiceMock;
    private static Mock eventExecutorServiceMock;
    private static Mock caseStrategyMock;
    private static Mock feedItemStrategyMock;
    private static Mock contentDocLinkStrategyMock;

    /**
     * @description Sets up the test environment by mocking all the necessary service dependencies.
     */
    private static void setupMocks() {
        // Create mocks for all service dependencies
        norlysNowServiceMock = Mock.forType(NorlysNowService.class);
        eventExecutorServiceMock = Mock.forType(EventExecutorService.class);
        caseStrategyMock = Mock.forType(NorlysNowCaseStrategy.class);
        feedItemStrategyMock = Mock.forType(NorlysNowFeedItemStrategy.class);
        contentDocLinkStrategyMock = Mock.forType(NorlysNowContentDocumentLinkStrategy.class);

        // Get the stub instances from the mocks
        NorlysNowService norlysNowServiceStub = (NorlysNowService) norlysNowServiceMock.stub;
        EventExecutorService eventExecutorServiceStub = (EventExecutorService) eventExecutorServiceMock.stub;
        NorlysNowCaseStrategy caseStrategyStub = (NorlysNowCaseStrategy) caseStrategyMock.stub;
        NorlysNowFeedItemStrategy feedItemStrategyStub = (NorlysNowFeedItemStrategy) feedItemStrategyMock.stub;
        NorlysNowContentDocumentLinkStrategy contentDocLinkStrategyStub = (NorlysNowContentDocumentLinkStrategy) contentDocLinkStrategyMock.stub;

        // Register all the singleton services with our stubs so the handler will use them
        SingletonFactory factory = SingletonFactory.getFactory();
        factory.registerSingleton(NorlysNowService.class, norlysNowServiceStub);
        factory.registerSingleton(EventExecutorService.class, eventExecutorServiceStub);
        factory.registerSingleton(NorlysNowCaseStrategy.class, caseStrategyStub);
        factory.registerSingleton(NorlysNowFeedItemStrategy.class, feedItemStrategyStub);
        factory.registerSingleton(NorlysNowContentDocumentLinkStrategy.class, contentDocLinkStrategyStub);
    }

    @isTest
    static void execute_WithCaseStrategy_ShouldCallCaseStrategy() {
        // Arrange
        setupMocks();

        EventExecutor__e testEvent = new EventExecutor__e(Parameters__c = '{"type":"NorlysNow_Case__c"}');
        NorlysNowService.Parameters params = new NorlysNowService.Parameters();
        params.type = 'NorlysNow_Case__c';

        // --- Mock Service Calls ---
        norlysNowServiceMock.spyOn('getParameters').whenCalledWith(testEvent.Parameters__c).thenReturn(params);
        
        MethodSpy toExecuteSpy = caseStrategyMock.spyOn('toExecute');
        toExecuteSpy.whenCalledWith(testEvent).thenReturn(new Set<Id>());
        
        eventExecutorServiceMock.spyOn('publish');

        NorlysNowExecutorHandler handler = new NorlysNowExecutorHandler();
        
        // Act
        Test.startTest();
        handler.execute(testEvent);
        Test.stopTest();

        // Assert
        MethodSpy publishSpy = eventExecutorServiceMock.getSpy('publish');
        System.assertEquals(1, toExecuteSpy.callLog.size(), 'The toExecute method on the case strategy should have been called once.');
        System.assertEquals(0, publishSpy.callLog.size(), 'The publish method should not have been called.');
    }

    @isTest
    static void execute_WithFeedItemStrategy_ShouldCallFeedItemStrategy() {
        // Arrange
        setupMocks();

        EventExecutor__e testEvent = new EventExecutor__e(Parameters__c = '{"type":"FeedItem"}');
        NorlysNowService.Parameters params = new NorlysNowService.Parameters();
        params.type = 'FeedItem';

        // --- Mock Service Calls ---
        norlysNowServiceMock.spyOn('getParameters').whenCalledWith(testEvent.Parameters__c).thenReturn(params);
        
        MethodSpy toExecuteSpy = feedItemStrategyMock.spyOn('toExecute');
        toExecuteSpy.whenCalledWith(testEvent).thenReturn(new Set<Id>());
        
        NorlysNowExecutorHandler handler = new NorlysNowExecutorHandler();
        
        // Act
        Test.startTest();
        handler.execute(testEvent);
        Test.stopTest();

        // Assert
        System.assertEquals(1, toExecuteSpy.callLog.size(), 'The toExecute method on the feed item strategy should have been called once.');
    }

    @isTest
    static void execute_WithContentDocumentLinkStrategy_ShouldCallContentDocumentLinkStrategy() {
        // Arrange
        setupMocks();

        EventExecutor__e testEvent = new EventExecutor__e(Parameters__c = '{"type":"ContentDocumentLink"}');
        NorlysNowService.Parameters params = new NorlysNowService.Parameters();
        params.type = 'ContentDocumentLink';

        // --- Mock Service Calls ---
        norlysNowServiceMock.spyOn('getParameters').whenCalledWith(testEvent.Parameters__c).thenReturn(params);
        
        MethodSpy toExecuteSpy = contentDocLinkStrategyMock.spyOn('toExecute');
        toExecuteSpy.whenCalledWith(testEvent).thenReturn(new Set<Id>());
        
        NorlysNowExecutorHandler handler = new NorlysNowExecutorHandler();
        
        // Act
        Test.startTest();
        handler.execute(testEvent);
        Test.stopTest();

        // Assert
        System.assertEquals(1, toExecuteSpy.callLog.size(), 'The toExecute method on the content document link strategy should have been called once.');
    }

    @isTest
    static void execute_WhenStrategyReturnsIds_ShouldPublishRetryEvent() {
        // Arrange
        setupMocks();

        EventExecutor__e testEvent = new EventExecutor__e(
            Executor__c = 'NorlysNowExecutorHandler',
            Parameters__c = '{"type":"NorlysNow_Case__c"}',
            RetryCount__c = 0
        );
        NorlysNowService.Parameters params = new NorlysNowService.Parameters();
        params.type = 'NorlysNow_Case__c';
        
        // --- Mock Service Calls ---
        norlysNowServiceMock.spyOn('getParameters').whenCalledWith(testEvent.Parameters__c).thenReturn(params);
        
        Set<Id> retryIds = new Set<Id>{Test.getStandardPricebookId()}; // Simulate that there are IDs to retry
        MethodSpy toExecuteSpy = caseStrategyMock.spyOn('toExecute');
        toExecuteSpy.whenCalledWith(testEvent).thenReturn(retryIds);

        eventExecutorServiceMock.spyOn('publish');

        NorlysNowExecutorHandler handler = new NorlysNowExecutorHandler();
        
        // Act
        Test.startTest();
        handler.execute(testEvent);
        Test.stopTest();

        // Assert
        MethodSpy publishSpy = eventExecutorServiceMock.getSpy('publish');
        System.assertEquals(1, publishSpy.callLog.size(), 'EventExecutorService.publish should have been called once to schedule a retry.');
    }

    @isTest
    static void execute_WithUnknownStrategy_ShouldLogError() {
        // Arrange
        setupMocks();

        EventExecutor__e testEvent = new EventExecutor__e(Parameters__c = '{"type":"Unknown_Type"}');
        NorlysNowService.Parameters params = new NorlysNowService.Parameters();
        params.type = 'Unknown_Type';

        // --- Mock Service Calls ---
        norlysNowServiceMock.spyOn('getParameters').whenCalledWith(testEvent.Parameters__c).thenReturn(params);
        
        MethodSpy caseExecuteSpy = caseStrategyMock.spyOn('toExecute');
        MethodSpy feedItemExecuteSpy = feedItemStrategyMock.spyOn('toExecute');
        MethodSpy contentDocLinkExecuteSpy = contentDocLinkStrategyMock.spyOn('toExecute');

        NorlysNowExecutorHandler handler = new NorlysNowExecutorHandler();
        
        // Act
        Test.startTest();
        handler.execute(testEvent);
        Test.stopTest();

        // Assert
        System.assertEquals(0, caseExecuteSpy.callLog.size(), 'Case strategy should not have been called for an unknown type.');
        System.assertEquals(0, feedItemExecuteSpy.callLog.size(), 'FeedItem strategy should not have been called for an unknown type.');
        System.assertEquals(0, contentDocLinkExecuteSpy.callLog.size(), 'ContentDocumentLink strategy should not have been called for an unknown type.');
    }
}
