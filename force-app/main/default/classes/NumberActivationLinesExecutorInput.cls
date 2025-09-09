/**
 * The NumberActivationLinesExecutorInput class is an invocable action that creates a mapping between activation lines and phone number assignments.
 * It is used in a flow to prepare the input for the NumberActivationLinesExecutorHandler.
 *  -----------------------------------------------------------------------------
 *  Developer            Date            Description
 *  -----------------------------------------------------------------------------
 *  Kenneth Houkjær         27/07/2025      Initial version
 *
 * 
 * @author Kenneth Houkjær
 * @date 27/07/2025
 */
public with sharing class NumberActivationLinesExecutorInput {
    private static String PHONE_NUMBER_RESERVATION_STATUS_INPROGRESS = 'INPROGRESS';

    /**
     * @description This method is called from a flow to create a mapping between activation lines and phone number assignments.
     * @param inputVariables A list of input variables from the flow.
     * @return A list of output variables containing the mapping.
     */
    @InvocableMethod(category='Number' label='Create ActivationLineExecutor Input' description='Creates a List<IdToString> collection mapping activationLines and assignments.')
    public static List<OutputVariables> createActivationLineToAssignmentMappings(List<InputVariables> inputVariables) {        
        OutputVariables output = new OutputVariables();
        output.activationLineIdToAssignementId = new List<IdToString>();
        
        try {
            // keep SOQL here instead of using selector class, advised by Kenneth
            Activation__c activation = [
                SELECT Id, Case__r.Id, Case__r.AccountId 
                FROM Activation__c 
                WHERE Id = :inputVariables.get(0).activation.Id
            ];

            Account acc = AccountSelector.getAccountByCaseId(activation.case__r.id);

            // we only want Account_Phone_Number_Assignment__c records where the Lookup field to Activation Line is null
            List<Account_Phone_Number_Assignment__c> listOfPhoneNumberAssignments = AccountPhoneNumberAssignmentSelector.getAssignmentsUnlinkedToActivationLine(acc);

            //TODO: khp we should filter the activationlines to those who need phone numbers
            // List<Activation_line__c> listOfActivationLines = ActivationLineSelector.getActivationLinesByCaseId(activation.Case__c);

            // we only want Activation_line__c records where Mobile_no__c is blank
            // keep SOQL here instead of using selector class, advised by Kenneth
            List<Activation_line__c> listOfActivationLines = [
                SELECT Id
                FROM Activation_line__c
                WHERE Activation__r.Case__c = :activation.Case__c AND Not_to_Activation__c = FALSE AND Mobile_no__c = ''
            ];

            Logger.logInfo('listOfActivationLines: ' + listOfActivationLines);
            Logger.logInfo('listOfActivationLines.size(): ' + listOfActivationLines.size());
            Logger.logInfo('listOfPhoneNumberAssignments: ' + listOfPhoneNumberAssignments);
            Logger.logInfo('listOfPhoneNumberAssignments.size(): ' + listOfPhoneNumberAssignments.size());

            for (integer i = 0; i < listOfActivationLines.size(); i++) {                
                Activation_line__c activationLine = listOfActivationLines.get(i);
                activationLine.Phone_Number_Reservation_Status__c = PHONE_NUMBER_RESERVATION_STATUS_INPROGRESS;
            }
            update listOfActivationLines;
            
            for (integer i = 0; i < listOfActivationLines.size(); i++) {                
                //were assigning new numbers to activationlines, so we do not care about the index as long as we have enough.            
                Activation_line__c activationLine = listOfActivationLines.get(i);
                Account_Phone_Number_Assignment__c assignment = listOfPhoneNumberAssignments.get(i);

                IdToString idToString = new IdToString();
                idToString.key = activationLine.Id;
                idToString.value = assignment.Id;
                output.activationLineIdToAssignementId.add(idToString);
            }
            Logger.emit();
        } catch(HTTPException ex) {
            Logger.logError(ex);
            Logger.emit();
            throw ex;
        }
        
        return new List<OutputVariables>{output};
  }

    public class InputVariables {
    @InvocableVariable
    public Activation__c activation;
  }

  public class OutputVariables {
        @InvocableVariable
        public List<IdToString> activationLineIdToAssignementId;
  }
}