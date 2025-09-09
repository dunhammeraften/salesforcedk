public with sharing class ActivationLinesAssignBAN {
    
    @InvocableMethod(label='Assign BAN to Activation Lines' description='Assign BAN to Activation Lines')
	public static void assignBAN(List<InputClass> input) {
        String ban = input[0].ban;

        List<Activation_Line__c> activationLines = new List<Activation_line__c>();

        for (SObject sObj : input[0].activationLines) {
            Activation_Line__c activationLine = (Activation_Line__c)sObj;
            activationLine.Billing_Account__c = ban;
            activationLines.add(activationLine);
        }

        update activationLines;
    }

    public class InputClass {
        @InvocableVariable(required=true)
        public List<SObject> activationLines;
        @InvocableVariable(required=true)
        public String ban;
    }

}