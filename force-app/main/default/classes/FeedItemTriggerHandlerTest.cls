/**
 * @description Test class for the FeedItemTriggerHandler. This class ensures that the handler
 *              correctly processes FeedItem records on insert, specifically when they are related
 *              to NorlysNow_Case__c objects.
 *  -----------------------------------------------------------------------------
 *  Developer            Date            Description
 *  -----------------------------------------------------------------------------
 *  Esben Hovgaard       11/09/2025      Initial version.
 *
 * @author Esben Hovgaard
 * @date 2025-09-11
 */
@isTest
private class FeedItemTriggerHandlerTest {

    // Mocked service dependencies, to be initialized in each test
    private static NorlysNowService norlysNowService;
    private static Mock norlysNowSelectorMock;
    private static Mock permissionServiceMock;
    private static Mock eventExecutorServiceMock;
    
    /**
     * @description Sets up the test environment by mocking all the necessary service dependencies.
     *              This is called by each test method to ensure a clean and predictable state.
     */
    private static void setupMocks() {
        // Create mocks for all service dependencies
        norlysNowSelectorMock = Mock.forType(NorlysNowSelector.class);
        permissionServiceMock = Mock.forType(PermissionService.class);
        eventExecutorServiceMock = Mock.forType(EventExecutorService.class);
        norlysNowService = (NorlysNowService) Mock.forType(NorlysNowService.class).stub;

        // Get the stub instances from the mocks
        NorlysNowSelector norlysNowSelectorStub = (NorlysNowSelector) norlysNowSelectorMock.stub;
        PermissionService permissionServiceStub = (PermissionService) permissionServiceMock.stub;
        EventExecutorService eventExecutorServiceStub = (EventExecutorService) eventExecutorServiceMock.stub;

        // Register all the singleton services with our stubs so the handler will use them
        SingletonFactory factory = SingletonFactory.getFactory();
        factory.registerSingleton(NorlysNowSelector.class, norlysNowSelectorStub);
        factory.registerSingleton(PermissionService.class, permissionServiceStub);
        factory.registerSingleton(EventExecutorService.class, eventExecutorServiceStub);
        factory.registerSingleton(NorlysNowService.class, norlysNowService);
    }

    /**
     * @description Tests that when a FeedItem is inserted on a NorlysNow_Case__c and the user has
     *              the correct permissions, an EventExecutor__e event is correctly published.
     */
    @isTest
    static void afterInsert_WithPermissionAndNorlysNowCaseParent_ShouldPublishEvent() {
        // Arrange
        TriggerHandler.bypass('FeedItemTriggerHandler');
        TriggerHandler.bypass('NorlysNowCaseTriggerHandler');
        setupMocks();
        
        // Create a NorlysNow Case with a FeedItem on it
        NorlysTestScenarios.ScenarioResult scenario = NorlysTestScenarios.newBuilder()
            .forNorlysNowCaseHandling()
            .withNorlysNowCases(1)
            .withFeedItems(1)
            .build();
        
        FeedItem testFeedItem = scenario.feedItems[0];
        NorlysNow_Case__c parentCase = scenario.norlysNowCases[0];

        // --- Mock Service Calls ---
        // 1. Mock the permission check to return true
        permissionServiceMock.spyOn('hasPermissionSet').whenCalledWith(Argument.ofType(List<String>.class)).thenReturn(true);

        // 2. Mock the selector to return the parent case
        Map<Id, NorlysNow_Case__c> caseMap = new Map<Id, NorlysNow_Case__c>{ parentCase.Id => parentCase };
        norlysNowSelectorMock.spyOn('getNorlysNowCasesMap').whenCalledWith(Argument.any()).thenReturn(caseMap);

        // 3. Mock the service calls for creating and publishing the event
        norlysNowService.chunkEventsInListsToBePublished(new List<Id>{testFeedItem.Id}, 'FeedItem', 'NorlysNowExecutorHandler');
        eventExecutorServiceMock.spyOn('publish').whenCalledWith(Argument.any()).thenReturn(null);
        
        // Instantiate the handler and set the trigger context
        FeedItemTriggerHandler handler = new FeedItemTriggerHandler();
        handler.triggerNew = new List<FeedItem>{ testFeedItem };
        handler.triggerNewMap = new Map<Id, FeedItem>{ testFeedItem.Id => testFeedItem };

        // Act
        Test.startTest();
        handler.afterInsert();
        Test.stopTest();

        // Assert
        // Verify that the eventExecutorService's publish method was called exactly once.
        MethodSpy publishSpy = eventExecutorServiceMock.getSpy('publish');
        System.assertEquals(1, publishSpy.callLog.size(), 'The publish method should have been called once.');
        
        TriggerHandler.clearAllBypasses();
    }

    /**
     * @description Tests that if the user does NOT have the required permission, no event is published.
     */
    @isTest
    static void afterInsert_WithoutPermission_ShouldNotPublishEvent() {
        // Arrange
        TriggerHandler.bypass('FeedItemTriggerHandler');
        TriggerHandler.bypass('NorlysNowCaseTriggerHandler');
        setupMocks();

        NorlysTestScenarios.ScenarioResult scenario = NorlysTestScenarios.newBuilder()
            .forNorlysNowCaseHandling()
            .withNorlysNowCases(1)
            .withFeedItems(1)
            .build();
        
        FeedItem testFeedItem = scenario.feedItems[0];

        // Mock the permission check to return false
        permissionServiceMock.spyOn('hasPermissionSet').whenCalledWith(Argument.ofType(List<String>.class)).thenReturn(false);
        // Initialize the spy for the 'publish' method so we can check its call log
        eventExecutorServiceMock.spyOn('publish');

        FeedItemTriggerHandler handler = new FeedItemTriggerHandler();
        handler.triggerNew = new List<FeedItem>{ testFeedItem };
        handler.triggerNewMap = new Map<Id, FeedItem>{ testFeedItem.Id => testFeedItem };

        // Act
        Test.startTest();
        handler.afterInsert();
        Test.stopTest();

        // Assert
        // Verify that the publish method was NEVER called.
        MethodSpy publishSpy = eventExecutorServiceMock.getSpy('publish');
        System.assertEquals(0, publishSpy.callLog.size(), 'The publish method should not have been called.');

        TriggerHandler.clearAllBypasses();
    }
}
