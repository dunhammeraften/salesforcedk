/** 
 * This Apex Class is used in the Flow 'Activation Line Update From Location Line'.
 * Used in the Home Office solution to ensure that Activation Lines are updated with data from Location Lines.
 * The class is introduced as a replacement for an existing Apex Action HomeOfficeFlowGetActivationLine which isn't 
 * catering for big amount of lines.
 * 
 * @author  Kirstine Nielsen
 * @since   07-05-2025
 * @see     https://jira.atlassian.teliacompany.net/browse/DKT-44508
 */
public with sharing class HomeOfficeFlowAction {

    /**
     * Goes through all inputVariables and returns a list of outputVariables.
     * Will for each inputVariable find the relevant Location Lines and Activation Lines and create outputVariables
     * and return them in a list of outputVariables.
     * Note: we write it to be able to handle mass update, i.e. via inspector or dataloader, 
     * not just for one single opportunity update, hence we don't want to merely do:
     * inputVariables.get(0).xxx and only deal with index 0.
     * 
     * @param inputVariables The list of inputVariables that holds the Opportunity in question.
     * @return List<OutputVariables>
     */
    @InvocableMethod(label='Get Home Office related records to act on' description='Get Home Office related records to act on')
    public static List<OutputVariables> getHomeOfficeRelatedRecordsToActOn(List<InputVariables> inputVariables) {
		List<OutputVariables> outputVarsList = new List<OutputVariables>();
        
		List<Opportunity> opportunityList = new List<Opportunity>();

        for (InputVariables inputVars : inputVariables) {
            opportunityList.add(inputVars.inputOpportunity);
        }

        outputVarsList = HomeOfficeFlowActionOutputVarsGenerator.generateListOfOutputVars(opportunityList);

        logInformationForOutputVarsList(outputVarsList);

        Logger.emit();
        
		// Output
		return outputVarsList;
	}
    
    private static void logInformationForOutputVarsList(List<OutputVariables> outputVarsList) {
        Logger.logInfo('outputVarsList size: ' + outputVarsList.size()); 
        // loop through outputVarsList and log infor about the list sizes
        for (OutputVariables outputVars : outputVarsList) {
            Logger.logInfo('outputVars.activationLinesToUpdate size: ' + outputVars.activationLinesToUpdate.size());
            Logger.logInfo('outputVars.activationToUpdate: ' + outputVars.activationToUpdate.Name);
            Logger.logInfo('outputVars.locationLinesToUpdate size: ' + outputVars.locationLinesToUpdate.size());
            Logger.logInfo('outputVars.quoteLinesToUpdate size: ' + outputVars.quoteLinesToUpdate.size());
            Logger.logInfo('outputVars.activationLinesToDelete size: ' + outputVars.activationLinesToDelete.size());
        }
    } 

	public class InputVariables {
		@InvocableVariable
		public Opportunity inputOpportunity;
	}

	public class OutputVariables {
		@InvocableVariable
		public List<Activation_Line__c> activationLinesToUpdate;

		@InvocableVariable
		public Activation__c activationToUpdate;

		@InvocableVariable
		public List<Location_Line__c> locationLinesToUpdate;

		@InvocableVariable
		public List<SBQQ__QuoteLine__c> quoteLinesToUpdate;

		@InvocableVariable
		public List<Activation_Line__c> activationLinesToDelete;

        // constructor that initialises lists
        public OutputVariables() {
            activationLinesToUpdate = new List<Activation_Line__c>(); 
            locationLinesToUpdate = new List<Location_Line__c>();
            quoteLinesToUpdate = new List<SBQQ__QuoteLine__c>();
            activationLinesToDelete = new List<Activation_Line__c>();
        }
	}

}