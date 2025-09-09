@isTest
public class DataDogSIEMConnectionTest {


    @IsTest
    public static void testDatadogEvent() {
        DataDogSIEMConnection.DatadogEvent event = new DataDogSIEMConnection.DatadogEvent(
            'title',
            'text',
            'service',
            'aggregationKey',
            'logLevel',
            'userName',
            'userId',
            System.now()
        );
        Assert.areEqual('title', event.title);
        Assert.areEqual('text', event.message);
        Assert.areEqual('service', event.service);
        Assert.areEqual('aggregationKey', event.trace_id);
        Assert.areEqual('logLevel', event.tags.get('sfLogLevel'));
        Assert.areEqual('userName(userId)', event.tags.get('userId'));
    }


    @IsTest
    public static void testAppendLogLine() {
        DataDogSIEMConnection connection = new DataDogSIEMConnection();
        Debug_Event__e eventToLog = new Debug_Event__e(
            Log_Lines__c = 'Log line',
            Salesforce_Execution_Context__c = 'Service',
            Trace_Id__c = 'Aggregation key',
            Log_Level__c = 'Log level',
            Created_By_Name__c = 'User name'
        );

        Test.startTest();
        connection.appendLogLine(eventToLog);
        Test.stopTest();

        Assert.areEqual(1, connection.payloadsToSend.size());
        DataDogSIEMConnection.DatadogEvent event = connection.payloadsToSend[0];
        Assert.areEqual('Log line', event.title);
        Assert.areEqual('Log line', event.message);
        Assert.areEqual('Service', event.service);
        Assert.areEqual('Aggregation key', event.trace_id);
        Assert.areEqual('Log level', event.tags.get('sfLogLevel'));
    }


@IsTest
    public static void testInvokeSIEM() {
        DataDogSIEMConnection connection = new DataDogSIEMConnection();
        connection.payloadsToSend.add(new DataDogSIEMConnection.DatadogEvent(
            'title',
            'text',
            'service',
            'aggregationKey',
            'logLevel',
            'userName',
            'userId',
            System.now()
        ));

        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('DatadogLogAPIResource');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json;charset=UTF-8');

        Test.setMock(HttpCalloutMock.class, mock);

        Test.startTest();
        try{
            connection.invokeSIEM();
            Assert.isTrue(true, 'No Exception occured meaning success');
        }catch(Exception e){
            Assert.isTrue(false, 'Exception occured meaning failure');
        }
        Test.stopTest();
    }

}