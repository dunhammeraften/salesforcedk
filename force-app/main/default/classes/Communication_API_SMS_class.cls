public class Communication_API_SMS_class {
    public String brandId {get;set;}   //teliadk 
    public cls_message message {get;set;}
    public List<cls_externalReferences> externalReferences {get;set;}
    
     public class cls_message {
        public String type {get;set;}  //SMS
        public cls_content content {get;set;}  //content of the sms text
        public String senderName {get;set;}  //Telia
        public String telephoneNumber {get;set;}  //+4512345678
        public String taskName {get;set;}   //case subject
    }
    
    public class cls_content {
        public String text {get;set;}  //Hello World
    }
    
    public class cls_externalReferences {
        public String referenceType {get;set;}  //SALESFORCE_CASE_NUMBER
        public String referenceValue {get;set;}  //00001685
    }
  
}