/**
 * Modified by Mujahid 
 * on 27/10/2022
 */
public with sharing class Activation_check_details {
    public String resultText{get;set;} 
    public String recordId; 
    String quoteId;         
    
    public Activation_check_details(ApexPages.StandardController controller) {
        System.debug('controller = ' + controller);
        recordId = controller.getRecord().Id;
        resultText = '';
    }   

    /**
     * This method will be invoked by Activation Updates and Notifications Flow
     */
    @InvocableMethod
    public static void Activation(List<Id> recordId) {  
        activationCheck(recordId.get(0));
    }
    
    /** 
     * This method will be invoked by the visual force page which is called by Activation Check button in the Case Layout 
     */      
    public void Activation_Check() {
        activationCheck(recordId);
    }

    @TestVisible
    private static void activationCheck(Id recordId) {
        String resultText = '';
        Activation__c activationRecord;
        String quoteId;

        try{            
            List<Activation__c> activationsByCaseId = ActivationSelector.getActivationsByCaseId(recordId);    
            System.debug('activationsByCaseId = ' + activationsByCaseId);
            if(activationsByCaseId.size() <=0) {
                resultText = 'Activation details can not be found with the Id value from:' + recordId;
                return;
            }else{
                activationRecord = activationsByCaseId[0];
            }
            
            quoteId = activationRecord.Case__r.Quote__c;
            
            List<Product2> productInfoList = ProductSelector.getAllActiveProductsOrderByName();  
            
            Map<String,String> allProducts= new Map<String, String>();
            //productId,Name  
            Map<String,String> allProductNames= new Map<String, String>();
            //Name,productId         
            for(Product2 pr : productInfoList) {
                allProducts.put(pr.Id,pr.Name);
                allProductNames.put(pr.Name,pr.Id);
            }
            
            List<Product2> vasProductInfoList = ProductSelector.getValueAddedServiceProducts();

            Map<String,String> vasProducts= new Map<String, String>();
            //TeliaProductId,Id
            
            for(Product2 prVas : vasProductInfoList) {
                vasProducts.put(prVas.ProductAPI_Telia_Product_Id__c,prVas.Id);    
            }

            //Select only the VAS products inside the Quote ONLY VAS
            List<SBQQ__QuoteLine__c> quoteLineInfoList = QuoteLineSelector.getValueAddedServiceProductByQuote(quoteId);
            
            Map<String,integer> quoteProducts= new Map<String, integer>();
            //productId, Quantity
            
            for(SBQQ__QuoteLine__c ql : quoteLineInfoList) {
                quoteProducts.put(ql.SBQQ__Product__c,Integer.valueOf(ql.SBQQ__Quantity__c));    
            }
            
            //Query the VAS services list
            Schema.DescribeSObjectResult activationlineDesc = Activation_line__c.sObjectType.getDescribe(); 
            
            Map<String, Schema.SObjectField> activationlineFields = activationlineDesc.fields.getMap();
            Map<String,String> vasfields= new Map<String, String>();
            String columnNames='Id';
            
    
            for(Schema.sObjectField fld:activationlineFields.values()) {     
                if(String.valueof(fld).indexOf('VAS_')==0) {
                    columnNames = columnNames + ',' +  fld.getDescribe().getName();
                    vasfields.put(fld.getDescribe().getName(),fld.getDescribe().getType().name().toupperCase());
                }
            }

            String productId;
            String vasName;
            
            //Query the ActivationLines
            List<Activation_line__c>  activationLinesByCase = ActivationLineSelector.getActivationLinesByCaseId(recordId, columnNames);
                        
            //Loop through the activation lines
            Map<String,integer> activationLineProducts= new Map<String, integer>();
            Integer quantity; 
            Boolean added= false;
            for (Activation_line__c activationLineData : activationLinesByCase) {
                //START OF LOOPING ACTIVATION LINES
                
                //First loop gets the orderproduct related count
                productId = activationLineData.Manual_Product__c; 
                added= false;

                for (String key : activationLineProducts.keySet())  { 
                    if(key==productId && String.isNotBlank(activationLineData.Manual_Product__r.ProductAPI_Telia_Product_Id__c)) { 
                        quantity = activationLineProducts.get(productId) + 1;
                        activationLineProducts.remove(productId);
                        activationLineProducts.put(productId,quantity); 
                        added = true;
                        break;
                    }                    
                }

                if(added==false && String.isNotBlank(activationLineData.Manual_Product__r.ProductAPI_Telia_Product_Id__c)) { 
                    activationLineProducts.put(productId,1);         
                } 
                
                added=false;
                
                //Touchpoint section
                if(activationLineData.Touchpoint_Bruger__c ) { 
                    productId = allProductNames.get('Touchpoint Bruger');
                    if(activationLineProducts.get(productId) >0) {
                        quantity = activationLineProducts.get(productId)+ 1;
                        activationLineProducts.remove(productId);  
                        activationLineProducts.put(productId,quantity ); 
                    } else {
                        activationLineProducts.put(productId,1); 
                    }    
                } 

                if(activationLineData.Touchpoint_Receptionist__c ) { 
                    productId = allProductNames.get('Touchpoint Receptionist');
                    if(activationLineProducts.get(productId) >0) {
                        quantity = activationLineProducts.get(productId)+ 1;
                        activationLineProducts.remove(productId);  
                        activationLineProducts.put(productId,quantity ); 
                    } else {
                        activationLineProducts.put(productId,1); 
                    }    
                }

                if(activationLineData.Touchpoint_Statistik__c ) { 
                    productId = allProductNames.get('Touchpoint Statistik');
                    if(activationLineProducts.get(productId) >0){
                        quantity = activationLineProducts.get(productId)+ 1;
                        activationLineProducts.remove(productId);  
                        activationLineProducts.put(productId,quantity ); 
                    } else {
                        activationLineProducts.put(productId,1); 
                    }    
                }

                if(activationLineData.Touchpoint_Softphone__c ) { 
                    productId = allProductNames.get('Touchpoint Softphone');
                    if(activationLineProducts.get(productId) >0){
                            quantity = activationLineProducts.get(productId)+ 1;
                            activationLineProducts.remove(productId);  
                            activationLineProducts.put(productId,quantity ); 
                        }
                    else {
                        activationLineProducts.put(productId,1); 
                    }    
                }

                //VAS services section    
                added = false;      
                for (String key : vasfields.keySet()){
                    productId = null;
                    if (vasfields.get(key) == 'BOOLEAN'  && activationLineData.get(key) == true){ 
                        vasName = key.remove('VAS_').remove('__c'); 
                        for (String vasTeliaProductId : vasProducts.keySet()){  
                            if(vasName == vasTeliaProductId) { 
                                productId = vasProducts.get(vasTeliaProductId);
                                break;
                            }     
                        } 
                        if(productId != null){ //Found a VAS that is not in the activation check list
                        
                            for (String vaskey : activationLineProducts.keySet()) { 
                                if(productId == vaskey && productId!=null) {  
                                    quantity = activationLineProducts.get(productId)+ 1;
                                    activationLineProducts.remove(productId);  
                                    activationLineProducts.put(productId,quantity );
                                    added = true;
                                    break;
                                }      
                            }  

                            if(added == false && productId!=null) {
                                activationLineProducts.put(productId,1);              
                            }
                            
                        }//if (vasfields.get(key) == 'BOOLEAN'
                    } else {    
                        if (vasfields.get(key) == 'INTEGER' && integer.valueof(activationLineData.get(key)) >0) {
                            System.debug('integer VAS to be added (not implemented) ' + vasName);     
                        }

                        if ((vasfields.get(key) == 'PICKLIST' || vasfields.get(key) == 'STRING') && activationLineData.get(key) != null) {
                            vasName = String.Valueof(activationLineData.get(key));
                            
                            for (String vasTeliaProductId : vasProducts.keySet()) {  
                                if(vasName == vasTeliaProductId ) { 
                                    productId = vasProducts.get(vasTeliaProductId);
                                    break;
                                }     
                            } 

                            if(productId != null) { 
                                for (String vasPickkey : activationLineProducts.keySet()) { 
                                    if(productId == vasPickkey && productId!=null) {  
                                        quantity = activationLineProducts.get(productId) +1;
                                        activationLineProducts.remove(productId);  
                                        activationLineProducts.put(productId,quantity);
                                        added = true;
                                        break;
                                    }
                                }

                                if(added == false && productId!=null) {
                                    activationLineProducts.put(productId,1); 
                                } 
                            }
                        }
                        added = false;   
                    }
                }
                
            }//END OF LOOPING ACTIVATION LINES 
            
            Integer i;
            
            for(String keyId: quoteProducts.Keyset()){
                
                //if Activation lines does not have that key
                if(!activationLineProducts.keyset().contains(keyId)){
                    //resultText = resultText + allProducts.get(keyId) + ' is in the Quote with quantity:'+ String.valueOf(quoteProducts.get(keyId)) +' but not in the Activation Lines' + ' <br/>' ;
                    resultText = resultText + '<font style="color:green;">Available ' + allProducts.get(keyId) + ':' + String.valueOf(quoteProducts.get(keyId)) + '</font> <br/>' ;
                } else  {
                    if (quoteProducts.get(keyId) > activationLineProducts.get(keyId)) {
                        i = Integer.valueOf(quoteProducts.get(keyId)) - Integer.valueOf(activationLineProducts.get(keyId));
                        resultText = resultText + '<font style="color:green;">Available ' + allProducts.get(keyId) + ':' + String.valueof(i) + '</font> <br/>' ;                      
                    }

                    if (quoteProducts.get(keyId) < activationLineProducts.get(keyId)) {    
                        i = Integer.valueOf(quoteProducts.get(keyId)) - Integer.valueOf(activationLineProducts.get(keyId));
                        resultText = resultText + '<font style="color:red;">Available ' + allProducts.get(keyId) + ':' + String.valueof(i) + '</font> <br/>' ;
                    }     
                } 
            } 
            for(String keyId2: activationLineProducts.Keyset()){
                //if Quote lines does not have that key
                if(!quoteProducts.keyset().contains(keyId2)){
                    resultText = resultText + '<font style="color:blue;">Available ' + allProducts.get(keyId2) + ':';
                    resultText = resultText + '-' + activationLineProducts.get(keyId2) + '</font> <br/>' ;                          
                }
            } 
            
            if(String.isBlank(resultText)) {
                resultText = 'There are no discrepancies';
            }
            validateActivation(activationRecord, resultText);
        }catch(Exception e){
            System.debug('### Error Occured : ' + e.getMessage());
            resultText = String.valueOf(e) + '\n\n' + e.getStackTraceString(); 
        }
    }

    @TestVisible
    private static void validateActivation(Activation__c activationRecordToValidate, String activationResultText) {  
        String resultText = activationResultText;
        String recordId = activationRecordToValidate.Case__c;
        
        if(String.isEmpty(String.valueOf(activationRecordToValidate.UC_Activation_Date__c)) && (activationRecordToValidate.Case__r.Account.Customer_has_Touchpoint__c )) {
           resultText =  resultText + 'UC Activation Date can not be blank<br>' ;  
        }

        //Query the ActivationLines
        List<Activation_line__c>  activationLinesByCaseId = ActivationLineSelector.getActivationLinesByCaseId(recordId);
        for (Activation_line__c activationLine : activationLinesByCaseId) { 
            if((!String.isBlank(activationLine.Manual_Product__r.Product_Group__c) && (activationLine.Manual_Product__r.Product_Group__c.IndexOf('Touchpoint') >= 0) && String.isEmpty(activationLine.Funktionsnr__c)) || 
               ((activationLine.Manual_Product__r.Name =='Touchpoint Fastnetnummer') && (activationLine.Funktionsnr__c) =='Mobile')) {
                resultText =  resultText + 'Please select the correct value for Funktionsnr on ' + activationLine.Name + '<br>';  
            } 

            if((!(activationLine.VAS_SIMBTB2__c) && (activationLine.VAS_SIMBX2__c || activationLine.VAS_SIMBX3__c || activationLine.VAS_SIMBX4__c )) ||
               (!(activationLine.VAS_SIMBX2__c) && (activationLine.VAS_SIMBX3__c || activationLine.VAS_SIMBX4__c )) ||
               (!(activationLine.VAS_SIMBX3__c) && (activationLine.VAS_SIMBX4__c ))) {   
                resultText =  resultText + 'Please select extra sim card services in an order from 1 to 4 on' + activationLine.Name + '<br>';   
            }

            if((!(activationLine.VAS_SIMBTB11__c) && (activationLine.VAS_SIMBX5__c || activationLine.VAS_SIMBX6__c || activationLine.VAS_SIMBX7__c )) ||
               (!(activationLine.VAS_SIMBX5__c) && (activationLine.VAS_SIMBX6__c || activationLine.VAS_SIMBX7__c )) ||
               (!(activationLine.VAS_SIMBX6__c) && (activationLine.VAS_SIMBX7__c ))) {   
                resultText =  resultText + 'Please select extra sim card services in an order from 1 to 4 on' + activationLine.Name + '<br>';   
            }

            if(activationLine.Phone_no_Status__c == 'Nummer skal porteres' && String.isBlank(activationLine.Power_of_Attorney_record__c)) {
               resultText =  resultText + 'Required field missing on Activation Line: POA on ' + activationLine.Name + '<br>';   
            }
            
            if(activationLine.Phone_no_Status__c == 'Nummer skal porteres' && (activationRecordToValidate.Case__r.Account.Customer_has_Touchpoint__c ) && (activationLine.Number_Porting_End_of_Commitment__c)) {
               resultText =  resultText + 'End Of Commitment can not be selected on ' + activationLine.Name + '<br>';  
            }
            
            // validation of TELIAINSIGHT email address
            if(activationLine.Manual_Product__r.ProductAPI_Telia_Product_Id__c == 'TINSIGH' && String.isEmpty(activationLine.Telia_INSIGHT_e_mail_contact__c)) {
               resultText =  resultText + '<br>Required field missing on Activation Line: Telia INSIGHT e-mail contact on ' + activationLine.Name + '<br>';  
            }
       }  
       updateCaseActivationStatus(recordId, resultText);
    } 

    @Testvisible
    private static void updateCaseActivationStatus(String recordId, String resultText) {
        Case activationCase = CaseSelector.getById(recordId);
        activationCase.Case_Activation_Check_Result__c = resultText;
        activationCase.Case_Activation_Check_Time__c = System.now();
        update activationCase;
    }
}