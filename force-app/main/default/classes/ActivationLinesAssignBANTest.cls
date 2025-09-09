@IsTest
public with sharing class ActivationLinesAssignBANTest {

    @TestSetup
	static void createTestData() {
        Account acc = new Account(Name='Test Account',Rationale__c='Test');
        insert acc;

        Billing_Account__c ban = new Billing_Account__c(Account__c=acc.Id);
        insert ban;

        Case theCase = new Case();
        insert theCase;

        Activation__c activation = new Activation__c(Case__c=theCase.Id);
        insert activation;

        List<Activation_Line__c> testActivationLines = new List<Activation_Line__c>();
        for (Integer i = 0; i < 5; i++) {
            Activation_Line__c activationLine = new Activation_Line__c();
            activationLine.Activation__c = activation.Id;
            testActivationLines.add(activationLine);
        }
        insert testActivationLines;
    }

    @IsTest
    static void testAssignBAN() {
        // Get test data
        List<Activation_line__c> testActivationLines = [SELECT Id FROM Activation_line__c];
        Billing_Account__c ban = [SELECT Id FROM Billing_Account__c];

        // Call the assignBAN method
        ActivationLinesAssignBAN.InputClass input = new ActivationLinesAssignBAN.InputClass();
        input.activationLines = testActivationLines;
        input.ban = ban.Id;
        ActivationLinesAssignBAN.assignBAN(new List<ActivationLinesAssignBAN.InputClass>{input});

        // Verify that Billing_Account__c is correctly updated
        List<Activation_Line__c> updatedActivationLines = [SELECT Id, Billing_Account__c FROM Activation_Line__c WHERE Id IN :testActivationLines];
        for (Activation_Line__c activationLine : updatedActivationLines) {
            System.assertEquals(ban.Id  , activationLine.Billing_Account__c);
        }
    }
}