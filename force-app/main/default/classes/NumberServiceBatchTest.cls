@IsTest
private with sharing class NumberServiceBatchTest {
    @IsTest
    private static void testRunReserveSuccess() {
        List<String> msisdns = new List<String>{'4527771499','4560376690'};
        String body = '{"data":{"countryCode":"45","id":"4512345678","number":"85317658","numberGroup":"P","numberLocation":"DWS","numberStatus":"AA","productType":["GSM"]}}';
        HttpResponseMock mockResponse = new HttpResponseMock(200, 'OK', body);
        Test.setMock(HttpCalloutMock.class, mockResponse);

        Test.startTest();
        NumberServiceBatch batchJob = new NumberServiceBatch(NumberServiceBatch.Action.RESERVE, msisdns);
        batchJob.run();
        Test.stopTest();

        Assert.isTrue(getNumberServiceBatchLogs().isEmpty(), 'No logs should be created');
    }

    @IsTest
    private static void testRunUnreserveSuccess() {
        List<String> msisdns = new List<String>{'4527771499','4560376690'};
        String body = '{"data":{"countryCode":"45","id":"4512345678","number":"85317658","numberGroup":"P","numberLocation":"DWS","numberStatus":"AA","productType":["GSM"]}}';
        HttpResponseMock mockResponse = new HttpResponseMock(200, 'OK', body);
        Test.setMock(HttpCalloutMock.class, mockResponse);

        Test.startTest();
        NumberServiceBatch batchJob = new NumberServiceBatch(NumberServiceBatch.Action.UNRESERVE, msisdns);
        batchJob.run();
        Test.stopTest();

        Assert.isTrue(getNumberServiceBatchLogs().isEmpty(), 'No logs should be created');
    }

    @IsTest
    private static void testRunReserveError() {
        List<String> msisdns = new List<String>{'456037'};
        String body = '{"error":{"code":400,"message":"400 BAD_REQUEST \\"Invalid id value(s): \'456037\'\\""}}';
        HttpResponseMock mockResponse = new HttpResponseMock(400, 'Bad request', body);
        Test.setMock(HttpCalloutMock.class, mockResponse);

        Test.startTest();
        NumberServiceBatch batchJob = new NumberServiceBatch(NumberServiceBatch.Action.RESERVE, msisdns);
        batchJob.run();
        Test.stopTest();

        Assert.areEqual(1, getNumberServiceBatchLogs().size(), 'Exactly 1 log should be created');
    }

    @IsTest
    private static void testRunUnreserveError() {
        List<String> msisdns = new List<String>{'456037'};
        String body = '{"error":{"code":400,"message":"400 BAD_REQUEST \\"Invalid id value(s): \'456037\'\\""}}';
        HttpResponseMock mockResponse = new HttpResponseMock(400, 'Bad request', body);
        Test.setMock(HttpCalloutMock.class, mockResponse);

        Test.startTest();
        NumberServiceBatch batchJob = new NumberServiceBatch(NumberServiceBatch.Action.UNRESERVE, msisdns);
        batchJob.run();
        Test.stopTest();

        Assert.areEqual(1, getNumberServiceBatchLogs().size(), 'Exactly 1 log should be created');
    }

    @IsTest
    private static void testRunReserveServiceException() {
        List<String> msisdns = new List<String>{'4527771499','4560376690'};
        String body = '{"thisIsNotValidJson":""';
        HttpResponseMock mockResponse = new HttpResponseMock(500, 'Server error', body);
        Test.setMock(HttpCalloutMock.class, mockResponse);

        Test.startTest();
        NumberServiceBatch batchJob = new NumberServiceBatch(NumberServiceBatch.Action.RESERVE, msisdns);
        batchJob.run();
        Test.stopTest();

        Assert.areEqual(1, getNumberServiceBatchLogs().size(), 'Exactly 1 log should be created');
    }

    @IsTest
    private static void testRunReserveBatchException() {
        List<String> msisdns = new List<String>{'',''};
        String body = '{"message":"server booting - wait a moment"}';
        HttpResponseMock mockResponse = new HttpResponseMock(500, 'Server error', body);
        Test.setMock(HttpCalloutMock.class, mockResponse);

        Test.startTest();
        NumberServiceBatch batchJob = new NumberServiceBatch(NumberServiceBatch.Action.RESERVE, msisdns);
        batchJob.run();
        Test.stopTest();

        Assert.areEqual(1, getNumberServiceBatchLogs().size(), 'Exactly 1 log should be created');
    }

    private static List<System_Log__c> getNumberServiceBatchLogs() {
        return SystemLogSelector.getLogsByAdditionalInformationLike(NumberServiceBatch.class.getName() + '%');
    }
}