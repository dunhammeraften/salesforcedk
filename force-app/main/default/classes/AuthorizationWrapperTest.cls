@isTest
public class AuthorizationWrapperTest {
	@isTest
	static void testGetAPIToken() {
		Test.setMock(HttpCalloutMock.class, new AuthorizationWrapperMock());

		String res = AuthorizationWrapper.getAPIToken(MetadataSelector.getAPISettings('OrderAPIHomeOfficeSettings'));
		String output = 'value';

		// System.assertEquals(200, res.getStatusCode());
		System.assertEquals(res, output);
	}
}