/**
 * The NumberClientServiceTest class is responsible for testing the NumberClientService class.
 *  -----------------------------------------------------------------------------
 *  Developer            Date            Description
 *  -----------------------------------------------------------------------------
 *  Kenneth Houkjær         29/07/2025      Initial version
 *
 * @author Kenneth Houkjær
 * @date 29/07/2025
 */
@IsTest(IsParallel = true)
public class NumberClientServiceTest {
 
	@IsTest
    public static void resetPhoneNumberAssignments_with10IdsAndChunkSize2_doPublish5Events(){
        //Arrange
        Map<Id, String> mapOfActivationLineIdToNumberToReset = new Map<Id, String>();

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
            activationLines.add(new Activation_line__c(Case__c = c.Id, Activation__c = activation.Id, Mobile_No__c = '2222222' + i));
        }
        insert activationLines;


        for(Integer i = 0; i < 10; i++) {
            mapOfActivationLineIdToNumberToReset.put(activationLines.get(i).Id, activationLines.get(i).Mobile_No__c);
        }
     
        //Act
        NumberClientService numberClientService = new NumberClientService();
        Boolean result = numberClientService.resetPhoneNumberAssignments(2, mapOfActivationLineIdToNumberToReset);
        //Assert
        Assert.isTrue(result, 'The method should return true');
    }
}