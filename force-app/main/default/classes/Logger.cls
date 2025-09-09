/**
 * The Logger class is responsible for logging debug messages in Salesforce and log messages
 * @log:
 *  -----------------------------------------------------------------------------
 *  Developer            Date            Description
 *  -----------------------------------------------------------------------------
 *  Sergio Pedro         18/03/2025      Initial version (Based on Kenneth Houkjær's implementations)
 *  Sergio Pedro         28/07/2025      Implement a test context skip
 * 
 * @author Sergio Pedro
 * @date 18/03/2025
 */
public without sharing class Logger {
    
    /**
     * Salesforce Request Id of the transaction 
     */
    public static final String SALESFORCE_REQUEST_ID;
    /**
     * Salesforce Execution Context of the transaction
     */
    public static final Quiddity SALESFORCE_EXECUTION_CONTEXT;
    /**
     * Empty log entry message
     */
    private static final String EMPTY_LOG_MESSAGE = '(No message)';
    /**
     * Name of the configuration metadata record
     */
    public static final String LOG_SETTINGS_NAME = 'NORLYS_CentralizedLog';
    /**
     * Name of the external requests header that contain the trace id of the transaction initiated in other systems
     */
    public static final String NORLYS_COMMON_TRACEID_HEADER = 'X-NORLYS-TRACEID';
    /**
     * Size of the trace id content
     */
    public static final Integer NORLYS_COMMON_TRACEID_LEN = 36;
    
    /**
     * Variable exsiting only for unit testing purposes. validation of log entries created
     */
    @TestVisible
    private static List<Debug_Event__e> testValidation;

    @TestVisible
    private static Boolean skipLoggingOnTestScope;
    
    /**
     * Set of variables used for configuration of the Logging registration
     */
    private static Boolean isProductionOrg;
    @TestVisible
    private static Logger_Setting__mdt logSettings;
    @TestVisible
    private static LoggingLevel platformEventLogLevel;
    private static Map<String, List<String>> mapOfLogFilterStringsAndUsernames = null;

    /**
     * Variables used in the transaction logging
     */
    private static String traceId;
    private static List<LogRecord> logEntries = new List<LogRecord>();

    /**
    * Initializes all constants in the static context
    */
    static {
        Request reqInfo = Request.getCurrent();
        SALESFORCE_REQUEST_ID = reqInfo.getRequestId();
        SALESFORCE_EXECUTION_CONTEXT = reqInfo.getQuiddity();
        isProductionOrg = !OrgUtils.isSandbox();
        skipLoggingOnTestScope = Test.isRunningTest();
        
        setTraceId();

        if (platformEventLogLevel == null) {
            initializePlatformLogging();
        }

        System.debug('*** New transaction started - TRACE ID: ' + traceId + ' ***');
        System.debug('*** Platform Event Logging Level: ' + platformEventLogLevel + ' ***');
        System.debug('*** Thanks for using the Logger. Remember to emit() at least once in a transaction. ***');
    }
    
    public static void setTraceId(String loggerTraceId) {
        if (SALESFORCE_EXECUTION_CONTEXT == Quiddity.TRANSACTION_FINALIZER_QUEUEABLE) {
            traceId = loggerTraceId;
        }
    }

    public static String getTraceId() {
        return traceId;
    }

    /**
     * Initializes the trace Id of the transaction based on the existing header or by generating a new
     * @example setTraceId()
     */
    private static void setTraceId() {
        traceId = RestContext.request?.headers?.get(NORLYS_COMMON_TRACEID_HEADER) ?? OrgUtils.generateGUID();
    }

    /**
     * Initializes the static variable necessary for the log framework to register proper logs
     * @example initializePlatformLogging()
     */
    private static void initializePlatformLogging() {
        logSettings = MetadataSelector.getLoggerSettings(LOG_SETTINGS_NAME);
        if (logSettings == null) {
            System.debug(LoggingLevel.WARN, 'No logger connection setting found for: ' + LOG_SETTINGS_NAME);
            System.debug(LoggingLevel.WARN, 'Log flushing will be disabled');
            //this will result in platformEventLogLevel being null
            platformEventLogLevel = LoggingLevel.WARN;
            return;
        } 

        try {
            platformEventLogLevel = validateLogLevel(logSettings.Log_Level__c);

        } catch(Exception e) {
            platformEventLogLevel = LoggingLevel.WARN;
        }

        //a list of strings indicating that errors should be logged as warn instead of error in the kibanalog
        if (mapOfLogFilterStringsAndUsernames == null) {
            mapOfLogFilterStringsAndUsernames = getMapOfLogIgnoreStrings();
        }
    }

    /**
     * Translates a string to a LoggingLevel enumerator
     * @param logLevel string with the value of log level configured in the custom metadata record
     * @return `LoggingLevel` enumerator value
     */
    private static LoggingLevel validateLogLevel(String platformEventLogLevel) {
        return LoggingLevel.valueOf(platformEventLogLevel);
    }

    /**
     * Returns a list of Log_Ignore__mdt objects indicating whether an error should be logged as a warn instead of an error in the log
     * @return List<Log_Ignore__mdt> with all the cases that should be ignored when generating log messages
     */
    private static List<Log_Ignore__mdt> getListOfLogIgnoreObjects() {
        List<Log_Ignore__mdt> listOfLogIgnores = MetadataSelector.getLogIgnoreMappings();
        return listOfLogIgnores;
    }

    /**
     * Returns a map with the strings to filter and to which users the string should be filtered for (ex: filter text "Words to Filter" for user "Sergio Pedro")
     * @return Map<String, List<String>> where the key is the string to filter and the list is the users who should be filtered out for that string
     */
    private static Map<String, List<String>> getMapOfLogIgnoreStrings() {
        List<Log_Ignore__mdt> listOfLogIgnores = Logger.getListOfLogIgnoreObjects();

        Map<String, List<String>> mapOfFilterStringsAndUsernames = new Map<String, List<String>>();
        for (Log_Ignore__mdt logIgnore : listOfLogIgnores) {
            if (!mapOfFilterStringsAndUsernames.containsKey(logIgnore.Filter_String__c)) {
                mapOfFilterStringsAndUsernames.put(logIgnore.Filter_String__c, new List<String>());
            }

            if (!mapOfFilterStringsAndUsernames.get(logIgnore.Filter_String__c).contains(logIgnore.Filter_UserName__c)) {
                mapOfFilterStringsAndUsernames.get(logIgnore.Filter_String__c).add(logIgnore.Filter_UserName__c);
            }        
        }
        return mapOfFilterStringsAndUsernames;
    }

    /**
     * Register a log entry that is only registered in the default SFDC system.debug
     * @param messageContent message to be written
     */
    public static void logInternal(Object messageContent) {
        System.debug(LoggingLevel.INTERNAL, messageContent);
    }

    /**
     * Register a log entry that will only show if the org log level is set to FINEST
     * @param messageContent message to be written
     */
    public static void logFinest(Object messageContent) {
        log(LoggingLevel.FINEST, messageContent);
    }

     /**
     * Register a log entry that will only show if the org log level is set to FINER or less detailed
     * @param messageContent message to be written
     */
    public static void logFiner(Object messageContent) {
        log(LoggingLevel.FINER, messageContent);
    }

    /**
     * Register a log entry that will only show if the org log level is set to FINE or less detailed
     * @param messageContent message to be written
     */
    public static void logFine(Object messageContent) {
        log(LoggingLevel.FINE, messageContent);
    }

    /**
     * Register a log entry that will only show if the org log level is set to DEBUG or less detailed
     * @param messageContent message to be written
     */
    public static void logDebug(Object messageContent) {
        log(LoggingLevel.DEBUG, messageContent);
    }

    /**
     * Register a log entry that will only show if the org log level is set to INFO or less detailed
     * @param messageContent message to be written
     */
    public static void logInfo(Object messageContent) {
        log(LoggingLevel.INFO, messageContent);
    }

    /**
     * Register a log entry that will only show if the org log level is set to WARN or less detailed
     * @param messageContent message to be written
     */
    public static void logWarning(Object messageContent) {
        log(LoggingLevel.WARN, messageContent);
    }

    /**
     * Register a log entry that will only show if the org log level is set to ERROR or less detailed
     * @param className name of th eclass where the error occured
     * @param messageContent message to be written
     */
    public static void logError(Object messageContent) {
        log(LoggingLevel.ERROR, '' + messageContent);
    }

    /**
     * Register a log entry that will only show if the org log level is set to ERROR or less detailed
     * @param className name of th eclass where the error occured
     * @param messageContent message to be written
     */
    public static void logError(String className, Object messageContent) {
        log(LoggingLevel.ERROR, 'Class: ' + className + ' | ' + messageContent);
    }

    /**
     * Register a log entry that will only show if the org log level is set to ERROR or less detailed with specific error code
     * @param className name of the class where the error occured
     * @param messageContent message to be written
     * @param errorCode Error code to be added to the message
     */
    public static void logError(String className, Object messageContent, String errorCode) {
        log(LoggingLevel.ERROR, 'Class: ' + className + ' | ' + messageContent, errorCode);
    }

    /**
     * Register a log entry that will only show if the org log level is set to ERROR or less detailed with specific error code
     * @param level level at which the message should be written
     * @param className name of the class where the error occured
     * @param messageContent message to be written
     * @param errorCode Error code to be added to the message
     */
    private static void log(System.LoggingLevel level, Object messageContent, String errorCode) {
        log(level, messageContent + ' | ' + errorCode);
    }

    /**
     * Invocable method to enable the logging from flows
     * @param logEntries list of and internal object that contains the necessary input data for the log entry to be processed encapsulation of other log methods
     */
    @InvocableMethod (label='Register Log' description='Use this method to generate a log entry. do not forget the emit command at the end if the flow is the only logic.' category='Utility' iconName='slds:utility:justify_text')
    public static void log(List<LogEntry> logEntries) {
        if (!skipLoggingOnTestScope) {
            for (LogEntry logLine : logEntries) {
                log(LoggingLevel.valueOf(logLine.level), logLine.messageContent + ' | ' + logLine.errorCode);
            }
            emit();
        }
    }

    /**
     * log
     * Used to build log messages within the current transaction specified by the traceid
     *
     * @param level level
     * @param messageContent messageContent
     */
    private static void log(LoggingLevel level, Object messageContent) {
         if (!skipLoggingOnTestScope) {
            //LoggerStackTrace is used to figure out the location and information about the process that called log()
            LoggerStackTrace trace = new LoggerStackTrace();

            // If we match one of the ignore rules then we change the level from error to warn, this ensures
            // that the log message will still be present if a subsequent non-ignored error is logged, in which case all related messages are logged.
            level = changeLevelBasedOnLogIgnore(level, messageContent);

            // Always System.debug so there's only one way to log in the codebase.
            System.debug(level, messageContent);


            //Building a logRecord. When emit is called it will construct a Debug_Event__e based on this.
            LogRecord log = new LogRecord();
            log.setLogLevel(level);
            log.setLocation(trace);
            log.setLogMessage(messageContent);  

            logEntries.add(log);
        }
    }

    /**
     * @param level The logginglevel of the error being processed
     * @param messageContent The logmessage where the presence of a log ignore string should be checked
     * @return new logging level
     */
    private static System.LoggingLevel changeLevelBasedOnLogIgnore(System.LoggingLevel level, Object messageContent) {
        if (level != LoggingLevel.ERROR) {
            return level;
        }
        String userName = UserInfo.getUserName();

        for (String logIgnoreString: mapOfLogFilterStringsAndUsernames.keySet()){
            if (messageContent.toString().contains(logIgnoreString) &&
                    mapOfLogFilterStringsAndUsernames.get(logIgnoreString).contains(username)) {
                return LoggingLevel.WARN;
            }
        }
        return level;
    }
    
    /**
     * emit()
     * Used to build and publish logmessages within the current transaction specified by the traceid
     */
    public static void emit() {
        if (!skipLoggingOnTestScope) {
            List<Debug_Event__e> eventsToEmit = new List<Debug_Event__e>();

            // Dont continue the emit if theres nothing to emit
            if (logEntries.isEmpty()) {
                return;
            }
            
            eventsToEmit = buildPlatformEvents(logEntries);
            
            logEntries.clear();
            testValidation = eventsToEmit;
            EventBus.publish(eventsToEmit);
        }
    }

    /**
     * buildPlatformEvents
     * The buildPlatformEvents method builds log messages and sends them to salesforce debug or kibana under the following conditions
     * 1. if no errors exists within the transaction (in the list of loglines) and we are in a production environment, then we log nothing
     * 2. if an error exists and we are in production, then we log both the error and other level logs within the transaction
     * 3. if we are not in production, then we log according to the allowed log level.
     *
     * @param logLines A list of logline objects each representing a log message
     * @param logLevels A list of levels matching the loglines index
     */
    private static List<Debug_Event__e> buildPlatformEvents(List<LogRecord> logLines) {

        List<Debug_Event__e> events = new List<Debug_Event__e>();
        Boolean prodOrg = isProductionOrg;

        Iterator<LogRecord> logIterator = logLines.iterator();
        
        while (logIterator.hasNext()) {
            LogRecord logRecord = logIterator.next();

            //if we are in a sandbox and the system logging level does not permit logging, move on to the next log message
            //when we get to a point where all log messages are gdpr compliant, we can remove the !prodOrg
            if (logRecord == null || !shouldPlatformEventLog(logRecord.level)) {
                continue;
            }

            events.add(logRecord.getDebugEvent());
        }

        return events;
    }



    /**
     * Constructs the correct string with the message being logged based on the type of data that has been passed to the logger
     * @param messageContent Message to be logged
     * @return  `String`
     */
    private static String createLogMessage(Object messageContent) {
        String logMessage = EMPTY_LOG_MESSAGE;
        if (messageContent instanceof String && !String.isBlank((String) messageContent)) {
            logMessage = '' + messageContent;
        }

        // Check if we are logging an exception solely and just reuse that one as the stack.
        if (messageContent instanceof Exception) {
            LoggerStackTrace stack = new LoggerStackTrace((Exception) messageContent);
            logMessage += ' :: ' + stack.ParsedStackTraceString;
        }

        // Strip newlines and trim
        logMessage = logMessage.replace('\n', ' - ').trim();
        return logMessage;
    }

    /**
     * Given the logg level of the message to be logged, this method decides if the message is to be published or not based on the confirguration of the org
     * The method will authorize the log entry if the log level of the message is less detaild that the configuration of the org
     * @param logLevel log level of the message to be logged
     * @return  `Boolean` with the result of the comparison between log level of the message and the org configuration.
     */
    private static Boolean shouldPlatformEventLog(LoggingLevel logLevel) {
    return (platformEventLogLevel.ordinal() <= logLevel.ordinal() && platformEventLogLevel != LoggingLevel.NONE);
    }

    /**
     * 
     * @param o Util method to serialize an object into JSON and append a newline at the end
     * @return  `String`
     */
    public static String serializeNdJson(Object o) {
        if(o instanceOf String ){
            return o + '\n';
        }

        return JSON.serialize(o) + '\n';
    }

    /**
     * Auxiliar class. Used to keep a log in memory before publishing it on emit();
     * 
     * See static list Logger.logEntries
     */
    public class LogRecord {
        private LoggingLevel level; 
        private String messageContent;
        public String location;

        public void setLogLevel(LoggingLevel level){
            this.level = level;
        }

        public void setLogMessage(Object messageContent){
            this.messageContent = createLogMessage(messageContent);
        }

        public void setLocation(LoggerStackTrace trace){
            this.location = trace.Location;
        }
        
        private Debug_Event__e getDebugEvent(){
            Debug_Event__e event = new Debug_Event__e();
            // Its important to end the log lines with a newline char.
            String logLine = serializeNdJson(this.messageContent);
            event.Log_Lines__c = logLine;
            event.Log_Level__c = this.level.name();
            event.Log_Location__c = this.location;
            event.Trace_Id__c = traceId;
            event.Created_By_Name__c = UserInfo.getName();
            event.Salesforce_Request_Id__c = SALESFORCE_REQUEST_ID;
            event.Salesforce_Execution_Context__c = SALESFORCE_EXECUTION_CONTEXT.toString();

            return event;
        }
    }

    /**
     * Auxiliar class to enable logging from flows, containing the structure of data requirements to be introduced in the UI
     */
    public class LogEntry {
        @InvocableVariable
        public String level; 
        @InvocableVariable
        public String messageContent;
        @InvocableVariable
        public String errorCode;
    }
}