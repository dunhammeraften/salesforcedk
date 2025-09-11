/**
 * @description Test class for the NorlysNowCaseTriggerHandler. This class ensures that the handler
 *              correctly processes NorlysNow_Case__c records on insert and update. It tests
 *              the logic for closing parent cases, publishing events to the NorlysNow executor,
 *              and enforcing validation rules.
 *  -----------------------------------------------------------------------------
 *  Developer            Date            Description
 *  -----------------------------------------------------------------------------
 *  Esben Hovgaard       11/09/2025      Initial version.
 *
 * @author Esben Hovgaard
 * @date 2025-09-11
 */
@isTest
private class NorlysNowCaseTriggerHandlerTest {

    // Mocked service dependencies, to be initialized in each test
    private static NorlysNowService norlysNowService;
    private static Mock norlysNowSelectorMock;
    private static Mock permissionServiceMock;
    private static Mock eventExecutorServiceMock;
    private static DatabaseService dbMock;
    
    /**
     * @description Sets up the test environment by mocking all the necessary service dependencies.
     *              This is called by each test method to ensure a clean and predictable state.
     */
    private static void setupMocks() {
        // Create mocks for all service dependencies
        norlysNowSelectorMock = Mock.forType(NorlysNowSelector.class);
        permissionServiceMock = Mock.forType(PermissionService.class);
        eventExecutorServiceMock = Mock.forType(EventExecutorService.class);

        // Get the stub instances from the mocks
        NorlysNowSelector norlysNowSelectorStub = (NorlysNowSelector) norlysNowSelectorMock.stub;
        PermissionService permissionServiceStub = (PermissionService) permissionServiceMock.stub;
        EventExecutorService eventExecutorServiceStub = (EventExecutorService) eventExecutorServiceMock.stub;

        // Instantiate DatabaseService with DML mocking enabled
        dbMock = new DatabaseService().mockDmls();

        // Instantiate the real NorlysNowService with its selector dependency stubbed
        norlysNowService = new NorlysNowService(norlysNowSelectorStub);

        // Register all the singleton services with our stubs so the handler will use them
        SingletonFactory factory = SingletonFactory.getFactory();
        factory.registerSingleton(NorlysNowSelector.class, norlysNowSelectorStub);
        factory.registerSingleton(PermissionService.class, permissionServiceStub);
        factory.registerSingleton(EventExecutorService.class, eventExecutorServiceStub);
        factory.registerSingleton(DatabaseService.class, dbMock);
        factory.registerSingleton(NorlysNowService.class, norlysNowService);
    }

    /**
     * @description Tests that when a NorlysNow_Case__c is inserted and the user has the correct permissions,
     *              an EventExecutor__e event is correctly published to be processed by the NorlysNowExecutorHandler.
     */
    @isTest
    static void afterInsert_WithPermission_ShouldPublishEvent() {
        // Arrange
        TriggerHandler.bypass('NorlysNowCaseTriggerHandler');
        setupMocks();
        NorlysTestScenarios.ScenarioResult scenario = NorlysTestScenarios.newBuilder()
            .forNorlysNowCaseHandling()
            .withNorlysNowCases(1)
            .build();
        
        NorlysNow_Case__c testCase = scenario.norlysNowCases[0];

        // --- Mock Service Calls ---
        permissionServiceMock.spyOn('hasPermissionSet').whenCalledWith(Argument.ofType(List<String>.class)).thenReturn(true);
        Map<Id, NorlysNow_Case__c> caseMap = new Map<Id, NorlysNow_Case__c>{ testCase.Id => testCase };
        norlysNowSelectorMock.spyOn('getNorlysNowCasesMap').whenCalledWith(Argument.any()).thenReturn(caseMap);
        eventExecutorServiceMock.spyOn('publish').whenCalledWith(Argument.any()).thenReturn(null);
        
        NorlysNowCaseTriggerHandler handler = new NorlysNowCaseTriggerHandler();
        handler.triggerNew = new List<NorlysNow_Case__c>{ testCase };
        handler.triggerNewMap = caseMap;

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
     * @description Tests that when the last open NorlysNow_Case__c under a parent Case is closed,
     *              the parent Case's status is also updated to 'Closed'.
     */
    @isTest
    static void afterUpdate_OnLastChildCaseClosure_ShouldCloseParentCase() {
        // Arrange
        TriggerHandler.bypass('NorlysNowCaseTriggerHandler');
        setupMocks();
        NorlysTestScenarios.ScenarioResult scenario = NorlysTestScenarios.newBuilder()
            .forNorlysNowCaseHandling()
            .withNorlysNowCases(1)
            .build();
        
        NorlysNow_Case__c testCase = scenario.norlysNowCases[0];
        testCase.Status__c = 'Closed';
        
        Map<Id, NorlysNow_Case__c> caseMap = new Map<Id, NorlysNow_Case__c>{ testCase.Id => testCase };

        // --- Mock Service Calls ---
        norlysNowSelectorMock.spyOn('getNorlysNowCasesMap').whenCalledWith(Argument.any()).thenReturn(caseMap);
        norlysNowSelectorMock.spyOn('getAllNorlysNowCasesUnderParentCases').whenCalledWith(Argument.any()).thenReturn(scenario.norlysNowCases);
        permissionServiceMock.spyOn('hasPermissionSet').whenCalledWith(Argument.ofType(List<String>.class)).thenReturn(false);

        NorlysNowCaseTriggerHandler handler = new NorlysNowCaseTriggerHandler();
        handler.triggerNewMap = caseMap;

        // Act
        Test.startTest();
        handler.afterUpdate();
        Test.stopTest();

        // Assert
        System.assertEquals(1, dbMock.register.updated.size(), 'A single record should have been updated.');
        Case updatedParentCase = (Case)dbMock.register.updated[0];
        System.assertEquals(scenario.caseRecord.Id, updatedParentCase.Id, 'The updated record should be the parent case.');
        System.assertEquals('Closed', updatedParentCase.Status, 'The parent case status should be updated to "Closed".');
        TriggerHandler.clearAllBypasses();
    }

    /**
     * @description Tests the beforeInsert validation rule that prevents creating a new NorlysNow_Case__c
     *              if the parent Case is already in a 'Closed' state.
     */
    @isTest
    static void beforeInsert_OnClosedParentCase_ShouldAddError() {
        // Arrange
        TriggerHandler.bypass('NorlysNowCaseTriggerHandler');
        setupMocks();
        NorlysTestScenarios.ScenarioResult scenario = NorlysTestScenarios.newBuilder()
            .forNorlysNowCaseHandling()
            .withNorlysNowCases(1)
            .build();
        
        NorlysNow_Case__c testCase = scenario.norlysNowCases[0];
        scenario.caseRecord.Status = 'Closed';
        scenario.caseRecord.Contract_compliant__c = 'Yes';
        update scenario.caseRecord;

        Map<Id, Case> closedParentCaseMap = new Map<Id, Case>{
            scenario.caseRecord.Id => scenario.caseRecord
        };
        norlysNowSelectorMock.spyOn('getCasesByIds').whenCalledWith(Argument.any()).thenReturn(closedParentCaseMap);

        NorlysNowCaseTriggerHandler handler = new NorlysNowCaseTriggerHandler();
        handler.triggerNew = new List<NorlysNow_Case__c>{ testCase };

        // Act
        Test.startTest();
        handler.beforeInsert();
        Test.stopTest();

        // Assert
        System.assert(testCase.hasErrors(), 'The NorlysNow case should have an error.');
        System.assertEquals(
            'You are not allowed to create or update NorlysNow Cases on a closed Case',
            testCase.getErrors()[0].getMessage(),
            'The error message is not the one expected.'
        );
        TriggerHandler.clearAllBypasses();
    }

    /**
     * @description Tests that when a NorlysNow_Case__c is inserted but the user does NOT have the
     *              required permission, the handler exits gracefully without publishing any events.
     */
    @isTest
    static void afterInsert_WithoutPermission_ShouldNotPublishEvent() {
        // Arrange
        TriggerHandler.bypass('NorlysNowCaseTriggerHandler');
        setupMocks();
        NorlysTestScenarios.ScenarioResult scenario = NorlysTestScenarios.newBuilder()
            .forNorlysNowCaseHandling()
            .withNorlysNowCases(1)
            .build();
        
        permissionServiceMock.spyOn('hasPermissionSet').whenCalledWith(Argument.ofType(List<String>.class)).thenReturn(false);
        // Initialize the spy for the 'publish' method so we can check its call log later.
        eventExecutorServiceMock.spyOn('publish');
        
        NorlysNowCaseTriggerHandler handler = new NorlysNowCaseTriggerHandler();
        handler.triggerNew = scenario.norlysNowCases;
        handler.triggerNewMap = new Map<Id, NorlysNow_Case__c>(scenario.norlysNowCases);

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
     * @description Tests that the parent Case is NOT closed if the current NorlysNow_Case__c is closed,
     *              but other sibling NorlysNow_Case__c records under the same parent are still open.
     */
    @isTest
    static void afterUpdate_WithOpenChildCases_ShouldNotCloseParentCase() {
        // Arrange
        TriggerHandler.bypass('NorlysNowCaseTriggerHandler');
        setupMocks();
        NorlysTestScenarios.ScenarioResult scenario = NorlysTestScenarios.newBuilder()
            .forNorlysNowCaseHandling()
            .withNorlysNowCases(2)
            .build();
        
        NorlysNow_Case__c caseToClose = scenario.norlysNowCases[0];
        caseToClose.Status__c = 'Closed';
        
        NorlysNow_Case__c openCase = scenario.norlysNowCases[1];
        openCase.Status__c = 'New';

        Map<Id, NorlysNow_Case__c> caseMap = new Map<Id, NorlysNow_Case__c>{ caseToClose.Id => caseToClose };

        // --- Mock Service Calls ---
        norlysNowSelectorMock.spyOn('getNorlysNowCasesMap').whenCalledWith(Argument.any()).thenReturn(caseMap);
        norlysNowSelectorMock.spyOn('getAllNorlysNowCasesUnderParentCases').whenCalledWith(Argument.any()).thenReturn(scenario.norlysNowCases);
        permissionServiceMock.spyOn('hasPermissionSet').whenCalledWith(Argument.ofType(List<String>.class)).thenReturn(false);

        NorlysNowCaseTriggerHandler handler = new NorlysNowCaseTriggerHandler();
        handler.triggerNewMap = caseMap;

        // Act
        Test.startTest();
        handler.afterUpdate();
        Test.stopTest();

        // Assert
        System.assertEquals(0, dbMock.register.updated.size(), 'No records should have been updated.');
        TriggerHandler.clearAllBypasses();
    }

    /**
     * @description Tests the afterUpdate logic to ensure an event is published when a case's
     *              status is updated to 'Withdrawn', given the user has permissions.
     */
    @isTest
    static void afterUpdate_WithdrawnStatus_ShouldPublishEvent() {
        // Arrange
        TriggerHandler.bypass('NorlysNowCaseTriggerHandler');
        setupMocks();
        NorlysTestScenarios.ScenarioResult scenario = NorlysTestScenarios.newBuilder()
            .forNorlysNowCaseHandling()
            .withNorlysNowCases(1)
            .build();
        
        NorlysNow_Case__c testCase = scenario.norlysNowCases[0];
        testCase.Status__c = 'Withdrawn';
        
        Map<Id, NorlysNow_Case__c> caseMap = new Map<Id, NorlysNow_Case__c>{ testCase.Id => testCase };

        // --- Mock Service Calls ---
        norlysNowSelectorMock.spyOn('getNorlysNowCasesMap').whenCalledWith(Argument.any()).thenReturn(caseMap);
        permissionServiceMock.spyOn('hasPermissionSet').whenCalledWith(Argument.ofType(List<String>.class)).thenReturn(true);
        eventExecutorServiceMock.spyOn('publish').whenCalledWith(Argument.any()).thenReturn(null);

        NorlysNowCaseTriggerHandler handler = new NorlysNowCaseTriggerHandler();
        handler.triggerNewMap = caseMap;

        // Act
        Test.startTest();
        handler.afterUpdate();
        Test.stopTest();

        // Assert
        MethodSpy publishSpy = eventExecutorServiceMock.getSpy('publish');
        System.assertEquals(1, publishSpy.callLog.size(), 'The publish method should have been called once.');
        TriggerHandler.clearAllBypasses();
    }
}
