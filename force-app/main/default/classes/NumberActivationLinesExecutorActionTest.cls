/**
 * The NumberActivationLinesExecutorActionTest class is responsible for testing the NumberActivationLinesExecutorAction class.
 *  -----------------------------------------------------------------------------
 *  Developer            Date            Description
 *  -----------------------------------------------------------------------------
 *  Kenneth Houkjær         28/07/2025      Initial version
 *
 * @author Kenneth Houkjær
 * @date 27/07/2025
 */
@IsTest(IsParallel = true)
public class NumberActivationLinesExecutorActionTest {
    /**
     * @description This method tests that the assignNumbersToActivationLines method publishes the correct number of events when the number of assignments is a multiple of the chunk size.
     */
	@IsTest
    public static void assignNumbersToActivationLines_with10IdsAndChunkSize2_doPublish5Events(){
        //Arrange
        List<NumberActivationLinesExecutorAction.InputVariables> inputVariables = new List<NumberActivationLinesExecutorAction.InputVariables>();
        NumberActivationLinesExecutorAction.InputVariables vars = new NumberActivationLinesExecutorAction.InputVariables();
        vars.chunkSize = 2;
        vars.activationLineIdToAssignementId = new List<IdToString>();
       
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
        for (Integer i = 0; i < 10; i++) {
            phoneAssignments.add(new Account_Phone_Number_Assignment__c(Account__c = acc.Id, Account_Phone_Number_Series__c = series.Id));
        }
        insert phoneAssignments;

        List<Activation_line__c> activationLines = new List<Activation_line__c>();
        for (Integer i = 0; i < 10; i++) {
            activationLines.add(new Activation_line__c(Case__c = c.Id, Activation__c = activation.Id));
        }
        insert activationLines;


        for(Integer i = 0; i < 10; i++) {
            IdToString idToString = new IdToString();
            idToString.key = activationLines.get(i).Id;
            idToString.value = phoneAssignments.get(i).Id;
            vars.activationLineIdToAssignementId.add(idToString);
        }

        inputVariables.add(vars);
        //Act
        List<NumberActivationLinesExecutorAction.OutputVariables> outputs = NumberActivationLinesExecutorAction.assignNumbersToActivationLines(inputVariables);
        //Assert
        Assert.areEqual(outputs.get(0).publishedEvents.size(), 5, 'Five events should be published.' );
    }
    
    /**
     * @description This method tests that the assignNumbersToActivationLines method publishes the correct number of events when the number of assignments is not a multiple of the chunk size.
     */
	@IsTest
    public static void assignNumbersToActivationLines_with10IdsAndChunkSize3_doPublish4Events(){
        //Arrange
        List<NumberActivationLinesExecutorAction.InputVariables> inputVariables = new List<NumberActivationLinesExecutorAction.InputVariables>();
        NumberActivationLinesExecutorAction.InputVariables vars = new NumberActivationLinesExecutorAction.InputVariables();
        vars.chunkSize = 3;
        vars.activationLineIdToAssignementId = new List<IdToString>();
       
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
        for (Integer i = 0; i < 10; i++) {
            phoneAssignments.add(new Account_Phone_Number_Assignment__c(Account__c = acc.Id, Account_Phone_Number_Series__c = series.Id));
        }
        insert phoneAssignments;

        List<Activation_line__c> activationLines = new List<Activation_line__c>();
        for (Integer i = 0; i < 10; i++) {
            activationLines.add(new Activation_line__c(Case__c = c.Id, Activation__c = activation.Id));
        }
        insert activationLines;


        for(Integer i = 0; i < 10; i++) {
            IdToString idToString = new IdToString();
            idToString.key = activationLines.get(i).Id;
            idToString.value = phoneAssignments.get(i).Id;
            vars.activationLineIdToAssignementId.add(idToString);
        }

        inputVariables.add(vars);
        //Act
        List<NumberActivationLinesExecutorAction.OutputVariables> output = NumberActivationLinesExecutorAction.assignNumbersToActivationLines(inputVariables);

        //Assert
        IdToString idToStringOut = new IdToString();
        idToStringOut.key = activationLines.get(9).Id;
        idToStringOut.value = phoneAssignments.get(9).Id;
        Map<Id, String> tmpMap = new Map<Id, String>();
        tmpMap.put(activationLines.get(9).Id, phoneAssignments.get(9).Id);

        NumberActivationLinesExecutorHandler.parameters params = new NumberActivationLinesExecutorHandler.parameters();
        params.activationLineIdToAssignementId = new Map<Id, String>(tmpMap);
        String lastExecutorParameter = JSON.serialize(params);
        
        Assert.areEqual(output.get(0).publishedEvents.size(), 4, 'Four events should be published.' );
        Assert.areEqual(output.get(0).publishedEvents.get(3).Parameters__c , lastExecutorParameter, 'The events has only 10 in it list.' );
    }
}