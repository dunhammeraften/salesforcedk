@isTest
private class PermissionServiceTest {
    @isTest
    static void testHasPermissionSet_returnsTrue_whenUserHasPermission() {
        // Arrange
        String psName = 'TestPermissionSet' + String.valueOf(Math.random()).substring(2,10);
        PermissionSet ps = new PermissionSet(Name = psName, Label = 'Test Permission Set');
        insert ps;

        PermissionSetAssignment psa = new PermissionSetAssignment(AssigneeId = UserInfo.getUserId(), PermissionSetId = ps.Id);
        insert psa;

        PermissionService service = new PermissionService();

        // Act
        Test.startTest();
        Boolean result = service.hasPermissionSet(new List<String>{psName});
        Test.stopTest();

        // Assert
        System.assertEquals(true, result, 'Should return true when user has the permission set');
    }

    @isTest
    static void testHasPermissionSet_returnsFalse_whenUserDoesNotHavePermission() {
        // Arrange
        PermissionService service = new PermissionService();

        // Act
        Test.startTest();
        Boolean result = service.hasPermissionSet(new List<String>{'Non_Existent_Permission_Set'});
        Test.stopTest();

        // Assert
        System.assertEquals(false, result, 'Should return false when user does not have the permission set');
    }

    @isTest
    static void testHasProfiles_returnsTrue_whenUserHasProfile() {
        // Arrange
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        String uniqueUserName = 'standarduser' + System.currentTimeMillis() + '@testorg.com';
        User u = new User(
            Alias = 'standt',
            Email='standarduser@testorg.com',
            EmailEncodingKey='UTF-8',
            LastName='Testing',
            LanguageLocaleKey='en_US',
            LocaleSidKey='en_US',
            ProfileId = p.Id,
            TimeZoneSidKey='America/Los_Angeles',
            UserName=uniqueUserName
        );
        insert u;

        PermissionService service = new PermissionService();

        System.runAs(u) {
            // Act
            Test.startTest();
            Boolean result = service.hasProfiles(new List<String>{'Standard User'});
            Test.stopTest();

            // Assert
            System.assertEquals(true, result, 'Should return true when user has the profile');
        }
    }

    @isTest
    static void testHasProfiles_returnsFalse_whenUserDoesNotHaveProfile() {
        // Arrange
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        String uniqueUserName = 'standarduser2' + System.currentTimeMillis() + '@testorg.com';
        User u = new User(
            Alias = 'standt2',
            Email='standarduser2@testorg.com',
            EmailEncodingKey='UTF-8',
            LastName='Testing2',
            LanguageLocaleKey='en_US',
            LocaleSidKey='en_US',
            ProfileId = p.Id,
            TimeZoneSidKey='America/Los_Angeles',
            UserName=uniqueUserName
        );
        insert u;

        PermissionService service = new PermissionService();

        System.runAs(u) {
            // Act
            Test.startTest();
            Boolean result = service.hasProfiles(new List<String>{'System Administrator'});
            Test.stopTest();

            // Assert
            System.assertEquals(false, result, 'Should return false when user does not have the profile');
        }
    }
}
