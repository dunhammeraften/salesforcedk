/**
 * The ISIEMConnection interface has all the generic method declarations that the trigger handler will use to send debug logs to the configured SIEM's
 * Implementations will differ as the API's will be different per SIEM
 * @log:
 *  -----------------------------------------------------------------------------
 *  Developer            Date            Description
 *  -----------------------------------------------------------------------------
 *  Sergio Pedro         18/03/2025      Initial version
 * 
 * @author Sergio Pedro
 * @date 18/03/2025
 */
public interface ISIEMConnection {
    void appendLogLine(Debug_Event__e logEntryToHandle);
    void invokeSIEM();
}