/**
 * @description Test class for NorlysNowCaseTriggerHandler.
 * This class tests the trigger handler logic for NorlysNow_Case__c objects.
 */
@isTest
private class NorlysNowCaseTriggerHandlerTest {

    /**
     * @description Tests the after update logic.
     * Verifies that the parent case is closed when all its child NorlysNow_Case__c records' statuses are updated to 'Closed'.
     */
    @isTest
    static void afterUpdate_LastChildCaseClosed_ParentCaseIsClosed() {
        // Arrange
        // 1. Create test data using the scenario builder to get a parent Case.
        NorlysTestScenarios.ScenarioResult scenario = NorlysTestScenarios.newBuilder().build();

        Case parentCase = scenario.caseRecord;
        parentCase.Status = 'New';
        update parentCase;

        // Create a child NorlysNow_Case__c record.
        NorlysNow_Case__c norlysNowCase = new NorlysNow_Case__c(
            Parent_Case__c = parentCase.Id,
            Status__c = 'In Progress'
        );
        insert norlysNowCase;

        NorlysNow_Case__c oldNorlysNowCase = norlysNowCase.clone();


        // 2. Mock services
        Mock norlysNowServiceMock = Mock.forType(NorlysNowService.class);
        // We will make closeParentCases return a list containing the parent case to be closed.
        // In a real scenario, this method would check if all sibling cases are closed.
        // For this test, we are forcing the condition to be true by mocking the service response.
        List<Case> casesToClose = new List<Case>{ new Case(Id = parentCase.Id, Status = 'Closed') };
        norlysNowServiceMock.spyOn('closeParentCases')
            .whenCalledWith(Argument.any())
            .thenReturn(casesToClose);

        Mock norlysNowSelectorMock = Mock.forType(NorlysNowSelector.class);
        // The handler queries for the NorlysNow_Case__c records from the trigger context.
        Map<Id, NorlysNow_Case__c> queriedCases = new Map<Id, NorlysNow_Case__c>{ norlysNowCase.Id => norlysNowCase };
        norlysNowSelectorMock.spyOn('getNorlysNowCasesMap')
            .whenCalledWith(Argument.any())
            .thenReturn(queriedCases);

        DatabaseService dbServiceMock = new DatabaseService().mockDmls();

        Mock permissionServiceMock = Mock.forType(PermissionService.class);
        // Return false to skip the event publishing part of the logic for this specific test.
        permissionServiceMock.spyOn('hasPermissionSet').whenCalledWith(Argument.any()).thenReturn(false);

        Mock eventExecutorServiceMock = Mock.forType(EventExecutorService.class);


        // 3. Instantiate the handler with mocks
        NorlysNowCaseTriggerHandler handler = new NorlysNowCaseTriggerHandler(
            (NorlysNowService) norlysNowServiceMock.stub,
            (NorlysNowSelector) norlysNowSelectorMock.stub,
            dbServiceMock,
            (PermissionService) permissionServiceMock.stub,
            (EventExecutorService) eventExecutorServiceMock.stub
        );

        // 4. Set trigger context for an update operation
        norlysNowCase.Status__c = 'Closed';
        handler.triggerNewMap = new Map<Id, NorlysNow_Case__c>{ norlysNowCase.Id => norlysNowCase };
        handler.triggerOldMap = new Map<Id, NorlysNow_Case__c>{ oldNorlysNowCase.Id => oldNorlysNowCase };
        handler.triggerNew = new List<NorlysNow_Case__c>{ norlysNowCase };
        handler.triggerOld = new List<NorlysNow_Case__c>{ oldNorlysNowCase };

        // Act
        Test.startTest();
        handler.afterUpdate();
        Test.stopTest();

        // Assert
        // Verify that NorlysNowService.closeParentCases was called.
        MethodSpy closeParentCasesSpy = norlysNowServiceMock.getSpy('closeParentCases');
        Assert.isTrue(closeParentCasesSpy.hasBeenCalled(), 'closeParentCases should have been called.');

        // Verify that databaseService.updateRecords was called with the case to be closed.
        Assert.areEqual(1, dbServiceMock.register.updated.size(), 'One record should be updated via DatabaseService.');
        Case updatedCase = (Case)dbServiceMock.register.updated[0];
        Assert.areEqual(parentCase.Id, updatedCase.Id, 'The correct case should be updated.');
        Assert.areEqual('Closed', updatedCase.Status, 'The case status should be updated to Closed.');
    }

    /**
     * @description Tests the before update logic.
     * Verifies that an error is added if the parent case is already closed.
     */
    @isTest
    static void beforeUpdate_ParentCaseIsClosed_ErrorIsAdded() {
        // Arrange
        // 1. Create test data
        NorlysTestScenarios.ScenarioResult scenario = NorlysTestScenarios.newBuilder().build();
        Case parentCase = scenario.caseRecord;
        parentCase.Status = 'Closed';
        update parentCase;

        NorlysNow_Case__c norlysNowCase = new NorlysNow_Case__c(
            Parent_Case__c = parentCase.Id,
            Status__c = 'In Progress'
        );
        insert norlysNowCase;

        // 2. Mock services
        // For before update, we are testing the CheckParentCaseIsClosed method in NorlysNowService.
        // We will not mock this service, but we will mock the selector it uses.
        Mock norlysNowSelectorMock = Mock.forType(NorlysNowSelector.class);
        // When getCasesByIds is called, return the closed parent case.
        norlysNowSelectorMock.spyOn('getCasesByIds')
            .whenCalledWith(Argument.any())
            .thenReturn(new Map<Id, Case>{ parentCase.Id => parentCase });

        NorlysNowService norlysNowService = new NorlysNowService((NorlysNowSelector) norlysNowSelectorMock.stub);

        // 3. Instantiate the handler
        // We only need to provide the NorlysNowService for this test. The other services are not used in beforeUpdate.
        NorlysNowCaseTriggerHandler handler = new NorlysNowCaseTriggerHandler(
            norlysNowService,
            null, // norlysNowSelector not used directly in beforeUpdate
            null, // databaseService not used
            null, // permissionService not used
            null  // eventExecutorService not used
        );

        // 4. Set trigger context
        handler.triggerNew = new List<NorlysNow_Case__c>{ norlysNowCase };

        // Act
        Test.startTest();
        handler.beforeUpdate();
        Test.stopTest();

        // Assert
        // Verify that an error was added to the record.
        Assert.isTrue(norlysNowCase.hasErrors(), 'An error should be added to the NorlysNow_Case__c record.');
        Assert.areEqual('You are not allowed to create or update NorlysNow Cases on a closed Case', norlysNowCase.getErrors()[0].getMessage(), 'The error message should be correct.');
    }

    /**
     * @description Tests the after insert logic.
     * Verifies that an event is published when a new NorlysNow_Case__c is created and the user has the required permission.
     */
    @isTest
    static void afterInsert_WithPermission_EventIsPublished() {
        // Arrange
        // 1. Create test data
        NorlysTestScenarios.ScenarioResult scenario = NorlysTestScenarios.newBuilder().build();
        Case parentCase = scenario.caseRecord;

        NorlysNow_Case__c norlysNowCase = new NorlysNow_Case__c(
            Parent_Case__c = parentCase.Id,
            Status__c = 'New'
        );
        insert norlysNowCase;

        // 2. Mock services
        Mock permissionServiceMock = Mock.forType(PermissionService.class);
        permissionServiceMock.spyOn('hasPermissionSet').whenCalledWith(Argument.any()).thenReturn(true);

        Mock norlysNowSelectorMock = Mock.forType(NorlysNowSelector.class);
        norlysNowSelectorMock.spyOn('getNorlysNowCasesMap')
            .whenCalledWith(Argument.any())
            .thenReturn(new Map<Id, NorlysNow_Case__c>{ norlysNowCase.Id => norlysNowCase });

        Mock norlysNowServiceMock = Mock.forType(NorlysNowService.class);
        List<EventExecutor__e> eventsToPublish = new List<EventExecutor__e>{
            new EventExecutor__e(Executor__c = 'NorlysNowExecutorHandler')
        };
        norlysNowServiceMock.spyOn('chunkEventsInListsToBePublished')
            .whenCalledWith(Argument.any(), Argument.any(), Argument.any())
            .thenReturn(eventsToPublish);

        Mock eventExecutorServiceMock = Mock.forType(EventExecutorService.class);
        MethodSpy publishSpy = eventExecutorServiceMock.spyOn('publish');

        // 3. Instantiate the handler with mocks
        NorlysNowCaseTriggerHandler handler = new NorlysNowCaseTriggerHandler(
            (NorlysNowService) norlysNowServiceMock.stub,
            (NorlysNowSelector) norlysNowSelectorMock.stub,
            new DatabaseService(), // not used in this path
            (PermissionService) permissionServiceMock.stub,
            (EventExecutorService) eventExecutorServiceMock.stub
        );

        // 4. Set trigger context for an insert operation
        handler.triggerNewMap = new Map<Id, NorlysNow_Case__c>{ norlysNowCase.Id => norlysNowCase };
        handler.triggerNew = new List<NorlysNow_Case__c>{ norlysNowCase };

        // Act
        Test.startTest();
        handler.afterInsert();
        Test.stopTest();

        // Assert
        // Verify that EventExecutorService.publish was called.
        Assert.isTrue(publishSpy.hasBeenCalled(), 'publish should have been called on EventExecutorService.');
        Assert.areEqual(1, publishSpy.calls.size(), 'publish should have been called once.');
        List<EventExecutor__e> publishedEvents = (List<EventExecutor__e>) publishSpy.calls[0].args[0];
        Assert.areEqual(1, publishedEvents.size(), 'One event should have been published.');
        Assert.areEqual('NorlysNowExecutorHandler', publishedEvents[0].Executor__c, 'The correct executor should be specified on the event.');
    }

    /**
     * @description Tests the after insert logic.
     * Verifies that no event is published when a new NorlysNow_Case__c is created and the user does not have the required permission.
     */
    @isTest
    static void afterInsert_WithoutPermission_EventIsNotPublished() {
        // Arrange
        // 1. Create test data
        NorlysNow_Case__c norlysNowCase = new NorlysNow_Case__c(
            Status__c = 'New'
        );
        insert norlysNowCase;

        // 2. Mock services
        Mock permissionServiceMock = Mock.forType(PermissionService.class);
        permissionServiceMock.spyOn('hasPermissionSet').whenCalledWith(Argument.any()).thenReturn(false);

        Mock eventExecutorServiceMock = Mock.forType(EventExecutorService.class);
        MethodSpy publishSpy = eventExecutorServiceMock.spyOn('publish');

        // 3. Instantiate the handler with mocks
        NorlysNowCaseTriggerHandler handler = new NorlysNowCaseTriggerHandler(
            null, // norlysNowService not used
            null, // norlysNowSelector not used
            null, // databaseService not used
            (PermissionService) permissionServiceMock.stub,
            (EventExecutorService) eventExecutorServiceMock.stub
        );

        // 4. Set trigger context
        handler.triggerNewMap = new Map<Id, NorlysNow_Case__c>{ norlysNowCase.Id => norlysNowCase };
        handler.triggerNew = new List<NorlysNow_Case__c>{ norlysNowCase };

        // Act
        Test.startTest();
        handler.afterInsert();
        Test.stopTest();

        // Assert
        // Verify that EventExecutorService.publish was not called.
        Assert.isFalse(publishSpy.hasBeenCalled(), 'publish should not have been called on EventExecutorService.');
    }

    /**
     * @description Tests the after update logic.
     * Verifies that an event is published when a NorlysNow_Case__c status is updated to 'Withdrawn' and the user has permission.
     */
    @isTest
    static void afterUpdate_StatusWithdrawnWithPermission_EventIsPublished() {
        // Arrange
        // 1. Create test data
        NorlysNow_Case__c norlysNowCase = new NorlysNow_Case__c(Status__c = 'In Progress');
        insert norlysNowCase;
        NorlysNow_Case__c oldNorlysNowCase = norlysNowCase.clone();

        // 2. Mock services
        Mock permissionServiceMock = Mock.forType(PermissionService.class);
        permissionServiceMock.spyOn('hasPermissionSet').whenCalledWith(Argument.any()).thenReturn(true);

        Mock norlysNowSelectorMock = Mock.forType(NorlysNowSelector.class);
        norlysNowSelectorMock.spyOn('getNorlysNowCasesMap')
            .whenCalledWith(Argument.any())
            .thenReturn(new Map<Id, NorlysNow_Case__c>{ norlysNowCase.Id => norlysNowCase });

        Mock norlysNowServiceMock = Mock.forType(NorlysNowService.class);
        norlysNowServiceMock.spyOn('closeParentCases').whenCalledWith(Argument.any()).thenReturn(new List<Case>());
        List<EventExecutor__e> eventsToPublish = new List<EventExecutor__e>{
            new EventExecutor__e(Executor__c = 'NorlysNowExecutorHandler')
        };
        norlysNowServiceMock.spyOn('chunkEventsInListsToBePublished')
            .whenCalledWith(Argument.any(), Argument.any(), Argument.any())
            .thenReturn(eventsToPublish);

        Mock eventExecutorServiceMock = Mock.forType(EventExecutorService.class);
        MethodSpy publishSpy = eventExecutorServiceMock.spyOn('publish');

        // 3. Instantiate the handler with mocks
        NorlysNowCaseTriggerHandler handler = new NorlysNowCaseTriggerHandler(
            (NorlysNowService) norlysNowServiceMock.stub,
            (NorlysNowSelector) norlysNowSelectorMock.stub,
            new DatabaseService().mockDmls(),
            (PermissionService) permissionServiceMock.stub,
            (EventExecutorService) eventExecutorServiceMock.stub
        );

        // 4. Set trigger context
        norlysNowCase.Status__c = 'Withdrawn';
        handler.triggerNewMap = new Map<Id, NorlysNow_Case__c>{ norlysNowCase.Id => norlysNowCase };
        handler.triggerOldMap = new Map<Id, NorlysNow_Case__c>{ oldNorlysNowCase.Id => oldNorlysNowCase };
        handler.triggerNew = new List<NorlysNow_Case__c>{ norlysNowCase };
        handler.triggerOld = new List<NorlysNow_Case__c>{ oldNorlysNowCase };

        // Act
        Test.startTest();
        handler.afterUpdate();
        Test.stopTest();

        // Assert
        Assert.isTrue(publishSpy.hasBeenCalled(), 'publish should have been called.');
    }

    /**
     * @description Tests the after update logic.
     * Verifies that an event is published when a NorlysNow_Case__c sync status is updated to 'Pending' and the user has permission.
     */
    @isTest
    static void afterUpdate_SyncStatusPendingWithPermission_EventIsPublished() {
        // Arrange
        NorlysNow_Case__c norlysNowCase = new NorlysNow_Case__c(Sync_Status__c = 'Success');
        insert norlysNowCase;
        NorlysNow_Case__c oldNorlysNowCase = norlysNowCase.clone();

        Mock permissionServiceMock = Mock.forType(PermissionService.class);
        permissionServiceMock.spyOn('hasPermissionSet').whenCalledWith(Argument.any()).thenReturn(true);

        Mock norlysNowSelectorMock = Mock.forType(NorlysNowSelector.class);
        norlysNowSelectorMock.spyOn('getNorlysNowCasesMap')
            .whenCalledWith(Argument.any())
            .thenReturn(new Map<Id, NorlysNow_Case__c>{ norlysNowCase.Id => norlysNowCase });

        Mock norlysNowServiceMock = Mock.forType(NorlysNowService.class);
        norlysNowServiceMock.spyOn('closeParentCases').whenCalledWith(Argument.any()).thenReturn(new List<Case>());
        List<EventExecutor__e> eventsToPublish = new List<EventExecutor__e>{
            new EventExecutor__e(Executor__c = 'NorlysNowExecutorHandler')
        };
        norlysNowServiceMock.spyOn('chunkEventsInListsToBePublished')
            .whenCalledWith(Argument.any(), Argument.any(), Argument.any())
            .thenReturn(eventsToPublish);

        Mock eventExecutorServiceMock = Mock.forType(EventExecutorService.class);
        MethodSpy publishSpy = eventExecutorServiceMock.spyOn('publish');

        NorlysNowCaseTriggerHandler handler = new NorlysNowCaseTriggerHandler(
            (NorlysNowService) norlysNowServiceMock.stub,
            (NorlysNowSelector) norlysNowSelectorMock.stub,
            new DatabaseService().mockDmls(),
            (PermissionService) permissionServiceMock.stub,
            (EventExecutorService) eventExecutorServiceMock.stub
        );

        norlysNowCase.Sync_Status__c = 'Pending';
        handler.triggerNewMap = new Map<Id, NorlysNow_Case__c>{ norlysNowCase.Id => norlysNowCase };
        handler.triggerOldMap = new Map<Id, NorlysNow_Case__c>{ oldNorlysNowCase.Id => oldNorlysNowCase };
        handler.triggerNew = new List<NorlysNow_Case__c>{ norlysNowCase };
        handler.triggerOld = new List<NorlysNow_Case__c>{ oldNorlysNowCase };

        // Act
        Test.startTest();
        handler.afterUpdate();
        Test.stopTest();

        // Assert
        Assert.isTrue(publishSpy.hasBeenCalled(), 'publish should have been called.');
    }

    /**
     * @description Tests the before insert logic.
     * Verifies that an error is added if the parent case is already closed.
     */
    @isTest
    static void beforeInsert_ParentCaseIsClosed_ErrorIsAdded() {
        // Arrange
        NorlysTestScenarios.ScenarioResult scenario = NorlysTestScenarios.newBuilder().build();
        Case parentCase = scenario.caseRecord;
        parentCase.Status = 'Closed';
        update parentCase;

        NorlysNow_Case__c norlysNowCase = new NorlysNow_Case__c(
            Parent_Case__c = parentCase.Id,
            Status__c = 'In Progress'
        );
        // Don't insert yet, it's a before insert trigger

        Mock norlysNowSelectorMock = Mock.forType(NorlysNowSelector.class);
        norlysNowSelectorMock.spyOn('getCasesByIds')
            .whenCalledWith(Argument.any())
            .thenReturn(new Map<Id, Case>{ parentCase.Id => parentCase });

        NorlysNowService norlysNowService = new NorlysNowService((NorlysNowSelector) norlysNowSelectorMock.stub);

        NorlysNowCaseTriggerHandler handler = new NorlysNowCaseTriggerHandler(
            norlysNowService, null, null, null, null
        );

        handler.triggerNew = new List<NorlysNow_Case__c>{ norlysNowCase };

        // Act
        Test.startTest();
        handler.beforeInsert();
        Test.stopTest();

        // Assert
        Assert.isTrue(norlysNowCase.hasErrors(), 'An error should be added.');
        Assert.areEqual('You are not allowed to create or update NorlysNow Cases on a closed Case', norlysNowCase.getErrors()[0].getMessage(), 'The error message should be correct.');
    }
}
