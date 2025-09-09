public class Contract_RenewalQuoteSchedule implements Schedulable{

    public void execute(SchedulableContext ctx) {
       
       Contract_RenewalQuote ProcessBatch = new Contract_RenewalQuote();
       ID batchprocessid = Database.executeBatch(ProcessBatch,1);
    
    }
    
}