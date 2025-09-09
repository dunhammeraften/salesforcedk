@isTest
private class RootBanServiceActionTest {
	@isTest
	static void testCreateRootBanSuccess() {
		// arrange
		List<RootBanServiceAction.Request> requests = new List<RootBanServiceAction.Request>();
		Account inputAccount = testDataFactory.createCVRAccountWithBillingAddress('12345678');
		RootBanServiceAction.Request request = new RootBanServiceAction.Request();
		request.inputAccount = inputAccount;
		request.companyName = 'test';
		request.billingAtt = 'Secretary';
		request.email = 'test@test.com';
		request.streetName = 'test';
		request.streetNumber = '19';
		request.postalCode = '2300';
		request.city = 'Copenhagen';
		request.country = 'Denmark';
		requests.add(request);

		Test.startTest();

		Test.setMock(HttpCalloutMock.class, new AuthorizationWrapperMock());
		Test.setMock(HttpCalloutMock.class, new RootBanServiceActionTest.RootBanServiceActionSuccessResponseMock());

		List<RootBanServiceAction.RootBanResult> results = RootBanServiceAction.createRootBan(requests);

		Test.stopTest();

		// assert
		Assert.areEqual(1, results.size());
		RootBanServiceAction.RootBanResult result = results.get(0);
		Assert.areNotEqual(null, result.billingAccountNumber);
		Assert.areEqual(false, result.hasErrors);
		Assert.areEqual(null, result.errors);
	}

	@isTest
	static void testCreateRootBanSuccessWithDoorNumberWhenDirection() {
		// arrange
		List<RootBanServiceAction.Request> requests = new List<RootBanServiceAction.Request>();
		Account inputAccount = testDataFactory.createCVRAccountWithBillingAddress('12345678');
		inputAccount.Billing_Door_Number__c = 'th';
		update inputAccount;

		RootBanServiceAction.Request request = new RootBanServiceAction.Request();
		request.inputAccount = inputAccount;
		request.companyName = 'test';
		request.billingAtt = 'Secretary';
		request.email = 'test@test.com';
		request.streetName = 'test';
		request.streetNumber = '19';
		request.postalCode = '2300';
		request.city = 'Copenhagen';
		request.country = 'Denmark';
		requests.add(request);

		Test.startTest();

		Test.setMock(HttpCalloutMock.class, new AuthorizationWrapperMock());
		Test.setMock(HttpCalloutMock.class, new RootBanServiceActionTest.RootBanServiceActionSuccessResponseMock());

		List<RootBanServiceAction.RootBanResult> results = RootBanServiceAction.createRootBan(requests);

		Test.stopTest();

		// assert
		Assert.areEqual(1, results.size());
		RootBanServiceAction.RootBanResult result = results.get(0);
		Assert.areNotEqual(null, result.billingAccountNumber);
		Assert.areEqual(false, result.hasErrors);
		Assert.areEqual(null, result.errors);
	}

	@isTest
	static void testCreateRootBanError() {
		// arrange
		List<RootBanServiceAction.Request> requests = new List<RootBanServiceAction.Request>();
		Account inputAccount = testDataFactory.createAccountWithCVR('12345678');
		RootBanServiceAction.Request request = new RootBanServiceAction.Request();
		request.inputAccount = inputAccount;
		request.companyName = 'test';
		request.billingAtt = 'Secretary';
		request.email = 'test@test.com';
		request.streetName = 'test';
		request.streetNumber = '19';
		request.postalCode = '2300';
		request.city = 'Copenhagen';
		request.country = 'Denmark';
		requests.add(request);

		Test.startTest();

		Test.setMock(HttpCalloutMock.class, new AuthorizationWrapperMock());
		Test.setMock(HttpCalloutMock.class, new RootBanServiceActionTest.RootBanServiceActionFailResponseMock());

		List<RootBanServiceAction.RootBanResult> results = RootBanServiceAction.createRootBan(requests);

		Test.stopTest();

		// assert
		Assert.areEqual(1, results.size());
		RootBanServiceAction.RootBanResult result = results.get(0);
		Assert.areEqual(true, result.hasErrors);
	}

	@isTest
	static void testCreateRootBanException() {
		List<RootBanServiceAction.Request> requests = new List<RootBanServiceAction.Request>();
		Account inputAccount = testDataFactory.createAccountWithCVR('12345678');
		RootBanServiceAction.Request request = new RootBanServiceAction.Request();
		request.inputAccount = inputAccount;
		request.companyName = 'test';
		request.billingAtt = 'Secretary';
		request.email = 'test@test.com';
		request.streetName = 'test';
		request.streetNumber = '19';
		request.postalCode = '2300';
		request.city = 'Copenhagen';
		request.country = 'Denmark';
		requests.add(request);

		Test.startTest();

		List<RootBanServiceAction.RootBanResult> results = RootBanServiceAction.createRootBan(requests);
		Assert.areEqual(true, results.get(0).hasErrors);

		Test.stopTest();
	}

	public class RootBanServiceActionSuccessResponseMock implements HttpCalloutMock {
		public HttpResponse respond(HttpRequest req) {
			HttpResponse res = new HttpResponse();
			res.setHeader('Content-Type', 'application/json');
			res.setBody(
				'{"data":{"channel":"SALES_FORCE","dealer":{"dealerCode":"1018","dealerName":"CO BtB Amager","salesAgentCode":"22334"},"orderId":"SF53892","id":"53892","segment":"B2B","channelOrderReference":"SF53892","brand":"teliadk","createdDate":"2023-02-02T08:25:30.428355133+01:00","processingStatus":"SUBMITTED","orderer":{"type":"ORGANIZATION","name":"Test A/S","cvr":"77712079","address":{"type":"DANISH_ADDRESS","city":"København","zipCode":"2300","country":"DNK","streetName":"Holmbladsgade","streetNumber":"133"},"telephoneNumber":{"countryCode":"45","localNumber":"73193137"}},"orderParts":[{"references":[],"type":"ACCOUNT","activity":"CREATE","changeTypes":[],"orderItems":[{"type":"ACCOUNT_ITEM","billingAccountNumber":"565855319","legalParty":{"type":"ORGANIZATION","name":"Test A/S","cvr":"77712079","address":{"type":"DANISH_ADDRESS","city":"København","zipCode":"2300","country":"DNK","streetName":"Holmbladsgade","streetNumber":"133"}},"billingParty":{"type":"ORGANIZATION","name":"Test A/S","cvr":"77712079","address":{"type":"DANISH_ADDRESS","city":"København","zipCode":"2300","attention":"Mr. Secretary","country":"DNK","streetName":"Holmbladsgade","streetNumber":"133","streetNumberSuffix":"B","floorNumber":"12","doorNumber":"1203","direction":"tv"}},"billingCycle":"MONTHLY","invoiceType":"PDF_BY_EMAIL","label":"My account","upTransferChargeCode":"THOD22","activity":"CREATE","id":2,"origin":"CLIENT"},{"type":"DISCOUNT_ITEM","discountCode":"HOF001","activity":"CREATE","id":3,"origin":"CLIENT"}],"validationErrors":[],"id":1}],"validationErrors":[],"hasValidationErrors":false,"documents":[]}}'
			);
			res.setStatusCode(200);
			return res;
		}
	}

	public class RootBanServiceActionFailResponseMock implements HttpCalloutMock {
		public HttpResponse respond(HttpRequest req) {
			HttpResponse res = new HttpResponse();
			res.setHeader('Content-Type', 'application/json');
			res.setBody(
				'{"data":{"channel":"SALES_FORCE","dealer":{"dealerCode":"1018","dealerName":"CO BtB Amager","salesAgentCode":"22334"},"segment":"B2B","brand":"teliadk","createdDate":"2023-02-20T14:43:19.922527929+01:00","orderer":{"type":"ORGANIZATION","name":"Test A/S","cvr":"77712079","address":{"type":"DANISH_ADDRESS","city":"København","zipCode":"2300","country":"DNK","streetName":"Holmbladsgade","streetNumber":"133"},"telephoneNumber":{"countryCode":"45","localNumber":"73193137"}},"orderParts":[{"references":[],"type":"ACCOUNT","activity":"CREATE","changeTypes":[],"orderItems":[{"type":"ACCOUNT_ITEM","legalParty":{"type":"ORGANIZATION","name":"Test A/S","cvr":"77712079"},"billingCycle":"MONTHLY","invoiceType":"PDF_BY_EMAIL","upTransferChargeCode":"THOD22","activity":"CREATE","id":2,"validationErrors":[{"errorCode":"INVALID_ORDER_ITEM","parameters":[{"reason":"address  must not be null"}]},{"errorCode":"MISSING_ADDRESS","parameters":[{"target":"REASON","reason":"Address can\'t be empty"}]}],"origin":"CLIENT"},{"type":"DISCOUNT_ITEM","discountCode":"HOF001","activity":"CREATE","id":3,"origin":"CLIENT"}],"validationErrors":[],"id":1}],"validationErrors": [{"errorCode": "INVALID_ORDERER","parameters": [{"target": "ORDERER","reason": "CustomerId or CVR must be present at Orderer of type Organization"},{"reason": "address  must not be null"},{"reason": "name  must not be null"}]}],"hasValidationErrors":true,"documents":[]}}'
			);
			res.setStatusCode(400);
			return res;
		}
	}
}