/**
 * @description This class is used to schedule the batchUpdatePhoneNumberReservations batch job.
 * @author Kenneth Houkjær
 */
global class ScheduleBatchUpdPhoneNumberRes implements Schedulable {
   /**
    * @description This method is called when the job is scheduled to run.
    * It creates an instance of the batchUpdatePhoneNumberReservations class and executes it.
    * @param sc The schedulable context.
    * @author Kenneth Houkjær
    */
   global void execute(SchedulableContext sc) {
      try {
         batchUpdatePhoneNumberReservations b = new batchUpdatePhoneNumberReservations();
         Database.executeBatch(b);
      }
      catch(Exception ex) {
         Logger.logError('ScheduleBatchUpdPhoneNumberRes', ex.getMessage()); 
      }
   }
}