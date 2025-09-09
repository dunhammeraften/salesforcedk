public with sharing class QuoteValidUntilSchedule implements Schedulable {
    public void execute(SchedulableContext sc) {
        QuoteValidUntilBatch batch = new QuoteValidUntilBatch();
        Database.executeBatch(batch);
    }
}