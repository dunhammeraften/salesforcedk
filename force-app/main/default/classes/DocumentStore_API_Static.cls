public class DocumentStore_API_Static {
public static String recordContentDocumentId ;
public static blob attachmentBody;
public static string attachmentFileName;
public static string attachmentFileExtension;
public static String attachmentId;
public static String CVR;
public static string emailhtmlBody;
public static String emailDocument;
public static String documentFileMimeType;
public static string APISettingforDocumentStoreAPI = 'DocumentStoreAPISettings';
public static String accessToken = '';     
    

    public static void sendErrorMail(String errorMessage, String emailAddress){              
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {emailAddress};
        mail.setToAddresses(toAddresses);  
        mail.setSenderDisplayName('Apex error message');
        mail.setSubject('DocumentStore_API Error from Org : ' + UserInfo.getOrganizationName());
        mail.setPlainTextBody(errorMessage);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
	}
    
public static String fileMimeTypeConversion(String fileExtension)
{
string fileMimeType;
switch on fileExtension
{
    when 'doc','docx' { fileMimeType = 'application/msword';}
    when 'pdf' { fileMimeType = 'application/pdf';}
    when 'rss' { fileMimeType = 'application/rss+xml';}
    when 'kml' { fileMimeType = 'application/vnd.google-earth.kml+xml';}
    when 'kmz' { fileMimeType = 'application/vnd.google-earth.kmz';}
    when 'xls', 'xlsx' { fileMimeType = 'application/vnd.ms-excel';}
    when 'pps', 'ppt', 'pptx' { fileMimeType = 'application/vnd.ms-powerpoint';}
    when 'odp' { fileMimeType = 'application/vnd.oasis.opendocument.presentation';}
    when 'ods' { fileMimeType = 'application/vnd.oasis.opendocument.spreadsheet';}
    when 'odt' { fileMimeType = 'application/vnd.oasis.opendocument.text';}
    when 'sxc' { fileMimeType = 'application/vnd.sun.xml.calc';}
    when 'sxw' { fileMimeType = 'application/vnd.sun.xml.writer';}
    when 'gzip' { fileMimeType = 'application/x-gzip';}
    when 'zip' { fileMimeType = 'application/zip';}
    when 'au', 'snd' { fileMimeType = 'audio/basic';}
    when 'flac' { fileMimeType = 'audio/flac';}
    when 'mid', 'rmi' { fileMimeType = 'audio/mid';}
    when 'm4a' { fileMimeType = 'audio/mp4';}
    when 'mp3' { fileMimeType = 'audio/mpeg';}
    when 'oga', 'ogg' { fileMimeType = 'audio/ogg';}
    when 'aif', 'aifc', 'aiff' { fileMimeType = 'audio/x-aiff';}
    when 'wav' { fileMimeType = 'audio/x-wav';}
    when 'gif' { fileMimeType = 'image/gif';}
    when 'jpeg', 'jpg', 'jpe' { fileMimeType = 'image/jpeg';}
    when 'png' { fileMimeType = 'image/png';}
    when 'tiff', 'tif' { fileMimeType = 'image/tiff';}
    when 'wbmp' { fileMimeType = 'image/vnd.wap.wbmp';}
    when 'bmp' { fileMimeType = 'image/x-ms-bmp';}
    when 'ics' { fileMimeType = 'text/calendar';}
    when 'csv' { fileMimeType = 'text/comma-separated-values';}
    when 'css' { fileMimeType = 'text/css';}
    when 'htm', 'html' { fileMimeType = 'text/html';}
    when 'asc', 'c', 'diff', 'log', 'patch', 'pot', 'text', 'txt' { fileMimeType = 'text/plain';}
    when 'vcf' { fileMimeType = 'text/x-vcard';}
    when 'mp4' { fileMimeType = 'video/mp4';}
    when 'mpeg', 'mpg', 'mpe' { fileMimeType = 'video/mpeg';}
    when 'ogv' { fileMimeType = 'video/ogg';}
    when 'qt', 'mov' { fileMimeType = 'video/quicktime';}
    when 'avi' { fileMimeType = 'video/x-msvideo';}
    when else {fileMimeType = 'text/plain'; }
    }
return fileMimeType;
}
 

public static DocumentStoreAPISettings__mdt DocumentStoreAPISettings; 
public static DocumentStoreAPISettings__mdt getAPISettings(String SettingsName)
{
    DocumentStoreAPISettings = [SELECT Id, API_EndPoint__c, API_ClientId__c, API_ClientSecret__c, API_PartialEndPoint__C, API_Environment__C,
                        brand__c, emailDocumentName__c, emailDocumentType__c, Host__c, attachmentDocumentType__c, applicationId__c, Exception_Email__c	
                        from DocumentStoreAPISettings__mdt where DeveloperName =:SettingsName LIMIT 1];
    return DocumentStoreAPISettings;
}

public static void SendFile(string temporaryPutFileUrl,blob fileBody, string fileMimeType  )
{
	   String method = 'PUT'; 
	   String fileId;
       DocumentStoreAPISettings = getAPISettings(APISettingforDocumentStoreAPI);
       HttpRequest httpReq = new HttpRequest(); 
       httpReq.setEndpoint(temporaryPutFileUrl); 
       httpReq.setMethod(method); 
	   //httpReq.setHeader('Host',DocumentStoreAPISettings.Host__c ); 
       httpReq.setHeader('Content-Type',fileMimeType  ); 
	   httpReq.setHeader('x-application-id', 'SalesforceDK');
       httpReq.setTimeout(45000); 
       httpReq.setBodyAsBlob(fileBody);   

       HttpResponse httpRes = new Http().send(httpReq); 
       System.debug('Response body Send File: ' + httpRes.getBody()); 

        if(httpRes.getStatusCode() == 200 || httpRes.getStatusCode() == 201){
                System.debug('File succesfully uploaded');
               }
        else
            {
            System.debug('Check errors');
            }
        }
 
public static string SendFileMetadata(blob fileBody, DocumentStore_API_Metadata_class fileMetadata, string accessToken )
{
       String fileId;     
       String fileTemporaryPutFileUrl; 
       DocumentStoreAPISettings = getAPISettings(APISettingforDocumentStoreAPI);
       String endpoint = DocumentStoreAPISettings.API_PartialEndpoint__c + DocumentStoreAPISettings.API_Environment__c + '/documents'; 
       String method = 'POST'; 
       HttpRequest httpReq = new HttpRequest(); 
       httpReq.setEndpoint(endpoint); 
       httpReq.setMethod(method); 
       httpReq.setHeader('Authorization', 'Bearer ' + accessToken); 
       httpReq.setHeader('Content-type', 'application/json'); 	   
	   httpReq.setHeader('x-application-id', 'SalesforceDK');
       httpReq.setHeader('Accept', 'application/json'); 
       httpReq.setTimeout(45000); 
       httpReq.setHeader('brand','teliadk');     
     
       string body =JSON.serialize(fileMetadata ,true);
	   httpReq.setBody(body);
       HttpResponse httpRes = new Http().send(httpReq);
	   System.debug('Response body: ' + httpRes.getBody());      

       if(httpRes.getStatusCode() == 200 || httpRes.getStatusCode() == 201){
 
           Map<String, Object> jsonMap =  (Map<String, Object>) JSON.deserializeUntyped(httpRes.getBody());
           Map<String, Object>  jsonMapData = (Map<String, Object>)jsonMap.get('data');
           if(jsonMapData.containsKey('temporaryPutFileUrl')) { 
               fileId= (String)jsonMapData.get('id');
               fileTemporaryPutFileUrl = (String)jsonMapData.get('temporaryPutFileUrl'); 
           } 
       }
	   //Send the file
         documentFileMimeType = fileMetadata.fileMimeType;
         SendFile(fileTemporaryPutFileUrl,fileBody,documentFileMimeType );
		 return fileId;

}
    
@future(callout = true) 
public static void DocumentStore_Call(Set<Id> Ids)
{      
string APISettingforDocumentStoreAPI = 'DocumentStoreAPISettings'; 
DocumentStoreAPISettings = getAPISettings(APISettingforDocumentStoreAPI);    
Http http = new Http();
HttpRequest request = new HttpRequest(); 
String OS_HTTP_CALLOUT_TIMEOUT = '30000'; 
request.setEndpoint(DocumentStoreAPISettings.API_EndPoint__c); 
request.setMethod('POST'); 
String clientId = DocumentStoreAPISettings.API_ClientId__c; 
String clientSecret = DocumentStoreAPISettings.API_ClientSecret__c; 
Blob headerValue = Blob.valueOf(clientId+':'+clientSecret); 
String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue); 
request.setCompressed(false); 
request.setHeader('Authorization' , authorizationHeader); 
request.setHeader('Content-type', 'application/x-www-form-urlencoded'); 
request.setTimeout(Integer.valueOf(OS_HTTP_CALLOUT_TIMEOUT)); 
request.setBody('grant_type' + '=' + 'client_credentials'); 
system.debug('request--->>>>'+request);

    try
    {         
	HttpResponse response; 
	// Parse the JSON response 
  	response = http.send(request); 
    system.debug('response--->>>>'+response.getBody());  

   if(response.getStatusCode() == 200){ 

       Map<String, Object> jsonMap =  (Map<String, Object>) JSON.deserializeUntyped(response.getBody()); 
       if(jsonMap.containsKey('access_token')) { 
           accessToken = (String)jsonMap.get('access_token');
       }
   } 
    system.debug('accessToken->>>'+accessToken);
 
    string JSONtemp;
    string emailBccAddress='';
    string emailCcAddress='';
    
    List<EmailMessage> EmailMessage_list = [SELECT ActivityId,BccAddress,CcAddress,CreatedDate,FirstOpenedDate,
                                            FromAddress,FromName,HasAttachment,Headers,MessageDate,MessageIdentifier,
                                            ReplyToEmailMessageId,Status,Subject,TextBody,ToAddress,ValidatedFromAddress,
                                            htmlBody, Parent.Account.CVR__c FROM EmailMessage Where Id in: Ids];
        
    for (EmailMessage EmailMessage_record: EmailMessage_list)
    {   
        CVR =  EmailMessage_record.Parent.Account.CVR__c ; 
        emailhtmlBody= EmailMessage_record.htmlBody ;
        emailDocument = '<html><br>From:' + EmailMessage_record.FromAddress  ;
        emailDocument = emailDocument + '<br>FromName:' + EmailMessage_record.FromName ;
        emailDocument = emailDocument + '<br>ToAddress:' + EmailMessage_record.ToAddress ;
       
        If (String.isNotEmpty(EmailMessage_record.BccAddress))
        {
           emailBccAddress = EmailMessage_record.BccAddress; 
        }
    
        emailDocument = emailDocument + '<br>BccAddress:' + emailBccAddress;
        If (String.isNotEmpty(EmailMessage_record.CcAddress))
            {
               emailCcAddress = EmailMessage_record.CcAddress; 
            }
    
        emailDocument = emailDocument + '<br>CcAddress:' + emailCcAddress;
        emailDocument = emailDocument + '<br>Subject:' + EmailMessage_record.Subject;
        emailDocument = emailDocument + '<br></html>';
        emailDocument = emailDocument + EmailMessage_record.htmlBody;
        
        system.debug(emailDocument );
    
        DocumentStore_API_Metadata_class documentMetadata = new DocumentStore_API_Metadata_class();
        documentMetadata.brand = DocumentStoreAPISettings.brand__c;
        documentMetadata.cvr= CVR;
        documentMetadata.documentType= DocumentStoreAPISettings.emailDocumentType__c;
        documentMetadata.documentName= 'Email';
        documentMetadata.fileName= EmailMessage_record.Subject.mid(0,EmailMessage_record.Subject.IndexOf('[')).deleteWhitespace() + '.html';
        documentMetadata.fileMimeType= 'text/html';
        documentMetadata.internal= 'false';           
        DocumentStore_API_Metadata_class.cls_additionalAttributes documentAdditionalAttributes = new DocumentStore_API_Metadata_class.cls_additionalAttributes();
        DocumentStore_API_Metadata_class.cls_email email = new DocumentStore_API_Metadata_class.cls_email();
        DocumentStore_API_Metadata_class.cls_recipients recipients = new DocumentStore_API_Metadata_class.cls_recipients();
        String[] ToAddress;
        String[] BccAddress;
        String[] CcAddress;
        ToAddress = String.valueOf(EmailMessage_record.ToAddress).split(';');
        BccAddress = String.valueOf(emailBccAddress).split(';');
        CcAddress = String.valueOf(emailCcAddress).split(';');
        
        List<String> toAddresses = new List<String>();
        List<String> bccAddresses = new List<String>();
        List<String> ccAddresses = new List<String>();
        
        for(integer i=0;i<ToAddress.size(); i++)
        {
          toAddresses.add(ToAddress[i].deleteWhitespace());    
        }
        recipients.to = toAddresses;
        
        for(integer i=0;i<BccAddress.size(); i++)
        {
            bccAddresses.add(BccAddress[i].deleteWhitespace());
        }
        recipients.bcc = bccAddresses;
        for(integer i=0;i<CcAddress.size(); i++)
        {
            ccAddresses.add(CcAddress[i].deleteWhitespace());
        }
        recipients.cc= ccAddresses;
        
        
        email.recipients = recipients;
        email.subject = EmailMessage_record.Subject;
        List<DocumentStore_API_Metadata_class.cls_attachments> emailattachments = new List<DocumentStore_API_Metadata_class.cls_attachments>();
        
        List<ContentDocumentLink> ContentDocumentLink_list= [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId  =:EmailMessage_record.Id];
        
        //Loop through the attachments
        if(ContentDocumentLink_list.size()>0)
        {
            for(ContentDocumentLink CDocumentLink: ContentDocumentLink_list)
            {
                List<ContentVersion> ContentVersion_list= [SELECT VersionData,FileExtension,FileType,Title FROM ContentVersion WHERE ContentDocumentId =: CDocumentLink.ContentDocumentId ];
                
                if(ContentVersion_list.size()>0)
                {
                    attachmentBody = ContentVersion_list[0].VersionData;
                    attachmentFileName = ContentVersion_list[0].Title + '.' + ContentVersion_list[0].FileExtension;
                    attachmentFileExtension = ContentVersion_list[0].FileExtension;
                
                    DocumentStore_API_Metadata_class attachmentMetadata = new DocumentStore_API_Metadata_class();
                    attachmentMetadata.brand = DocumentStoreAPISettings.brand__c;
                    attachmentMetadata.cvr= CVR;
                    attachmentMetadata.documentType= DocumentStoreAPISettings.attachmentDocumentType__c;
                    attachmentMetadata.documentName= ContentVersion_list[0].Title.deleteWhitespace();
                    attachmentMetadata.fileName= attachmentFileName;
                    attachmentMetadata.fileMimeType= fileMimeTypeConversion(attachmentFileExtension);
                    attachmentMetadata.internal= 'false';	
                    
                    attachmentId = SendFileMetadata(attachmentBody, attachmentMetadata, accessToken);
                    system.debug(attachmentId );
                    DocumentStore_API_Metadata_class.cls_attachments attachments = new DocumentStore_API_Metadata_class.cls_attachments();
                    
                    attachments.documentStoreDocumentId = attachmentId;
                    emailattachments.add(attachments);
                } 
            } 
        } //ContentDocumentLink_list.size
        
    //Send the emailDocument       
       email.attachments = emailattachments; 
       documentAdditionalAttributes.email = email;
       documentMetadata.additionalAttributes = documentAdditionalAttributes;
       system.debug(JSON.serialize(documentMetadata));
       
       string sentfileId = SendFileMetadata(Blob.valueOf(emailDocument) , documentMetadata, accessToken);    
       system.debug(sentfileId);
    }	//for loop of the email list  
        
    }//try
    catch(Exception e){
    System.debug('### Error Occured while calling Http Client : ' + e.getMessage());
    sendErrorMail(e.getMessage(),DocumentStoreAPISettings.Exception_Email__c);  
    }
}   
        
}