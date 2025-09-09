/**
 * 
 * @author keh
 * @since 11032025
 */
@isTest
public class HomeOfficeSelectorTest {

    /**
     * getHomeOfficeProductOptions_validCall_returnsListOfOptionsFromMdt
     */
    @isTest
    public static void getHomeOfficeProductOptions_validCall_returnsListOfOptionsFromMdt() {       
        //ARRANGE
        

        //ACT
        Test.startTest();
        List<Home_Office_Product_Preferences__mdt> result = HomeOfficeSelector.getHomeOfficeProductOptions();
        Test.stopTest();   

        //ASSERT
        System.Assert(result.size() > 0);
    }
    
    /**
     * getHomeOfficeProductOptionsRanking_validCall_returnsHomeOfficeProductRanking
     */
    @IsTest
    static void getHomeOfficeProductOptionsRanking_validCall_returnsHomeOfficeProductRanking() {
        //ARRANGE
        // Create test data
        Account testAccount = new Account();
        testAccount.Name = 'Test Account';
        testAccount.CVR__c = '77889911';
        testAccount.Home_Office_Product_Preferences__c = 'Test Preferences';
        insert testAccount;
        
        Contact testContact = new Contact();
        testContact.FirstName = 'Test';
        testContact.LastName = 'Contact';
        testContact.Email = 'test@testing.test';
        testContact.AccountId = testAccount.Id;
        insert testContact;

        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Telia Onboarding Portal User' LIMIT 1];
        User testUser = new User();

        Blob b = Crypto.GenerateAESKey(128);
        String h = EncodingUtil.ConvertTohex(b);
        String uid = h.SubString(0,8);
   
        testUser.FirstName = 'Test';
        testUser.LastName = 'User';
        testUser.ContactId = testContact.Id;
        testUser.Email = uid + '@companytest.com';
        testUser.Alias = uid;
        testUser.Username = uid + '@companytest.com';
        testUser.CommunityNickname = 'test12';
        testUser.LocaleSidKey = 'en_US';
        testUser.TimeZoneSidKey = 'GMT';
        testUser.ProfileID = profileId.Id;
        testUser.LanguageLocaleKey = 'en_US';
        testUser.EmailEncodingKey = 'UTF-8';
        insert testUser;
        
        //ACT
        Test.startTest();
        String result = '';
        System.runAs(testUser) {
            result = HomeOfficeSelector.getHomeOfficeProductOptionsRanking();   
        }
        Test.stopTest();

        //ASSERT
        System.assertEquals('Test Preferences', result);
    }

    /**
     * 
     */
    @isTest
    public static void getAccount_validCall_returnsAccountId() {
        //ARRANGE
        
        
        //ACT
        Test.startTest();
        String accId = HomeOfficeSelector.getAccount();
        Test.stopTest();

        //ASSERT
        System.assert(accId != null);
    }
    
    @isTest
    public static void getOpportunity_validCall_returnsOpportunityId() {
        //ARRANGE
        // Create test data
        // Create test records for User, Contact, and OpportunityContactRole
        
        //ACT
        Test.startTest();
        String oppId = HomeOfficeSelector.getOpportunity();
        Test.stopTest();
        
        // Perform assertions
        // Add assertions based on the expected behavior of the method
        //ASSERT
        System.assert(oppId != null);
    }
}