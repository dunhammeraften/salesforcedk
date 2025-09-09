public class CreateUserHistoryFuture {

    @InvocableMethod
    public static void createRecord(List<User_History__c> recordsToInsert) {
        createRecordFuture(JSON.serialize(recordsToInsert));
    }
    
    @Future
    private static void createRecordFuture(String jsonString) {
        insert (List<User_History__c>) JSON.deserialize(jsonString, List<User_History__c>.class);
    }
}