public class Consent_API_class {

public class ConsentResponse{
  public String state  {get;set;}
  public String consentId  {get;set;}
}
    
public class ConsentUpdate{
  public String state  {get;set;}
  public String consentId  {get;set;}
  public salesAgent salesAgent {get;set;}
  public changeDetails changeDetails {get;set;}
} 
    
public class changeDetails {
  //public String changeDate  {get;set;}  
  public String systemId  {get;set;}
  public channels[] channels {get;set;}
} 
    
public class channels{
  public String id  {get;set;}
} 
    
public class salesAgent   {
  public String externalId   {get;set;}
  public String type    {get;set;}
}     
    
}