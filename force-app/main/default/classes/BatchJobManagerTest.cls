/**
 * @description Test the BatchJobManager 
 * @author Kenneth Houkjær
 */
@isTest
private class BatchJobManagerTest {
    @isTest
    static void testStartAllJobs() {
        Test.startTest();
        BatchJobManager.startAllJobs();
        Test.stopTest();

        List<CronTrigger> triggers = [SELECT Id FROM CronTrigger];
        System.assert(!triggers.isEmpty(), 'No jobs were scheduled');
    }

    @isTest
    static void testStopAllJobs() {
        Test.startTest();
        // Schedule the mock job
        BatchJobMock mockJob = new BatchJobMock();
        mockJob.schedule();

        // Stop all jobs
        BatchJobManager.stopAllJobs();
        Test.stopTest();

        List<CronTrigger> triggers = [SELECT Id FROM CronTrigger WHERE CronJobDetail.Name = 'BatchJobMock'];
        System.assert(triggers.isEmpty(), 'Jobs were not aborted');
    }

    @isTest
    static void testStartJob() {
        Test.startTest();
        BatchJobManager.startJob('BatchJobMock');
        Test.stopTest();

        List<CronTrigger> triggers = [SELECT Id FROM CronTrigger WHERE CronJobDetail.Name = 'BatchJobMock'];
        System.assert(!triggers.isEmpty(), 'Job was not scheduled');
    }

    @isTest
    static void testStopJob() {
        Test.startTest();
        BatchJobManager.startJob('BatchJobMock');
        BatchJobManager.stopJob('BatchJobMock');
        Test.stopTest();

        List<CronTrigger> triggers = [SELECT Id FROM CronTrigger WHERE CronJobDetail.Name = 'BatchJobMock'];
        System.assert(triggers.isEmpty(), 'Job was not aborted');
    }
}