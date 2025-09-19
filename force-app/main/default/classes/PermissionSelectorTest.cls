/**
 * @description Test class for the PermissionSelector.
 *              This class verifies that the SOQL queries in the PermissionSelector
 *              work as expected.
 *
 * -----------------------------------------------------------------------------
 * @author Developer           Date            Description
 * -----------------------------------------------------------------------------
 * @author Esben Hovgaard      19/09/2025      Initial Version
 * -----------------------------------------------------------------------------
 */
@isTest
private class PermissionSelectorTest {
	/**
	 * @description Verifies that selectPermissionSetAssignments returns the correct PermissionSetAssignment.
	 */
	@isTest
	static void testSelectPermissionSetAssignments() {
		// Arrange
		String psName = 'TestPermissionSet' + String.valueOf(Math.random()).substring(2, 10);
		PermissionSet ps = new PermissionSet(Name = psName, Label = 'Test Permission Set');
		insert ps;

		PermissionSetAssignment psa = new PermissionSetAssignment(
			AssigneeId = UserInfo.getUserId(),
			PermissionSetId = ps.Id
		);
		insert psa;

		PermissionSelector selector = new PermissionSelector();

		// Act
		Test.startTest();
		List<PermissionSetAssignment> result = selector.selectPermissionSetAssignments(new List<String>{ psName });
		Test.stopTest();

		// Assert
		System.assertEquals(1, result.size(), 'Should return one PermissionSetAssignment');
		System.assertEquals(psa.Id, result[0].Id, 'Should return the correct PermissionSetAssignment');
	}

	/**
	 * @description Verifies that selectPermissionSetAssignments returns an empty list when no PermissionSetAssignment is found.
	 */
	@isTest
	static void testSelectPermissionSetAssignments_returnsEmptyList() {
		// Arrange
		PermissionSelector selector = new PermissionSelector();

		// Act
		Test.startTest();
		List<PermissionSetAssignment> result = selector.selectPermissionSetAssignments(
			new List<String>{ 'Non_Existent_Permission_Set' }
		);
		Test.stopTest();

		// Assert
		System.assertEquals(0, result.size(), 'Should return an empty list');
	}

	/**
	 * @description Verifies that selectProfiles returns the correct Profile.
	 */
	@isTest
	static void testSelectProfiles() {
		// Arrange
		Profile p = [SELECT Id, Name FROM Profile WHERE Name = 'Standard User'];
		String uniqueUserName = 'standarduser' + System.currentTimeMillis() + '@testorg.com';
		User u = new User(
			Alias = 'standt',
			Email = 'standarduser@testorg.com',
			EmailEncodingKey = 'UTF-8',
			LastName = 'Testing',
			LanguageLocaleKey = 'en_US',
			LocaleSidKey = 'en_US',
			ProfileId = p.Id,
			TimeZoneSidKey = 'America/Los_Angeles',
			UserName = uniqueUserName
		);
		insert u;

		PermissionSelector selector = new PermissionSelector();

		System.runAs(u) {
			// Act
			Test.startTest();
			List<Profile> result = selector.selectProfiles(new List<String>{ 'Standard User' });
			Test.stopTest();

			// Assert
			System.assertEquals(1, result.size(), 'Should return one Profile');
			System.assertEquals(p.Name, result[0].Name, 'Should return the correct Profile');
		}
	}

	/**
	 * @description Verifies that selectProfiles returns an empty list when no Profile is found.
	 */
	@isTest
	static void testSelectProfiles_returnsEmptyList() {
		// Arrange
		PermissionSelector selector = new PermissionSelector();

		// Act
		Test.startTest();
		List<Profile> result = selector.selectProfiles(new List<String>{ 'Non_Existent_Profile' });
		Test.stopTest();

		// Assert
		System.assertEquals(0, result.size(), 'Should return an empty list');
	}
}
