/**
 * Trigger handler for the Debug event platform event trigger
 * it is responsible for initiating the push of debug messages to all configured SIEM's
 * @log:
 *  -----------------------------------------------------------------------------
 *  Developer            Date            Description
 *  -----------------------------------------------------------------------------
 *  Sergio Pedro         18/03/2025      Initial version
 * 
 * @author Sergio Pedro
 * @date 18/03/2025
 */

public with sharing class DebugEventTriggerHandler extends TriggerHandler {
    /**
     * List of platform events triggered
     */
    private List<Debug_Event__e> newList = (List<Debug_Event__e>) Trigger.new;
    /**
     * List of configurations that will be fetched from custom metadata and trigger the integration
     */
    private List<ISIEMConnection> configuredConnections;


    /**
     * Implementation of the afterInsert for the trigger.
     * the method will initialize the connectors and trigger the invocation that will send information to SIEM's
     */
    protected override void afterInsert() {
        initializeConnectors();
        for (ISIEMConnection connector : configuredConnections) {
            for (Debug_Event__e logEntry : newList) {
                connector.appendLogLine(logEntry);
            }
            connector.invokeSIEM();
        }
    }

    /**
     * Method responsible for fetching the configuration from Salesforce about all the SIEM's configured and initialize the proper connector
     * Support at 18/03/2025 - only internal logging
     */
    private void initializeConnectors() {
        Map<String, Logger_Setting__mdt> connectedSIEM = Logger_Setting__mdt.getAll();
        configuredConnections = new List<ISIEMConnection>();
        
        for (String configName : connectedSIEM.keySet()) {
            configuredConnections.add(getConnection(connectedSIEM.get(configName)));
        }
    }

    /**
     * Connection factory responsible for returning the proper connector implementation to be used to send the necessary information to the SIEM's
     * @param configuration 
     * @return  `ISIEMConnection`
     */
    private ISIEMConnection getConnection(Logger_Setting__mdt configuration) {
        switch on configuration.SIEM__c {
            when 'ELK' {
                return new InternalSIEMConnection();
            }
            when 'DataDog' {
                return new DataDogSIEMConnection();
            }
            when 'Zabbix' {
                return new InternalSIEMConnection();
            }
            when else {
                return new InternalSIEMConnection();
            }
        }   
    }
}