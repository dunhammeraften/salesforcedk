// Auto-generated class that was deployed without renaming according to our naming convention.
//  it should be renamed and the Auth. Provider should be updated to use the new class
global class RegHandler1736344095018 implements Auth.RegistrationHandler {
    public User createUser(Id portalId, Auth.UserData data) {
        // TODO: Create new method in UserSelector
        List<User> users = [
            SELECT Id, Username, Alias
            FROM User 
            WHERE Email = :data.email
            OR FederationIdentifier = :data.AttributeMap.get('tcad') 
            OR Legacy_Email__c = :data.email
        ];

        if(users.size() > 0) {
            return users[0];
        }

        return null;
    }

    // we perform no actions on update as we don't update users on SSO login
    public void updateUser(Id userId, Id portalId, Auth.UserData data) {}
}