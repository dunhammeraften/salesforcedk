@IsTest
private class CaseSelectorTest {
    private static final String TEST_CASE_STANDARD_NAME = 'Test Case';
    private static final String TEST_CVR = '00000001';

    @testSetup
    private static void setup() {
        Account acc = TDF_AccountUtils.createAccountWithCVR(TEST_CVR);
        acc.OwnerId = UserInfo.getUserId();
        insert acc;

        Opportunity opp = TDF_OpportunityUtils.createOpportunitiesForAccounts(1, new List<Account>{acc})[0];

        Case cas = TDF_CaseUtils.createCasesForOpportunitiesAndAssignThem(new List<Opportunity>{opp})[0];
        cas.Subject = TEST_CASE_STANDARD_NAME;
        update cas;
    }

    @IsTest 
    private static void getByIdTest() {
        Case testCase = [
            SELECT Id, Subject
            FROM Case
            WHERE Subject = :TEST_CASE_STANDARD_NAME
        ];

        Test.startTest();
        Case resultCase = CaseSelector.getById(testCase.Id);
        Test.stopTest();

        Assert.areEqual(testCase.Id, resultCase.Id, 'Returned Case Id should match test Case');
    }

    //Tests method that is only used by LWC topEncryptionKey - can probably be deleted
    @IsTest
    private static void testGetByCurrentUser() {
        Account testAccount = new Account(Name = 'Test Account', CVR__c = '11110000');
        insert testAccount;

        Contact testContact = new Contact(FirstName = 'Test', LastName = 'Tester', email = 'test@companytesting.com', AccountId = testAccount.Id);
        insert testContact;
        
        User testUser = new User();
        testUser.ContactId = testContact.Id;
        testUser.LastName = 'Test Code';
        testUser.Email = 'test@companytest.com';
        testUser.Alias = 'Tcode';
        testUser.Username = 'test1234444@companytest.com';
        testUser.LocaleSidKey = 'en_US';
        testUser.TimeZoneSidKey = 'GMT';
        testUser.ProfileID = [SELECT Id FROM Profile WHERE Name = 'Telia Onboarding Portal User' LIMIT 1].Id;
        testUser.LanguageLocaleKey = 'en_US';
        testUser.EmailEncodingKey = 'UTF-8';

        insert testUser;
        
        Case testCase = new Case(
            AccountId = testAccount.Id,
            Status = 'Gather Information',
            RecordTypeId =  Schema.sObjectType.Case.getRecordTypeInfosByDeveloperName().get('Order_Fulfilment_Case').getRecordTypeId()
        );
        insert testCase;
        
        String resultCaseId;
        Test.startTest();
        System.runAs(testUser) {
            resultCaseId = CaseSelector.getByCurrentUser();
        }
        Test.stopTest();

        Assert.areEqual(testCase.Id, resultCaseId, 'Returned Case Id should match test Case');
    }

    @IsTest 
    private static void testGetOrderFulfilmentCasesByAccountId() {
        Account testAccount = new Account(Name = 'Test Account', CVR__c = '11110000');
        insert testAccount;
        
        Case testCase = new Case(
            AccountId = testAccount.Id,
            Status = 'Gather Information',
            RecordTypeId =  Schema.sObjectType.Case.getRecordTypeInfosByDeveloperName().get('Order_Fulfilment_Case').getRecordTypeId()
        );
        insert testCase;
        
        Test.startTest();
        List<Case> resultCases = CaseSelector.getOrderFulfilmentCasesByAccountId(testAccount.Id);
        Test.stopTest();
        
        Assert.areEqual(1, resultCases.size(), 'Exactly one Case should be returned');
        Assert.areEqual(testCase.Id, resultCases[0].Id, 'Returned Case Id should match test Case');
    }

    @IsTest 
    private static void testGetCasesByOpportunityIds() {
        Opportunity opp = [
            SELECT Id
            FROM Opportunity
            LIMIT 1
        ];
        Set<Id> opportunityIds = new Set<Id>{opp.Id};

        Test.startTest();
        List<Case> cases = CaseSelector.getCasesByOpportunityIds(opportunityIds);
        Test.stopTest();

        Assert.areEqual(1, cases.size(), 'Exactly one Case should be returned');
        Assert.areEqual(opp.Id, cases[0].Opportunity__c, 'The Case should be related to the test Opportunity');
    }

    @IsTest
    private static void testGetCustomerServiceCasesByIdsSuccess() {
        Account acc = [
            SELECT Id
            FROM Account
            WHERE CVR__c = :TEST_CVR
            LIMIT 1
        ];
        Case testCase = TDF_CaseUtils.createCustomerServiceCasesForAccounts(new List<Account>{acc})[0];
        CaseSelector caseSelector = new CaseSelector();
        Test.startTest();
        List<Case> resultCases = caseSelector.getCustomerServiceCasesByIds(new List<Id>{testCase.Id});
        Test.stopTest();

        Assert.areEqual(1, resultCases.size(), 'Exactly one Case should be returned');
        Assert.areEqual(testCase.Id, resultCases[0].Id, 'Returned Case Id should match test Case');
    }
}