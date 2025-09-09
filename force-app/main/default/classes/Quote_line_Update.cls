public with sharing class Quote_line_Update {
public List<Id> recordsId; 
   
  
   @InvocableMethod(label='Update quote line bundles' description='Updating Quote line bundles for Activation Quote lines')
   public static void Quote_line_Bundle_Update(list <id> recordId)
        {
            list<SBQQ__QuoteLine__c > QuoteLineList = [SELECT SBQQ__Product__c,id,SBQQ__ProductOption__r.SBQQ__ConfiguredSKU__r.Product_ID_2__c from SBQQ__QuoteLine__c where SBQQ__Quote__c in:recordId ];
            map<String,String> QuoteLineProducts = new Map<String,String>(); //ProductId,QuoteLineId
            list<SBQQ__QuoteLine__c> QuoteLineUpdateList = new list<SBQQ__QuoteLine__c>();
            SBQQ__QuoteLine__c QuteLinerecord = new SBQQ__QuoteLine__c();
            
            try
            {
                for (SBQQ__QuoteLine__c rc : QuoteLineList)
                {
                    QuoteLineProducts.put(rc.SBQQ__Product__c,rc.Id);
                }
                
                for (SBQQ__QuoteLine__c rc : QuoteLineList)
                {
                   if(QuoteLineProducts.containsKey(rc.SBQQ__ProductOption__r.SBQQ__ConfiguredSKU__r.Product_ID_2__c))
                    {
                        QuteLinerecord.SBQQ__RequiredBy__c = QuoteLineProducts.get(rc.SBQQ__ProductOption__r.SBQQ__ConfiguredSKU__r.Product_ID_2__c);
                        QuteLinerecord.Id = rc.Id;
                        QuoteLineUpdateList.add(QuteLinerecord);
                        QuteLinerecord = new SBQQ__QuoteLine__c();
                    }                  
                }
                
                system.debug(QuoteLineUpdateList);
                if(QuoteLineUpdateList.size()>0)
                {
                    update QuoteLineUpdateList;
                }                
            }
            
            catch(Exception e){
            System.debug('### Error Occured Quote_line_Update : ' + e.getMessage());
            System_Log__c  logerror = new System_Log__c (Origin__c  = 'Apex',Error_Body__c = e.getMessage(),Additional_Information__c = 'Quote_line_Update');
            insert logerror;  
       }
            
 }
}