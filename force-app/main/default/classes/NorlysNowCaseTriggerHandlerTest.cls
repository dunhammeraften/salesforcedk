/**
 * @description Test class for NorlysNowCaseTriggerHandler.
 *              This class tests the logic of the trigger handler for NorlysNow_Case__c objects,
 *              ensuring that parent cases are correctly handled, events are published as expected,
 *              and permission checks are enforced.
 *              It utilizes the NorlysTestScenarios and NorlysTestMocks frameworks for robust and
 *              maintainable test data setup and dependency mocking.
 *
 * -----------------------------------------------------------------------------
 * Developer            Date            Description
 * -----------------------------------------------------------------------------
 * Kenneth Houkjær      09/10/2025      Initial version
 *
 * @see NorlysNowCaseTriggerHandler
 * @see NorlysTestScenarios
 * @see NorlysTestMocks
 */
@isTest
private class NorlysNowCaseTriggerHandlerTest {

    private static final String PERMISSION_SET_NAME = 'Customer_Support_Technical_NorlysNow_Requester';

    /**
     * @description Sets up the test data and mock services required for the tests.
     */
    @testSetup
    static void makeData(){
        NorlysTestScenarios.ScenarioResult scenario = NorlysTestScenarios.newBuilder()
            .forNumberCaseHandling()
            .build();

        NorlysNow_Case__c norlysNowCase = new NorlysNow_Case__c(
            Parent_Case__c = scenario.caseRecord.Id,
            Status__c = 'New'
        );
        insert norlysNowCase;
    }

    /**
     * @description Verifies that the parent case is closed when a NorlysNow_Case__c is updated.
     */
    @isTest
    static void afterUpdate_closeParentCase_parentCaseClosed() {
        // Arrange
        NorlysNow_Case__c norlysNowCase = [SELECT Id, Parent_Case__c FROM NorlysNow_Case__c LIMIT 1];

        Case parentCaseToClose = new Case(Id = norlysNowCase.Parent_Case__c, Status = 'Closed');

        NorlysTestMocks.NorlysNowServiceMockBuilder mockServiceBuilder = NorlysTestMocks.forNorlysNowService()
            .withCloseParentCases(new List<Case>{ parentCaseToClose });
        NorlysNowService mockService = mockServiceBuilder.build();

        NorlysTestMocks.NorlysNowSelectorMockBuilder mockSelectorBuilder = NorlysTestMocks.forNorlysNowSelector()
            .withNorlysNowCases(new Map<Id, NorlysNow_Case__c>{ norlysNowCase.Id => norlysNowCase });
        NorlysNowSelector mockSelector = mockSelectorBuilder.build();

        DatabaseService dbMock = new DatabaseService().mockDmls();

        SingletonFactory singletonFactory = SingletonFactory.getFactory();
        singletonFactory.reset();
        singletonFactory.registerSingleton(NorlysNowService.class, mockService);
        singletonFactory.registerSingleton(NorlysNowSelector.class, mockSelector);
        singletonFactory.registerSingleton(DatabaseService.class, dbMock);

        // Act
        Test.startTest();
        norlysNowCase.Status__c = 'In Progress';
        update norlysNowCase;
        Test.stopTest();

        // Assert
        System.assertEquals(1, dbMock.register.updated.size(), 'One record should have been updated.');
        System.assertEquals(parentCaseToClose.Id, dbMock.register.updated[0].Id, 'The updated record should be the parent case.');
        System.assertEquals('Closed', ((Case)dbMock.register.updated[0]).Status, 'The parent case status should be "Closed".');
    }

    /**
     * @description Verifies that an event is published when a NorlysNow_Case__c is updated
     *              to 'Withdrawn' status and the user has the required permission set.
     */
    @isTest
    static void afterUpdate_userHasPermissionAndStatusWithdrawn_eventIsPublished() {
        // Arrange
        NorlysNow_Case__c norlysNowCase = [SELECT Id FROM NorlysNow_Case__c LIMIT 1];

        NorlysTestMocks.PermissionServiceMockBuilder mockPermissionServiceBuilder = NorlysTestMocks.forPermissionService()
            .withHasPermissionSet(true);
        PermissionService mockPermissionService = mockPermissionServiceBuilder.build();

        List<EventExecutor__e> eventsToPublish = new List<EventExecutor__e>{
            new EventExecutor__e(Executor__c = 'NorlysNowExecutorHandler')
        };
        NorlysTestMocks.NorlysNowServiceMockBuilder mockNorlysNowServiceBuilder = NorlysTestMocks.forNorlysNowService()
            .withCloseParentCases(new List<Case>())
            .withChunkedEvents(eventsToPublish);
        NorlysNowService mockNorlysNowService = mockNorlysNowServiceBuilder.build();

        NorlysTestMocks.NorlysNowSelectorMockBuilder mockSelectorBuilder = NorlysTestMocks.forNorlysNowSelector()
            .withNorlysNowCases(new Map<Id, NorlysNow_Case__c>{ norlysNowCase.Id => norlysNowCase });
        NorlysNowSelector mockSelector = mockSelectorBuilder.build();

        NorlysTestMocks.EventExecutorServiceMockBuilder mockEventExecutorBuilder = NorlysTestMocks.forEventExecutorService().withPublish();
        EventExecutorService mockEventExecutorService = mockEventExecutorBuilder.build();
        MethodSpy publishSpy = mockEventExecutorBuilder.getPublishSpy();

        SingletonFactory singletonFactory = SingletonFactory.getFactory();
        singletonFactory.reset();
        singletonFactory.registerSingleton(PermissionService.class, mockPermissionService);
        singletonFactory.registerSingleton(NorlysNowService.class, mockNorlysNowService);
        singletonFactory.registerSingleton(NorlysNowSelector.class, mockSelector);
        singletonFactory.registerSingleton(EventExecutorService.class, mockEventExecutorService);

        // Act
        Test.startTest();
        norlysNowCase.Status__c = 'Withdrawn';
        update norlysNowCase;
        Test.stopTest();

        // Assert
        System.assertEquals(1, publishSpy.calls.size(), 'The publish method should have been called once.');
    }

    /**
     * @description Verifies that an event is published when a NorlysNow_Case__c is updated
     *              with 'Pending' sync status and the user has the required permission set.
     */
    @isTest
    static void afterUpdate_userHasPermissionAndSyncStatusPending_eventIsPublished() {
        // Arrange
        NorlysNow_Case__c norlysNowCase = [SELECT Id FROM NorlysNow_Case__c LIMIT 1];

        NorlysTestMocks.PermissionServiceMockBuilder mockPermissionServiceBuilder = NorlysTestMocks.forPermissionService()
            .withHasPermissionSet(true);
        PermissionService mockPermissionService = mockPermissionServiceBuilder.build();

        List<EventExecutor__e> eventsToPublish = new List<EventExecutor__e>{
            new EventExecutor__e(Executor__c = 'NorlysNowExecutorHandler')
        };
        NorlysTestMocks.NorlysNowServiceMockBuilder mockNorlysNowServiceBuilder = NorlysTestMocks.forNorlysNowService()
            .withCloseParentCases(new List<Case>())
            .withChunkedEvents(eventsToPublish);
        NorlysNowService mockNorlysNowService = mockNorlysNowServiceBuilder.build();

        NorlysTestMocks.NorlysNowSelectorMockBuilder mockSelectorBuilder = NorlysTestMocks.forNorlysNowSelector()
            .withNorlysNowCases(new Map<Id, NorlysNow_Case__c>{ norlysNowCase.Id => norlysNowCase });
        NorlysNowSelector mockSelector = mockSelectorBuilder.build();

        NorlysTestMocks.EventExecutorServiceMockBuilder mockEventExecutorBuilder = NorlysTestMocks.forEventExecutorService().withPublish();
        EventExecutorService mockEventExecutorService = mockEventExecutorBuilder.build();
        MethodSpy publishSpy = mockEventExecutorBuilder.getPublishSpy();

        SingletonFactory singletonFactory = SingletonFactory.getFactory();
        singletonFactory.reset();
        singletonFactory.registerSingleton(PermissionService.class, mockPermissionService);
        singletonFactory.registerSingleton(NorlysNowService.class, mockNorlysNowService);
        singletonFactory.registerSingleton(NorlysNowSelector.class, mockSelector);
        singletonFactory.registerSingleton(EventExecutorService.class, mockEventExecutorService);

        // Act
        Test.startTest();
        norlysNowCase.Sync_Status__c = 'Pending';
        update norlysNowCase;
        Test.stopTest();

        // Assert
        System.assertEquals(1, publishSpy.calls.size(), 'The publish method should have been called once.');
    }

    /**
     * @description Verifies that no event is published when the user does not have the
     *              required permission set, even if the status is 'Withdrawn'.
     */
    @isTest
    static void afterUpdate_userDoesNotHavePermission_eventIsNotPublished() {
        // Arrange
        NorlysNow_Case__c norlysNowCase = [SELECT Id FROM NorlysNow_Case__c LIMIT 1];

        NorlysTestMocks.PermissionServiceMockBuilder mockPermissionServiceBuilder = NorlysTestMocks.forPermissionService()
            .withHasPermissionSet(false);
        PermissionService mockPermissionService = mockPermissionServiceBuilder.build();

        NorlysTestMocks.NorlysNowServiceMockBuilder mockNorlysNowServiceBuilder = NorlysTestMocks.forNorlysNowService()
            .withCloseParentCases(new List<Case>());
        NorlysNowService mockNorlysNowService = mockNorlysNowServiceBuilder.build();

        NorlysTestMocks.NorlysNowSelectorMockBuilder mockSelectorBuilder = NorlysTestMocks.forNorlysNowSelector()
            .withNorlysNowCases(new Map<Id, NorlysNow_Case__c>{ norlysNowCase.Id => norlysNowCase });
        NorlysNowSelector mockSelector = mockSelectorBuilder.build();

        NorlysTestMocks.EventExecutorServiceMockBuilder mockEventExecutorBuilder = NorlysTestMocks.forEventExecutorService().withPublish();
        EventExecutorService mockEventExecutorService = mockEventExecutorBuilder.build();
        MethodSpy publishSpy = mockEventExecutorBuilder.getPublishSpy();

        SingletonFactory singletonFactory = SingletonFactory.getFactory();
        singletonFactory.reset();
        singletonFactory.registerSingleton(PermissionService.class, mockPermissionService);
        singletonFactory.registerSingleton(NorlysNowService.class, mockNorlysNowService);
        singletonFactory.registerSingleton(NorlysNowSelector.class, mockSelector);
        singletonFactory.registerSingleton(EventExecutorService.class, mockEventExecutorService);

        // Act
        Test.startTest();
        norlysNowCase.Status__c = 'Withdrawn';
        update norlysNowCase;
        Test.stopTest();

        // Assert
        System.assertEquals(0, publishSpy.calls.size(), 'The publish method should not have been called.');
    }

    /**
     * @description Verifies that the CheckParentCaseIsClosed method is called before a
     *              NorlysNow_Case__c record is updated.
     */
    @isTest
    static void beforeUpdate_checkParentCaseIsClosed_validationIsCalled() {
        // Arrange
        NorlysNow_Case__c norlysNowCase = [SELECT Id FROM NorlysNow_Case__c LIMIT 1];

        NorlysTestMocks.NorlysNowServiceMockBuilder mockServiceBuilder = NorlysTestMocks.forNorlysNowService()
            .withCheckParentCaseIsClosed();
        NorlysNowService mockService = mockServiceBuilder.build();
        MethodSpy checkParentCaseSpy = mockServiceBuilder.getCheckParentCaseIsClosedSpy();

        SingletonFactory singletonFactory = SingletonFactory.getFactory();
        singletonFactory.reset();
        singletonFactory.registerSingleton(NorlysNowService.class, mockService);

        // Act
        Test.startTest();
        norlysNowCase.Status__c = 'In Progress';
        update norlysNowCase;
        Test.stopTest();

        // Assert
        System.assertEquals(1, checkParentCaseSpy.calls.size(), 'The CheckParentCaseIsClosed method should have been called once.');
    }

    /**
     * @description Verifies that the CheckParentCaseIsClosed method is called before a
     *              new NorlysNow_Case__c record is inserted.
     */
    @isTest
    static void beforeInsert_checkParentCaseIsClosed_validationIsCalled() {
        // Arrange
        Case parentCase = [SELECT Id FROM Case LIMIT 1];

        NorlysTestMocks.NorlysNowServiceMockBuilder mockServiceBuilder = NorlysTestMocks.forNorlysNowService()
            .withCheckParentCaseIsClosed();
        NorlysNowService mockService = mockServiceBuilder.build();
        MethodSpy checkParentCaseSpy = mockServiceBuilder.getCheckParentCaseIsClosedSpy();

        SingletonFactory singletonFactory = SingletonFactory.getFactory();
        singletonFactory.reset();
        singletonFactory.registerSingleton(NorlysNowService.class, mockService);

        // Act
        Test.startTest();
        NorlysNow_Case__c norlysNowCase = new NorlysNow_Case__c(
            Parent_Case__c = parentCase.Id,
            Status__c = 'New'
        );
        insert norlysNowCase;
        Test.stopTest();

        // Assert
        System.assertEquals(1, checkParentCaseSpy.calls.size(), 'The CheckParentCaseIsClosed method should have been called once.');
    }

    /**
     * @description Verifies that an event is published after a new NorlysNow_Case__c is inserted,
     *              provided the user has the required permission set.
     */
    @isTest
    static void afterInsert_userHasPermission_eventIsPublished() {
        // Arrange
        Case parentCase = [SELECT Id FROM Case LIMIT 1];

        NorlysTestMocks.PermissionServiceMockBuilder mockPermissionServiceBuilder = NorlysTestMocks.forPermissionService()
            .withHasPermissionSet(true);
        PermissionService mockPermissionService = mockPermissionServiceBuilder.build();

        List<EventExecutor__e> eventsToPublish = new List<EventExecutor__e>{
            new EventExecutor__e(Executor__c = 'NorlysNowExecutorHandler')
        };
        NorlysTestMocks.NorlysNowServiceMockBuilder mockNorlysNowServiceBuilder = NorlysTestMocks.forNorlysNowService()
            .withChunkedEvents(eventsToPublish);
        NorlysNowService mockNorlysNowService = mockNorlysNowServiceBuilder.build();

        NorlysNow_Case__c norlysNowCaseToInsert = new NorlysNow_Case__c(Parent_Case__c = parentCase.Id);
        NorlysTestMocks.NorlysNowSelectorMockBuilder mockSelectorBuilder = NorlysTestMocks.forNorlysNowSelector()
            .withNorlysNowCases(new Map<Id, NorlysNow_Case__c>{ norlysNowCaseToInsert.Id => norlysNowCaseToInsert });
        NorlysNowSelector mockSelector = mockSelectorBuilder.build();

        NorlysTestMocks.EventExecutorServiceMockBuilder mockEventExecutorBuilder = NorlysTestMocks.forEventExecutorService().withPublish();
        EventExecutorService mockEventExecutorService = mockEventExecutorBuilder.build();
        MethodSpy publishSpy = mockEventExecutorBuilder.getPublishSpy();

        SingletonFactory singletonFactory = SingletonFactory.getFactory();
        singletonFactory.reset();
        singletonFactory.registerSingleton(PermissionService.class, mockPermissionService);
        singletonFactory.registerSingleton(NorlysNowService.class, mockNorlysNowService);
        singletonFactory.registerSingleton(NorlysNowSelector.class, mockSelector);
        singletonFactory.registerSingleton(EventExecutorService.class, mockEventExecutorService);

        // Act
        Test.startTest();
        insert norlysNowCaseToInsert;
        Test.stopTest();

        // Assert
        System.assertEquals(1, publishSpy.calls.size(), 'The publish method should have been called once.');
    }

    /**
     * @description Verifies that no event is published after a new NorlysNow_Case__c is inserted
     *              if the user does not have the required permission set.
     */
    @isTest
    static void afterInsert_userDoesNotHavePermission_eventIsNotPublished() {
        // Arrange
        Case parentCase = [SELECT Id FROM Case LIMIT 1];

        NorlysTestMocks.PermissionServiceMockBuilder mockPermissionServiceBuilder = NorlysTestMocks.forPermissionService()
            .withHasPermissionSet(false);
        PermissionService mockPermissionService = mockPermissionServiceBuilder.build();

        NorlysTestMocks.NorlysNowServiceMockBuilder mockNorlysNowServiceBuilder = NorlysTestMocks.forNorlysNowService();
        NorlysNowService mockNorlysNowService = mockNorlysNowServiceBuilder.build();

        NorlysTestMocks.NorlysNowSelectorMockBuilder mockSelectorBuilder = NorlysTestMocks.forNorlysNowSelector();
        NorlysNowSelector mockSelector = mockSelectorBuilder.build();

        NorlysTestMocks.EventExecutorServiceMockBuilder mockEventExecutorBuilder = NorlysTestMocks.forEventExecutorService().withPublish();
        EventExecutorService mockEventExecutorService = mockEventExecutorBuilder.build();
        MethodSpy publishSpy = mockEventExecutorBuilder.getPublishSpy();

        SingletonFactory singletonFactory = SingletonFactory.getFactory();
        singletonFactory.reset();
        singletonFactory.registerSingleton(PermissionService.class, mockPermissionService);
        singletonFactory.registerSingleton(NorlysNowService.class, mockNorlysNowService);
        singletonFactory.registerSingleton(NorlysNowSelector.class, mockSelector);
        singletonFactory.registerSingleton(EventExecutorService.class, mockEventExecutorService);

        // Act
        Test.startTest();
        NorlysNow_Case__c norlysNowCase = new NorlysNow_Case__c(
            Parent_Case__c = parentCase.Id,
            Status__c = 'New'
        );
        insert norlysNowCase;
        Test.stopTest();

        // Assert
        System.assertEquals(0, publishSpy.calls.size(), 'The publish method should not have been called.');
    }
}
