/**
 * @description Test class for the NorlysNowCaseTriggerHandler.
 *              This class follows the project's standard of mocking service dependencies
 *              and injecting them via a shared SingletonFactory instance.
 *
 * -----------------------------------------------------------------------------
 * @author Developer           Date            Description
 * -----------------------------------------------------------------------------
 * @author Esben Hovgaard        18/09/2025      Class and method documentation
 * -----------------------------------------------------------------------------
 */
@isTest
private class NorlysNowCaseTriggerHandlerTest {
	private static Mock norlysNowServiceMock;
	private static Mock norlysNowSelectorMock;
	private static Mock permissionServiceMock;
	private static Mock eventExecutorServiceMock;
	private static DatabaseService dbMock;

	/**
	 * @description Sets up the test environment by creating mocks for all service dependencies
	 *              and registering them with the shared SingletonFactory.
	 */
	private static void setupMocks() {
		// Create all necessary mocks
		norlysNowServiceMock = Mock.forType(NorlysNowService.class);
		norlysNowSelectorMock = Mock.forType(NorlysNowSelector.class);
		permissionServiceMock = Mock.forType(PermissionService.class);
		eventExecutorServiceMock = Mock.forType(EventExecutorService.class);
		dbMock = new DatabaseService().mockDmls();

		// Get the shared factory instance
		SingletonFactory factory = SingletonFactory.getFactory();

		// Register all our mock stubs with the shared factory.
		// The handler's default constructor will now receive these mocks.
		factory.registerSingleton(NorlysNowService.class, (NorlysNowService) norlysNowServiceMock.stub);
		factory.registerSingleton(NorlysNowSelector.class, (NorlysNowSelector) norlysNowSelectorMock.stub);
		factory.registerSingleton(PermissionService.class, (PermissionService) permissionServiceMock.stub);
		factory.registerSingleton(EventExecutorService.class, (EventExecutorService) eventExecutorServiceMock.stub);
		factory.registerSingleton(DatabaseService.class, dbMock);
	}

	/**
	 * @description Verifies that an event is published after a NorlysNow_Case__c is inserted
	 *              when the user has the required permissions.
	 */
	@isTest
	static void afterInsert_WithPermission_ShouldPublishEvent() {
		// Arrange
		TriggerHandler.bypass('NorlysNowCaseTriggerHandler');
		TriggerHandler.bypass('CaseTriggerHandler');
		setupMocks();

		NorlysTestScenarios.ScenarioResult scenario = NorlysTestScenarios.newBuilder()
			.forNorlysNowCaseHandling()
			.withNorlysNowCases(1)
			.build();
		Map<Id, NorlysNow_Case__c> caseMap = new Map<Id, NorlysNow_Case__c>(scenario.norlysNowCases);

		// Configure mock behavior
		permissionServiceMock.spyOn('hasPermissionSet').whenCalledWith(Argument.any()).thenReturn(true);
		norlysNowServiceMock.spyOn('chunkEventsInListsToBePublished')
			.whenCalledWith(Argument.any(), Argument.any(), Argument.any())
			.thenReturn(new List<EventExecutor__e>{ new EventExecutor__e() });
		norlysNowServiceMock.spyOn('closeParentCases').whenCalledWith(Argument.any()).thenReturn(new List<Case>());
		MethodSpy publishSpy = eventExecutorServiceMock.spyOn('publishEvents');

		// Act
		NorlysNowCaseTriggerHandler handler = new NorlysNowCaseTriggerHandler();
		handler.triggerNew = scenario.norlysNowCases;
		handler.triggerNewMap = caseMap;
		Test.startTest();
		handler.afterInsert();
		Test.stopTest();

		// Assert
		System.assertEquals(1, publishSpy.callLog.size(), 'The publish method should have been called once.');
		TriggerHandler.clearAllBypasses();
	}

	/**
	 * @description Verifies that the parent case is closed when the last child NorlysNow_Case__c is updated.
	 */
	@isTest
	static void afterUpdate_OnLastChildCaseClosure_ShouldCloseParentCase() {
		// Arrange
		TriggerHandler.bypass('NorlysNowCaseTriggerHandler');
		TriggerHandler.bypass('CaseTriggerHandler');
		setupMocks();

		NorlysTestScenarios.ScenarioResult scenario = NorlysTestScenarios.newBuilder()
			.forNorlysNowCaseHandling()
			.withNorlysNowCases(1)
			.build();

		// Create old and new versions of the case for the trigger context
		NorlysNow_Case__c newCase = scenario.norlysNowCases[0];
		newCase.Status__c = 'Closed';

		NorlysNow_Case__c oldCase = newCase.clone(true, false, false, false);
		oldCase.Status__c = 'New';

		Map<Id, NorlysNow_Case__c> newCaseMap = new Map<Id, NorlysNow_Case__c>{ newCase.Id => newCase };
		Map<Id, NorlysNow_Case__c> oldCaseMap = new Map<Id, NorlysNow_Case__c>{ oldCase.Id => oldCase };

		permissionServiceMock.spyOn('hasPermissionSet').whenCalledWith(Argument.any()).thenReturn(true);

		// Use a generic argument matcher to make the mock less brittle
		norlysNowServiceMock.spyOn('closeParentCases')
			.whenCalledWith(Argument.any())
			.thenReturn(new List<Case>{ new Case(Id = scenario.caseRecord.Id, Status = 'Closed') });

		MethodSpy sendNotificationsSpy = norlysNowServiceMock.spyOn('sendNotifications');
		sendNotificationsSpy.whenCalledWith(Argument.any(), Argument.any(), Argument.any()).thenReturn(null);

		// Act
		NorlysNowCaseTriggerHandler handler = new NorlysNowCaseTriggerHandler();
		handler.triggerNew = new List<NorlysNow_Case__c>(newCaseMap.values());
		handler.triggerNewMap = newCaseMap;
		handler.triggerOldMap = oldCaseMap;
		Test.startTest();
		handler.afterUpdate();
		Test.stopTest();

		// Assert
		System.assertEquals(1, dbMock.register.updated.size(), 'A single record should have been updated.');
		Case updatedParentCase = (Case) dbMock.register.updated[0];
		System.assertEquals(scenario.caseRecord.Id, updatedParentCase.Id, 'The updated record should be the parent case.');
		System.assertEquals('Closed', updatedParentCase.Status, 'The parent case status should be updated to "Closed".');
		System.assertEquals(
			1,
			sendNotificationsSpy.callLog.size(),
			'sendNotifications should have been called once for the status change.'
		);
		TriggerHandler.clearAllBypasses();
	}

	/**
	 * @description Verifies that the CheckParentCaseIsClosed method is called before a NorlysNow_Case__c is inserted.
	 */
	@isTest
	static void beforeInsert_OnClosedParentCase_ShouldAddError() {
		// Arrange
		TriggerHandler.bypass('NorlysNowCaseTriggerHandler');
		TriggerHandler.bypass('CaseTriggerHandler');
		setupMocks();

		NorlysTestScenarios.ScenarioResult scenario = NorlysTestScenarios.newBuilder()
			.forNorlysNowCaseHandling()
			.withNorlysNowCases(1)
			.build();

		MethodSpy checkParentCaseSpy = norlysNowServiceMock.spyOn('CheckParentCaseIsClosed');

		// Act
		NorlysNowCaseTriggerHandler handler = new NorlysNowCaseTriggerHandler();
		handler.triggerNew = scenario.norlysNowCases;
		Test.startTest();
		handler.beforeInsert();
		Test.stopTest();

		// Assert
		System.assertEquals(1, checkParentCaseSpy.callLog.size(), 'CheckParentCaseIsClosed should have been called once.');
		TriggerHandler.clearAllBypasses();
	}

	/**
	 * @description Verifies that no event is published after a NorlysNow_Case__c is inserted
	 *              when the user does not have the required permissions.
	 */
	@isTest
	static void afterInsert_WithoutPermission_ShouldNotPublishEvent() {
		// Arrange
		TriggerHandler.bypass('NorlysNowCaseTriggerHandler');
		TriggerHandler.bypass('CaseTriggerHandler');
		setupMocks();

		NorlysTestScenarios.ScenarioResult scenario = NorlysTestScenarios.newBuilder()
			.forNorlysNowCaseHandling()
			.withNorlysNowCases(1)
			.build();
		Map<Id, NorlysNow_Case__c> caseMap = new Map<Id, NorlysNow_Case__c>(scenario.norlysNowCases);

		permissionServiceMock.spyOn('hasPermissionSet').whenCalledWith(Argument.any()).thenReturn(false);
		MethodSpy publishSpy = eventExecutorServiceMock.spyOn('publishEvents');

		// Act
		NorlysNowCaseTriggerHandler handler = new NorlysNowCaseTriggerHandler();
		handler.triggerNew = scenario.norlysNowCases;
		handler.triggerNewMap = caseMap;
		Test.startTest();
		handler.afterInsert();
		Test.stopTest();

		// Assert
		System.assertEquals(0, publishSpy.callLog.size(), 'The publish method should not have been called.');
		TriggerHandler.clearAllBypasses();
	}

	/**
	 * @description Verifies that the parent case is not closed when there are still open child NorlysNow_Case__c records.
	 */
	@isTest
	static void afterUpdate_WithOpenChildCases_ShouldNotCloseParentCase() {
		// Arrange
		TriggerHandler.bypass('NorlysNowCaseTriggerHandler');
		TriggerHandler.bypass('CaseTriggerHandler');
		setupMocks();

		NorlysTestScenarios.ScenarioResult scenario = NorlysTestScenarios.newBuilder()
			.forNorlysNowCaseHandling()
			.withNorlysNowCases(2)
			.build();
		Map<Id, NorlysNow_Case__c> caseMap = new Map<Id, NorlysNow_Case__c>(scenario.norlysNowCases);
		permissionServiceMock.spyOn('hasPermissionSet').whenCalledWith(Argument.any()).thenReturn(true);
		norlysNowServiceMock.spyOn('closeParentCases').whenCalledWith(scenario.norlysNowCases).thenReturn(new List<Case>());

		// Act
		NorlysNowCaseTriggerHandler handler = new NorlysNowCaseTriggerHandler();
		handler.triggerNew = scenario.norlysNowCases;
		handler.triggerNewMap = caseMap;
		Test.startTest();
		handler.afterUpdate();
		Test.stopTest();

		// Assert
		System.assertEquals(0, dbMock.register.updated.size(), 'No records should have been updated.');
		TriggerHandler.clearAllBypasses();
	}

	/**
	 * @description Verifies that an event is published when a NorlysNow_Case__c status is updated to 'Withdrawn'.
	 */
	@isTest
	static void afterUpdate_WithdrawnStatus_ShouldPublishEvent() {
		// Arrange
		TriggerHandler.bypass('NorlysNowCaseTriggerHandler');
		TriggerHandler.bypass('CaseTriggerHandler');
		setupMocks();

		NorlysTestScenarios.ScenarioResult scenario = NorlysTestScenarios.newBuilder()
			.forNorlysNowCaseHandling()
			.withNorlysNowCases(1)
			.build();

		scenario.norlysNowCases[0].Status__c = 'Withdrawn';
		Map<Id, NorlysNow_Case__c> caseMap = new Map<Id, NorlysNow_Case__c>(scenario.norlysNowCases);

		permissionServiceMock.spyOn('hasPermissionSet').whenCalledWith(Argument.any()).thenReturn(true);
		norlysNowServiceMock.spyOn('chunkEventsInListsToBePublished')
			.whenCalledWith(Argument.any(), Argument.any(), Argument.any())
			.thenReturn(new List<EventExecutor__e>{ new EventExecutor__e() });
		norlysNowServiceMock.spyOn('closeParentCases').whenCalledWith(scenario.norlysNowCases).thenReturn(new List<Case>());
		MethodSpy publishSpy = eventExecutorServiceMock.spyOn('publishEvents');

		// Act
		NorlysNowCaseTriggerHandler handler = new NorlysNowCaseTriggerHandler();
		handler.triggerNew = scenario.norlysNowCases;
		handler.triggerNewMap = caseMap;
		Test.startTest();
		handler.afterUpdate();
		Test.stopTest();

		// Assert
		System.assertEquals(1, publishSpy.callLog.size(), 'The publish method should have been called once.');
		TriggerHandler.clearAllBypasses();
	}

	@isTest
	static void afterUpdate_OnStatusChange_ShouldSendNotification() {
		// Arrange
		TriggerHandler.bypass('NorlysNowCaseTriggerHandler');
		TriggerHandler.bypass('CaseTriggerHandler');
		setupMocks();

		NorlysTestScenarios.ScenarioResult scenario = NorlysTestScenarios.newBuilder()
			.forNorlysNowCaseHandling()
			.withNorlysNowCases(1)
			.build();

		NorlysNow_Case__c newCase = scenario.norlysNowCases[0];
		newCase.Status__c = 'In Progress';

		NorlysNow_Case__c oldCase = newCase.clone(true, false, false, false);
		oldCase.Status__c = 'New';

		Map<Id, NorlysNow_Case__c> newCaseMap = new Map<Id, NorlysNow_Case__c>{ newCase.Id => newCase };
		Map<Id, NorlysNow_Case__c> oldCaseMap = new Map<Id, NorlysNow_Case__c>{ oldCase.Id => oldCase };

		permissionServiceMock.spyOn('hasPermissionSet').whenCalledWith(Argument.any()).thenReturn(true);
		norlysNowServiceMock.spyOn('closeParentCases').whenCalledWith(Argument.any()).thenReturn(new List<Case>());
		MethodSpy sendNotificationsSpy = norlysNowServiceMock.spyOn('sendNotifications');
		sendNotificationsSpy.whenCalledWith(Argument.any(), Argument.any(), Argument.any()).thenReturn(null);

		// Act
		NorlysNowCaseTriggerHandler handler = new NorlysNowCaseTriggerHandler();
		handler.triggerNew = new List<NorlysNow_Case__c>(newCaseMap.values());
		handler.triggerNewMap = newCaseMap;
		handler.triggerOldMap = oldCaseMap;
		Test.startTest();
		handler.afterUpdate();
		Test.stopTest();

		// Assert
		System.assertEquals(1, sendNotificationsSpy.callLog.size(), 'sendNotifications should have been called once.');
		TriggerHandler.clearAllBypasses();
	}

	@isTest
	static void afterUpdate_OnWithdrawnStatusChange_ShouldNotSendNotification() {
		// Arrange
		TriggerHandler.bypass('NorlysNowCaseTriggerHandler');
		TriggerHandler.bypass('CaseTriggerHandler');
		setupMocks();

		NorlysTestScenarios.ScenarioResult scenario = NorlysTestScenarios.newBuilder()
			.forNorlysNowCaseHandling()
			.withNorlysNowCases(1)
			.build();

		NorlysNow_Case__c newCase = scenario.norlysNowCases[0];
		newCase.Status__c = 'Withdrawn';

		NorlysNow_Case__c oldCase = newCase.clone(true, false, false, false);
		oldCase.Status__c = 'New';

		Map<Id, NorlysNow_Case__c> newCaseMap = new Map<Id, NorlysNow_Case__c>{ newCase.Id => newCase };
		Map<Id, NorlysNow_Case__c> oldCaseMap = new Map<Id, NorlysNow_Case__c>{ oldCase.Id => oldCase };

		permissionServiceMock.spyOn('hasPermissionSet').whenCalledWith(Argument.any()).thenReturn(true);
		norlysNowServiceMock.spyOn('closeParentCases').whenCalledWith(Argument.any()).thenReturn(new List<Case>());
		MethodSpy sendNotificationsSpy = norlysNowServiceMock.spyOn('sendNotifications');
		sendNotificationsSpy.whenCalledWith(Argument.any(), Argument.any(), Argument.any()).thenReturn(null);

		// Act
		NorlysNowCaseTriggerHandler handler = new NorlysNowCaseTriggerHandler();
		handler.triggerNew = new List<NorlysNow_Case__c>(newCaseMap.values());
		handler.triggerNewMap = newCaseMap;
		handler.triggerOldMap = oldCaseMap;
		Test.startTest();
		handler.afterUpdate();
		Test.stopTest();

		// Assert
		System.assertEquals(
			0,
			sendNotificationsSpy.callLog.size(),
			'sendNotifications should not have been called for a status change to Withdrawn.'
		);
		TriggerHandler.clearAllBypasses();
	}
}
