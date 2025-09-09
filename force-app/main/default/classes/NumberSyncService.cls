/**
 * The NumberSyncService is responsible for synchronizing Fokus phone numbers with Salesforce.
 *  -----------------------------------------------------------------------------
 *  Developer            Date            Description
 *  -----------------------------------------------------------------------------
 *  Kenneth Houkjær         27/07/2025      Initial version
 *
 * @author Kenneth Houkjær
 * @date 27/07/2025
 */
public virtual class NumberSyncService {

    private NumberClient numberClient;
 
    /**
     * @description Default constructor that initializes the NumberClient using the SingletonFactory.
     */
    public NumberSyncService() {
        this(SingletonFactory.getFactory());
    }

    /**
     * @description Private constructor for dependency injection.
     * @param singletonFactory The SingletonFactory instance to use for creating dependencies.
     */
	private NumberSyncService(SingletonFactory singletonFactory) {
		this.numberClient = (NumberClient) singletonFactory.getOrRegisterSingleton(
			NumberClient.class
		);
	}

    /**
     * @description Test-visible constructor for dependency injection during testing.
     * @param mockNumberClient The mock NumberClient instance to use.
     */
    @TestVisible
    private NumberSyncService(NumberClient mockNumberClient) {
        this.numberClient = mockNumberClient;
    }

    /**
     * @description Inner class to hold remote assignment data along with its parent Series Id.
     */
    public class RemoteAssignmentWrapper {
        @TestVisible public NumberClientResponseDTO.NumberData numberData;
        @TestVisible public Id parentSeriesId;

        /**
         * @description Constructor for the RemoteAssignmentWrapper class.
         * @param data The NumberClientResponseDTO.NumberData object.
         * @param seriesId The ID of the parent series.
         */
        public RemoteAssignmentWrapper(NumberClientResponseDTO.NumberData data, Id seriesId) {
            this.numberData = data;
            this.parentSeriesId = seriesId;
        }
    }

    /**
     * @description Wrapper method for the static call to make it mockable in tests.
     * @param params The parameters for the getNumberDetails call.
     * @return The response from the getNumberDetails call.
     */
    @TestVisible
    protected virtual NumberClientResponseDTO.NumberDetails callGetNumberDetails(NumberClientRequestDTO.NumberDetails params) {
        try{
            return numberClient.getNumberDetails(params);
        }
        catch(Exception e){
            Logger.logError(e);
        }

        return null;
    }

    /**
     * @description Method to get Account Phone Number Series records. Made virtual for potential test mocking.
     * @param acc The account to get the phone number series for.
     * @return A list of Account_Phone_Number_Series__c records.
     */
    @TestVisible
    protected virtual List<Account_Phone_Number_Series__c> getAllAccountPhoneNumberSeries(Account acc) {
       return AccountPhoneNumberSeriesSelector.getAllAccountPhoneNumberSeries(acc);
    }

    /**
     * @description Method to get OpenPhoneNumberSeries metadata. Made virtual for potential test mocking.
     * @return A list of OpenPhoneNumberSeries__mdt records.
     */
    @TestVisible
    protected virtual List<OpenPhoneNumberSeries__mdt> getOpenPhoneNumberSeriesMetadata() {
        return MetadataSelector.getOpenPhoneNumberSeries();
    }

    /**
     * @description Synchronizes assignments for a given account.
     * @param acc The account to synchronize assignments for.
     */
    public virtual void synchronizeAssignmentsForAccount(Account acc) {
        Map<String, Account_Phone_Number_Assignment__c> localAssignments = getLocalAssignments(acc);
        Map<String, RemoteAssignmentWrapper> remoteAssignments = getRemoteAssignments(acc); // Changed return type
        compareAndPrepareDML(localAssignments, remoteAssignments, acc); // Argument type changed
        
        Logger.emit();
    }
    
     /**
      * @description Synchronizes assignments for all accounts.
      */
    public void synchronizeAllAssignments() {
        Map<String, Account_Phone_Number_Assignment__c> localAssignments = getLocalAssignments(null);
        Map<String, RemoteAssignmentWrapper> remoteAssignments = getRemoteAssignments(null); // Changed return type
        compareAndPrepareDML(localAssignments, remoteAssignments, null); // Argument type changed
        
        Logger.emit();
    }

    /**
     * @description Gets the local assignments for a given account.
     * @param acc The account to get the local assignments for.
     * @return A map of local assignments, keyed by phone number.
     */
    private Map<String, Account_Phone_Number_Assignment__c> getLocalAssignments(Account acc) {
        List<Account_Phone_Number_Assignment__c> listOfAccountPhoneNumberAssignments = AccountPhoneNumberAssignmentSelector.getAssignments(acc);
        
        Map<String, Account_Phone_Number_Assignment__c> localAssignmentsMap = new Map<String, Account_Phone_Number_Assignment__c>();

        for (Account_Phone_Number_Assignment__c assignment : listOfAccountPhoneNumberAssignments) {
            if (String.isNotBlank(assignment.Phone_Number__c)) {
                localAssignmentsMap.put(assignment.Phone_Number__c.toLowerCase(), assignment); // Key by lowercase phone number for case-insensitivity
            }
        }
        return localAssignmentsMap;
    }

    /**
     * @description Gets the remote assignments for a given account.
     * @param acc The account to get the remote assignments for.
     * @return A map of remote assignments, keyed by phone number.
     */
    private Map<String, RemoteAssignmentWrapper> getRemoteAssignments(Account acc) {
        Map<String, RemoteAssignmentWrapper> remoteAssignmentsMap = new Map<String, RemoteAssignmentWrapper>();

        // 1. Get all Account Phone Number Series
        List<Account_Phone_Number_Series__c> allSeriesRecords = getAllAccountPhoneNumberSeries(acc);
        if (allSeriesRecords.isEmpty()) {
            Logger.logInfo('No Account_Phone_Number_Series__c records found. No remote assignments to fetch.');
            return remoteAssignmentsMap;
        }

        // 2. Get OpenPhoneNumberSeries metadata
        Set<String> openSeriesKeys = new Set<String>();
        for (OpenPhoneNumberSeries__mdt opsMeta : getOpenPhoneNumberSeriesMetadata()) {
            // Create a unique key for comparison, e.g., "P_EKC"
             if (String.isNotBlank(opsMeta.number_group__c) && String.isNotBlank(opsMeta.number_location__c)) {
                openSeriesKeys.add(opsMeta.number_group__c.toUpperCase() + '_' + opsMeta.number_location__c.toUpperCase());
            }
        }
        Logger.logInfo('Open Series Keys from CMD: ' + openSeriesKeys);

        List<String> defaultStatuses = new List<String>{
            SFConstants.ASSIGNED_AVAILABLE,
            SFConstants.ASSIGNED_RESERVED,
            SFConstants.ASSIGNED_INUSE,
            SFConstants.ASSIGNED_SUSPENDED};

        List<String> openSeriesStatuses = new List<String>{SFConstants.ASSIGNED_RESERVED};

        // 3. Iterate through each Account_Phone_Number_Series__c record
        for (Account_Phone_Number_Series__c seriesRecord : allSeriesRecords) {
            String currentSeriesKey = '';
            if (String.isNotBlank(seriesRecord.Number_Group__c) && String.isNotBlank(seriesRecord.Number_Location__c)) {
                currentSeriesKey = seriesRecord.Number_Group__c.toUpperCase() + '_' + seriesRecord.Number_Location__c.toUpperCase();
            }

            boolean isSeriesOpen = openSeriesKeys.contains(currentSeriesKey);
            List<String> statusesToQuery = isSeriesOpen ? openSeriesStatuses : defaultStatuses;

            Logger.logInfo('Processing Series: ' + seriesRecord.Name +
                         ', Group: ' + seriesRecord.Number_Group__c +
                         ', Location: ' + seriesRecord.Number_Location__c +
                         ', IsOpen: ' + isSeriesOpen +
                         ', Statuses: ' + statusesToQuery);

            for (String status : statusesToQuery) {
                NumberClientRequestDTO.NumberDetails params = new NumberClientRequestDTO.NumberDetails();
                params.numberGroup = seriesRecord.Number_Group__c;
                params.numberLocation = seriesRecord.Number_Location__c;
                params.cvr = seriesRecord.account__r.CVR__c;
                logger.logInfo('seriesRecord.CVR__c in params is ' + seriesRecord.account__r.CVR__c);
                params.numberPattern = seriesRecord.Number_Pattern__c;

                params.numberStatus = status;
                
                Logger.logInfo('Calling getNumberDetails with ' +  params);
                NumberClientResponseDTO.NumberDetails details = callGetNumberDetails(params);
                Logger.logInfo('getNumberDetails returned ' + details);

                if (details != null && details.data != null) {
                    for (NumberClientResponseDTO.NumberData numberData : details.data) {
                        if (String.isNotBlank(numberData.Id)) {
                            // Key by lowercase phone number for case-insensitivity
                            remoteAssignmentsMap.put(
                                numberData.Id.toLowerCase(),
                                new RemoteAssignmentWrapper(numberData, seriesRecord.Id)
                            );

                            Logger.logInfo('Adding remote assignment ' + numberData.Id + ' to map');
                            Logger.logInfo('seriesRecord.Id = ' + seriesRecord.Id);
                            Logger.logInfo('numberData ' + numberData);
                        }
                    }
                } else if (details != null && details.error != null) {
                    Logger.logInfo('Error fetching remote numbers for Series Name ' + seriesRecord.Name +
                                 ' (Group: ' + seriesRecord.Number_Group__c +
                                 ', Location: ' + seriesRecord.Number_Location__c +
                                 ') with status ' + status + ': ' + details.error.message);
                }
            }
        }
        return remoteAssignmentsMap;
    }

    /**
     * @description Compares the local and remote assignments and prepares the DML operations.
     * @param localAssignments A map of local assignments, keyed by phone number.
     * @param remoteAssignments A map of remote assignments, keyed by phone number.
     */
    private void compareAndPrepareDML(
        Map<String, Account_Phone_Number_Assignment__c> localAssignments,
        Map<String, RemoteAssignmentWrapper> remoteAssignments,
        Account acc
    ) {
        List<Account_Phone_Number_Assignment__c> toCreate = new List<Account_Phone_Number_Assignment__c>();
        List<Account_Phone_Number_Assignment__c> toUpdate = new List<Account_Phone_Number_Assignment__c>();
        List<Account_Phone_Number_Assignment__c> toDelete = new List<Account_Phone_Number_Assignment__c>();

        // Iterate through remote assignments to find new or changed records
        for (String remoteKey : remoteAssignments.keySet()) { // remoteKey is already lowercased
            RemoteAssignmentWrapper wrapper = remoteAssignments.get(remoteKey);
            NumberClientResponseDTO.NumberData remoteData = wrapper.numberData;
            Id parentSeriesIdForRemote = wrapper.parentSeriesId;

            Account_Phone_Number_Assignment__c localRecord = localAssignments.get(remoteKey);

            if (localRecord == null) {
                // New record: create it
                Account_Phone_Number_Assignment__c newAssignment = new Account_Phone_Number_Assignment__c();

                newAssignment.Phone_Number__c = remoteData.phoneNumber; // Store with original casing
                newAssignment.CTN_Number_Status__c = remoteData.numberStatus;
                newAssignment.Account_Phone_Number_Series__c = parentSeriesIdForRemote; // Set Master-Detail relationship

                if(acc != null) {
                    newAssignment.Account__c = acc.Id;
                }
                // TODO: Map other fields from remoteData to newAssignment if necessary
                // e.g., newAssignment.Phone_Number_user__c = remoteData.someUserField;
                // e.g., newAssignment.Account__c = determineAccountIdLogic();
                // For now, only core fields are mapped.

                toCreate.add(newAssignment);
                Logger.logInfo('To Create: Id/Phone=' + remoteData.Id + ', Status=' + remoteData.numberStatus + ', SeriesId=' + parentSeriesIdForRemote);

            } else {
                // Existing record: check for changes
                boolean changed = false;

                // Compare CTN_Number_Status__c
                if (localRecord.CTN_Number_Status__c != remoteData.numberStatus) {
                    localRecord.CTN_Number_Status__c = remoteData.numberStatus;
                    changed = true;
                }

                // TODO: Compare other relevant fields from remoteData and update localRecord if changed.
                // Example:
                // if (localRecord.Phone_Number_user__c != remoteData.someUserField) {
                //    localRecord.Phone_Number_user__c = remoteData.someUserField;
                //    changed = true;
                // }

                // Note: The parentSeriesId (Account_Phone_Number_Series__c) for an existing localRecord
                // is generally not expected to change based on remote data for the *same phone number*.
                // If a phone number were to move series, it might appear as a delete from old series
                // and an add to new series, depending on how NumberService reports it.
                // We are not updating localRecord.Account_Phone_Number_Series__c here.

                if (changed) {
                    toUpdate.add(localRecord);
                    Logger.logInfo('To Update: Id/Phone=' + localRecord.Phone_Number__c + ', NewStatus=' + localRecord.CTN_Number_Status__c);
                }
            }
        }

        // Iterate through local assignments to find records for deletion
        for (String localKey : localAssignments.keySet()) { // localKey is lowercased Phone_Number__c
            if (!remoteAssignments.containsKey(localKey)) {
                Account_Phone_Number_Assignment__c assignmentToDelete = localAssignments.get(localKey);
                
                //we should not delete the local assignment if for some reason the number is assigned to a user via e.g., an 
                //activation line, we should instead throw an error and then figure out why this has been done   
                if(!String.isBlank(assignmentToDelete.Phone_Number_user__c)){
                    Logger.logError('NumberSyncService', 'The local phonenumber assignement ' + assignmentToDelete.Phone_Number__c +
                    ' is assigned to user ' + assignmentToDelete.Phone_Number_user__c + ' but is not registered in Fokus.');
                }
                else {
                    toDelete.add(assignmentToDelete);
                    Logger.logInfo('To Delete: Id/Phone=' + assignmentToDelete.Phone_Number__c + ', Id=' + assignmentToDelete.Id);
                }
            }
        }

        executeDMLOperations(toCreate, toUpdate, toDelete);
    }

    /**
     * @description Executes the DML operations.
     * @param toCreate A list of records to create.
     * @param toUpdate A list of records to update.
     * @param toDelete A list of records to delete.
     */
    private void executeDMLOperations(
        List<Account_Phone_Number_Assignment__c> toCreate,
        List<Account_Phone_Number_Assignment__c> toUpdate,
        List<Account_Phone_Number_Assignment__c> toDelete
    ) {
        // Placeholder for DML execution
        try {
            if (!toCreate.isEmpty()) {
                // TODO: Before insert, ensure required fields are populated or handle defaults
                DatabaseService dbs = new DatabaseService();
                dbs.insertRecords(toCreate);
                Logger.logInfo('Created ' + toCreate.size() + ' new assignments.');
            }
            if (!toUpdate.isEmpty()) {
                DatabaseService dbs = new DatabaseService();
                dbs.updateRecords(toUpdate);
                Logger.logInfo('Updated ' + toUpdate.size() + ' existing assignments.');
            }
            if (!toDelete.isEmpty()) {
                DatabaseService dbs = new DatabaseService();
                dbs.deleteRecords(toDelete);

                Logger.logInfo('Deleted ' + toDelete.size() + ' assignments.');
            }
        } catch (DmlException e) {
            // TODO: Implement robust error handling for DML failures
            system.debug('kk ' +  'DML Error: ' + e.getMessage());
            Logger.logError('NumberSyncService', 'DML Error: ' + e.getMessage());
        }
    }
}