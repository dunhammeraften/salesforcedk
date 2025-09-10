/**
 * @description Test class for NorlysNowCaseTriggerHandler.
 * This class tests the trigger handler logic for NorlysNow_Case__c objects.
 */
@isTest
private class NorlysNowCaseTriggerHandlerTest {
    private class TestSetup {
        public Case parentCase = new Case(Subject = 'Test Parent Case', Status = 'New');
        public NorlysNow_Case__c norlysNowCase = new NorlysNow_Case__c(Status__c = 'In Progress');
        public User testUser;

        public TestSetup() {
            insert parentCase;
            norlysNowCase.Parent_Case__c = parentCase.Id;
            insert norlysNowCase;
        }

        public User createTestUserWithPermissionSet() {
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

            PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'Customer_Support_Technical_NorlysNow_Requester'];
            insert new PermissionSetAssignment(AssigneeId = u.Id, PermissionSetId = ps.Id);

            this.testUser = u;
            return u;
        }
    }

    @isTest
    static void afterUpdate_LastChildCaseClosed_ParentCaseIsClosed() {
        TestSetup testSetup = new TestSetup();
        NorlysNow_Case__c oldNorlysNowCase = testSetup.norlysNowCase.clone();

        List<Case> casesToClose = new List<Case>{ new Case(Id = testSetup.parentCase.Id, Status = 'Closed') };
        NorlysNowService norlysNowServiceStub = NorlysTestMocks.forNorlysNowService()
            .withCloseParentCases(casesToClose)
            .build();

        Map<Id, NorlysNow_Case__c> queriedCases = new Map<Id, NorlysNow_Case__c>{ testSetup.norlysNowCase.Id => testSetup.norlysNowCase };
        NorlysNowSelector norlysNowSelectorStub = NorlysTestMocks.forNorlysNowSelector()
            .withNorlysNowCases(queriedCases)
            .build();

        DatabaseService dbServiceMock = new DatabaseService().mockDmls();
        PermissionService permissionServiceStub = NorlysTestMocks.forPermissionService().withHasPermissionSet(false).build();

        NorlysNowCaseTriggerHandler handler = new NorlysNowCaseTriggerHandler(
            norlysNowServiceStub, norlysNowSelectorStub, dbServiceMock, permissionServiceStub, NorlysTestMocks.forEventExecutorService().build()
        );

        testSetup.norlysNowCase.Status__c = 'Closed';
        handler.triggerNewMap = new Map<Id, NorlysNow_Case__c>{ testSetup.norlysNowCase.Id => testSetup.norlysNowCase };
        handler.triggerOldMap = new Map<Id, NorlysNow_Case__c>{ oldNorlysNowCase.Id => oldNorlysNowCase };
        handler.triggerNew = new List<NorlysNow_Case__c>{ testSetup.norlysNowCase };
        handler.triggerOld = new List<NorlysNow_Case__c>{ oldNorlysNowCase };

        Test.startTest();
        handler.afterUpdate();
        Test.stopTest();

        Assert.areEqual(1, dbServiceMock.register.updated.size(), 'One record should be updated.');
        Case updatedCase = (Case)dbServiceMock.register.updated[0];
        Assert.areEqual(testSetup.parentCase.Id, updatedCase.Id, 'The correct case should be updated.');
        Assert.areEqual('Closed', updatedCase.Status, 'The case status should be Closed.');
    }

    @isTest
    static void beforeUpdate_ParentCaseIsClosed_ErrorIsAdded() {
        Id parentCaseId = DatabaseService.getFakeId(Case.SObjectType);
        NorlysNow_Case__c norlysNowCase = new NorlysNow_Case__c(
            Id = DatabaseService.getFakeId(NorlysNow_Case__c.SObjectType), Parent_Case__c = parentCaseId
        );

        NorlysNowSelector norlysNowSelectorStub = NorlysTestMocks.forNorlysNowSelector().withClosedParentCase(parentCaseId).build();
        NorlysNowService norlysNowServiceStub = NorlysTestMocks.forNorlysNowService().build();

        NorlysNowCaseTriggerHandler handler = new NorlysNowCaseTriggerHandler(
            norlysNowServiceStub, norlysNowSelectorStub, null, null, null
        );
        handler.triggerNew = new List<NorlysNow_Case__c>{ norlysNowCase };

        Test.startTest();
        handler.beforeUpdate();
        Test.stopTest();

        Assert.isTrue(norlysNowCase.hasErrors(), 'An error should be added.');
        Assert.areEqual('You are not allowed to create or update NorlysNow Cases on a closed Case', norlysNowCase.getErrors()[0].getMessage(), 'The error message should be correct.');
    }

    @isTest
    static void beforeInsert_ParentCaseIsClosed_ErrorIsAdded() {
        Id parentCaseId = DatabaseService.getFakeId(Case.SObjectType);
        NorlysNow_Case__c norlysNowCase = new NorlysNow_Case__c(Parent_Case__c = parentCaseId);

        NorlysNowSelector norlysNowSelectorStub = NorlysTestMocks.forNorlysNowSelector().withClosedParentCase(parentCaseId).build();
        NorlysNowService norlysNowServiceStub = NorlysTestMocks.forNorlysNowService().build();

        NorlysNowCaseTriggerHandler handler = new NorlysNowCaseTriggerHandler(
            norlysNowServiceStub, norlysNowSelectorStub, null, null, null
        );
        handler.triggerNew = new List<NorlysNow_Case__c>{ norlysNowCase };

        Test.startTest();
        handler.beforeInsert();
        Test.stopTest();

        Assert.isTrue(norlysNowCase.hasErrors(), 'An error should be added.');
        Assert.areEqual('You are not allowed to create or update NorlysNow Cases on a closed Case', norlysNowCase.getErrors()[0].getMessage(), 'The error message should be correct.');
    }

    @isTest
    static void afterInsert_WithPermission_EventIsPublished() {
        TestSetup testSetup = new TestSetup();
        System.runAs(testSetup.createTestUserWithPermissionSet()) {
            NorlysNowSelector norlysNowSelectorStub = NorlysTestMocks.forNorlysNowSelector()
                .withNorlysNowCases(new Map<Id, NorlysNow_Case__c>{ testSetup.norlysNowCase.Id => testSetup.norlysNowCase })
                .build();
            List<EventExecutor__e> eventsToPublish = new List<EventExecutor__e>{ new EventExecutor__e(Executor__c = 'NorlysNowExecutorHandler') };
            NorlysNowService norlysNowServiceStub = NorlysTestMocks.forNorlysNowService().withChunkedEvents(eventsToPublish).build();
            NorlysTestMocks.EventExecutorServiceMockBuilder eventExecutorBuilder = NorlysTestMocks.forEventExecutorService().withPublish();
            EventExecutorService eventExecutorServiceStub = eventExecutorBuilder.build();
            PermissionService permissionServiceStub = NorlysTestMocks.forPermissionService().withHasPermissionSet(true).build();

            NorlysNowCaseTriggerHandler handler = new NorlysNowCaseTriggerHandler(
                norlysNowServiceStub, norlysNowSelectorStub, new DatabaseService(), permissionServiceStub, eventExecutorServiceStub
            );
            handler.triggerNewMap = new Map<Id, NorlysNow_Case__c>{ testSetup.norlysNowCase.Id => testSetup.norlysNowCase };
            handler.triggerNew = new List<NorlysNow_Case__c>{ testSetup.norlysNowCase };

            Test.setMock(HttpCalloutMock.class, new NorlysNowClientMock());
            Test.startTest();
            handler.afterInsert();
            Test.stopTest();

            MethodSpy publishSpy = eventExecutorBuilder.getPublishSpy();
            Assert.isFalse(publishSpy.callLog.isEmpty(), 'publish should have been called.');
            Assert.areEqual(1, publishSpy.callLog.size(), 'publish should have been called once.');
        }
    }

    @isTest
    static void afterInsert_WithoutPermission_EventIsNotPublished() {
        TestSetup testSetup = new TestSetup();
        NorlysNowSelector norlysNowSelectorStub = NorlysTestMocks.forNorlysNowSelector()
            .withNorlysNowCases(new Map<Id, NorlysNow_Case__c>{ testSetup.norlysNowCase.Id => testSetup.norlysNowCase })
            .build();
        NorlysTestMocks.EventExecutorServiceMockBuilder eventExecutorBuilder = NorlysTestMocks.forEventExecutorService().withPublish();
        EventExecutorService eventExecutorServiceStub = eventExecutorBuilder.build();

        NorlysNowCaseTriggerHandler handler = new NorlysNowCaseTriggerHandler(
            NorlysTestMocks.forNorlysNowService().build(),
            norlysNowSelectorStub,
            new DatabaseService(),
            new PermissionService(),
            eventExecutorServiceStub
        );
        handler.triggerNewMap = new Map<Id, NorlysNow_Case__c>{ testSetup.norlysNowCase.Id => testSetup.norlysNowCase };
        handler.triggerNew = new List<NorlysNow_Case__c>{ testSetup.norlysNowCase };

        Test.startTest();
        handler.afterInsert();
        Test.stopTest();

        MethodSpy publishSpy = eventExecutorBuilder.getPublishSpy();
        Assert.isTrue(publishSpy.callLog.isEmpty(), 'publish should not have been called.');
    }

    @isTest
    static void afterInsert_WithoutPermission_DoesNotPublishEvent() {
        TestSetup testSetup = new TestSetup();

        NorlysNowSelector norlysNowSelectorStub = NorlysTestMocks.forNorlysNowSelector()
            .withNorlysNowCases(new Map<Id, NorlysNow_Case__c>{ testSetup.norlysNowCase.Id => testSetup.norlysNowCase })
            .build();
        NorlysTestMocks.EventExecutorServiceMockBuilder eventExecutorBuilder = NorlysTestMocks.forEventExecutorService().withPublish();
        EventExecutorService eventExecutorServiceStub = eventExecutorBuilder.build();
        PermissionService permissionServiceStub = NorlysTestMocks.forPermissionService().withHasPermissionSet(false).build();

        NorlysNowCaseTriggerHandler handler = new NorlysNowCaseTriggerHandler(
            NorlysTestMocks.forNorlysNowService().build(),
            norlysNowSelectorStub,
            new DatabaseService(),
            permissionServiceStub,
            eventExecutorServiceStub
        );
        handler.triggerNewMap = new Map<Id, NorlysNow_Case__c>{ testSetup.norlysNowCase.Id => testSetup.norlysNowCase };
        handler.triggerNew = new List<NorlysNow_Case__c>{ testSetup.norlysNowCase };

        Test.startTest();
        handler.afterInsert();
        Test.stopTest();

        MethodSpy publishSpy = eventExecutorBuilder.getPublishSpy();
        Assert.isTrue(publishSpy.callLog.isEmpty(), 'The event should not be published without the required permission.');
    }

    @isTest
    static void afterUpdate_StatusWithdrawnWithPermission_EventIsPublished() {
        TestSetup testSetup = new TestSetup();
        System.runAs(testSetup.createTestUserWithPermissionSet()) {
            NorlysNow_Case__c oldNorlysNowCase = testSetup.norlysNowCase.clone();
            NorlysNowSelector norlysNowSelectorStub = NorlysTestMocks.forNorlysNowSelector()
                .withNorlysNowCases(new Map<Id, NorlysNow_Case__c>{ testSetup.norlysNowCase.Id => testSetup.norlysNowCase })
                .build();
            List<EventExecutor__e> eventsToPublish = new List<EventExecutor__e>{ new EventExecutor__e(Executor__c = 'NorlysNowExecutorHandler') };
            NorlysNowService norlysNowServiceStub = NorlysTestMocks.forNorlysNowService()
                .withCloseParentCases(new List<Case>())
                .withChunkedEvents(eventsToPublish)
                .build();
            NorlysTestMocks.EventExecutorServiceMockBuilder eventExecutorBuilder = NorlysTestMocks.forEventExecutorService().withPublish();
            EventExecutorService eventExecutorServiceStub = eventExecutorBuilder.build();
            PermissionService permissionServiceStub = NorlysTestMocks.forPermissionService().withHasPermissionSet(true).build();

            NorlysNowCaseTriggerHandler handler = new NorlysNowCaseTriggerHandler(
                norlysNowServiceStub,
                norlysNowSelectorStub,
                new DatabaseService().mockDmls(),
                permissionServiceStub,
                eventExecutorServiceStub
            );

            testSetup.norlysNowCase.Status__c = 'Withdrawn';
            handler.triggerNewMap = new Map<Id, NorlysNow_Case__c>{ testSetup.norlysNowCase.Id => testSetup.norlysNowCase };
            handler.triggerOldMap = new Map<Id, NorlysNow_Case__c>{ oldNorlysNowCase.Id => oldNorlysNowCase };
            handler.triggerNew = new List<NorlysNow_Case__c>{ testSetup.norlysNowCase };
            handler.triggerOld = new List<NorlysNow_Case__c>{ oldNorlysNowCase };

            Test.setMock(HttpCalloutMock.class, new NorlysNowClientMock());
            Test.startTest();
            handler.afterUpdate();
            Test.stopTest();

            MethodSpy publishSpy = eventExecutorBuilder.getPublishSpy();
            Assert.isFalse(publishSpy.callLog.isEmpty(), 'publish should have been called.');
        }
    }

    @isTest
    static void afterUpdate_SyncStatusPendingWithPermission_EventIsPublished() {
        TestSetup testSetup = new TestSetup();
        System.runAs(testSetup.createTestUserWithPermissionSet()) {
            testSetup.norlysNowCase.Sync_Status__c = 'Success';
            update testSetup.norlysNowCase;
            NorlysNow_Case__c oldNorlysNowCase = testSetup.norlysNowCase.clone();

            NorlysNowSelector norlysNowSelectorStub = NorlysTestMocks.forNorlysNowSelector()
                .withNorlysNowCases(new Map<Id, NorlysNow_Case__c>{ testSetup.norlysNowCase.Id => testSetup.norlysNowCase })
                .build();
            List<EventExecutor__e> eventsToPublish = new List<EventExecutor__e>{ new EventExecutor__e(Executor__c = 'NorlysNowExecutorHandler') };
            NorlysNowService norlysNowServiceStub = NorlysTestMocks.forNorlysNowService()
                .withCloseParentCases(new List<Case>())
                .withChunkedEvents(eventsToPublish)
                .build();
            NorlysTestMocks.EventExecutorServiceMockBuilder eventExecutorBuilder = NorlysTestMocks.forEventExecutorService().withPublish();
            EventExecutorService eventExecutorServiceStub = eventExecutorBuilder.build();
            PermissionService permissionServiceStub = NorlysTestMocks.forPermissionService().withHasPermissionSet(true).build();

            NorlysNowCaseTriggerHandler handler = new NorlysNowCaseTriggerHandler(
                norlysNowServiceStub,
                norlysNowSelectorStub,
                new DatabaseService().mockDmls(),
                permissionServiceStub,
                eventExecutorServiceStub
            );

            testSetup.norlysNowCase.Sync_Status__c = 'Pending';
            handler.triggerNewMap = new Map<Id, NorlysNow_Case__c>{ testSetup.norlysNowCase.Id => testSetup.norlysNowCase };
            handler.triggerOldMap = new Map<Id, NorlysNow_Case__c>{ oldNorlysNowCase.Id => oldNorlysNowCase };
            handler.triggerNew = new List<NorlysNow_Case__c>{ testSetup.norlysNowCase };
            handler.triggerOld = new List<NorlysNow_Case__c>{ oldNorlysNowCase };

            Test.setMock(HttpCalloutMock.class, new NorlysNowClientMock());
            Test.startTest();
            handler.afterUpdate();
            Test.stopTest();

            MethodSpy publishSpy = eventExecutorBuilder.getPublishSpy();
            Assert.isFalse(publishSpy.callLog.isEmpty(), 'publish should have been called.');
        }
    }
}
