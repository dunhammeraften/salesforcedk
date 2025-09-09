// Testing auto-generated class RegHandler1736344095018, which should be renamed and this class should be re-visited, when we have a little time.
@IsTest
private class SsoRegHandlerTest {
    private static final String USER_ALIAS = 'My_Alias';
    private static final String TELIA_ENTERPRISE_SALES_PROFILE_NAME = 'Telia Enterprise Sales';

    @TestSetup
    private static void makeData() {
        Id profileId = ProfileSelector.getProfileByProfileName(TELIA_ENTERPRISE_SALES_PROFILE_NAME).Id;
        TestDataFactory.createUser(USER_ALIAS, profileId);
    }

    @IsTest
    private static void createUserTestSuccess() {
        Auth.UserData data = getTestAuthUserDataWithEmail('standarduser@testorg.com');
        
        Test.startTest();
        User testUser = new RegHandler1736344095018().createUser(null, data);
        Test.stopTest();
        
        Assert.areEqual(USER_ALIAS, testUser.Alias, 'User Alias should match');
    }
    
    @IsTest
    private static void createUserTestError() {
        Auth.UserData data = getTestAuthUserDataWithEmail('non-existing-email@nodomainfound.invalid');
        
        Test.startTest();
        User testUser = new RegHandler1736344095018().createUser(null, data);
        Test.stopTest();
        
        Assert.isNull(testUser, 'Null should be returned when no User is found');
    }
    
    // This is purely for code coverage as the method called is doing nothing for now but is required by the
    //  Auth.RegistrationHandler interface implemented
    @IsTest
    private static void updateUserTest() {
        Auth.UserData data = getTestAuthUserDataWithEmail('standarduser@testorg.com');
        
        Test.startTest();
        new RegHandler1736344095018().updateUser(UserInfo.getUserId(), null, data);
        Test.stopTest();
    }
    
    private static Auth.UserData getTestAuthUserDataWithEmail(String email) {
        Map<String, String> attributeMap = new Map<String, String>();
        attributeMap.put('tcad', '12345');
        
        Auth.UserData data = new Auth.UserData(
            'standarduser@testorg.com',
            'firstName',
            'lastName',
            'fullName',
            email,
            'link',
            'userName',
            'en_US',
            'idp_SSO',
            'siteLoginUrl',
            attributeMap
        );
        
        return data;
    }
}