@isTest
private class ContentDocumentLinkServiceTest {

    @isTest
    static void getRelatedCasesByLinkedEntityIdsTest() {
        Account acc = TDF_AccountUtils.createAccountWithCVR('12345678');

		Case testCase = new Case(
                    Id = '500000000000001AAA',
                    AccountId = acc.Id,
                    Status = 'New',
                    Origin = 'Web',
                    Subject = 'Customer Service Case',
                    RecordTypeId = Schema.sObjectType.Case.getRecordTypeInfosByDeveloperName().get('Customer_Service_Case').getRecordTypeId()
                );
        
        ContentVersion contentVersion = new ContentVersion(
            Id = '068000000000001AAA',
            Title = 'title',
            PathOnClient = '/title.pdf',
            VersionData = Blob.valueOf('This is a test file body text')
        );

        ContentDocumentLink contentDocumentLink = new ContentDocumentLink(
            Id = '06A000000000001AAA',
			LinkedEntityId = testCase.Id,
			ContentDocumentId = contentVersion.ContentDocumentId,
			ShareType = 'V',
			Visibility = 'InternalUsers'
		);

        ContentDocumentLinkService contentDocumentLinkService = new ContentDocumentLinkService();

        Test.startTest();
            List<Id> relatedCaseIds = contentDocumentLinkService.getRelatedCasesByLinkedEntityIds(new List<ContentDocumentLink>{contentDocumentLink});
        Test.stopTest();

        Assert.areEqual(1, relatedCaseIds.size(), 'Exactly one CaseId should be returned');
    }
    
}