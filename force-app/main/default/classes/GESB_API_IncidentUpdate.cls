public class GESB_API_IncidentUpdate {
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
    public static void GESB_Authentication_Update_Call(list <id> recordId)
    { 		
        integer fileLimit = 5;
        string fileNames = '';
        GESBCustomerOperationservice_xsd.UpdateIncidentInboundType UpdateIncidentInboundTypeRecord = new GESBCustomerOperationservice_xsd.UpdateIncidentInboundType();                     
        GESBCustomerOperationservice_xsd.AttachmentList_element AttachmentList = new GESBCustomerOperationservice_xsd.AttachmentList_element();   
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
            
            // Parse the JSON response          
            response = http.send(request);
      		if(response.getStatusCode() == 200){
               Map<String, Object> jsonMap =  (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
               if(jsonMap.containsKey('access_token')) {
                 accessToken = (String)jsonMap.get('access_token');
               }
            }
            system.debug('accessToken->>>'+accessToken); 
            
            list <OneWorkflow__c> OneWorkflow_list= [select id, Description__c, Title__c,Priority__c,ReasonForWithdrawal__c,
                                                         Case__r.Contact.Name, Case__r.ContactPhone, Case__r.ContactEmail,FaultPosition__c,
                                                         Case__r.IsEscalated, Case__r.Account.Name,Case__r.CaseNumber, Update_Type__c,
                                                         Resolution__c, ResolutionCode__c, AssignReason__c, TicketId__c, Name
                                                         from OneWorkflow__c where Id in:recordId ];
            if(OneWorkflow_list.size()>0)
            {
            	for(OneWorkflow__c OneWorkflow_record:OneWorkflow_list) 
                {   
                UpdateIncidentInboundTypeRecord.InterfaceName = 'Salesforce Denmark';
                UpdateIncidentInboundTypeRecord.ModifiedByLogin = 'Salesforce Denmark';
                UpdateIncidentInboundTypeRecord.InterfaceTicketID = OneWorkflow_record.Name; //From UI
                UpdateIncidentInboundTypeRecord.TicketID = OneWorkflow_record.TicketId__c;
                 
                List<FeedItem> FeedItem_list= [SELECT Id, Title FROM FeedItem WHERE ParentId  =:recordId and Title!='Uploaded to OW' and hascontent = true Order by CreatedDate desc LIMIT 1];
                FeedItem FeedItemRecord;
                if(FeedItem_list.size()>0)  //there is a feed item with attachments not closed
                { 
                    FeedItemRecord = FeedItem_list[0];
                    List<FeedAttachment> FeedAttachment_list= [SELECT RecordId FROM FeedAttachment WHERE FeedEntityId  =:FeedItemRecord.Id];
         			if(FeedAttachment_list.size()>0)
                      {  
                      	GESBCustomerOperationservice_xsd.Attachment_element[] AttachmentListElements = new List<GESBCustomerOperationservice_xsd.Attachment_element>();   
                        GESBCustomerOperationservice_xsd.Attachment_element AttachmentRecord= new GESBCustomerOperationservice_xsd.Attachment_element();                                
                       
                        //Loop through the attachments
                        for(FeedAttachment FeedAttachmentRecord: FeedAttachment_list)
                        {                      
                                List<ContentVersion> ContentVersion_list= [SELECT VersionData,FileExtension,FileType,Title,ContentDocumentId FROM ContentVersion WHERE Id =: FeedAttachmentRecord.RecordId ];                        
                                if(ContentVersion_list.size()>0 && fileLimit >0)
                                {
                                    AttachmentRecord.Filename = ContentVersion_list[0].Title + '.' + ContentVersion_list[0].FileExtension;
                                    AttachmentRecord.AttachmentData = EncodingUtil.base64Encode(ContentVersion_list[0].VersionData);   
                                    AttachmentListElements.add(AttachmentRecord);
                                    fileLimit = fileLimit-1;
                                    fileNames = AttachmentRecord.Filename + ', ' + fileNames;
                                } 
                            AttachmentRecord= new GESBCustomerOperationservice_xsd.Attachment_element();                                
                          }  //for   
                          AttachmentList.Attachment = AttachmentListElements; 
                       }   
                }    

                GESBCustomerOperationservice_xsd.Operation_element OperationRecord = new GESBCustomerOperationservice_xsd.Operation_element();
                UpdateIncidentInboundTypeRecord.Action = 'MODIFY';
                GESBCustomerOperationservice_xsd.UpdateInfo_element UpdateInfoRecord = new GESBCustomerOperationservice_xsd.UpdateInfo_element();
                UpdateInfoRecord.WorkNotes = OneWorkflow_record.Description__c ; //From UI
                UpdateInfoRecord.TicketPriority = OneWorkflow_record.Priority__c; //From UI
                UpdateInfoRecord.AttachmentList =  AttachmentList; 
                
                GESBCustomerOperationservice_xsd.Withdrawn_element WithdrawnRecord = new GESBCustomerOperationservice_xsd.Withdrawn_element();
                WithdrawnRecord.ReasonForWithdrawal = OneWorkflow_record.ReasonForWithdrawal__c;
                
                GESBCustomerOperationservice_xsd.Closed_element ClosedRecord = new GESBCustomerOperationservice_xsd.Closed_element();
                ClosedRecord.ResolutionCode = OneWorkflow_record.ResolutionCode__c;
                ClosedRecord.Resolution = OneWorkflow_record.Resolution__c;
                ClosedRecord.ActionCode = OneWorkflow_record.ResolutionCode__c;
                if(String.isEmpty(OneWorkflow_record.FaultPosition__c))
                   {
                        ClosedRecord.FaultPosition = 'Fault';
                   }
                else
                   {
                     	ClosedRecord.FaultPosition = OneWorkflow_record.FaultPosition__c;
                   } 
                
                 GESBCustomerOperationservice_xsd.Assign_element AssignRecord = new GESBCustomerOperationservice_xsd.Assign_element();
                 if(String.isEmpty(OneWorkflow_record.Description__c))
                 {
                     AssignRecord.AssignReason = OneWorkflow_record.AssignReason__c;
                 }
                 else
                 {
                     AssignRecord.AssignReason = OneWorkflow_record.Description__c.mid(0,254); 
                 }
                 AssignRecord.DestinationSystem = 'One Workflow';
                    
                switch on OneWorkflow_record.Update_Type__c {
                    when 'Update' {		
                        OperationRecord.UpdateInfo = UpdateInfoRecord;
                        OperationRecord.field_order_type_info = new String[]{'UpdateInfo'};
                        OperationRecord.Assign_type_info = null;
                        OperationRecord.Closed_type_info = null;
                        OperationRecord.Withdrawn_type_info = null;
                    }
                    when 'Withdrawn' {	
                        OperationRecord.Withdrawn = WithdrawnRecord;
                        OperationRecord.field_order_type_info = new String[]{'Withdrawn'};
                        OperationRecord.Assign_type_info = null;
                        OperationRecord.Closed_type_info = null;
                        OperationRecord.UpdateInfo_type_info = null;
                    }
                    when 'Closed' {	
                        OperationRecord.Closed = ClosedRecord;
                        OperationRecord.field_order_type_info = new String[]{'Closed'};
                        OperationRecord.Assign_type_info = null;
                        OperationRecord.Withdrawn_type_info = null;
                        OperationRecord.UpdateInfo_type_info = null;
                    }
                    when 'Assign' {	
                        OperationRecord.Assign = AssignRecord;
                        OperationRecord.field_order_type_info = new String[]{'Assign'};
                        OperationRecord.Closed_type_info = null;
                        OperationRecord.Withdrawn_type_info = null;
                        OperationRecord.UpdateInfo_type_info = null;
                    }
                } 
                
                UpdateIncidentInboundTypeRecord.Operation = OperationRecord;  
                GESBCustomerOperationserviceUpdate.PortTypeEndpoint1 TestCall = new GESBCustomerOperationserviceUpdate.PortTypeEndpoint1();                   
                TestCall.inputHttpHeaders_x = new Map<String, String>();
                TestCall.inputHttpHeaders_x.put('Authorization', 'Bearer ' + accessToken);
                TestCall.inputHttpHeaders_x.put('Content-Type', 'application/xml');
                TestCall.inputHttpHeaders_x.put('charset', 'UTF-8');
                
                GESBCustomerOperationservice_xsd.GESB_Response_element UpdateIncidentInboundTypeResponse = TestCall.UpdateIncidentOP(UpdateIncidentInboundTypeRecord);                       
                if(UpdateIncidentInboundTypeResponse.status == 'Success' ){
                   if(FeedItem_list.size()>0)
                   {    
                        FeedItem post = new FeedItem();
                        post.ParentId = OneWorkflow_record.Id;
                        post.Body = fileNames + 'have been sent to OW';
                        insert post;
                       
                       FeedItemRecord.Title = 'Uploaded to OW';
                       update FeedItemRecord;
                   }
                }
             }//for
            }
                
           }//try
           catch(Exception e){
               System.debug('### Error Occured while calling Http Client : ' + e.getMessage());
               sendErrorMail(e.getMessage(),GESB_APISettings.Exception_Email__c);  
          }
            
    }
    
    @InvocableMethod
    public static void GESBUpdateIncident(list <id> recordId)
    {
        GESB_Authentication_Update_Call(recordId);
    }
    

}