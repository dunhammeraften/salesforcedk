public class Contract_RenewalOpportunitySchedule implements Schedulable{

    public void execute(SchedulableContext ctx) {
       
       Contract_RenewalOpportunity ProcessBatch = new Contract_RenewalOpportunity();
       ID batchprocessid = Database.executeBatch(ProcessBatch,1);
    
    }
    
}