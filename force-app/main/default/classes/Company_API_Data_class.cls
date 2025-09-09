public class Company_API_Data_class {
    public String name {get;set;}   //TELIA DANMARK
    public String cvr {get;set;}    //20367997
    public String industryCode {get;set;}   //619000
    public String industryDescription {get;set;}    //Anden telekommunikation
    public String secondaryNace {get;set;}  //474200
    public String secondaryNaceDescription {get;set;}   //Detailhandel med telekommunikationsudstyr
    public String tertiaryNace {get;set;}   //612000
    public String tertiaryNaceDescription {get;set;}    //Trådløs telekommunikation
    public String fourthNace {get;set;} //474200
    public String fourthNaceDescription {get;set;}  //Engroshandel med andre maskiner og andet udstyr
    public String status {get;set;} //NORMAL
    public String advertisingProtection {get;set;}  //false    
    public cls_contactDetails contactDetails {get;set;}
    public cls_companyType companyType {get;set;}
    public cls_address address {get;set;}
    public String employeeCount {get;set;}
    public cls_employeeCount  annualEmployeeCount{get;set;}
    public cls_employeeCount  quaterlyEmployeeCount{get;set;}
    public cls_employeeCount  monthlyEmployeeCount{get;set;}
    public String tscId {get;set;}  //DK12A
    public String creationDate {get;set;}   //2019-11-18T22:38:34+0000  
    public String updateDate {get;set;} //2019-11-18T22:38:34+0000  
    
    public class cls_contactDetails {
        public String phone {get;set;}  //82337000
    }
    
    public class cls_companyType {
        public String code {get;set;}   //170
        public String shortDescription {get;set;}   //FAS
        public String longDescription {get;set;}    //Filial af udenlandsk aktieselskab, kommanditakties
    }
    
     public class cls_address{
        public String streetName {get;set;} //Holmbladsgade
        public String streetCode {get;set;} //2984
        public String zip {get;set;}    //2300
        public String city {get;set;}   //København S
        public String country {get;set;}    //Denmark
        public String houseNumberFrom {get;set;}    //139 
        public String houseLetterFrom {get;set;}    
        public String floor {get;set;} //2
        public String doorNo {get;set;} //tv
        public String addressLine1 {get;set;} //"Prinsessegade 82, 2. tv."
    }
    
    public class cls_employeeCount{
        public string Ito;
        public string Ifrom;
    }
    
    public static Company_API_Data_class parse(String json){
        return (Company_API_Data_class) System.JSON.deserialize(json, Company_API_Data_class.class);
    }
}