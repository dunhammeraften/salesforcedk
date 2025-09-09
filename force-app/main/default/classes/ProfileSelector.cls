public with sharing class ProfileSelector {
    
    public static Profile getProfileByProfileName(String profileName) {
        return [SELECT Id FROM Profile WHERE Name = :profileName LIMIT 1];
    }
}