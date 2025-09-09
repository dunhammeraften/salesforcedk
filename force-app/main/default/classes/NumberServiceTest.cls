@IsTest
private with sharing class NumberServiceTest {
    private static final String ERROR_RESPONSE_BODY = '{"error":{"code":400,"message":"Validation Failed with following issue(s)","parameters":[{"key":"YOU_DID_BAD","value":"And you should feel bad about it"}]}}';
    private static final String INVALID_JSON = '{"thisIsNotValidJson":""';

    @IsTest
    private static void testGetNumberDetailsSuccess() {
        Integer amountOfNumbers = 2;
        String cvr = '11221122';
        String numberPattern = '85*';
        String availableNumberStatus = 'AA';
        String body = '{"data":[{"countryCode":"45","id":"4585307625","number":"85307625","numberGroup":"P","numberLocation":"BUS","numberStatus":"AA","productType":["GSM"]},{"countryCode":"45","id":"4585406390","number":"85406390","numberGroup":"P","numberLocation":"BUS","numberStatus":"AA","productType":["GSM"]}],"pageSize":2}';
        HttpResponseMock mockResponse = new HttpResponseMock(200, 'OK', body);
        Test.setMock(HttpCalloutMock.class, mockResponse);

        Test.startTest();
        NumberService.GetNumbersParameterbuilder parameters = new NumberService.GetNumbersParameterbuilder()
            .withCvr(cvr)
            .withNumberPattern(numberPattern)
            .withNumberStatus(availableNumberStatus)
            .withAmountOfNumbers(amountOfNumbers);

        NumberResDAO.NumberDetails numberDetails = NumberService.getNumberDetails(parameters);
        Test.stopTest();

        Assert.isNull(numberDetails.error, 'No error should be returned');
        Assert.isFalse(numberDetails.data.isEmpty(), 'Data should contain entries');
        Assert.areEqual(amountOfNumbers, numberDetails.data.size(), 'Amount of number details should match the amount of numbers requested');
        Assert.isTrue(getNumberServiceLogs().isEmpty(), 'No logs should be created');
    }

    @IsTest
    private static void testGetNumberDetailsError() {
        Integer amountOfNumbers = 2;
        String badNumberStatus = 'badValue';
        HttpResponseMock mockResponse = new HttpResponseMock(400, 'Bad Request', ERROR_RESPONSE_BODY);
        Test.setMock(HttpCalloutMock.class, mockResponse);

        Test.startTest();
        NumberService.GetNumbersParameterbuilder parameters = new NumberService.GetNumbersParameterbuilder()
            .withNumberStatus(badNumberStatus)
            .withAmountOfNumbers(amountOfNumbers);

        NumberResDAO.NumberDetails numberDetails = NumberService.getNumberDetails(parameters);
        Test.stopTest();

        Assert.isNotNull(numberDetails.error, 'An error object should be returned');
        Assert.isFalse(numberDetails.error.parameters.isEmpty(), 'Error parameters should be returned');
        Assert.isNull(numberDetails.data, 'Data should not be returned');
        Assert.isTrue(getNumberServiceLogs().isEmpty(), 'No logs should be created');
    }

    @IsTest
    private static void testGetNumberDetailsException() {
        Integer amountOfNumbers = 2;
        String availableNumberStatus = 'AA';
        String numberGroup = 'P';
        String numberLocation = 'BUS';
        String productType = 'GSM';
        String body = INVALID_JSON;
        HttpResponseMock mockResponse = new HttpResponseMock(500, 'Server error', body);
        Test.setMock(HttpCalloutMock.class, mockResponse);

        Test.startTest();
        NumberService.GetNumbersParameterbuilder parameters = new NumberService.GetNumbersParameterbuilder()
            .withNumberStatus(availableNumberStatus)
            .withAmountOfNumbers(amountOfNumbers)
            .withNumberGroup(numberGroup)
            .withNumberLocation(numberLocation);

        NumberResDAO.NumberDetails numberDetails = NumberService.getNumberDetails(parameters);
        Test.stopTest();

        Assert.isNotNull(numberDetails.error.message, 'Exception should return an error message');
        List<System_Log__c> logs = getNumberServiceLogs();
        Assert.areEqual(1, logs.size(), 'Exactly one log should be created');
        Assert.isTrue(logs[0].Additional_Information__c.contains('getNumberDetails'), 'Log should contain method name');
    }

    @IsTest
    private static void testGetNumberDetailByMsisdnSuccess() {
        String msisdn = '4585307625';
        String body = '{"data":{"countryCode":"45","id":"' + msisdn + '","number":"85317658","numberGroup":"P","numberLocation":"BUS","numberStatus":"AA","productType":["GSM"]}}';
        HttpResponseMock mockResponse = new HttpResponseMock(200, 'OK', body);
        Test.setMock(HttpCalloutMock.class, mockResponse);

        Test.startTest();
        NumberResDAO.NumberDetail numberDetail = NumberService.getNumberDetailByMsisdn(msisdn);
        Test.stopTest();

        Assert.isNull(numberDetail.error, 'No error should be returned');
        Assert.isNotNull(numberDetail.data, 'Data should be returned');
        Assert.areEqual(msisdn, numberDetail.data.id, 'Provided msisdn should match returned id');
        Assert.isTrue(getNumberServiceLogs().isEmpty(), 'No logs should be created');
    }

    @IsTest
    private static void testGetNumberDetailByMsisdnError() {
        String msisdn = '4585307625';
        HttpResponseMock mockResponse = new HttpResponseMock(400, 'Bad Request', ERROR_RESPONSE_BODY);
        Test.setMock(HttpCalloutMock.class, mockResponse);

        Test.startTest();
        NumberResDAO.NumberDetail numberDetail = NumberService.getNumberDetailByMsisdn(msisdn);
        Test.stopTest();

        Assert.isNotNull(numberDetail.error, 'An error object should be returned');
        Assert.isFalse(numberDetail.error.parameters.isEmpty(), 'Error parameters should be returned');
        Assert.isNull(numberDetail.data, 'Data should not be returned');
        Assert.isTrue(getNumberServiceLogs().isEmpty(), 'No logs should be created');
    }

    @IsTest
    private static void testGetNumberDetailByMsisdnException() {
        String msisdn = '4585307625';
        String body = INVALID_JSON;
        HttpResponseMock mockResponse = new HttpResponseMock(500, 'Server error', body);
        Test.setMock(HttpCalloutMock.class, mockResponse);

        Test.startTest();
        NumberResDAO.NumberDetail numberDetail = NumberService.getNumberDetailByMsisdn(msisdn);
        Test.stopTest();

        Assert.isNotNull(numberDetail.error.message, 'Exception should return an error message');
        List<System_Log__c> logs = getNumberServiceLogs();
        Assert.areEqual(1, logs.size(), 'Exactly one log should be created');
        Assert.isTrue(logs[0].Additional_Information__c.contains('getNumberDetailByMsisdn'), 'Log should contain method name');
    }

    @IsTest
    private static void testReserveNumberByMsisdnSuccess() {
        String msisdn = '4585307625';
        String body = '{"data":{"countryCode":"45","id":"' + msisdn + '","number":"85317658","numberGroup":"P","numberLocation":"BUS","numberStatus":"AA","productType":["GSM"]}}';
        HttpResponseMock mockResponse = new HttpResponseMock(200, 'OK', body);
        Test.setMock(HttpCalloutMock.class, mockResponse);

        Test.startTest();
        NumberResDAO.NumberDetail numberDetail = NumberService.reserveNumberByMsisdn(msisdn);
        Test.stopTest();

        Assert.isNull(numberDetail.error, 'No error should be returned');
        Assert.isNotNull(numberDetail.data, 'Data should be returned');
        Assert.areEqual(msisdn, numberDetail.data.id, 'Provided msisdn should match returned id');
        Assert.isTrue(getNumberServiceLogs().isEmpty(), 'No logs should be created');
    }

    @IsTest
    private static void testReserveNumberByMsisdnError() {
        String msisdn = '4585307625';
        HttpResponseMock mockResponse = new HttpResponseMock(400, 'Bad Request', ERROR_RESPONSE_BODY);
        Test.setMock(HttpCalloutMock.class, mockResponse);

        Test.startTest();
        NumberResDAO.NumberDetail numberDetail = NumberService.reserveNumberByMsisdn(msisdn);
        Test.stopTest();

        Assert.isNotNull(numberDetail.error, 'An error object should be returned');
        Assert.isFalse(numberDetail.error.parameters.isEmpty(), 'Error parameters should be returned');
        Assert.isNull(numberDetail.data, 'Data should not be returned');
        Assert.isTrue(getNumberServiceLogs().isEmpty(), 'No logs should be created');
    }

    @IsTest
    private static void testReserveNumberByMsisdnException() {
        String msisdn = '4585307625';
        String body = INVALID_JSON;
        HttpResponseMock mockResponse = new HttpResponseMock(500, 'Server error', body);
        Test.setMock(HttpCalloutMock.class, mockResponse);

        Test.startTest();
        NumberResDAO.NumberDetail numberDetail = NumberService.reserveNumberByMsisdn(msisdn);
        Test.stopTest();

        Assert.isNotNull(numberDetail.error.message, 'Exception should return an error message');
        List<System_Log__c> logs = getNumberServiceLogs();
        Assert.areEqual(1, logs.size(), 'Exactly one log should be created');
        Assert.isTrue(logs[0].Additional_Information__c.contains('reserveNumberByMsisdnAndCvr'), 'Log should contain method name');
    }

    @IsTest
    private static void testUnreserveNumberByMsisdnSuccess() {
        String msisdn = '4585307625';
        String body = '{"data":{"countryCode":"45","id":"' + msisdn + '","number":"85317658","numberGroup":"P","numberLocation":"BUS","numberStatus":"AR"}}';
        HttpResponseMock mockResponse = new HttpResponseMock(200, 'OK', body);
        Test.setMock(HttpCalloutMock.class, mockResponse);

        Test.startTest();
        NumberResDAO.NumberDetail numberDetail = NumberService.unreserveNumberByMsisdn(msisdn);
        Test.stopTest();

        Assert.isNull(numberDetail.error, 'No error should be returned');
        Assert.isNotNull(numberDetail.data, 'Data should be returned');
        Assert.areEqual(msisdn, numberDetail.data.id, 'Provided msisdn should match returned id');
        Assert.isTrue(getNumberServiceLogs().isEmpty(), 'No logs should be created');
    }

    @IsTest
    private static void testUnreserveNumberByMsisdnError() {
        String msisdn = '4585307625';
        HttpResponseMock mockResponse = new HttpResponseMock(400, 'Bad Request', ERROR_RESPONSE_BODY);
        Test.setMock(HttpCalloutMock.class, mockResponse);

        Test.startTest();
        NumberResDAO.NumberDetail numberDetail = NumberService.unreserveNumberByMsisdn(msisdn);
        Test.stopTest();

        Assert.isNotNull(numberDetail.error, 'An error object should be returned');
        Assert.isFalse(numberDetail.error.parameters.isEmpty(), 'Error parameters should be returned');
        Assert.isNull(numberDetail.data, 'Data should not be returned');
        Assert.isTrue(getNumberServiceLogs().isEmpty(), 'No logs should be created');
    }

    @IsTest
    private static void testUnreserveNumberByMsisdnException() {
        String msisdn = '4585307625';
        String body = INVALID_JSON;
        HttpResponseMock mockResponse = new HttpResponseMock(500, 'Server error', body);
        Test.setMock(HttpCalloutMock.class, mockResponse);

        Test.startTest();
        NumberResDAO.NumberDetail numberDetail = NumberService.unreserveNumberByMsisdn(msisdn);
        Test.stopTest();

        Assert.isNotNull(numberDetail.error.message, 'Exception should return an error message');
        List<System_Log__c> logs = getNumberServiceLogs();
        Assert.areEqual(1, logs.size(), 'Exactly one log should be created');
        Assert.isTrue(logs[0].Additional_Information__c.contains('unreserveNumberByMsisdn'), 'Log should contain method name');
    }

    @IsTest
    private static void testGetPortOrdersByMsisdnsSuccess() {
        List<String> msisdns = new List<String>{'4527771499','4560376690'};
        String body = '{"data":[{"currentStatusCode":10,"externalStatusCode":"600","iccNumber":"89450401061109595817","msisdn":"4527771499","ochNumber":"200022152041","orderId":11721967,"portingCase":"PortedNonGeo","requestExecutionDate":"2014-06-02T03:56:20","subStatusCode":"COMPLETE","transactionStatusCode":"S"},{"currentStatusCode":9,"externalStatusCode":"600","msisdn":"4560376690","ochNumber":"200024690130","orderId":12420737,"portingCase":"NonPorted","subStatusCode":"IN_PROGRESS","transactionStatusCode":"S"}]}';
        HttpResponseMock mockResponse = new HttpResponseMock(200, 'OK', body);
        Test.setMock(HttpCalloutMock.class, mockResponse);

        Test.startTest();
        NumberResDAO.PortOrders portOrders = NumberService.getPortOrdersByMsisdns(msisdns);
        Test.stopTest();

        Assert.isNull(portOrders.error, 'No error should be returned');
        Assert.isNotNull(portOrders.data, 'Data should be returned');
        Assert.areEqual(msisdns.size(), portOrders.data.size(), 'Amount of returned port orders should match amount of provided msisdns');
        Assert.isTrue(getNumberServiceLogs().isEmpty(), 'No logs should be created');
    }

    @IsTest
    private static void testGetPortOrdersByMsisdnsError() {
        List<String> msisdns = new List<String>{'4527771499','4560376690'};
        HttpResponseMock mockResponse = new HttpResponseMock(400, 'Bad request', ERROR_RESPONSE_BODY);
        Test.setMock(HttpCalloutMock.class, mockResponse);

        Test.startTest();
        NumberResDAO.PortOrders portOrders = NumberService.getPortOrdersByMsisdns(msisdns);
        Test.stopTest();

        Assert.isNotNull(portOrders.error, 'An error object should be returned');
        Assert.isFalse(portOrders.error.parameters.isEmpty(), 'Error parameters should be returned');
        Assert.isNull(portOrders.data, 'Data should not be returned');
        Assert.isTrue(getNumberServiceLogs().isEmpty(), 'No logs should be created');
    }

    @IsTest
    private static void testGetPortOrdersByMsisdnsException() {
        List<String> msisdns = new List<String>{'4527771499','4560376690'};
        String body = INVALID_JSON;
        HttpResponseMock mockResponse = new HttpResponseMock(500, 'Server error', body);
        Test.setMock(HttpCalloutMock.class, mockResponse);

        Test.startTest();
        NumberResDAO.PortOrders portOrders = NumberService.getPortOrdersByMsisdns(msisdns);
        Test.stopTest();

        Assert.isNotNull(portOrders.error.message, 'Exception should return an error message');
        List<System_Log__c> logs = getNumberServiceLogs();
        Assert.areEqual(1, logs.size(), 'Exactly one log should be created');
        Assert.isTrue(logs[0].Additional_Information__c.contains('getPortOrdersByMsisdns'), 'Log should contain method name');
    }

    // use new SystemLogSelector class instead
    private static List<System_Log__c> getNumberServiceLogs() {
        return SystemLogSelector.getLogsByAdditionalInformationLike(NumberService.class.getName() + '%');
    }
}