public class ContactDataMaskInSandbox implements Database.Batchable<sObject>,SandboxPostCopy {
  
    public void runApexClass(SandboxContext context) {
      Database.executeBatch(new ContactDataMaskInSandbox());
    } 
    
    public Database.QueryLocator start(Database.BatchableContext BC){ 
           String query='Select Id,FirstName,LastName,Phone,MobilePhone,Email from Contact';
          return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<Contact> contData){

        for(Contact con:contData){
            if (con.Phone != null){
             con.Phone= Label.Mask_Phone_number_in_Sandbox;   
            }
            if (con.MobilePhone != null){
                con.MobilePhone= Label.Mask_Phone_number_in_Sandbox;    
            }
            con.FirstName = RandomNameGenerator.firstName();
            con.LastName = RandomNameGenerator.lastName();
            if (con.Email != null){
                con.Email=con.FirstName.trim()+'.'+con.LastName.trim()+Label.Mask_Email_In_Sandbox;
            }
        }
        update contData;  
    }

    public void finish(Database.BatchableContext BC){
    }   
}