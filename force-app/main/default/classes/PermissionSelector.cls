/**
 * @description This selector class is responsible for all SOQL queries related to Permissions.
 *              It provides methods to retrieve records such as PermissionSetAssignment and Profile.
 *
 * -----------------------------------------------------------------------------
 * @author Developer           Date            Description
 * -----------------------------------------------------------------------------
 * @author Esben Hovgaard      19/09/2025      Initial Version
 * -----------------------------------------------------------------------------
 */
public with sharing class PermissionSelector {
	/**
	 * @description Retrieves a list of PermissionSetAssignment records for the current user and a given set of permission set names.
	 * @param permissionSetName A list of permission set names.
	 * @return A list of PermissionSetAssignment records.
	 */
	public List<PermissionSetAssignment> selectPermissionSetAssignments(List<String> permissionSetName) {
		Logger.logInfo(String.format('selectPermissionSetAssignments( {0} )', new List<Object>{ permissionSetName }));
		return (List<PermissionSetAssignment>) new Query('PermissionSetAssignment')
			.selectFields(new List<String>{ 'PermissionSet.Name' })
			.addConditionEq('AssigneeId', UserInfo.getUserId())
			.addConditionIn('PermissionSet.Name', permissionSetName)
			.run();
	}

	/**
	 * @description Retrieves a list of Profile records for the current user and a given set of profile names.
	 * @param profileNames A list of profile names.
	 * @return A list of Profile records.
	 */
	public List<Profile> selectProfiles(List<String> profileNames) {
		Logger.logInfo(String.format('selectProfiles( {0} )', new List<Object>{ profileNames }));
		return (List<Profile>) new Query('Profile')
			.selectField('Name')
			.addConditionEq('Id', UserInfo.getProfileId())
			.addConditionIn('Name', profileNames)
			.run();
	}
}
