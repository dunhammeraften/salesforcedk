public with sharing class UserSelector {
	public static User getById(String id) {
		List<User> users = [
			SELECT
				ContactId,
				Contact.AccountId,
				FederationIdentifier
			FROM User
			WHERE Id = :id
		];
		if(!users.isEmpty()) {
			return users[0];
		}

		return null;
	}

	public static User getActiveUserByAlias(String alias) {
		List<User> users = [
			SELECT
				Id,
				Alias,
				FederationIdentifier
			FROM User
			WHERE Alias = :alias
			AND IsActive = true
		];
		if(!users.isEmpty()) {
			return users[0];
		}

		return null;
	}
}