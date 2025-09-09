/**
 * @author keh
 * @since 10-03-2025 
 */
@IsTest global with sharing class SiteLoginControllerTest {

    /**
     * Test the site login functionality
     */
    @IsTest(SeeAllData=true) global static void login_inValidCredentials_returnsNull() {
        //ARRANGE
        SiteLoginController controller = new SiteLoginController ();
        controller.username = 'test@salesforce.com';
        controller.password = '123456'; 
        
        //ACT
        PageReference pageRef = controller.login();

        //ASSERT
        System.assertEquals(null, pageRef);                           
    }    
}