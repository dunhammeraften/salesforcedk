/**
 * @description 
 *  A base class for tests written with the SUnit framework.
 *  It provides convenience methods for accessing SUnit utilities.
 *  This class is not a test class itself, but is intended to be extended by test classes.
 * @group SUnit
 */
public virtual class NorlysSUnitTest {

    /**
     * @description Provides a new instance of the SUnit Data Factory.
     * @return A new NorlysSUnitDataFactory instance.
     */
    public static NorlysSUnitDataFactory getFactory() {
        return new NorlysSUnitDataFactory();
    }
}