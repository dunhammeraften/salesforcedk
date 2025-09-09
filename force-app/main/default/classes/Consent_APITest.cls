@isTest
public class Consent_APITest {
    @isTest 
    static void TestStatus()
    {
        //TODO: keh fix unittest
        //sandboxes are running as system email only under deliverability.
        //can we change this to make this and the other email test work, without  risk of sending out to customers?
         Profile prof = [Select Id from Profile where name = 'System Administrator'];
         User u = new User(
            Alias = 'standt', 
            Email='standarduser@testorg.com',
            EmailEncodingKey='UTF-8', 
            LastName='Testing', 
            LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', 
            ProfileId = prof.Id,
            TimeZoneSidKey='America/Los_Angeles',
            UserName='standard_user@testorg.com', 
            Dealer_Code__c = 1111);

            system.runAs(u) {            
                
                Account acct = TDF_AccountUtils.creatActiveAccountWithCVRAndOwner();
                insert acct;
                
                Contact cont = new Contact(FirstName='Test', LastName='Contact',MobilePhone='12345678', Phone='12345',AccountId = acct.Id);
                insert cont;
                
                Billing_Account__c bAcc = TDF_BillingAccountUtils.CreateBillingAccount(acct);
                
                Fokus_Subscription__c Fokussubs = new Fokus_Subscription__c(
                    SUBSCRIBER_ID__c= 123456,
                    MOBILE_NO__C = cont.Phone,
                    SF_ACCOUNT_KEY__c = acct.Id,
                    EndDate__c = null,
                    Billing_Account__c = bAcc.Id
                 );
                insert Fokussubs; 
                
                DMC_Channel_Id__c  Channel_Settings = new DMC_Channel_Id__c();
   				Channel_Settings.E_Mail__c = '1234';
                Channel_Settings.Phone_call__c = '1234';
                Channel_Settings.Social_media__c = '1234';
                Channel_Settings.Text_message__c = '1234';
                Channel_Settings.Notifications__c = '1234';
                insert Channel_Settings;
                
                Consent_API_class testclass = new Consent_API_class();
                //Consent_API_class.ConsentResponse = new Consent_API_class.ConsentResponse();
                Consent_API_class.ConsentResponse testresponse = new Consent_API_class.ConsentResponse();
                testresponse.state = 'given';
                testresponse.consentId = '111';
                //testclass.ConsentResponse = testresponse;

                Test.startTest();
                Test.setMock(HttpCalloutMock.class, new Consent_API_CalloutMock());
                Consent_API.retrieveConsent(cont.Id);
                map<string,string> SubscriberResult = Consent_API.SubscriptionAPICall('123455','124');
                string testvalue = Consent_API.updateConsent(cont.Id,'123455','test@test.com','given','Phone');
                Test.setMock(HttpCalloutMock.class, new Subscription_API_CalloutMock());
                Consent_API.SubscriptionAPICall('123455','124');
                Consent_API.authenticateSubscriptionAPI();
                
                Integer callouts = Limits.getCallouts();
                Test.stopTest();  
        }
    } 
}