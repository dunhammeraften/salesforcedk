@isTest
private class HttpWrapperTest {
	@isTest
	static void testGet() {
		Test.setMock(HttpCalloutMock.class, new HttpResponseMock());

		HttpResponse res = HttpWrapper.get('http://test.com', new Map<String, String>{ 'Content-type' => 'application/json' });
		String output = '{"test":"test"}';

		System.assertEquals(200, res.getStatusCode());
		System.assertEquals(res.getBody(), output);
	}

	@isTest
	static void testPost() {
		Test.setMock(HttpCalloutMock.class, new HttpResponseMock());

		HttpResponse res = HttpWrapper.post('http://test.com', '{"test":"test"}', new Map<String, String>{ 'Content-type' => 'application/json' });
		String output = '{"test":"test"}';

		System.assertEquals(200, res.getStatusCode());
		System.assertEquals(res.getBody(), output);
	}

	@isTest
	static void testPostException() {
		Map<String, String> headers = new Map<String, String>{ 'headerKey' => 'headerValue' };
		Test.setMock(HttpCalloutMock.class, new HttpWrapperExceptionMock());
		try {
			HttpWrapper.post('endpoint', 'body', headers);
			System.assert(false, 'Exception not thrown');
		} catch (HttpWrapper.HttpWrapperException ex) {
			System.assertEquals('Mock Exception', ex.getMessage());
		}
	}

	@isTest
	static void testGetException() {
		Map<String, String> headers = new Map<String, String>{ 'headerKey' => 'headerValue' };
		Test.setMock(HttpCalloutMock.class, new HttpWrapperExceptionMock());
		try {
			HttpWrapper.get('endpoint', headers);
			System.assert(false, 'Exception not thrown');
		} catch (HttpWrapper.HttpWrapperException ex) {
			System.assertEquals('Mock Exception', ex.getMessage());
		}
	}
}