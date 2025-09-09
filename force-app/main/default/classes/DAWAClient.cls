public with sharing class DAWAClient extends HTTPClient {
    private static final String NAMED_CREDENTIAL = 'DawaProd';

    //private static final Endpoint__mdt endpoint = Endpoint__mdt.getInstance('DAWAClient');

    //datavask/adresser?betegnelse={0}
    private static final String endpointAddresseVask = '/datavask/adresser?betegnelse={0}';//endpoint.Path__c;

    /**
     * @description Internal custom exception used by this class for errors
     */
    public class ApiException extends Exception {
    }

    /**
     * @description Parses the provided JSON string into DAWADataVaskDTO object
     * @param json Incoming JSON string. Often from an api call's results.
     */
    public DAWADataVaskDTO parse(String json) {
        try {
            return (DAWADataVaskDTO) System.JSON.deserialize(json, DAWADataVaskDTO.class);
        } catch (System.JSONException jse) {
            throw new DAWAClient.ApiException(jse.getMessage());
        }
    }

    public DAWAClient() {
        super(NAMED_CREDENTIAL);
    }

    public DAWADataVaskDTO addresseVask(String address) {
        Logger.logFinest(String.format('addresseVask( {0} )', new List<Object>{ address }));

        String dataVaskEndpoint = String.format(endpointAddresseVask, new List<Object>{ EncodingUtil.urlEncode(address, 'UTF-8') });

        HttpResponse response = get(dataVaskEndpoint);

        switch on response.getStatusCode() {
            when 200 {
                return parse(response.getBody());
            }
            // Handle other response codes like 30x as well
            when 404 {
                throw new DAWAClient.ApiException('404 error!');
            }
            when else {
                throw new DAWAClient.ApiException('Unexpected Response code: ' + response.getStatusCode());
            }
        }
    }

    /**
     * @description This class contains the 'data transfer object' details.
     * Data transfer objects are used to serialize Apex objects to JSON and
     * web service response JSON to Apex objects.
     *
     * It's not neccesary for it to be an internal class
     */
    public class DAWADataVaskDTO {
        /**
         * These properties represent the JSON keys that we need
         * to send or receive.
         */
        public String kategori;
        public List<DAWADataVaskResultat> resultater;
    }

    /**
     * @description example of how to model a nested JSON object
     */
    public class DAWADataVaskResultat {
        public Address adresse;
    }

    public class Address {
        public String id;
        public String vejnavn;
        public String adresseringsvejnavn;
        public String husnr;
    }
}