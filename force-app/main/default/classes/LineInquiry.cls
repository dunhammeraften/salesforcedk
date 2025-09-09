public without sharing class LineInquiry {

    public class DawaRes {
    	public String kategori;
	}

	public static DawaRes parse(String json) {
		return (DawaRes) System.JSON.deserialize(json, DawaRes.class);
	}
	

    public static Location_Line__c theCall(Location_Line__c line) {
        String fullAddress = EncodingUtil.urlEncode((String) line.get('Address__c'), 'UTF-8');               
        HttpRequest req = new HttpRequest(); 
        req.setEndpoint('https://api.dataforsyningen.dk/datavask/adresser?betegnelse=' + fullAddress); 
        req.setMethod('GET'); 
        Http http = new Http(); 
        HTTPResponse res = http.send(req); 
        DawaRes obj = DawaRes.parse(res.getBody());

        line.addressWash_Category__c = obj.kategori;
        if (obj.kategori == 'A') {
            line.Address_Wash_Status__c = 'Valid';
        } else {
            line.Address_Wash_Status__c = 'Not Valid';   
        }
        
        return line;
    }

    @InvocableMethod(label='Line Inquiry Address Wash' description='CALL DAWA.' callout=true)
    public static void callDawa(List<List<Location_Line__c>> locations) {       
        List<Location_Line__c> als = new List<Location_Line__c>();
        
        for (List<Location_Line__c> location : locations) {
            for (Location_Line__c line : location) {
                Location_Line__c result = theCall(line);
                als.add(result);
            }
        }

        update als;
    }    
}