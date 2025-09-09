public class Contract_RenewalOpportunity implements Database.Batchable<sObject>{
    public List<Id> recordsId; 
   @InvocableMethod(label='Create renewal opportunity from Contracts' description='Create renewal opportunity from Contracts')
   public static list<id> Contract_RenewalOpportunity_Batch(list <id> recordId)
        {
            Contract_RenewalOpportunity ProcessBatch = new Contract_RenewalOpportunity();
            //ID batchprocessid = Database.executeBatch(ProcessBatch);
            String cronID = System.scheduleBatch(ProcessBatch, 'Creating renewal opportunity '+ System.now(), 1,100); 
            return recordId;
        }
      
   public Database.querylocator start(Database.BatchableContext BC){
   
         String squery = 'select id from Contract where Renewal_Opportunity_Creation_Date__c <= TODAY and SBQQ__RenewalForecast__c = false and ' + 
         				 ' EndDate != null and EndDate <= NEXT_N_DAYS:365 and StartDate!= null and AccountId != null and ContractTerm != null and ' +
                         ' Status = \'Activated\' and Account.Status__c = \'Active\' and Contract_Type__c = \'Mobile\' ' ;

        return Database.getQueryLocator(squery);
    }
    
    
    public void execute(Database.BatchableContext BC, List<Contract> scope){
    List<Contract> ContractUpdateList = new List<Contract>();    
      try
        {
  
        for(Contract c : scope)
          { 
              c.SBQQ__RenewalForecast__c = true;
              ContractUpdateList.add(c);
           }        
          if(ContractUpdateList.size()>0)
              { 
               	update ContractUpdateList;
              } 
        }
        catch(Exception e){
            System_Log__c  logerror = new System_Log__c (Origin__c  = 'Apex',Error_Body__c = e.getMessage() + 'Line:' + e.getLineNumber(),Additional_Information__c = 'Contract_RenewalOpportunity');
            insert logerror; 
        }  
    }
    
        
    public void finish(Database.BatchableContext BC){

    } 
    
       
}