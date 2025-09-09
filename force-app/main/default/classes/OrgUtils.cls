/**
 * The OrgUtils class is responsible providing org wide utility methods that enable multiple classes to operate
 * @log:
 *  -----------------------------------------------------------------------------
 *  Developer            Date            Description
 *  -----------------------------------------------------------------------------
 *  Sergio Pedro         18/03/2025      Initial version
 * 
 * @author Sergio Pedro
 * @date 18/03/2025
 */
public without sharing class OrgUtils {
    @TestVisible
    static final private String COMPANY_SF_SYSTEM_USER_DEVELOPERNAME = 'CompanySFSystemUser';
    @TestVisible
    static final private Cache.OrgPartition orgConfig = Cache.Org.getPartition('NorlysConfiguration');
    
    /**
     * Method that will return the indication of the org being a sandbox or an production org
     * @return `Boolean` result of the assessment of the type of org
     */
    public static Boolean isSandbox() {
        return [SELECT IsSandbox, Id FROM Organization LIMIT 1].IsSandbox;
    }
    
    /**
     * MEthod that generates a GUID to be used in integrations
     * @return  `String` String with the Guid generated
     */
    public static String generateGUID() {
        String guid = UUID.randomUUID().toString();
        
        return guid;
    }

    /**
     * Get the username for the Company SF System User held in Company Setttings mdt,
     * before returning it we check if we need to append the sandbox name to it. Sandbox name is appended, if we
     * are running in a sandbox.
     * @return String username of Company SF System User name held in custom metadata
     */
	public static String getUsernameForCompanySFSystemUser() {
        String username = getCompanySettingsConfigurationValueByDeveloperName(COMPANY_SF_SYSTEM_USER_DEVELOPERNAME);

        // we need to determine if the org is sandbox 
        String sandboxName = DomainParser.parse(DomainCreator.getOrgMyDomainHostname()).getSandboxName();
        if (!String.isEmpty(sandboxName)) {
            username += '.' + sandboxName;
        }
        return username;
	}

    /**
     * Get the Configuration_Value__c from the Company_Settings__mdt that matches the developerName
     * @param developerName Developer name of the Company_Settings__mdt record
     * @return configuration value matching the developer name passed in
     */
	public static String getCompanySettingsConfigurationValueByDeveloperName(String developerName) {
        if(!developerName.isAlphanumeric()) {
            Logger.logError('Configuration names must be alpha-numeric only');
        }

        if(orgConfig.contains(developerName)) {
            Logger.logInfo('Configuration value found in cache');
            return (String)orgConfig.get(developerName);
        }

        Company_Settings__mdt companySettingsRecord = Company_Settings__mdt.getInstance(developerName);
        String configurationValue = '';
        if (companySettingsRecord != null) {
            configurationValue = companySettingsRecord.Configuration_Value__c;
            orgConfig.put(developerName, configurationValue);
            Logger.logInfo('Configuration value found in custom metadata and added to cache');
        } else {
            Logger.logWarning('No record found for developerName: ' + developerName);
        }
        return configurationValue;
	}


    /**
     * Clears the organization configuration cache.
     * This method is used to reset the cached configuration values stored in the `orgConfig` cache.
     */
    public static void clearOrgConfigurationCache() {
        Set<String> keysInCache = orgConfig.getKeys();
        for (String key : keysInCache) {
            orgConfig.remove(key);
        }
    }

    /**
     * @description This method chunks a list of objects into a list of lists of objects.
     * @param chunkSize The size of each chunk.
     * @param listToChunk The list to be chunked.
     * @return A list of lists of objects.
     */
    public static List<List<Object>> chunkList(Integer chunkSize,  List<Object> listToChunk){
        List<List<Object>> chunkedLists = new List<List<Object>>();
        
        if (!listToChunk.isEmpty()) {
            chunkedLists.add(new List<Object>());
            Integer partition = 0;
            for (Object obj : listToChunk) {
              if (chunkedLists[partition].size() == chunkSize) {
                partition++;
                chunkedLists.add(new List<Object>());
              }
              chunkedLists[partition].add(obj);
            }
        }
        
        return chunkedLists;
    }

     /**
     * Chunks a list of objects into a list of lists of objects with a specified size.
     * @param chunkSize The size of each chunk.
     * @param listToChunk The list to be chunked.
     * @param destType The type of the destination list.
     * @return A list of lists of objects, where each inner list has a maximum size of chunkSize.
     */
    public static List<List<Object>> chunkListOfStrings(Integer chunkSize,  List<Object> listToChunk, Type destType){
        List<List<Object>> chunkedLists = (List<List<Object>>) destType.newInstance();

        List<Object> bluePrintList = listToChunk.clone();
        bluePrintList.clear();
        chunkedLists.add(bluePrintList.clone());

        Integer partition = 0;
        for (Object obj : listToChunk) {
          // Create a new partition when we fill one up
          if (chunkedLists[partition].size() == chunkSize) {
            partition++;
            chunkedLists.add(bluePrintList.clone());
          }
          // Add object to current partition
          chunkedLists[partition].add(obj);
        }
        
        return chunkedLists;
	}
}