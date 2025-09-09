/** 
 * Wrapper class that holds maps belonging to an Opportunity.
 * Used in the Home Office solution to ensure that Activation Lines are updated with data from Location Lines.
 * 
 * @author  Kirstine Nielsen
 * @since   07-05-2025
 * @see     https://jira.atlassian.teliacompany.net/browse/DKT-44508
 */
public with sharing class HomeOfficeDataWrapper {
    
    public Map<Id, SBQQ__QuoteLine__c> quoteLineMap;
    public Map<String, List<SBQQ__QuoteLine__c>> concatenatedIdsToQuoteLinesMap;
    public Map<Id, Activation_Line__c> activationLineMap;
    public Map<Id, Activation__c> activationMap;
    public Map<Id, Location_Line__c> locationLineMap;
    public Map<Id, Activation_Line__c> locationLineIdToActivationLineMap;
    public Map<Id, List<Activation_Line__c>> quoteLineIdToActivationLinesMap;    
    
    // HomeOfficeDataWrapper with necessary map properties for a specific Opportunity
    public HomeOfficeDataWrapper() {
        this.quoteLineMap = new Map<Id, SBQQ__QuoteLine__c>();
        this.concatenatedIdsToQuoteLinesMap = new Map<String, List<SBQQ__QuoteLine__c>>();
        this.activationLineMap = new Map<Id, Activation_Line__c>();
        this.activationMap = new Map<Id, Activation__c>();
        this.locationLineMap = new Map<Id, Location_Line__c>();
        this.locationLineIdToActivationLineMap = new Map<Id, Activation_Line__c>();
        this.quoteLineIdToActivationLinesMap = new Map<Id, List<Activation_Line__c>>();   
    }

}