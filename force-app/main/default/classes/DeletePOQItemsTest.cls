/**
 * 
 * @author keh
 * @since 13032025
 */
@isTest
private class DeletePOQItemsTest {
    private static final String TEST_CVR = '12345678';

    /**
     * setup method
     *  - create user
     *  - create account
     *  - create opportunity
     *  - create location line
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
        ll.Street_Name__c = 'Risbystræde';
        ll.Number__c = '19';
        ll.ZIP_Code__c = '2620';
        ll.City__c = 'Albertslund';
        ll.Opportunity__c = opp.Id;
        insert ll;
        

        POQ_Item__c pi = new POQ_Item__c();
        pi.Name = 'Test POQ Item';
        pi.Location_Line__c = ll.Id;
        insert pi;
    }

    /**
     * deleteItems_locationWithItems_deletesAllItems
     */
    @isTest 
    static void deleteItems_locationWithItems_deletesAllItems() {
        //ARRANGE
        Location_Line__c ll = [SELECT Id, Street_Name__c, Number__c, ZIP_Code__c, City__c FROM Location_Line__c WHERE Street_Name__c = 'Risbystræde'];
        List<Location_Line__c> list1 = new List<Location_Line__c>();
        list1.add(ll);
        List<List<Location_Line__c>> list2 = new List<List<Location_Line__c>>();
        list2.add(list1);

        //ACT
        DeletePOQItems.deleteItems(list2);

        //ASSERT
        ll = [SELECT Id, Street_Name__c, Number__c, ZIP_Code__c, City__c FROM Location_Line__c WHERE Street_Name__c = 'Risbystræde'];
        List<POQ_Item__c> POQ_Items = [SELECT Id FROM POQ_Item__c WHERE Location_Line__c = :ll.Id];
        
        System.Assert(POQ_Items.size() == 0);
    }
}