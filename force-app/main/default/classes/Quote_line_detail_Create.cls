public without sharing class Quote_line_detail_Create implements Database.Batchable<sObject> {
    public List<Id> recordsId;

    @InvocableMethod(label='Create quote line details' description='Creating quote line details for Activation Quote')
    public static list<id> Quote_line_details_Batch(list<id> recordId) {
        Quote_line_detail_Create ProcessBatch = new Quote_line_detail_Create();
        ProcessBatch.recordsId = recordId;
        ID batchprocessid = Database.executeBatch(ProcessBatch);
        //String cronID = System.scheduleBatch(ProcessBatch, 'Creating quote line', 1);
        return recordId;
    }

    public Database.querylocator start(Database.BatchableContext BC) {
        String squery = 'SELECT Id,Original_Quote_Line__c  from SBQQ__QuoteLine__c  where SBQQ__Quote__c in :recordsId';
        return Database.getQueryLocator(squery);
    }

    public void execute(Database.BatchableContext BC, List<SBQQ__QuoteLine__c> scope) {
        List<Quote_Line_Detail__c> QuoteLineDetailCreateList = new List<Quote_Line_Detail__c>();
        Schema.DescribeSObjectResult activationline_desc = Activation_line__c.sObjectType.getDescribe();

        Map<String, Schema.SObjectField> activationline_fields = activationline_desc.fields.getMap();
        String columnNames = 'Id';

        for (Schema.sObjectField fld : activationline_fields.values()) {
            columnNames = columnNames + ',' + fld.getDescribe().getName();
        }

        columnNames = columnNames.removeStart('Id,');

        try {
            for (SBQQ__QuoteLine__c s : scope) {
                //Query the VAS services list
                system.debug(columnNames);
                //Query the ActivationLines
                list<Activation_line__c> Activation_line_records = Database.query(
                    'SELECT ' +
                        columnNames +
                        ' , Quote_line__r.SBQQ__Product__c  from Activation_line__c  where Quote_line__c =\'' +
                        s.Original_Quote_Line__c +
                        '\''
                );

                if (Activation_line_records.size() > 0) {
                    for (Activation_line__c al : Activation_line_records) {
                        if (al.Manual_Product__c == al.Quote_line__r.SBQQ__Product__c) {
                            QuoteLineDetailCreateList.add(
                                new Quote_Line_Detail__c(
                                    Activation_Line__c = al.Id,
                                    Quote_Line__c = s.Id,
                                    VAS_BARDATA__c = al.VAS_BARDATA__c,
                                    Quantity__c = al.Quantity__c,
                                    Description__c = al.Description__c,
                                    Invoice_Email__c = al.Invoice_Email__c,
                                    Touchpoint_Statistik__c = al.Touchpoint_Statistik__c,
                                    Is_invoiced__c = al.Is_invoiced__c,
                                    Protection_Circuit_ID__c = al.Protection_Circuit_ID__c,
                                    Address_filled__c = al.Address_filled__c,
                                    Keywords__c = al.Keywords__c,
                                    RT_number__c = al.RT_number__c,
                                    Delivery_Country__c = al.Delivery_Country__c,
                                    Trunked_Ports__c = al.Trunked_Ports__c,
                                    Installation_Address_existing__c = al.Installation_Address_existing__c,
                                    Phone_no_Status__c = al.Phone_no_Status__c,
                                    Notes__c = al.Notes__c,
                                    Attendant_Agent_login__c = al.Attendant_Agent_login__c,
                                    Fax__c = al.Fax__c,
                                    Ekstra_Data_SIM_number_2__c = al.Ekstra_Data_SIM_number_2__c,
                                    SLA__c = al.SLA__c,
                                    TPXFastnet_nr_Serie_100__c = al.TPXFastnet_nr_Serie_100__c,
                                    IP_Helper__c = al.IP_Helper__c,
                                    VAS_TEAMSPAEB__c = al.VAS_TEAMSPAEB__c,
                                    Existing_SIM_number__c = al.Existing_SIM_number__c,
                                    No_Porting__c = al.No_Porting__c,
                                    VAS_FIX2MOBIL__c = al.VAS_FIX2MOBIL__c,
                                    VRF_ID__c = al.VRF_ID__c,
                                    HSRP_LAN_IP__c = al.HSRP_LAN_IP__c,
                                    Static_Setup__c = al.Static_Setup__c,
                                    VAS_BARTOTRO__c = al.VAS_BARTOTRO__c,
                                    Email__c = al.Email__c,
                                    eBuy_PR_no__c = al.eBuy_PR_no__c,
                                    Touchpoint_Bruger__c = al.Touchpoint_Bruger__c,
                                    Vendor_circuit__c = al.Vendor_circuit__c,
                                    VAS_M2M_SMS__c = al.VAS_M2M_SMS__c,
                                    Sales_type__c = al.Sales_type__c,
                                    Local_Company_Name__c = al.Local_Company_Name__c,
                                    PoA__c = al.PoA__c,
                                    VAS_BARSTD__c = al.VAS_BARSTD__c,
                                    Supervisor__c = al.Supervisor__c,
                                    Delivery_City__c = al.Delivery_City__c,
                                    VAS_TINSEFAK__c = al.VAS_TINSEFAK__c,
                                    VAS_TSCBTC5__c = al.VAS_TSCBTC5__c,
                                    Fixed_no__c = al.Phone_no__c,
                                    Start_up_fee_Add_on_s__c = al.Start_up_fee_Add_on_s__c,
                                    X70_80_nummer__c = al.X70_80_nummer__c,
                                    VAS_BAROUTRO__c = al.VAS_BAROUTRO__c,
                                    Email_address__c = al.Email_address__c,
                                    VAS_CORUSA5G__c = al.VAS_CORUSA5G__c,
                                    VAS_BARMMS__c = al.VAS_BARMMS__c,
                                    SIM_number__c = al.SIM_number__c,
                                    Locale__c = al.Locale__c,
                                    New_Dual_card__c = al.New_Dual_card__c,
                                    RCC_Owner_Control__c = al.RCC_Owner_Control__c,
                                    VAS_TINABBOV__c = al.VAS_TINABBOV__c,
                                    EAN_number__c = al.EAN_number__c,
                                    Telia_INSIGHT_e_mail_contact__c = al.Telia_INSIGHT_e_mail_contact__c,
                                    Statistics__c = al.Statistics__c,
                                    NUA_Owner_Control__c = al.NUA_Owner_Control__c,
                                    VPN_number__c = al.VPN_number__c,
                                    Customer_AS_Number__c = al.Customer_AS_Number__c,
                                    VAS_BAR90__c = al.VAS_BAR90__c,
                                    VAS_BARINC__c = al.VAS_BARINC__c,
                                    VAS_TINFORDE__c = al.VAS_TINFORDE__c,
                                    VAS_TINFAKOV__c = al.VAS_TINFAKOV__c,
                                    VAS_BARORXD__c = al.VAS_BARORXD__c,
                                    VAS_TININTRO__c = al.VAS_TININTRO__c,
                                    VAS_SIMBX2__c = al.VAS_SIMBX2__c,
                                    VAS_SIMBX5__c = al.VAS_SIMBX5__c,
                                    Offer_ID__c = al.Offer_ID__c,
                                    Postal_Code__c = al.Postal_Code__c,
                                    Actual_delivery_date__c = al.Actual_delivery_date__c,
                                    Routing_Type__c = al.Routing_Type__c,
                                    VAS_TPXTEAMSO__c = al.VAS_TPXTEAMSO__c,
                                    Single_No__c = al.Single_No__c,
                                    VAS_ALLBIZA__c = al.VAS_ALLBIZA__c,
                                    VAS_CORWA5G__c = al.VAS_CORWA5G__c,
                                    Job_description__c = al.Job_description__c,
                                    TPX_Fastnet_nr_Serie_10__c = al.TPX_Fastnet_nr_Serie_10__c,
                                    Mobile_no__c = al.Mobile_no__c,
                                    Delivery_Email__c = al.Delivery_Email__c,
                                    SNMP_address_mask__c = al.SNMP_address_mask__c,
                                    Supervisor_No__c = al.Supervisor_No__c,
                                    Invoice_Type__c = al.Invoice_Type__c,
                                    PDF__c = al.PDF__c,
                                    VAS_TPXTEAMSR__c = al.VAS_TPXTEAMSR__c,
                                    VAS_BARPRCSMS__c = al.VAS_BARPRCSMS__c,
                                    Company_Name__c = al.Company_Name__c,
                                    Department__c = al.Department__c,
                                    Internet_on_Site__c = al.Internet_on_Site__c,
                                    Conference_Phones__c = al.Conference_Phones__c,
                                    Old_ICC__c = al.Old_ICC__c,
                                    Quick_Launch__c = al.Quick_Launch__c,
                                    Additional_services__c = al.Additional_services__c,
                                    Ekstra_Data_SIM_number_3__c = al.Ekstra_Data_SIM_number_3__c,
                                    Start_up_fee_Access__c = al.Start_up_fee_Access__c,
                                    Ekstra_Data_SIM_number__c = al.Ekstra_Data_SIM_number__c,
                                    VAS_BAR3G__c = al.VAS_BAR3G__c,
                                    Number_Porting_End_of_Commitment__c = al.Number_Porting_End_of_Commitment__c,
                                    Number_Porting_Specific_Date__c = al.Number_Porting_Specific_Date__c,
                                    Delivery_Att__c = al.Delivery_Att__c,
                                    CPE_ID__c = al.CPE_ID__c,
                                    Installation_address__c = al.Installation_address__c,
                                    VLANs__c = al.VLANs__c,
                                    DHCP__c = al.DHCP__c,
                                    VAS_SIMBTB2__c = al.VAS_SIMBTB2__c,
                                    VAS_SIMBTB11__c = al.VAS_SIMBTB11__c,
                                    Fastnet_no_Type__c = al.Fastnet_no_Type__c,
                                    Foreign_circuit__c = al.Foreign_circuit__c,
                                    Monthly_Access_fee__c = al.Monthly_Access_fee__c,
                                    Physical_LAN_interface__c = al.Physical_LAN_interface__c,
                                    Sub_Circuit__c = al.Sub_Circuit__c,
                                    VAS_EntitleAW__c = al.VAS_EntitleAW__c,
                                    Subscriber_Id__c = al.Subscriber_Id__c,
                                    VAS_M2M_Data__c = al.VAS_M2M_Data__c,
                                    Extra_ACD_k__c = al.Extra_ACD_k__c,
                                    VAS_BARINTRO__c = al.VAS_BARINTRO__c,
                                    Activation_Fulfilled__c = al.Activation_Fulfilled__c,
                                    VAS_SFBTB60__c = al.VAS_SFBTB60__c,
                                    VAS_SIMBX3__c = al.VAS_SIMBX3__c,
                                    VAS_SIMBX6__c = al.VAS_SIMBX6__c,
                                    VAS_M2MROAM__c = al.VAS_M2MROAM__c,
                                    Operator__c = al.Operator__c,
                                    Attendant_Agent_login_No__c = al.Attendant_Agent_login_No__c,
                                    BAN__c = al.BAN__c,
                                    VAS_UC_License__c = al.VAS_UC_License__c,
                                    VAS_TEAMSPAUD__c = al.VAS_TEAMSPAUD__c,
                                    VAS_BARTOTAL__c = al.VAS_BARTOTAL__c,
                                    Vendor_delivery_date__c = al.Vendor_delivery_date__c,
                                    VAS_CORAS5G__c = al.VAS_CORAS5G__c,
                                    VAS_BARLEVEL__c = al.VAS_BARLEVEL__c,
                                    Vendor_Name__c = al.Vendor_Name__c,
                                    Services__c = al.Services__c,
                                    Wallboard__c = al.Wallboard__c,
                                    VAS_BAROUTG__c = al.VAS_BAROUTG__c,
                                    Telia_til_Telia_transfer__c = al.Telia_til_Telia_transfer__c,
                                    Touchpoint_Receptionist__c = al.Touchpoint_Receptionist__c,
                                    VAS_FLIPPBTC5__c = al.VAS_FLIPPBTC5__c,
                                    Extra_ACD_k_Quantity__c = al.Extra_ACD_k_Quantity__c,
                                    VAS_BARINTCAL__c = al.VAS_BARINTCAL__c,
                                    Total_Access_fee__c = al.Total_Access_fee__c,
                                    Country_code__c = al.Country_code__c,
                                    Touchpoint_Softphone__c = al.Touchpoint_Softphone__c,
                                    VAS_SFBTB40__c = al.VAS_SFBTB40__c,
                                    SAP_PR_no__c = al.SAP_PR_no__c,
                                    Status__c = al.Status_x__c,
                                    VAS_OFFBTC5__c = al.VAS_OFFBTC5__c,
                                    Termination_Point__c = al.Termination_Point__c,
                                    LAN_network_address_mask__c = al.LAN_network_address_mask__c,
                                    Order_Type__c = al.Order_Type__c,
                                    Shortnr__c = al.Shortnr__c,
                                    Extra_Contact_Person__c = al.Extra_Contact_Person__c,
                                    VAS_SIMBX4__c = al.VAS_SIMBX4__c,
                                    VAS_SIMBX7__c = al.VAS_SIMBX7__c,
                                    Extra_Equipment__c = al.Extra_Equipment__c,
                                    VAS_CORDKTOEU__c = al.VAS_CORDKTOEU__c,
                                    Last_name__c = al.Last_name__c,
                                    TSRR_Owner_Control__c = al.TSRR_Owner_Control__c,
                                    Conference__c = al.Conference__c,
                                    Exchange__c = al.Exchange__c,
                                    MultipleVPN__c = al.MultipleVPN__c,
                                    Ekstra_Data_SIM_number_4__c = al.Ekstra_Data_SIM_number_4__c,
                                    Funktionsnr__c = al.Funktionsnr__c,
                                    First_name__c = al.First_name__c,
                                    Monthly_Add_on_fee__c = al.Monthly_Add_on_fee__c,
                                    VAS_BAR4G__c = al.VAS_BAR4G__c,
                                    Circuit_ID_existing__c = al.Circuit_ID_existing__c,
                                    VAS_HBOBTC5__c = al.VAS_HBOBTC5__c,
                                    VAS_OCMUSR__c = al.VAS_OCMUSR__c,
                                    Redundancy__c = al.Redundancy__c,
                                    SNMP_community__c = al.SNMP_community__c,
                                    VAS_BARINCRO__c = al.VAS_BARINCRO__c,
                                    Delivery_Street_and_number__c = al.Delivery_Street_and_number__c,
                                    Fastnet_user__c = al.Fastnet_user__c,
                                    Access_Method__c = al.Access_Method__c,
                                    Forbrugskontrol_amount__c = al.Forbrugskontrol_amount__c,
                                    Modified_delivery_date__c = al.Modified_delivery_date__c,
                                    Administrator__c = al.Administrator__c,
                                    VAS_UDVSLABTC__c = al.VAS_UDVSLABTC__c,
                                    CPE_ID_existing__c = al.CPE_ID_existing__c,
                                    Landline_no__c = al.Landline_no__c,
                                    Circuit_ID__c = al.Circuit_ID__c,
                                    VAS_TEAMSPABA__c = al.VAS_TEAMSPABA__c,
                                    Primary_or_Secondary__c = al.Primary_or_Secondary__c,
                                    Activation__c = al.Activation__c,
                                    Billing_Account__c = al.Billing_Account__c,
                                    Contact_person_on_site__c = al.Contact_person_on_site__c,
                                    Kollegakald__c = al.Kollegakald__c,
                                    M2M__c = al.M2M__c,
                                    Manual_Product__c = al.Manual_Product__c,
                                    MBB__c = al.MBB__c,
                                    Order_Product__c = al.Order_Product__c,
                                    Power_of_Attorney_Record__c = al.Power_of_Attorney_Record__c,
                                    QoS_Realtime__c = al.QoS_Realtime__c,
                                    SLA_x__c = al.SLA_x__c,
                                    TP_License__c = al.TP_License__c,
                                    TP_Voice__c = al.TP_Voice__c,
                                    Related_Activation_Line__c = al.Related_Activation_Line__c,
                                    VAS_COR__c = al.VAS_COR__c,
                                    Number_of_IP_Addresses__c = al.Number_of_IP_Addresses__c,
                                    LAN_IP__c = al.LAN_IP__c,
                                    IP_routes__c = al.IP_routes__c,
                                    Express_Delivery__c = al.Express_Delivery__c,
                                    Dynamic_Static_Routing__c = al.Dynamic_Static_Routing__c,
                                    Dynamic_Static__c = al.Dynamic_Static__c,
                                    DHCP_server__c = al.DHCP_server__c,
                                    DHCP_range__c = al.DHCP_range__c,
                                    DHCP_DNS_Secondary__c = al.DHCP_DNS_Secondary__c,
                                    DHCP_DNS_Primary__c = al.DHCP_DNS_Primary__c,
                                    AS_no__c = al.AS_no__c,
                                    VLAN_TAG_EVPN__c = al.VLAN_TAG_EVPN__c,
                                    Trunk_no_Small_world_Dedicated__c = al.Trunk_no_Small_world_Dedicated__c,
                                    TPX_Power_Adapter__c = al.TPX_Power_Adapter__c,
                                    TPX_Deskphone__c = al.TPX_Deskphone__c,
                                    Secondary_Circuit_ID__c = al.Secondary_Circuit_ID__c,
                                    SAP_Order_number__c = al.SAP_Order_number__c,
                                    Primary_Circuit_ID__c = al.Primary_Circuit_ID__c,
                                    PO_number__c = al.PO_number__c,
                                    POI_TNID_EVPN__c = al.POI_TNID_EVPN__c,
                                    Peering_address__c = al.Peering_address__c,
                                    VAS_DUMMY2__c = al.VAS_DUMMY2__c,
                                    VAS_TMSBBAND__c = al.VAS_TMSBBAND__c,
                                    VAS_TMSMOBILE__c = al.VAS_TMSMOBILE__c,
                                    VAS_CORWB8G__c = al.VAS_CORWB8G__c,
                                    VAS_CORWA9G__c = al.VAS_CORWA9G__c,
                                    VAS_TPXRECB__c = al.VAS_TPXRECB__c,
                                    VAS_TPXREC3__c = al.VAS_TPXREC3__c,
                                    VAS_TPXREC7__c = al.VAS_TPXREC7__c,
                                    VAS_MAXBTB__c = al.VAS_MAXBTB__c,
                                    VAS_MAXSPORTB__c = al.VAS_MAXSPORTB__c,
                                    VAS_CORWA10G__c = al.VAS_CORWA10G__c,
                                    VAS_CORDKTEU4__c = al.VAS_CORDKTEU4__c,
                                    VAS_CORDKTEU5__c = al.VAS_CORDKTEU5__c, 
                                    VAS_OCCINS__c = al.VAS_OCCINS__c,
                                    VAS_OCCCON__c = al.VAS_OCCCON__c,
                                    VAS_OCCASO__c = al.VAS_OCCASO__c,
                                    VAS_OCCBAS__c = al.VAS_OCCBAS__c,
                                    VAS_OCCAAU__c = al.VAS_OCCAAU__c,
                                    VAS_OCCAAS__c = al.VAS_OCCAAS__c,
                                    VAS_OCCAAO__c = al.VAS_OCCAAO__c,
                                    VAS_OCCONB__c = al.VAS_OCCONB__c,
                                    VAS_OCCAGRECO__c = al.VAS_OCCAGRECO__c,
                                    VAS_OCCSCSTAT__c = al.VAS_OCCSCSTAT__c,
                                    VAS_OCCAVAIVA__c = al.VAS_OCCAVAIVA__c,
                                    VAS_OCCMAILDI__c = al.VAS_OCCMAILDI__c,
                                    VAS_OCCCRMINT__c = al.VAS_OCCCRMINT__c,
                                    VAS_OCCCCWGRM__c = al.VAS_OCCCCWGRM__c,
                                    VAS_OCCCCENTM__c = al.VAS_OCCCCENTM__c,
                                    VAS_OCCQUAMON__c = al.VAS_OCCQUAMON__c,
                                    VAS_OCCCLBACK__c = al.VAS_OCCCLBACK__c,
                                    VAS_OCCIVREXP__c = al.VAS_OCCIVREXP__c,
                                    VAS_OCCMOBPGW__c = al.VAS_OCCMOBPGW__c,
                                    VAS_OCCCCWGRV__c = al.VAS_OCCCCWGRV__c,
                                    VAS_OCCCCENTV__c = al.VAS_OCCCCENTV__c,
                                    VAS_OCCOFFCLI__c = al.VAS_OCCOFFCLI__c,
                                    VAS_OCCATTCON__c = al.VAS_OCCATTCON__c, 
                                    VAS_TSPBRONZE__c = al.VAS_TSPBRONZE__c,
                                    VAS_TSPSOLV__c = al.VAS_TSPSOLV__c,
                                    VAS_TSPGULD__c = al.VAS_TSPGULD__c,
                                    VAS_FINTDKEU__c = al.VAS_FINTDKEU__c,
                                    VAS_OCFUSR__c = al.VAS_OCFUSR__c,
                                    VAS_OCFUSUS__c = al.VAS_OCFUSUS__c,
                                    VAS_OCFSERVUS__c = al.VAS_OCFSERVUS__c
                                )
                            );
                        }
                    }
                }
            }

            if (QuoteLineDetailCreateList.size() > 0) {
                QuoteLineDetailsService.disableQuantityCounting = true;
                insert QuoteLineDetailCreateList;
                //system.debug(QuoteLineDetailCreateList)    ;
            }
        } catch (Exception e) {
            System_Log__c logerror = new System_Log__c(
                Origin__c = 'Apex',
                Error_Body__c = e.getMessage(),
                Additional_Information__c = 'Quote_line_detail_Create'
            );
            //insert logerror;
        }
    }

    public void finish(Database.BatchableContext BC) {
        //update the quote  QuoteLineDetailsCreated__c = true
        //List<SBQQ__Quote__c> QuoteRecord= [SELECT Id  from SBQQ__Quote__c where Id in :recordsId ];

        SBQQ__Quote__c updateQuote = new SBQQ__Quote__c(Id = recordsId[0], QuoteLineDetailsCreated__c = true);
        update updateQuote;
    }
}