@IsTest
public with sharing class QuoteValidUntilScheduleTest {
    @IsTest
    private static void testSchedule() {
        String cronExpression = '0 0 0 ? * * *';
        QuoteValidUntilSchedule schedule = new QuoteValidUntilSchedule();

        Test.startTest();
        String jobId = System.schedule('QuoteValidUntilScheduleTest', cronExpression, schedule);
        Test.stopTest();

        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE Id = :jobId];
        Assert.areEqual(cronExpression, ct.CronExpression, 'Scheduled expression should match');
    }
}