@isTest
private class FeatureToggleExampleUsageTests {

    static FeatureToggle__mdt createMockedFeatureToggle(String developerName, Boolean isEnabled){
 
        FeatureToggle__mdt toggle = new FeatureToggle__mdt();
        toggle.DeveloperName = developerName;
        toggle.MasterLabel = developerName; // MasterLabel is required
        toggle.IsEnabled__c = isEnabled;
 
        return toggle;
    }
    
    @isTest
    static void testGetFeatureBehavior_WhenFeatureIsEnabled() {
        // Setup: Enable the feature toggle for this test
        List<FeatureToggle__mdt> listOfMockedFeatureToggles = new List<FeatureToggle__mdt>();
        listOfMockedFeatureToggles.add(createMockedFeatureToggle(FeatureToggleExampleUsage.NEW_FEATURE_TOGGLE_NAME, true));
        MetadataSelector.setMock(new MetadataSelectorMock(listOfMockedFeatureToggles));

        FeatureToggleService.clearCache(); // Clear cache to ensure fresh read for this test method

        FeatureToggleExampleUsage example = new FeatureToggleExampleUsage();
        Test.startTest();
        String behavior = example.getFeatureBehavior();
        Test.stopTest();

        System.assertEquals('New Behavior Enabled', behavior, 'Behavior should be new when toggle is ON');
    }

    @isTest
    static void testGetFeatureBehavior_WhenFeatureIsDisabled() {
        // Setup: Disable the feature toggle for this test (or ensure it's not present/false)
        List<FeatureToggle__mdt> listOfMockedFeatureToggles = new List<FeatureToggle__mdt>();
        listOfMockedFeatureToggles.add(createMockedFeatureToggle(FeatureToggleExampleUsage.NEW_FEATURE_TOGGLE_NAME, false));
        MetadataSelector.setMock(new MetadataSelectorMock(listOfMockedFeatureToggles));
        FeatureToggleService.clearCache(); // Clear cache

        FeatureToggleExampleUsage example = new FeatureToggleExampleUsage();
        Test.startTest();
        String behavior = example.getFeatureBehavior();
        Test.stopTest();

        System.assertEquals('Old Behavior', behavior, 'Behavior should be old when toggle is OFF');
    }

    @isTest
    static void testGetFeatureBehavior_WhenFeatureToggleDoesNotExist() {
        // Setup: Ensure the toggle does not exist or is not true.
        // No need to create a toggle, or ensure it's not the one we're looking for.
        // FeatureToggleService.isFeatureEnabled will return false.
        FeatureToggleService.clearCache(); // Clear cache

        FeatureToggleExampleUsage example = new FeatureToggleExampleUsage();
        Test.startTest();
        String behavior = example.getFeatureBehavior();
        Test.stopTest();

        System.assertEquals('Old Behavior', behavior, 'Behavior should be old when toggle does not exist');
    }

    @isTest
    static void testPerformComplexCalculation_V2Enabled() {
        List<FeatureToggle__mdt> listOfMockedFeatureToggles = new List<FeatureToggle__mdt>();
        listOfMockedFeatureToggles.add(createMockedFeatureToggle('ComplexMathV2Enabled', true));
        MetadataSelector.setMock(new MetadataSelectorMock(listOfMockedFeatureToggles));
        FeatureToggleService.clearCache();

        FeatureToggleExampleUsage example = new FeatureToggleExampleUsage();
        Test.startTest();
        Integer result = example.performComplexCalculation(5);
        Test.stopTest();

        System.assertEquals(50, result, 'Should use V2 calculation: 5*5*2 = 50');
    }

    @isTest
    static void testPerformComplexCalculation_V2Disabled() {
        List<FeatureToggle__mdt> listOfMockedFeatureToggles = new List<FeatureToggle__mdt>();
        listOfMockedFeatureToggles.add(createMockedFeatureToggle('ComplexMathV2Enabled', false));
        MetadataSelector.setMock(new MetadataSelectorMock(listOfMockedFeatureToggles));
        FeatureToggleService.clearCache();

        FeatureToggleExampleUsage example = new FeatureToggleExampleUsage();
        Test.startTest();
        Integer result = example.performComplexCalculation(5);
        Test.stopTest();

        System.assertEquals(25, result, 'Should use V1 calculation: 5*5 = 25');
    }
}