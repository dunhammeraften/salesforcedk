/**
 * 
 * @author keh
 * @since 10032025
 */
@isTest
private class LineInquiryTest {

    private static final String TEST_CVR = '12345678';

    /**
     * setup
     */
    @testSetup
    static void setup(){
        Profile prof = ProfileSelector.getProfileByProfileName(ProfileConstants.SYSTEM_ADMINISTRATOR);
		User usr = testDataFactory.createUser('standt', prof.Id);

		Account acc = TDF_AccountUtils.createAccountWithCVR(TEST_CVR);
        acc.Status__c = 'Active';
		acc.OwnerId = usr.Id;
        insert acc;

        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opportunity';
        opp.StageName = 'Qualification';
        opp.CloseDate = Date.newInstance(2024, 12, 31);
        opp.AccountId = acc.Id;
        insert opp;
        
        Location_Line__c ll = new Location_Line__c();
        ll.Opportunity__c = opp.Id;
        ll.Street_Name__c = 'Risbystræde';
        ll.Number__c = '19';
        ll.ZIP_Code__c = '2620';
        ll.City__c = 'Albertslund';
        
        insert ll;
    }

    /**
     * 
     */
    @isTest
    static void theCall_correctWashCategory_returnsCorrectLocationLine() { 
        //ARRANGE
        Opportunity opp = [SELECT Id FROM Opportunity WHERE Name='Test Opportunity' LIMIT 1];
        Location_Line__c line = [SELECT Address__c FROM Location_Line__c WHERE Opportunity__c =: opp.Id limit 1];
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new LineInquiryCalloutMock());
        
        //ACT
        Location_Line__c res = LineInquiry.theCall(line);
        Test.stopTest();

        //ASSERT
        System.assertEquals('A', res.addressWash_Category__c, 'Address Wash Category does not match');        
    }

    /**
    * static void callDawa_setWash_onAllLines() { 
     */
    @isTest
    static void callDawa_setWash_onAllLines() { 
        //ARRANGE
        Opportunity opp = [SELECT Id FROM Opportunity WHERE Name='Test Opportunity' LIMIT 1];
        Location_Line__c line = [SELECT Address__c FROM Location_Line__c WHERE Opportunity__c =: opp.Id limit 1];
        List<Location_Line__c> innerList = new List<Location_Line__c>();
        innerList.add(line);
        List<List<Location_Line__c>> outerList = new List<List<Location_Line__c>>();
        outerList.add(innerList);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new LineInquiryCalloutMock());
        
        //ACT
        LineInquiry.callDawa(outerList);
        Test.stopTest();

        //ASSERT
        line = [SELECT Address__c, Address_Wash_Status__c FROM Location_Line__c WHERE Opportunity__c =: opp.Id limit 1];
        System.assertEquals('Valid', line.Address_Wash_Status__c);        
    }






}