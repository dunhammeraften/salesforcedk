public without sharing class Communication_API_SMS {
public final String recordId {get; set;}
public static string messageText {get; set;}
public static string theHiddenInput {get; set;}
public static string mobileNumbers {get; set;}
public static string hiddenCaseId {get; set;}
private static Case caserecord;
    
public static void LogSMS(string commentText, string AccountId, string CaseId)
{
        //Create a completed task under Account
    List<Task> taskList = new List<Task>();
    Task tsk = new Task();
    tsk.Subject = 'Bulk SMS has been sent';
    tsk.Status = 'Completed';
    tsk.Priority = 'Normal';    
    tsk.Description = commentText;
    tsk.WhatId = AccountId;
    tsk.OwnerId = UserInfo.getUserId();
    tsk.ActivityDate = date.today();    
    taskList.add(tsk);
    insert taskList;
        
    //insert chatter
    FeedItem post = new FeedItem();
    post.ParentId = CaseId;
    post.Body = commentText;
    insert post;  
        
}    

public Communication_API_SMS(ApexPages.StandardController controller) 
{
    recordId = controller.getRecord().Id;
    system.debug(recordId);
    messageText = '';
    mobileNumbers = '';
    theHiddenInput = '';
    hiddenCaseId = recordId;
} 

public static void sendErrorMail(String errorMessage, String emailAddress){              
    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
    String[] toAddresses = new String[] {emailAddress};
    mail.setToAddresses(toAddresses);  
    mail.setSenderDisplayName('Apex error message');
    mail.setSubject('Communication_API Error from Org : ' + UserInfo.getOrganizationName());
    mail.setPlainTextBody(errorMessage);
    if(!test.isRunningTest()){
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
    
}

public static APISettings__mdt CommunicationAPISettings;
    
@future(callout = true)   
public static void sendSMS()
{    
    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM ,'SMS successfully initiated'));   
    system.debug(mobileNumbers);
    Case Case_record= [SELECT Id, CaseNumber, Subject, AccountId, Account.CVR__c  from Case where Id =:hiddenCaseId LIMIT 1];    
        
    string CaseId = Case_record.Id;
    string CaseNumber = Case_record.CaseNumber;
    string AccountId = Case_record.AccountId;
    string AccountCVR = Case_record.Account.CVR__c;
    string CaseSubject = Case_record.Subject;
         
    string APISettingforCommunicationAPI = 'CommunicationAPISettings';
             
    CommunicationAPISettings = [SELECT Id, API_EndPoint__c, API_ClientId__c, API_ClientSecret__c, API_PartialEndPoint__C, API_Environment__C,
                            brand__c,channel__c, dealerCode__c, directoryListing__c, erpTsProduct__c, Exception_Email__c,
                            materialId__c , NotificationRecipientsRole__c, tsfOffering__c, salesAgentCode__c   from APISettings__mdt where DeveloperName =:APISettingforCommunicationAPI LIMIT 1];
     
    Http http = new Http();
    HttpRequest request = new HttpRequest();
    String OS_HTTP_CALLOUT_TIMEOUT = '30000';
    request.setEndpoint(CommunicationAPISettings.API_EndPoint__c);
    request.setMethod('POST');
    String clientId = CommunicationAPISettings.API_ClientId__c;
    String clientSecret = CommunicationAPISettings.API_ClientSecret__c;
    Blob headerValue = Blob.valueOf(clientId+':'+clientSecret);
    String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
    request.setCompressed(false);
    request.setHeader('Authorization' , authorizationHeader);
    request.setHeader('Content-type', 'application/x-www-form-urlencoded');
    request.setTimeout(Integer.valueOf(OS_HTTP_CALLOUT_TIMEOUT));
    request.setBody('grant_type' + '=' + 'client_credentials');
    system.debug('request--->>>>'+request);
    HttpResponse response;
    // Parse the JSON response
    try{
        response = http.send(request);
        system.debug('response--->>>>'+response.getBody());
        String accessToken = '';

        if(response.getStatusCode() == 200){
           Map<String, Object> jsonMap =  (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
           if(jsonMap.containsKey('access_token')) {
               accessToken = (String)jsonMap.get('access_token');
           }
       }
        system.debug('accessToken->>>'+accessToken);
        
        string extension = CommunicationAPISettings.dealerCode__c;
        
        String[] mobileNumbersDetails;
        mobileNumbersDetails = mobileNumbers.split(',');
            
        Communication_API_SMS_class SMSmessage = new Communication_API_SMS_class();
        SMSmessage.brandId = CommunicationAPISettings.brand__c;
        
        Communication_API_SMS_class.cls_message message = new Communication_API_SMS_class.cls_message();  
        message.type= 'SMS';
        message.taskName = CaseSubject;  
        message.senderName = CommunicationAPISettings.channel__c;
        Communication_API_SMS_class.cls_content content= new Communication_API_SMS_class.cls_content();  
        content.text= messageText;
        message.content = content;
        
        List<Communication_API_SMS_class.cls_externalReferences> externalReferences = new List<Communication_API_SMS_class.cls_externalReferences>();
        
        Communication_API_SMS_class.cls_externalReferences caseNumberReference= new Communication_API_SMS_class.cls_externalReferences();  
        caseNumberReference.referenceType= CommunicationAPISettings.NotificationRecipientsRole__c;
        caseNumberReference.referenceValue= CaseNumber;
        externalReferences.add(caseNumberReference);
         
        SMSmessage.externalReferences = externalReferences;
        
        string body;
        string failedNumbers='';
        string resultText = '';
        string commentText = '';
        
        String endpoint = CommunicationAPISettings.API_PartialEndpoint__c + CommunicationAPISettings.API_Environment__c + '/communications';   
        // Call Test.startTest before performing callout
        // but after setting test data.
        String method = 'POST';
        HttpRequest httpReq = new HttpRequest();
        httpReq.setEndpoint(endpoint);
        httpReq.setMethod(method);
        httpReq.setHeader('Authorization', 'Bearer ' + accessToken);
        httpReq.setHeader('Content-type', 'application/json');
        httpReq.setHeader('x-application-id', '');
        System.debug(body);     
        httpReq.setTimeout(45000);
        httpReq.setHeader('brand',CommunicationAPISettings.brand__c);
        Long startTime = DateTime.now().getTime();
        Long finishTime = DateTime.now().getTime();
        integer SMSCount = 0;
        for(String singleMobile :mobileNumbersDetails)
        {
            system.debug(singleMobile);
            message.telephoneNumber = extension + singleMobile;
            SMSmessage.message = message   ;
            
            body =JSON.serialize(SMSmessage ,true);
            system.debug(JSON.serialize(SMSmessage ,true) );
            httpReq.setBody(body); 
            
            HttpResponse httpRes = new Http().send(httpReq);
            SMSCount ++; 
            System.debug('Response body: ' + httpRes.getBody());
            if(httpRes.getStatusCode() == 200 || httpRes.getStatusCode() == 201)
            {
                Map<String, Object> jsonMap =  (Map<String, Object>) JSON.deserializeUntyped(httpRes.getBody());
                Map<String, Object>  jsonMapData = (Map<String, Object>)jsonMap.get('data');
                if(jsonMapData.containsKey('id')) 
                {
                    System.debug( 'Communication Id: '+ (String)jsonMapData.get('id '));
                }
            }
            else
            {
                failedNumbers = failedNumbers  + ', ' +   message.telephoneNumber ;
            } 
        } 
    commentText = messageText + ' has been sent to ' + mobileNumbers ;        
    if(String.isNotEmpty(failedNumbers))
        {
            commentText = commentText + '. ' + failedNumbers + ' couldnt receive the text.' ;
        }
        
    LogSMS(commentText,AccountId, CaseId);
    
    //Call DocumentStore
    //DocumentStore_API_Static.SendFileForSMS(Blob.valueOf(commentText), CommunicationAPISettings.brand__c,  CommunicationAPISettings.directoryListing__c , AccountCVR); 
    
    //Clear the visualforce page    
    messageText = '';
    mobileNumbers = '';  
        
    }//try
    catch(Exception e){
       System.debug('### Error Occured while calling Http Client : ' + e.getMessage());
       sendErrorMail(e.getMessage(),CommunicationAPISettings.Exception_Email__c);  
    }
} //send SMS    
}