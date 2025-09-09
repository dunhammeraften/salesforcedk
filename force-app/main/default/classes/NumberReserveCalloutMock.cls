/**
 * The NumberReserveCalloutMock class is a mock class for the Number API callout.
 * It is used for testing purposes to simulate a successful response from the Number API.
 *  -----------------------------------------------------------------------------
 *  Developer            Date            Description
 *  -----------------------------------------------------------------------------
 *  Kenneth Houkjær         27/07/2025      Initial version
 *
 * @author Kenneth Houkjær
 * @date 27/07/2025
 */
@isTest
global class NumberReserveCalloutMock implements HttpCalloutMock {
    /**
     * @description This method is called by the test framework to get the response for the callout.
     * @param req The request that is being sent.
     * @return The response to the callout.
     */
    global HttpResponse respond(HttpRequest req) {
        HttpResponse res = new HttpResponse();
        res.setStatusCode(200);
        res.setBody('{"data": {"phoneNumber": "Reserved", "numberStatus": "Reserved"}}');
        return res;
    }
}