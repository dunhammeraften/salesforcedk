public class Activation_lineCreateAmendment {
@InvocableMethod(label='Create activation lines for amendments' description='Updating activation lines for a Quote from subscription details')
   public static void Activation_line_Create(list <id> recordId)
        {
            Activation_lineCreateAmendment_Iterable ProcessBatch = new Activation_lineCreateAmendment_Iterable();
            
              
            String columnNames = 'Id';
            Schema.DescribeSObjectResult subscriptionLineDetail_desc = Subscription_Line_Detail__c.sObjectType.getDescribe(); 
            Map<String, Schema.SObjectField> subscriptionLineDetail_fields = subscriptionLineDetail_desc.fields.getMap();
                    
              for(Schema.sObjectField fld:subscriptionLineDetail_fields.values())
              {     
                 columnNames = columnNames + ',' +  fld.getDescribe().getName();  
              } 
            
            columnNames = columnNames.removeStart('Id,');
 
            String batchQuery = 'SELECT '+ columnNames + 
            ',Subscription__r.SBQQ__Quantity__c,' +
            'Manual_Product__r.ProductAPI_Telia_Product_Id__c, ' +
            'Manual_Product__r.activate_with_other_products__c, '+
            ' Subscription__r.SBQQ__Account__r.Name from Subscription_Line_Detail__c  ' +
            ' where Subscription__c  in ( select SBQQ__UpgradedSubscription__c from SBQQ__QuoteLine__c '+
            ' where SBQQ__Quote__c =\'' + recordId.get(0) + 
            '\' and SBQQ__Product__r.Activation_Record_Type__c = \'Voice\'' +
            ') order by Quote_Line__c, Quote_line__r.SBQQ__UpgradedSubscription__c, '+
            ' Manual_Product__r.activate_with_other_products__c';
            ProcessBatch.query = batchQuery; 
            ProcessBatch.recordId = String.valueOf(recordId.get(0));
            ID batchprocessid = Database.executeBatch(ProcessBatch);   
        }

}