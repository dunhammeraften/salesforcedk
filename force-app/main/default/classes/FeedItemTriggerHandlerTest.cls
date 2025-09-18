/**
 * @description Test class for the FeedItemTriggerHandler. This class ensures that the handler
 *              correctly processes FeedItem records on insert. It tests the logic for publishing 
 *              events to the NorlysNow executor.
 * @author Jules
 * @date 2025-09-11
 */
@isTest
private class FeedItemTriggerHandlerTest {

    // Mocked service dependencies, to be initialized in each test
    private static Mock norlysNowServiceMock;
    private static Mock norlysNowSelectorMock;
    private static Mock permissionServiceMock;
    private static Mock eventExecutorServiceMock;
    private static DatabaseService dbMock;
    
    /**
     * @description Sets up the test environment by mocking all the necessary service dependencies.
     *              This is called by each test method to ensure a clean and predictable state.
     */
    private static void setupMocks() {
        // Create mocks for all service dependencies
        norlysNowServiceMock = Mock.forType(NorlysNowService.class);
        norlysNowSelectorMock = Mock.forType(NorlysNowSelector.class);
        permissionServiceMock = Mock.forType(PermissionService.class);
        eventExecutorServiceMock = Mock.forType(EventExecutorService.class);
        // Instantiate DatabaseService with DML mocking enabled
        dbMock = new DatabaseService().mockDmls();
        // Get the shared factory instance
        SingletonFactory factory = SingletonFactory.getFactory();
        // Register all our mock stubs with the shared factory.
        // The handler's default constructor will now receive these mocks.
        factory.registerSingleton(NorlysNowService.class, (NorlysNowService)norlysNowServiceMock.stub);
        factory.registerSingleton(NorlysNowSelector.class, (NorlysNowSelector)norlysNowSelectorMock.stub);
        factory.registerSingleton(PermissionService.class, (PermissionService)permissionServiceMock.stub);
        factory.registerSingleton(EventExecutorService.class, (EventExecutorService)eventExecutorServiceMock.stub);
        factory.registerSingleton(DatabaseService.class, dbMock);
    }

    /**
     * @description Tests that when a FeedItem is inserted and the user has the correct permissions,
     *              an EventExecutor__e event is correctly published to be processed by the NorlysNowExecutorHandler.
     */
    @isTest
    static void afterInsert_WithPermissionAndNorlysNowCaseParent_ShouldPublishEvent() {
        // Arrange
        TriggerHandler.bypass('FeedItemTriggerHandler');
        TriggerHandler.bypass('NorlysNowCaseTriggerHandler');
        setupMocks();

        // Create a scenario with one NorlysNow case and one feed item
        NorlysTestScenarios.ScenarioResult scenario = NorlysTestScenarios.newBuilder()
            .forNorlysNowCaseHandling()
            .withNorlysNowCases(1)
            .withFeedItems(1)
            .build();
        Map<Id, NorlysNow_Case__c> caseMap = new Map<Id, NorlysNow_Case__c>(scenario.norlysNowCases);

        // --- Mock Service Calls ---
        permissionServiceMock.spyOn('hasPermissionSet').whenCalledWith(Argument.any()).thenReturn(true);
        norlysNowSelectorMock.spyOn('getNorlysNowCasesMap').whenCalledWith(caseMap.keySet()).thenReturn(caseMap);
        norlysNowServiceMock.spyOn('chunkEventsInListsToBePublished').whenCalledWith(Argument.any(), Argument.any(), Argument.any())
            .thenReturn(new List<EventExecutor__e>{ new EventExecutor__e() });
        MethodSpy publishSpy = eventExecutorServiceMock.spyOn('publishEvents');
        
        FeedItemTriggerHandler handler = new FeedItemTriggerHandler();
        handler.triggerNew = scenario.feedItems;
        handler.triggerNewMap = new Map<Id, FeedItem>(scenario.feedItems);

        // Act
        Test.startTest();
        handler.afterInsert();
        Test.stopTest();

        // Assert
        System.assertEquals(1, publishSpy.callLog.size(), 'The publish method should have been called once.');
        TriggerHandler.clearAllBypasses();
    }

    /**
     * @description Tests that when a FeedItem is inserted but the user does NOT have the
     *              required permission, the handler exits gracefully without publishing any events.
     */
    @isTest
    static void afterInsert_WithoutPermission_ShouldNotPublishEvent() {
        // Arrange
        TriggerHandler.bypass('FeedItemTriggerHandler');
        TriggerHandler.bypass('NorlysNowCaseTriggerHandler');
        setupMocks();

        // Create a scenario with one NorlysNow case and one feed item
        NorlysTestScenarios.ScenarioResult scenario = NorlysTestScenarios.newBuilder()
            .forNorlysNowCaseHandling()
            .withNorlysNowCases(1)
            .withFeedItems(1)
            .build();
        Map<Id, NorlysNow_Case__c> caseMap = new Map<Id, NorlysNow_Case__c>(scenario.norlysNowCases);

        // --- Mock Service Calls ---
        permissionServiceMock.spyOn('hasPermissionSet').whenCalledWith(Argument.any()).thenReturn(false);
        norlysNowSelectorMock.spyOn('getNorlysNowCasesMap').whenCalledWith(caseMap.keySet()).thenReturn(caseMap);
        norlysNowServiceMock.spyOn('chunkEventsInListsToBePublished').whenCalledWith(Argument.any(), Argument.any(), Argument.any())
            .thenReturn(new List<EventExecutor__e>{ new EventExecutor__e() });
        MethodSpy publishSpy = eventExecutorServiceMock.spyOn('publishEvents');
        
        FeedItemTriggerHandler handler = new FeedItemTriggerHandler();
        handler.triggerNew = scenario.feedItems;
        handler.triggerNewMap = new Map<Id, FeedItem>(scenario.feedItems);

        // Act
        Test.startTest();
        handler.afterInsert();
        Test.stopTest();

        // Assert
        System.assertEquals(0, publishSpy.callLog.size(), 'The publish method should not have been called.');
        TriggerHandler.clearAllBypasses();
    }
}
