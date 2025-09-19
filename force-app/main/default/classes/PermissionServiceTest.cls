/**
 * @description Test class for the PermissionService.
 *              This class verifies that the permission and profile checking methods
 *              in the PermissionService work as expected.
 *
 * -----------------------------------------------------------------------------
 * @author Developer           Date            Description
 * -----------------------------------------------------------------------------
 * @author Esben Hovgaard        18/09/2025      Class and method documentation
 * -----------------------------------------------------------------------------
 */
@isTest
private class PermissionServiceTest {
	private static Mock permissionSelectorMock;

	private static void setupMocks() {
		permissionSelectorMock = Mock.forType(PermissionSelector.class);

		SingletonFactory factory = SingletonFactory.getFactory();
		factory.registerSingleton(PermissionSelector.class, (PermissionSelector) permissionSelectorMock.stub);
	}

	/**
	 * @description Verifies that hasPermissionSet returns true when the user has the specified permission set.
	 */
	@isTest
	static void testHasPermissionSet_returnsTrue_whenUserHasPermission() {
		// Arrange
		setupMocks();
		permissionSelectorMock.spyOn('selectPermissionSetAssignments')
			.whenCalledWith(new List<String>{ 'Test_Permission_Set' })
			.thenReturn(new List<PermissionSetAssignment>{ new PermissionSetAssignment() });

		PermissionService service = new PermissionService();
		List<String> permissionSetNames = new List<String>{ 'Test_Permission_Set' };

		// Act
		Test.startTest();
		Boolean result = service.hasPermissionSet(permissionSetNames);
		Test.stopTest();

		// Assert
		System.assertEquals(true, result, 'Should return true when user has the permission set');
	}

	/**
	 * @description Verifies that hasPermissionSet returns false when the user does not have the specified permission set.
	 */
	@isTest
	static void testHasPermissionSet_returnsFalse_whenUserDoesNotHavePermission() {
		// Arrange
		setupMocks();
		permissionSelectorMock.spyOn('selectPermissionSetAssignments')
			.whenCalledWith(new List<String>{ 'Non_Existent_Permission_Set' })
			.thenReturn(new List<PermissionSetAssignment>());

		PermissionService service = new PermissionService();
		List<String> permissionSetNames = new List<String>{ 'Non_Existent_Permission_Set' };

		// Act
		Test.startTest();
		Boolean result = service.hasPermissionSet(permissionSetNames);
		Test.stopTest();

		// Assert
		System.assertEquals(false, result, 'Should return false when user does not have the permission set');
	}

	/**
	 * @description Verifies that hasProfiles returns true when the user has the specified profile.
	 */
	@isTest
	static void testHasProfiles_returnsTrue_whenUserHasProfile() {
		// Arrange
		setupMocks();
		permissionSelectorMock.spyOn('selectProfiles')
			.whenCalledWith(new List<String>{ 'Standard User' })
			.thenReturn(new List<Profile>{ new Profile() });

		PermissionService service = new PermissionService();
		List<String> profileNames = new List<String>{ 'Standard User' };

		// Act
		Test.startTest();
		Boolean result = service.hasProfiles(profileNames);
		Test.stopTest();

		// Assert
		System.assertEquals(true, result, 'Should return true when user has the profile');
	}

	/**
	 * @description Verifies that hasProfiles returns false when the user does not have the specified profile.
	 */
	@isTest
	static void testHasProfiles_returnsFalse_whenUserDoesNotHaveProfile() {
		// Arrange
		setupMocks();
		permissionSelectorMock.spyOn('selectProfiles')
			.whenCalledWith(new List<String>{ 'System Administrator' })
			.thenReturn(new List<Profile>());

		PermissionService service = new PermissionService();
		List<String> profileNames = new List<String>{ 'System Administrator' };

		// Act
		Test.startTest();
		Boolean result = service.hasProfiles(profileNames);
		Test.stopTest();

		// Assert
		System.assertEquals(false, result, 'Should return false when user does not have the profile');
	}
}
