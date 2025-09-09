/**
 * @description This batch job is used to update the phone number reservations for all accounts.
 * It iterates through all Account_Phone_Number_Series__c records and calls the NumberSyncService to synchronize the assignments.
 * @author Kenneth Houkjær
 */
public class batchUpdatePhoneNumberReservations extends BatchJob {
    private static final String QUERY = 'SELECT Id, Account__c FROM Account_Phone_Number_Series__c';
    @TestVisible
    private NumberSyncService numberSyncService;

    /**
     * @description The constructor for the batchUpdatePhoneNumberReservations class.
     * It initializes the numberSyncService.
     * @author Kenneth Houkjær
     */
    public batchUpdatePhoneNumberReservations() {
        this.numberSyncService = new NumberSyncService();
    }

    /**
     * @description This method is called at the beginning of the batch job.
     * It returns a Database.QueryLocator that retrieves the records to be processed.
     * @param bc The batchable context.
     * @return A Database.QueryLocator.
     * @author Kenneth Houkjær
     */
    public override Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(QUERY);
    }

    /**
     * @description This method is called for each batch of records.
     * It iterates through the records and calls the NumberSyncService to synchronize the assignments.
     * @param bc The batchable context.
     * @param scope The list of records to process.
     * @author Kenneth Houkjær
     */
    public override void execute(Database.BatchableContext bc, List<SObject> scope) {
        for (SObject s : scope) {
            Account_Phone_Number_Series__c series = (Account_Phone_Number_Series__c) s;
            try {
                Account acc = new Account(Id = series.Account__c);
                this.numberSyncService.synchronizeAssignmentsForAccount(acc);
            } catch (Exception e) {
                Logger.logError(this.getJobName(), 'Error processing Account_Phone_Number_Series__c ' + series.Id + ': ' + e.getMessage());
            }
        }
    }

    /**
     * @description This method is called at the end of the batch job.
     * It logs a message and emits the logs.
     * @param bc The batchable context.
     * @author Kenneth Houkjær
     */
    public override void finish(Database.BatchableContext bc) {
        Logger.logInfo(this.getJobName() + ' finished.');
        Logger.emit();
    }

    /**
     * @description This method returns the cron expression for the job.
     * It returns a cron expression that runs the job every day at 1am.
     * @return The cron expression for the job.
     * @author Kenneth Houkjær
     */
    public override String getCronExpression() {
        return '0 0 1 * * ?'; // Every day at 1am
    }
}