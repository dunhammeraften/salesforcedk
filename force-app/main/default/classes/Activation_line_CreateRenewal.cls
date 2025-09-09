public with sharing class Activation_line_CreateRenewal {
@InvocableMethod(label='Create activation lines for renewals' description='Updating activation lines for a Quote from details')
   public static void Activation_line_Create(list <id> recordId)
        {
            Activation_lineCreateRenewal_Iterable ProcessBatch = new Activation_lineCreateRenewal_Iterable();
            String columnNames = 'Id';
            Schema.DescribeSObjectResult quoteLineDetail_desc = Quote_Line_Detail__c.sObjectType.getDescribe(); 
            Map<String, Schema.SObjectField> quoteLineDetail_fields = quoteLineDetail_desc.fields.getMap();
                    
              for(Schema.sObjectField fld:quoteLineDetail_fields.values())
              {     
                 columnNames = columnNames + ',' +  fld.getDescribe().getName();  
              } 
            
            columnNames = columnNames.removeStart('Id,');
 
            String batchQuery = 'SELECT '+ columnNames + 
            ',Quote_Line__r.SBQQ__Quantity__c , Quote_Line__r.SBQQ__Product__c,' +
            'Quote_Line__r.SBQQ__Product__r.ProductAPI_Telia_Product_Id__c, ' +
            'Quote_Line__r.Additional_Quantity__c, Quote_Line__r.Activation__c,' +
            'Quote_Line__r.Activation_Record_Type__c, Quote_Line__r.SBQQ__Quote__r.SBQQ__BillingCity__c,' +
            ' Quote_Line__r.SBQQ__Quote__r.SBQQ__BillingCountry__c, Quote_Line__r.SBQQ__Quote__r.SBQQ__BillingStreet__c,' +    
            ' Quote_Line__r.SBQQ__Quote__r.SBQQ__BillingPostalCode__c,'+
            ' Quote_Line__r.SBQQ__Product__r.activate_with_other_products__c, Quote_Line__r.SBQQ__Quote__c, '+
            ' Quote_line__r.SBQQ__RenewedSubscription__c,Quote_Line__r.SBQQ__Quote__r.Account_Name__c from Quote_Line_Detail__c  ' +
            ' where Quote_Line__r.SBQQ__EffectiveQuantity__c >0 and Quote_Line__r.Activation_Record_Type__c <>\'No activation needed\'' +  
            ' and Quote_Line__r.SBQQ__Quote__c =\'' + recordId.get(0) + 
            '\' order by Quote_Line__c, Quote_line__r.SBQQ__RenewedSubscription__c, '+
            ' Quote_Line__r.SBQQ__Product__r.activate_with_other_products__c,Termination_verifier__c';
            ProcessBatch.query = batchQuery; 
            ProcessBatch.recordId = String.valueOf(recordId.get(0));
            ID batchprocessid = Database.executeBatch(ProcessBatch);   
        }

}