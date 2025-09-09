public with sharing class PermissionService {
    
    public Boolean hasPermissionSet(List<String> permissionSetName) {
        Set<String> psNames = new Set<String>();
        for (PermissionSetAssignment psa : [
            SELECT PermissionSet.Name
            FROM PermissionSetAssignment
            WHERE AssigneeId = :UserInfo.getUserId() AND PermissionSet.Name IN : permissionSetName]) {
            psNames.add(psa.PermissionSet.Name);
        }

        return !psNames.isEmpty();
    }

    public Boolean hasProfiles (List<String> hasProfileNames) {
        Set<String> profileNames = new Set<String>();
        for (Profile p: [SELECT Name FROM Profile WHERE Id = :UserInfo.getProfileId() AND Name IN : hasProfileNames]) {
            profileNames.add(p.Name);
        }

        return !profileNames.isEmpty();
    }

}