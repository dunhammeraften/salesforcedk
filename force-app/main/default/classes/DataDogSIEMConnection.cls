/**
 * The InternalSIEMConnection class implements the ISIEMConnection interface
 * Class responsible fo rthe internal logging.
 * This implementation will be improved as we discover more details about the individual SIEM's
 * @log:
 *  -----------------------------------------------------------------------------
 *  Developer            Date            Description
 *  -----------------------------------------------------------------------------
 *  Sergio Pedro         30/04/2025      Initial version
 * 
 * @author Sergio Pedro
 * @date 18/03/2025
 */
public with sharing class DataDogSIEMConnection implements ISIEMConnection {

    /**
     * Constant with the name of the named credential for the Datadog API
     */
    private static final String NAMED_CREDENTIAL = 'callout:DatadogLogAPI';
    /**
     * Constant with the target endpoint of the Datadog API being used.
     */
    private static final String ENDPOINT_PATH = '/v1/input';

    /**
     * list of messages to send
     */
    @TestVisible
    private List<DatadogEvent> payloadsToSend;

    /**
     * Constructor without parameters
     */
    public DataDogSIEMConnection() {
        payloadsToSend = new List<DatadogEvent>();
    }

     /**
     * Method that creates the payload to be sent to the SIEM
     * @param logEntryToHandle  `Debug_Event__e` log entry to send to SIEM
     */
    public void appendLogLine(Debug_Event__e eventToLog){

        DatadogEvent datadogLine = new DatadogEvent(eventToLog.Log_Lines__c.abbreviate(50), 
                                                    eventToLog.Log_Lines__c, 
                                                    eventToLog.Salesforce_Execution_Context__c,
                                                    eventToLog.Trace_Id__c, 
                                                    eventToLog.Log_Level__c, 
                                                    eventToLog.Created_By_Name__c, 
                                                    eventToLog.CreatedById, 
                                                    eventToLog.CreatedDate);

        payloadsToSend.add(datadogLine);
    } 

    /**
     * Method that will invoke an API to push the message to the SIEM
     * This method exposes the orchestration of generating the payload and sending over the wire to be invoked from the trigger handler
     */
    public void invokeSIEM() {
        String jsonBody = constructPayload();

        sendPayload(jsonBody);
        return;
    }
    
    /**
     * Method that creates the payload to be sent to the SIEM based of the list of Datadog class instances 
     * @return String with the payload to be sent
     */
    private String constructPayload(){
		return JSON.serialize(payloadsToSend);
	} 

    /**
     * Method that makes the call to the endpoint of Datadog to post a log entry
     * @param payload request body that will be sent to Datadog
     */
    @future(callout=true)
    public static void sendPayload(String payload){
        Http http = new Http();
        HttpRequest req = new HttpRequest();

        req.setEndpoint(NAMED_CREDENTIAL + ENDPOINT_PATH);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('DD-API-KEY', Logger_Setting__mdt.getInstance(Logger.LOG_SETTINGS_NAME).SIEM_Service_Key__c);
        req.setBody(payload);

        try {
            HttpResponse res = http.send(req);
            System.debug('Datadog Event Response: ' + res.getBody());
        } catch (Exception e) {
            System.debug('Error sending event to Datadog: ' + e.getMessage());
        }
    }

	

    /**
     * Class representing the log entry in the Datadog SIEM
     * Notice that the property names are non compliant with Norlys Salesforce programing naming conventions 
     * but are aligned with Datadog API specifications
     * @see https://docs.datadoghq.com/api/?lang=python#events
     */
    public class DatadogEvent {
        public String title;
        public String message;
        public String trace_id;
        public String ddsource;
        public String host;
        public String ddindex;
        public String service;
        public String status;
        public Datetime date_happened;
        public Map<String, Object> tags;

        public DatadogEvent(String title, String text, String service, String aggregationKey, String logLevel, String userName, String userId, Datetime createdDate) {
            this.title = title;
            this.message = text;
            this.trace_id = aggregationKey;
            this.ddindex = MetadataSelector.getLoggerSettings(Logger.LOG_SETTINGS_NAME).Log_Bucket__c;
            this.ddsource = 'salesforce';
            this.host = System.URL.getOrgDomainUrl().toExternalForm();
            this.service = service;
            this.status = logLevel == LoggingLevel.ERROR.toString() ? 'Error' : (logLevel == LoggingLevel.WARN.toString() ? 'Warn' :(logLevel == LoggingLevel.DEBUG.toString() ? 'Debug' : 'Info'));
            this.date_happened = createdDate;
            this.tags = new Map<String, Object>{
                'sfLogLevel' => logLevel,
                'userId' =>  userName + '(' + userId + ')'
            };
        }
    }
}