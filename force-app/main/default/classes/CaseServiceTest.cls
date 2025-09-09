@isTest
private class CaseServiceTest {

    @IsTest
    static void updateCustomerServiceCasesToAwaitingUserTest() {

        Account acc = TDF_AccountUtils.createAccountWithCVR('12345678');

		Case testCase = TDF_CaseUtils.createCustomerServiceCasesForAccounts(new List<Account>{acc})[0];

        Assert.isFalse(testCase.Awaiting_user__c, 'Case should be awaiting user after update');

        Mock caseSelectorMock = Mock.forType(CaseSelector.class);
        MethodSpy getCustomerServiceCasesByIdsSpy = caseSelectorMock.spyOn('getCustomerServiceCasesByIds');
        
        getCustomerServiceCasesByIdsSpy.whenCalledWith(Argument.any()).thenReturn(new List<Case>{testCase});

        CaseService caseService = new CaseService((CaseSelector) caseSelectorMock.stub);
        
        Test.startTest();
            List<Case> resultCases = caseService.updateCustomerServiceCasesToAwaitingUser(new List<Id>{testCase.Id});
        Test.stopTest();

        Assert.isTrue(resultCases[0].Awaiting_user__c, 'Case should be awaiting user after update');
    }

	@IsTest
	public static void createTeamMember_withEmptyList_returnsEmptyList() {
		//ARRANGE
		List<Case> cases = new List<Case>();
	
		CaseService caseService = new CaseService();
		//ACT
		List<CaseTeamMember> members = caseService.createTeamMember(cases, 'Case Originator');
	
		//ASSERT
		Assert.isTrue(members.isEmpty(), 'The list is empty');
	}
	
	@IsTest
	public static void createTeamMember_withCase_returnsTeamMember() {
		//ARRANGE
		List<Case> cases = new List<Case>();
		Case c = new Case();
		c.OwnerId = UserInfo.getUserId();
		cases.add(c);
	
		CaseService caseService = new CaseService();
	
		//ACT
		List<CaseTeamMember> members = caseService.createTeamMember(cases, 'Case Originator');
	
		//ASSERT
		Assert.isFalse(members.isEmpty(), 'The list is not empty');
		Assert.areEqual(members.get(0).MemberId, c.OwnerId, 'The case owner and the memberId should be equals.');
	}
	
	@IsTest
	public static void createTeamMember_withGroupOwnerCase_returnsEmptyList() {
		//ARRANGE
		List<Case> cases = new List<Case>();
		Case c = new Case();
		c.OwnerId = '00G1i000002SfYwEAK'; //Internal support group
		cases.add(c);
	
		CaseService caseService = new CaseService();
	
		//ACT
		List<CaseTeamMember> members = caseService.createTeamMember(cases, 'Case Originator');
	
		//ASSERT
		Assert.isTrue(members.isEmpty(), 'The list is empty');
	}
	
	@IsTest
	public static void getNewCaseStatusChangeRecords_withNewCase_returnsCaseStatusChange() {
		//ARRANGE
		List<Case> cases = new List<Case>();
		Case c = new Case();
		c.OwnerId = '00G1i000002SfYwEAK'; //Internal support group
		c.Status = 'Testing';
		cases.add(c);
	
		CaseService caseService = new CaseService();
	
		//ACT
		List<Case_Status_Change__c> caseStatusChanges = caseService.getNewCaseStatusChangeRecords(cases, null);
	
		//ASSERT
		Assert.isFalse(caseStatusChanges.isEmpty(), 'The list is empty');
		Assert.areEqual(
			c.Status,
			caseStatusChanges.get(0).Status_Name__c,
			'The status is set on the created Case_Status_Change'
		);
	}
	
	@IsTest
	public static void getNewCaseStatusChangeRecords_withCaseStatusChange_returnsCaseStatusChange() {
		//ARRANGE
		List<Case> cases = new List<Case>();
		Case c = new Case();
		c.Status = 'Testing changed';
		c.Id = '500RR00000Ly4ZaYAJ';
		cases.add(c);
	
		Map<Id, Case> oldCaseMap = new Map<Id, Case>();
		oldCaseMap.put('500RR00000Ly4ZaYAJ', new Case(Status = 'Testing', Id = '500RR00000Ly4ZaYAJ'));
	
		CaseService caseService = new CaseService();
	
		//ACT
		List<Case_Status_Change__c> caseStatusChanges = caseService.getNewCaseStatusChangeRecords(cases, oldCaseMap);
	
		//ASSERT
		Assert.isFalse(caseStatusChanges.isEmpty(), 'The list is empty');
		Assert.areEqual(
			c.Status,
			caseStatusChanges.get(0).Status_Name__c,
			'The status is set on the created Case_Status_Change'
		);
		Assert.areEqual(
			'Testing',
			caseStatusChanges.get(0).Status_From__c,
			'The status was set for the previous value'
		);
	}
	
	@IsTest
	public static void getCurrentCaseStatusChangeRecords_withCaseStatusChange_returnsCaseStatusChange() {
		//ARRANGE
		Id caseId = '500RR00000Ly4ZaYAJ';
		List<Case> cases = new List<Case>();
		Case c = new Case();
		c.Status = 'Testing changed';
		c.Id = caseId;
		cases.add(c);
	
		Map<Id, Case> oldCaseMap = new Map<Id, Case>();
		oldCaseMap.put('500RR00000Ly4ZaYAJ', new Case(Status = 'Testing', Id = caseId));
	
		Mock caseSelectorMock = Mock.forType(CaseSelector.class);
		MethodSpy getCurrentCaseChangeStatus = caseSelectorMock.spyOn('getCurrentCaseChangeStatus');
		getCurrentCaseChangeStatus.whenCalledWith(Argument.any())
			.thenReturn(
				new List<Case_Status_Change__c>{
					new Case_Status_Change__c(Case__c = caseId, Set_Time__c = Datetime.now())
				}
			);
	
		CaseService caseService = new CaseService((CaseSelector) caseSelectorMock.stub);
	
		//ACT
		List<Case_Status_Change__c> caseStatusChanges = caseService.getCurrentCaseStatusChangeRecords(
			new Map<Id, Case>(cases),
			oldCaseMap
		);
	
		//ASSERT
		Assert.isFalse(caseStatusChanges.isEmpty(), 'The list is empty');
		Assert.isNotNull(caseStatusChanges.get(0).Change_Time__c, 'The change_Time__c was set.');
	}

    /*
    TODO TALK WITH SERGIO TEST LIKE THIS!

    //APEX_DATA_ACCESS_RESTRICTION, In parallel Apex tests, DML operations aren't permitted on this type of object: User: []
    @IsTest
    public static void testAccessible1(){
        User u = getUser('Chatter Free User');

        System.runAs(u) { //APEX_DATA_ACCESS_RESTRICTION, In parallel Apex tests, DML operations aren't permitted on this type of object: User: []

            Boolean caught = false;
            try {
                CaseService caseService = new CaseService();
                caseService.hasPermissionToCaseStatusChange();
            }catch (DmlException ex) {
                caught = true;
            }

            System.assert(caught, 'We do not have case creation right');
        }
    }
    
    public static User getUser(String profileName) {
        Profile p = [SELECT Id FROM Profile WHERE Name=:profileName limit 1];
        
        String testemail = 'atest@test.demo';
        User pu = new User(profileId = p.Id, username = testemail, email = testemail, 
                           emailencodingkey = 'UTF-8', localesidkey = 'en_US', 
                           languagelocalekey = 'en_US', timezonesidkey = 'America/Los_Angeles', 
                           alias='cspu', lastname='lastname');
        
        return pu;
    }
    */
}