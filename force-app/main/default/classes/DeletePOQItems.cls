public class DeletePOQItems {
    @InvocableMethod(label='Delete POQ Items from Location Lines' description='Delete POQ Items from Location Lines')
    public static void deleteItems(List<List<SObject>> Location_Lines_List) {
        List<Id> locationLineIds = new List<Id>();
        
        // Collect Location_Line Ids from the input
        for (List<SObject> locationLines : Location_Lines_List) {
            for (SObject locationLine : locationLines) {
                Id locationLineId = (Id)locationLine.get('Id');
                locationLineIds.add(locationLineId);
            }
        }

        // Retrieve related POQ_Item__c records
        List<POQ_Item__c> POQ_Items = [SELECT Id FROM POQ_Item__c WHERE Location_Line__c IN :locationLineIds];

        // Delete POQ_Items
        try {
            delete POQ_Items;
        } catch (DmlException e) {
            // Handle any potential exceptions
            System.debug('Error deleting POQ_Items: ' + e);
        }
    }
}