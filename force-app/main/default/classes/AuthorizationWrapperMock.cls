@IsTest
public class AuthorizationWrapperMock implements HttpCalloutMock {
	public HttpResponse respond(HttpRequest req) {
		HttpResponse res = new HttpResponse();
		res.setHeader('Content-Type', 'application/json');
		res.setBody('{"access_token":"value"}');
		res.setStatusCode(200);
		res.setStatus('OK');
		return res;
	}
}