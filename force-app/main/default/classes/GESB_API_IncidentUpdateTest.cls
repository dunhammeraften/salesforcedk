@isTest
public class GESB_API_IncidentUpdateTest {
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
    
        OneWorkflow__c OW = new     OneWorkflow__c( Update_Type__c = 'Update',  Update_Status__c = 'Pending', Case__c = Case_record.Id,     
                                                    Title__c = 'Test',  Description__c='Test');
    
        insert OW;
    /*
        OneWorkflow__c OW2 = new     OneWorkflow__c( Update_Type__c = 'Create',  Update_Status__c = 'New', Case__c = Case_record.Id,     
                                                    Title__c = 'Test2',  Description__c='Test');
    
        insert OW2;
    
         OneWorkflow__c OW2 = new     OneWorkflow__c( Update_Type__c = 'Assign',  Update_Status__c = 'Pending', Case__c = Case_record.Id,     
                                                    Title__c = 'Test',  Description__c='Test' , AssignReason__c = 'TestAssign');
    
        insert OW2;
    
       OneWorkflow__c OW3 = new     OneWorkflow__c( Update_Type__c = 'Closed',  Update_Status__c = 'Pending', Case__c = Case_record.Id,     
                                                 Title__c = 'Test',  Description__c='Test', ResolutionCode__c = 'Test', 
                                                Resolution__c = 'TestResolution');
    
        insert OW3;
    */
    ContentVersion content=new ContentVersion(); 
        content.Title='Header_Picture1'; 
        content.PathOnClient='/' + content.Title + '.jpg'; 
        Blob bodyBlob=Blob.valueOf('Unit Test ContentVersion Body'); 
        content.VersionData=bodyBlob; 
        //content.LinkedEntityId=sub.id;
        content.origin = 'H';
        insert content;

    
    /*
        ContentDocumentLink  ContentDocumentLink_record = new ContentDocumentLink(LinkedEntityId = OW.Id, ContentDocumentId = ContentVersion_record.ContentDocumentId);
        insert ContentDocumentLink_record;
    */
      FeedItem FeedItem_record = new FeedItem( Title = 'test', ParentId = OW.Id, Body='TestBody');
    insert FeedItem_record;
    
    ContentVersion ContentVersion_record = new ContentVersion(Title='Logo',PathOnClient='Logo.png',
                                                                  ContentDocumentId = [select contentdocumentid from contentversion where id =: content.id].contentdocumentid,
                                                                 VersionData=Blob.valueOf('iVBORw0KGgoAAAANSUhE'));
    insert ContentVersion_record;
    
    FeedAttachment FeedAttachment_record = new FeedAttachment(FeedEntityId = FeedItem_record.Id, Type = 'Content', recordId=ContentVersion_record.Id);
   insert  FeedAttachment_record;

   
}
    
    
@isTest static  void testGetCallout() {
        // Create the mock response based on a static resource
           // Associate the callout with a mock response
   
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('Company_API_DataFetchResource');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
    
        /*
        MultiStaticResourceCalloutMock multimock = new MultiStaticResourceCalloutMock();
        multimock.setStaticResource('https://6i3dd64wwg.execute-api.eu-west-1.amazonaws.com', 'Company_API_DataFetchResource');
        
        multimock.setStaticResource('https://api-garden-uat.teliacompany.com/oauth/client_credential/accesstoken?grant_type=client_credentials', 'Company_API_DataFetchResource');
        multimock.setStatusCode(200);
        multimock.setHeader('Content-Type', 'application/xml');
       */
    GESBCustomerOperationservice_xsd.CreateIncidentInboundType CreateIncidentInboundTypeRecord = new GESBCustomerOperationservice_xsd.CreateIncidentInboundType();                     
    CreateIncidentInboundTypeRecord.Action = 'Create';CreateIncidentInboundTypeRecord.Operation ='Assignment';
                CreateIncidentInboundTypeRecord.DestinationSystem = 'One Workflow';
                CreateIncidentInboundTypeRecord.InterfaceName = 'Salesforce Denmark';
                CreateIncidentInboundTypeRecord.RequestedByLoginID = 'Salesforce Denmark';
                CreateIncidentInboundTypeRecord.Source = 'Customer Care';
                CreateIncidentInboundTypeRecord.EventStartTime = Datetime.now().format('yyyy-MM-dd\'T\'HH:mm:ssXXX');
                CreateIncidentInboundTypeRecord.Title = 'VIP-';
    			CreateIncidentInboundTypeRecord.RequestType = 'Customer';
                CreateIncidentInboundTypeRecord.Description = 'OneWorkflow_record.Description__c' ; //From UI
                CreateIncidentInboundTypeRecord.TicketPriority = 'OneWorkflow_record.Priority__c'; //From UI
                CreateIncidentInboundTypeRecord.InterfaceTicketID = 'OneWorkflow_record.Name'; //From UI
                CreateIncidentInboundTypeRecord.Category = 'Customer Service';
                CreateIncidentInboundTypeRecord.Type_x= 'Mobile Services';
                CreateIncidentInboundTypeRecord.Technology = 'GSM';
                CreateIncidentInboundTypeRecord.Item = 'OneWorkflow_record.Type__c';//From UI
                CreateIncidentInboundTypeRecord.ContactPersonName= 'OneWorkflow_record.Case__r.Contact.Name';
                CreateIncidentInboundTypeRecord.ContactPersonPhoneNumber= 'OneWorkflow_record.Case__r.ContactPhone';
                CreateIncidentInboundTypeRecord.ContactPersonEmail= 'OneWorkflow_record.Case__r.ContactEmail';
                CreateIncidentInboundTypeRecord.CustomerName = 'OneWorkflow_record.Case__r.Account.Name'; 
                     
    
    
     list <id> Ids = new list<id>();   
     List<OneWorkflow__c> test_check=[select id,Title__c from OneWorkflow__c where Title__c = 'Test'];
        if(test_check.size()>0)
        {
            for(OneWorkflow__c test_checkrecord:test_check)
            {
                Ids.add(test_checkrecord.Id);
            }
        }
    
     list <id> SecondIds = new list<id>();   
     List<OneWorkflow__c> test_check2=[select id,Title__c from OneWorkflow__c where Title__c = 'Test2'];
        if(test_check2.size()>0)
        {
            for(OneWorkflow__c test_checkrecord2:test_check2)
            {
                SecondIds.add(test_checkrecord2.Id);
            }
        }
    
 
        //List<Id> Ids = new List<Id>();
        // List<Order_API_Product_class> ProductList = new Order_API_Product_class[]{}; 
system.debug('CHECKTEST');         
system.debug(Ids);
    
              
        GESB_API_IncidentUpdate.GESBUpdateIncident(Ids); 
    
          
     HttpResponse response = new HttpResponse();
    
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, mock);
        //HttpResponse response = getInfoFromExternalService();
        // Call method to test
       
        response.setBody('Mock response body');   
        response.setStatusCode(200);
        response.setStatus('Success');
    
        Test.stopTest();
   
    }

}