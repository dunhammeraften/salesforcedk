public with sharing class UploadTool {
    @AuraEnabled(cacheable=false)
    public static void uploadLines(String jsonData, String actId, Boolean insertLinesWithoutId) {

        List<Activation_Line__c> als = (List<Activation_Line__c>)JSON.deserialize(jsonData, List<Activation_Line__c>.class);
        List<Activation_Line__c> alsWithId = new List<Activation_Line__c>();
        List<Activation_Line__c> alsWithoutId = new List<Activation_Line__c>();

        for (Activation_Line__c al : als) {
            if (String.isBlank(al.Id)) {
                al.Activation__c = actId;
                alsWithoutId.add(al);
            } else {
                alsWithId.add(al);
            }
        }

        try {
            if (insertLinesWithoutId == null || insertLinesWithoutId == true) {
                insert alsWithoutId;
            }
            update alsWithId;
        } catch (Exception e) {
            System.debug(e);
        }
        
    }
}