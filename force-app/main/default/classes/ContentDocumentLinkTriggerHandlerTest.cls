/**
 * @description Test class for the ContentDocumentLinkTriggerHandler.
 *
 * -----------------------------------------------------------------------------
 * @author Developer           Date            Description
 * -----------------------------------------------------------------------------
 * @author Esben Hovgaard        18/09/2025      Class and method documentation
 * -----------------------------------------------------------------------------
 */
@IsTest
private with sharing class ContentDocumentLinkTriggerHandlerTest {
	// Mocked service dependencies, to be initialized in each test
	private static Mock contentDocumentLinkServiceMock;
	private static Mock caseServiceMock;
	private static Mock permissionServiceMock;
	private static Mock norlysNowServiceMock;
	private static Mock eventExecutorServiceMock;
	private static Mock norlysNowSelectorMock;

	/**
	 * @description Sets up the test environment by mocking all the necessary service dependencies.
	 */
	private static void setupMocks() {
		// Create mocks for all service dependencies
		contentDocumentLinkServiceMock = Mock.forType(ContentDocumentLinkService.class);
		caseServiceMock = Mock.forType(CaseService.class);
		permissionServiceMock = Mock.forType(PermissionService.class);
		norlysNowServiceMock = Mock.forType(NorlysNowService.class);
		eventExecutorServiceMock = Mock.forType(EventExecutorService.class);
		norlysNowSelectorMock = Mock.forType(NorlysNowSelector.class);

		// Get the stub instances from the mocks
		ContentDocumentLinkService cds = (ContentDocumentLinkService) contentDocumentLinkServiceMock.stub;
		CaseService cs = (CaseService) caseServiceMock.stub;
		PermissionService ps = (PermissionService) permissionServiceMock.stub;
		NorlysNowService nns = (NorlysNowService) norlysNowServiceMock.stub;
		EventExecutorService ees = (EventExecutorService) eventExecutorServiceMock.stub;
		NorlysNowSelector nnsm = (NorlysNowSelector) norlysNowSelectorMock.stub;

		// Register all the singleton services with our stubs so the handler will use them
		SingletonFactory factory = SingletonFactory.getFactory();
		factory.registerSingleton(ContentDocumentLinkService.class, cds);
		factory.registerSingleton(CaseService.class, cs);
		factory.registerSingleton(PermissionService.class, ps);
		factory.registerSingleton(NorlysNowService.class, nns);
		factory.registerSingleton(EventExecutorService.class, ees);
		factory.registerSingleton(NorlysNowSelector.class, nnsm);
	}

	/**
	 * @description Tests that when a file is attached to a standard Case, the case's status is correctly updated.
	 */
	@isTest
	static void afterInsert_OnCase_ShouldUpdateCase() {
		// Arrange
		TriggerHandler.bypass('ContentDocumentLinkTriggerHandler');
		TriggerHandler.bypass('CaseTriggerHandler');
		setupMocks();

		Account acc = TDF_AccountUtils.createAccountWithCVR('12345678');
		Case testCase = TDF_CaseUtils.createCustomerServiceCasesForAccounts(new List<Account>{ acc })[0];

		ContentVersion cv = TDF_ContentVersionUtils.createContentVersion('Test Doc', 'txt', 'Test Data');
		ContentDocument cd = [
			SELECT Id
			FROM ContentDocument
			WHERE LatestPublishedVersionId = :cv.Id
		];

		ContentDocumentLink testLink = new ContentDocumentLink(
			LinkedEntityId = testCase.Id,
			ContentDocumentId = cd.Id,
			ShareType = 'V'
		);
		insert testLink;

		// --- Mock Service Calls ---
		MethodSpy getRelatedCasesSpy = contentDocumentLinkServiceMock.spyOn('getRelatedCasesByLinkedEntityIds');
		getRelatedCasesSpy.whenCalledWith(Argument.any()).thenReturn(new List<Id>{ testCase.Id });

		MethodSpy updateCasesSpy = caseServiceMock.spyOn('updateCustomerServiceCasesToAwaitingUser');
		updateCasesSpy.whenCalledWith(Argument.any()).thenReturn(null);

		MethodSpy hasPermissionSpy = permissionServiceMock.spyOn('hasPermissionSet');
		hasPermissionSpy.whenCalledWith(Argument.any()).thenReturn(false);

		ContentDocumentLinkTriggerHandler handler = new ContentDocumentLinkTriggerHandler();
		handler.triggerNew = new List<ContentDocumentLink>{ testLink };

		// Act
		Test.startTest();
		handler.afterInsert();
		Test.stopTest();

		// Assert
		System.assertEquals(
			1,
			getRelatedCasesSpy.callLog.size(),
			'getRelatedCasesByLinkedEntityIds should have been called once.'
		);
		System.assertEquals(
			1,
			updateCasesSpy.callLog.size(),
			'updateCustomerServiceCasesToAwaitingUser should have been called once.'
		);
		TriggerHandler.clearAllBypasses();
	}

	/**
	 * @description Tests that an event is published when a file is attached to a NorlysNow_Case__c
	 *              and the user has the required permission.
	 */
	@isTest
	static void afterInsert_WithPermissionAndNorlysNowCase_ShouldPublishEvent() {
		// Arrange
		TriggerHandler.bypass('ContentDocumentLinkTriggerHandler');
		TriggerHandler.bypass('CaseTriggerHandler');
		TriggerHandler.bypass('NorlysNowCaseTriggerHandler');
		setupMocks();

		NorlysTestScenarios.ScenarioResult scenario = NorlysTestScenarios.newBuilder()
			.forNorlysNowCaseHandling()
			.withNorlysNowCases(1)
			.withAttachedFiles(1)
			.build();

		// --- Mock Service Calls ---
		permissionServiceMock.spyOn('hasPermissionSet').whenCalledWith(Argument.any()).thenReturn(true);
		norlysNowServiceMock.spyOn('chunkEventsInListsToBePublished')
			.whenCalledWith(Argument.any(), Argument.any(), Argument.any())
			.thenReturn(new List<EventExecutor__e>{ new EventExecutor__e() });
		MethodSpy publishSpy = eventExecutorServiceMock.spyOn('publishEvents');

		ContentDocumentLinkTriggerHandler handler = new ContentDocumentLinkTriggerHandler();
		handler.triggerNew = scenario.contentDocumentLinks;

		// Act
		Test.startTest();
		handler.afterInsert();
		Test.stopTest();

		// Assert
		System.assertEquals(1, publishSpy.callLog.size(), 'The publish method should have been called once.');
		TriggerHandler.clearAllBypasses();
	}

	/**
	 * @description Tests that no event is published when a file is attached to a NorlysNow_Case__c
	 *              but the user does NOT have the required permission.
	 */
	@isTest
	static void afterInsert_WithoutPermission_ShouldNotPublishEvent() {
		// Arrange
		TriggerHandler.bypass('ContentDocumentLinkTriggerHandler');
		TriggerHandler.bypass('CaseTriggerHandler');
		TriggerHandler.bypass('NorlysNowCaseTriggerHandler');
		setupMocks();

		NorlysTestScenarios.ScenarioResult scenario = NorlysTestScenarios.newBuilder()
			.forNorlysNowCaseHandling()
			.withNorlysNowCases(1)
			.withAttachedFiles(1)
			.build();

		// --- Mock Service Calls ---
		permissionServiceMock.spyOn('hasPermissionSet').whenCalledWith(Argument.any()).thenReturn(false);

		MethodSpy publishSpy = eventExecutorServiceMock.spyOn('publishEvents');

		ContentDocumentLinkTriggerHandler handler = new ContentDocumentLinkTriggerHandler();
		handler.triggerNew = scenario.contentDocumentLinks;

		// Act
		Test.startTest();
		handler.afterInsert();
		Test.stopTest();

		// Assert
		System.assertEquals(0, publishSpy.callLog.size(), 'The publish method should not have been called.');
		TriggerHandler.clearAllBypasses();
	}

	@isTest
	static void afterInsert_byIntegrationUser_shouldSendNotification() {
		// Arrange
		TriggerHandler.bypass('ContentDocumentLinkTriggerHandler');
		TriggerHandler.bypass('NorlysNowCaseTriggerHandler');
		TriggerHandler.bypass('CaseTriggerHandler');
		setupMocks();

		User integrationUser = [SELECT Id, Email FROM User WHERE Email = 'norlysnowintegration@norlys.dk' LIMIT 1];

		NorlysTestScenarios.ScenarioResult scenario = NorlysTestScenarios.newBuilder()
			.forNorlysNowCaseHandling()
			.withNorlysNowCases(1)
			.withAttachedFiles(1)
			.build();

		Map<Id, NorlysNow_Case__c> caseMap = new Map<Id, NorlysNow_Case__c>(scenario.norlysNowCases);

		// --- Mock Service Calls ---
		permissionServiceMock.spyOn('hasPermissionSet').whenCalledWith(Argument.any()).thenReturn(false);
		norlysNowSelectorMock.spyOn('getNorlysNowCasesMap').whenCalledWith(caseMap.keySet()).thenReturn(caseMap);
		MethodSpy sendNotificationsSpy = norlysNowServiceMock.spyOn('sendNotifications');
		sendNotificationsSpy.whenCalledWith(Argument.any(), Argument.any(), Argument.any()).thenReturn(null);

		ContentDocumentLinkTriggerHandler handler = new ContentDocumentLinkTriggerHandler();
		handler.triggerNew = scenario.contentDocumentLinks;

		// Act
		Test.startTest();
		System.runAs(integrationUser) {
			handler.afterInsert();
		}
		Test.stopTest();

		// Assert
		System.assertEquals(
			1,
			sendNotificationsSpy.callLog.size(),
			'The sendNotifications method should have been called once.'
		);
		TriggerHandler.clearAllBypasses();
	}
}
