public class Subscription_Line_Detail_Update implements Database.Batchable<sObject>{
    public String query;    
    public Database.querylocator start(Database.BatchableContext BC){
        return Database.getQueryLocator('Select Id,CreatedDate, Subscription__c, Quantity__c  ' +
                                        'from Subscription_Line_Detail__c where CreatedDate >=TODAY OR ' +
                                        ' (LastModifiedDate >=TODAY AND  TerminatedDate__c != null)');
    }
    
    public void execute(Database.BatchableContext BC, List<Subscription_Line_Detail__c> scope){

    map<String,Integer> SubscriptionUpdates = new Map <String,Integer>(); //SubscriberId,Quantity
    integer quantity;
    string subscriptionId;
    string subscriptiondetailId; 
    string contractid;
    try
     {
        system.debug('Start');
        for(Subscription_Line_Detail__c s : scope)
      	{ 
          if(s.CreatedDate >=System.today()) //new insert
          { 
              if(SubscriptionUpdates.get(s.Subscription__c)!=null)
               {   
                   quantity = SubscriptionUpdates.get(s.Subscription__c);
                   SubscriptionUpdates.put(s.Subscription__c, quantity + (s.Quantity__c == null ? 1 : Integer.valueOf(s.Quantity__c)));
               }
              else
               {   
                   system.debug('Missing');
                   SubscriptionUpdates.put(s.Subscription__c, (s.Quantity__c == null ? 1 : Integer.valueOf(s.Quantity__c)));
               }   
          }
          else //Delete
          {  
              if(SubscriptionUpdates.get(s.Subscription__c)!=null)
               {   
                   quantity = SubscriptionUpdates.get(s.Subscription__c);
                   SubscriptionUpdates.put(s.Subscription__c, quantity - Integer.valueOf(s.Quantity__c));
               }
              else
               {   
                   System_Log__c  logerror = new System_Log__c (Origin__c  = 'Apex',Error_Body__c = s.Id +' is deleted from Fokus without a matching Subscription in Salesforce',Additional_Information__c = 'Subscription_Line_Detail_Update');
           		   insert logerror; 
               } 
          }
      }    
    List<Subscription_Line_Detail__c> UpdateSubscriptionLineDetails = new List<	Subscription_Line_Detail__c>();    
    Subscription_Line_Detail__c  SubscriptionLine = new Subscription_Line_Detail__c();
	update UpdateSubscriptionLineDetails;
    system.debug(UpdateSubscriptionLineDetails);  
         }//try
         catch(Exception e){
            System_Log__c  logerror = new System_Log__c (Origin__c  = 'Apex',Error_Body__c = e.getMessage(),Additional_Information__c = 'Fokus_SubscriptionService_Update');
            insert logerror;  
       }
    } 
    public void finish(Database.BatchableContext BC){        
    }
}