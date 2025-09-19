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
	/**
	 * @description Default constructor.
	 */
	public PermissionService() {
	}

	/**
	 * @description Checks if the current user has at least one of the specified permission sets.
	 * @param permissionSetName A list of permission set names to check for.
	 * @return True if the user has at least one of the permission sets, false otherwise.
	 */
	public Boolean hasPermissionSet(List<String> permissionSetName) {
		Set<String> psNames = new Set<String>();
		for (PermissionSetAssignment psa : [
			SELECT PermissionSet.Name
			FROM PermissionSetAssignment
			WHERE
				AssigneeId = :UserInfo.getUserId()
				AND PermissionSet.Name IN :permissionSetName
		]) {
			psNames.add(psa.PermissionSet.Name);
		}

		return !psNames.isEmpty();
	}

	/**
	 * @description Checks if the current user has one of the specified profiles.
	 * @param hasProfileNames A list of profile names to check for.
	 * @return True if the user's profile is in the list, false otherwise.
	 */
	public Boolean hasProfiles(List<String> hasProfileNames) {
		Set<String> profileNames = new Set<String>();
		for (Profile p : [
			SELECT Name
			FROM Profile
			WHERE Id = :UserInfo.getProfileId() AND Name IN :hasProfileNames
		]) {
			profileNames.add(p.Name);
		}

		return !profileNames.isEmpty();
	}
}
