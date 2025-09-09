public with sharing class Consent_API {
	public final String recordId {get; set;}
    public static APISettings__mdt ConsentAPISettings;
    public static APISettings__mdt SubscriptionAPISettings;
    public static string SubscriptionId {get; set;} 
    public static string accessToken {get; set;} 
    
    public static void sendErrorMail(String errorMessage, String emailAddress){              
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {emailAddress};
        mail.setToAddresses(toAddresses);  
        mail.setSenderDisplayName('Apex error message');
        mail.setSubject('Consent_API Error from Org : ' + UserInfo.getOrganizationName());
        mail.setPlainTextBody(errorMessage);
        if(!test.isRunningTest()){
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
    }
    
    @AuraEnabled(Cacheable=false)
    public static string updateConsent(string recordId, string subscriptionId, string emailaddress, string state, string givenvia)
    {
        if(String.isBlank(accessToken))
        {
       		 accessToken = authenticateConsent();
        }
        
        ConsentAPISettings = [SELECT Id, API_EndPoint__c, API_ClientId__c, API_ClientSecret__c, API_PartialEndPoint__C, API_Environment__C,consentId__c ,
                        brand__c,channel__c,  Debug__c, NotificationRecipientsRole__c, tsfOffering__c, salesAgentCode__c,
                        Exception_Email__c, emailTemplate1__c, emailTemplate2__c from APISettings__mdt where DeveloperName = 'ConsentAPISettings' LIMIT 1];

        Contact Contact_record= [SELECT Id, AccountId, Phone,MobilePhone,Consent_given_via__c  from Contact where Id =:recordId LIMIT 1];    
              
        string resultText = '';
        string userId = UserInfo.getUserId();
        string dealerCode;
                                    
        
        DMC_Channel_Id__c  Channel_Settings = DMC_Channel_Id__c.getInstance() ;
    
        Consent_API_class.changeDetails changeDetails = new Consent_API_class.changeDetails();
        changeDetails.systemId = ConsentAPISettings.channel__c;
        changeDetails.channels = new Consent_API_class.channels[]{}; 
        Consent_API_class.channels channel = new Consent_API_class.channels();
        if(String.isNotBlank(Channel_Settings.E_Mail__c) && state == 'given')
        {
            channel = new Consent_API_class.channels();
        	channel.id = Channel_Settings.E_Mail__c;  
            changeDetails.channels.add(channel); 
        }
              
        if(String.isNotBlank(Channel_Settings.Notifications__c) && state == 'given')
        {
            channel = new Consent_API_class.channels();
        	channel.id = Channel_Settings.Notifications__c;  
            changeDetails.channels.add(channel); 
        } 
        
        if(String.isNotBlank(Channel_Settings.Phone_call__c) && state == 'given')
        {
            channel = new Consent_API_class.channels();
        	channel.id = Channel_Settings.Phone_call__c;  
            changeDetails.channels.add(channel); 
        } 
        
        if(String.isNotBlank(Channel_Settings.Social_media__c) && state == 'given')
        {
            channel = new Consent_API_class.channels();
        	channel.id = Channel_Settings.Social_media__c;  
            changeDetails.channels.add(channel); 
        }
         if(String.isNotBlank(Channel_Settings.Text_message__c) && state == 'given')
        {
            channel = new Consent_API_class.channels();
        	channel.id = Channel_Settings.Text_message__c;  
            changeDetails.channels.add(channel); 
        }
    
        
        datetime nowDatetime = DateTime.now();
        string ModifiedDate = nowDatetime.format('YYYY-MM-dd');
        //changeDetails.changeDate = ModifiedDate;
        
        List<Consent_API_class.ConsentUpdate> BulkconsentUpdate = new Consent_API_class.ConsentUpdate[]{};
        
        Consent_API_class.ConsentUpdate consentUpdate = new Consent_API_class.ConsentUpdate();
        consentUpdate.state = state;
        consentUpdate.consentId = ConsentAPISettings.consentId__c;
        consentUpdate.changeDetails = changeDetails;
        
        List<User> User_records = [SELECT Dealer_Code__c from User where Id=:userId]; 
        dealerCode = String.valueOf(User_records[0].Dealer_Code__c);
        consentUpdate.salesAgent = new Consent_API_class.salesAgent();
        Consent_API_class.salesAgent salesAgent = new Consent_API_class.salesAgent();
        if(!String.isBlank(dealerCode))
        {
            salesAgent.externalId = dealerCode;
        	salesAgent.type = 'DEALER_ADMIN';  
            consentUpdate.salesAgent = salesAgent; 
        }
        

        BulkconsentUpdate.add(consentUpdate);
        system.debug(JSON.serialize(BulkconsentUpdate,true));
       

        String method = 'PUT';
        string endPoint;
        string body;
        body =JSON.serialize(BulkconsentUpdate ,true);
        string consentId = ConsentAPISettings.consentId__c;
        string consentStatus;
        endPoint = ConsentAPISettings.API_PartialEndPoint__c + ConsentAPISettings.API_Environment__c  + '/customers/SUBSCRIPTION-ID/' + subscriptionId +'/consents';
        HttpRequest httpReq = new HttpRequest();
        httpReq.setEndpoint(endPoint);
        httpReq.setMethod(method);
        httpReq.setHeader('Authorization', 'Bearer ' + accessToken);
        httpReq.setHeader('Content-type', 'application/json');
		httpReq.setBody(body); 
   	    httpReq.setTimeout(45000);
		httpReq.setHeader('brand','teliadk');
       
        try
        {     
       		HttpResponse httpRes = new Http().send(httpReq);
           System.debug('Response body: ' + httpRes.getBody());
           resultText = resultText + '\n' + string.valueOf(httpRes.getBody());
           if(httpRes.getStatusCode() == 200 || httpRes.getStatusCode() == 201){
				resultText = 'Success';
               
                //Update contact with the value of ConsentVia 
                Contact UpdateContactwithConsent = new Contact();
                UpdateContactwithConsent.Id = Contact_record.Id;
                UpdateContactwithConsent.Consent_given_via__c = givenvia;
                update UpdateContactwithConsent;
               
                //insert chatter
                FeedItem post = new FeedItem();
                post.ParentId = recordId;
                post.Body = 'Consent status has been updated as: ' + state + ' via: ' + givenvia;
                insert post;  
               
                string templateId;
                string orgFromMail;

                String customerServiceEmailDeveloperName = 'Customer_Service_Email';
                String customerServiceEmail = OrgUtils.getCompanySettingsConfigurationValueByDeveloperName(customerServiceEmailDeveloperName);

                OrgWideEmailAddress[] owea = [SELECT Id FROM OrgWideEmailAddress WHERE Address = :customerServiceEmail];
                    
                if (owea.size() > 0) 
                    {
                        orgFromMail = owea.get(0).Id;
                    }
                    // TODO handle if not no owea is found
               
               	String[] toAddresses = new String[] {emailaddress};
                if(ConsentAPISettings.Debug__c)
       				 { 
                    	toAddresses = new String[] {ConsentAPISettings.Exception_Email__c};
                      } 
				FeedItem postEmail = new FeedItem();
                
                String noReplyMobilEmailDeveloperName = 'No_Reply_Mobil_Email';
                String noReplyMobilEmail = OrgUtils.getCompanySettingsConfigurationValueByDeveloperName(noReplyMobilEmailDeveloperName);
               
                if(state == 'given')
                 {    
                     templateId = ConsentAPISettings.emailTemplate1__c; 
                     Messaging.SingleEmailMessage mail = Messaging.renderStoredEmailTemplate(templateId,userId,recordId);               
                     mail.setOrgWideEmailAddressId(orgFromMail);
                     mail.setSaveAsActivity(false);
                     mail.setToAddresses(toAddresses);
                     mail.setReplyTo(noReplyMobilEmail) ;
                     Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                     
                    //insert chatter
                    postEmail.ParentId = recordId;
                    postEmail.Body = 'Consent given email has been sent to the customer email: ' + emailaddress;
                    insert postEmail;  
   				 }
               if(state == 'withdrawn')
                 {    
                     templateId = ConsentAPISettings.emailTemplate2__c; 
                     Messaging.SingleEmailMessage mail = Messaging.renderStoredEmailTemplate(templateId,userId,recordId);               
                     mail.setOrgWideEmailAddressId(orgFromMail);
                     mail.setSaveAsActivity(false);
                     mail.setToAddresses(toAddresses);
                     mail.setReplyTo(noReplyMobilEmail) ;
                     Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                     
                    //insert chatter
                    postEmail.ParentId = recordId;
                    postEmail.Body = 'Consent withdrawn email has been sent to the customer email: ' + emailaddress;
                    insert postEmail;  
   				 }
            }     
            
        }//try
        catch(Exception e){
            System.debug('### Error Occured while calling Http Client : ' + e.getMessage());
            resultText = e.getMessage();
            sendErrorMail(e.getMessage(),ConsentAPISettings.Exception_Email__c);  
        }
        return resultText;
    } //updateConsent   
    
    @AuraEnabled   
    public static map<string,string> retrieveConsent(string recordId)
    {    
        
        map<string,string> returnMap = new map<string,string>();
        returnMap.put('subscriptionId','');
        returnMap.put('emailaddress','');
       		 
        //Map will return subscriptionId,state and emailaddress from both ConsentAPI and SubscriptionAPI
        
        ConsentAPISettings = [SELECT Id, API_EndPoint__c, API_ClientId__c, API_ClientSecret__c, API_PartialEndPoint__C, API_Environment__C,consentId__c ,
                        brand__c,channel__c,  Debug__c, NotificationRecipientsRole__c, tsfOffering__c, salesAgentCode__c   from APISettings__mdt where DeveloperName = 'ConsentAPISettings' LIMIT 1];

        string ContactPhone = '';
        
        Contact Contact_record= [SELECT Id, AccountId, Phone,MobilePhone  from Contact where Id =:recordId LIMIT 1];    
 
        string emailAddress;
        if(String.isBlank(Contact_record.MobilePhone))
         {
             returnMap.put('subscriptionId','0');
             returnMap.put('state','');
             return returnMap;
         } 
        
        if(String.isBlank(accessToken))
        {
       		 accessToken = authenticateConsent();
        }
              
        ContactPhone = Contact_record.MobilePhone;
                
        map<string,string> SubscriberResult = SubscriptionAPICall(ContactPhone, accesstoken);
        if(SubscriberResult.get('status') != 'Success' || String.isBlank(SubscriberResult.get('subscriptionId')))
        {
            returnMap.put('subscriptionId','1');
            returnMap.put('state','');
            return returnMap;    
        }
        
        SubscriptionId = SubscriberResult.get('subscriptionId');
        emailAddress = SubscriberResult.get('emailaddress');
        String method = 'GET';
        string endPoint;
        string consentId = ConsentAPISettings.consentId__c;
        string consentStatus = '';
        endPoint = ConsentAPISettings.API_PartialEndPoint__c + ConsentAPISettings.API_Environment__c  + '/customers/SUBSCRIPTION-ID/' + SubscriptionId +'/consents';
        HttpRequest httpReq = new HttpRequest();
        httpReq.setEndpoint(endPoint);
        httpReq.setMethod(method);
        httpReq.setHeader('Authorization', 'Bearer ' + accessToken);
        httpReq.setHeader('Content-type', 'application/json');
        httpReq.setTimeout(45000);
        httpReq.setHeader('brand','teliadk');
        
        try{
            HttpResponse httpRes = new Http().send(httpReq);
            System.debug('Response body: ' + httpRes.getBody());
            
            if(httpRes.getStatusCode() <> 200)
            {
                consentStatus = httpRes.getStatus() + ' returned with status code:' + httpRes.getStatusCode() + ' from ' + ConsentAPISettings.API_EndPoint__c;
                returnMap.put('state',consentStatus);
                return returnMap;
            }
            else
            { 
                List<Consent_API_class.ConsentResponse> responseList =  (List<Consent_API_class.ConsentResponse>) JSON.deserialize(httpRes.getBody(),List<Consent_API_class.ConsentResponse>.class);
                for(Consent_API_class.ConsentResponse SFConsent: responseList)
                {
                    system.debug(consentId);
                    system.debug(SFConsent.consentId);
                    if(SFConsent.consentId == consentId)
                    {  
                        consentStatus = SFConsent.state;
                        break;
                    }
                } 
            } 
        }//try
        catch(Exception e){
            System.debug('### Error Occured while calling Http Client : ' + e.getMessage());
            sendErrorMail(e.getMessage(),ConsentAPISettings.Exception_Email__c);  
        }
        
        returnMap.put('subscriptionId',SubscriptionId);
        returnMap.put('emailaddress',emailAddress);
       	returnMap.put('state',consentStatus);
        return returnMap;
    } //retrieveConsent  
    
    @AuraEnabled
    public static string authenticateConsent()
    {    
        string accessToken = '';
        string APISettingforConsentAPI = 'ConsentAPISettings';
        
        ConsentAPISettings = [SELECT Id, API_EndPoint__c, API_ClientId__c, API_ClientSecret__c, API_PartialEndPoint__C, 
                              API_Environment__C,Exception_Email__c,channel__c,consentId__c, Debug__c
                              from APISettings__mdt where DeveloperName =:APISettingforConsentAPI LIMIT 1];
        
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        String OS_HTTP_CALLOUT_TIMEOUT = '30000';
        request.setEndpoint(ConsentAPISettings.API_EndPoint__c);
        request.setMethod('POST');
        String clientId = ConsentAPISettings.API_ClientId__c;
        String clientSecret = ConsentAPISettings.API_ClientSecret__c;
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
            
            if(response.getStatusCode() == 200){
                Map<String, Object> jsonMap =  (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                if(jsonMap.containsKey('access_token')) {
                    accessToken = (String)jsonMap.get('access_token');
                }
            }
            system.debug('accessToken->>>'+accessToken);
            
        }//try
        catch(Exception e){
            System.debug('### Error Occured while calling Http Client : ' + e.getMessage());
        }
        return accessToken;
    } //authenticateConsent   
    
    @AuraEnabled
    public static string authenticateSubscriptionAPI()
    {    
        string accessToken = '';
        string APISettingforSubscriptionAPI = 'SubscriptionAPISettings';
        
        SubscriptionAPISettings = [SELECT Id, API_EndPoint__c, API_ClientId__c, API_ClientSecret__c, API_PartialEndPoint__C, 
                              API_Environment__C,Exception_Email__c,channel__c,consentId__c, Debug__c
                              from APISettings__mdt where DeveloperName =:APISettingforSubscriptionAPI LIMIT 1];
        
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        String OS_HTTP_CALLOUT_TIMEOUT = '30000';
        request.setEndpoint(SubscriptionAPISettings.API_EndPoint__c);
        request.setMethod('POST');
        String clientId = SubscriptionAPISettings.API_ClientId__c;
        String clientSecret = SubscriptionAPISettings.API_ClientSecret__c;
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
            
            if(response.getStatusCode() == 200){
                Map<String, Object> jsonMap =  (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                if(jsonMap.containsKey('access_token')) {
                    accessToken = (String)jsonMap.get('access_token');
                }
            }
            system.debug('accessToken->>>'+accessToken);
            
        }//try
        catch(Exception e){
            System.debug('### Error Occured while calling Http Client : ' + e.getMessage());
            //sendErrorMail(e.getMessage(),SubscriptionAPISettings.Exception_Email__c);  
        }
        return accessToken;
    } //authenticateSubscriptionAPI  
 
    @AuraEnabled
    public static map<string,string> SubscriptionAPICall(string msisdn, string accesstoken)
    {    
        
        map<string,string> subscriptionDetails = new map<string,string>();
        //Map will contain subscriptionId,status and emailaddress
        integer subscriptionId;
        string subscriptionIdValue = '';
        string subscriberEmail ='';
        string APISettingforSubscriptionAPI = 'SubscriptionAPISettings';
        SubscriptionAPISettings = [SELECT Id, API_EndPoint__c, API_ClientId__c, API_ClientSecret__c, API_PartialEndPoint__C, 
                              API_Environment__C,Exception_Email__c,channel__c,consentId__c, Debug__c
                              from APISettings__mdt where DeveloperName =:APISettingforSubscriptionAPI LIMIT 1];
      
        if(SubscriptionAPISettings.Debug__c)
        {    
            accesstoken = authenticateSubscriptionAPI();
        }
        
        String OS_HTTP_CALLOUT_TIMEOUT = '30000';
        String method = 'GET';
        string endPoint;
        endPoint = SubscriptionAPISettings.API_PartialEndPoint__c + msisdn;
        HttpRequest httpReq = new HttpRequest();
        httpReq.setEndpoint(endPoint);
        httpReq.setMethod(method);
        httpReq.setHeader('Authorization', 'Bearer ' + accessToken);
        httpReq.setHeader('Content-type', 'application/json');
        httpReq.setTimeout(45000);
        httpReq.setHeader('brand','teliadk');
        
        try{
            HttpResponse httpRes = new Http().send(httpReq);
            System.debug('Response body: ' + httpRes.getBody());
            
            if(httpRes.getStatusCode() <> 200)
            {
                subscriptionDetails.put('status',httpRes.getStatus() + ' returned with status code:' + httpRes.getStatusCode() + ' from ' + SubscriptionAPISettings.API_EndPoint__c);
                subscriptionDetails.put('subscriptionId','');
                subscriptionDetails.put('emailaddress','');
                return subscriptionDetails;
            }
            else
            { 
               Map<String, Object> jsonMap =  (Map<String, Object>) JSON.deserializeUntyped(httpRes.getBody());
                
               system.debug(jsonMap);
               List<Object>  jsonMapData = (List<Object>)jsonMap.get('data');
               if(jsonMapData.size()>0) 
               {   
                   Map<String, Object>  jsonMapDataRecord = (Map<String, Object>)jsonMapData[0];
                   system.debug(jsonMapDataRecord);
                   if(jsonMapDataRecord.containsKey('id')) {
                       subscriptionId = (Integer)jsonMapDataRecord.get('id');
                       subscriptionIdValue = String.valueOf(subscriptionId);
                       Map<String, Object>  jsonMapProductRecord = (Map<String, Object>)jsonMapDataRecord.get('productUser');
                       if(jsonMapProductRecord.containsKey('email'))
                       {
                          subscriberEmail = (String)jsonMapProductRecord.get('email'); 
                       }
                   }  
               } 
   			}
            
        }//try
        catch(Exception e){
            System.debug('### Error Occured while calling Http Client : ' + e.getMessage());
            sendErrorMail(e.getMessage(),SubscriptionAPISettings.Exception_Email__c);  
        }
        subscriptionDetails.put('status','Success');
        subscriptionDetails.put('subscriptionId',subscriptionIdValue);
        subscriptionDetails.put('emailaddress',subscriberEmail);
        return subscriptionDetails;
    } //subscriptionAPI   
   
}