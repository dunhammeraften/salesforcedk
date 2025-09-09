@IsTest
public with sharing class EventExecutorExampleImplTest {
    @IsTest
    public static void parseParameters_withNull_returnNull() {
        //ARRANGE
        EventExecutorExampleImpl p = new EventExecutorExampleImpl();
        //ACT
        EventExecutorExampleImpl.Parameters params = p.parseParameters(null);

        //ASSERT
        Assert.isNull(params, 'Parameters should be null.');
    }

    @IsTest
    public static void parseParameters_withJSON_returnParametersObject() {
        //ARRANGE
        EventExecutorExampleImpl p = new EventExecutorExampleImpl();
        //ACT
        EventExecutorExampleImpl.Parameters params = p.parseParameters(
            '{"action":"EXCEPTION","address":"Peder skrams gade 26, 2.th"}'
        );

        //ASSERT
        Assert.isTrue(params.action == 'EXCEPTION', 'We have an exception action');
        Assert.isTrue(params.address == 'Peder skrams gade 26, 2.th', 'We have address Peder skrams gade 26, 2.th');
    }

    @IsTest
    public static void parseParameters_withBobbyProperty_returnParametersObject() {
        //ARRANGE
        EventExecutorExampleImpl p = new EventExecutorExampleImpl();
        //ACT
        EventExecutorExampleImpl.Parameters params = p.parseParameters(
            '{"action":"EXCEPTION","address":"Peder skrams gade 26, 2.th","bobby":"boo"}'
        );

        //ASSERT
        Assert.isTrue(params.action == 'EXCEPTION', 'We have an exception action');
        Assert.isTrue(params.address == 'Peder skrams gade 26, 2.th', 'We have address Peder skrams gade 26, 2.th');
    }

    @IsTest
    public static void parseParameters_withoutActionProperty_returnParametersObject() {
        //ARRANGE
        EventExecutorExampleImpl p = new EventExecutorExampleImpl();
        //ACT
        EventExecutorExampleImpl.Parameters params = p.parseParameters('{"address":"Peder skrams gade 26, 2.th"}');

        //ASSERT
        Assert.isNull(params.action, 'We have a null');
        Assert.isTrue(params.address == 'Peder skrams gade 26, 2.th', 'We have address Peder skrams gade 26, 2.th');
    }

    @IsTest
    public static void execute_withEventActionEXCEPTION_throwsNullpointer() {
        //ARRANGE
        EventExecutorExampleImpl p = new EventExecutorExampleImpl();
        EventExecutor__e eventAction = new EventExecutor__e(
            Executor__c = 'EventExecutorExampleImpl',
            Parameters__c = '{"action":"EXCEPTION","address":"Peder skrams gade 26, 2.th"}'
        );
        //ACT
        NullPointerException nullPointer = null;
        try {
            p.execute(eventAction);
        } catch (NullPointerException ex) {
            nullPointer = ex;
        }

        //ASSERT
        Assert.isNotNull(nullPointer, 'NullPointerException should be thrown.');
    }

    @IsTest
    public static void execute_withEventActionRETRY_throwsNullpointer() {
        //ARRANGE
        EventExecutorExampleImpl p = new EventExecutorExampleImpl();
        EventExecutor__e eventAction = new EventExecutor__e(
            Executor__c = 'EventExecutorExampleImpl',
            Parameters__c = '{"action":"RETRY","address":"Peder skrams gade 26, 2.th"}'
        );
        //ACT
        EventExecutorRetryException retryException = null;
        try {
            p.execute(eventAction);
        } catch (EventExecutorRetryException ex) {
            retryException = ex;
        }

        //ASSERT
        Assert.isNotNull(retryException, 'EventExecutorRetryException should be thrown.');
    }

    @IsTest
    public static void execute_withEventActionCALLOUT_callsDAWAWithAddressProperty() {
        //ARRANGE
        Mock dawaClientMock = Mock.forType(DAWAClient.class);
        MethodSpy addresseVaskSpy = dawaClientMock.spyOn('addresseVask');

        EventExecutorExampleImpl p = new EventExecutorExampleImpl((DAWAClient) dawaClientMock.stub);
        EventExecutor__e eventAction = new EventExecutor__e(
            Executor__c = 'EventExecutorExampleImpl',
            Parameters__c = '{"action":"CALLOUT","address":"Peder skrams gade 26, 2.th"}'
        );

        //ACT
        p.execute(eventAction);

        //ASSERT
        Expect.that(addresseVaskSpy).hasBeenCalledWith('Peder skrams gade 26, 2.th');
        Assert.isTrue(true, 'PMD WARNING');
    }
}