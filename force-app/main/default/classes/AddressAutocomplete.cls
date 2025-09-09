public without sharing class AddressAutocomplete {
    
    @AuraEnabled(cacheable=false)
    public static void uploadLines(String jsonData) {
        List<Location_Line__c> linesToInsert = (List<Location_Line__c>)JSON.deserialize(jsonData, List<Location_Line__c>.class);
        
        try {
            insert linesToInsert;
        } catch (Exception e) {
            System.debug(e);
        }
        
    }

}