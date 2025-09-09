/**
 * @description This abstract class is the base class for all batch jobs.
 * It provides a basic structure for batch jobs, including logging and error handling.
 * It also provides default implementations for the schedule and execute methods.
 * @author Jules
 */
public abstract class BatchJob implements Database.Batchable<SObject>, Database.Stateful, Schedulable {
    private static final String DEFAULT_CRON_EXPRESSION = '0 0 0 * * ? *';
    private static final Integer DEFAULT_BATCH_SIZE = 200;

    /**
     * @description This method is called at the beginning of the batch job.
     * It should return a Database.QueryLocator that retrieves the records to be processed.
     * @param bc The batchable context.
     * @return A Database.QueryLocator.
     * @author Jules
     */
    public abstract Database.QueryLocator start(Database.BatchableContext bc);

    /**
     * @description This method is called for each batch of records.
     * It should contain the logic to be executed for each record.
     * @param bc The batchable context.
     * @param scope The list of records to process.
     * @author Jules
     */
    public abstract void execute(Database.BatchableContext bc, List<SObject> scope);

    /**
     * @description This method is called at the end of the batch job.
     * It can be used to send a summary email or perform other cleanup tasks.
     * @param bc The batchable context.
     * @author Jules
     */
    public abstract void finish(Database.BatchableContext bc);

    /**
     * @description This method is used to schedule the batch job.
     * It uses the cron expression returned by the getCronExpression method.
     * @author Jules
     */
    public virtual void schedule() {
        String jobName = this.getJobName();
        String cronExpression = this.getCronExpression();
        System.schedule(jobName, cronExpression, this);
    }

    /**
     * @description This method is used to execute the batch job immediately.
     * It uses the batch size returned by the getBatchSize method.
     * @author Jules
     */
    public virtual void execute() {
        Database.executeBatch(this, this.getBatchSize());
    }

    /**
     * @description This method is called by the scheduler.
     * It executes the batch job.
     * @param sc The schedulable context.
     * @author Jules
     */
    public void execute(SchedulableContext sc) {
        this.execute();
    }

    /**
     * @description This method returns the name of the job.
     * By default, it returns the name of the class.
     * @return The name of the job.
     * @author Jules
     */
    public virtual String getJobName() {
        return String.valueOf(this).substring(0, String.valueOf(this).indexOf(':'));
    }

    /**
     * @description This method returns the cron expression for the job.
     * By default, it returns a cron expression that runs the job every day at midnight.
     * @return The cron expression for the job.
     * @author Jules
     */
    public virtual String getCronExpression() {
        return DEFAULT_CRON_EXPRESSION;
    }

    /**
     * @description This method returns the batch size for the job.
     * By default, it returns a batch size of 200.
     * @return The batch size for the job.
     * @author Jules
     */
    public virtual Integer getBatchSize() {
        return DEFAULT_BATCH_SIZE;
    }
}