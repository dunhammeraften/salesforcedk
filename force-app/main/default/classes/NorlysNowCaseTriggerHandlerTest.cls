/**
 * @description Test class for NorlysNowCaseTriggerHandler.
 * This class tests the trigger handler logic for NorlysNow_Case__c objects.
 */
@isTest
private class NorlysNowCaseTriggerHandlerTest {

    // Helper method to create a test user with the required permission set
    private static User createTestUserWithPermissionSet() {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Telia Enterprise Customer Service'];
        User u = new User(
            Alias = 'standt',
            Email = 'standarduser@testorg.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Testing',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = p.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'standarduser' + System.currentTimeMillis() + '@testorg.com'
        );
        insert u;

        PermissionSet ps = [
            SELECT Id
            FROM PermissionSet
            WHERE Name = 'Customer_Support_Technical_NorlysNow_Requester'
        ];
        insert new PermissionSetAssignment(AssigneeId = u.Id, PermissionSetId = ps.Id);

        return u;
    }

    /**
     * @description Tests the after update logic.
     * Verifies that the parent case is closed when all its child NorlysNow_Case__c records' statuses are updated to 'Closed'.
     */
    @isTest
    static void afterUpdate_LastChildCaseClosed_ParentCaseIsClosed() {
        // This test does not depend on specific user permissions, so it can run as the default test user.
        // Arrange
        Case parentCase = new Case(Subject = 'Test Parent Case', Status = 'New');
        insert parentCase;

        NorlysNow_Case__c norlysNowCase = new NorlysNow_Case__c(
            Parent_Case__c = parentCase.Id,
            Status__c = 'In Progress'
        );
        insert norlysNowCase;

        NorlysNow_Case__c oldNorlysNowCase = norlysNowCase.clone();

        // Mock services using the extended NorlysTestMocks framework
        List<Case> casesToClose = new List<Case>{ new Case(Id = parentCase.Id, Status = 'Closed') };
        NorlysNowService norlysNowServiceStub = NorlysTestMocks.forNorlysNowService()
            .withCloseParentCases(casesToClose)
            .build();

        Map<Id, NorlysNow_Case__c> queriedCases = new Map<Id, NorlysNow_Case__c>{ norlysNowCase.Id => norlysNowCase };
        NorlysNowSelector norlysNowSelectorStub = NorlysTestMocks.forNorlysNowSelector()
            .withNorlysNowCases(queriedCases)
            .build();

        DatabaseService dbServiceMock = new DatabaseService().mockDmls();

        PermissionService permissionServiceStub = NorlysTestMocks.forPermissionService()
            .withHasPermissionSet(false)
            .build();

        // Instantiate the handler
        NorlysNowCaseTriggerHandler handler = new NorlysNowCaseTriggerHandler(
            norlysNowServiceStub,
            norlysNowSelectorStub,
            dbServiceMock,
            permissionServiceStub,
            NorlysTestMocks.forEventExecutorService().build()
        );

        // Set trigger context
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
        Assert.areEqual(1, dbServiceMock.register.updated.size(), 'One record should be updated.');
        Case updatedCase = (Case)dbServiceMock.register.updated[0];
        Assert.areEqual(parentCase.Id, updatedCase.Id, 'The correct case should be updated.');
        Assert.areEqual('Closed', updatedCase.Status, 'The case status should be Closed.');
    }

    @isTest
    static void beforeUpdate_ParentCaseIsClosed_ErrorIsAdded() {
        // Arrange
        Id parentCaseId = Test.getFakeId(Case.SObjectType);
        NorlysNow_Case__c norlysNowCase = new NorlysNow_Case__c(
            Id = Test.getFakeId(NorlysNow_Case__c.SObjectType),
            Parent_Case__c = parentCaseId
        );

        NorlysNowSelector norlysNowSelectorStub = NorlysTestMocks.forNorlysNowSelector()
            .withClosedParentCase(parentCaseId)
            .build();

        NorlysNowService norlysNowService = new NorlysNowService(norlysNowSelectorStub);

        NorlysNowCaseTriggerHandler handler = new NorlysNowCaseTriggerHandler(
            norlysNowService, null, null, null, null
        );

        handler.triggerNew = new List<NorlysNow_Case__c>{ norlysNowCase };

        // Act
        Test.startTest();
        handler.beforeUpdate();
        Test.stopTest();

        // Assert
        Assert.isTrue(norlysNowCase.hasErrors(), 'An error should be added.');
        Assert.areEqual('You are not allowed to create or update NorlysNow Cases on a closed Case', norlysNowCase.getErrors()[0].getMessage(), 'The error message should be correct.');
    }

    @isTest
    static void beforeInsert_ParentCaseIsClosed_ErrorIsAdded() {
        // Arrange
        Id parentCaseId = Test.getFakeId(Case.SObjectType);
        NorlysNow_Case__c norlysNowCase = new NorlysNow_Case__c(
            Parent_Case__c = parentCaseId
        );

        NorlysNowSelector norlysNowSelectorStub = NorlysTestMocks.forNorlysNowSelector()
            .withClosedParentCase(parentCaseId)
            .build();

        NorlysNowService norlysNowService = new NorlysNowService(norlysNowSelectorStub);

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

    @isTest
    static void afterInsert_WithPermission_EventIsPublished() {
        // Arrange
        User testUser = createTestUserWithPermissionSet();

        System.runAs(testUser) {
            Case parentCase = new Case(Subject = 'Test Parent Case', Status = 'New');
            insert parentCase;
            NorlysNow_Case__c norlysNowCase = new NorlysNow_Case__c(Parent_Case__c = parentCase.Id, Status__c = 'New');
            insert norlysNowCase;

            NorlysNowSelector norlysNowSelectorStub = NorlysTestMocks.forNorlysNowSelector()
                .withNorlysNowCases(new Map<Id, NorlysNow_Case__c>{ norlysNowCase.Id => norlysNowCase })
                .build();

            List<EventExecutor__e> eventsToPublish = new List<EventExecutor__e>{ new EventExecutor__e(Executor__c = 'NorlysNowExecutorHandler') };
            NorlysNowService norlysNowServiceStub = NorlysTestMocks.forNorlysNowService()
                .withChunkedEvents(eventsToPublish)
                .build();

            NorlysTestMocks.EventExecutorServiceMockBuilder eventExecutorBuilder = NorlysTestMocks.forEventExecutorService().withPublish();
            EventExecutorService eventExecutorServiceStub = eventExecutorBuilder.build();

            NorlysNowCaseTriggerHandler handler = new NorlysNowCaseTriggerHandler(
                norlysNowServiceStub,
                norlysNowSelectorStub,
                new DatabaseService(),
                new PermissionService(),
                eventExecutorServiceStub
            );

            handler.triggerNewMap = new Map<Id, NorlysNow_Case__c>{ norlysNowCase.Id => norlysNowCase };
            handler.triggerNew = new List<NorlysNow_Case__c>{ norlysNowCase };

            // Act
            Test.startTest();
            handler.afterInsert();
            Test.stopTest();

            // Assert
            MethodSpy publishSpy = eventExecutorBuilder.getPublishSpy();
            Assert.isFalse(publishSpy.callLog.isEmpty(), 'publish should have been called.');
            Assert.areEqual(1, publishSpy.callLog.size(), 'publish should have been called once.');
        }
    }

    @isTest
    static void afterInsert_WithoutPermission_EventIsNotPublished() {
        // Arrange
        Case parentCase = new Case(Subject = 'Test Parent Case', Status = 'New');
        insert parentCase;
        NorlysNow_Case__c norlysNowCase = new NorlysNow_Case__c(Parent_Case__c = parentCase.Id, Status__c = 'New');
        insert norlysNowCase;

        NorlysNowSelector norlysNowSelectorStub = NorlysTestMocks.forNorlysNowSelector()
            .withNorlysNowCases(new Map<Id, NorlysNow_Case__c>{ norlysNowCase.Id => norlysNowCase })
            .build();

        NorlysTestMocks.EventExecutorServiceMockBuilder eventExecutorBuilder = NorlysTestMocks.forEventExecutorService().withPublish();
        EventExecutorService eventExecutorServiceStub = eventExecutorBuilder.build();

        NorlysNowCaseTriggerHandler handler = new NorlysNowCaseTriggerHandler(
            new NorlysNowService(),
            norlysNowSelectorStub,
            new DatabaseService(),
            new PermissionService(),
            eventExecutorServiceStub
        );

        handler.triggerNewMap = new Map<Id, NorlysNow_Case__c>{ norlysNowCase.Id => norlysNowCase };
        handler.triggerNew = new List<NorlysNow_Case__c>{ norlysNowCase };

        // Act
        Test.startTest();
        handler.afterInsert();
        Test.stopTest();

        // Assert
        MethodSpy publishSpy = eventExecutorBuilder.getPublishSpy();
        Assert.isTrue(publishSpy.callLog.isEmpty(), 'publish should not have been called.');
    }

    @isTest
    static void afterUpdate_StatusWithdrawnWithPermission_EventIsPublished() {
        // Arrange
        User testUser = createTestUserWithPermissionSet();

        System.runAs(testUser) {
            Case parentCase = new Case(Subject = 'Test Parent Case', Status = 'New');
            insert parentCase;
            NorlysNow_Case__c norlysNowCase = new NorlysNow_Case__c(Parent_Case__c = parentCase.Id, Status__c = 'In Progress');
            insert norlysNowCase;

            NorlysNow_Case__c oldNorlysNowCase = norlysNowCase.clone();

            NorlysNowSelector norlysNowSelectorStub = NorlysTestMocks.forNorlysNowSelector()
                .withNorlysNowCases(new Map<Id, NorlysNow_Case__c>{ norlysNowCase.Id => norlysNowCase })
                .build();

            List<EventExecutor__e> eventsToPublish = new List<EventExecutor__e>{ new EventExecutor__e(Executor__c = 'NorlysNowExecutorHandler') };
            NorlysNowService norlysNowServiceStub = NorlysTestMocks.forNorlysNowService()
                .withCloseParentCases(new List<Case>())
                .withChunkedEvents(eventsToPublish)
                .build();

            NorlysTestMocks.EventExecutorServiceMockBuilder eventExecutorBuilder = NorlysTestMocks.forEventExecutorService().withPublish();
            EventExecutorService eventExecutorServiceStub = eventExecutorBuilder.build();

            NorlysNowCaseTriggerHandler handler = new NorlysNowCaseTriggerHandler(
                norlysNowServiceStub,
                norlysNowSelectorStub,
                new DatabaseService().mockDmls(),
                new PermissionService(),
                eventExecutorServiceStub
            );

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
            MethodSpy publishSpy = eventExecutorBuilder.getPublishSpy();
            Assert.isFalse(publishSpy.callLog.isEmpty(), 'publish should have been called.');
        }
    }

    @isTest
    static void afterUpdate_SyncStatusPendingWithPermission_EventIsPublished() {
        // Arrange
        User testUser = createTestUserWithPermissionSet();

        System.runAs(testUser) {
            Case parentCase = new Case(Subject = 'Test Parent Case', Status = 'New');
            insert parentCase;
            NorlysNow_Case__c norlysNowCase = new NorlysNow_Case__c(Parent_Case__c = parentCase.Id, Sync_Status__c = 'Success');
            insert norlysNowCase;
            NorlysNow_Case__c oldNorlysNowCase = norlysNowCase.clone();

            NorlysNowSelector norlysNowSelectorStub = NorlysTestMocks.forNorlysNowSelector()
                .withNorlysNowCases(new Map<Id, NorlysNow_Case__c>{ norlysNowCase.Id => norlysNowCase })
                .build();

            List<EventExecutor__e> eventsToPublish = new List<EventExecutor__e>{ new EventExecutor__e(Executor__c = 'NorlysNowExecutorHandler') };
            NorlysNowService norlysNowServiceStub = NorlysTestMocks.forNorlysNowService()
                .withCloseParentCases(new List<Case>())
                .withChunkedEvents(eventsToPublish)
                .build();

            NorlysTestMocks.EventExecutorServiceMockBuilder eventExecutorBuilder = NorlysTestMocks.forEventExecutorService().withPublish();
            EventExecutorService eventExecutorServiceStub = eventExecutorBuilder.build();

            NorlysNowCaseTriggerHandler handler = new NorlysNowCaseTriggerHandler(
                norlysNowServiceStub,
                norlysNowSelectorStub,
                new DatabaseService().mockDmls(),
                new PermissionService(),
                eventExecutorServiceStub
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
            MethodSpy publishSpy = eventExecutorBuilder.getPublishSpy();
            Assert.isFalse(publishSpy.callLog.isEmpty(), 'publish should have been called.');
        }
    }
}
