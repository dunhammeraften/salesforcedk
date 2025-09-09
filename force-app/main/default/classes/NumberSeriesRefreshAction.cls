/**
 * The NumberSeriesRefreshAction class is an invocable action used by the Phone_Number_Series_Refresh flow.
 * It is responsible for refreshing the phone number series for a given account.
 *  -----------------------------------------------------------------------------
 *  Developer            Date            Description
 *  -----------------------------------------------------------------------------
 *  Kenneth Houkjær         27/07/2025      Initial version
 *
 * @author Kenneth Houkjær
 * @date 27/07/2025
 */
public with sharing class NumberSeriesRefreshAction {    
    
    /**
     * @description This method is called from a flow to refresh the phone number series for a given account.
     * @param inputVariables A list of input variables from the flow.
     * @return A list of output variables indicating whether the refresh was successful.
     */
    @InvocableMethod(label='Refresh Phone Number Series' description='Refresh Phone Number Series')
    public static List<OutputVariables> refreshPhoneNumberSeries(List<InputVariables> inputVariables) {
        NumberClient numberClient = new NumberClient();
        
        List<OutputVariables> outputVarsList = new List<OutputVariables>();
        for (InputVariables inputVars : inputVariables) {
            // hook up with Kenneths code to pass in the Account record
            Account accountRecord = inputVars.inputAccount;

            NumberSyncService numberSyncService = new NumberSyncService ();
            Logger.logInfo('accountRecord: ' + accountRecord);
            numberSyncService.synchronizeAssignmentsForAccount(accountRecord);  // void method by Kenneth

            OutputVariables outputVars = new OutputVariables();
            outputVars.outputIsSuccess = true;  // for now, we simply just set it to true as a dummy value. it will need adjustment  depending on what Kenneth's code does???
            outputVarsList.add(outputVars);
        }
        return outputVarsList;
	}
    
	public class InputVariables {
		@InvocableVariable
		public Account inputAccount;
	}

	public class OutputVariables {
		@InvocableVariable
		public Boolean outputIsSuccess;
	}
}