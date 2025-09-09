@isTest
private class UploadToolTest {
    
    @isTest
    static void uploadLinesTest() {

        Activation__c a = new Activation__c();
        Activation_Line__c al = new Activation_Line__c();
        al.Activation__c = a.Id;
        String actId = a.Id;
        String jsonData = '[{"First_name__c":"Frederik","Last_name__c":"Test","Mobile_no__c":"55005500","Id":"' + al.Id + '"}]';

        UploadTool.uploadLines(jsonData, actId, true);
    }


}