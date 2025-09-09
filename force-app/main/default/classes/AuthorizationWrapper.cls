/**
 *
 * @author Mujahid
 * @since 27/02/2023
 * @description AuthorizationWrapper uses to retrieve token for different API endpoints.
 * Keep the API information in APISettings__mdt Custom Meta Data
 */
public with sharing class AuthorizationWrapper {
	public static String getAPIToken(APISettings__mdt api) {
		try {
			String endpoint = api.API_EndPoint__c;
			String clientId = api.API_ClientId__c;
			String clientSecret = api.API_ClientSecret__c;
			String scope = api.Scope__c;

			String payload =
				'client_id=' +
				getEncodedValue(clientId) +
				'&client_secret=' +
				getEncodedValue(clientSecret) +
				'&grant_type=client_credentials' +
				'&scope=' +
				getEncodedValue(scope);

			System.debug('payload = ' + payload);

			Map<String, String> headers = new Map<String, String>{ 'Content-Type' => 'application/x-www-form-urlencoded' };
			HttpResponse respones = HttpWrapper.post(endpoint, payload, headers);
			Map<String, Object> authResult = (Map<String, Object>) JSON.deserializeUntyped(respones.getBody());
			String token = (String) authResult.get('access_token');
			return token;
		} catch (Exception ex) {
			throw new AuthorizationWrapperException(ex.getMessage());
		}
	}

	private static String getEncodedValue(String value) {
		return EncodingUtil.urlEncode(value, 'UTF-8');
	}

	class AuthorizationWrapperException extends Exception {
	}
}