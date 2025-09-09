public with sharing class FeatureToggleExampleUsage {

    public static final String NEW_FEATURE_TOGGLE_NAME = 'NewExampleFeature';

    public String getFeatureBehavior() {
        if (FeatureToggles.NewExampleFeature) { 
            return 'New Behavior Enabled';
        } else {
            return 'Old Behavior';
        }
    }

    public Integer performComplexCalculation(Integer input) {
        if (FeatureToggles.ComplexMathV2Enabled) { 
            return input * input * 2; // New version
        } else {
            // Old, simpler calculation
            return input * input; // Old version
        }
    }
}