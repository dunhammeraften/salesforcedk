/**
 * The NumberClient class is a client for interacting with the Number API service.
 * It handles phone number management operations including details lookup, reservation, and port orders.
 *  -----------------------------------------------------------------------------
 *  Developer            Date            Description
 *  -----------------------------------------------------------------------------
 *  Kenneth Houkjær         27/07/2025      Initial version
 *
 * @author Kenneth Houkjær
 * @date 27/07/2025
 */
public virtual with sharing class NumberClient extends HTTPClient {
    /**
     * @description Named credential used for authentication with the Number API
     */
    private static final String NAMED_CREDENTIAL = NamedCredentialService.getNamedCredential('NumberApi');

    /**
     * @description Endpoint for retrieving number details by MSISDN
     */
    private static final String ENDPOINT_GET_NUMBER_DETAIL_BY_MSISDN = OrgUtils.getCompanySettingsConfigurationValueByDeveloperName(
        'endpointNumberClientnumberByMsisdn'
    );

    /**
     * @description Endpoint for reserving a number by MSISDN
     */
    private static final String ENDPOINT_RESERVE_NUMBER_BY_MSISDN = OrgUtils.getCompanySettingsConfigurationValueByDeveloperName(
        'endpointNumberClientreserveByMsisdn'
    );

    /**
     * @description Endpoint for unreserving a number by MSISDN
     */
    private static final String ENDPOINT_UNRESERVE_NUMBER_BY_MSISDN = OrgUtils.getCompanySettingsConfigurationValueByDeveloperName(
        'endpointNumberClientunreserveByMsisdn'
    );

    /**
     * @description Endpoint for retrieving multiple numbers
     */
    private static final String ENDPOINT_GET_NUMBERS = OrgUtils.getCompanySettingsConfigurationValueByDeveloperName(
        'endpointNumberClientgetNumbers'
    );

    /**
     * @description Endpoint for retrieving port orders by MSISDNs
     */
    private static final String ENDPOINT_PORT_ORDERS_BY_MSISDNS = OrgUtils.getCompanySettingsConfigurationValueByDeveloperName(
        'endpointNumberClientportOrdersByMsisdn'
    );

    /**
     * @description Constructor initializing the client with named credential authentication
     */
    public NumberClient() {
        super(NAMED_CREDENTIAL);
    }

    /**
     * Retrieves detailed information about a specific phone number
     * @param msisdn The MSISDN (Mobile Subscriber Integrated Services Digital Number) to query
     * @return NumberDetailResponse containing the number details
     * @throws HTTPException if the API returns an error status (400, 404, 406, 500)
     */
    public NumberClientResponseDTO.NumberDetail getNumberDetailByMsisdn(String msisdn) {
        Logger.logInfo(String.format('getNumberDetailByMsisdn( {0} )', new List<Object>{msisdn}));
        
        String endPoint = String.format(ENDPOINT_GET_NUMBER_DETAIL_BY_MSISDN, new List<Object>{ msisdn });
        HttpResponse response = get(endPoint);

        switch on response.getStatusCode() {
            when 200 {
                return getNumberDetail(response.getBody());
            }
            when 400, 404, 406, 500 {
                HTTPException httpEx = new HTTPException(response);
                NumberClientResponseDTO.NumberError errorResponse = getNumberDetail(response.getBody()).error;
                httpEx.setMessage(errorResponse.toString());
                throw httpEx;
            }
            when else {
                throw new HTTPException(response);
            }
        }
    }
  
    /**
     * Reserves a phone number for future use
     * @param msisdn The MSISDN to reserve
     * @param accountCVR Account CVR number (optional)
     * @return NumberDetailResponse containing the reserved number details
     * @throws HTTPException if the API returns an error status (400, 404, 406, 500)
     */
    public virtual NumberClientResponseDTO.NumberDetail reserveNumberDetailByMsisdnAndCVR(String msisdn, String accountCVR, String productType) {
        Logger.logInfo(String.format('reserveNumberDetailByMsisdn( {0} )', new List<Object>{msisdn}));

        String endPoint = String.format(ENDPOINT_RESERVE_NUMBER_BY_MSISDN, new List<Object>{ msisdn });

        //Prepare request body with GSM product type
        NumberClientRequestDTO.NumberReservation requestObject = new NumberClientRequestDTO.NumberReservation();
       
        if(String.isNotBlank(productType)){
            requestObject.productType = productType.toUpperCase();
        }

        if(String.isNotBlank(accountCVR)){
            requestObject.cvr = accountCVR;
        }

        String requestBody = JSON.serialize(requestObject);

        HttpResponse response = put(endPoint, requestBody);

        switch on response.getStatusCode() {
            when 200, 201 {
                return getNumberDetail(response.getBody());
            }
            when 400, 404, 406, 500 {
                HTTPException httpEx = new HTTPException(response);
                NumberClientResponseDTO.NumberError errorResponse = getNumberDetail(response.getBody()).error;
                httpEx.setMessage(errorResponse.toString());
                throw httpEx;
            }
            when else {
                Logger.logInfo('Unexpected error code returned from service.');
                throw new HTTPException(response);
            }
        }
    }

    /**
     * Unreserves a previously reserved phone number
     * @param msisdn The MSISDN to unreserve
     * @return NumberDetailResponse containing the unreserved number details
     * @throws HTTPException if the API returns an error status (400, 404, 406, 500)
     */
    public NumberClientResponseDTO.NumberDetail unreserveNumberDetailByMsisdn(String msisdn) {
        Logger.logInfo(String.format('unreserveNumberDetailByMsisdn( {0} )', new List<Object>{msisdn}));
        
        String endPoint = String.format(ENDPOINT_UNRESERVE_NUMBER_BY_MSISDN, new List<Object>{ msisdn });

        HttpResponse response = put(endPoint, null);

        switch on response.getStatusCode() {
            when 200, 201 {
                return getNumberDetail(response.getBody());
            }
            when 400, 404, 406, 500 {
                HTTPException httpEx = new HTTPException(response);
                NumberClientResponseDTO.NumberError errorResponse = getNumberDetail(response.getBody()).error;
                httpEx.setMessage(errorResponse.toString());
                throw httpEx;
            }
            when else {
                throw new HTTPException(response);
            }
        }
    }

    /**
     * Retrieves a list of numbers based on provided criteria
     * @param request NumberDetailsRequest containing filter parameters
     * @return NumberDetailsResponse containing the filtered number list
     * @throws HTTPException if the API returns an error status (400, 404, 406, 500)
     */
    public NumberClientResponseDTO.NumberDetails getNumberDetails(NumberClientRequestDTO.NumberDetails details) {
        Logger.logInfo(String.format('getNumberDetails( {0} )', new List<Object>{details}));
        
        String endPoint = String.format(ENDPOINT_GET_NUMBERS, new List<Object>{ getQueryParameters(details) });
        HttpResponse response = get(endPoint);

        switch on response.getStatusCode() {
            when 200 {
                return getNumberDetails(response.getBody());
            }
            when 400, 404, 406, 500 {
                HTTPException httpEx = new HTTPException(response);
                NumberClientResponseDTO.NumberError errorResponse = getNumberDetails(response.getBody()).error;
                httpEx.setMessage(errorResponse.toString());
                throw httpEx;
            }
            when else {
                throw new HTTPException(response);
            }
        }
    }

    /**
     * Retrieves port order information for multiple MSISDNs
     * @param msisdns List of MSISDNs to query port order information for
     * @return PortOrdersResponse containing port order details
     * @throws HTTPException if the API returns an error status (400, 404, 406, 500)
     */
    public NumberClientResponseDTO.PortOrders getPortOrdersByMsisdns(List<String> msisdns) {
        Logger.logInfo(String.format('getNumberDetails( {0} )', new List<Object>{msisdns}));
        
        String endPoint = String.format(
            ENDPOINT_PORT_ORDERS_BY_MSISDNS,
            new List<Object>{ 'ids=' + String.join(msisdns, ',') }
        );

        HttpResponse response = get(endPoint);

        switch on response.getStatusCode() {
            when 200 {
                return getPortOrders(response.getBody());
            }
            when 400, 404, 406, 500 {
                HTTPException httpEx = new HTTPException(response);
                NumberClientResponseDTO.NumberError errorResponse = getPortOrders(response.getBody()).error;
                httpEx.setMessage(errorResponse.toString());
                throw httpEx;
            }
            when else {
                throw new HTTPException(response);
            }
        }
    }

    /**
     * This method constructs a query string from a NumberClientRequestDTO.NumberDetails object.
     * @param detail The NumberClientRequestDTO.NumberDetails object.
     * @return A string of query parameters.
     */
    private String getQueryParameters(NumberClientRequestDTO.NumberDetails detail) {
        String urlQueryParameters = 'product_type=' + detail.product_type;

        if (String.isNotBlank(detail.numberGroup)) {
            urlQueryParameters += '&number_group=' + detail.numberGroup;
        }
        if (String.isNotBlank(detail.numberLocation)) {
            urlQueryParameters += '&number_location=' + detail.numberLocation;
        }
        if (String.isNotBlank(detail.numberStatus)) {
            urlQueryParameters += '&number_status=' + detail.numberStatus;
        }
        if (detail.amountOfNumbers > 0) {
            urlQueryParameters += '&page_size=' + detail.amountOfNumbers;
        }
        if (String.isNotBlank(detail.cvr)) {
            urlQueryParameters += '&cvr=' + detail.cvr;
        }
        if (String.isNotBlank(detail.numberPattern)) {
            // pattern search is exposed by the Number API to search for numbers in format 04512345678
            // to avoid forcing clients to always add initial ___ or 045 to search in the actual number part,
            // we always prefix with ___ here
            urlQueryParameters += '&number_pattern=___' + detail.numberPattern;
        }

        return urlQueryParameters;
    }

    /**
     * Deserializes a JSON response into a NumberDetailsResponse object
     * Handles reserved keyword 'number' by replacing it with 'phoneNumber'
     * @param responseBody The JSON string to deserialize
     * @return Parsed NumberDetailsResponse object
     */
    private NumberClientResponseDTO.NumberDetails getNumberDetails(String responseBody) {
        String safeToDeserializeResponseBody = responseBody.replace('"number":', '"phoneNumber":');
        return (NumberClientResponseDTO.NumberDetails) System.JSON.deserialize(
            safeToDeserializeResponseBody,
            NumberClientResponseDTO.NumberDetails.class
        );
    }

    /**
     * Deserializes a JSON response into a NumberDetailResponse object
     * Handles reserved keyword 'number' by replacing it with 'phoneNumber'
     * @param responseBody The JSON string to deserialize
     * @return Parsed NumberDetailResponse object
     */
    private NumberClientResponseDTO.NumberDetail getNumberDetail(String responseBody) {
        String safeToDeserializeResponseBody = responseBody.replace('"number":', '"phoneNumber":');
        return (NumberClientResponseDTO.NumberDetail) System.JSON.deserialize(
            safeToDeserializeResponseBody,
            NumberClientResponseDTO.NumberDetail.class
        );
    }

    /**
     * Deserializes a JSON response into a PortOrdersResponse object
     * Handles reserved keyword 'number' by replacing it with 'phoneNumber'
     * @param responseBody The JSON string to deserialize
     * @return Parsed PortOrdersResponse object
     */
    private NumberClientResponseDTO.PortOrders getPortOrders(String responseBody) {
        String safeToDeserializeResponseBody = responseBody.replace('"number":', '"phoneNumber":');
        return (NumberClientResponseDTO.PortOrders) System.JSON.deserialize(
            safeToDeserializeResponseBody,
            NumberClientResponseDTO.PortOrders.class
        );
    }

    
    public class NumberClientMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"data":{"id":"12345"}}');
            res.setStatusCode(200);
            return res;
        }
    }

}