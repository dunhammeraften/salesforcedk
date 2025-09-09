/**
 * @description 
 *  The main facade for the SUnit framework.
 *  Provides static methods to access framework features.
 * @group SUnit
 */
public class NorlysSUnit {

    /**
     * @description Creates a new test suite builder.
     * @return A new instance of NorlysSUnitSuite.
     */
    public static NorlysSUnitSuite newSuite() {
        return new NorlysSUnitSuite();
    }

    /**
     * @description Creates a new data factory.
     * @return A new instance of NorlysSUnitDataFactory.
     */
    public static NorlysSUnitDataFactory newFactory() {
        return new NorlysSUnitDataFactory();
    }
}