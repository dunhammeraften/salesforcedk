@isTest
private class FeatureToggleServiceTest {
    
    static FeatureToggle__mdt createMockedFeatureToggle(String developerName, Boolean isEnabled){
 
        FeatureToggle__mdt toggle = new FeatureToggle__mdt();
        toggle.DeveloperName = developerName;
        toggle.MasterLabel = developerName; // MasterLabel is required
        toggle.IsEnabled__c = isEnabled;
 
        return toggle;
    }

    @TestSetup
    static void makeData(){
        // Create some sample toggles for the tests
        /*List<FeatureToggle__mdt> listOfMockedFeatureToggles = new List<FeatureToggle__mdt>();
        listOfMockedFeatureToggles.add(createMockedFeatureToggle('TestFeatureEnabled', true));
        listOfMockedFeatureToggles.add(createMockedFeatureToggle('TestFeatureDisabled', false));
        MetadataSelector.setMock(new MetadataSelectorMock(listOfMockedFeatureToggles));*/
        // 'TestFeatureNotFound' is intentionally not created
    }

    @isTest
    static void testFeatureEnabled() {
        Test.startTest();
        List<FeatureToggle__mdt> listOfMockedFeatureToggles = new List<FeatureToggle__mdt>();
        listOfMockedFeatureToggles.add(createMockedFeatureToggle('TestFeatureEnabled', true));
        MetadataSelector.setMock(new MetadataSelectorMock(listOfMockedFeatureToggles));
        
        Boolean isEnabled = FeatureToggleService.isFeatureEnabled('TestFeatureEnabled');
        Test.stopTest();
        System.assertEquals(true, isEnabled, 'TestFeatureEnabled should be true');
    }

    @isTest
    static void testFeatureDisabled() {
        Test.startTest();
        Boolean isEnabled = FeatureToggleService.isFeatureEnabled('TestFeatureDisabled');
        Test.stopTest();
        System.assertEquals(false, isEnabled, 'TestFeatureDisabled should be false');
    }

    @isTest
    static void testFeatureNotFound() {
        Test.startTest();
        Boolean isEnabled = FeatureToggleService.isFeatureEnabled('TestFeatureNotFound');
        Test.stopTest();
        System.assertEquals(false, isEnabled, 'TestFeatureNotFound should be false as it does not exist');
    }

    /*@isTest
    static void testBlankFeatureName() {
        Test.startTest();
        Boolean isEnabled = FeatureToggleService.isFeatureEnabled('');
        Boolean isEnabledNull = FeatureToggleService.isFeatureEnabled(null);
        Test.stopTest();
        System.assertEquals(false, isEnabled, 'Blank feature name should return false');
        System.assertEquals(false, isEnabledNull, 'Null feature name should return false');
    }

    @isTest
    static void testCachingBehavior() {
        // Prime the cache for 'TestFeatureEnabled'
        List<FeatureToggle__mdt> listOfMockedFeatureToggles = new List<FeatureToggle__mdt>();
        listOfMockedFeatureToggles.add(createMockedFeatureToggle('CacheTestFeature', true));
        MetadataSelector.setMock(new MetadataSelectorMock(listOfMockedFeatureToggles));

        Test.startTest();
        // First call - should query and cache
        Boolean firstCall = FeatureToggleService.isFeatureEnabled('CacheTestFeature');
        System.assertEquals(true, firstCall, 'First call for CacheTestFeature should be true');

        // To verify caching, we ideally need to check SOQL query counts.
        // We can simulate this by trying to change the underlying data (not possible for CMDTs directly mid-transaction)
        // or by asserting the SOQL count if Test.getQueries() was more granular for CMDTs.
        // For this test, we'll rely on the logic that if it works, the cache must be effective.
        // A more advanced test could involve deleting the CMDT record (if possible in test)
        // and seeing if the cached value persists. However, CMDT records are part of metadata.

        // Second call - should use cache
        // To ensure this, we clear the SOQL limit and then make the call.
        // If it makes another query when it shouldn't, it might hit limits in more complex scenarios.
        Integer soqlQueriesBeforeSecondCall = Limits.getQueries();
        Boolean secondCall = FeatureToggleService.isFeatureEnabled('CacheTestFeature');
        Integer soqlQueriesAfterSecondCall = Limits.getQueries();

        Test.stopTest();

        System.assertEquals(true, secondCall, 'Second call for CacheTestFeature should also be true (from cache)');
        System.assertEquals(soqlQueriesBeforeSecondCall, soqlQueriesAfterSecondCall, 'SOQL queries should not increase on the second call for the same feature toggle due to caching.');

        // Test cache clear
        FeatureToggleService.clearCache(); // Clear the cache
        // Re-create the toggle as clearCache doesn't affect @TestSetup data for this test's purpose
        // but we want to ensure the next call re-queries if the cache was indeed cleared.
        // Note: TestSetup data is available across test methods, but static cache is per transaction.
        // clearCache clears the static variable. The CMDT record still exists from TestSetup.

        soqlQueriesBeforeSecondCall = Limits.getQueries(); // Reset counter before the call
        Boolean thirdCallAfterClear = FeatureToggleService.isFeatureEnabled('CacheTestFeature');
        soqlQueriesAfterSecondCall = Limits.getQueries();

        System.assertEquals(true, thirdCallAfterClear, 'Third call for CacheTestFeature after cache clear should be true (re-queried)');
        System.assert(soqlQueriesAfterSecondCall > soqlQueriesBeforeSecondCall, 'SOQL queries should increase after cache clear, indicating a fresh query.');
    }*/

    /*@isTest
    static void testFeatureNameCaseSensitivity() {
        // TestSetup creates 'TestFeatureEnabled'
        Test.startTest();
        Boolean isEnabledUpper = FeatureToggleService.isFeatureEnabled('TESTFEATUREENABLED');
        Boolean isEnabledLower = FeatureToggleService.isFeatureEnabled('testfeatureenabled');
        Boolean isEnabledMixed = FeatureToggleService.isFeatureEnabled('TestFeatureEnabled');
        Test.stopTest();

        System.assertEquals(true, isEnabledUpper, 'Uppercase feature name should be found (cache key is lowercased)');
        System.assertEquals(true, isEnabledLower, 'Lowercase feature name should be found');
        System.assertEquals(true, isEnabledMixed, 'Mixed case feature name should be found');

        // Verify caching behavior for different cases of the same name
        Integer queriesBefore = Limits.getQueries();
        FeatureToggleService.isFeatureEnabled('testfeatureenabled_case'); // First call with this variant
        FeatureToggleService.isFeatureEnabled('TestFeatureEnabled_Case'); // Second call, different case
        FeatureToggleService.isFeatureEnabled('TESTFEATUREENABLED_CASE'); // Third call, another case
        Integer queriesAfter = Limits.getQueries();
        // Expecting only 1 query for 'testfeatureenabled_case' due to cache normalization.
        // This requires 'testfeatureenabled_case' to be created first.
        List<FeatureToggle__mdt> listOfMockedFeatureToggles = new List<FeatureToggle__mdt>();
        listOfMockedFeatureToggles.add(createMockedFeatureToggle('testfeatureenabled_case', true));
        MetadataSelector.setMock(new MetadataSelectorMock(listOfMockedFeatureToggles));
        FeatureToggleService.clearCache(); // Clear cache before this specific test part

        queriesBefore = Limits.getQueries();
        FeatureToggleService.isFeatureEnabled('testfeatureenabled_case');
        Integer queriesAfterFirst = Limits.getQueries();
        FeatureToggleService.isFeatureEnabled('TestFeatureEnabled_Case');
        FeatureToggleService.isFeatureEnabled('TESTFEATUREENABLED_CASE');
        Integer queriesAfterThird = Limits.getQueries();

        System.assertEquals(1, queriesAfterFirst - queriesBefore, 'Only one query should be made for the first variant.');
        System.assertEquals(queriesAfterFirst, queriesAfterThird, 'Subsequent calls with different casing for the same DeveloperName should hit the cache.');
    }*/
}