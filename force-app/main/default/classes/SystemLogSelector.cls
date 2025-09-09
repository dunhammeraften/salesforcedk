public with sharing class SystemLogSelector {
    public static List<System_Log__c> getLogsByAdditionalInformationLike(String likeValue) {
        return [
            SELECT 
                Id,
                Origin__c,
                Type__c,
                Error_Body__c,
                Additional_Information__c
            FROM System_Log__c
            WHERE Additional_Information__c LIKE :likeValue
        ];
    }
}