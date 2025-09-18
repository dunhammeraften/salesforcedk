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