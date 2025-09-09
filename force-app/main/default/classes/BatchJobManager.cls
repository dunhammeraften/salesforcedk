/**
 * @description This class is used to manage all batch jobs that implement the BatchJob interface.
 * It provides methods to start and stop all batch jobs, as well as individual batch jobs.
 */
public class BatchJobManager {
    /**
     * @description Starts all batch jobs that implement the BatchJob interface.
     * @author Jules
     */
    public static void startAllJobs() {
        List<BatchJob> jobs = getAllBatchJobs();
        for (BatchJob job : jobs) {
            startJob(job.getJobName());
        }
    }

    /**
     * @description Stops all batch jobs that implement the BatchJob interface.
     * @author Jules
     */
    public static void stopAllJobs() {
        List<BatchJob> jobs = getAllBatchJobs();
        for (BatchJob job : jobs) {
            stopJob(job.getJobName());
        }
    }

    /**
     * @description Starts a specific batch job by its name.
     * @param jobName The name of the job to start.
     * @author Jules
     */
    public static void startJob(String jobName) {
        BatchJob job = getBatchJob(jobName);
        if (job != null) {
            job.schedule();
        }
    }

    /**
     * @description Stops a specific batch job by its name.
     * @param jobName The name of the job to stop.
     * @author Jules
     */
    public static void stopJob(String jobName) {
        List<CronTrigger> cronTriggers = [SELECT Id FROM CronTrigger WHERE CronJobDetail.Name = :jobName];
        for (CronTrigger cronTrigger : cronTriggers) {
            System.abortJob(cronTrigger.Id);
        }
    }

    /**
     * @description This method returns a list of all batch jobs that implement the BatchJob interface.
     * @return A list of all batch jobs.
     * @author Jules
     */
    private static List<BatchJob> getAllBatchJobs() {
        List<BatchJob> jobs = new List<BatchJob>();
        if (Test.isRunningTest()) {
            jobs.add(new BatchJobMock());
            return jobs;
        }
        for (ApexClass ac : [
            SELECT Name
            FROM ApexClass
            WHERE IsValid = TRUE
                AND Status = 'Active'
                AND NamespacePrefix = ''
        ]) {
            try {
                Type t = Type.forName(ac.Name);
                if (t != null && t.newInstance() instanceof BatchJob) {
                    jobs.add((BatchJob) t.newInstance());
                }
            } catch (Exception e) {
                // Do nothing
            }
        }
        return jobs;
    }

    /**
     * @description This method returns a batch job by its name.
     * @param jobName The name of the job to return.
     * @return A batch job.
     * @author Jules
     */
    private static BatchJob getBatchJob(String jobName) {
        try {
            Type t = Type.forName(jobName);
            if (t != null) {
                Object obj = t.newInstance();
                if (obj instanceof BatchJob) {
                    return (BatchJob) obj;
                }
            }
        } catch (Exception e) {
            Logger.logError('BatchJobManager', 'Error creating instance of ' + jobName + ': ' + e.getMessage());
        }
        return null;
    }
}