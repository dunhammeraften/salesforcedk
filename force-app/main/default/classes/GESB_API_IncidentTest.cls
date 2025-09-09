@isTest
public class GESB_API_IncidentTest {
    public static HttpResponse getInfoFromExternalService() {
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://api-garden');
        req.setMethod('GET');
        Http h = new Http();
        HttpResponse res = h.send(req);
        return res;
    }
    private class Mock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            if (req.getEndpoint().startsWith('https://api-garden')) {
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
@testSetup    
public static void CreateRecords()
{
            Account acct = new Account(Name='TestAccount787878', BillingCity='CP',BillingPostalCode = '2000',BillingCountry = 'DK'
                                           ,BillingStreet = 'Holmbladsgade 133', Phone = '111', CVR__c ='23568978');
     insert acct;
    
         Case Case_record= NEW case(AccountId= acct.Id);  
        insert Case_record;
    
        OneWorkflow__c OW = new     OneWorkflow__c( Update_Type__c = 'Create',  Update_Status__c = 'New', Case__c = Case_record.Id,     
                                                    Title__c = 'Test',  Description__c='Test');
    
        insert OW;
  
    ContentVersion content=new ContentVersion(); 
        content.Title='Header_Picture1'; 
        content.PathOnClient='/' + content.Title + '.jpg'; 
        Blob bodyBlob=Blob.valueOf('Unit Test ContentVersion Body'); 
        content.VersionData=bodyBlob; 
        //content.LinkedEntityId=sub.id;
        content.origin = 'H';
        insert content;
       
    
      ContentVersion ContentVersion_record = new ContentVersion(Title='Logo',PathOnClient='Logo.png',
                                                                  ContentDocumentId = [select contentdocumentid from contentversion where id =: content.id].contentdocumentid,
                                                                 VersionData=Blob.valueOf('iVBORw0KGgoAAAANSUhE'));
      insert ContentVersion_record;
    
        //ContentDocumentLink  ContentDocumentLink_record = new ContentDocumentLink(LinkedEntityId = OW.Id, ContentDocumentId = ContentVersion_record.ContentDocumentId);
        //insert ContentDocumentLink_record;
    
}
    
    
@isTest static  void testGetCallout() {
        // Create the mock response based on a static resource
           // Associate the callout with a mock response
   
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('Company_API_DataFetchResource');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
    
                
     OneWorkflow__c test_check=[select id,Title__c from OneWorkflow__c where Title__c = 'Test'];
     system.debug(test_check.Id);
    
        //List<Id> Ids = new List<Id>();
        // List<Order_API_Product_class> ProductList = new Order_API_Product_class[]{};  
    list <id> Ids = new list<id>();
        Ids.add(test_check.Id);
    
        GESB_API_IncidentCreate.GESBCreateIncident(Ids); 
    
        GESBCustomerOperationservice.PortTypeEndpoint1 TestCall = new GESBCustomerOperationservice.PortTypeEndpoint1();                   
        TestCall.inputHttpHeaders_x = new Map<String, String>();
        TestCall.inputHttpHeaders_x.put('Content-Type', 'application/xml');
        TestCall.inputHttpHeaders_x.put('charset', 'UTF-8');
        GESBCustomerOperationservice_xsd.UpdateIncidentInboundType UpdateIncidentInboundTypeRecord = new GESBCustomerOperationservice_xsd.UpdateIncidentInboundType();                                  
        GESBCustomerOperationservice_xsd.GESB_Response_element UpdateIncidentInboundTypeResponse;
    
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, mock);
        //HttpResponse response = getInfoFromExternalService();
        // Call method to test
        HttpResponse response = new HttpResponse();
        response.setBody('Mock response body');   
        response.setStatusCode(200);
        Test.stopTest();
   
    }

}