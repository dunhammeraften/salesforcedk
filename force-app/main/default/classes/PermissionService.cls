/**
 * @description This service class provides methods to check the current user's permissions.
 *              It can be used to verify if a user has a specific permission set or profile.
 *
 * -----------------------------------------------------------------------------
 * @author Developer           Date            Description
 * -----------------------------------------------------------------------------
 * @author Esben Hovgaard        18/09/2025      Class and method documentation
 * -----------------------------------------------------------------------------
 */
public with sharing class PermissionService {
	private final PermissionSelector permissionSelector;

	/**
	 * @description Default constructor.
	 */
	public PermissionService() {
		this(SingletonFactory.getFactory());
	}

	/**
	 * @description Private constructor for dependency injection.
	 * @param singletonFactory The SingletonFactory instance to use for creating dependencies.
	 */
	private PermissionService(SingletonFactory singletonFactory) {
		this.permissionSelector = (PermissionSelector) singletonFactory.getOrRegisterSingleton(PermissionSelector.class);
	}

	/**
	 * @description Checks if the current user has at least one of the specified permission sets.
	 * @param permissionSetName A list of permission set names to check for.
	 * @return True if the user has at least one of the permission sets, false otherwise.
	 */
	public Boolean hasPermissionSet(List<String> permissionSetName) {
		Logger.logInfo(String.format('hasPermissionSet( {0} )', new List<Object>{ permissionSetName }));
		List<PermissionSetAssignment> psAssignments = this.permissionSelector.selectPermissionSetAssignments(
			permissionSetName
		);

		return !psAssignments.isEmpty();
	}

	/**
	 * @description Checks if the current user has one of the specified profiles.
	 * @param hasProfileNames A list of profile names to check for.
	 * @return True if the user's profile is in the list, false otherwise.
	 */
	public Boolean hasProfiles(List<String> hasProfileNames) {
		Logger.logInfo(String.format('hasProfiles( {0} )', new List<Object>{ hasProfileNames }));
		List<Profile> profiles = this.permissionSelector.selectProfiles(hasProfileNames);

		return !profiles.isEmpty();
	}
}
