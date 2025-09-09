@IsTest
private with sharing class NumbersGetByCvrActionTest {
    private static final String ERROR_RESPONSE = '{"error":{"code":400,"message":"Validation Failed with following issue(s)","parameters":[{"key":"YOU_DID_BAD","value":"And you should feel bad about it"}]}}';

    private static String namedCredential = NamedCredentialService.getNamedCredential('NumberApi');

    @IsTest
    private static void testGetAssignedAvailableByCvrSuccess() {
        NumbersGetByCvrAction.Request request = new NumbersGetByCvrAction.Request();
        request.cvr = '12345678';
        request.amountOfNumbers = 2;
        String body = '{"data":[{"countryCode":"45","id":"4585307625","number":"85307625","numberGroup":"P","numberLocation":"BUS","numberStatus":"AA","productType":["GSM"]},{"countryCode":"45","id":"4585406390","number":"85406390","numberGroup":"P","numberLocation":"SAL","numberStatus":"AA","productType":["GSM"]}],"pageSize":2}';
        HttpResponseMock mockResponse = new HttpResponseMock(200, 'OK', body);
        Test.setMock(HttpCalloutMock.class, mockResponse);

        Test.startTest();
        List<NumbersGetByCvrAction.Response> responses = NumbersGetByCvrAction.invoke(new List<NumbersGetByCvrAction.Request>{request});
        Test.stopTest();

        Assert.areEqual(1, responses.size(), 'Exactly one response should be returned');
        NumbersGetByCvrAction.Response response = responses[0];

        Assert.isTrue(response.isSuccess, 'Response should be successful');
        Assert.areEqual(request.amountOfNumbers, response.numbersByCvrInAssignedAvailableStatus.size(), 'The amount of AA numbers by CVR in response should match the request');
        Assert.isTrue(response.numbersByCvrInAssignedReservedStatus.isEmpty(), 'No AR numbers by CVR should be returned');
        Assert.isTrue(response.numbersWithoutCvrInAssignedAvailableStatus.isEmpty(), 'No AA numbers without CVR should be returned');
    }

    @IsTest
    private static void testGetAssignedAvailableAndAssignedReservedByCvrSuccess() {
        NumbersGetByCvrAction.Request request = new NumbersGetByCvrAction.Request();
        request.cvr = '12345678';
        request.amountOfNumbers = 2;

        String endpointAssignedAvailable = 'callout:' + namedCredential + '?' + getUrlQueryParametersWithCvr(NumbersGetByCvrAction.ASSIGNED_AVAILABLE, request.amountOfNumbers, request.cvr);
        String bodyAssignedAvailable = '{"data":[{"countryCode":"45","id":"4585307625","number":"85307625","numberGroup":"P","numberLocation":"BUS","numberStatus":"AA","productType":["GSM"]}],"pageSize":1}';
        HttpResponseMock mockResponseAssignedAvailable = new HttpResponseMock(200, 'OK', bodyAssignedAvailable);

        String endpointAssignedReserved = 'callout:' + namedCredential + '?' + getUrlQueryParametersWithCvr(NumbersGetByCvrAction.ASSIGNED_RESERVED, request.amountOfNumbers - 1, request.cvr);
        String bodyAssignedReserved = '{"data":[{"countryCode":"45","id":"4585307625","number":"85307625","numberGroup":"P","numberLocation":"BUS","numberStatus":"AR","productType":["GSM"]}],"pageSize":1}';
        HttpResponseMock mockResponseAssignedReserved = new HttpResponseMock(200, 'OK', bodyAssignedReserved);

        Map<String, HttpResponseMock> endpoint2HttpCalloutMock = new Map<String, HttpResponseMock>{
            endpointAssignedAvailable => mockResponseAssignedAvailable,
            endpointAssignedReserved => mockResponseAssignedReserved
        };
        HttpResponseMock mockResponseMulti = new HttpResponseMock(endpoint2HttpCalloutMock);
        Test.setMock(HttpCalloutMock.class, mockResponseMulti);

        Test.startTest();
        NumbersGetByCvrAction.Response response = NumbersGetByCvrAction.invoke(new List<NumbersGetByCvrAction.Request>{request})[0];
        Test.stopTest();

        Assert.isTrue(response.isSuccess, 'Response should be successful');
        Assert.areEqual(1, response.numbersByCvrInAssignedAvailableStatus.size(), 'A single AA number by CVR should be returned');
        Assert.areEqual(1, response.numbersByCvrInAssignedReservedStatus.size(), 'A single AR number by CVR should be returned');
        Assert.isTrue(response.numbersWithoutCvrInAssignedAvailableStatus.isEmpty(), 'No AA numbers without CVR should be returned');
    }

    @IsTest
    private static void testGetAssignedAvailableAndAssignedReservedByCvrAndAssignedAvailableWithoutCvrSuccess() {
        NumbersGetByCvrAction.Request request = new NumbersGetByCvrAction.Request();
        request.cvr = '12345678';
        request.amountOfNumbers = 3;
        request.reserveNumbersNotCvrAssigned = true;

        String endpointAssignedAvailableByCvr = 'callout:' + namedCredential + '?' + getUrlQueryParametersWithCvr(NumbersGetByCvrAction.ASSIGNED_AVAILABLE, request.amountOfNumbers, request.cvr);
        String bodyAssignedAvailableByCvr = '{"data":[{"countryCode":"45","id":"4585307625","number":"85307625","numberGroup":"P","numberLocation":"BUS","numberStatus":"AA","productType":["GSM"]}],"pageSize":1}';
        HttpResponseMock mockResponseAssignedAvailableByCvr = new HttpResponseMock(200, 'OK', bodyAssignedAvailableByCvr);

        String endpointAssignedReservedByCvr = 'callout:' + namedCredential + '?' + getUrlQueryParametersWithCvr(NumbersGetByCvrAction.ASSIGNED_RESERVED, request.amountOfNumbers - 1, request.cvr);
        String bodyAssignedReservedByCvr = '{"data":[{"countryCode":"45","id":"4585307625","number":"85307625","numberGroup":"P","numberLocation":"BUS","numberStatus":"AR","productType":["GSM"]}],"pageSize":1}';
        HttpResponseMock mockResponseAssignedReservedByCvr = new HttpResponseMock(200, 'OK', bodyAssignedReservedByCvr);

        String endpointAssignedAvailableWithoutCvr = 'callout:' + namedCredential + '?' + getUrlQueryParametersWithoutCvr(request.amountOfNumbers - 2);
        System.debug(endpointAssignedAvailableWithoutCvr);
        String bodyAssignedAvailableWithoutCvr = '{"data":[{"countryCode":"45","id":"4585307625","number":"85307625","numberGroup":"P","numberLocation":"BUS","numberStatus":"AA","productType":["GSM"]}],"pageSize":1}';
        HttpResponseMock mockResponseAssignedAvailableWithoutCvr = new HttpResponseMock(200, 'OK', bodyAssignedAvailableWithoutCvr);

        Map<String, HttpResponseMock> endpoint2HttpCalloutMock = new Map<String, HttpResponseMock>{
            endpointAssignedAvailableByCvr => mockResponseAssignedAvailableByCvr,
            endpointAssignedReservedByCvr => mockResponseAssignedReservedByCvr,
            endpointAssignedAvailableWithoutCvr => mockResponseAssignedAvailableWithoutCvr
        };
        HttpResponseMock mockResponseMulti = new HttpResponseMock(endpoint2HttpCalloutMock);
        Test.setMock(HttpCalloutMock.class, mockResponseMulti);

        Test.startTest();
        NumbersGetByCvrAction.Response response = NumbersGetByCvrAction.invoke(new List<NumbersGetByCvrAction.Request>{request})[0];
        Test.stopTest();

        Assert.isTrue(response.isSuccess, 'Response should be successful');
        Assert.areEqual(1, response.numbersByCvrInAssignedAvailableStatus.size(), 'A single AA number by CVR should be returned');
        Assert.areEqual(1, response.numbersByCvrInAssignedReservedStatus.size(), 'A single AR number by CVR should be returned');
        Assert.areEqual(1, response.numbersWithoutCvrInAssignedAvailableStatus.size(), 'A single AA number without CVR should be returned');
    }

    @IsTest
    private static void testGetAssignedAvailableByCvrError() {
        NumbersGetByCvrAction.Request request = new NumbersGetByCvrAction.Request();
        request.cvr = '12345678';
        request.amountOfNumbers = 2;
        String body = ERROR_RESPONSE;
        HttpResponseMock mockResponse = new HttpResponseMock(400, 'Bad Request', body);
        Test.setMock(HttpCalloutMock.class, mockResponse);

        Test.startTest();
        List<NumbersGetByCvrAction.Response> responses = NumbersGetByCvrAction.invoke(new List<NumbersGetByCvrAction.Request>{request});
        Test.stopTest();

        Assert.areEqual(1, responses.size(), 'Exactly one response should be returned');
        NumbersGetByCvrAction.Response response = responses[0];

        Assert.isFalse(response.isSuccess, 'Response should not be successful');
        Assert.isTrue(String.isNotBlank(response.errorMessage), 'An error message should be returned');
        Assert.isTrue(response.numbersByCvrInAssignedAvailableStatus.isEmpty(), 'No AA numbers by CVR should be returned');
        Assert.isTrue(response.numbersByCvrInAssignedReservedStatus.isEmpty(), 'No AR numbers by CVR should be returned');
        Assert.isTrue(response.numbersWithoutCvrInAssignedAvailableStatus.isEmpty(), 'No AA numbers without CVR should be returned');
    }

    @IsTest
    private static void testGetAssignedAvailableAndAssignedReservedByCvrError() {
        NumbersGetByCvrAction.Request request = new NumbersGetByCvrAction.Request();
        request.cvr = '12345678';
        request.amountOfNumbers = 2;

        String endpointAssignedAvailable = 'callout:' + namedCredential + '?' + getUrlQueryParametersWithCvr(NumbersGetByCvrAction.ASSIGNED_AVAILABLE, request.amountOfNumbers, request.cvr);
        String bodyAssignedAvailable = '{"data":[{"countryCode":"45","id":"4585307625","number":"85307625","numberGroup":"P","numberLocation":"BUS","numberStatus":"AA","productType":["GSM"]}],"pageSize":1}';
        HttpResponseMock mockResponseAssignedAvailable = new HttpResponseMock(200, 'OK', bodyAssignedAvailable);

        String endpointAssignedReserved = 'callout:' + namedCredential + '?' + getUrlQueryParametersWithCvr(NumbersGetByCvrAction.ASSIGNED_RESERVED, request.amountOfNumbers - 1, request.cvr);
        String bodyAssignedReserved = ERROR_RESPONSE;
        HttpResponseMock mockResponseAssignedReserved = new HttpResponseMock(400, 'Bad Request', bodyAssignedReserved);

        Map<String, HttpResponseMock> endpoint2HttpCalloutMock = new Map<String, HttpResponseMock>{
            endpointAssignedAvailable => mockResponseAssignedAvailable,
            endpointAssignedReserved => mockResponseAssignedReserved
        };
        HttpResponseMock mockResponseMulti = new HttpResponseMock(endpoint2HttpCalloutMock);
        Test.setMock(HttpCalloutMock.class, mockResponseMulti);

        Test.startTest();
        NumbersGetByCvrAction.Response response = NumbersGetByCvrAction.invoke(new List<NumbersGetByCvrAction.Request>{request})[0];
        Test.stopTest();

        Assert.isFalse(response.isSuccess, 'Response should not be successful');
        Assert.isTrue(String.isNotBlank(response.errorMessage), 'An error message should be returned');
        Assert.areEqual(1, response.numbersByCvrInAssignedAvailableStatus.size(), 'A single AA number by CVR should be returned');
        Assert.isTrue(response.numbersByCvrInAssignedReservedStatus.isEmpty(), 'No AR numbers by CVR should be returned');
        Assert.isTrue(response.numbersWithoutCvrInAssignedAvailableStatus.isEmpty(), 'No AA numbers without CVR should be returned');
    }

    @IsTest
    private static void testGetAssignedAvailableAndAssignedReservedByCvrAndAssignedAvailableWithoutCvrError() {
        NumbersGetByCvrAction.Request request = new NumbersGetByCvrAction.Request();
        request.cvr = '12345678';
        request.amountOfNumbers = 3;

        String endpointAssignedAvailableByCvr = 'callout:' + namedCredential + '?' + getUrlQueryParametersWithCvr(NumbersGetByCvrAction.ASSIGNED_AVAILABLE, request.amountOfNumbers, request.cvr);
        String bodyAssignedAvailableByCvr = '{"data":[{"countryCode":"45","id":"4585307625","number":"85307625","numberGroup":"P","numberLocation":"BUS","numberStatus":"AA","productType":["GSM"]}],"pageSize":1}';
        HttpResponseMock mockResponseAssignedAvailableByCvr = new HttpResponseMock(200, 'OK', bodyAssignedAvailableByCvr);

        String endpointAssignedReservedByCvr = 'callout:' + namedCredential + '?' + getUrlQueryParametersWithCvr(NumbersGetByCvrAction.ASSIGNED_RESERVED, request.amountOfNumbers - 1, request.cvr);
        String bodyAssignedReservedByCvr = '{"data":[{"countryCode":"45","id":"4585307625","number":"85307625","numberGroup":"P","numberLocation":"BUS","numberStatus":"AR","productType":["GSM"]}],"pageSize":1}';
        HttpResponseMock mockResponseAssignedReservedByCvr = new HttpResponseMock(200, 'OK', bodyAssignedReservedByCvr);

        String endpointAssignedAvailableWithoutCvr = 'callout:' + namedCredential + '?' + getUrlQueryParametersWithoutCvr(request.amountOfNumbers - 2);
        String bodyAssignedAvailableWithoutCvr = ERROR_RESPONSE;
        HttpResponseMock mockResponseAssignedAvailableWithoutCvr = new HttpResponseMock(400, 'Bad Request', bodyAssignedAvailableWithoutCvr);

        Map<String, HttpResponseMock> endpoint2HttpCalloutMock = new Map<String, HttpResponseMock>{
            endpointAssignedAvailableByCvr => mockResponseAssignedAvailableByCvr,
            endpointAssignedReservedByCvr => mockResponseAssignedReservedByCvr,
            endpointAssignedAvailableWithoutCvr => mockResponseAssignedAvailableWithoutCvr
        };
        HttpResponseMock mockResponseMulti = new HttpResponseMock(endpoint2HttpCalloutMock);
        Test.setMock(HttpCalloutMock.class, mockResponseMulti);

        Test.startTest();
        NumbersGetByCvrAction.Response response = NumbersGetByCvrAction.invoke(new List<NumbersGetByCvrAction.Request>{request})[0];
        Test.stopTest();

        Assert.isFalse(response.isSuccess, 'Response should not be successful');
        Assert.isTrue(String.isNotBlank(response.errorMessage), 'An error message should be returned');
        Assert.areEqual(1, response.numbersByCvrInAssignedAvailableStatus.size(), 'A single AA number by CVR should be returned');
        Assert.areEqual(1, response.numbersByCvrInAssignedReservedStatus.size(), 'A single AR number by CVR should be returned');
        Assert.isTrue(response.numbersWithoutCvrInAssignedAvailableStatus.isEmpty(), 'No AA numbers without CVR should be returned');
    }

    private static String getUrlQueryParametersWithCvr(String numberStatus, Integer amountOfNumbers, String cvr) {
        String queryParameters = new NumberService.GetNumbersParameterbuilder()
            .withNumberStatus(numberStatus)
            .withAmountOfNumbers(amountOfNumbers)
            .withCvr(cvr)
            .build();

        return queryParameters;
    }

    private static String getUrlQueryParametersWithoutCvr(Integer amountOfNumbers) {
        String queryParameters = new NumberService.GetNumbersParameterbuilder()
            .withNumberStatus(NumbersGetByCvrAction.ASSIGNED_AVAILABLE)
            .withAmountOfNumbers(amountOfNumbers)
            .withNumberGroup(NumbersGetByCvrAction.NUMBER_GROUP_P)
            .withNumberLocation(NumbersGetByCvrAction.NUMBER_LOCATION_BUSINESS)
            .build();

        return queryParameters;
    }
}