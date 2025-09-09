public with sharing class NorlysNowSelector {

    public Map<Id, NorlysNow_Case__c> getNorlysNowCasesMap(Set<Id> recordIds) {
        Logger.logInfo(String.format('getNorlysNowCasesMap( {0} )', new List<Object>{ recordIds }));

        Map<Id, NorlysNow_Case__c> norlysNowCasesMap = new Map<Id, NorlysNow_Case__c>(
        (List<NorlysNow_Case__c>) new Query('NorlysNow_Case__c')
        .selectFields(new List<String>{
            'Id',
            'Name',
            'Account__c',
            'Parent_Case__c',
            'Parent_Case__r.Status',
            'Parent_Case__r.OwnerId',
            'CreatedBy.Id',
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
            'Sync_Message__c'
        })
        .byId(recordIds)
        .addConditionNotNull('Parent_Case__c')
        .addConditionNotEq('Parent_Case__r.Status', 'Closed')
        .run()
        );

        return norlysNowCasesMap;
    }

    public List<NorlysNow_Case__c> getAllNorlysNowCasesUnderParentCases(Set<Id> parentCaseIds) {
        Logger.logInfo(String.format('getAllNorlysNowCasesUnderParentCases( {0} )', new List<Object>{ parentCaseIds }));

        List<NorlysNow_Case__c> norlysNowCases = new List<NorlysNow_Case__c>(
        (List<NorlysNow_Case__c>) new Query('NorlysNow_Case__c')
        .selectFields(new List<String>{
            'Id',
            'Parent_Case__c',
            'Status__c',
            'Sync_Status__c'
        })
        .addConditionIn('Parent_Case__c', parentCaseIds)
        .run()
        );

        return norlysNowCases;
    }

    public Map<Id, FeedItem> getFeedItemMap(Set<Id> recordIds ) {
        Logger.logInfo(String.format('getNorlysNowFeedItemMap( {0} )', new List<Object>{ recordIds }));
        Map<Id, FeedItem> feedItemMap = new Map<Id, FeedItem>(
            (List<FeedItem>) new Query('FeedItem')
                .selectFields(new List<String>{
                    'Id',
                    'Body',
                    'ParentId'
                })
                .byId(recordIds)
                .run()
        );

        return feedItemMap;
    }

    public List<ContentVersion> getContentVersions(Set<Id> fileIds) {
        Logger.logInfo(String.format('getContentVersions( {0} )', new List<Object>{ fileIds }));
        List<ContentVersion> cvList = (List<ContentVersion>) new Query('ContentVersion')
        .selectFields(new List<String>{
            'Id',
            'ContentDocumentId',
            'PathOnClient',
            'VersionData'
        })
        .addConditionEq('IsLatest', true)
        .addConditionIn('ContentDocumentId', fileIds)
        .run();

        return cvList;
    }

    public List<ContentDocumentLink> getContentDocumentLinks(Set<Id> recordIds) {
        Logger.logInfo(String.format('getContentDocumentLinks( {0} )', new List<Object>{ recordIds }));
        List<ContentDocumentLink> cdList = (List<ContentDocumentLink>) new Query('ContentDocumentLink')
        .selectFields(new List<String>{
            'ContentDocumentId',
            'LinkedEntityId'
        })
        .addConditionIn('ContentDocumentId', recordIds)
        .run();

        return cdList;
    }

    public CustomNotificationType getCustomNotificationType(String customNotifyTypeName) {
        Logger.logInfo(String.format('getCustomNotificationType( {0} )', new List<Object>{ customNotifyTypeName }));
        CustomNotificationType notifyType = (CustomNotificationType) new Query('CustomNotificationType')
        .selectField('Id')
        .addConditionEq('DeveloperName', customNotifyTypeName)
        .setLimit(1)
        .fetch();

        return notifyType;
    }

    public List<User> getUsers(Set<Id> ownerIds) {
        Logger.logInfo(String.format('getUsers( {0} )', new List<Object>{ ownerIds }));
        List<User> users = (List<User>) new Query('User')
        .selectFields(new List<String>{
            'Id',
            'Name',
            'Email'
        })
        .addConditionIn('Id', ownerIds)
        .run();

        return users;
    }

    public Map<Id, Case> getCasesByIds(Set<Id> parentCaseIds) {
        Map<Id, Case> closedParentCases = new Map<Id, Case>(
        (List<Case>) new Query('Case')
        .selectFields(new List<String>{
            'Id',
            'Status'
        })
        .addConditionIn('Id', parentCaseIds)
        .addConditionEq('Status', 'Closed')
        .run()
        );
       
        return closedParentCases;
    }

    public OrgWideEmailAddress getOrgWideEmailAddress(String address) {
        Logger.logInfo(String.format('getOrgWideEmailAddress( {0} )', new List<Object>{ address }));
        OrgWideEmailAddress orgWideEmailAddress = (OrgWideEmailAddress) new Query('OrgWideEmailAddress')
        .selectFields(new List<String>{
            'Id',
            'Address'
        })
        .addConditionEq('Address', address)
        .setLimit(1)
        .fetch();   
        return orgWideEmailAddress;
    }
}