/**
 * The AccountPhoneNumberAssignmentSelector class is responsible for selects related to Account Phone Number Assignments
 *  -----------------------------------------------------------------------------
 *  Developer            Date            Description
 *  -----------------------------------------------------------------------------
 *  Kenneth Houkjær         22/06/2025      Initial version 
 * 
 * 
 * @author Kenneth Houkjær
 * @date 22/06/2025
 */
public virtual with sharing class AccountPhoneNumberAssignmentSelector {

    private static AccountPhoneNumberAssignmentSelector mock;

    @TestVisible
    private static void setMock(AccountPhoneNumberAssignmentSelector mockInstance) {
        mock = mockInstance;
    }

    public virtual Account_Phone_Number_Assignment__c selectByMsisdn(String msisdn) {
        return null;
    }

    /**
     * 
     * @param acc An Account owning the assignments, if null all assignemnts for all 
     *            Accounts are returned.
     * @return List<Account_Phone_Number_Assignment__c> 
     */
    public static List<Account_Phone_Number_Assignment__c> getAssignments(Account acc){
       
        List<Account_Phone_Number_Assignment__c> assignments;
        List<String> fieldsToQuery = new List<String>{
                    'Id', 'Name', 'Phone_Number__c', 'CTN_Number_Status__c', +
                    'Account_Phone_Number_Series__c', + // Master-Detail Relationship ID
                    'Account_Phone_Number_Series__r.Name', + // Name of the parent series
                    'Account_Phone_Number_Series__r.Number_Group__c', +
                    'Account_Phone_Number_Series__r.Number_Location__c', +
                    'Phone_Number_Reservation_Error__c', +
                    'Phone_Number_Reservation_Status__c', +
                    'Phone_Number_user__c', +
                    'Account__c', + // Lookup to Account
                    'Account_Phone_Number_Series__r.Product_Type__c', +
                    'account__r.CVR__c' 
        };
        
        if(acc != null){
            assignments = new Query('Account_Phone_Number_Assignment__c').
            selectFields(fieldsToQuery).
            addConditionEq('Account__c', acc.Id).
            run();
        }
        else{
            assignments = new Query('Account_Phone_Number_Assignment__c').
            selectFields(fieldsToQuery).
            run();
        }

        return assignments;
    }

    /**
     * KIRSTINE
     * Returning only assignments that are not linked to an Activation Line.
     * @param acc An Account owning the assignments, if null all unlinked assignments for all Accounts are returned.
     * @return List<Account_Phone_Number_Assignment__c> 
     */
    public static List<Account_Phone_Number_Assignment__c> getAssignmentsUnlinkedToActivationLine(Account acc) {
       
        List<Account_Phone_Number_Assignment__c> assignments;
        List<String> fieldsToQuery = new List<String>{
            'Id', 'Name', 'Phone_Number__c', 'CTN_Number_Status__c', +
            'Account_Phone_Number_Series__c', + // Master-Detail Relationship ID
            'Account_Phone_Number_Series__r.Name', + // Name of the parent series
            'Account_Phone_Number_Series__r.Number_Group__c', +
            'Account_Phone_Number_Series__r.Number_Location__c', +
            'Phone_Number_Reservation_Error__c', +
            'Phone_Number_Reservation_Status__c', +
            'Phone_Number_user__c', +
            'Account__c', + // Lookup to Account
            'Account_Phone_Number_Series__r.Product_Type__c', +
            'account__r.CVR__c' 
        };
        
        if (acc != null) {
            assignments = new Query('Account_Phone_Number_Assignment__c').
            selectFields(fieldsToQuery).
            addConditionEq('Account__c', acc.Id).
            addConditionNull('Activation_line__c').
            run();
        } else {
            assignments = new Query('Account_Phone_Number_Assignment__c').
            selectFields(fieldsToQuery).
            addConditionNull('Activation_line__c').
            run();
        }

        return assignments;
    } 
}