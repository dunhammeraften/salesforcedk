public without sharing class HomeOfficeSelector {
       
    @AuraEnabled(cacheable=true)
    public static List<Home_Office_Product_Preferences__mdt> getHomeOfficeProductOptions() {
        return [
            SELECT Label, Product_Da_Translation__c, Product_Codes__c, Product_Sequence__c 
            FROM Home_Office_Product_Preferences__mdt 
            WHERE Customer_Option__c = TRUE
            // WITH SECURITY_ENFORCED
            ORDER BY Product_Sequence__c
        ];
    }

    @AuraEnabled(cacheable=true)
    public static string getHomeOfficeProductOptionsRanking() {
        User userRecord = [SELECT Contact.AccountId, ContactId FROM User WHERE Id = :UserInfo.getUserId()];
    
        String accId = userRecord.ContactId != null ? userRecord.Contact.AccountId : 'ERROR: User not found!';
    
        Account accountRecord = [SELECT Home_Office_Product_Preferences__c FROM Account WHERE Id = :accId];
    
        return accountRecord.Home_Office_Product_Preferences__c;
    }

    @AuraEnabled(cacheable=true)
    public static string getAccount() {
      // AccountWrapper retValue = new AccountWrapper();
      Id currUserId = UserInfo.getUserId();
  
      String accId = 'THIS IS A TEST';
      User userRecord = [
        SELECT Id, ContactId, Contact.AccountId
        FROM User
        WHERE Id = :currUserId
      ];
      if (userRecord.ContactId != null) {
        accId = userRecord.Contact.AccountId;
      } else {
        System.debug('ERROR: User not found!');
      }
      return accId;
    }
  
    @AuraEnabled(cacheable=true)
    public static string getOpportunity() {
      
      Id currUserId = UserInfo.getUserId();
      String oppId = 'Not found';

      User userRecord = [
        SELECT Id, ContactId, Contact.AccountId
        FROM User
        WHERE Id = :currUserId
      ];

      if (userRecord.ContactId != null) {
        
        List<OpportunityContactRole> oppContactRoleRecord = [
            SELECT Id, OpportunityId
            FROM OpportunityContactRole
            WHERE ContactId =:userRecord.ContactId AND Role = 'Sales Contact' 
        ];

        oppId = oppContactRoleRecord[0].OpportunityId;

      } else {
        System.debug('ERROR: User not found!');
      }
      
      return oppId;
    }


}