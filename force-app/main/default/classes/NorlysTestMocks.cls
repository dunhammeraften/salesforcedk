/**
 * @description Provides reusable, configurable mocks for test data setup.
 * @group SUnit
 */
@isTest
public class NorlysTestMocks {

    /**
     * @description Private constructor to prevent instantiation.
     */
    private NorlysTestMocks() {}

    public class NumberClientMockBuilder {
        private Mock mockProvider;

        public NumberClientMockBuilder() {
            this.mockProvider = Mock.forType(NumberClient.class);
        }

        public NumberClientMockBuilder withSuccessOnUnreserve() {
            NumberClientResponseDTO.NumberDetail tmpResponse = new NumberClientResponseDTO.NumberDetail();
            tmpResponse.data = new NumberClientResponseDTO.NumberData();
            tmpResponse.data.id = '12345678';
            tmpResponse.data.numberStatus = 'AA';
            this.mockProvider.spyOn('unreserveNumberDetailByMsisdn').whenCalledWith(Argument.any()).thenReturn(tmpResponse);
            return this;
        }

        public NumberClientMockBuilder withSuccessOnReserve() {
            NumberClientResponseDTO.NumberDetail numberDetail = new NumberClientResponseDTO.NumberDetail();
            numberDetail.data = new NumberClientResponseDTO.NumberData();
            numberDetail.data.id = '4511223344';
            this.mockProvider.spyOn('reserveNumberDetailByMsisdnAndCVR').whenCalledWith(Argument.any(), Argument.any(), Argument.any()).thenReturn(numberDetail);
            return this;
        }

        public NumberClientMockBuilder withFailureOnReserve(Exception ex) {
            this.mockProvider.spyOn('reserveNumberDetailByMsisdnAndCVR').throwsException(ex);
            return this;
        }

        public NumberClient build() {
            return (NumberClient) this.mockProvider.stub;
        }
    }

    public static NumberClientMockBuilder forNumberClient() {
        return new NumberClientMockBuilder();
    }

    public class NorlysNowServiceMockBuilder {
        private Mock mockProvider;
        public NorlysNowServiceMockBuilder() {
            this.mockProvider = Mock.forType(NorlysNowService.class);
        }

        public NorlysNowServiceMockBuilder withCloseParentCases(List<Case> result) {
            this.mockProvider.spyOn('closeParentCases').whenCalledWith(Argument.any()).thenReturn(result);
            return this;
        }

        public NorlysNowServiceMockBuilder withChunkedEvents(List<EventExecutor__e> result) {
            this.mockProvider.spyOn('chunkEventsInListsToBePublished').whenCalledWith(Argument.any(), Argument.any(), Argument.any()).thenReturn(result);
            return this;
        }

        public NorlysNowServiceMockBuilder withCheckParentCaseIsClosed() {
            this.mockProvider.spyOn('CheckParentCaseIsClosed');
            return this;
        }

        public NorlysNowService build() {
            return (NorlysNowService) this.mockProvider.stub;
        }

        public MethodSpy getCheckParentCaseIsClosedSpy() {
            return this.mockProvider.getSpy('CheckParentCaseIsClosed');
        }
    }

    public static NorlysNowServiceMockBuilder forNorlysNowService() {
        return new NorlysNowServiceMockBuilder();
    }

    public class NorlysNowSelectorMockBuilder {
        private Mock mockProvider;
        public NorlysNowSelectorMockBuilder() {
            this.mockProvider = Mock.forType(NorlysNowSelector.class);
        }

        public NorlysNowSelectorMockBuilder withNorlysNowCases(Map<Id, NorlysNow_Case__c> result) {
            this.mockProvider.spyOn('getNorlysNowCasesMap').whenCalledWith(Argument.any()).thenReturn(result);
            return this;
        }

        public NorlysNowSelectorMockBuilder withClosedParentCase(Id parentCaseId) {
            Case closedCase = new Case(Id = parentCaseId, Status = 'Closed');
            this.mockProvider.spyOn('getCasesByIds')
                .whenCalledWith(Argument.any())
                .thenReturn(new Map<Id, Case>{ parentCaseId => closedCase });
            return this;
        }

        public NorlysNowSelector build() {
            return (NorlysNowSelector) this.mockProvider.stub;
        }
    }

    public static NorlysNowSelectorMockBuilder forNorlysNowSelector() {
        return new NorlysNowSelectorMockBuilder();
    }

    public class PermissionServiceMockBuilder {
        private Mock mockProvider;
        public PermissionServiceMockBuilder() {
            this.mockProvider = Mock.forType(PermissionService.class);
        }

        public PermissionServiceMockBuilder withHasPermissionSet(Boolean result) {
            this.mockProvider.spyOn('hasPermissionSet').whenCalledWith(Argument.any()).thenReturn(result);
            return this;
        }

        public PermissionService build() {
            return (PermissionService) this.mockProvider.stub;
        }
    }

    public static PermissionServiceMockBuilder forPermissionService() {
        return new PermissionServiceMockBuilder();
    }

    public class EventExecutorServiceMockBuilder {
        private Mock mockProvider;
        public EventExecutorServiceMockBuilder() {
            this.mockProvider = Mock.forType(EventExecutorService.class);
        }

        public EventExecutorServiceMockBuilder withPublish() {
            this.mockProvider.spyOn('publish');
            return this;
        }

        public EventExecutorService build() {
            return (EventExecutorService) this.mockProvider.stub;
        }

        public MethodSpy getPublishSpy() {
            return this.mockProvider.getSpy('publish');
        }
    }

    public static EventExecutorServiceMockBuilder forEventExecutorService() {
        return new EventExecutorServiceMockBuilder();
    }

    /**
     * @description Creates a mock EventExecutor__e for testing handlers.
     * @param handlerName The name of the handler to be executed.
     * @param parameters A map of parameters to be serialized into the event's Parameters__c field.
     * @return A new EventExecutor__e instance.
     */
    public static EventExecutor__e createEventExecutor(String handlerName, Map<String, Object> parameters) {
        return new EventExecutor__e(
            Executor__c = handlerName,
            Parameters__c = JSON.serialize(parameters)
        );
    }
}