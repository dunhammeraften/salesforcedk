@IsTest
public with sharing class SystemLogSelectorTest {
    @IsTest
    private static void testGetLogsByAdditionalInformationLike() {
        String additionalInformation = 'Some text before: ' + SystemLogSelector.class.getName() + ' :and some text after.';
        String errorBody = 'Imagine a really long stack trace.';

	    ErrorLogging errorLogs = new ErrorLogging('Apex');
        errorLogs.addError(errorBody, additionalInformation);
        errorLogs.logErrors();

        Test.startTest();
        List<System_Log__c> logs = SystemLogSelector.getLogsByAdditionalInformationLike('%' + SystemLogSelector.class.getName() + '%');
        Test.stopTest();

        Assert.areEqual(1, logs.size(), 'Exactly 1 log should be returned.');
    }
}