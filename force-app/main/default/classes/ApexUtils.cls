public class ApexUtils {
public string GetVASColumnNamesfromActivationLines()
{
    Schema.DescribeSObjectResult activationline_desc = Activation_line__c.sObjectType.getDescribe(); 
            
    Map<String, Schema.SObjectField> activationline_fields = activationline_desc.fields.getMap();
    String columnNames='Id';
            
      for(Schema.sObjectField fld:activationline_fields.values())
      {     
         if(string.valueof(fld).indexOf('VAS_')==0)
         {
             columnNames = columnNames + ',' +  fld.getDescribe().getName();  
              
         }
      } 
    return columnNames;
}
        
    public static void sendMail(String mailMessage, String mailSubject, String emailAddress){              
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {emailAddress};
        mail.setToAddresses(toAddresses);  
        mail.setSenderDisplayName('Salesforce Reminder');
        mail.setSubject(mailSubject);
        mail.setPlainTextBody(mailMessage);
        if(!Test.isRunningTest()){
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
	}
    
    public List<String> CheckIgnoreProducts ()
    {
        List<String> IgnoreProducts = new List<String>();
        list<Ignore_Remove_Product__c> IgnoreProductList;
        IgnoreProductList =  [select Order_Product__c from Ignore_Remove_Product__c];
        
        if(IgnoreProductList.size()>0)
        {
            for (Ignore_Remove_Product__c OpsRec: IgnoreProductList)
          	{
         	    IgnoreProducts.add(OpsRec.Order_Product__c); 
          	}   
        }
        system.debug('Ignore products:' + IgnoreProducts);
        return IgnoreProducts;
    } 
    
    public List<String> CheckDSLProducts ()
    {
        List<String> DSLProductCodes = new List<String>();
        list<SBQQ__ProductOption__c>DSLProductList;
        DSLProductList =  [select SBQQ__ConfiguredSKU__r.ProductAPI_Telia_Product_Id__c from SBQQ__ProductOption__c 
                           where SBQQ__MaxQuantity__c = 1];
        
        if(DSLProductList.size()>0)
        {
            for (SBQQ__ProductOption__c OpsRec: DSLProductList)
          	{
             if(OpsRec.SBQQ__ConfiguredSKU__r.ProductAPI_Telia_Product_Id__c !=null)
              {   
            	  DSLProductCodes.add(OpsRec.SBQQ__ConfiguredSKU__r.ProductAPI_Telia_Product_Id__c); 
        	  } 
          	}   
        }
        system.debug('DSL products:' + DSLProductCodes);
        return DSLProductCodes;
    }
    
        public Map<String,String> LoadSubscriptionProductCodeList()
    {
           list<Product2> ProductInfoList = [SELECT Id,ProductAPI_Telia_Product_Id__c,Contract_Group__c  
                                              from Product2 where IsActive = true
                                              and activate_with_other_products__c = false
                                              and SBQQ__SubscriptionType__c <> 'One-Time'
                                              and ProductAPI_Telia_Product_Id__c != null];   
            Map<String,String> ALLProductCodes= new Map<String, String>();
            //Name,ProductId         
            for(Product2 pr : ProductInfoList)
            {
                ALLProductCodes.put(pr.Id,pr.ProductAPI_Telia_Product_Id__c);
            }
            
    	return ALLProductCodes;
    }
    
    public Map<String,String> LoadSubscriptionProductList()
    {
           list<Product2> ProductInfoList = [SELECT Id,ProductAPI_Telia_Product_Id__c,Contract_Group__c  
                                              from Product2 where IsActive = true
                                              and activate_with_other_products__c = false
                                              and SBQQ__SubscriptionType__c <> 'One-Time'
                                              and ProductAPI_Telia_Product_Id__c != null ];  
            Map<String,String> ALLProductNames= new Map<String, String>();
            //Name,ProductId         
            for(Product2 pr : ProductInfoList)
            {
                ALLProductNames.put(pr.ProductAPI_Telia_Product_Id__c,pr.Id);
            }
            
             //Add the Product Matching Table
            list<Product_Matching__c> ProductMatchInfoList = [SELECT Product__c ,ProductAPI_Telia_Product_Id__c   
                                              from Product_Matching__c];  
            for(Product_Matching__c pr : ProductMatchInfoList)
            {
                ALLProductNames.put(pr.ProductAPI_Telia_Product_Id__c,pr.Product__c);
            }

    	return ALLProductNames;
    }
    
    
    
    public Map<String,String> LoadProductList()
    {
           list<Product2> ProductInfoList = [SELECT Id,ProductAPI_Telia_Product_Id__c,Contract_Group__c  
                                              from Product2 where IsActive = true
                                              and SBQQ__SubscriptionType__c <> 'One-Time' 
                                              and ProductAPI_Telia_Product_Id__c != null  ];
            Map<String,String> ALLProductNames= new Map<String, String>();
            //Name,ProductId         
            for(Product2 pr : ProductInfoList)
            {
                ALLProductNames.put(pr.ProductAPI_Telia_Product_Id__c,pr.Id);
            }
            
             //Add the Product Matching Table
            list<Product_Matching__c> ProductMatchInfoList = [SELECT Product__c ,ProductAPI_Telia_Product_Id__c   
                                              from Product_Matching__c];  
            for(Product_Matching__c pr : ProductMatchInfoList)
            {
                ALLProductNames.put(pr.ProductAPI_Telia_Product_Id__c,pr.Product__c);
            }

    	return ALLProductNames;
    }
    
     public Map<String,String> LoadProductContractGroups()
    {
           list<Product2> ProductInfoList = [SELECT Id,ProductAPI_Telia_Product_Id__c,Contract_Group__c  
                                              from Product2 where IsActive = true];
                                              //and activate_with_other_products__c = false
                                              //and ProductAPI_Telia_Product_Id__c != null   
            Map<String,String> ALLProductContractTypes= new Map<String, String>();
            //Name,ProductId         
            for(Product2 pr : ProductInfoList)
            {
                ALLProductContractTypes.put(pr.Id, pr.Contract_Group__c != null ? pr.Contract_Group__c : 'Mobile');
            }

    	return ALLProductContractTypes;
    }
}