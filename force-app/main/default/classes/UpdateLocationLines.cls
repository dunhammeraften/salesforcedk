/**
 *
 * @author Frederik
 *
 * @author by Mujahid
 * @since 22/06/2022
 * @description UpdateLocationLines find relevant POQ Item record and update the OTC products and few extra flags that are needed for order api in the location line record
 */
public without sharing class UpdateLocationLines {
    private static final String DSL_INSTALLATION = 'CHXT01';
    private static final String COAX_INSTALLATION = 'CHXT08';
    private static final String FIBER_INSTALLATION_A_DIGGING = 'CHXT02';
    private static final String FIBER_INSTALLATION_A = 'CHXT03';
    private static final String FIBER_INSTALLATION_B_DIGGING = 'CHXT04';
    private static final String FIBER_INSTALLATION_B = 'CHXT05';
    private static final String FIBER_INSTALLATION_C_DIGGING = 'CHXT06';
    private static final String FIBER_INSTALLATION_C = 'CHXT07';
    private static final String FIBER_INSTALLATION_D_DIGGING = 'CHXT11';
    private static final String FIBER_INSTALLATION_D = 'CHXT12';
    
    private static Map<String, String> productMapWithDigging = new Map<String, String>{
        'FIBHOF03' => FIBER_INSTALLATION_A_DIGGING,
        'FIBHOF02' => FIBER_INSTALLATION_A_DIGGING,
        'FIBHOF06' => FIBER_INSTALLATION_B_DIGGING,
        'FIBHOF05' => FIBER_INSTALLATION_B_DIGGING,
        'FIBHOF09' => FIBER_INSTALLATION_C_DIGGING,
        'FIBHOF08' => FIBER_INSTALLATION_C_DIGGING,
        'FIBHOF10' => FIBER_INSTALLATION_A_DIGGING,
        'FIBHOF11' => FIBER_INSTALLATION_B_DIGGING,
        'FIBHOF12' => FIBER_INSTALLATION_C_DIGGING,
        'FIBHOF13' => FIBER_INSTALLATION_D_DIGGING,
        'FIBHOF14' => FIBER_INSTALLATION_D_DIGGING,
        'FIBHOF15' => FIBER_INSTALLATION_D_DIGGING
    };

    private static Map<String, String> productMapWithoutDigging = new Map<String, String>{
        'FIBHOF03' => FIBER_INSTALLATION_A,
        'FIBHOF02' => FIBER_INSTALLATION_A,
        'FIBHOF06' => FIBER_INSTALLATION_B,
        'FIBHOF05' => FIBER_INSTALLATION_B,
        'FIBHOF09' => FIBER_INSTALLATION_C,
        'FIBHOF08' => FIBER_INSTALLATION_C,
        'COAHOF03' => COAX_INSTALLATION,
        'COAHOF02' => COAX_INSTALLATION,
        'DSLHOF01' => DSL_INSTALLATION,
        'FIBHOF10' => FIBER_INSTALLATION_A,
        'FIBHOF11' => FIBER_INSTALLATION_B,
        'FIBHOF12' => FIBER_INSTALLATION_C,
        'FIBHOF13' => FIBER_INSTALLATION_D,
        'FIBHOF14' => FIBER_INSTALLATION_D,
        'FIBHOF15' => FIBER_INSTALLATION_D
    };

    @InvocableMethod(label='Update Location Lines from POQ Items' description='Update Location Lines from POQ Items' callout=false)
    public static void finalUpdate(List<Opportunity> opps) {
        Map<String, Location_Line__c> linesById = getLocationLinesByOpp(opps);

        List<Location_Line__c> linesToBeUpdated = new List<Location_Line__c>();

        for (POQ_item__c item : [
            SELECT
                Id,
                DIGGING_NEEDED__c,
                Location_Line__c,
                priceplanCode__c,
                plugPresentPositiveValidation__c,
                plugTechnicianRequired__c,
                Active_Blocking_Line_Present__c,
                VendorProductCode__c,
			    VendorProductCatalogId__c,
                AddressRefId__c,
                lineConnectionStatus__c,
                lineProvider__c,
                SiteId__c
            FROM POQ_Item__c
            WHERE Location_Line__c IN :linesById.keySet()
        ]) {
            Location_Line__c line = linesById.get(item.Location_Line__c);
            if (line != null && line.Subscription_product__c == item.priceplanCode__c) {
                line.plugPresentPositiveValidation__c = item.plugPresentPositiveValidation__c;
                line.Plug_Technician_Required__c = item.plugTechnicianRequired__c;
                line.Active_Blocking_Line_Present__c = item.Active_Blocking_Line_Present__c;
                line.OTC_product__c = getOTCProduct(item, line);
                line.VendorProductCode__c = item.VendorProductCode__c;
                line.VendorProductCatalogId__c = item.VendorProductCatalogId__c;
                line.AddressRefId__c = item.AddressRefId__c;
                line.lineConnectionStatus__c = item.lineConnectionStatus__c;
                line.lineProvider__c = item.lineProvider__c;
                line.SiteId__c = item.SiteId__c;
                linesToBeUpdated.add(line);
            }
        }

        update linesToBeUpdated;
    }

    @TestVisible
    private static Map<String, Location_Line__c> getLocationLinesByOpp(List<Opportunity> opps) {
        Map<String, Location_Line__c> linesById = new Map<String, Location_Line__c>();
        for (Location_Line__c line : [
            SELECT Id, OTC_product__c, Subscription_product__c, plugPresentPositiveValidation__c, Plug_Technician_Required__c, Active_Blocking_Line_Present__c, VendorProductCode__c, VendorProductCatalogId__c, AddressRefId__c, lineConnectionStatus__c, lineProvider__c, siteId__c
            FROM Location_Line__c
            WHERE Opportunity__c = :opps.get(0).Id
        ]) {
            line.OTC_product__c = null;
            line.plugPresentPositiveValidation__c = false;
            line.Plug_Technician_Required__c = false;
            line.Active_Blocking_Line_Present__c = false;
            line.VendorProductCode__c = null;
            line.VendorProductCatalogId__c = null;
            line.AddressRefId__c = null;
            line.lineConnectionStatus__c = null;
            line.lineProvider__c = null;
            line.SiteId__c = null;
            linesById.put(line.Id, line);
        }
        update linesById.values();
        return linesById;
    }

    @TestVisible
    private static String getOTCProduct(POQ_Item__c item, Location_Line__c line) {
        if (line.Subscription_product__c == item.priceplanCode__c) {
            // OTC Products should be assigned depending on the DIGGING_NEEDED
            String productCode = line.Subscription_product__c;

            if (item.plugTechnicianRequired__c == true) {
                if (item.DIGGING_NEEDED__c == false) {
                    return productMapWithoutDigging.get(productCode);
                } else {
                    return productMapWithDigging.get(productCode);
                }
            } else {
                // plugTechnicianRequired__c false
                if (item.DIGGING_NEEDED__c == true) {
                    return productMapWithDigging.get(productCode);
                }
            }
        }
        return null;
    }
}