/**
 * @description Test class for the NorlysNowCaseStrategy. This class ensures that the strategy
 *              correctly processes NorlysNow_Case__c records, sends them to the NorlysNow API,
 *              and handles both success and error responses.
 * -----------------------------------------------------------------------------
 * Developer            Date            Description
 * -----------------------------------------------------------------------------
 * Jules                2025-09-14      Initial version.
 */
@isTest
private class NorlysNowCaseStrategyTest {
    private static Mock norlysNowServiceMock;
    private static Mock norlysNowSelectorMock;
    private static Mock norlysNowClientMock;
    private static DatabaseService databaseServiceStub;

    /**
     * @description Sets up the test environment by mocking all the necessary service dependencies.
     *              This is called by each test method to ensure a clean and predictable state.
     */
    private static void setupMocks() {
        // Create mocks for all service dependencies
        norlysNowServiceMock = Mock.forType(NorlysNowService.class);
        norlysNowSelectorMock = Mock.forType(NorlysNowSelector.class);
        norlysNowClientMock = Mock.forType(NorlysNowClient.class);
        databaseServiceStub = new DatabaseService().mockDmls();

        // Get the stub instances from the mocks
        NorlysNowService norlysNowServiceStub = (NorlysNowService) norlysNowServiceMock.stub;
        NorlysNowSelector norlysNowSelectorStub = (NorlysNowSelector) norlysNowSelectorMock.stub;
        NorlysNowClient norlysNowClientStub = (NorlysNowClient) norlysNowClientMock.stub;

        // Register all the singleton services with our stubs so the handler will use them
        SingletonFactory factory = SingletonFactory.getFactory();
        factory.registerSingleton(NorlysNowService.class, norlysNowServiceStub);
        factory.registerSingleton(NorlysNowSelector.class, norlysNowSelectorStub);
        factory.registerSingleton(NorlysNowClient.class, norlysNowClientStub);
        factory.registerSingleton(DatabaseService.class, databaseServiceStub);
    }

    @isTest
    static void toExecute_OnSuccess_ShouldUpdateCaseAndReturnEmptySet() {
        // Arrange
        setupMocks();
        NorlysTestScenarios.ScenarioResult scenario = NorlysTestScenarios.newBuilder()
            .forNorlysNowCaseHandling()
            .withNorlysNowCases(1)
            .build();

        NorlysNow_Case__c testCase = scenario.norlysNowCases[0];
        Set<Id> recordIds = new Set<Id>{ testCase.Id };

        EventExecutor__e testEvent = new EventExecutor__e(
            Parameters__c = '{"recordIds":["' + testCase.Id + '"]}'
        );

        // --- Mock Service Calls ---
        NorlysNowService.Parameters params = new NorlysNowService.Parameters();
        params.recordIds = recordIds;
        norlysNowServiceMock.spyOn('getParameters').whenCalledWith(testEvent.Parameters__c).thenReturn(params);

        Map<Id, NorlysNow_Case__c> caseMap = new Map<Id, NorlysNow_Case__c>{ testCase.Id => testCase };
        norlysNowSelectorMock.spyOn('getNorlysNowCasesMap').whenCalledWith(recordIds).thenReturn(caseMap);

        HttpResponse successResponse = new HttpResponse();
        successResponse.setStatusCode(200);
        successResponse.setBody('{"result":{"created record number":"CASE123"}}');
        norlysNowClientMock.spyOn('sentRequestNorlysNowCase').whenCalledWith(Argument.any()).thenReturn(successResponse);

        norlysNowServiceMock.spyOn('createCaseRequestObject').whenCalledWith(Argument.any()).thenReturn(new NorlysNowClientRequestDTO());
        MethodSpy setSuccessSpy = norlysNowServiceMock.spyOn('setSuccessOnNorlysNowCase');
        setSuccessSpy.whenCalledWith(Argument.any()).thenReturn(new NorlysNow_Case__c());

        NorlysNowCaseStrategy strategy = new NorlysNowCaseStrategy();

        // Act
        Test.startTest();
        Set<Id> remainingIds = strategy.toExecute(testEvent);
        Test.stopTest();

        // Assert
        System.assertEquals(0, remainingIds.size(), 'The returned set of IDs should be empty on success.');
        System.assertEquals(1, databaseServiceStub.register.updated.size(), 'The databaseService.updateRecords method should have been called once.');
        System.assertEquals(1, setSuccessSpy.callLog.size(), 'setSuccessOnNorlysNowCase should have been called once.');
        List<Object> firstCallArgs = setSuccessSpy.callLog.get(0);
        NorlysNow_Case__c processedCase = (NorlysNow_Case__c)firstCallArgs[0];
        System.assertEquals('CASE123', processedCase.NorlysNow_Id__c, 'The NorlysNow Id should be set on the case before being passed to the service.');
    }

    @isTest
    static void toExecute_OnHttpException_ShouldUpdateCaseAndCreateTask() {
        // Arrange
        setupMocks();
        NorlysTestScenarios.ScenarioResult scenario = NorlysTestScenarios.newBuilder()
            .forNorlysNowCaseHandling()
            .withNorlysNowCases(1)
            .build();

        NorlysNow_Case__c testCase = scenario.norlysNowCases[0];
        Set<Id> recordIds = new Set<Id>{ testCase.Id };

        EventExecutor__e testEvent = new EventExecutor__e(
            Parameters__c = '{"recordIds":["' + testCase.Id + '"]}'
        );

        // --- Mock Service Calls ---
        NorlysNowService.Parameters params = new NorlysNowService.Parameters();
        params.recordIds = recordIds;
        norlysNowServiceMock.spyOn('getParameters').whenCalledWith(testEvent.Parameters__c).thenReturn(params);

        Map<Id, NorlysNow_Case__c> caseMap = new Map<Id, NorlysNow_Case__c>{ testCase.Id => testCase };
        norlysNowSelectorMock.spyOn('getNorlysNowCasesMap').whenCalledWith(recordIds).thenReturn(caseMap);

        HTTPException testException = new HTTPException('Error');
        norlysNowClientMock.spyOn('sentRequestNorlysNowCase').whenCalledWith(Argument.any()).thenThrow(testException);

        norlysNowServiceMock.spyOn('createCaseRequestObject').whenCalledWith(Argument.any()).thenReturn(new NorlysNowClientRequestDTO());
        norlysNowServiceMock.spyOn('setErrorOnNorlysNowCase').whenCalledWith(testCase, testException.getMessage()).thenReturn(testCase);
        MethodSpy createTasksSpy = norlysNowServiceMock.spyOn('createFollowUpTasks');
        createTasksSpy.whenCalledWith(Argument.any(), Argument.any(), Argument.any(), Argument.any()).thenReturn(null);

        NorlysNowCaseStrategy strategy = new NorlysNowCaseStrategy();

        // Act
        Test.startTest();
        Set<Id> remainingIds = strategy.toExecute(testEvent);
        Test.stopTest();

        // Assert
        System.assertEquals(0, remainingIds.size(), 'The returned set of IDs should be empty on a non-retryable error.');
        System.assertEquals(1, databaseServiceStub.register.updated.size(), 'The databaseService.updateRecords method should have been called once.');
        System.assertEquals(1, createTasksSpy.callLog.size(), 'The createFollowUpTasks method should have been called once.');
    }

    @isTest
    static void toExecute_OnCalloutException_ShouldUpdateCaseAndCreateTask() {
        // Arrange
        setupMocks();
        NorlysTestScenarios.ScenarioResult scenario = NorlysTestScenarios.newBuilder()
            .forNorlysNowCaseHandling()
            .withNorlysNowCases(1)
            .build();

        NorlysNow_Case__c testCase = scenario.norlysNowCases[0];
        Set<Id> recordIds = new Set<Id>{ testCase.Id };

        EventExecutor__e testEvent = new EventExecutor__e(
            Parameters__c = '{"recordIds":["' + testCase.Id + '"]}'
        );

        // --- Mock Service Calls ---
        NorlysNowService.Parameters params = new NorlysNowService.Parameters();
        params.recordIds = recordIds;
        norlysNowServiceMock.spyOn('getParameters').whenCalledWith(testEvent.Parameters__c).thenReturn(params);

        Map<Id, NorlysNow_Case__c> caseMap = new Map<Id, NorlysNow_Case__c>{ testCase.Id => testCase };
        norlysNowSelectorMock.spyOn('getNorlysNowCasesMap').whenCalledWith(recordIds).thenReturn(caseMap);

        System.CalloutException testException = new System.CalloutException('Error');
        norlysNowClientMock.spyOn('sentRequestNorlysNowCase').whenCalledWith(Argument.any()).thenThrow(testException);

        norlysNowServiceMock.spyOn('createCaseRequestObject').whenCalledWith(Argument.any()).thenReturn(new NorlysNowClientRequestDTO());
        norlysNowServiceMock.spyOn('setErrorOnNorlysNowCase').whenCalledWith(testCase, testException.getMessage()).thenReturn(testCase);
        MethodSpy createTasksSpy = norlysNowServiceMock.spyOn('createFollowUpTasks');
        createTasksSpy.whenCalledWith(Argument.any(), Argument.any(), Argument.any(), Argument.any()).thenReturn(null);

        NorlysNowCaseStrategy strategy = new NorlysNowCaseStrategy();

        // Act
        Test.startTest();
        Set<Id> remainingIds = strategy.toExecute(testEvent);
        Test.stopTest();

        // Assert
        System.assertEquals(0, remainingIds.size(), 'The returned set of IDs should be empty on a callout exception.');
        System.assertEquals(1, databaseServiceStub.register.updated.size(), 'The databaseService.updateRecords method should have been called once.');
        System.assertEquals(1, createTasksSpy.callLog.size(), 'The createFollowUpTasks method should have been called once.');
    }
}
