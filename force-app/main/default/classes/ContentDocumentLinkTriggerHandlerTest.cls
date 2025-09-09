@IsTest
private with sharing class ContentDocumentLinkTriggerHandlerTest {
	@isTest
    static void afterInsertTest() {

        Account acc = TDF_AccountUtils.createAccountWithCVR('12345678');

		Case testCase = TDF_CaseUtils.createCustomerServiceCasesForAccounts(new List<Account>{acc})[0];

        Mock ContentDocumentLinkServiceMock = Mock.forType(ContentDocumentLinkService.class);
        MethodSpy getRelatedCasesByLinkedEntityIdsSpy = ContentDocumentLinkServiceMock.spyOn('getRelatedCasesByLinkedEntityIds');
        
		Mock caseServiceMock = Mock.forType(CaseService.class);
      	MethodSpy updateCustomerServiceCasesToAwaitingUserSpy = caseServiceMock.spyOn('updateCustomerServiceCasesToAwaitingUser');

        ContentDocumentLinkTriggerHandler contentDocumentLinkTriggerHandler = new ContentDocumentLinkTriggerHandler((ContentDocumentLinkService) ContentDocumentLinkServiceMock.stub, (CaseService) caseServiceMock.stub);

        contentDocumentLinkTriggerHandler.afterInsert();

		Expect.that(getRelatedCasesByLinkedEntityIdsSpy).hasBeenCalled();
		Expect.that(updateCustomerServiceCasesToAwaitingUserSpy).hasBeenCalled();

    }
}