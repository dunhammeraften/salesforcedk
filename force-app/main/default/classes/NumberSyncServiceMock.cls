/**
 * The NumberSyncServiceMock class is a mock class for the NumberSyncService.
 * It is used for testing purposes to prevent callouts to the Number API.
 *  -----------------------------------------------------------------------------
 *  Developer            Date            Description
 *  -----------------------------------------------------------------------------
 *  Kenneth Houkjær         27/07/2025      Initial version
 *
 * @author Kenneth Houkjær
 * @date 27/07/2025
 */
@isTest
global class NumberSyncServiceMock extends NumberSyncService {
    /**
     * @description This method overrides the synchronizeAssignmentsForAccount method in the NumberSyncService class.
     * It does nothing, which prevents callouts to the Number API during testing.
     * @param acc The account to synchronize assignments for.
     */
    global override void synchronizeAssignmentsForAccount(Account acc) {
        // Do nothing
    }
}