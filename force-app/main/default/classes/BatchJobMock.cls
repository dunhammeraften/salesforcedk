/**
 * @description Mocks the BatchJob class
 * @author Kenneth Houkjær
 */
@isTest
public class BatchJobMock extends BatchJob implements Database.Batchable<SObject> {
    public override Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator('SELECT Id FROM Account');
    }

    public override void execute(Database.BatchableContext bc, List<SObject> scope) {
        // Do nothing
    }

    public override void finish(Database.BatchableContext bc) {
        // Do nothing
    }
}