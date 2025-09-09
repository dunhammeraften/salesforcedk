public with sharing class HomeOfficeFlowGetActivationLine {
	@InvocableMethod(label='Find Activation Line in a list' description='Find Activation Line in a list')
	public static List<OutputVariables> getActivationLine(List<InputVariables> inputVariables) {
		// Input
		List<Activation_Line__c> passedInActivationLines = inputVariables.get(0).activationLines;
		List<Id> passedInProcessedActivationLineIds = inputVariables.get(0).processedActivationLineIds;
		String passedInAgreementType = inputVariables.get(0).agreementType; // Specified or Framework
		Id passedInSelectionRecordId = inputVariables.get(0).selectionRecordId;

		System.debug('passedInActivationLines = ' + passedInActivationLines);

		// Logic
		Activation_Line__c selectedActivationLine = null;

		for (Activation_Line__c activationLine : passedInActivationLines) {
			System.debug('activationLine = ' + activationLine);
			if (passedInAgreementType.equalsIgnoreCase('Framework')) {
				if (
					activationLine.Location_Line__c == passedInSelectionRecordId &&
					(passedInProcessedActivationLineIds == null || !passedInProcessedActivationLineIds.contains(activationLine.Id))
				) {
					selectedActivationLine = activationLine;
					break;
				}
			} else if (passedInAgreementType.equalsIgnoreCase('Specified')) {
				if (
					activationLine.Quote_Line__c == passedInSelectionRecordId &&
					(passedInProcessedActivationLineIds == null || !passedInProcessedActivationLineIds.contains(activationLine.Id))
				) {
					selectedActivationLine = activationLine;
					break;
				}
			}
			System.debug('selectedActivationLine = ' + selectedActivationLine);
		}

		// Output
		List<OutputVariables> outputVarsList = new List<OutputVariables>();
		OutputVariables outputVars = new OutputVariables();
		outputVars.activationLine = selectedActivationLine;
		outputVarsList.add(outputVars);
		System.debug('outputVarsList = ' + outputVarsList);
		return outputVarsList;
	}

	public class InputVariables {
		@InvocableVariable
		public List<Activation_Line__c> activationLines;

		@InvocableVariable
		public List<Id> processedActivationLineIds;

		@InvocableVariable
		public String agreementType; // Specified or Framework

		@InvocableVariable
		public Id selectionRecordId;
	}

	public class OutputVariables {
		@InvocableVariable
		public Activation_Line__c activationLine;
	}
}