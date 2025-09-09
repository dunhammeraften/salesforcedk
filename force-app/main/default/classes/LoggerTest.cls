/**
 * The LoggerTest class is responsible for unit testing the methods made available by the Logger class
 * @log:
 *  -----------------------------------------------------------------------------
 *  Developer            Date            Description
 *  -----------------------------------------------------------------------------
 *  Sergio Pedro         18/03/2025      Initial version
 *  Sergio Pedro         28/07/2025      Focring the Logger to run in the context of this test
 * 
 * @author Sergio Pedro
 * @date 18/03/2025
 */
@IsTest
public with sharing class LoggerTest {

    static final String LOG_TEXT = 'Test message';

    // Test method for logInternal
    @IsTest
    static void testLogInternal() {

        try {
            Test.startTest();
            Logger.skipLoggingOnTestScope = false;
            Logger.logInternal(LOG_TEXT);
            Test.stopTest();

            Assert.isTrue(true, 'Method only makes a system debug and if no exception was thrown all is green');
        } catch (Exception ex) {
            Assert.isTrue(false, 'Method only makes a system debug and if exception was thrown all is red');
        } 
    }

    // Test method for logFinest
    @IsTest
    static void testLogFinest_WithAllParameters_Success() {
        Test.startTest();
        
        Logger.skipLoggingOnTestScope = false;
        Logger.logFinest(LOG_TEXT);
        Logger.emit();

        Test.stopTest();

        // Assert that the specific platform event you expect is triggered
        Assert.areEqual(1, Logger.testValidation.size(), 'Platform event should be logged');
    }

    // Test method for logFiner
    @IsTest
    static void testLogFiner_WithAllParameters_Success() {
        Test.startTest();

        Logger.skipLoggingOnTestScope = false;
        Logger.logFiner(LOG_TEXT);
        Logger.emit();

        Test.stopTest();

        // Assert that the specific platform event you expect is triggered
        Assert.areEqual(1, Logger.testValidation.size(), 'Platform event should be logged');
    }

    // Test method for logFine
    @IsTest
    static void testLogFine_WithAllParameters_Success() {
        Test.startTest();

        Logger.skipLoggingOnTestScope = false;
        Logger.logFine(LOG_TEXT);
        Logger.emit();

        Test.stopTest();

        // Assert that the specific platform event you expect is triggered
        Assert.areEqual(1, Logger.testValidation.size(), 'Platform event should be logged');
    }

    @IsTest
    static void testLogDebug_WithAllParameters_Success() {
        Test.startTest();

        Logger.skipLoggingOnTestScope = false;
        Logger.logDebug(LOG_TEXT);
        Logger.emit();

        Test.stopTest();

        // Assert that the specific platform event you expect is triggered
        Assert.areEqual(1, Logger.testValidation.size(), 'Platform event should be logged');
    }

    @IsTest
    static void testLogInfo_WithAllParameters_Success() {
        Test.startTest();

        Logger.skipLoggingOnTestScope = false;
        Logger.logInfo(LOG_TEXT);
        Logger.emit();

        Test.stopTest();

        // Assert that the specific platform event you expect is triggered
        Assert.areEqual(1, Logger.testValidation.size(), 'Platform event should be logged');
    }

    @IsTest
    static void testLogWarning_WithAllParameters_Success() {
        Test.startTest();

        Logger.skipLoggingOnTestScope = false;
        Logger.logWarning(LOG_TEXT);
        Logger.emit();

        Test.stopTest();

        // Assert that the specific platform event you expect is triggered
        Assert.areEqual(1, Logger.testValidation.size(), 'Platform event should be logged');
    }

    @IsTest
    static void testLogError_WithAllParameters_Success() {
        Test.startTest();

        Logger.skipLoggingOnTestScope = false;
        Logger.logError('ClassName', LOG_TEXT);
        Logger.emit();

        Test.stopTest();

        // Assert that the specific platform event you expect is triggered
        Assert.areEqual(1, Logger.testValidation.size(), 'Platform event should be logged');
    }

    // Test method for logError with class name, message content, and error code
    @IsTest
    static void testLogErrorWithErrorCode_WithAllParameters_Success() {

        Test.startTest();

        Logger.skipLoggingOnTestScope = false;
        Logger.logError('ClassName', LOG_TEXT, 'ERROR_CODE');
        Logger.emit(); 

        Test.stopTest();

        // Assert that the specific platform event you expect is triggered
        Assert.areEqual(1, Logger.testValidation.size(), 'Platform event should be logged');
    }

    @IsTest
    static void testLogFromFlow_WithAllParameters_Success() {

        List<Logger.LogEntry> logToWrite = new List<Logger.LogEntry>();
        Logger.LogEntry newLogEntry = new Logger.LogEntry(); 
        newLogEntry.level = 'DEBUG'; 
        newLogEntry.messageContent = 'Message from Flow';
        logToWrite.add(newLogEntry);

        Test.startTest();

        Logger.skipLoggingOnTestScope = false;
        Logger.log(logToWrite);
        Logger.emit();

        Test.stopTest();

        Assert.areEqual(1, Logger.testValidation.size(), 'Platform event should be logged');
    }

    @IsTest
    static void testLogFromFlow_WithInvalidLevel_NoLogWritten() {

        List<Logger_Setting__mdt> mockedMetadata = new List<Logger_Setting__mdt>();
        mockedMetadata.add(createMockedLoggerSetting(LoggingLevel.WARN));

        MetadataSelector.setMock(new MetadataSelectorMock(mockedMetadata));

        Test.startTest();

        Logger.skipLoggingOnTestScope = false;
        Logger.logFinest(LOG_TEXT);
        Logger.emit();

        Test.stopTest();

        Assert.areEqual(0, Logger.testValidation.size(), 'Platform event should not be logged');
    }

    static Log_Ignore__mdt createMockedLoggerIgnoreMapping(String label, String userName, Boolean active){
 
        Log_Ignore__mdt loggerMapping = new Log_Ignore__mdt();
        loggerMapping.Filter_String__c = label;
        loggerMapping.Filter_UserName__c = userName;
        loggerMapping.Active__c = active;
 
        return loggerMapping;
    }
 
    static Logger_Setting__mdt createMockedLoggerSetting(LoggingLevel logLevel){
 
        Logger_Setting__mdt loggerSetting = new Logger_Setting__mdt();
        loggerSetting.Log_Level__c = logLevel.toString();
 
        return loggerSetting;
    }
}