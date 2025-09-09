@isTest
private class ActivationLineServiceTest {

    @isTest
    static void createActivationLineTest() {
 
        List<Activation_line__c> triggerNew = new List<Activation_line__c>{
            new Activation_line__c(
                TOP_Activation_Flow_Step__c = 'FINISHED',
                TOP_Completed_Flows__c = 'Voice_Flow',
                Fastnet_user__c = true,
                VAS_UC_License__c = '12345'
            )
        };
 
        DatabaseService db = new DatabaseService().mockDMLs();
 
        ActivationLineService activationLineService = new ActivationLineService(db);
 
        Test.startTest();
            activationLineService.createActivationLine(triggerNew);
        Test.stopTest();
 
        System.assertEquals('12345', triggerNew[0].VAS_UC_License__c, 'We call insert on the Voice flow activation line provided in the list');
    }

    @isTest
    static void handleAfterUpdateTest() {

        List<Activation_line__c > triggerNew = new List<Activation_line__c>{new Activation_line__c(
            TOP_Activation_Flow_Step__c = 'FINISHED', 
            TOP_Completed_Flows__c = 'Voice_Flow', 
            Fastnet_user__c = true, 
            VAS_UC_License__c = '12345')};

        List<Activation_line__c > triggerOld = new List<Activation_line__c>{new Activation_line__c(
            TOP_Activation_Flow_Step__c = 'STARTED', 
            TOP_Completed_Flows__c = 'None', 
            Fastnet_user__c = true, 
            VAS_UC_License__c = '12345')};
 
        ActivationLineService activationLineService = new ActivationLineService();

        Test.startTest();
            activationLineService.hasCompletedVoiceFlow(triggerNew, triggerOld);
        Test.stopTest();

        System.assertEquals('FINISHED', triggerNew[0].TOP_Activation_Flow_Step__c, 'We call insert on the Voice flow activation line provided in the list');
    }
}