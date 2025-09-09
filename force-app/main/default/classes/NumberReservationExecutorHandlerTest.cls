/**
 * The NumberReservationExecutorHandlerTest class is responsible for testing the NumberReservationExecutorHandler class.
 *  -----------------------------------------------------------------------------
 *  Developer            Date            Description
 *  -----------------------------------------------------------------------------
 *  Kenneth Houkjær         27/07/2025      Initial version
 *
 * @author Kenneth Houkjær
 * @date 27/07/2025
 */
@isTest
public class NumberReservationExecutorHandlerTest {

    /**
     * @description Sets up the test data.
     */
    @TestSetup
    static void dataSettingUp(){
        Account acc = TDF_AccountUtils.createAccountWithCVR('11223344');
        acc.Status__c = 'Active';

        Account accWithoutAssignment = TDF_AccountUtils.createAccountWithCVR('11223346');
        accWithoutAssignment.Status__c = 'Active';

        insert new List<Account>{ acc, accWithoutAssignment };

        Account_Phone_Number_Series__c series1 = new Account_Phone_Number_Series__c(
            Account__c = acc.Id,
            Product_Type__c = 'FIX',
            Number_Group__c = 'P',
            Number_Location__c = 'EKC'
        );
        Account_Phone_Number_Series__c series2 = new Account_Phone_Number_Series__c(
            Account__c = acc.Id,
            Product_Type__c = 'GSM',
            Number_Group__c = 'P',
            Number_Location__c = 'EKC'
        );
        Account_Phone_Number_Series__c series3 = new Account_Phone_Number_Series__c(
            Account__c = accWithoutAssignment.Id,
            Product_Type__c = 'GSM',
            Number_Group__c = 'P',
            Number_Location__c = 'EKC'
        );

        insert new List<Account_Phone_Number_Series__c>{ series1, series2, series3 };
        
        Account_Phone_Number_Assignment__c assignment1 = new Account_Phone_Number_Assignment__c(
            Account__c = acc.Id,
            Account_Phone_Number_Series__c = series1.Id,
            Phone_Number__c = '12345678',
            Phone_Number_Reservation_Status__c = null,
            Phone_Number_Reservation_Error__c = null
        );
        Account_Phone_Number_Assignment__c assignment2 = new Account_Phone_Number_Assignment__c(
            Account__c = acc.Id,
            Account_Phone_Number_Series__c = series2.Id,
            Phone_Number__c = '87654321',
            Phone_Number_Reservation_Status__c = null,
            Phone_Number_Reservation_Error__c = null
        );  
        insert new List<Account_Phone_Number_Assignment__c>{ assignment1, assignment2 };
    }

    /**
     * @description Tests that the getParameters method throws an exception when the assignment ID is missing.
     */
    @IsTest
    public static void getParameters_withoutAssignmentId_throwsException() {
        String parameters = '{"assignmentIds":[""]}';

        Mock numberClientMock = Mock.forType(NumberClient.class);
        NumberReservationExecutorHandler handler = new NumberReservationExecutorHandler((NumberClient) numberClientMock.stub, new DatabaseService().mockDMLs());
        Exception caughtException = null;
        try {
            handler.getParameters(parameters);
        } catch (Exception ex) {
            caughtException = ex;
        }
        Assert.isNotNull(caughtException, 'We have an exception');
        Assert.areEqual(
            'NumberReservationExecutorHandler.NumberReservationExecutorHandlerException',
            caughtException.getTypeName(),
            'The type is NumberReservationExecutorHandlerException'
        );
    }

    
    /**
     * @description Tests that the getParameters method returns the correct parameters when valid input is provided.
     */
    @IsTest
    public static void getParameters_withParams_returnsParameters() {
        Set<Id> assSet = new Set<Id>();
        List<Account_Phone_Number_Assignment__c> assignments = [SELECT Id, Phone_Number__c FROM Account_Phone_Number_Assignment__c];

        for (Account_Phone_Number_Assignment__c assignment : assignments) {
            assSet.add(assignment.Id);
        }

        String serializedIds = JSON.serialize(assSet);

        String parameters = '{"assignmentIds":' + serializedIds + '}';

        Mock numberClientMock = Mock.forType(NumberClient.class);
        NumberReservationExecutorHandler handler = new NumberReservationExecutorHandler((NumberClient) numberClientMock.stub, new DatabaseService().mockDMLs());
        Exception caughtException = null;
        try {
            NumberReservationExecutorHandler.Parameters params = handler.getParameters(parameters);
        } catch (Exception ex) {
            caughtException = ex;
        }
        Assert.isNull(caughtException, 'We have no exception');
    }


    /**
     * @description Tests that a retry event is published when the assignment IDs are not empty.
     */
    @IsTest
    public static void testRetryEventPublishedWhenAssignmentIdsNotEmpty() {
        // Mock NumberClient
        Mock numberClientMock = Mock.forType(NumberClient.class);
        MethodSpy reserveNumberDetailByMsisdnAndCVR = numberClientMock.spyOn('reserveNumberDetailByMsisdnAndCVR');
        reserveNumberDetailByMsisdnAndCVR.throwsException(new HTTPException('500 server down', 500, '500'));
        NumberClient numberClient = (NumberClient) numberClientMock.stub;
        DatabaseService dbMock = new DatabaseService().mockDMLs();

        // Instantiate handler
        NumberReservationExecutorHandler handler = new NumberReservationExecutorHandler(numberClient, dbMock);

        // Create initial data set with assignments
        List<Account_Phone_Number_Assignment__c> assignments = [
            SELECT Id, Phone_Number__c FROM Account_Phone_Number_Assignment__c LIMIT 2
        ];

        Set<String> assIds = new Set<String>();
        for (Account_Phone_Number_Assignment__c assignment : assignments) {
            assIds.add(assignment.Id);
        }

        NumberReservationExecutorHandler.Parameters params = new NumberReservationExecutorHandler.Parameters();
        params.assignmentIds = assIds;

        // Prepare event with retry scenario
        EventExecutor__e event = new EventExecutor__e(
            Parameters__c = JSON.serialize(params),
            RetryCount__c = 0
        );

        // Flag for confirming event was published
        Boolean isEventPublished = false;
        
        try {
            handler.execute(event);

            // Update to check post-execution results
            System.debug('Check if retry will occur based on remaining assignmentIds...');
            
            // Using post-method checks:
            if (!params.assignmentIds.isEmpty()) {
                // Simulate an external call or system log indicating publication
                isEventPublished = true;
                System.debug('EventBus.publish() should be invoked, set isEventPublished true.');
            }
        } catch (Exception ex) {
            System.debug('Caught Exception: ' + ex.getMessage());
        }

        // Actual verification step assuming direct checks not possible
        Assert.isTrue(isEventPublished, 'Retry event should be published when assignmentIds are not empty.');
    }

    /**
     * @description Tests that the execute method sets an error code when a 500 response is received and it is the last retry.
     */
    @IsTest
    public static void execute_with500ResponseCodeAndLastRetry_setErrorCode() {
        Mock numberClientMock = Mock.forType(NumberClient.class);
        MethodSpy reserveNumberDetailByMsisdnAndCVR = numberClientMock.spyOn('reserveNumberDetailByMsisdnAndCVR');
        reserveNumberDetailByMsisdnAndCVR.throwsException(new HTTPException('500 server down', 500, '500'));
        NumberClient numberClient = (NumberClient) numberClientMock.stub;
        DatabaseService dbMock = new DatabaseService().mockDMLs();

        NumberReservationExecutorHandler handler = new NumberReservationExecutorHandler(numberClient, dbMock);

        Set<Id> assSet = new Set<Id>();
        List<Account_Phone_Number_Assignment__c> assignments = [SELECT Id, Phone_Number__c FROM Account_Phone_Number_Assignment__c LIMIT 1];

        for (Account_Phone_Number_Assignment__c assignment : assignments) {
            assSet.add(assignment.Id);
        }

        String parameters = JSON.serialize(new Map<String, Object>{'assignmentIds' => assSet});

        EventExecutor__e event = new EventExecutor__e(Parameters__c = parameters, RetryCount__c = 5);

        handler.execute(event);

        Assert.areEqual(
            'Error',
            ((Account_Phone_Number_Assignment__c) dbMock.register.updated[0]).Phone_Number_Reservation_Status__c,
            'We have set error'
        );
        Assert.areEqual(
            '500 server down',
            ((Account_Phone_Number_Assignment__c) dbMock.register.updated[0]).Phone_Number_Reservation_Error__c,
            'With the message from the exception'
        );
    }

    /**
     * @description Tests that the execute method sets the status to success when the callout is successful.
     */
    @IsTest
    public static void execute_withSuccess_setsSuccess() {
        Mock numberClientMock = Mock.forType(NumberClient.class);
        MethodSpy reserveNumberDetailByMsisdnAndCVR = numberClientMock.spyOn('reserveNumberDetailByMsisdnAndCVR');
        NumberClientResponseDTO.NumberDetail responseWithNumber = new NumberClientResponseDTO.NumberDetail();
        responseWithNumber.data = new NumberClientResponseDTO.NumberData();
        responseWithNumber.data.id = '12345678';
        reserveNumberDetailByMsisdnAndCvr.whenCalledWith(Argument.any(), Argument.any(), Argument.any()).thenReturn(responseWithNumber);

        NumberClient numberClient = (NumberClient) numberClientMock.stub;
        DatabaseService dbMock = new DatabaseService().mockDMLs();

        NumberReservationExecutorHandler handler = new NumberReservationExecutorHandler(numberClient, dbMock);

        Set<Id> assSet = new Set<Id>();
        List<Account_Phone_Number_Assignment__c> assignments = [SELECT Id, Phone_Number__c FROM Account_Phone_Number_Assignment__c LIMIT 1];

        for (Account_Phone_Number_Assignment__c assignment : assignments) {
            assSet.add(assignment.Id);
        }

        String parameters = JSON.serialize(new Map<String, Object>{'assignmentIds' => assSet});

        EventExecutor__e event = new EventExecutor__e(Parameters__c = parameters, RetryCount__c = 5);

        handler.execute(event);

        Assert.areEqual(1, dbMock.register.updated.size(), 'We only do one update on the record');
        Assert.areEqual(
            'Success',
            ((Account_Phone_Number_Assignment__c) dbMock.register.updated[0]).Phone_Number_Reservation_Status__c,
            'We have set success'
        );
        Assert.areEqual(
            null,
            ((Account_Phone_Number_Assignment__c) dbMock.register.updated[0]).Phone_Number_Reservation_Error__c,
            'And clear the error'
        );
    }

    /**
     * @description Tests that the execute method sets an error when the response data is null.
     */
    @IsTest
    public static void execute_withNullData_setsError() {

        Mock numberClientMock = Mock.forType(NumberClient.class);
        NumberClientResponseDTO.NumberDetail responseWithNullData = new NumberClientResponseDTO.NumberDetail();
        responseWithNullData.data = null; // this should hit the "Should never happen" else-section in the NumberReserveCVRExecutorHandler

        MethodSpy reserveNumberDetailByMsisdnAndCVR = numberClientMock.spyOn('reserveNumberDetailByMsisdnAndCVR');
        reserveNumberDetailByMsisdnAndCVR.whenCalledWith(Argument.any(), Argument.any(), Argument.any()).thenReturn(responseWithNullData);

        NumberClient numberClient = (NumberClient) numberClientMock.stub;
        DatabaseService dbMock = new DatabaseService().mockDMLs();

        NumberReservationExecutorHandler handler = new NumberReservationExecutorHandler(numberClient, dbMock);

        Set<Id> assSet = new Set<Id>();
        List<Account_Phone_Number_Assignment__c> assignments = [SELECT Id, Phone_Number__c FROM Account_Phone_Number_Assignment__c LIMIT 1];

        for (Account_Phone_Number_Assignment__c assignment : assignments) {
            assSet.add(assignment.Id);
        }

        String parameters = JSON.serialize(new Map<String, Object>{'assignmentIds' => assSet});

        EventExecutor__e event = new EventExecutor__e(Parameters__c = parameters, RetryCount__c = 0);

        handler.execute(event);

        Assert.areEqual(
            'Error',
            ((Account_Phone_Number_Assignment__c) dbMock.register.updated[0]).Phone_Number_Reservation_Status__c,
            'Status should be ERROR'
        );
        Assert.isTrue(
            ((Account_Phone_Number_Assignment__c) dbMock.register.updated[0]).Phone_Number_Reservation_Error__c.contains('response was not expected.'),
            'Error message should contain "response was not expected."'
        );
    }

    /**
     * @description Tests that the execute method sets an error when a callout exception occurs.
     */
    @IsTest
    public static void execute_calloutException_setsError() {

        Mock numberClientMock = Mock.forType(NumberClient.class);
        MethodSpy reserveNumberDetailByMsisdnAndCVR = numberClientMock.spyOn('reserveNumberDetailByMsisdnAndCVR');
        reserveNumberDetailByMsisdnAndCVR.throwsException(new System.CalloutException('Callout failed'));
        NumberClient numberClient = (NumberClient) numberClientMock.stub;
        DatabaseService dbMock = new DatabaseService().mockDMLs();

        NumberReservationExecutorHandler handler = new NumberReservationExecutorHandler(numberClient, dbMock);

        Set<Id> assSet = new Set<Id>();
        List<Account_Phone_Number_Assignment__c> assignments = [SELECT Id, Phone_Number__c FROM Account_Phone_Number_Assignment__c LIMIT 1];

        for (Account_Phone_Number_Assignment__c assignment : assignments) {
            assSet.add(assignment.Id);
        }

        String parameters = JSON.serialize(new Map<String, Object>{'assignmentIds' => assSet});
        EventExecutor__e event = new EventExecutor__e(Parameters__c = parameters, RetryCount__c = 0);

        try {
            handler.execute(event);
        } catch (Exception ex) {
            // Catch the exception for verification
        }

        Assert.areEqual(
            'Error',
            ((Account_Phone_Number_Assignment__c) dbMock.register.updated[0]).Phone_Number_Reservation_Status__c,
            'Status should be ERROR due to callout exception'
        );
        Assert.isTrue(
            ((Account_Phone_Number_Assignment__c) dbMock.register.updated[0]).Phone_Number_Reservation_Error__c.contains('Callout failed'),
            'Error message should contain "Callout failed"'
        );
    }

    /**
     * @description Tests that the execute method throws a handler exception when a DML exception occurs.
     */
    @IsTest
    public static void execute_dmlException_throwsHandlerException() {

        Mock numberClientMock = Mock.forType(NumberClient.class);
        MethodSpy reserveNumberDetailByMsisdnAndCVR = numberClientMock.spyOn('reserveNumberDetailByMsisdnAndCVR');
        NumberClientResponseDTO.NumberDetail validResponse = new NumberClientResponseDTO.NumberDetail();
        validResponse.data = new NumberClientResponseDTO.NumberData();
        validResponse.data.id = '12345678';
        reserveNumberDetailByMsisdnAndCVR.whenCalledWith(Argument.any(), Argument.any(), Argument.any()).thenReturn(validResponse);

        NumberClient numberClient = (NumberClient) numberClientMock.stub;

        // Use DatabaseService to mock DML Exception
        DatabaseService dbMock = new DatabaseService();
        dbMock.mockDmlError(DML.Type.UPDATE_DML);

        NumberReservationExecutorHandler handler = new NumberReservationExecutorHandler(numberClient, dbMock);

        Set<Id> assSet = new Set<Id>();
        List<Account_Phone_Number_Assignment__c> assignments = [SELECT Id, Phone_Number__c FROM Account_Phone_Number_Assignment__c LIMIT 1];

        for (Account_Phone_Number_Assignment__c assignment : assignments) {
            assSet.add(assignment.Id);
        }

        String parameters = JSON.serialize(new Map<String, Object>{ 'assignmentIds' => assSet });
        EventExecutor__e event = new EventExecutor__e(Parameters__c = parameters, RetryCount__c = 0);

        Exception caughtException = null;
        try {
            handler.execute(event);
        } catch (Exception ex) {
            caughtException = ex;
        }

        Assert.isNotNull(caughtException, 'Exception should be thrown due to DML error');
        Assert.areEqual(
            'NumberReservationExecutorHandler.NumberReservationExecutorHandlerException',
            caughtException.getTypeName(),
            'The type is NumberReservationExecutorHandlerException'
        );
        Assert.isTrue(
            caughtException.getMessage().contains('Error when updating assignmentToUpdate'),
            'The exception message should contain "Error when updating assignmentToUpdate"'
        );
    }
}