/**
 * @description This selector class is responsible for all SOQL queries related to the Norlys Now integration.
 *              It provides methods to retrieve records such as NorlysNow_Case__c, FeedItem, ContentVersion, etc.
 *
 * -----------------------------------------------------------------------------
 * @author Developer           Date            Description
 * -----------------------------------------------------------------------------
 * @author Esben Hovgaard        18/09/2025      Class and method documentation
 * -----------------------------------------------------------------------------
 */
public with sharing class NorlysNowSelector {
	/**
	 * @description Retrieves a map of NorlysNow_Case__c records by their Ids, excluding those related to closed parent cases.
	 * @param recordIds A set of NorlysNow_Case__c record Ids.
	 * @return A map of NorlysNow_Case__c records keyed by their Id.
	 */
	public Map<Id, NorlysNow_Case__c> getNorlysNowCasesMap(Set<Id> recordIds) {
		Logger.logInfo(String.format('getNorlysNowCasesMap( {0} )', new List<Object>{ recordIds }));

		Map<Id, NorlysNow_Case__c> norlysNowCasesMap = new Map<Id, NorlysNow_Case__c>(
			(List<NorlysNow_Case__c>) new Query('NorlysNow_Case__c')
				.selectFields(
					new List<String>{
						'Id',
						'Name',
						'Parent_Case__c',
						'Parent_Case__r.Status',
						'Parent_Case__r.OwnerId',
						'CreatedBy.Id',
						'CreatedBy.Name',
						'Priority__c',
						'Description__c',
						'Title__c',
						'Type__c',
						'Status__c',
						'Reported_On__c',
						'NorlysNow_Id__c',
						'Request_Source__c',
						'Category__c',
						'Technology_Type__c',
						'Technology__c',
						'Sync_Status__c',
						'Sync_Message__c',
						'OneWorkFlow_Id__c'
					}
				)
				.byId(recordIds)
				.forView()
				.run()
		);

		return norlysNowCasesMap;
	}

	/**
	 * @description Retrieves all NorlysNow_Case__c records that are children of a given set of parent Case Ids.
	 * @param parentCaseIds A set of parent Case record Ids.
	 * @return A list of child NorlysNow_Case__c records.
	 */
	public List<NorlysNow_Case__c> getAllNorlysNowCasesUnderParentCases(Set<Id> parentCaseIds) {
		Logger.logInfo(String.format('getAllNorlysNowCasesUnderParentCases( {0} )', new List<Object>{ parentCaseIds }));

		List<NorlysNow_Case__c> norlysNowCases = new List<NorlysNow_Case__c>(
			(List<NorlysNow_Case__c>) new Query('NorlysNow_Case__c')
				.selectFields(new List<String>{ 'Id', 'Parent_Case__c', 'Status__c', 'Sync_Status__c' })
				.addConditionIn('Parent_Case__c', parentCaseIds)
				.run()
		);

		return norlysNowCases;
	}

	/**
	 * @description Retrieves a map of FeedItem records by their Ids.
	 * @param recordIds A set of FeedItem record Ids.
	 * @return A map of FeedItem records keyed by their Id.
	 */
	public Map<Id, FeedItem> getFeedItemMap(Set<Id> recordIds) {
		Logger.logInfo(String.format('getNorlysNowFeedItemMap( {0} )', new List<Object>{ recordIds }));
		Map<Id, FeedItem> feedItemMap = new Map<Id, FeedItem>(
			(List<FeedItem>) new Query('FeedItem')
				.selectFields(new List<String>{ 'Id', 'Body', 'ParentId' })
				.byId(recordIds)
				.run()
		);

		return feedItemMap;
	}

	/**
	 * @description Retrieves the latest ContentVersion for a given set of ContentDocument Ids.
	 * @param fileIds A set of ContentDocument Ids.
	 * @return A list of the latest ContentVersion records.
	 */
	public List<ContentVersion> getContentVersions(Set<Id> fileIds) {
		Logger.logInfo(String.format('getContentVersions( {0} )', new List<Object>{ fileIds }));
		List<ContentVersion> cvList = (List<ContentVersion>) new Query('ContentVersion')
			.selectFields(new List<String>{ 'Id', 'ContentDocumentId', 'PathOnClient', 'VersionData' })
			.addConditionEq('IsLatest', true)
			.addConditionIn('ContentDocumentId', fileIds)
			.run();

		return cvList;
	}

	/**
	 * @description Retrieves all ContentDocumentLink records for a given set of ContentDocument Ids.
	 * @param recordIds A set of ContentDocument Ids.
	 * @return A list of ContentDocumentLink records.
	 */
	public List<ContentDocumentLink> getContentDocumentLinks(Set<Id> recordIds) {
		Logger.logInfo(String.format('getContentDocumentLinks( {0} )', new List<Object>{ recordIds }));
		List<ContentDocumentLink> cdList = (List<ContentDocumentLink>) new Query('ContentDocumentLink')
			.selectFields(new List<String>{ 'ContentDocumentId', 'LinkedEntityId' })
			.addConditionIn('ContentDocumentId', recordIds)
			.run();

		return cdList;
	}

	/**
	 * @description Retrieves a CustomNotificationType record by its developer name.
	 * @param customNotifyTypeName The developer name of the CustomNotificationType.
	 * @return The CustomNotificationType record, or null if not found.
	 */
	public CustomNotificationType getCustomNotificationType(String customNotifyTypeName) {
		Logger.logInfo(String.format('getCustomNotificationType( {0} )', new List<Object>{ customNotifyTypeName }));
		CustomNotificationType notifyType = (CustomNotificationType) new Query('CustomNotificationType')
			.selectField('Id')
			.addConditionEq('DeveloperName', customNotifyTypeName)
			.setLimit(1)
			.fetch();

		return notifyType;
	}

	/**
	 * @description Retrieves a list of User records by their Ids.
	 * @param ownerIds A set of User record Ids.
	 * @return A list of User records.
	 */
	public List<User> getUsers(Set<Id> ownerIds) {
		Logger.logInfo(String.format('getUsers( {0} )', new List<Object>{ ownerIds }));
		List<User> users = (List<User>) new Query('User')
			.selectFields(new List<String>{ 'Id', 'Name', 'Email' })
			.addConditionIn('Id', ownerIds)
			.run();

		return users;
	}

	/**
	 * @description Retrieves a map of closed Case records by their Ids.
	 * @param parentCaseIds A set of Case record Ids.
	 * @return A map of closed Case records keyed by their Id.
	 */
	public Map<Id, Case> getCasesByIds(Set<Id> parentCaseIds) {
		Logger.logInfo(String.format('getCasesByIds( {0} )', new List<Object>{ parentCaseIds }));
		Map<Id, Case> closedParentCases = new Map<Id, Case>(
			(List<Case>) new Query('Case')
				.selectFields(new List<String>{ 'Id', 'Status' })
				.addConditionIn('Id', parentCaseIds)
				.addConditionEq('Status', 'Closed')
				.run()
		);

		return closedParentCases;
	}

	/**
	 * @description Retrieves an OrgWideEmailAddress record by its address.
	 * @param address The email address to search for.
	 * @return The OrgWideEmailAddress record, or null if not found.
	 */
	public OrgWideEmailAddress getOrgWideEmailAddress(String address) {
		Logger.logInfo(String.format('getOrgWideEmailAddress( {0} )', new List<Object>{ address }));
		OrgWideEmailAddress orgWideEmailAddress = (OrgWideEmailAddress) new Query('OrgWideEmailAddress')
			.selectFields(new List<String>{ 'Id', 'Address' })
			.addConditionEq('Address', address)
			.setLimit(1)
			.fetch();
		return orgWideEmailAddress;
	}
}
