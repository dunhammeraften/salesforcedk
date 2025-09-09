@isTest
public class StringUtilsTest {
    
    @IsTest
    private static void testMakeRandomStringFromCharacterSet() {
        Test.startTest();
            String testString = StringUtils.makeRandomStringNoNumerics(10);
            System.assertEquals(10, testString.length(), 'Generated string with 10 characters');
        Test.stopTest();
    }
}