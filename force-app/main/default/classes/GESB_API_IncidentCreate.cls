public class GESB_API_IncidentCreate {
    public static String accessToken = '';
    public static APISettings__mdt GESB_APISettings;
    
    public static void sendErrorMail(String errorMessage, String emailAddress){              
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {emailAddress};
        mail.setToAddresses(toAddresses);  
        mail.setSenderDisplayName('Apex error message');
        mail.setSubject('GESB_API Error from Org : ' + UserInfo.getOrganizationName());
        mail.setPlainTextBody(errorMessage);
        if(!test.isRunningTest()){
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
        
	}
    
    @future(callout = true)       
    public static void GESB_Authentication_Create_Call(list <id> recordId)
    { 		
        integer fileLimit = 5;
        string fileNames = '';
        system.debug(recordId);
        GESBCustomerOperationservice_xsd.CreateIncidentInboundType CreateIncidentInboundTypeRecord = new GESBCustomerOperationservice_xsd.CreateIncidentInboundType();                     
        try
        {
            string APISettingforGESBAPI = 'GESB_APISettings'; 
            GESB_APISettings = [SELECT Id, API_EndPoint__c, API_ClientId__c, API_ClientSecret__c, API_PartialEndPoint__C, API_Environment__C,
            Exception_Email__c
            from APISettings__mdt where DeveloperName =:APISettingforGESBAPI LIMIT 1];
        
            Http http = new Http();
            HttpRequest request = new HttpRequest(); 
            String OS_HTTP_CALLOUT_TIMEOUT = '30000'; 
            request.setEndpoint(GESB_APISettings.API_EndPoint__c); 
            request.setMethod('POST'); 
            String clientId = GESB_APISettings.API_ClientId__c; 
            String clientSecret = GESB_APISettings.API_ClientSecret__c; 
        
            Blob headerValue = Blob.valueOf(clientId+':'+clientSecret);
            String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);            
            request.setHeader('Authorization' , authorizationHeader);           
            request.setCompressed(false);
            request.setHeader('Content-type', 'application/xml');
            request.setTimeout(Integer.valueOf(OS_HTTP_CALLOUT_TIMEOUT));
            request.setBody('grant_type' + '=' + 'client_credentials');
            system.debug('request--->>>>'+request);
            HttpResponse response;
            
            // Parse the response          
            response = http.send(request);
      		if(response.getStatusCode() == 200){
               Map<String, Object> jsonMap =  (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
               if(jsonMap.containsKey('access_token')) {
                 accessToken = (String)jsonMap.get('access_token');
               }
            }
            system.debug('accessToken->>>'+accessToken); 
            
            list <OneWorkflow__c> OneWorkflow_list= [SELECT id, Description__c, Title__c,Priority__c, Type__c, Name,
                                                         Case__r.Contact.Name, Case__r.ContactPhone, Case__r.ContactEmail,
                                                         Case__r.IsEscalated, Case__r.Account.Name,Case__r.CaseNumber, Update_Type__c
                                                         from OneWorkflow__c where Id in:recordId ];
            if(OneWorkflow_list.size()>0)
            {
            	OneWorkflow__c OneWorkflow_record = OneWorkflow_list[0];                    
                
                CreateIncidentInboundTypeRecord.Action = 'Create';CreateIncidentInboundTypeRecord.Operation ='Assignment';
                CreateIncidentInboundTypeRecord.DestinationSystem = 'One Workflow';
                CreateIncidentInboundTypeRecord.InterfaceName = 'Salesforce Denmark';
                CreateIncidentInboundTypeRecord.RequestedByLoginID = 'Salesforce Denmark';
                CreateIncidentInboundTypeRecord.Source = 'Customer Care';
                CreateIncidentInboundTypeRecord.EventStartTime = Datetime.now().format('yyyy-MM-dd\'T\'HH:mm:ssXXX');
                CreateIncidentInboundTypeRecord.Title = 'VIP-' + OneWorkflow_record.Case__r.Account.Name + '-' + OneWorkflow_record.Title__c;
                CreateIncidentInboundTypeRecord.RequestType = 'Customer';
                CreateIncidentInboundTypeRecord.Description = OneWorkflow_record.Description__c ; //From UI
                CreateIncidentInboundTypeRecord.TicketPriority = OneWorkflow_record.Priority__c; //From UI
                CreateIncidentInboundTypeRecord.InterfaceTicketID = OneWorkflow_record.Name; //From UI
                CreateIncidentInboundTypeRecord.Category = 'Customer Service';
                CreateIncidentInboundTypeRecord.Type_x= 'Mobile Services';
                CreateIncidentInboundTypeRecord.Technology = 'GSM';
                CreateIncidentInboundTypeRecord.Item = OneWorkflow_record.Type__c;//From UI
                CreateIncidentInboundTypeRecord.ContactPersonName= OneWorkflow_record.Case__r.Contact.Name;
                CreateIncidentInboundTypeRecord.ContactPersonPhoneNumber= OneWorkflow_record.Case__r.ContactPhone;
                CreateIncidentInboundTypeRecord.ContactPersonEmail= OneWorkflow_record.Case__r.ContactEmail;
                CreateIncidentInboundTypeRecord.CustomerName = OneWorkflow_record.Case__r.Account.Name; 
                    
                if (OneWorkflow_record.Case__r.IsEscalated == true) {
               		CreateIncidentInboundTypeRecord.CustomerEscalatedFlag= 'Yes';
                   }
                   else{
                   	CreateIncidentInboundTypeRecord.CustomerEscalatedFlag= 'No';
                   }
                
                List<ContentDocumentLink> ContentDocumentLink_list= [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId  =:recordId ORDER BY SystemModstamp];
                    
                //Loop through the attachments
                if(ContentDocumentLink_list.size()>0)
                {
                     GESBCustomerOperationservice_xsd.AttachmentList_element AttachmentList = new GESBCustomerOperationservice_xsd.AttachmentList_element();   
                     GESBCustomerOperationservice_xsd.Attachment_element[] AttachmentListElements = new List<GESBCustomerOperationservice_xsd.Attachment_element>();   
                     GESBCustomerOperationservice_xsd.Attachment_element AttachmentRecord= new GESBCustomerOperationservice_xsd.Attachment_element();                                
                          
                     for(ContentDocumentLink CDocumentLink: ContentDocumentLink_list)
                     {                      
                     	List<ContentVersion> ContentVersion_list= [SELECT VersionData,FileExtension,FileType,Title,ContentDocumentId FROM ContentVersion WHERE ContentDocumentId =: CDocumentLink.ContentDocumentId ];                        
                        if(ContentVersion_list.size()>0 && fileLimit >0)
                        {
                        	 AttachmentRecord.Filename = ContentVersion_list[0].Title + '.' + ContentVersion_list[0].FileExtension;
                             AttachmentRecord.AttachmentData = EncodingUtil.base64Encode(ContentVersion_list[0].VersionData);   
                             AttachmentListElements.add(AttachmentRecord);
                             fileLimit = fileLimit-1;
                             fileNames = AttachmentRecord.Filename + ', ' + fileNames;
                        }    
                      }
                      AttachmentList.Attachment = AttachmentListElements;  
                      CreateIncidentInboundTypeRecord.AttachmentList  = AttachmentList;
				}  
                system.debug(CreateIncidentInboundTypeRecord);
                     
                GESBCustomerOperationservice.PortTypeEndpoint1 TestCall = new GESBCustomerOperationservice.PortTypeEndpoint1();                   
                TestCall.inputHttpHeaders_x = new Map<String, String>();
                TestCall.inputHttpHeaders_x.put('Authorization', 'Bearer ' + accessToken);
                TestCall.inputHttpHeaders_x.put('Content-Type', 'application/xml');
                TestCall.inputHttpHeaders_x.put('charset', 'UTF-8');
                GESBCustomerOperationservice_xsd.GESB_Response_element CreateIncidentInboundTypeResponse = TestCall.CreateIncidentOP(CreateIncidentInboundTypeRecord);                       
                system.debug(CreateIncidentInboundTypeResponse);  
                
                if(CreateIncidentInboundTypeResponse.status == 'Success' ){
                   if(filelimit<5)
                   {    
                        FeedItem post = new FeedItem();
                        post.ParentId = OneWorkflow_record.Id;
                        post.Body = fileNames + 'have been sent to OW';
                        insert post;
                   }
                }
            }
                
           }//try
           catch(Exception e){
               System.debug('### Error Occured while calling Http Client : ' + e.getMessage());
               sendErrorMail(e.getMessage(),GESB_APISettings.Exception_Email__c);  
          }
            
    }  

    @InvocableMethod 
    public static void GESBCreateIncident(list <id> recordId)
    {
        GESB_Authentication_Create_Call(recordId);
    }
    
   
}