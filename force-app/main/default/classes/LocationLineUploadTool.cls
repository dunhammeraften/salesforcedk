public without sharing class LocationLineUploadTool {

    @AuraEnabled(cacheable=false)
    public static void uploadLocationLines(String jsonData, String oppId) {
        System.debug(jsonData);
        List<Location_Line__c> als = (List<Location_Line__c>)JSON.deserialize(jsonData, List<Location_Line__c>.class);
        List<Location_Line__c> als_with_id = new List<Location_Line__c>();
        List<Location_Line__c> als_without_id = new List<Location_Line__c>();

        for (Location_Line__c al : als) {
            if (String.isBlank(al.Id)) {
                al.Opportunity__c = oppId;
                als_without_id.add(al);
            } else {
                als_with_id.add(al);
            }
        }

        System.debug(als_with_id);
        System.debug(als_without_id);

        try {
            insert als_without_id;
            update als_with_id;
        } catch (Exception e) {
            System.debug(e);
        }

    }


    @AuraEnabled(cacheable=false)
    public static Location_line__c uploadLocationLineAndReturnRecord(String jsonData, String oppId) {

        Location_Line__c line = (Location_Line__c)JSON.deserialize(jsonData, Location_Line__c.class);
        line.Opportunity__c = oppId;
      
        try {
            insert line;
        } catch (Exception e) {
            System.debug(e);
        }

        return line;

    }

}