@isTest
public class Communication_API_SMSTest {
        private class Mock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            if (req.getEndpoint().endsWith('abc')) {
                HTTPResponse res = new HTTPResponse();
                res.setBody('{}');
                res.setStatusCode(200);
                return res;
            } else if (req.getEndpoint().endsWith('xyz')) {
                HTTPResponse res = new HTTPResponse();
                res.setBody('{}');
                res.setStatusCode(200);
                return res;
            } else {
                System.assert(false, 'unexpected endpoint ' + req.getEndpoint());
                return null;
            }
        }
    }
@isTest static void TestSMS()
    {
             
     Account acct = new Account(Name='TestAccount', BillingCity='CP',BillingPostalCode = '2000',BillingCountry = 'DK'
                                           ,BillingStreet = 'Holmbladsgade 133', Phone = '111', CVR__c ='12345678');
     insert acct;
        
    Case Case_record= NEW case(AccountId= acct.Id);  
        insert Case_record;
 
     ApexPages.StandardController controller2 = new ApexPages.StandardController(case_record);
        
        Communication_API_SMS testclass = new Communication_API_SMS(controller2);
        // Associate the callout with a mock response
		// Create the mock response based on a static resource
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('Communication_API_AuthResource');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
       
    	//Test.startTest();

        Test.setMock(HttpCalloutMock.class, mock);
                    
		Communication_API_SMS.sendSMS();
     
}    
}