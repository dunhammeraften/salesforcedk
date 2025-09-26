/**
 * @description Test class for NorlysNowService.
 *              This class tests the business logic contained within the NorlysNowService,
 *              ensuring that request objects are created correctly, case statuses are managed properly,
 *              and other service methods behave as expected.
 * @see NorlysNowService
 *
 * -----------------------------------------------------------------------------
 * @author Developer           Date            Description
 * -----------------------------------------------------------------------------
 * @author Esben Hovgaard        18/09/2025      Added changeLine to documentation
 * -----------------------------------------------------------------------------
 */
@isTest
private class NorlysNowServiceTest {
	private static Mock norlysNowSelectorMock;
	private static DatabaseService dbMock;

	/**
	 * @description Sets up the mock environment for each test method.
	 *              This ensures a consistent and predictable state for all tests by
	 *              mocking the service's dependencies.
	 */
	private static void setupMocks() {
		// Create a mock for the selector dependency
		norlysNowSelectorMock = Mock.forType(NorlysNowSelector.class);

		// Mock the DatabaseService to prevent actual DML operations
		dbMock = new DatabaseService().mockDmls();

		// Register the mocks with the SingletonFactory so they can be used by other services if needed
		SingletonFactory factory = SingletonFactory.getFactory();
		factory.registerSingleton(NorlysNowSelector.class, (NorlysNowSelector) norlysNowSelectorMock.stub);
		factory.registerSingleton(DatabaseService.class, dbMock);
	}

	@isTest
	static void createCaseCommentRequestObject_ShouldReturnCorrectDTO() {
		// Arrange
		setupMocks();
		NorlysNowService service = new NorlysNowService();
		String correlationId = 'test-corr-id';
		String externalAction = 'CREATE';
		String externalReference = 'ref-123';
		String messageType = 'CaseComment';
		String integrationMode = 'Async';
		String integrationPartner = 'PartnerA';
		String salesforceId = '5003N000002W9p6QAC';
		String commentBody = 'This is a test comment.';

		// Act
		NorlysNowClientRequestDTO result = service.createCaseCommentRequestObject(
			correlationId,
			externalAction,
			externalReference,
			messageType,
			integrationMode,
			integrationPartner,
			salesforceId,
			commentBody
		);

		// Assert
		System.assertEquals(correlationId, result.correlation_id, 'Correlation ID should be set correctly.');
		System.assertEquals(externalAction, result.external_action, 'External Action should be set correctly.');
		System.assertEquals(messageType, result.message_type, 'Message Type should be set correctly.');
		System.assertEquals(salesforceId, result.payload.salesforceId, 'Salesforce ID should be set in the payload.');
		System.assertEquals(commentBody, result.payload.comment, 'Comment body should be set in the payload.');
	}

	@isTest
	static void createCaseRequestObject_ShouldReturnCorrectDTO() {
		// Arrange
		setupMocks();
		NorlysNowService service = new NorlysNowService();

		// Act
		NorlysNowClientRequestDTO result = service.createCaseRequestObject(
			'corr-id',
			'CREATE',
			'ext-ref',
			'Case',
			'Async',
			'PartnerB',
			'5003N000002W9p7QAD',
			'A comment',
			'High',
			'A description',
			'A title',
			'Problem',
			'New',
			'Email',
			'Tech',
			'Fiber',
			'Coax',
			'WF12345',
			'Firstname Lastname'
		);

		// Assert
		System.assertEquals('corr-id', result.correlation_id, 'Correlation ID should match.');
		System.assertEquals('CREATE', result.external_action, 'External Action should match.');
		System.assertEquals('Case', result.message_type, 'Message Type should match.');
		System.assertEquals('5003N000002W9p7QAD', result.payload.salesforceId, 'Salesforce ID should match.');
		System.assertEquals('A description', result.payload.description, 'Description should match.');
		System.assertEquals('A title', result.payload.title, 'Title should match.');
		System.assertEquals('Problem', result.payload.type, 'Type should match.');
		System.assertEquals('New', result.payload.status, 'Status should match.');
		System.assertEquals('Firstname Lastname', result.payload.createdBy, 'createdBy should match.');
	}

	@isTest
	static void createFileRequestObject_ShouldReturnCorrectDTO() {
		// Arrange
		setupMocks();
		NorlysNowService service = new NorlysNowService();

		// Act
		NorlysNowClientRequestDTO result = service.createFileRequestObject(
			'corr-id-file',
			'ATTACH',
			'ext-ref-file',
			'File',
			'Async',
			'PartnerC',
			'5003N000002W9p8QAE',
			'base64-encoded-data',
			'testfile.txt'
		);

		// Assert
		System.assertEquals('corr-id-file', result.correlation_id, 'Correlation ID should match.');
		System.assertEquals('ATTACH', result.external_action, 'External Action should match.');
		System.assertEquals('File', result.message_type, 'Message Type should match.');
		System.assertEquals('base64-encoded-data', result.payload.fileData, 'File data should match.');
		System.assertEquals('testfile.txt', result.payload.fileName, 'File name should match.');
	}

	@isTest
	static void setSuccessOnNorlysNowCase_ShouldUpdateStatus() {
		// Arrange
		setupMocks();
		NorlysNowService service = new NorlysNowService();
		NorlysNow_Case__c testCase = new NorlysNow_Case__c();

		// Act
		NorlysNow_Case__c result = service.setSuccessOnNorlysNowCase(testCase);

		// Assert
		System.assertEquals('Success', result.Sync_Status__c, 'Sync Status should be "Success".');
	}

	@isTest
	static void setErrorOnNorlysNowCase_ShouldUpdateStatusAndMessage() {
		// Arrange
		setupMocks();
		NorlysNowService service = new NorlysNowService();
		NorlysNow_Case__c testCase = new NorlysNow_Case__c();
		String errorMessage = 'An error occurred.';

		// Act
		NorlysNow_Case__c result = service.setErrorOnNorlysNowCase(testCase, errorMessage);

		// Assert
		System.assertEquals('Error', result.Sync_Status__c, 'Sync Status should be "Error".');
		System.assertEquals(errorMessage, result.Sync_Message__c, 'Sync Message should be set.');
	}

	@isTest
	static void getParameters_ShouldDeserializeCorrectly() {
		// Arrange
		setupMocks();
		NorlysNowService service = new NorlysNowService();
		Id fakeId1 = DatabaseService.getFakeId(NorlysNow_Case__c.SObjectType);
		Id fakeId2 = DatabaseService.getFakeId(NorlysNow_Case__c.SObjectType);
		Set<Id> recordIds = new Set<Id>{ fakeId1, fakeId2 };

		String jsonString = '{"type":"Case","recordIds":["' + fakeId1 + '","' + fakeId2 + '"]}';

		// Act
		NorlysNowService.Parameters result = service.getParameters(jsonString);

		// Assert
		System.assertEquals('Case', result.type, 'Type should be deserialized correctly.');
		System.assertEquals(recordIds, result.recordIds, 'Record IDs should be deserialized correctly.');
	}

	@isTest
	static void getFileIdToVersion_ShouldReturnCorrectMap() {
		// Arrange
		TriggerHandler.bypass('NorlysNowCaseTriggerHandler');
		TriggerHandler.bypass('ContentDocumentLinkTriggerHandler');
		setupMocks();
		NorlysNowService service = new NorlysNowService();
		NorlysTestScenarios.ScenarioResult scenario = NorlysTestScenarios.newBuilder()
			.forNorlysNowCaseHandling()
			.withNorlysNowCases(1)
			.withAttachedFiles(1)
			.build();

		ContentDocumentLink cdl = scenario.contentDocumentLinks[0];
		Set<Id> docIds = new Set<Id>{ cdl.ContentDocumentId };

		ContentVersion cv = new ContentVersion(
			Id = '0683N000002W9pBQAS',
			ContentDocumentId = cdl.ContentDocumentId,
			VersionData = Blob.valueOf('test data')
		);
		norlysNowSelectorMock.spyOn('getContentVersions').whenCalledWith(docIds).thenReturn(new List<ContentVersion>{ cv });

		// Act
		Map<Id, ContentVersion> result = service.getFileIdToVersion(docIds);

		// Assert
		System.assertEquals(1, result.size(), 'The map should contain one entry.');
		System.assert(result.containsKey(cdl.ContentDocumentId), 'Map should contain the content document Id.');
		System.assertEquals(cv.Id, result.get(cdl.ContentDocumentId).Id, 'The content version should match.');
		TriggerHandler.clearAllBypasses();
	}

	@isTest
	static void createFollowUpTasks_ShouldCreateTasksAndSendEmails() {
		// Arrange
		TriggerHandler.bypass('NorlysNowCaseTriggerHandler');
		setupMocks();
		NorlysNowService service = new NorlysNowService();
		NorlysTestScenarios.ScenarioResult scenario = NorlysTestScenarios.newBuilder()
			.forNorlysNowCaseHandling()
			.withNorlysNowCases(1)
			.build();

		String subject = 'Follow Up';
		String description = 'Please follow up on this case.';
		Date dueDate = Date.today().addDays(5);

		// Mock selector calls
		Set<Id> ownerIds = new Set<Id>{ scenario.owner.Id };
		norlysNowSelectorMock.spyOn('getUsers').whenCalledWith(ownerIds).thenReturn(new List<User>{ scenario.owner });

		CustomNotificationType notifType = new CustomNotificationType(
			Id = DatabaseService.getFakeId(CustomNotificationType.SObjectType),
			DeveloperName = 'New_Task_on_NorlysNow_Case'
		);
		norlysNowSelectorMock.spyOn('getCustomNotificationType')
			.whenCalledWith('New_Task_on_NorlysNow_Case')
			.thenReturn(notifType);

		OrgWideEmailAddress owe = new OrgWideEmailAddress(
			Id = DatabaseService.getFakeId(OrgWideEmailAddress.SObjectType),
			Address = 'noreply.mobil@norlys.dk'
		);
		norlysNowSelectorMock.spyOn('getOrgWideEmailAddress').whenCalledWith('noreply.mobil@norlys.dk').thenReturn(owe);

		// Act
		Test.startTest();
		service.createFollowUpTasks(scenario.norlysNowCases, subject, description, dueDate);
		Test.stopTest();

		// Assert
		List<Task> insertedTasks = [
			SELECT Id, Subject, Description, WhatId, OwnerId
			FROM Task
		];
		System.assertEquals(1, insertedTasks.size(), 'One task should have been inserted.');

		Task insertedTask = insertedTasks[0];
		System.assertEquals(subject, insertedTask.Subject, 'Task subject should match.');
		System.assertEquals(description, insertedTask.Description, 'Task description should match.');
		System.assertEquals(
			scenario.norlysNowCases[0].Id,
			insertedTask.WhatId,
			'Task should be related to the NorlysNow Case.'
		);
		System.assertEquals(scenario.owner.Id, insertedTask.OwnerId, 'Task owner should be the case creator.');
		TriggerHandler.clearAllBypasses();
	}

	@isTest
	static void closeParentCases_WhenAllChildrenAreClosed_ShouldReturnParentToClose() {
		// Arrange
		TriggerHandler.bypass('NorlysNowCaseTriggerHandler');
		setupMocks();
		NorlysNowService service = new NorlysNowService();
		NorlysTestScenarios.ScenarioResult scenario = NorlysTestScenarios.newBuilder()
			.forNorlysNowCaseHandling()
			.withNorlysNowCases(2)
			.build();

		for (NorlysNow_Case__c nc : scenario.norlysNowCases) {
			nc.Status__c = 'Closed';
		}

		Set<Id> parentIds = new Set<Id>{ scenario.caseRecord.Id };
		norlysNowSelectorMock.spyOn('getAllNorlysNowCasesUnderParentCases')
			.whenCalledWith(parentIds)
			.thenReturn(scenario.norlysNowCases);

		// Act
		List<Case> result = service.closeParentCases(scenario.norlysNowCases);

		// Assert
		System.assertEquals(1, result.size(), 'One parent case should be returned to be closed.');
		System.assertEquals(scenario.caseRecord.Id, result[0].Id, 'The correct parent case should be returned.');
		System.assertEquals('Closed', result[0].Status, 'The parent case status should be "Closed".');
		TriggerHandler.clearAllBypasses();
	}

	@isTest
	static void closeParentCases_WhenSomeChildrenAreOpen_ShouldNotReturnParent() {
		// Arrange
		TriggerHandler.bypass('NorlysNowCaseTriggerHandler');
		setupMocks();
		NorlysNowService service = new NorlysNowService();
		NorlysTestScenarios.ScenarioResult scenario = NorlysTestScenarios.newBuilder()
			.forNorlysNowCaseHandling()
			.withNorlysNowCases(2)
			.build();

		scenario.norlysNowCases[0].Status__c = 'Closed';
		scenario.norlysNowCases[1].Status__c = 'New'; // One case is still open

		Set<Id> parentIds = new Set<Id>{ scenario.caseRecord.Id };
		norlysNowSelectorMock.spyOn('getAllNorlysNowCasesUnderParentCases')
			.whenCalledWith(parentIds)
			.thenReturn(scenario.norlysNowCases);

		// Act
		List<Case> result = service.closeParentCases(new List<NorlysNow_Case__c>{ scenario.norlysNowCases[0] });

		// Assert
		System.assert(result.isEmpty(), 'No parent cases should be returned for closure.');
		TriggerHandler.clearAllBypasses();
	}

	@isTest
	static void checkParentCaseIsClosed_WhenParentIsClosed_ShouldAddError() {
		// Arrange
		TriggerHandler.bypass('NorlysNowCaseTriggerHandler');
		setupMocks();
		NorlysNowService service = new NorlysNowService();
		NorlysTestScenarios.ScenarioResult scenario = NorlysTestScenarios.newBuilder()
			.forNorlysNowCaseHandling()
			.withNorlysNowCases(1)
			.build();

		scenario.caseRecord.Status = 'Closed';
		Map<Id, Case> closedParentMap = new Map<Id, Case>{ scenario.caseRecord.Id => scenario.caseRecord };

		norlysNowSelectorMock.spyOn('getCasesByIds')
			.whenCalledWith(new Set<Id>{ scenario.caseRecord.Id })
			.thenReturn(closedParentMap);

		// Act
		service.CheckParentCaseIsClosed(scenario.norlysNowCases);

		// Assert
		System.assert(scenario.norlysNowCases[0].hasErrors(), 'The NorlysNow case should have an error.');
		System.assertEquals(
			'You are not allowed to create or update NorlysNow Cases on a closed Case',
			scenario.norlysNowCases[0].getErrors()[0].getMessage(),
			'The error message is not the one expected.'
		);
		TriggerHandler.clearAllBypasses();
	}

	@isTest
	static void chunkEventsInListsToBePublished_ShouldReturnCorrectEventList() {
		// Arrange
		setupMocks();
		NorlysNowService service = new NorlysNowService();
		List<Id> idsToChunk = new List<Id>();
		for (Integer i = 0; i < 150; i++) {
			idsToChunk.add(DatabaseService.getFakeId(NorlysNow_Case__c.SObjectType));
		}

		// Act
		List<EventExecutor__e> result = service.chunkEventsInListsToBePublished(idsToChunk, 'TestType', 'TestExecutor');

		// Assert
		System.assertEquals(2, result.size(), 'The list should be chunked into two events.');

		// Check the first event
		NorlysNowService.Parameters params1 = (NorlysNowService.Parameters) JSON.deserialize(
			result[0].Parameters__c,
			NorlysNowService.Parameters.class
		);
		System.assertEquals(100, params1.recordIds.size(), 'First chunk should have 100 records.');
		System.assertEquals('TestType', params1.type, 'Type should be set correctly.');
		System.assertEquals('TestExecutor', result[0].Executor__c, 'Executor should be set correctly.');

		// Check the second event
		NorlysNowService.Parameters params2 = (NorlysNowService.Parameters) JSON.deserialize(
			result[1].Parameters__c,
			NorlysNowService.Parameters.class
		);
		System.assertEquals(50, params2.recordIds.size(), 'Second chunk should have 50 records.');
	}

	@isTest
	static void sendNotifications_ShouldSendNotificationsToCaseCreators() {
		// Arrange
		TriggerHandler.bypass('NorlysNowCaseTriggerHandler');
		setupMocks();
		NorlysNowService service = new NorlysNowService();
		NorlysTestScenarios.ScenarioResult scenario = NorlysTestScenarios.newBuilder()
			.forNorlysNowCaseHandling()
			.withNorlysNowCases(2)
			.build();

		CustomNotificationType notifType = new CustomNotificationType(
			Id = DatabaseService.getFakeId(CustomNotificationType.SObjectType),
			DeveloperName = 'New_Task_on_NorlysNow_Case'
		);
		norlysNowSelectorMock.spyOn('getCustomNotificationType')
			.whenCalledWith('New_Task_on_NorlysNow_Case')
			.thenReturn(notifType);

		// Act
		Test.startTest();
		service.sendNotifications(scenario.norlysNowCases, 'Test Title', 'Test Body');
		Test.stopTest();

		// Assert
		// We can't directly verify the CustomNotification was sent,
		// but we can ensure the selector was called to get the notification type.
		System.assertEquals(
			1,
			norlysNowSelectorMock.spyOn('getCustomNotificationType').callLog.size(),
			'getCustomNotificationType should have been called once.'
		);
		TriggerHandler.clearAllBypasses();
	}
}
