@isTest
private class NorlysNowExecutorHandlerTest {
    /*
    
    private static User createTestUser() {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Telia Enterprise Customer Service' LIMIT 1];
        User u = new User(
            Alias = 'testusr',
            Email = 'testuser@example.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Test',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = p.Id,
            TimeZoneSidKey = 'Europe/Copenhagen',
            UserName = 'testuser' + System.currentTimeMillis() + '@example.com'
        );
        insert u;
        return u;
    }

    @isTest
    static void testCreateNorlysNowCaseSuccess() {
        User u = createTestUser();

        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'Customer_Support_Technical_NorlysNow_Requester' LIMIT 1];
        insert new PermissionSetAssignment(
            AssigneeId = u.Id,
            PermissionSetId = ps.Id
        );

        System.runAs(u) {
            // Create test data inside runAs to avoid mixed DML errors
            Account acc = TDF_AccountUtils.createAccountWithCVR('12345678');
            insert acc;

            Case testCase = TDF_CaseUtils.createCustomerServiceCasesForAccounts(new List<Account>{acc})[0];

            NorlysNow_Case__c testNorlysNowCase = new NorlysNow_Case__c(Parent_Case__c = testCase.Id, Status__c = 'New');
            insert testNorlysNowCase;

            Set<Id> norlysNowCaseIds = new Set<Id>{testNorlysNowCase.Id};
            NorlysNowStrategyService.Parameters params = new NorlysNowStrategyService.Parameters();
            params.type = 'NorlysNow_Case__c';
            params.recordIds = norlysNowCaseIds;
            String paramsJson = JSON.serialize(params);

            EventExecutor__e event = new EventExecutor__e(
                Parameters__c = paramsJson,
                RetryCount__c = 5
            );

            // Mock NorlysNowClient and response
            HttpResponseMock mock = new HttpResponseMock(200, 'OK', '{"created record number":"12345678"}', new Map<String, String>());
		    Test.setMock(HttpCalloutMock.class, mock);

            Test.startTest();
            NorlysNowExecutorHandler handler = new NorlysNowExecutorHandler();
            handler.execute(event);
            Test.stopTest();

            NorlysNow_Case__c updatedCase = [SELECT Sync_Status__c FROM NorlysNow_Case__c WHERE Id = :testNorlysNowCase.Id];
            System.assertEquals('Success', updatedCase.Sync_Status__c);
        }
    }

    @isTest
    static void testCreateNorlysNowCaseError() {
        User u = createTestUser();
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'Customer_Support_Technical_NorlysNow_Requester' LIMIT 1];
        insert new PermissionSetAssignment(
            AssigneeId = u.Id,
            PermissionSetId = ps.Id
        );

        System.runAs(u) {
            // Create test data inside runAs to avoid mixed DML errors
            Account acc = TDF_AccountUtils.createAccountWithCVR('12345678');
            insert acc;

            Case testCase = TDF_CaseUtils.createCustomerServiceCasesForAccounts(new List<Account>{acc})[0];

            NorlysNow_Case__c testNorlysNowCase = new NorlysNow_Case__c(Parent_Case__c = testCase.Id, Status__c = 'New');
            insert testNorlysNowCase;

            Set<Id> norlysNowCaseIds = new Set<Id>{testNorlysNowCase.Id};
            NorlysNowStrategyService.Parameters params = new NorlysNowStrategyService.Parameters();
            params.type = 'NorlysNow_Case__c';
            params.recordIds = norlysNowCaseIds;
            String paramsJson = JSON.serialize(params);

            EventExecutor__e event = new EventExecutor__e(
                Parameters__c = paramsJson,
                RetryCount__c = 5
            );
            
            // Mock NorlysNowClient
            Mock norlysNowClientMock = Mock.forType(NorlysNowClient.class);
            MethodSpy sentRequestNorlysNowCase = norlysNowClientMock.spyOn('sentRequestNorlysNowCase');
            sentRequestNorlysNowCase.throwsException(new HTTPException('500 server down', 500, '500'));
            NorlysNowClient norlysNowClient = (NorlysNowClient) norlysNowClientMock.stub;
            DatabaseService dbMock = new DatabaseService().mockDMLs();
            NorlysNowStrategyService norlysNowStrategyService = new NorlysNowStrategyService();

            NorlysNowCaseStrategy strategy = new NorlysNowCaseStrategy(norlysNowClient, dbMock, norlysNowStrategyService);
            strategy.toExecute(event);

            Assert.areEqual(
                'Error',
                ((NorlysNow_Case__c) dbMock.register.updated[0]).Status__c,
                'We have set error'
            );
        }
    }

    @isTest
    static void testWithdrawnNorlysNowCaseSuccess() {
        User u = createTestUser();

        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'Customer_Support_Technical_NorlysNow_Requester' LIMIT 1];
        insert new PermissionSetAssignment(
            AssigneeId = u.Id,
            PermissionSetId = ps.Id
        );

        System.runAs(u) {
            // Create test data inside runAs to avoid mixed DML errors
            Account acc = TDF_AccountUtils.createAccountWithCVR('12345678');
            insert acc;

            Case testCase = TDF_CaseUtils.createCustomerServiceCasesForAccounts(new List<Account>{acc})[0];

            NorlysNow_Case__c testNorlysNowCase = new NorlysNow_Case__c(Parent_Case__c = testCase.Id, Status__c = 'New');
            insert testNorlysNowCase;

            testNorlysNowCase.Status__c = 'Withdrawn';
            update testNorlysNowCase;

            Set<Id> norlysNowCaseIds = new Set<Id>{testNorlysNowCase.Id};
            NorlysNowStrategyService.Parameters params = new NorlysNowStrategyService.Parameters();
            params.type = 'NorlysNow_Case__c';
            params.recordIds = norlysNowCaseIds;
            String paramsJson = JSON.serialize(params);

            EventExecutor__e event = new EventExecutor__e(
                Parameters__c = paramsJson
            );

            // Mock NorlysNowClient and response
            HttpResponseMock mock = new HttpResponseMock(200, 'OK', '{"created record number":"12345678"}', new Map<String, String>());
		    Test.setMock(HttpCalloutMock.class, mock);

            Test.startTest();
            NorlysNowExecutorHandler handler = new NorlysNowExecutorHandler();
            handler.execute(event);
            Test.stopTest();

            NorlysNow_Case__c updatedCase = [SELECT Sync_Status__c FROM NorlysNow_Case__c WHERE Id = :testNorlysNowCase.Id];
            System.assertEquals('Success', updatedCase.Sync_Status__c);
        }
    }

    //FeedComment tests

    @isTest
    static void testCreateNorlysNowCaseCommentSuccess() {
        User u = createTestUser();

        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'Customer_Support_Technical_NorlysNow_Requester' LIMIT 1];
        insert new PermissionSetAssignment(
            AssigneeId = u.Id,
            PermissionSetId = ps.Id
        );

        System.runAs(u) {
            // Create test data inside runAs to avoid mixed DML errors
            Account acc = TDF_AccountUtils.createAccountWithCVR('12345678');
            insert acc;

            Case testCase = TDF_CaseUtils.createCustomerServiceCasesForAccounts(new List<Account>{acc})[0];

            NorlysNow_Case__c testNorlysNowCase = new NorlysNow_Case__c(Parent_Case__c = testCase.Id);
            insert testNorlysNowCase;

            FeedItem post = new FeedItem();
            post.ParentId = testNorlysNowCase.Id;
            post.Body = 'Initial Case Post';
            post.Type = 'TextPost';
            insert post;

            FeedComment fc = new FeedComment();
            fc.FeedItemId = post.Id;
            fc.CommentBody = 'This is a comment on the case feed';
            insert fc;

            Set<Id> feedCommentIds = new Set<Id>{fc.Id};
            NorlysNowStrategyService.Parameters params = new NorlysNowStrategyService.Parameters();
            params.type = 'FeedComment';
            params.recordIds = feedCommentIds;
            params.feedItemIds = new Set<Id>{post.Id};
            String paramsJson = JSON.serialize(params);

            EventExecutor__e event = new EventExecutor__e(
                Parameters__c = paramsJson
            );

            // Set mock for HTTP callouts
            HttpResponseMock mock = new HttpResponseMock(200, 'OK', '{"created record number":"12345678"}', new Map<String, String>());
            Test.setMock(HttpCalloutMock.class, mock);
            
            Test.startTest();
                NorlysNowExecutorHandler handler = new NorlysNowExecutorHandler();
                handler.execute(event);
            Test.stopTest();

            NorlysNow_Case__c updatedCase = [SELECT Sync_Status__c FROM NorlysNow_Case__c WHERE Id = :testNorlysNowCase.Id];
            System.assertEquals('Success', updatedCase.Sync_Status__c);
        }
    }

    @isTest
    static void testCreateNorlysNowFeedCommentError() {
        User u = createTestUser();
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'Customer_Support_Technical_NorlysNow_Requester' LIMIT 1];
        insert new PermissionSetAssignment(
            AssigneeId = u.Id,
            PermissionSetId = ps.Id
        );

        System.runAs(u) {
            // Create test data inside runAs to avoid mixed DML errors
            Account acc = TDF_AccountUtils.createAccountWithCVR('12345678');
            insert acc;

            Case testCase = TDF_CaseUtils.createCustomerServiceCasesForAccounts(new List<Account>{acc})[0];

            NorlysNow_Case__c testNorlysNowCase = new NorlysNow_Case__c(Parent_Case__c = testCase.Id);
            insert testNorlysNowCase;

            FeedItem post = new FeedItem();
            post.ParentId = testNorlysNowCase.Id;
            post.Body = 'Initial Case Post';
            post.Type = 'TextPost';
            insert post;

            FeedComment fc = new FeedComment();
            fc.FeedItemId = post.Id;
            fc.CommentBody = 'This is a comment on the case feed';
            insert fc;

            Set<Id> feedCommentIds = new Set<Id>{fc.Id};
            NorlysNowStrategyService.Parameters params = new NorlysNowStrategyService.Parameters();
            params.type = 'FeedComment';
            params.feedItemIds = new Set<Id>{post.Id};
            params.recordIds = feedCommentIds;
            String paramsJson = JSON.serialize(params);

            EventExecutor__e event = new EventExecutor__e(
                Parameters__c = paramsJson,
                RetryCount__c = 5
            );

            // Mock NorlysNowClient
            Mock norlysNowClientMock = Mock.forType(NorlysNowClient.class);
            MethodSpy createFeedCommentPlatformEvent = norlysNowClientMock.spyOn('sentRequestNorlysNowCase');
            createFeedCommentPlatformEvent.throwsException(new HTTPException('500 server down', 500, '500'));
            NorlysNowClient norlysNowClient = (NorlysNowClient) norlysNowClientMock.stub;
            DatabaseService dbMock = new DatabaseService().mockDMLs();
            NorlysNowStrategyService norlysNowStrategyService = new NorlysNowStrategyService();

            NorlysNowFeedCommentStrategy strategy = new NorlysNowFeedCommentStrategy(norlysNowClient, dbMock, norlysNowStrategyService);
            strategy.toExecute(event);

            Assert.areEqual(
                'Error',
                ((NorlysNow_Case__c) dbMock.register.updated[0]).Sync_Status__c,
                'We have set error'
            );
        }
    }
        */
}