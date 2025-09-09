/**
 * The NumberClientTest class is responsible for testing the NumberClient class.
 * It covers success and error scenarios for all the methods in the NumberClient class.
 *  -----------------------------------------------------------------------------
 *  Developer            Date            Description
 *  -----------------------------------------------------------------------------
 *  Kenneth Houkjær         27/07/2025      Initial version
 *
 * @author Kenneth Houkjær
 * @date 27/07/2025
 */
@IsTest(IsParallel = true)
public with sharing class NumberClientTest {

    private static final String ERROR_RESPONSE_BODY = '{"error":{"code":400,"message":"Validation Failed with following issue(s)","parameters":[{"key":"YOU_DID_BAD","value":"And you should feel bad about it"}]}}';
    private static final String INVALID_JSON = '{"thisIsNotValidJson":""';

    /**
     * @description Tests the successful retrieval of number details.
     */
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

        NumberClientRequestDTO.NumberDetails parameters = new NumberClientRequestDTO.NumberDetails();
        parameters.cvr = cvr;
        parameters.numberPattern = numberPattern;
        parameters.amountOfNumbers = amountOfNumbers;
        parameters.numberStatus =availableNumberStatus;

        NumberClient client = new NumberClient();
        NumberClientResponseDTO.NumberDetails resp = client.getNumberDetails(parameters);
        Test.stopTest();

        Assert.isNull(resp.error, 'No error should be returned');
        Assert.isFalse(resp.data.isEmpty(), 'Data should contain entries');
        Assert.areEqual(amountOfNumbers, resp.data.size(), 'Amount of number details should match the amount of numbers requested');
    }

    /**
     * @description Tests the handling of an HTTP exception when retrieving number details.
     */
    @IsTest
    private static void testGetNumberDetailsHTTPException() {
        Integer amountOfNumbers = 2;
        String badNumberStatus = 'badValue';
        HttpResponseMock mockResponse = new HttpResponseMock(400, 'Bad Request', ERROR_RESPONSE_BODY);
        Test.setMock(HttpCalloutMock.class, mockResponse);

        Test.startTest();
        NumberClientRequestDTO.NumberDetails parameters = new NumberClientRequestDTO.NumberDetails();
        parameters.amountOfNumbers = amountOfNumbers;
        parameters.numberStatus = badNumberStatus;

        NumberClient client = new NumberClient();

        HTTPException httpEx = null;
        try {
            NumberClientResponseDTO.NumberDetails resp = client.getNumberDetails(parameters);
        } catch (HTTPException ex) {
             httpEx = ex;
        }

        Test.stopTest();
        Assert.areEqual(httpEx.getStatusCode(), 400, 'We throw an HTTPException with 400 statusCOde');
        Assert.IsTrue(httpEx.getMessage().contains( 'Validation Failed with following issue(s)'), 'The message is set correctly.');
        Assert.IsTrue(httpEx.getMessage().contains( 'And you should feel bad about it'), 'And contains parametersx.');
    }

    /**
     * @description Tests the handling of a general exception when retrieving number details.
     */
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
        NumberClientRequestDTO.NumberDetails parameters = new NumberClientRequestDTO.NumberDetails();
        parameters.amountOfNumbers = amountOfNumbers;
        parameters.numberStatus = availableNumberStatus;
        parameters.numberLocation = numberLocation;
        parameters.numberGroup = numberGroup;

        NumberClient client = new NumberClient();

        Exception ex = null;
        try {
            NumberClientResponseDTO.NumberDetails resp = client.getNumberDetails(parameters);
        } catch (Exception exc) {
             ex = exc;
        }

        Test.stopTest();
        Assert.isNotNull(ex);
    }

    /**
     * @description Tests the successful retrieval of a single number detail by MSISDN.
     */
    @IsTest
    private static void testGetNumberDetailByMsisdnSuccess() {
        String msisdn = '4585307625';
        String cvr = '12345678';
        String prodType = 'GSM';
        String body = '{"data":{"countryCode":"45","id":"' + msisdn + '","number":"85317658","numberGroup":"P","numberLocation":"BUS","numberStatus":"AA","productType":["GSM"]}}';
        HttpResponseMock mockResponse = new HttpResponseMock(200, 'OK', body);
        Test.setMock(HttpCalloutMock.class, mockResponse);

        Test.startTest();
        NumberClient client = new NumberClient();
        NumberClientResponseDTO.NumberDetail numberDetail = client.reserveNumberDetailByMsisdnAndCVR(msisdn, cvr,prodType);
        Test.stopTest();

        Assert.isNull(numberDetail.error, 'No error should be returned');
        Assert.isNotNull(numberDetail.data, 'Data should be returned');
        Assert.areEqual(msisdn, numberDetail.data.id, 'Provided msisdn should match returned id');
    }

    /**
     * @description Tests the handling of an HTTP exception when retrieving a single number detail by MSISDN.
     */
    @IsTest
    private static void testGetNumberDetailByMsisdnHTTPException() {
        String msisdn = '4585307625';
         String cvr = '12345678';
        String prodType = 'GSM';
        HttpResponseMock mockResponse = new HttpResponseMock(400, 'Bad Request', ERROR_RESPONSE_BODY);
        Test.setMock(HttpCalloutMock.class, mockResponse);

        Test.startTest();
        NumberClient client = new NumberClient();

        HTTPException httpEx = null;
        try {
            NumberClientResponseDTO.NumberDetail resp =  client.reserveNumberDetailByMsisdnAndCVR(msisdn, cvr, prodType);
        } catch (HTTPException ex) {
             httpEx = ex;
        }

        Test.stopTest();
        Assert.areEqual(httpEx.getStatusCode(), 400, 'We throw an HTTPException with 400 statusCOde');
        Assert.IsTrue(httpEx.getMessage().contains( 'Validation Failed with following issue(s)'), 'The message is set correctly.');
        Assert.IsTrue(httpEx.getMessage().contains( 'And you should feel bad about it'), 'And contains parametersx.');
    }

    /**
     * @description Tests the handling of a general exception when retrieving a single number detail by MSISDN.
     */
    @IsTest
    private static void testGetNumberDetailByMsisdnException() {
        String msisdn = '4585307625';
        String cvr = '12345678';
        String prodType = 'GSM';
        String body = INVALID_JSON;
        HttpResponseMock mockResponse = new HttpResponseMock(500, 'Server error', body);
        Test.setMock(HttpCalloutMock.class, mockResponse);

        Test.startTest();
        NumberClient client = new NumberClient();

        Exception ex = null;
        try {
            NumberClientResponseDTO.NumberDetail resp =  client.reserveNumberDetailByMsisdnAndCVR(msisdn, cvr,prodType);
        } catch (Exception exc) {
             ex = exc;
        }

        Test.stopTest();
        Assert.isNotNull(ex);
    }

    /**
     * @description Tests the successful reservation of a number by MSISDN.
     */
    @IsTest
    private static void testReserveNumberByMsisdnSuccess() {
        String msisdn = '4585307625';
        String cvr = '12345678';
        String prodType = 'GSM';
        String body = '{"data":{"countryCode":"45","id":"' + msisdn + '","number":"85317658","numberGroup":"P","numberLocation":"BUS","numberStatus":"AA","productType":["GSM"]}}';
        HttpResponseMock mockResponse = new HttpResponseMock(200, 'OK', body);
        Test.setMock(HttpCalloutMock.class, mockResponse);

        Test.startTest();
        NumberClient client = new NumberClient();
        NumberClientResponseDTO.NumberDetail numberDetail =  client.reserveNumberDetailByMsisdnAndCVR(msisdn, cvr,prodType);
        Test.stopTest();

        Assert.isNull(numberDetail.error, 'No error should be returned');
        Assert.isNotNull(numberDetail.data, 'Data should be returned');
        Assert.areEqual(msisdn, numberDetail.data.id, 'Provided msisdn should match returned id');
    }

    /**
     * @description Tests the handling of an HTTP exception when reserving a number by MSISDN.
     */
    @IsTest
    private static void testReserveNumberByMsisdnHTTPException() {
        String msisdn = '4585307625';
        String cvr = '12345678';
        String prodType = 'GSM';
        HttpResponseMock mockResponse = new HttpResponseMock(400, 'Bad Request', ERROR_RESPONSE_BODY);
        Test.setMock(HttpCalloutMock.class, mockResponse);

        Test.startTest();

        NumberClient client = new NumberClient();
        HTTPException httpEx = null;
        try {
            NumberClientResponseDTO.NumberDetail numberDetail =  client.reserveNumberDetailByMsisdnAndCVR(msisdn, cvr,prodType);
        } catch (HTTPException ex) {
             httpEx = ex;
        }
        Test.stopTest();

        Assert.areEqual(httpEx.getStatusCode(), 400, 'We throw an HTTPException with 400 statusCOde');
        Assert.IsTrue(httpEx.getMessage().contains( 'Validation Failed with following issue(s)'), 'The message is set correctly.');
        Assert.IsTrue(httpEx.getMessage().contains( 'And you should feel bad about it'), 'And contains parametersx.');
    }

    /**
     * @description Tests the handling of a general exception when reserving a number by MSISDN.
     */
    @IsTest
    private static void testReserveNumberByMsisdnException() {
        String msisdn = '4585307625';
        String cvr = '12345678';
        String prodType = 'GSM';
        String body = INVALID_JSON;
        HttpResponseMock mockResponse = new HttpResponseMock(500, 'Server error', body);
        Test.setMock(HttpCalloutMock.class, mockResponse);

        Test.startTest();

        NumberClient client = new NumberClient();

        Exception ex = null;
        try {
            NumberClientResponseDTO.NumberDetail numberDetail =  client.reserveNumberDetailByMsisdnAndCVR(msisdn, cvr,prodType);
        } catch (Exception exc) {
             ex = exc;
        }

        
        Test.stopTest();

        Assert.isNotNull(ex, 'Exception should throw an exception.');
    }

    /**
     * @description Tests the successful un-reservation of a number by MSISDN.
     */
    @IsTest
    private static void testUnreserveNumberByMsisdnSuccess() {
        String msisdn = '4585307625';
        String cvr = '12345678';
        String prodType = 'GSM';
        String body = '{"data":{"countryCode":"45","id":"' + msisdn + '","number":"85317658","numberGroup":"P","numberLocation":"BUS","numberStatus":"AR"}}';
        HttpResponseMock mockResponse = new HttpResponseMock(200, 'OK', body);
        Test.setMock(HttpCalloutMock.class, mockResponse);

        Test.startTest();
        NumberClient client = new NumberClient();
        NumberClientResponseDTO.NumberDetail numberDetail = client.unreserveNumberDetailByMsisdn(msisdn);

        Test.stopTest();

        Assert.isNull(numberDetail.error, 'No error should be returned');
        Assert.isNotNull(numberDetail.data, 'Data should be returned');
        Assert.areEqual(msisdn, numberDetail.data.id, 'Provided msisdn should match returned id');
    }
    
    /**
     * @description Tests the handling of an HTTP exception when un-reserving a number by MSISDN.
     */
    @IsTest
    private static void testUnreserveNumberByMsisdnHttpException() {
        String msisdn = '4585307625';
        HttpResponseMock mockResponse = new HttpResponseMock(400, 'Bad Request', ERROR_RESPONSE_BODY);
        Test.setMock(HttpCalloutMock.class, mockResponse);

        Test.startTest();
        
        NumberClient client = new NumberClient();
        HTTPException httpEx = null;
        try {
            NumberClientResponseDTO.NumberDetail numberDetail = client.unreserveNumberDetailByMsisdn(msisdn);
        } catch (HTTPException ex) {
             httpEx = ex;
        }
        
        Test.stopTest();

        Assert.areEqual(httpEx.getStatusCode(), 400, 'We throw an HTTPException with 400 statusCOde');
        Assert.IsTrue(httpEx.getMessage().contains( 'Validation Failed with following issue(s)'), 'The message is set correctly.');
        Assert.IsTrue(httpEx.getMessage().contains( 'And you should feel bad about it'), 'And contains parametersx.');
    }

    /**
     * @description Tests the handling of a general exception when un-reserving a number by MSISDN.
     */
    @IsTest
    private static void testUnreserveNumberByMsisdnException() {
        String msisdn = '4585307625';
        String body = INVALID_JSON;
        HttpResponseMock mockResponse = new HttpResponseMock(500, 'Server error', body);
        Test.setMock(HttpCalloutMock.class, mockResponse);

        Test.startTest();
        
        NumberClient client = new NumberClient();
        Exception caughtEx = null;
        try {
            NumberClientResponseDTO.NumberDetail numberDetail = client.unreserveNumberDetailByMsisdn(msisdn);
        } catch (Exception ex) {
             caughtEx = ex;
        }
        
        Test.stopTest();

        Assert.isNotNull(caughtEx, 'we have an exception');
    }


    /**
     * @description Tests the successful retrieval of port orders by MSISDNs.
     */
    @IsTest
    private static void testGetPortOrdersByMsisdnsSuccess() {
        List<String> msisdns = new List<String>{'4527771499','4560376690'};
        String body = '{"data":[{"currentStatusCode":10,"externalStatusCode":"600","iccNumber":"89450401061109595817","msisdn":"4527771499","ochNumber":"200022152041","orderId":11721967,"portingCase":"PortedNonGeo","requestExecutionDate":"2014-06-02T03:56:20","subStatusCode":"COMPLETE","transactionStatusCode":"S"},{"currentStatusCode":9,"externalStatusCode":"600","msisdn":"4560376690","ochNumber":"200024690130","orderId":12420737,"portingCase":"NonPorted","subStatusCode":"IN_PROGRESS","transactionStatusCode":"S"}]}';
        HttpResponseMock mockResponse = new HttpResponseMock(200, 'OK', body);
        Test.setMock(HttpCalloutMock.class, mockResponse);

        Test.startTest();
        NumberClient client = new NumberClient();
        NumberClientResponseDTO.PortOrders portOrders = client.getPortOrdersByMsisdns(msisdns);
        Test.stopTest();


        Assert.isNull(portOrders.error, 'No error should be returned');
        Assert.isNotNull(portOrders.data, 'Data should be returned');
        Assert.areEqual(msisdns.size(), portOrders.data.size(), 'Amount of returned port orders should match amount of provided msisdns');
    }


    /**
     * @description Tests the handling of an HTTP exception when retrieving port orders by MSISDNs.
     */
    @IsTest
    private static void testGetPortOrdersByMsisdnsHTTPException() {
        List<String> msisdns = new List<String>{'4527771499','4560376690'};
        HttpResponseMock mockResponse = new HttpResponseMock(400, 'Bad request', ERROR_RESPONSE_BODY);
        Test.setMock(HttpCalloutMock.class, mockResponse);

        Test.startTest();
        HTTPException httpEx = null;
        try {
            NumberClient client = new NumberClient();
            NumberClientResponseDTO.PortOrders portOrders = client.getPortOrdersByMsisdns(msisdns);
        } catch (HTTPException ex) {
             httpEx = ex;
        }
        Test.stopTest();

        Assert.areEqual(httpEx.getStatusCode(), 400, 'We throw an HTTPException with 400 statusCOde');
        Assert.IsTrue(httpEx.getMessage().contains( 'Validation Failed with following issue(s)'), 'The message is set correctly.');
        Assert.IsTrue(httpEx.getMessage().contains( 'And you should feel bad about it'), 'And contains parametersx.');
    }

    /**
     * @description Tests the handling of a general exception when retrieving port orders by MSISDNs.
     */
    @IsTest
    private static void testGetPortOrdersByMsisdnsException() {
        List<String> msisdns = new List<String>{'4527771499','4560376690'};
        String body = INVALID_JSON;
        HttpResponseMock mockResponse = new HttpResponseMock(500, 'Server error', body);
        Test.setMock(HttpCalloutMock.class, mockResponse);

        Test.startTest();
                
        NumberClient client = new NumberClient();
        Exception caughtEx = null;
        try {
            NumberClientResponseDTO.PortOrders portOrders = client.getPortOrdersByMsisdns(msisdns);
        } catch (Exception ex) {
             caughtEx = ex;
        }
        Test.stopTest();

        Assert.isNotNull(caughtEx, 'Exception should be caught.');
    }
}