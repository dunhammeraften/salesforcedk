public class Activation_lineCreateRenewal_Iterable  implements Database.Batchable<sObject>{
public String query;  
public String recordId;
public Database.querylocator start(Database.BatchableContext BC){
    return Database.getQueryLocator(query);
    }
 
public void execute(Database.BatchableContext BC, List<Quote_Line_Detail__c> scope){
   	 List<Activation_line__c> ActivationLineCreateList = new List<Activation_line__c>();
	 Activation_line__c Activation_line_record = new Activation_line__c();
     
    try
    {
        
        list<Product2> VASProductInfoList = [SELECT Name, Id,
                                                 ProductAPI_Telia_Product_Id__c  from Product2 where IsActive = true
                                                 and activate_with_other_products__c =true];   
            Map<String,String> VasProducts= new Map<String, String>();
            //TeliaProductId,Id
            
            for(Product2 prVas : VASProductInfoList)
            {
                VasProducts.put(prVas.ProductAPI_Telia_Product_Id__c,prVas.Id);    
            }
        
            //Query the VAS services list
            Schema.DescribeSObjectResult activationline_desc = Activation_line__c.sObjectType.getDescribe(); 
            
            Map<String, Schema.SObjectField> activationline_fields = activationline_desc.fields.getMap();
            Map<String,String> Vasfields= new Map<String, String>();
            Map<String,List<String>> M2MPicklistProducts= new Map<String, List<String>>();
            String columnNames='Id';
            
        for(Schema.sObjectField fld:activationline_fields.values())
      {     
         if(string.valueof(fld).indexOf('VAS_')==0)
         {
            if(fld.getDescribe().getType().name().toupperCase() == 'BOOLEAN')
            {
                columnNames = columnNames + ',' +  fld.getDescribe().getName();  
            }    
            Vasfields.put(fld.getDescribe().getName(),fld.getDescribe().getType().name().toupperCase());
            if(fld.getDescribe().getType().name().toupperCase() == 'PICKLIST')
                {
                    List<String> lstPickvals=new List<String>(); 
                    List<Schema.PicklistEntry> pick_list_values = fld.getDescribe().getPickListValues(); //grab the list of picklist values for the passed field on the sobject
                	for (Schema.PicklistEntry a : pick_list_values) { //for all values in the picklist list
                 		lstPickvals.add(a.getValue());//add the value  to our final list 
                    } 
                    M2MPicklistProducts.put(fld.getDescribe().getName(),lstPickvals);//add the value  to our final list      
                }
         }
      }            

    
    List<String> ListServices = new List<String>();
    //prepare a map for Mobile_no__c/List of VAS  
    Map<String, List<String>> NumberRelatedProducts = new Map<String, List<String>>();
 	NumberRelatedProducts = getNumberRelatedProducts();   
	system.debug(NumberRelatedProducts);
        
     
     Activation_line__c AltoUpdate = new Activation_line__c();
     List<Activation_line__c> ALListtoUpdate = new List<Activation_line__c>(); 
     List<String> VAScheck = new List<String>();  
        
    Map<String,String> TouchpointProducts= new Map<String, String>();
    //FieldName,ProductCode
    TouchpointProducts.put('TPSUSER','Touchpoint_Bruger__c');  
    TouchpointProducts.put('TPSUSERD','Touchpoint_Bruger__c');  
    TouchpointProducts.put('TPSUSERR','Touchpoint_Bruger__c');  
	TouchpointProducts.put('TPSRECEP', 'Touchpoint_Receptionist__c'); 
    TouchpointProducts.put('TPSRECEPD', 'Touchpoint_Receptionist__c'); 
    TouchpointProducts.put('TPSSOFT', 'Touchpoint_Softphone__c'); 
    TouchpointProducts.put('TPSSOFTD', 'Touchpoint_Softphone__c'); 
    TouchpointProducts.put('TPSSTAT', 'Touchpoint_Statistik__c');
    TouchpointProducts.put('TPSSTATD', 'Touchpoint_Statistik__c');
    //TouchpointProducts.put('TPXFNR10', 'TPX_Fastnet_nr_Serie_10__c');
    //TouchpointProducts.put('TPXFNR100', 'TPXFastnet_nr_Serie_100__c');
    TouchpointProducts.put('TPXATTAGT', 'Attendant_Agent_login__c');
    TouchpointProducts.put('TPXSUPV', 'Supervisor__c');
    TouchpointProducts.put('TPXATTAGT', 'Attendant_Agent_login__c'); 
    TouchpointProducts.put('TPXFNR1', 'Fastnet_user__c');    
        
     String service_name; 
     integer i=0; 
     integer imax = 0;   
     string QuoteLine_Id = '0';
         
     for(Quote_Line_Detail__c s : scope)
      {   
          if(s.Quote_Line__r.SBQQ__Product__r.activate_with_other_products__c == false) //Subscription detail
          {
              AltoUpdate.Activation__c = s.Quote_Line__r.Activation__c;
              AltoUpdate.Quote_line__c = s.Quote_Line__r.Id;
              AltoUpdate.RecordTypeId = Schema.sObjectType.Activation_line__c.getRecordTypeInfosByName().get(s.Quote_Line__r.Activation_Record_Type__c+ ' activation line').getRecordTypeId();
              AltoUpdate.Delivery_City__c = s.Quote_Line__r.SBQQ__Quote__r.SBQQ__BillingCity__c;
              AltoUpdate.Delivery_Country__c = s.Quote_Line__r.SBQQ__Quote__r.SBQQ__BillingCountry__c;
              AltoUpdate.Delivery_Street_and_number__c = s.Quote_Line__r.SBQQ__Quote__r.SBQQ__BillingStreet__c;
              AltoUpdate.Postal_Code__c = s.Quote_Line__r.SBQQ__Quote__r.SBQQ__BillingPostalCode__c;
        	  AltoUpdate.Manual_Product__c = s.Quote_Line__r.SBQQ__Product__c;
              AltoUpdate.Quantity__c = s.Quantity__c;
              AltoUpdate.Description__c = s.Description__c;
              AltoUpdate.Invoice_Email__c = s.Invoice_Email__c;
              AltoUpdate.Is_invoiced__c = s.Is_invoiced__c;
              AltoUpdate.Protection_Circuit_ID__c = s.Protection_Circuit_ID__c;
              AltoUpdate.Keywords__c = s.Keywords__c;
              AltoUpdate.RT_number__c = s.RT_number__c;
              AltoUpdate.Trunked_Ports__c = s.Trunked_Ports__c;
              AltoUpdate.Installation_Address_existing__c = s.Installation_Address_existing__c;
              AltoUpdate.Phone_no_Status__c = s.Phone_no_Status__c !=null ? s.Phone_no_Status__c: 'Eksisterende Norlys nummer';
              AltoUpdate.Notes__c = s.Notes__c;
              AltoUpdate.Attendant_Agent_login__c = s.Attendant_Agent_login__c;
              AltoUpdate.Fax__c = s.Fax__c;
              AltoUpdate.Ekstra_Data_SIM_number_2__c = s.Ekstra_Data_SIM_number_2__c;
              AltoUpdate.SLA__c = s.SLA__c;
              AltoUpdate.IP_Helper__c = s.IP_Helper__c;
              AltoUpdate.Existing_SIM_number__c = s.Existing_SIM_number__c;
              AltoUpdate.No_Porting__c = s.No_Porting__c;
              AltoUpdate.VRF_ID__c = s.VRF_ID__c;
              AltoUpdate.HSRP_LAN_IP__c = s.HSRP_LAN_IP__c;
              AltoUpdate.Static_Setup__c = s.Static_Setup__c;
              AltoUpdate.Email__c = s.Email__c;
              AltoUpdate.eBuy_PR_no__c = s.eBuy_PR_no__c;
              AltoUpdate.Vendor_circuit__c = s.Vendor_circuit__c;
              AltoUpdate.Sales_type__c = s.Sales_type__c;
              AltoUpdate.Local_Company_Name__c = s.Local_Company_Name__c;
              AltoUpdate.PoA__c = s.PoA__c;
              AltoUpdate.Supervisor__c = s.Supervisor__c;
              AltoUpdate.Phone_no__c = s.Fixed_no__c;
              AltoUpdate.Start_up_fee_Add_on_s__c = s.Start_up_fee_Add_on_s__c;
              AltoUpdate.X70_80_nummer__c = s.X70_80_nummer__c;
              AltoUpdate.Email_address__c = s.Email_address__c;
              AltoUpdate.SIM_number__c = s.SIM_number__c;
              AltoUpdate.Locale__c = s.Locale__c;
              AltoUpdate.New_Dual_card__c = s.New_Dual_card__c;
              AltoUpdate.RCC_Owner_Control__c = s.RCC_Owner_Control__c;
              AltoUpdate.EAN_number__c = s.EAN_number__c;
              AltoUpdate.Telia_INSIGHT_e_mail_contact__c = s.Telia_INSIGHT_e_mail_contact__c;
              AltoUpdate.Statistics__c = s.Statistics__c;
              AltoUpdate.NUA_Owner_Control__c = s.NUA_Owner_Control__c;
              AltoUpdate.VPN_number__c = s.VPN_number__c;
              AltoUpdate.Customer_AS_Number__c = s.Customer_AS_Number__c;
              AltoUpdate.Offer_ID__c = s.Offer_ID__c;
              AltoUpdate.Postal_Code__c = s.Postal_Code__c;
              AltoUpdate.Routing_Type__c = s.Routing_Type__c;
              AltoUpdate.Single_No__c = s.Single_No__c;
              AltoUpdate.Job_description__c = s.Job_description__c;
              AltoUpdate.Mobile_no__c = s.Mobile_no__c;
              AltoUpdate.Delivery_Email__c = s.Delivery_Email__c;
              AltoUpdate.SNMP_address_mask__c = s.SNMP_address_mask__c;
              AltoUpdate.Supervisor_No__c = s.Supervisor_No__c;
              AltoUpdate.Invoice_Type__c = s.Invoice_Type__c;
              AltoUpdate.PDF__c = s.PDF__c;
              AltoUpdate.Company_Name__c = s.Company_Name__c == null ? s.Quote_Line__r.SBQQ__Quote__r.Account_Name__c:s.Company_Name__c;
              AltoUpdate.Department__c = s.Department__c;
              AltoUpdate.Internet_on_Site__c = s.Internet_on_Site__c;
              AltoUpdate.Conference_Phones__c = s.Conference_Phones__c;
              AltoUpdate.Old_ICC__c = s.Old_ICC__c;
              AltoUpdate.Quick_Launch__c = s.Quick_Launch__c;
              AltoUpdate.Additional_services__c = s.Additional_services__c;
              AltoUpdate.Ekstra_Data_SIM_number_3__c = s.Ekstra_Data_SIM_number_3__c;
              AltoUpdate.Start_up_fee_Access__c = s.Start_up_fee_Access__c;
              AltoUpdate.Ekstra_Data_SIM_number__c = s.Ekstra_Data_SIM_number__c;
              AltoUpdate.Number_Porting_End_of_Commitment__c = s.Number_Porting_End_of_Commitment__c;
              AltoUpdate.CPE_ID__c = s.CPE_ID__c;
              AltoUpdate.Installation_address__c = s.Installation_address__c;
              AltoUpdate.VLANs__c = s.VLANs__c;
              AltoUpdate.DHCP__c = s.DHCP__c;
              AltoUpdate.Fastnet_no_Type__c = s.Fastnet_no_Type__c;
              AltoUpdate.Foreign_circuit__c = s.Foreign_circuit__c;
              AltoUpdate.Monthly_Access_fee__c = s.Monthly_Access_fee__c;
              AltoUpdate.Physical_LAN_interface__c = s.Physical_LAN_interface__c;
              AltoUpdate.Sub_Circuit__c = s.Sub_Circuit__c;
              AltoUpdate.Subscriber_Id__c = s.Subscriber_Id__c;
              AltoUpdate.Extra_ACD_k__c = s.Extra_ACD_k__c;
              AltoUpdate.Operator__c = s.Operator__c;
              AltoUpdate.Attendant_Agent_login_No__c = s.Attendant_Agent_login_No__c;
              AltoUpdate.BAN__c = s.BAN__c;
              AltoUpdate.Vendor_delivery_date__c = s.Vendor_delivery_date__c;
              AltoUpdate.Vendor_Name__c = s.Vendor_Name__c;
              AltoUpdate.Services__c = s.Services__c;
              AltoUpdate.Wallboard__c = s.Wallboard__c;
              AltoUpdate.Telia_til_Telia_transfer__c = s.Telia_til_Telia_transfer__c;
              AltoUpdate.Extra_ACD_k_Quantity__c = s.Extra_ACD_k_Quantity__c;
              AltoUpdate.Total_Access_fee__c = s.Total_Access_fee__c;
              AltoUpdate.Country_code__c = s.Country_code__c;
              AltoUpdate.SAP_PR_no__c =s.SAP_PR_no__c;
              AltoUpdate.Status_x__c = s.Status__c;
              AltoUpdate.Termination_Point__c = s.Termination_Point__c;
              AltoUpdate.LAN_network_address_mask__c = s.LAN_network_address_mask__c;
              AltoUpdate.Order_Type__c = s.Order_Type__c;
              AltoUpdate.Shortnr__c = s.Shortnr__c;
              AltoUpdate.Extra_Contact_Person__c = s.Extra_Contact_Person__c;
              AltoUpdate.Extra_Equipment__c = s.Extra_Equipment__c;
              AltoUpdate.Last_name__c = s.Last_name__c;
              AltoUpdate.TSRR_Owner_Control__c = s.TSRR_Owner_Control__c;
              AltoUpdate.Conference__c = s.Conference__c;
              AltoUpdate.Exchange__c = s.Exchange__c;
              AltoUpdate.MultipleVPN__c = s.MultipleVPN__c;
              AltoUpdate.Ekstra_Data_SIM_number_4__c = s.Ekstra_Data_SIM_number_4__c;
              AltoUpdate.Funktionsnr__c = s.Funktionsnr__c;
              AltoUpdate.First_name__c = s.First_name__c;
              AltoUpdate.Monthly_Add_on_fee__c = s.Monthly_Add_on_fee__c;
              AltoUpdate.Circuit_ID_existing__c = s.Circuit_ID_existing__c;
              AltoUpdate.Redundancy__c = s.Redundancy__c;
              AltoUpdate.SNMP_community__c = s.SNMP_community__c;
              AltoUpdate.Fastnet_user__c = s.Fastnet_user__c;
              AltoUpdate.Access_Method__c = s.Access_Method__c;
              AltoUpdate.Forbrugskontrol_amount__c = s.Forbrugskontrol_amount__c;
              AltoUpdate.Administrator__c = s.Administrator__c;
              AltoUpdate.CPE_ID_existing__c = s.CPE_ID_existing__c;
              AltoUpdate.Landline_no__c = s.Landline_no__c;
              AltoUpdate.Circuit_ID__c = s.Circuit_ID__c;
              AltoUpdate.Primary_or_Secondary__c = s.Primary_or_Secondary__c;
              AltoUpdate.Billing_Account__c = s.Billing_Account__c;
              AltoUpdate.Contact_person_on_site__c = s.Contact_person_on_site__c;
              AltoUpdate.Kollegakald__c = s.Kollegakald__c;
              AltoUpdate.M2M__c = s.M2M__c;
              AltoUpdate.MBB__c = s.MBB__c;
              AltoUpdate.Power_of_Attorney_Record__c = s.Power_of_Attorney_Record__c;
              AltoUpdate.QoS_Realtime__c = s.QoS_Realtime__c;
              AltoUpdate.SLA_x__c = s.SLA_x__c;
              AltoUpdate.TP_License__c = s.TP_License__c;
              AltoUpdate.TP_Voice__c = s.TP_Voice__c;
              AltoUpdate.Fokus_SOC__c = s.Fokus_SOC__c;
              AltoUpdate.Number_of_IP_Addresses__c = s.Number_of_IP_Addresses__c;
              AltoUpdate.LAN_IP__c = s.LAN_IP__c;
              AltoUpdate.IP_routes__c  = s.IP_routes__c ;
              AltoUpdate.Express_Delivery__c  = s.Express_Delivery__c ;
              AltoUpdate.Dynamic_Static_Routing__c = s.Dynamic_Static_Routing__c;
              AltoUpdate.Dynamic_Static__c  = s.Dynamic_Static__c ;
              AltoUpdate.DHCP_server__c  = s.DHCP_server__c ;
              AltoUpdate.DHCP_range__c  = s.DHCP_range__c ;
              AltoUpdate.DHCP_DNS_Secondary__c = s.DHCP_DNS_Secondary__c;
              AltoUpdate.DHCP_DNS_Primary__c = s.DHCP_DNS_Primary__c;
              AltoUpdate.AS_no__c = s.AS_no__c;
              AltoUpdate.VLAN_TAG_EVPN__c = s.VLAN_TAG_EVPN__c;
              AltoUpdate.Trunk_no_Small_world_Dedicated__c = s.Trunk_no_Small_world_Dedicated__c;
              AltoUpdate.TPX_Power_Adapter__c  = s.TPX_Power_Adapter__c;
              AltoUpdate.TPX_Deskphone__c = s.TPX_Deskphone__c ;
              AltoUpdate.Secondary_Circuit_ID__c = s.Secondary_Circuit_ID__c  ;
              AltoUpdate.SAP_Order_number__c = s.SAP_Order_number__c ;
              AltoUpdate.Primary_Circuit_ID__c = s.Primary_Circuit_ID__c ;
              AltoUpdate.PO_number__c = s.PO_number__c ;
              AltoUpdate.POI_TNID_EVPN__c = s.POI_TNID_EVPN__c  ;
              AltoUpdate.Peering_address__c = s.Peering_address__c  ;
              
              if(s.Phone_no_Status__c == 'Opsigelse')
              {
                  AltoUpdate.Number_Porting_Specific_Date__c = s.Number_Porting_Specific_Date__c;
              }
              
              
              system.debug(NumberRelatedProducts);
              VAScheck = NumberRelatedProducts.get(s.MobileFixedCircuit__c);
              if(VAScheck != null)
              {
                 for(string VASservice : VAScheck)
                  { 
                      if(columnNames.indexOf(VASservice)>=0) 
                       {  
                           if(TouchpointProducts.get(VASservice) == null)
                           {
                               service_name='VAS_'+  VASservice + '__c';
                               AltoUpdate.put(service_name,true); 
                           }
                       }
                      
                       //Touchpoint assignments
                       for (string key : TouchpointProducts.keySet())
                       {   
                           if(key == VASservice)
                           { 
                              AltoUpdate.put(TouchpointProducts.get(VASservice),true); 
                           }    
                       }
                       system.debug('M2MPicklistProducts:'+M2MPicklistProducts);
                       //Picklist VAS assignments
                       
                       for (string key : M2MPicklistProducts.keySet())
                       {   
                           for (String M2MPicklistVal : M2MPicklistProducts.get(key))
                           {   
                               if(VASservice == M2MPicklistVal)
                               { 
                                  AltoUpdate.put(key,M2MPicklistVal);
                                   system.debug(key);
                                   system.debug(M2MPicklistVal);
                               }  
                           }
                        }  
                        
                  } 
              }
              ALListtoUpdate.add(AltoUpdate);
              AltoUpdate = new Activation_line__c();
          }//if
          
      }  
   
            system.debug(ALListtoUpdate);
        	if(ALListtoUpdate.size()>0)
            {
                insert ALListtoUpdate; 
            }
            
      }
      catch(Exception e){
          System.debug('### Error Occured while inserting renewal activation lines : ' + e.getMessage());
          System_Log__c  logerror = new System_Log__c (
                        Origin__c  = 'Apex',
                        Error_Body__c = e.getMessage() + ' Line:' + e.getLineNumber(),
            			Additional_Information__c = 'Activation_lineCreateRenewal_Iterable');
            insert logerror; 
      }     
}
    
public void finish(Database.BatchableContext BC){
}


    public Map<String, List<String>> getNumberRelatedProducts ()
    {
     	//MobileFixedCircuit__c,List(Quote_Line__r.SBQQ__Product__r.ProductAPI_Telia_Product_Id__c )         
        Map<String, List<String>> NumberRelatedProducts = new Map<String, List<String>>();
        String MobileFixedCircuit;
        List<String> ListServices = new List<String>();
        list<Quote_Line_Detail__c> ProductInfoList = [select MobileFixedCircuit__c,
                                                Quote_Line__r.SBQQ__Product__r.ProductAPI_Telia_Product_Id__c 
                                                 from Quote_Line_Detail__c  
                                                 where Quote_Line__r.SBQQ__EffectiveQuantity__c >0  and Quote_Line__r.SBQQ__Product__r.activate_with_other_products__c =true
                                                and Quote_Line__r.SBQQ__Quote__c =: recordId order by MobileFixedCircuit__c];   
                if(ProductInfoList.size()>0)
                 {   
                    MobileFixedCircuit = ProductInfoList[0].MobileFixedCircuit__c;
                        
                    for(Quote_Line_Detail__c pr : ProductInfoList)
                    {
                        if(MobileFixedCircuit == pr.MobileFixedCircuit__c)
                        {    
                        	ListServices.add(pr.Quote_Line__r.SBQQ__Product__r.ProductAPI_Telia_Product_Id__c );
                        }  
                        else
                        {    
                            NumberRelatedProducts.put(MobileFixedCircuit,ListServices);
                            ListServices = new List<String>();
                            MobileFixedCircuit = pr.MobileFixedCircuit__c;
                            ListServices.add(pr.Quote_Line__r.SBQQ__Product__r.ProductAPI_Telia_Product_Id__c );                       
                        }
                    }
                    NumberRelatedProducts.put(MobileFixedCircuit,ListServices);                             
    			}
            return NumberRelatedProducts;   
    }
}