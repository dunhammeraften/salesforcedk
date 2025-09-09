/**
 * The NumberAssignmentResetExecutorHandlerTest class is responsible for testing the NumberAssignmentResetExecutorHandler class.
 *  -----------------------------------------------------------------------------
 *  Developer            Date            Description
 *  -----------------------------------------------------------------------------
 *  Kenneth Houkjær         29/07/2025      Initial version
 *
 * @author Kenneth Houkjær
 * @date 29/07/2025
 */
@IsTest(IsParallel = true)
public class NumberAssignmentResetExecutorHandlerTest {

    @IsTest
    public static void execute_openSeriesNumber_resetsAssignmentValues() {
        
        Mock numberClientMock = Mock.forType(NumberClient.class);
        MethodSpy unreserveNumberDetailByMsisdn = numberClientMock.spyOn('unreserveNumberDetailByMsisdn');
        NumberClientResponseDTO.NumberDetail tmpResponse = new NumberClientResponseDTO.NumberDetail();
        tmpResponse.data = new NumberClientResponseDTO.NumberData();
        tmpResponse.data.id = '12345678';
        unreserveNumberDetailByMsisdn.whenCalledWith(Argument.any()).thenReturn(tmpResponse);

        NumberClient numberClient = (NumberClient) numberClientMock.stub;
        DatabaseService dbMock = new DatabaseService().mockDMLs();

        NumberAssignmentResetExecutorHandler handler = new NumberAssignmentResetExecutorHandler(numberClient, dbMock);       
        
        // Create mock data
        Account acc = new Account(Name = 'Test Account', CVR__c = '12345678');
        insert acc;

        Case c = new Case(AccountId = acc.Id);
        insert c;

        Activation__c activation = new Activation__c(Case__c = c.Id);
        insert activation;

        Account_Phone_Number_Series__c series = new Account_Phone_Number_Series__c(
            Account__c = acc.Id,
            Number_Group__c = 'P',
            Number_Location__c = 'EKC',
            Product_Type__c = 'GSM'
        );
        insert series;

        List<Account_Phone_Number_Assignment__c> phoneAssignments = new List<Account_Phone_Number_Assignment__c>();
        for (Integer i = 0; i < 1; i++) {
            phoneAssignments.add(
                new Account_Phone_Number_Assignment__c(
                    Account__c = acc.Id, 
                    Account_Phone_Number_Series__c = series.Id,             
                    CTN_Number_Status__c = 'AR',
                    Phone_Number_Reservation_Status__c = '',
                    Phone_Number_Reservation_Error__c = null,
                    Activation_line__c = null,
                    Phone_Number__c = '2222222' + i
                    ));
        }
        insert phoneAssignments;

        List<Activation_line__c> activationLines = new List<Activation_line__c>();
        for (Integer i = 0; i < 1; i++) {
            activationLines.add(
                new Activation_line__c(
                    Case__c = c.Id, 
                    Activation__c = activation.Id,
                    Phone_Number_Reservation_Status__c = '',
                    Phone_Number_Reservation_Error__c = null,
                    First_Name__c = 'Peter',
                    Last_Name__c = 'Griffin' + i,
                    Email__c = 'pg' + i + '@test.com'
                    //Mobile_No__c = '2222222' + i                    
                    ));
        }
        insert activationLines;

        activationLines.get(0).Mobile_No__c = '22222220';
        update activationLines;

        phoneAssignments.get(0).Activation_line__c = activationLines.get(0).Id;
        phoneAssignments.get(0).Phone_Number_User__c = activationLines.get(0).First_Name__c;
        update phoneAssignments;    

        Map<Id, String> tmpMap = new  Map<Id, String>();
        tmpMap.put(activationLines.get(0).Id, activationLines.get(0).Mobile_No__c);

        String parameters = JSON.serialize(new Map<String, Object>{'activationLineIdToNumber' => tmpMap});

        Logger.logInfo('parameters' + parameters);

        EventExecutor__e event = new EventExecutor__e(Parameters__c = parameters, RetryCount__c = 5);

        //ACT
        handler.execute(event);

        //ASSERT
        Account_Phone_Number_Assignment__c updatedAssignment = (Account_Phone_Number_Assignment__c) dbMock.register.updated.get(0);

        Assert.areEqual(1, dbMock.register.updated.size(), 'We updated an assignment');
        Assert.areEqual(updatedAssignment.Activation_Line__c,null, 'Assignment and ActivationLine got unrelated');
        Assert.areEqual(updatedAssignment.Phone_Number_User__c, null, 'Assignment phone number user is reset');
        Assert.areEqual(updatedAssignment.CTN_Number_Status__c, 'AR', 'Assignment status is set');  
    }

    @IsTest
    public static void execute_fixedSeriesNumber_resetsAssignmentValuesAndUnreservesNumber() {
        
        Mock numberClientMock = Mock.forType(NumberClient.class);
        MethodSpy unreserveNumberDetailByMsisdn = numberClientMock.spyOn('unreserveNumberDetailByMsisdn');
        NumberClientResponseDTO.NumberDetail tmpResponse = new NumberClientResponseDTO.NumberDetail();
        tmpResponse.data = new NumberClientResponseDTO.NumberData();
        tmpResponse.data.id = '12345678';
        tmpResponse.data.numberStatus = 'AA';
        unreserveNumberDetailByMsisdn.whenCalledWith(Argument.any()).thenReturn(tmpResponse);

        NumberClient numberClient = (NumberClient) numberClientMock.stub;
        DatabaseService dbMock = new DatabaseService().mockDMLs();

        NumberAssignmentResetExecutorHandler handler = new NumberAssignmentResetExecutorHandler(numberClient, dbMock);       
        
        // Create mock data
        Account acc = new Account(Name = 'Test Account', CVR__c = '12345678');
        insert acc;

        Case c = new Case(AccountId = acc.Id);
        insert c;

        Activation__c activation = new Activation__c(Case__c = c.Id);
        insert activation;

        Account_Phone_Number_Series__c series = new Account_Phone_Number_Series__c(
            Account__c = acc.Id,
            Number_Group__c = 'P',
            Number_Location__c = 'SAL',
            Product_Type__c = 'GSM'
        );
        insert series;

        List<Account_Phone_Number_Assignment__c> phoneAssignments = new List<Account_Phone_Number_Assignment__c>();
        for (Integer i = 0; i < 1; i++) {
            phoneAssignments.add(
                new Account_Phone_Number_Assignment__c(
                    Account__c = acc.Id, 
                    Account_Phone_Number_Series__c = series.Id,             
                    CTN_Number_Status__c = 'AR',
                    Phone_Number_Reservation_Status__c = '',
                    Phone_Number_Reservation_Error__c = null,
                    Activation_line__c = null,
                    Phone_Number__c = '2222222' + i
                    ));
        }
        insert phoneAssignments;

        List<Activation_line__c> activationLines = new List<Activation_line__c>();
        for (Integer i = 0; i < 1; i++) {
            activationLines.add(
                new Activation_line__c(
                    Case__c = c.Id, 
                    Activation__c = activation.Id,
                    Phone_Number_Reservation_Status__c = '',
                    Phone_Number_Reservation_Error__c = null,
                    First_Name__c = 'Peter',
                    Last_Name__c = 'Griffin' + i,
                    Email__c = 'pg' + i + '@test.com'
                    //Mobile_No__c = '2222222' + i                    
                    ));
        }
        insert activationLines;

        activationLines.get(0).Mobile_No__c = '22222220';
        update activationLines;

        phoneAssignments.get(0).Activation_line__c = activationLines.get(0).Id;
        phoneAssignments.get(0).Phone_Number_User__c = activationLines.get(0).First_Name__c;
        update phoneAssignments;    

        Map<Id, String> tmpMap = new  Map<Id, String>();
        tmpMap.put(activationLines.get(0).Id, activationLines.get(0).Mobile_No__c);

        String parameters = JSON.serialize(new Map<String, Object>{'activationLineIdToNumber' => tmpMap});

        Logger.logInfo('parameters' + parameters);

        EventExecutor__e event = new EventExecutor__e(Parameters__c = parameters, RetryCount__c = 5);

        //ACT
        handler.execute(event);

        //ASSERT
        Account_Phone_Number_Assignment__c updatedAssignment = (Account_Phone_Number_Assignment__c) dbMock.register.updated.get(0);

        Assert.areEqual(1, dbMock.register.updated.size(), 'We updated an assignment');
        Assert.areEqual(updatedAssignment.Activation_Line__c,null, 'Assignment and ActivationLine got unrelated');
        Assert.areEqual(updatedAssignment.Phone_Number_User__c, null, 'Assignment phone number user is reset');
        Assert.areEqual(updatedAssignment.CTN_Number_Status__c, 'AA', 'Assignment status is set');  
    }
}