@RestResource(urlMapping='/Case/*')
global class RPA_API_SendMail {
    
//public string EmailId = '02s1w00000129xEAAQ'; //02s1w0000015R1KAAU fulldev
//public string EmailType = 'Forward';
//public string EmailHtmlBody = '<html>test email body</html>';
public static  blob attachmentBody;
public static string attachmentFileName;
public static string attachmentFileExtension;

    global class MyEmailSendClass { 
        global String EmailId;
        global String EmailType;
        global String ForwardEmail;
        private String EmailHtmlBody;
        global transient String transientString;
    }

@HttpPost    
global static void SendEmail(string EmailId, string EmailType, string EmailHtmlBody, string ForwardEmail)
{   
    RestResponse res = RestContext.response;
         
try
   {     
        if (res == null) {
            res = new RestResponse();
            RestContext.response = res;
        }
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

        // TODO we should eventually use OrgUtils class and the method getCompanySettingsConfigurationValueByDeveloperName
        OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'kundeservice.erhverv@norlys.dk'];

        //OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'support-enterprise@teliacompany.com'];
        
        if (owea.size() > 0) 
        {
            mail.setOrgWideEmailAddressId(owea.get(0).Id);
        }
            
        List<EmailMessage> email_record =[Select id,ParentId,subject,FromName,FromAddress,TextBody,HtmlBody from EmailMessage where id =:EmailId];
        
       
        if(email_record.size()<=0)
        {
            res.responseBody = Blob.valueOf('Email can not be found with the Id value:' + EmailId);
            res.statusCode = 400;
            return;
        } 
        EmailMessage email = email_record[0];
        
        List<Case> case_record = [Select id,	case_reference__c from case where id =:email.ParentId];
       
        if(case_record.size()<=0)
        {
            res.responseBody = Blob.valueOf('Case can not be found with the Parent Id value from the Email:' + EmailId);
            res.statusCode = 400;
            return;
        }    
       
        String[] toAddresses = new String[] {email.FromAddress};
        String[] ForwardAddresses = new String[] {ForwardEmail};
        mail.setWhatId(email.ParentId);
        mail.setHtmlBody(EmailHtmlBody + '<html><br><br><br><b>Original Message:</b><font color="#FFFFFF">'+case_record[0].case_reference__c+'</font><br><br></html>'+ email.HtmlBody );
        mail.setToAddresses(toAddresses);
            
        if (EmailType == 'Forward')
        {
            mail.setSubject('Fw: ' + email.subject);
            mail.setToAddresses(ForwardAddresses);
            List<ContentDocumentLink> ContentDocumentLink_list= [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId  =:email.Id];
        
            //Loop through the attachments
            if(ContentDocumentLink_list.size()>0)
            {
                List<Messaging.EmailFileAttachment> attachments = new List<Messaging.EmailFileAttachment>();     
                for(ContentDocumentLink CDocumentLink: ContentDocumentLink_list)
                {
                    List<ContentVersion> ContentVersion_list= [SELECT VersionData,FileExtension,FileType,Title FROM ContentVersion WHERE ContentDocumentId =: CDocumentLink.ContentDocumentId ];
                    if(ContentVersion_list.size()>0)
                    {
                        attachmentBody = ContentVersion_list[0].VersionData;
                        attachmentFileName = ContentVersion_list[0].Title + '.' + ContentVersion_list[0].FileExtension;
                        attachmentFileExtension = ContentVersion_list[0].FileExtension;
                    
                        Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
                        efa.setFileName(attachmentFileName);
                        efa.setBody(attachmentBody);
                        efa.setContentType(DocumentStore_API_Static.fileMimeTypeConversion(attachmentFileExtension));
                        attachments.add(efa);	     
                    } 
                } 
                mail.setFileAttachments(attachments);   
            } 
        }
        else
        {
            mail.setSubject('Re: ' + email.subject);
        }
         
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        res.responseBody = Blob.valueOf('Email Message Sent');
       
   }//try
    catch(Exception e){
       System.debug('### Error Occured while calling Http Client : ' + e.getMessage());
       res.responseBody = Blob.valueOf(
                    String.valueOf(e) + '\n\n' + e.getStackTraceString()
                    );
       res.statusCode = 500; 
   }
}
}