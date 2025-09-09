@IsTest
global class HttpResponseMock implements HttpCalloutMock {
	global String body;
	global Map<String, String> headers;
	global Integer statusCode;
	global String status;
	private Map<String, HttpCalloutMock> endpoint2HttpCalloutMock = new Map<String, HttpCalloutMock>();
	
	global HttpResponseMock() {
		this(200, 'OK', '{"test":"test"}', new Map<String, String>{'Content-Type' => 'application/json'});
	}

	global HttpResponseMock(Integer statusCode, String status, String body) {
		this(statusCode, status, body, new Map<String, String>());
	}

	global HttpResponseMock(Integer statusCode, String status, String body, Map<String, String> headers) {
		this.body = body;
		this.status = status;
		this.statusCode = statusCode;
		this.headers = headers;
	}

	global HttpResponseMock(Map<String, HttpCalloutMock> endpoint2HttpCalloutMock) {
		this.endpoint2HttpCalloutMock = endpoint2HttpCalloutMock;
	}

	global HttpResponse respond(HttpRequest req) {
		HttpResponse res = new HttpResponse();
		if(this.endpoint2HttpCalloutMock.isEmpty()) {
			if(!this.headers.isEmpty()) {
				for(String key : this.headers.keySet()) {
					res.setHeader(key, headers.get(key));
				}
			}
			if(String.isNotBlank(this.body)) {
				res.setBody(this.body);
			}
			if(this.statusCode != null) {
				res.setStatusCode(this.statusCode);
			}
			if(String.isNotBlank(this.status)) {
				res.setStatus(this.status);
			}
		} else {
			HttpCalloutMock mock = this.endpoint2HttpCalloutMock.get(req.getEndpoint());
			res = mock.respond(req);
		}

		return res;
	}
}