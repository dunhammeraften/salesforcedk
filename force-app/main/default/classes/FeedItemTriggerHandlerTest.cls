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
    
    /**
     * @description Sets up the test environment by mocking all the necessary service dependencies.
     *              This is called by each test method to ensure a clean and predictable state.
     */
    private static void setupMocks() {
        // Create mocks for all service dependencies
        norlysNowSelectorMock = Mock.forType(NorlysNowSelector.class);
        permissionServiceMock = Mock.forType(PermissionService.class);
        eventExecutorServiceMock = Mock.forType(EventExecutorService.class);
        norlysNowServiceMock = Mock.forType(NorlysNowService.class);

        // Get the stub instances from the mocks
        NorlysNowSelector norlysNowSelectorStub = (NorlysNowSelector) norlysNowSelectorMock.stub;
        PermissionService permissionServiceStub = (PermissionService) permissionServiceMock.stub;
        EventExecutorService eventExecutorServiceStub = (EventExecutorService) eventExecutorServiceMock.stub;
        NorlysNowService norlysNowServiceStub = (NorlysNowService) norlysNowServiceMock.stub;

        // Register all the singleton services with our stubs so the handler will use them
        SingletonFactory factory = SingletonFactory.getFactory();
        factory.registerSingleton(NorlysNowSelector.class, norlysNowSelectorStub);
        factory.registerSingleton(PermissionService.class, permissionServiceStub);
        factory.registerSingleton(EventExecutorService.class, eventExecutorServiceStub);
        factory.registerSingleton(NorlysNowService.class, norlysNowServiceStub);
    }

    /**
     * @description Tests that when a FeedItem is inserted and the user has the correct permissions,
     *              an EventExecutor__e event is correctly published to be processed by the NorlysNowExecutorHandler.
     */
    @isTest
    static void afterInsert_WithPermissionAndNorlysNowCaseParent_ShouldPublishEvent() {
        // Arrange
        TriggerHandler.bypass('FeedItemTriggerHandler');
        TriggerHandler.bypass('NorlysNowCaseTrigger');
        setupMocks();
        NorlysTestScenarios.ScenarioResult scenario = NorlysTestScenarios.newBuilder()
            .forNorlysNowCaseHandling()
            .withNorlysNowCases(1)
            .withFeedItems(1)
            .build();
        
        FeedItem testFeedItem = scenario.feedItems[0];
        NorlysNow_Case__c testCase = scenario.norlysNowCases[0];

        // --- Mock Service Calls ---
        permissionServiceMock.spyOn('hasPermissionSet').whenCalledWith(Argument.ofType(List<String>.class)).thenReturn(true);
        Map<Id, NorlysNow_Case__c> caseMap = new Map<Id, NorlysNow_Case__c>{ testCase.Id => testCase };
        norlysNowSelectorMock.spyOn('getNorlysNowCasesMap').whenCalledWith(Argument.any()).thenReturn(caseMap);
        
        List<EventExecutor__e> dummyEventList = new List<EventExecutor__e>{ new EventExecutor__e() };
        norlysNowServiceMock.spyOn('chunkEventsInListsToBePublished')
            .whenCalledWith(Argument.any(), Argument.any(), Argument.any())
            .thenReturn(dummyEventList);

        eventExecutorServiceMock.spyOn('publish').whenCalledWith(Argument.any()).thenReturn(null);
        
        FeedItemTriggerHandler handler = new FeedItemTriggerHandler();
        handler.triggerNew = new List<FeedItem>{ testFeedItem };
        handler.triggerNewMap = new Map<Id, FeedItem>{ testFeedItem.Id => testFeedItem };

        // Act
        Test.startTest();
        handler.afterInsert();
        Test.stopTest();

        // Assert
        MethodSpy publishSpy = eventExecutorServiceMock.getSpy('publish');
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
        TriggerHandler.bypass('NorlysNowCaseTrigger');
        setupMocks();
        NorlysTestScenarios.ScenarioResult scenario = NorlysTestScenarios.newBuilder()
            .forNorlysNowCaseHandling()
            .withNorlysNowCases(1)
            .withFeedItems(1)
            .build();
        
        permissionServiceMock.spyOn('hasPermissionSet').whenCalledWith(Argument.ofType(List<String>.class)).thenReturn(false);
        // Initialize the spy for the 'publish' method so we can check its call log later.
        eventExecutorServiceMock.spyOn('publish');
        
        FeedItemTriggerHandler handler = new FeedItemTriggerHandler();
        handler.triggerNew = scenario.feedItems;
        handler.triggerNewMap = new Map<Id, FeedItem>(scenario.feedItems);

        // Act
        Test.startTest();
        handler.afterInsert();
        Test.stopTest();

        // Assert
        MethodSpy publishSpy = eventExecutorServiceMock.getSpy('publish');
        System.assertEquals(0, publishSpy.callLog.size(), 'The publish method should not have been called.');
        TriggerHandler.clearAllBypasses();
    }

    /**
     * @description Tests that the handler exits gracefully without publishing any events
     *              when the FeedItem parent is not a NorlysNow_Case__c.
     */
    @isTest
    static void afterInsert_WithNonNorlysNowCaseParent_ShouldNotPublishEvent() {
        // Arrange
        TriggerHandler.bypass('FeedItemTriggerHandler');
        TriggerHandler.bypass('NorlysNowCaseTrigger');
        setupMocks();
        
        // Create a Case instead of a NorlysNow_Case__c
        Case parentCase = new Case(Subject = 'Test Case');
        insert parentCase;

        FeedItem testFeedItem = new FeedItem(
            ParentId = parentCase.Id,
            Body = 'Test Feed Item'
        );
        insert testFeedItem;

        permissionServiceMock.spyOn('hasPermissionSet').whenCalledWith(Argument.ofType(List<String>.class)).thenReturn(true);
        eventExecutorServiceMock.spyOn('publish');
        
        FeedItemTriggerHandler handler = new FeedItemTriggerHandler();
        handler.triggerNew = new List<FeedItem>{ testFeedItem };
        handler.triggerNewMap = new Map<Id, FeedItem>{ testFeedItem.Id => testFeedItem };

        // Act
        Test.startTest();
        handler.afterInsert();
        Test.stopTest();

        // Assert
        MethodSpy publishSpy = eventExecutorServiceMock.getSpy('publish');
        System.assertEquals(0, publishSpy.callLog.size(), 'The publish method should not have been called.');
        TriggerHandler.clearAllBypasses();
    }
}
