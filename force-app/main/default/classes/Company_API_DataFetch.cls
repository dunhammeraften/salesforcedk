public with sharing class Company_API_DataFetch {
    
    public class ErrorObject{
        public ErrorDetails error;
    } 
    
    public class  ErrorDetails{
        public string code;
        public string message;
    }
    
    public class DataObject{
        public string offset;
        public string pageSize;
        public string totalCount;
        public Company_API_Data_class[] data;
    }    
    
    public static void sendErrorMail(String errorMessage, String emailAddress){
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {emailAddress};
		mail.setToAddresses(toAddresses);  
        mail.setSenderDisplayName('Apex error message');
        mail.setSubject('Company_API_DataFetch Error from Org : ' + UserInfo.getOrganizationName());
        mail.setPlainTextBody(errorMessage);
        if(!Test.isRunningTest()){
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
    }  
    
     //@InvocableMethod
    @future(callout = true)
    public static void FetchData(Set<Id> Ids)
    {
        List<Account> Accounts = [Select Id,CVR__c, BillingCity, BillingState, BillingCountry, BillingStreet, BillingPostalCode from Account Where Id in: Ids];
        system.debug('Accounts Queried: '+Accounts);
        
        Map<String, Account> accountMap = new Map<String, Account>();
        String CVRNumbers = ''; 
        for (Account acc: Accounts){
            CVRNumbers = CVRNumbers +','+acc.CVR__c;
            accountMap.put(acc.CVR__c, acc);
        }
        
        List<Account> AccountsToUpdate = new List <Account>(); //Use this account to clone the list obtained from logic below    
        
        APISettings__mdt CompanyAPISettings = [SELECT Id, API_EndPoint__c, API_ClientId__c, API_ClientSecret__c, API_PartialEndPoint__C,API_Environment__c, Exception_Email__c from APISettings__mdt where DeveloperName =:'CompanyAPISettings' LIMIT 1];
        
        // Parse the JSON response
        try{
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint(CompanyAPISettings.API_EndPoint__c);
            request.setMethod('POST');
            Blob headerValue = Blob.valueOf(CompanyAPISettings.API_ClientId__c+':'+CompanyAPISettings.API_ClientSecret__c);
            String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
            request.setCompressed(false);
            request.setHeader('Authorization' , authorizationHeader);
            request.setHeader('Content-type', 'application/x-www-form-urlencoded');
            request.setTimeout(30000);
            request.setBody('grant_type' + '=' + 'client_credentials');
            HttpResponse response = http.send(request);
            String accessToken = '';
            if(response.getStatusCode() == 200){
                Map<String, Object> jsonMap =  (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                if(jsonMap.containsKey('access_token')) {
                    accessToken = (String)jsonMap.get('access_token');
                }
            }
            system.debug('accessToken->>>'+accessToken);
            
            //Comma separated string of CVR Numbers to be used here 
            String endpoint = CompanyAPISettings.API_PartialEndpoint__c +  CompanyAPISettings.API_Environment__c + '/companies?cvr=' + CVRNumbers;   
            
            HttpRequest httpReq = new HttpRequest();
            httpReq.setEndpoint(endpoint);
            httpReq.setMethod('GET');
            httpReq.setHeader('Authorization', 'Bearer ' + accessToken);
            httpReq.setHeader('Content-type', 'application/json');
            httpReq.setHeader('brand','teliadk');
            httpReq.setTimeout(45000);
            HttpResponse httpRes = new Http().send(httpReq);
            System.debug('Response body: ' + httpRes.getBody());
            string resultText;
            
            if(httpRes.getStatusCode() <> 200)
            {
                resultText = httpRes.getStatus() + ' returned with status code:' + httpRes.getStatusCode() + ' from ' + endpoint;
                System.debug(resultText);
            }
            
            if(httpRes.getStatusCode() == 200)
            {
                ErrorObject JsonError = (ErrorObject)JSON.deserialize(HttpRes.getBody(), ErrorObject.class);
                if(JsonError.error!= null )
                {
                    resultText = httpRes.getStatus() + ' returned with description:' + (String)JsonError.error.message + ' from ' + endpoint;
                    System.debug(resultText);
                }
                
                String jsonString = HttpRes.getBody();
                jsonString = jsonString.replace('"to":', '"Ito":');
                jsonString = jsonString.replace('"from":', '"Ifrom":');
                DataObject JsonData = (DataObject)JSON.deserialize(jsonString, DataObject.class);
                system.debug('List from CompanyAPI'+JsonData.data);
                
                Account tempAcc;
                
                if(JsonData.data.size()>0) //Parse the result
                {
                    for(Company_API_Data_class companyData: JsonData.data)
                    {
                        Account acc = accountMap.get(companyData.cvr);
                        tempAcc = new Account();
                        tempAcc.Id= acc.Id;
                        tempAcc.AccountSource = 'CVR';
                        tempAcc.name = companyData.name;
                        tempAcc.Nace_Code__c = companyData.industryCode;
                        tempAcc.Nace_Description__c = companyData.industryDescription;
                        tempAcc.CVR_Status__c = companyData.status;
                        tempAcc.CVR_Refresh_Date__c = System.today();
                        
                        if(companyData.contactDetails != null){tempAcc.phone = companyData.contactDetails.phone;}
                        if(companyData.address.city!=Null){tempAcc.BillingCity = companyData.address.city;}
                        if(companyData.address.streetName!=Null){tempAcc.Billing_Street_Name__c = companyData.address.streetName;}
                        if(companyData.address.floor!=Null){tempAcc.Billing_Floor_Number__c = companyData.address.floor;}
                        if(companyData.address.doorNo!=Null){tempAcc.Billing_Door_Number__c = companyData.address.doorNo;}
                        if(companyData.address.houseLetterFrom!=Null){tempAcc.Billing_Street_Number_Suffix__c = companyData.address.houseLetterFrom;}
                        if(companyData.address.houseNumberFrom!=Null){tempAcc.Billing_Street_Number__c = companyData.address.houseNumberFrom;}
                        if(companyData.address.addressLine1!=Null){tempAcc.BillingStreet = companyData.address.addressLine1;}
                        if(companyData.address.zip!=Null){tempAcc.BillingPostalCode = companyData.address.zip;}
                        if(companyData.address.country!=Null){tempAcc.BillingCountry = companyData.address.country;}
                        if(companyData.employeeCount != null) {tempAcc.NumberOfEmployees = Integer.valueOf(companyData.employeeCount);}
                        if(companyData.advertisingProtection!=null) {tempAcc.Marketing_Opt_Out_CVR__c = boolean.valueOf(companyData.advertisingProtection);}
                        
                        if(companyData.monthlyEmployeeCount != null)
                        {
                            tempAcc.Employee_Number_Range__c = companyData.monthlyEmployeeCount.Ifrom + '-' + companyData.monthlyEmployeeCount.Ito;
                        }
                        else if (companyData.quaterlyEmployeeCount  != null)
                        {
                            tempAcc.Employee_Number_Range__c = companyData.quaterlyEmployeeCount.Ifrom + '-' + companyData.quaterlyEmployeeCount.Ito;
                        }
                        else if (companyData.annualEmployeeCount  != null)
                        {
                            tempAcc.Employee_Number_Range__c = companyData.annualEmployeeCount.Ifrom + '-' + companyData.annualEmployeeCount.Ito;
                        }
                        
                        if(companyData.companyType != null)
                        {
                            tempAcc.CVR_Company_Code__c = companyData.companyType.code; 
                            tempAcc.CVR_Short_Description__c = companyData.companyType.shortDescription; 
                            tempAcc.CVR_Long_Description__c = companyData.companyType.longDescription; 
                        }
                        
                        AccountsToUpdate.add(tempAcc);
                    }
                } 
                update AccountsToUpdate;  
                System.debug('Successfully updated');
            } //If StatusCode = 200
        }
        catch(Exception e){
            System.debug('### Error Occured while calling Http Client : ' + e.getMessage());
            sendErrorMail(e.getMessage(),CompanyAPISettings.Exception_Email__c);  
        }
    }
    

    
    @future(callout = true)
    public static void FetchLeadData(Set<Id> Ids)
    {
        List<Lead> Leads = [Select Id,CVR__c  from Lead Where Id in: Ids];
        
        Map<String, Lead> leadMap = new Map<String, Lead>();
        String CVRNumbers = ''; 
        for (Lead ld: Leads){
            CVRNumbers = CVRNumbers +','+ld.CVR__c;
            leadMap.put(ld.CVR__c, ld);
        }
        
        List<Lead> LeadsToUpdate = new List <Lead>();
        APISettings__mdt CompanyAPISettings = [SELECT Id, API_EndPoint__c, API_ClientId__c, API_ClientSecret__c, API_PartialEndPoint__C,API_Environment__c, Exception_Email__c from APISettings__mdt where DeveloperName =:'CompanyAPISettings' LIMIT 1];
         
        // Parse the JSON response
        try{
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint(CompanyAPISettings.API_EndPoint__c);
            request.setMethod('POST');
            Blob headerValue = Blob.valueOf(CompanyAPISettings.API_ClientId__c+':'+CompanyAPISettings.API_ClientSecret__c);
            String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
            request.setCompressed(false);
            request.setHeader('Authorization' , authorizationHeader);
            request.setHeader('Content-type', 'application/x-www-form-urlencoded');
            request.setTimeout(30000);
            request.setBody('grant_type' + '=' + 'client_credentials');
            HttpResponse response = http.send(request);
            String accessToken = '';
            if(response.getStatusCode() == 200){
                Map<String, Object> jsonMap =  (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                if(jsonMap.containsKey('access_token')) {
                    accessToken = (String)jsonMap.get('access_token');
                }
            }
            system.debug('accessToken->>>'+accessToken);
            
            //Comma separated string of CVR Numbers to be used here 
            String endpoint = CompanyAPISettings.API_PartialEndpoint__c +  CompanyAPISettings.API_Environment__c + '/companies?cvr=' + CVRNumbers;   
            
            HttpRequest httpReq = new HttpRequest();
            httpReq.setEndpoint(endpoint);
            httpReq.setMethod('GET');
            httpReq.setHeader('Authorization', 'Bearer ' + accessToken);
            httpReq.setHeader('Content-type', 'application/json');
            httpReq.setHeader('brand','teliadk');
            httpReq.setTimeout(45000);
            HttpResponse httpRes = new Http().send(httpReq);
            System.debug('Response body: ' + httpRes.getBody());
            string resultText;
            
            if(httpRes.getStatusCode() <> 200)
            {
                resultText = httpRes.getStatus() + ' returned with status code:' + httpRes.getStatusCode() + ' from ' + endpoint;
                System.debug(resultText);
            }
            
            if(httpRes.getStatusCode() == 200)
            {
                ErrorObject JsonError = (ErrorObject)JSON.deserialize(HttpRes.getBody(), ErrorObject.class);
                if(JsonError.error!= null )
                {
                    resultText = httpRes.getStatus() + ' returned with description:' + (String)JsonError.error.message + ' from ' + endpoint;
                    System.debug(resultText);
                }
                
                String jsonString = HttpRes.getBody();
                jsonString = jsonString.replace('"to":', '"Ito":');
                jsonString = jsonString.replace('"from":', '"Ifrom":');
                DataObject JsonData = (DataObject)JSON.deserialize(jsonString, DataObject.class);
                system.debug('List from CompanyAPI'+JsonData.data);
                
                Lead tempLd;
                
                if(JsonData.data.size()>0) //Parse the result
                {
                	for(Company_API_Data_class companyData: JsonData.data)
                        {
                            tempLd = new Lead();
                            lead ld = leadMap.get(companyData.cvr);
                            tempLd.Id= ld.Id;
                            tempLd.Company = companyData.name;
                            tempLd.Nace_Code__c = companyData.industryCode;
                            tempLd.Nace_Description__c = companyData.industryDescription;
                            tempLd.CVR_Status__c = companyData.status;
                            tempLd.CVR_Refresh_Date__c = System.today();
                            
                            if(companyData.contactDetails != null){tempLd.phone = companyData.contactDetails.phone;}
                            if(companyData.address.city!=Null){tempLd.City = companyData.address.city;}
                            if(companyData.address.streetName!=Null){tempLd.Billing_Street_Name__c = companyData.address.streetName;}
                            if(companyData.address.floor!=Null){tempLd.Billing_Floor_Number__c = companyData.address.floor;}
                            if(companyData.address.doorNo!=Null){tempLd.Billing_Door_Number__c = companyData.address.doorNo;}
                            if(companyData.address.houseLetterFrom!=Null){tempLd.Billing_Street_Number_Suffix__c = companyData.address.houseLetterFrom;}
                            if(companyData.address.houseNumberFrom!=Null){tempLd.Billing_Street_Number__c = companyData.address.houseNumberFrom;}
                            if(companyData.address.addressLine1!=Null){tempLd.Street = companyData.address.addressLine1;}
                            if(companyData.address.zip!=Null){tempLd.PostalCode = companyData.address.zip;}
                            if(companyData.address.country!=Null){tempLd.Country = companyData.address.country;}
                            if(companyData.employeeCount != null) {tempLd.NumberOfEmployees = Integer.valueOf(companyData.employeeCount);}
                            if(companyData.advertisingProtection!=null) {tempLd.Marketing_Opt_Out_CVR__c = boolean.valueOf(companyData.advertisingProtection);}
                            
                            if(companyData.monthlyEmployeeCount != null)
                            {
                                tempLd.Employee_Number_Range__c = companyData.monthlyEmployeeCount.Ifrom + '-' + companyData.monthlyEmployeeCount.Ito;
                            }
                            else if (companyData.quaterlyEmployeeCount  != null)
                            {
                                tempLd.Employee_Number_Range__c = companyData.quaterlyEmployeeCount.Ifrom + '-' + companyData.quaterlyEmployeeCount.Ito;
                            }
                            else if (companyData.annualEmployeeCount  != null)
                            {
                                tempLd.Employee_Number_Range__c = companyData.annualEmployeeCount.Ifrom + '-' + companyData.annualEmployeeCount.Ito;
                            }
                            
                            if(companyData.companyType != null)
                            {
                                tempLd.CVR_Company_Code__c = companyData.companyType.code; 
                                tempLd.CVR_Short_Description__c = companyData.companyType.shortDescription; 
                                tempLd.CVR_Long_Description__c = companyData.companyType.longDescription; 
                            }
                            
                            LeadsToUpdate.add(tempLd);
                        }
                        update LeadsToUpdate; 
                  }
                System.debug('Successfully updated');
                
                //run the dml rules
                Database.DMLOptions dmo = new Database.DMLOptions();
                dmo.assignmentRuleHeader.useDefaultRule = true;         
                for (Lead l:Leads) {
                    // use leadAssignment rules when updating
                    l.setOptions(dmo);
                }
                update(Leads);
  
            } //If StatusCode = 200
        }
        catch(Exception e){
            System.debug('### Error Occured while calling Http Client : ' + e.getMessage());
            sendErrorMail(e.getMessage(),CompanyAPISettings.Exception_Email__c);  
        }
    }
}