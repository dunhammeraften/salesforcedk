@isTest
private class NorlysNowSelectorTest {

    @isTest
    static void getNorlysNowCasesMap_ShouldReturnOpenCases() {
        // Arrange
        NorlysTestScenarios.ScenarioResult scenario = NorlysTestScenarios.newBuilder()
            .forNorlysNowCaseHandling()
            .withNorlysNowCases(1)
            .build();
        
        Set<Id> norlysNowCaseIds = new Set<Id>{ scenario.norlysNowCases[0].Id };

        // Act
        NorlysNowSelector selector = new NorlysNowSelector();
        Map<Id, NorlysNow_Case__c> result;
        Test.startTest();
        result = selector.getNorlysNowCasesMap(norlysNowCaseIds);
        Test.stopTest();

        // Assert
        System.assertEquals(1, result.size(), 'Should return the open case.');
        System.assert(result.containsKey(scenario.norlysNowCases[0].Id), 'The returned map should contain the created case.');
    }

    @isTest
    static void getNorlysNowCasesMap_ShouldNotReturnCasesWithClosedParents() {
        // Arrange
        NorlysTestScenarios.ScenarioResult scenario = NorlysTestScenarios.newBuilder()
            .forNorlysNowCaseHandling()
            .withNorlysNowCases(1)
            .build();
        
        // Close the parent case
        scenario.caseRecord.Status = 'Closed';
        scenario.caseRecord.Contract_compliant__c = 'Yes';
        update scenario.caseRecord;

        Set<Id> norlysNowCaseIds = new Set<Id>{ scenario.norlysNowCases[0].Id };

        // Act
        NorlysNowSelector selector = new NorlysNowSelector();
        Map<Id, NorlysNow_Case__c> result;
        Test.startTest();
        result = selector.getNorlysNowCasesMap(norlysNowCaseIds);
        Test.stopTest();

        // Assert
        System.assertEquals(0, result.size(), 'Should not return cases whose parent case is closed.');
    }

    @isTest
    static void getAllNorlysNowCasesUnderParentCases_ShouldReturnAllCases() {
        // Arrange
        NorlysTestScenarios.ScenarioResult scenario = NorlysTestScenarios.newBuilder()
            .forNorlysNowCaseHandling()
            .withNorlysNowCases(3)
            .build();
        
        Set<Id> parentCaseIds = new Set<Id>{ scenario.caseRecord.Id };

        // Act
        NorlysNowSelector selector = new NorlysNowSelector();
        List<NorlysNow_Case__c> result;
        Test.startTest();
        result = selector.getAllNorlysNowCasesUnderParentCases(parentCaseIds);
        Test.stopTest();

        // Assert
        System.assertEquals(3, result.size(), 'Should return all three cases under the parent.');
    }

    @isTest
    static void getFeedItemMap_ShouldReturnCorrectFeedItems() {
        // Arrange
        NorlysTestScenarios.ScenarioResult scenario = NorlysTestScenarios.newBuilder()
            .forNorlysNowCaseHandling()
            .withNorlysNowCases(1)
            .withFeedItems(1)
            .build();
        
        Set<Id> feedItemIds = new Set<Id>{ scenario.feedItems[0].Id };

        // Act
        NorlysNowSelector selector = new NorlysNowSelector();
        Map<Id, FeedItem> result;
        Test.startTest();
        result = selector.getFeedItemMap(feedItemIds);
        Test.stopTest();

        // Assert
        System.assertEquals(1, result.size(), 'Should return one feed item.');
        System.assert(result.containsKey(scenario.feedItems[0].Id), 'The returned map should contain the created feed item.');
    }

    @isTest
    static void getContentVersions_ShouldReturnLatestVersions() {
        // Arrange
        NorlysTestScenarios.ScenarioResult scenario = NorlysTestScenarios.newBuilder()
            .forNorlysNowCaseHandling()
            .withNorlysNowCases(1)
            .withAttachedFiles(1)
            .build();
        
        Set<Id> contentDocumentIds = new Set<Id>();
        for (ContentDocumentLink cdl : scenario.contentDocumentLinks) {
            contentDocumentIds.add(cdl.ContentDocumentId);
        }

        // Act
        NorlysNowSelector selector = new NorlysNowSelector();
        List<ContentVersion> result;
        Test.startTest();
        result = selector.getContentVersions(contentDocumentIds);
        Test.stopTest();

        // Assert
        System.assertEquals(1, result.size(), 'Should return one content version.');
        System.assertEquals(contentDocumentIds.iterator().next(), result[0].ContentDocumentId, 'Should be for the correct document.');
    }

    @isTest
    static void getContentDocumentLinks_ShouldReturnCorrectLinks() {
        // Arrange
        NorlysTestScenarios.ScenarioResult scenario = NorlysTestScenarios.newBuilder()
            .forNorlysNowCaseHandling()
            .withNorlysNowCases(1)
            .withAttachedFiles(1)
            .build();
        
        Set<Id> contentDocumentIds = new Set<Id>();
        for (ContentDocumentLink cdl : scenario.contentDocumentLinks) {
            contentDocumentIds.add(cdl.ContentDocumentId);
        }

        // Act
        NorlysNowSelector selector = new NorlysNowSelector();
        List<ContentDocumentLink> result;
        Test.startTest();
        result = selector.getContentDocumentLinks(contentDocumentIds);
        Test.stopTest();

        // Assert
        // When a file is created, it's linked to the owner and the specified record.
        // So we expect at least one link to the case.
        System.assert(result.size() > 0, 'Should return at least one content document link.');
        
        Boolean isLinkedToCase = false;
        for(ContentDocumentLink cdl : result) {
            if(cdl.LinkedEntityId == scenario.norlysNowCases[0].Id) {
                isLinkedToCase = true;
                break;
            }
        }
        System.assert(isLinkedToCase, 'A content document link should be linked to the NorlysNow Case.');
    }

    @isTest
    static void getCustomNotificationType_ShouldReturnNullForNonExistentType() {
        // Arrange
        final String NOTIFICATION_NAME = 'NonExistentTestNotificationForTest';

        // Act
        NorlysNowSelector selector = new NorlysNowSelector();
        CustomNotificationType result;
        Test.startTest();
        result = selector.getCustomNotificationType(NOTIFICATION_NAME);
        Test.stopTest();

        // Assert
        System.assertEquals(null, result, 'Should return null for a non-existent notification type.');
    }

    @isTest
    static void getUsers_ShouldReturnCorrectUsers() {
        // Arrange
        // The scenario builder creates a user we can query for.
        NorlysTestScenarios.ScenarioResult scenario = NorlysTestScenarios.newBuilder()
            .forNorlysNowCaseHandling()
            .build();
        
        Set<Id> userIds = new Set<Id>{ scenario.owner.Id };

        // Act
        NorlysNowSelector selector = new NorlysNowSelector();
        List<User> result;
        Test.startTest();
        result = selector.getUsers(userIds);
        Test.stopTest();

        // Assert
        System.assertEquals(1, result.size(), 'Should return one user.');
        System.assertEquals(scenario.owner.Id, result[0].Id, 'Should return the correct user.');
    }

    @isTest
    static void getCasesByIds_ShouldReturnClosedCases() {
        // Arrange
        NorlysTestScenarios.ScenarioResult scenario = NorlysTestScenarios.newBuilder()
            .forNorlysNowCaseHandling()
            .build();
        
        scenario.caseRecord.Status = 'Closed';
        scenario.caseRecord.Contract_compliant__c = 'Yes';
        update scenario.caseRecord;

        Set<Id> caseIds = new Set<Id>{ scenario.caseRecord.Id };

        // Act
        NorlysNowSelector selector = new NorlysNowSelector();
        Map<Id, Case> result;
        Test.startTest();
        result = selector.getCasesByIds(caseIds);
        Test.stopTest();

        // Assert
        System.assertEquals(1, result.size(), 'Should return one case.');
        System.assert(result.containsKey(scenario.caseRecord.Id), 'The returned map should contain the created case.');
        System.assertEquals('Closed', result.get(scenario.caseRecord.Id).Status, 'The case status should be "Closed".');
    }

    @isTest
    static void getOrgWideEmailAddress_ShouldReturnNullForNonExistentAddress() {
        // Arrange
        // OrgWideEmailAddress is a metadata type and cannot be created in a test method.
        // Therefore, we can only test the negative case where the address does not exist.

        // Act
        NorlysNowSelector selector = new NorlysNowSelector();
        OrgWideEmailAddress result;
        Test.startTest();
        result = selector.getOrgWideEmailAddress('non.existent.email.for.test@test.com');
        Test.stopTest();

        // Assert
        System.assertEquals(null, result, 'Should return null for a non-existent email address.');
    }
}
