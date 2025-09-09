public with sharing class Subscription_Update {
public List<Id> recordsId; 
 
   @InvocableMethod(label='Update subscription bundles' description='Updating subscription bundles')
   public static void Subscription_Bundle_Update(list <id> recordId)
        {
            system.debug('Start Subscription update');
            list<SBQQ__Subscription__c > SubscriptionList = [SELECT SBQQ__RequiredById__c,SBQQ__Contract__c,SBQQ__Account__c,SBQQ__Product__c,
                                                             	SBQQ__Number__c,SBQQ__Bundle__c ,SBQQ__RootId__c , id from SBQQ__Subscription__c where SBQQ__Contract__c in:recordId ];
            
                       
            map<String,Decimal> SubscriptionNumbers = new Map<String,Decimal>(); //RequiredById,MaxNumber
            map<String,Decimal> BundleSubscriptionNumbers = new Map<String,Decimal>(); //BundleId,SBQQ__Number__c
            
           
            list<Id> ProductIds = new List<Id>();
            map<String,String> SubscriptionProducts = new Map<String,String>(); //ProductId,SubscriptionId
            map<String,String> ProductOptionProducts = new Map<String,String>(); //ProductId,ConfProductId
			map<String,String> ProductOptions = new Map<String,String>(); //ProductId,ProductOptionId
                        
            list<SBQQ__Subscription__c> SubscriptionUpdateList = new list<SBQQ__Subscription__c>();
            SBQQ__Subscription__c Subscriptionrecord = new SBQQ__Subscription__c();
            
            try
            {
                for (SBQQ__Subscription__c rc : SubscriptionList)
                {
                    SubscriptionProducts.put(rc.SBQQ__Product__c,rc.Id);
                    ProductIds.add(rc.SBQQ__Product__c); 
                    if(rc.SBQQ__RequiredById__c == null)
                       { 
                           if(rc.SBQQ__Number__c == null)
                           {   
                               BundleSubscriptionNumbers.put((String)rc.Id,100);
                           }
                           else
                           {  
                               BundleSubscriptionNumbers.put((String)rc.Id,(Decimal)rc.SBQQ__Number__c);
                           }   
                           
                       }    
                }
               
                
                list<SBQQ__ProductOption__c > ProductOptionsList = [select SBQQ__ConfiguredSKU__c,SBQQ__OptionalSKU__c from SBQQ__ProductOption__c where SBQQ__OptionalSKU__c in:ProductIds ];
           		for (SBQQ__ProductOption__c oprc : ProductOptionsList)
                {
                    ProductOptionProducts.put(oprc.SBQQ__OptionalSKU__c, oprc.SBQQ__ConfiguredSKU__c );
                	ProductOptions.put(oprc.SBQQ__OptionalSKU__c,oprc.Id);
                }
                
                for (SBQQ__Subscription__c rc : SubscriptionList)
                {
                   if(String.isBlank(rc.SBQQ__RequiredById__c) && ProductOptionProducts.get(rc.SBQQ__Product__c)!=null)
                    {   
                        if(SubscriptionProducts.containsKey(ProductOptionProducts.get(rc.SBQQ__Product__c)))
                        {
                            Subscriptionrecord.SBQQ__RequiredById__c = SubscriptionProducts.get(ProductOptionProducts.get(rc.SBQQ__Product__c));
                            Subscriptionrecord.SBQQ__RequiredByProduct__c = ProductOptionProducts.get(rc.SBQQ__Product__c);
                            Subscriptionrecord.SBQQ__ProductOption__c = ProductOptions.get(rc.SBQQ__Product__c);
                            Subscriptionrecord.Id = rc.Id;
                            Subscriptionrecord.SBQQ__OptionLevel__c = 1;
                            Subscriptionrecord.SBQQ__OptionType__c = 'Related Product';
                            SubscriptionUpdateList.add(Subscriptionrecord);
                            Subscriptionrecord = new SBQQ__Subscription__c();
                        }                  
                        else //Bundle is not added as a subscription, add a subscription
                         {
                            SBQQ__Subscription__c newSubscription = new SBQQ__Subscription__c(
                             SBQQ__Contract__c = rc.SBQQ__Contract__c,
                             SBQQ__Product__c = ProductOptionProducts.get(rc.SBQQ__Product__c),
                             SBQQ__Quantity__c = 1, //TODO!!
                             SBQQ__Account__c = rc.SBQQ__Account__c,
                             SBQQ__ProductSubscriptionType__c = 'Renewable',
                             SBQQ__SubscriptionType__c = 'Renewable',
                             //SBQQ__RenewalQuantity__c = 1,
                             SBQQ__Bundle__c = true);
                             insert newSubscription;  
                            
                            newSubscription.SBQQ__RootId__c =  newSubscription.Id;
                            SubscriptionProducts.put(newSubscription.SBQQ__Product__c,newSubscription.Id);
                            Subscriptionrecord.SBQQ__RequiredById__c = newSubscription.Id;
                            Subscriptionrecord.SBQQ__RequiredById__c = newSubscription.Id;
                            Subscriptionrecord.SBQQ__RequiredByProduct__c = newSubscription.SBQQ__Product__c;
                            Subscriptionrecord.SBQQ__ProductOption__c =  ProductOptions.get(rc.SBQQ__Product__c);
                            BundleSubscriptionNumbers.put((String)newSubscription.Id,100); 
                            Subscriptionrecord.Id = rc.Id;
                            Subscriptionrecord.SBQQ__OptionLevel__c = 1;
                            Subscriptionrecord.SBQQ__OptionType__c = 'Related Product';
                            SubscriptionUpdateList.add(newSubscription);
                            SubscriptionUpdateList.add(Subscriptionrecord);
                            Subscriptionrecord = new SBQQ__Subscription__c();
                    	} 
                   }     
                }
                
                   
                //Existing numbers without the newly added ones
                list<AggregateResult > SubscriptionNumberList = [SELECT SBQQ__RequiredById__c,max(SBQQ__Number__c) SBQQ__Number__c from SBQQ__Subscription__c 
                                                                   where SBQQ__Contract__c in:recordId group by SBQQ__RequiredById__c ];
  
                
                for (AggregateResult  SubscriptionNumber :SubscriptionNumberList)   
                {
                    if(SubscriptionNumber.get('SBQQ__RequiredById__c') == null)
                    {
                        if(SubscriptionNumber.get('SBQQ__Number__c') != null)
                        {    
                     	   SubscriptionNumbers.put('0',(Decimal)SubscriptionNumber.get('SBQQ__Number__c'));
                        }  
                        else
                        {    
                     	   SubscriptionNumbers.put('0',100);
                        }   
                    }  
                    else
                    {
                        if(SubscriptionNumber.get('SBQQ__Number__c') == null)
                        {    
                     	   SubscriptionNumbers.put((String)SubscriptionNumber.get('SBQQ__RequiredById__c'),1000);
                        }  
                        else
                        {     
                       	 SubscriptionNumbers.put((String)SubscriptionNumber.get('SBQQ__RequiredById__c'),(Decimal)SubscriptionNumber.get('SBQQ__Number__c'));
                   		}
                     }    
                }
                
                system.debug(SubscriptionNumbers);
                Decimal SubscriptionNumberUpdate;
                if(SubscriptionUpdateList.size()>0)
                {
                    for (SBQQ__Subscription__c rc : SubscriptionUpdateList)
                    {
                         if(rc.SBQQ__RootId__c == rc.Id) //get 0 from the map
                         {
                             if (SubscriptionNumbers.get('0') == null)
                                 {
                                     SubscriptionNumberUpdate = 100;
                                 }
                             else
                                 {
                                     SubscriptionNumberUpdate = SubscriptionNumbers.get('0') +100;
                                 }
                              SubscriptionNumbers.put('0',SubscriptionNumberUpdate);
                         }
                        else
                         {
                             if (SubscriptionNumbers.get(rc.SBQQ__RequiredById__c) == null)
                                 {
                                     SubscriptionNumberUpdate = BundleSubscriptionNumbers.get((String)rc.SBQQ__RequiredById__c) + 1000;
                                 }
                             else
                                 {
                           			SubscriptionNumberUpdate = SubscriptionNumbers.get(rc.SBQQ__RequiredById__c) + 1000;
                        		}
                             SubscriptionNumbers.put((String)rc.SBQQ__RequiredById__c,SubscriptionNumberUpdate);
                         } 
                        
                   		 rc.SBQQ__Number__c = (double)SubscriptionNumberUpdate;  
               		}
                    update SubscriptionUpdateList;
                }                
            }
            
            catch(Exception e){
            System.debug('### Error Occured Subscription_Update : ' + e.getMessage());
            System_Log__c  logerror = new System_Log__c (Origin__c  = 'Apex',Error_Body__c = e.getMessage() + ' Line:' + e.getLineNumber(),Additional_Information__c = 'Subscription_Update');
            insert logerror;  
       }
            
 }
}