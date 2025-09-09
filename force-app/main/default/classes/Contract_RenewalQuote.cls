public class Contract_RenewalQuote implements Database.Batchable<sObject>{
    public List<Id> recordsId; 
   @InvocableMethod(label='Create renewal quotes from Contracts' description='Create renewal quotes from Contracts')
   public static list<id> Contract_RenewalQuote_Batch(list <id> recordId)
        {
            Contract_RenewalQuote ProcessBatch = new Contract_RenewalQuote();
            //ID batchprocessid = Database.executeBatch(ProcessBatch);
            String cronID = System.scheduleBatch(ProcessBatch, 'Creating renewal quotes '+ System.now(), 1,100); 
            return recordId;
        }
      
   public Database.querylocator start(Database.BatchableContext BC){
   
        String squery = 'select id from Contract where Renewal_Quote_Creation_date__c <= TODAY and SBQQ__RenewalQuoted__c = false  and SBQQ__RenewalForecast__c = true' ;
        
        return Database.getQueryLocator(squery);
    }
    
    
    public void execute(Database.BatchableContext BC, List<Contract> scope){
    List<Contract> ContractUpdateList = new List<Contract>();    
      try
        {
  
        for(Contract c : scope)
          { 
              c.SBQQ__RenewalQuoted__c = true;
              ContractUpdateList.add(c);
           }        
          if(ContractUpdateList.size()>0)
              { 
               	update ContractUpdateList;
              } 
        }
        catch(Exception e){
            System_Log__c  logerror = new System_Log__c (Origin__c  = 'Apex',Error_Body__c = e.getMessage() + 'Line:' + e.getLineNumber(),Additional_Information__c = 'Contract_RenewalQuote');
            insert logerror; 
        }  
    }
    
        
    public void finish(Database.BatchableContext BC){

    } 
    
       
}