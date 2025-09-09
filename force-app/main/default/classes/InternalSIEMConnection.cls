/**
 * The InternalSIEMConnection class implements the ISIEMConnection interface
 * Class responsible fo rthe internal logging.
 * This implementation will be improved as we discover more details about the individual SIEM's
 * @log:
 *  -----------------------------------------------------------------------------
 *  Developer            Date            Description
 *  -----------------------------------------------------------------------------
 *  Sergio Pedro         18/03/2025      Initial version
 * 
 * @author Sergio Pedro
 * @date 18/03/2025
 */
public with sharing class InternalSIEMConnection implements ISIEMConnection {

    /**
     * list of messages to send
     */
    private static List<String> payloadsToSend = new List<String>();

    /**
     * Constructor without parameters
     */
    public InternalSIEMConnection() {
    }

    /**
     * Method that creates the payload to be sent to the SIEM
     * @param logEntryToHandle  `Debug_Event__e` log entry to send to SIEM
     */
    public void appendLogLine(Debug_Event__e logEntryToHandle) {
        String payload = '';

        payloadsToSend.add(payload);
    }

    /**
     * Method that will invoke an API to push the message to the SIEM
     */
    public void invokeSIEM() {
        
        return;
    }
}