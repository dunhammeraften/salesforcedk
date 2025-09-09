@IsTest
public with sharing class HttpWrapperExceptionMock implements HttpCalloutMock {
	public HttpResponse respond(HttpRequest req) {
		throw new HttpWrapper.HttpWrapperException('Mock Exception');
	}
}