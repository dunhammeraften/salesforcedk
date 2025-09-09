public with sharing class CaseSelector {

    public Id getCaseTeamRoleIdByName( String name ){
        Id teamRoleId = null;

        List<CaseTeamRole> teamRoles = [SELECT Id FROM CaseTeamRole WHERE Name = :name ];

        if(!teamRoles.isEmpty() && teamRoles.size() == 1){
            teamRoleId = teamRoles.get(0).Id;
        }

        return teamRoleId;
    }

    public List<Case_Status_Change__c> getCurrentCaseChangeStatus(Set<Id> cases){
        return [
			SELECT Id, Name, Set_Time__c, Case__c, Change_Time__c
			FROM Case_Status_Change__c
			WHERE Case__c IN :cases AND Change_Time__c = NULL
		];
    }

    public static Case getById(String id) {
        return [
            SELECT Id, Case_Activation_Check_Result__c, Case_Activation_Check_Time__c, CaseNumber
            FROM Case
            WHERE Id = :id
            LIMIT 1
        ];
    }
    
    public static List<Case> getOrderFulfilmentCasesByAccountId(String accountId){
        return [
            SELECT Id FROM Case WHERE Status = 'Gather information'
              AND RecordType.DeveloperName = 'Order_Fulfilment_Case'
              AND AccountId = :accountId
          ];
    }
    
    //Only used by LWC topEncryptionKey - can probably be deleted
    @AuraEnabled(Cacheable=true)
    public static String getByCurrentUser() {
        String userId = UserInfo.getUserId();
        User currentUser = [
            SELECT Id, ContactId
            FROM User
            WHERE Id = :userId
            LIMIT 1
        ];

        Contact currentContact = [
            SELECT Id
            FROM Contact
            WHERE Id = :currentUser.ContactId
            LIMIT 1
        ];

        // Retrieve the current user's Account Id
        Id userAccountId = [
            SELECT AccountId
            FROM Contact
            WHERE Id = :currentContact.Id
        ].AccountId;
        
        // Query for the Case related to the Account and meets the specified criteria
        List<Case> theCase = [
            SELECT Id, Subject, Status, RecordType.DeveloperName
            FROM Case
            WHERE AccountId = :userAccountId
                AND Status = 'Gather Information'
                AND RecordType.DeveloperName = 'Order_Fulfilment_Case'
        ];

        if(theCase.size() > 0) {
            return theCase.get(0).Id;
        }
        
        return null;
    }

    public static List<Case> getCasesByOpportunityIds(Set<Id> opportunityIds) {
        return [
            SELECT Type, Opportunity__c
            FROM Case
            WHERE Opportunity__c IN :opportunityIds
            WITH SECURITY_ENFORCED
        ];
    }

    public List<Case> getCustomerServiceCasesByIds(List<Id> caseIds) {
        return [
            SELECT Id, RecordTypeId, Awaiting_user__c
            FROM Case
            WHERE Id IN :caseIds
                AND RecordTypeId = :Schema.sObjectType.Case.getRecordTypeInfosByDeveloperName().get('Customer_Service_Case').getRecordTypeId()
        ];
    }
}