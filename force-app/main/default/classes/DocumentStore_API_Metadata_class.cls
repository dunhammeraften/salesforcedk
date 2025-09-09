public class DocumentStore_API_Metadata_class {
    public String brand {get;set;}   //teliadk
    public String cvr {get;set;}
    public String documentType{get;set;}   //EMAIL
    public String documentName{get;set;} //Email_Subject
    public String fileName{get;set;}   //Email_Subject
    public String fileMimeType{get;set;} //text/html
    public String internal{get;set;}  //false
    public cls_additionalAttributes additionalAttributes{get;set;}
    public class cls_additionalAttributes {
        public cls_email email{get;set;}
    }
    public class cls_email {
        public String subject{get;set;}
		public cls_recipients recipients{get;set;}
		public List<cls_attachments> attachments{get;set;}
    }
    public class cls_attachments {
        public String documentStoreDocumentId{get;set;}
    }
    public class cls_recipients {
        public List<String> to{get;set;}
		public List<String> cc{get;set;}
		public List<String> bcc{get;set;}
    }
    
}