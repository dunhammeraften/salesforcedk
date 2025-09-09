public with sharing class HttpWrapper {
	public static HttpResponse get(String endpoint, Map<String, String> headers) {
		Http http = new Http();
		HttpRequest request = new HttpRequest();
		request.setEndpoint(endpoint);
		request.setMethod('GET');
		for (String key : headers.keySet()) {
			request.setHeader(key, headers.get(key));
		}
		try {
			return http.send(request);
		} catch (Exception ex) {
			throw new HttpWrapperException(ex.getMessage());
		}
	}
    
	public static HttpResponse post(String endpoint, String body, Map<String, String> headers) {
		Http http = new Http();
		HttpRequest request = new HttpRequest();
		request.setEndpoint(endpoint);
		request.setMethod('POST');
		request.setBody(body);
		request.setTimeout(120000);
		for (String key : headers.keySet()) {
			request.setHeader(key, headers.get(key));
		}
		try {
			return http.send(request);
		} catch (Exception ex) {
			throw new HttpWrapperException(ex.getMessage());
		}
	}
    
    public static HttpResponse del(String endpoint, Map<String, String> headers) {
		Http http = new Http();
		HttpRequest request = new HttpRequest();
		request.setEndpoint(endpoint);
		request.setMethod('DELETE');
		for (String key : headers.keySet()) {
			request.setHeader(key, headers.get(key));
		}
		try {
			return http.send(request);
		} catch (Exception ex) {
			throw new HttpWrapperException(ex.getMessage());
		}
	}

	@TestVisible
	class HttpWrapperException extends Exception {
	}
}