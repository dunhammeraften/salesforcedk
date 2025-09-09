public with sharing class NumberService {
    private static final String PRODUCT_TYPE_GSM = 'GSM';
    private static String namedCredential = NamedCredentialService.getNamedCredential('NumberApi');
    private static ErrorLogging logs = new ErrorLogging('Apex');

    public static NumberResDAO.NumberDetails getNumberDetails(GetNumbersParameterbuilder parameters) {
        HttpRequest request = new HttpRequest();
        String urlQueryParameters = parameters.build();
        request.setEndpoint('callout:' + namedCredential + '?' + urlQueryParameters);
        request.setMethod('GET');
        setDefaultHeader(request);

        NumberResDAO.NumberDetails numberDetails = new NumberResDAO.NumberDetails();
        HttpResponse response;
        try {
            response = new http().send(request);
            numberDetails = (NumberResDAO.NumberDetails)JSON.deserialize(getApexSafeBody(response.getBody()), NumberResDAO.NumberDetails.class);
        } catch(Exception ex) {
            numberDetails.error = setErrorFieldsFromHttpResponseAndException(numberDetails.error, response, ex);
            insertSystemLog(ex, 'getNumberDetails');
        }

        return numberDetails;
    }

    public class GetNumbersParameterbuilder {
        String numberGroup;
        String numberLocation;
        Integer amountOfNumbers;
        String numberStatus;
        String cvr;
        String numberPattern;

        public GetNumbersParameterbuilder withNumberGroup(String numberGroup) {
            this.numberGroup = numberGroup;
            return this;
        }

        public GetNumbersParameterbuilder withNumberLocation(String numberLocation) {
            this.numberLocation = numberLocation;
            return this;
        }

        public GetNumbersParameterbuilder withAmountOfNumbers(Integer amountOfNumbers) {
            this.amountOfNumbers = amountOfNumbers;
            return this;
        }

        public GetNumbersParameterbuilder withNumberStatus(String numberStatus) {
            this.numberStatus = numberStatus;
            return this;
        }

        public GetNumbersParameterbuilder withCvr(String cvr) {
            this.cvr = cvr;
            return this;
        }

        public GetNumbersParameterbuilder withNumberPattern(String numberPattern) {
            this.numberPattern = numberPattern;
            return this;
        }

        public String build() {
            String urlQueryParameters = 'product_type=' + PRODUCT_TYPE_GSM;
            if(String.isNotBlank(this.numberGroup)) {
                urlQueryParameters += '&number_group=' + this.numberGroup;
            }
            if(String.isNotBlank(this.numberLocation)) {
                urlQueryParameters += '&number_location=' + this.numberLocation;
            }
            if(String.isNotBlank(this.numberStatus)) {
                urlQueryParameters += '&number_status=' + this.numberStatus;
            }
            if(this.amountOfNumbers > 0) {
                urlQueryParameters += '&page_size=' + this.amountOfNumbers;
            }
            if(String.isNotBlank(this.cvr)) {
                urlQueryParameters += '&cvr=' + this.cvr;
            }
            if(String.isNotBlank(this.numberPattern)) {
                // pattern search is exposed by the Number API to search for numbers in format 04512345678
                // to avoid forcing clients to always add initial ___ or 045 to search in the actual number part,
                // we always prefix with ___ here
                urlQueryParameters += '&number_pattern=___' + this.numberPattern;
            }

            return urlQueryParameters;
        }
    }

    public static NumberResDAO.NumberDetail getNumberDetailByMsisdn(String msisdn) {
        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:' + namedCredential + '/' + msisdn);
        request.setMethod('GET');
        setDefaultHeader(request);

        NumberResDAO.NumberDetail numberDetail = new NumberResDAO.NumberDetail();
        HttpResponse response;
        try {
            response = new http().send(request);
            numberDetail = (NumberResDAO.NumberDetail)JSON.deserialize(getApexSafeBody(response.getBody()), NumberResDAO.NumberDetail.class);
        } catch(Exception ex) {
            numberDetail.error = setErrorFieldsFromHttpResponseAndException(numberDetail.error, response, ex);
            insertSystemLog(ex, 'getNumberDetailByMsisdn');
        }

        return numberDetail;
    }

    public static NumberResDAO.NumberDetail reserveNumberByMsisdn(String msisdn) {
        return reserveNumberByMsisdn(msisdn, true);
    }

    public static NumberResDAO.NumberDetail reserveNumberByMsisdn(String msisdn, Boolean doLogInsert) {
        HttpRequest request = new HttpRequest();

        request.setEndpoint('callout:' + namedCredential + '/' + msisdn + '/reserve');
        request.setMethod('PUT');
        setDefaultHeader(request);

        NumberReqDAO.ReserveNumber requestObject = new NumberReqDAO.ReserveNumber();
        requestObject.productType = PRODUCT_TYPE_GSM;
        String requestBody = JSON.serializePretty(requestObject);
        request.setBody(requestBody);

        NumberResDAO.NumberDetail numberDetail = new NumberResDAO.NumberDetail();
        HttpResponse response;
        try {
            response = new http().send(request);
            numberDetail = (NumberResDAO.NumberDetail)JSON.deserialize(getApexSafeBody(response.getBody()), NumberResDAO.NumberDetail.class);
        } catch(Exception ex) {
            numberDetail.error = setErrorFieldsFromHttpResponseAndException(numberDetail.error, response, ex);
            if(doLogInsert) {
                insertSystemLog(ex, 'reserveNumberByMsisdnAndCvr');
            }
        }

        return numberDetail;
    }

    public static NumberResDAO.NumberDetail unreserveNumberByMsisdn(String msisdn) {
        return unreserveNumberByMsisdn(msisdn, true);
    }

    public static NumberResDAO.NumberDetail unreserveNumberByMsisdn(String msisdn, Boolean doLogInsert) {
        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:' + namedCredential + '/' + msisdn + '/unreserve');
        request.setMethod('PUT');
        setDefaultHeader(request);

        NumberResDAO.NumberDetail numberDetail = new NumberResDAO.NumberDetail();
        HttpResponse response;
        try {
            response = new http().send(request);
            numberDetail = (NumberResDAO.NumberDetail)JSON.deserialize(getApexSafeBody(response.getBody()), NumberResDAO.NumberDetail.class);
        } catch(Exception ex) {
            numberDetail.error = setErrorFieldsFromHttpResponseAndException(numberDetail.error, response, ex);
            if(doLogInsert) {
                insertSystemLog(ex, 'unreserveNumberByMsisdn');
            }
        }

        return numberDetail;
    }

    /*
    This is not used anywhere for now, but is supported by the Number API, so it is implemented to be available for future use
    */
    public static NumberResDAO.PortOrders getPortOrdersByMsisdns(List<String> msisdns) {
        String commaSeparatedMsisdns = String.join(msisdns, ',');

        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:' + namedCredential + '/port_orders?ids=' + commaSeparatedMsisdns);
        request.setMethod('GET');
        setDefaultHeader(request);
        
        NumberResDAO.PortOrders portOrders = new NumberResDAO.PortOrders();
        HttpResponse response;
        try {
            response = new http().send(request);
            portOrders = (NumberResDAO.PortOrders)JSON.deserialize(response.getBody(), NumberResDAO.PortOrders.class);
        } catch(Exception ex) {
            portOrders.error = setErrorFieldsFromHttpResponseAndException(portOrders.error, response, ex);
            insertSystemLog(ex, 'getPortOrdersByMsisdns');
        }

        return portOrders;
    }

    private static void setDefaultHeader(HttpRequest request) {
        request.setHeader('Accept', 'application/json'); //to use API v3 set to application/vnd.telia.dk-v3+json
        request.setHeader('x-application-id', 'salesforce'); //only 'admin' is allowed for API v3 for now, if switching to v3, then we should request salesforce as a valid value
    }

    // number is a reserved keywork in Apex so we replace with phoneNumber to be able to deserialize
    // only needed in API v2 for responses to be deserialized using NumberResDAO.NumberData object
    private static String getApexSafeBody(String body) {
        return body.replace('"number":', '"phoneNumber":');
    }

    private static void insertSystemLog(Exception ex, String methodName) {
        logs.addError(ex.getMessage(), NumberService.class.getName() + '.' + methodName);
        logs.logErrors();
    }

    private static NumberResDAO.error setErrorFieldsFromHttpResponseAndException(NumberResDAO.error error, HttpResponse response, Exception ex) {
        if(error == null) {
            error = new NumberResDAO.Error();
        }
        error.code = response?.getStatusCode();
        error.message = ex.getMessage();

        return error;
    }
}