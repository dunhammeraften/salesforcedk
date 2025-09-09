/**
 * The NumberActivationLinesExecutorInputTest class is responsible for testing the NumberActivationLinesExecutorInput class.
 *  -----------------------------------------------------------------------------
 *  Developer            Date            Description
 *  -----------------------------------------------------------------------------
 *  Kenneth Houkjær         27/07/2025      Initial version
 *
 * @author Kenneth Houkjær
 * @date 27/07/2025
 */
@IsTest(IsParallel = true)
public class NumberActivationLinesExecutorInputTest {
    /**
     * @description This method tests that the createActivationLineToAssignmentMappings method returns the correct mappings.
     */
	@IsTest
    public static void createActivationLineToAssignmentMappings_validActivation_returnsIdToStringMappings(){
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
        for (Integer i = 0; i < 5; i++) {
            phoneAssignments.add(new Account_Phone_Number_Assignment__c(Account__c = acc.Id, Account_Phone_Number_Series__c = series.Id));
        }
        insert phoneAssignments;

        List<Activation_line__c> activationLines = new List<Activation_line__c>();
        for (Integer i = 0; i < 5; i++) {
            activationLines.add(new Activation_line__c(Case__c = c.Id, Activation__c = activation.Id));
        }
        insert activationLines;

        // Set up the mock provider
        MockProvider mockProvider = new MockProvider();
        mockProvider.mockValueMap.put('AccountSelector.getAccountByCaseId', acc);
        mockProvider.mockValueMap.put('AccountPhoneNumberAssignmentSelector.getAssignments', phoneAssignments);
        mockProvider.mockValueMap.put('ActivationLineSelector.getActivationLinesByCaseId', activationLines);

        // Set the mock provider
        Test.setMock(System.StubProvider.class, mockProvider);

        // Call the method
        NumberActivationLinesExecutorInput.InputVariables input = new NumberActivationLinesExecutorInput.InputVariables();
        input.activation = activation;
        List<NumberActivationLinesExecutorInput.OutputVariables> result = NumberActivationLinesExecutorInput.createActivationLineToAssignmentMappings(new List<NumberActivationLinesExecutorInput.InputVariables>{input});

        // Assert the results
        System.assertEquals(1, result.size());
        System.assertEquals(5, result[0].activationLineIdToAssignementId.size());

        for (Integer i = 0; i < 5; i++) {
            System.assertEquals(activationLines[i].Id, result[0].activationLineIdToAssignementId[i].key);
            System.assertEquals(phoneAssignments[i].Id, result[0].activationLineIdToAssignementId[i].value);
        }
    }

    /**
     * @description This class is a mock provider for the test method.
     */
    private class MockProvider implements System.StubProvider {
        private final Map<String, Object> mockValueMap = new Map<String, Object>();

        /**
         * @description This method handles the method calls from the test method.
         * @param stubbedObject The object that is being stubbed.
         * @param C The name of the class that is being stubbed.
         * @param returnType The return type of the method that is being stubbed.
         * @param listOfParamTypes A list of the parameter types of the method that is being stubbed.
         * @param listOfParamNames A list of the parameter names of the method that is being stubbed.
         * @param listOfArgs A list of the arguments of the method that is being stubbed.
         * @return The mock value for the method call.
         */
        public Object handleMethodCall(Object stubbedObject, String C, Type returnType, List<Type> listOfParamTypes, List<String> listOfParamNames, List<Object> listOfArgs) {
            String methodName = C.substring(C.lastIndexOf('.') + 1);
            String className = C.substring(0, C.lastIndexOf('.'));
            return mockValueMap.get(className + '.' + methodName);
        }
    }
}