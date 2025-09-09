/**
 * 
 * @author keh
 * @since 10-03-2025
 */
@isTest
public class FieldPickerControllerTest {
    
    /**
     * Test whether the getPicklistValues method returns a list of members
     */
    @isTest
    public static void getPicklistValues_correctInput_returnsMemberList() {
        //ARRANGE
        String objName = 'Account';
        String fieldName = 'Type';

        //ACT
        List<FieldPickerController.Member> memberList = FieldPickerController.getPicklistValues(objName, fieldName);

        //ASSERT
        System.assertNotEquals(memberList, null);
    
    }
}