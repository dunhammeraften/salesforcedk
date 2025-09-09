@isTest
private inherited sharing class HTTPClientTest {
    /**
     * The HTTPClient class is intended to be extended
     * by API Service classes. See CovidTrackerAPIService for an example
     * Because the HTTPClient class is extended, these tests cover the
     * constructors and static convience methods. This class also tests
     * a few instance convience methods that our example API Service
     * class does not utilize.
     */

    /**
     * @description Executes a positive test case of the Constructor.
     * Expects the named credential to be set.
     */
    @isTest
    static void testConstructorPositive() {
        HTTPClient rc;

        Test.startTest();
        rc = new HTTPClient('dummyNamedCredential');
        Test.stopTest();

        System.Assert.areEqual(
            'dummyNamedCredential',
            rc.namedCredentialName,
            'Expected the name credential to match'
        );
    }

    /**
     * Note: we do not have a constructor test for the no param
     * constructor. Because it's access modifier is protected
     * we cannot use that constructor - the compiler throws an error
     * noting the method is not visible
     */

    /**
     * @description Executes a positive test case against the HTTPClients'
     * makeApiCall method, this time specifying all the method params
     */
    @isTest
    static void testStaticMakeApiCallFullParamsPositive() {
        HttpResponseMock mock = new HttpResponseMock(
            200,
            'OK',
            'OK',
            new Map<String, String>()
        );
        Test.setMock(HttpCalloutMock.class, mock);

        Test.startTest();
        HttpResponse response = HTTPClient.makeApiCall(
            'DummyNamedCredential',
            HTTPClient.HttpVerb.GET,
            '/',
            '',
            '',
            null
        );
        Test.stopTest();

        System.Assert.areEqual(
            200,
            response.getStatusCode(),
            'Expected the return status code to be 200'
        );
    }

    @isTest
    static void testStaticMakeApiCallNoHeadersoOrBodyParamsPositive() {
        HttpResponseMock mock = new HttpResponseMock(
            200,
            'OK',
            'OK',
            new Map<String, String>()
        );
        Test.setMock(HttpCalloutMock.class, mock);

        Test.startTest();
        HttpResponse response = HTTPClient.makeApiCall(
            'DummyNamedCredential',
            HTTPClient.HttpVerb.GET,
            '/',
            ''
        );
        Test.stopTest();

        System.Assert.areEqual(
            200,
            response.getStatusCode(),
            'Expected the return status code to be 200'
        );
    }

    @isTest
    static void testStaticMakeApiCallNoHeadersoOrBodyOrQueryParamsPositive() {
        HttpResponseMock mock = new HttpResponseMock(
            200,
            'OK',
            'OK',
            new Map<String, String>()
        );
        Test.setMock(HttpCalloutMock.class, mock);

        Test.startTest();
        HttpResponse response = HTTPClient.makeApiCall(
            'DummyNamedCredential',
            HTTPClient.HttpVerb.GET,
            '/'
        );
        Test.stopTest();

        System.Assert.areEqual(
            200,
            response.getStatusCode(),
            'Expected the return status code to be 200'
        );
    }

    /**
     * Convience, Instance Methods
     * These 6 methods are not utilized by our API service
     * class.
     */

    /**
     * @description Postive test case for covienence method needing only
     * path and query params.
     */
    @isTest
    static void testGetWithPathAndQueryPositive() {
        HTTPClient rc = new HTTPClient('DummyNamedCredential');
        HttpResponseMock mock = new HttpResponseMock(
            200,
            'OK',
            'OK',
            new Map<String, String>()
        );
        Test.setMock(HttpCalloutMock.class, mock);

        Test.startTest();
        HttpResponse response = rc.get('/', '?test');
        Test.stopTest();

        System.Assert.areEqual(
            200,
            response.getStatusCode(),
            'Expected to get the 200 response code'
        );
    }

    @isTest
    static void testDelWithPathPositive() {
        HTTPClient rc = new HTTPClient('DummyNamedCredential');
        HttpResponseMock mock = new HttpResponseMock(
            200,
            'OK',
            'OK',
            new Map<String, String>()
        );
        Test.setMock(HttpCalloutMock.class, mock);

        Test.startTest();
        HttpResponse response = rc.del('/');
        Test.stopTest();

        System.Assert.areEqual(
            200,
            response.getStatusCode(),
            'Expected to get the 200 response code'
        );
    }

    @isTest
    static void testPostWithPathQueryAndBodyPositive() {
        HTTPClient rc = new HTTPClient('DummyNamedCredential');
        HTTPResponseMock mock = new HTTPResponseMock(
            201,
            'OK',
            'OK',
            new Map<String, String>()
        );
        Test.setMock(HttpCalloutMock.class, mock);

        Test.startTest();
        HttpResponse response = rc.post(
            '/',
            '',
            '{"Id": "003ae3fn12df25k309"}'
        );
        Test.stopTest();

        System.Assert.areEqual(
            201,
            response.getStatusCode(),
            'Expected to get the 201 response code'
        );
    }

    @isTest
    static void testPutWithPathAndBodyPositive() {
        HTTPClient rc = new HTTPClient('DummyNamedCredential');
        HTTPResponseMock mock = new HTTPResponseMock(
            201,
            'OK',
            'OK',
            new Map<String, String>()
        );
        Test.setMock(HttpCalloutMock.class, mock);

        Test.startTest();
        HttpResponse response = rc.put('/', '{"Id": "003ae3fn12df25k309"}');
        Test.stopTest();

        System.Assert.areEqual(
            201,
            response.getStatusCode(),
            'Expected to get the 201 response code'
        );
    }

    @isTest
    static void testPutWithPathQueryAndBodyPositive() {
        HTTPClient rc = new HTTPClient('DummyNamedCredential');
        HTTPResponseMock mock = new HTTPResponseMock(
            201,
            'OK',
            'OK',
            new Map<String, String>()
        );
        Test.setMock(HttpCalloutMock.class, mock);

        Test.startTest();
        HttpResponse response = rc.put('/', '', '{"Id": "003ae3fn12df25k309"}');
        Test.stopTest();

        System.Assert.areEqual(
            201,
            response.getStatusCode(),
            'Expected to get the 201 response code'
        );
    }

    @isTest
    static void testPatchWithPathQueryAndBodyPositive() {
        HTTPClient rc = new HTTPClient('DummyNamedCredential');
        HTTPResponseMock mock = new HTTPResponseMock(
            201,
            'OK',
            'OK',
            new Map<String, String>()
        );
        Test.setMock(HttpCalloutMock.class, mock);

        Test.startTest();
        HttpResponse response = rc.patch('/', '{"Id": "003ae3fn12df25k309"}');
        Test.stopTest();

        System.Assert.areEqual(
            201,
            response.getStatusCode(),
            'Expected to get the 201 response code'
        );
    }
}