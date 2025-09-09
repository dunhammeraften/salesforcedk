/**
 * @description A class for creating and running test suites.
 */
public class NorlysSUnitSuite {

    private Set<String> classNames;

    /**
     * @description Constructor for NorlysSUnitSuite.
     */
    public NorlysSUnitSuite() {
        classNames = new Set<String>();
    }

    /**
     * @description Adds a test class to the suite.
     * @param testClass The type of the test class to add.
     * @return The current NorlysSUnitSuite instance for fluent chaining.
     */
    public NorlysSUnitSuite addClass(Type testClass) {
        if (testClass != null) {
            classNames.add(testClass.getName());
        }
        return this;
    }

    /**
     * @description Adds a list of test classes to the suite.
     * @param testClasses A list of test class types to add.
     * @return The current NorlysSUnitSuite instance for fluent chaining.
     */
    public NorlysSUnitSuite addClasses(List<Type> testClasses) {
        if (testClasses != null) {
            for (Type testClass : testClasses) {
                addClass(testClass);
            }
        }
        return this;
    }

    /**
     * @description Gets the ApexClass records for the tests in the suite.
     * @return A list of ApexClass records to be enqueued by the caller.
     */
    public List<ApexClass> getClassesToRun() {
        if (classNames.isEmpty()) {
            System.debug(LoggingLevel.WARN, 'SUnit Suite: No test classes were added to the suite.');
            return new List<ApexClass>();
        }

        return [SELECT Id FROM ApexClass WHERE Name IN :classNames];
    }
}