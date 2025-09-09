/**
 * 
 * @author keh
 * @since 11032025
 */
@IsTest
public with sharing class OrderAPIActionTest {
	private static final String CVR = '12345678';

	/**
	 * makeData
	 */
	//@TestSetup
	static void makeData() {
		Profile prof = ProfileSelector.getProfileByProfileName(ProfileConstants.SYSTEM_ADMINISTRATOR);
		User usr = testDataFactory.createUser('standt', prof.Id);
		Account account = testDataFactory.createAccountWithCVR(CVR);
		account.OwnerId = usr.Id;
		insert account;
		List<Opportunity> listOfOpportunities = testDataFactory.createOpportunitiesForAccounts(1, new List<Account>{ account });

		Integer numOfAccounts = 1,
			numOfOppsPerAccount = 1,
			numOfQuotesPerOpp = 1,
			numOfQuoteLinesPerQuote = 2,
			numOfDiffProducts = 2,
			numOfNoActionProducts = 0;

		List<SBQQ__Quote__c> listOfQuotes = testDataFactory.createQuotesForOpps(numOfQuotesPerOpp, listOfOpportunities);
		listOfOpportunities = [SELECT Id, AccountId, SBQQ__PrimaryQuote__c, SBQQ__PrimaryQuote__r.SBQQ__StartDate__c, Case__c FROM Opportunity];
		List<Case> theRelatedToOppCases = testDataFactory.createCasesForOpportunitiesAndAssignThem(listOfOpportunities); // Should be called after Quote creation
		listOfOpportunities = [SELECT Id, AccountId, SBQQ__PrimaryQuote__c, SBQQ__PrimaryQuote__r.SBQQ__StartDate__c, Case__c FROM Opportunity];
		List<SBQQ__QuoteLine__c> listOfQuoteLines = testDataFactory.createQuoteLineRecordsForQuote(
			numOfQuoteLinesPerQuote,
			listOfQuotes,
			numOfDiffProducts,
			numOfNoActionProducts,
			true
		);
		listOfQuoteLines = [SELECT Id, Activation_Record_Type__c, SBQQ__Quote__c, SBQQ__Quantity__c, SBQQ__Product__c, Sales_Type__c FROM SBQQ__QuoteLine__c];

		List<SBQQ__Quote__c> quotesList = [SELECT Id FROM SBQQ__Quote__c];
		List<Id> quoteIdsList = new List<Id>();

		quoteIdsList.add(quotesList[0].Id);

		List<Case> caseListMain = [SELECT Id FROM Case LIMIT 1];
		caseListMain[0].Quote__c = quotesList[0].Id;
		update caseListMain[0];

		List<Case> caseList = [SELECT Id FROM Case WHERE Quote__c = :quotesList[0].Id];

		Product2 pr = new Product2(
			ProductAPI_Telia_Product_Id__c = 'CORFRI10G',
			name = 'Corporate Fri tale EU 10 GB',
			SBQQ__SubscriptionType__c = 'Renewable',
			isActive = true,
			Activation_Record_Type__c = 'Voice',
			activate_with_other_products__c = false
		);

		Product2 pr2 = new Product2(
			ProductAPI_Telia_Product_Id__c = 'CORFRI20G',
			name = 'Home office',
			SBQQ__SubscriptionType__c = 'Renewable',
			isActive = true,
			Activation_Record_Type__c = 'Home office',
			activate_with_other_products__c = false,
			ProductCode = '3100',
			address_required__c = true
		);
        insert new List<Product2>{ pr, pr2 };

		List<SBQQ__QuoteLine__c> quoteLinesList = [SELECT Id, SBQQ__Product__c FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c = :quotesList[0].Id];
		quoteLinesList[0].Additional_Quantity__c = 3;
		quoteLinesList[0].SBQQ__Product__c = pr.Id;
		quoteLinesList[0].SBQQ__SegmentIndex__c = 1;
		quoteLinesList[0].Address_filled_on_activation_lines__c = false;

		quoteLinesList[1].Additional_Quantity__c = 3;
		quoteLinesList[1].SBQQ__Product__c = pr2.Id;
		quoteLinesList[1].SBQQ__SegmentIndex__c = 1;
		quoteLinesList[1].Address_filled_on_activation_lines__c = false;
        update new List<SBQQ__QuoteLine__c>{ quoteLinesList[0], quoteLinesList[1]};

		Activation__c activation = new Activation__c(
			Case__c = caseList[0].Id,
			RecordTypeId = Schema.sObjectType.Activation__c.getRecordTypeInfosByName().get('Home office activation').getRecordTypeId()
		);
		insert activation;
	}

	/**
	private static void createOrder_ValidRequest_ReturnsNullOnSuccess() {
	 * 
	 */
	@IsTest
	private static void createOrder_ValidRequest_ReturnsNullOnSuccess() {
		makeData();

		//ARRANGE
		List<OrderAPIAction.Request> requests = new List<OrderAPIAction.Request>();
		Account account = AccountSelector.getByCVR(CVR);
		Opportunity opp = [SELECT Id FROM Opportunity WHERE AccountId = :account.Id LIMIT 1];
		Fokus_Campaign__c campaign = new Fokus_Campaign__c(
			Campaign_Id__c = 'FI06HOF03',
			Product_Id__c = 'FIBHOF03',
			Campaign_Value__c = 0,
			Product_Campaign_Composite_Key__c = 'FIBHOF03.FI06HOF03'
		);
		insert campaign;

		Case cs = [SELECT Id FROM Case LIMIT 1];
		Activation__c activation = [SELECT Id FROM Activation__c WHERE Case_Account_ID__c = :account.Id LIMIT 1];
		SBQQ__Quote__c quote = [SELECT Id FROM SBQQ__Quote__c LIMIT 1];
		SBQQ__QuoteLine__c quoteLine = [SELECT Id FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c = :quote.Id LIMIT 1];

		Location_Line__c location = testDataFactory.createLocationLine('FIBHOF03');
		location.Opportunity__c = opp.Id;
		insert location;
		RecordType rcType = [SELECT Id FROM RecordType WHERE DeveloperName = 'Home_office_activation_line' LIMIT 1];
		List<Activation_line__c> activationLines = new List<Activation_line__c>();
		Activation_line__c activationLine = new Activation_line__c(
			RecordTypeId = rcType.Id,
			Activation__c = activation.Id,
			BAN__c = '12345678',
			Case__c = cs.Id,
			Installation_address__c = 'Daglykkevej 5, 2650 Hvidovre',
			Quote_line__c = quoteLine.Id,
			Company_Name__c = 'JENSEN BØFHUS A/S',
			Delivery_City__c = 'Odense M',
			Delivery_Country__c = 'Denmark',
			Delivery_Street_and_number__c = 'Læssøegade 215',
			Postal_Code__c = '5230',
			Employee_Number__c = '13',
			Activation_Fulfilled__c = false,
			Email__c = 'test@test.com',
			Quantity__c = 1,
			Location_Line__c = location.Id,
			Home_Office_VAS_Product__c = 'FASTIP',
			Home_Office_OTC_Product__c = 'CHXT03'
		);
		activationLines.add(activationLine);
		insert activationLines;

		//ACT
		List<OrderAPIAction.Result> results = new List<OrderApiAction.Result>();
		System.runAs(getOnboardingUser()) {
			OrderAPIAction.Request request = new OrderAPIAction.Request();
			request.activationLines = activationLines;
			request.account = AccountSelector.getByCVR(CVR);
			requests.add(request);

			Test.startTest();

			Test.setMock(HttpCalloutMock.class, new AuthorizationWrapperMock());
			Test.setMock(HttpCalloutMock.class, new OrderAPIActionTest.OrderAPIActionSuccessResponseMock());

			results = OrderAPIAction.createOrder(requests);

			Test.stopTest();
		}

		//ASSERT
		Assert.areEqual(null, results); // The request has success and updated the response, not returning anything except null
	}

	/**
	 * createOrder_validRequest_updatesResponse
	 */
	@IsTest
	private static void createOrder_validRequest_updatesResponse() {
		makeData();

		//ARRANGE
		List<OrderAPIAction.Request> requests = new List<OrderAPIAction.Request>();
		Account account = AccountSelector.getByCVR(CVR);
		Opportunity opp = [SELECT Id FROM Opportunity WHERE AccountId = :account.Id LIMIT 1];

		Case cs = [SELECT Id FROM Case LIMIT 1];
		Activation__c activation = [SELECT Id FROM Activation__c WHERE Case_Account_ID__c = :account.Id LIMIT 1];
		SBQQ__Quote__c quote = [SELECT Id FROM SBQQ__Quote__c LIMIT 1];
		SBQQ__QuoteLine__c quoteLine = [SELECT Id FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c = :quote.Id LIMIT 1];

		Location_Line__c location = testDataFactory.createLocationLine('FIBHOF03');
		location.Opportunity__c = opp.Id;
		insert location;
		RecordType rcType = [SELECT Id FROM RecordType WHERE DeveloperName = 'Home_office_activation_line' LIMIT 1];
		List<Activation_line__c> activationLines = new List<Activation_line__c>();
		Activation_line__c activationLine = new Activation_line__c(
			RecordTypeId = rcType.Id,
			Activation__c = activation.Id,
			BAN__c = '12345678',
			Case__c = cs.Id,
			Installation_address__c = 'Daglykkevej 5, 2650 Hvidovre',
			Quote_line__c = quoteLine.Id,
			Company_Name__c = 'JENSEN BØFHUS A/S',
			Delivery_City__c = 'Odense M',
			Delivery_Country__c = 'Denmark',
			Delivery_Street_and_number__c = 'Læssøegade 215',
			Postal_Code__c = '5230',
			Employee_Number__c = '13',
			Activation_Fulfilled__c = false,
			Email__c = 'test@test.com',
			Quantity__c = 1,
			Location_Line__c = location.Id,
			Home_Office_VAS_Product__c = 'FASTIP'
		);
		activationLines.add(activationLine);
		insert activationLines;

		List<OrderAPIAction.Result> results = new List<OrderApiAction.Result>();
		
		//ACT
		System.runAs(getOnboardingUser()) {
			OrderAPIAction.Request request = new OrderAPIAction.Request();
			request.activationLines = activationLines;
			request.account = AccountSelector.getByCVR(CVR);
			requests.add(request);
			System.debug('request body = ' + JSON.serialize(request));
			Test.startTest();

			Test.setMock(HttpCalloutMock.class, new AuthorizationWrapperMock());
			Test.setMock(HttpCalloutMock.class, new OrderAPIActionTest.OrderAPIActionSuccessResponseMock());

			results = OrderAPIAction.createOrder(requests);

			Test.stopTest();
		}

		//ASSERT
		Assert.areEqual(null, results); // The request has success and updated the response, not returning anything except null
	}

	/**
	 * createOrder_InvalidRequest_CreatesError
	 */
	@IsTest
	private static void createOrder_InvalidRequest_CreatesError() {
		makeData();

		//ARRANGE
		List<OrderAPIAction.Request> requests = new List<OrderAPIAction.Request>();
		Account account = AccountSelector.getByCVR(CVR);
		Opportunity opp = [SELECT Id FROM Opportunity WHERE AccountId = :account.Id LIMIT 1];
		Fokus_Campaign__c campaign = new Fokus_Campaign__c(
			Campaign_Id__c = 'FI06HOF03',
			Product_Id__c = 'FIBHOF03',
			Campaign_Value__c = 0,
			Product_Campaign_Composite_Key__c = 'FIBHOF03.FI06HOF03'
		);
		insert campaign;

		Case cs = [SELECT Id FROM Case LIMIT 1];
		Activation__c activation = [SELECT Id FROM Activation__c WHERE Case_Account_ID__c = :account.Id LIMIT 1];
		SBQQ__Quote__c quote = [SELECT Id FROM SBQQ__Quote__c LIMIT 1];
		SBQQ__QuoteLine__c quoteLine = [SELECT Id FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c = :quote.Id LIMIT 1];

		Location_Line__c location = testDataFactory.createLocationLine('FIBHOF03');
		location.Opportunity__c = opp.Id;
		insert location;
		RecordType rcType = [SELECT Id FROM RecordType WHERE DeveloperName = 'Home_office_activation_line' LIMIT 1];
		List<Activation_line__c> activationLines = new List<Activation_line__c>();
		Activation_line__c activationLine = new Activation_line__c(
			RecordTypeId = rcType.Id,
			Activation__c = activation.Id,
			Case__c = cs.Id,
			Installation_address__c = 'Daglykkevej 5, 2650 Hvidovre',
			Quote_line__c = quoteLine.Id,
			Company_Name__c = 'JENSEN BØFHUS A/S',
			Delivery_City__c = 'Odense M',
			Delivery_Country__c = 'Denmark',
			Delivery_Street_and_number__c = 'Læssøegade 215',
			Postal_Code__c = '5230',
			Employee_Number__c = '13',
			Activation_Fulfilled__c = false,
			Quantity__c = 1,
			Location_Line__c = location.Id,
			Home_Office_VAS_Product__c = 'FASTIP'
		);
		activationLines.add(activationLine);
		insert activationLines;

		//ACT
		List<System_Log__c> errorLogs = new List<System_Log__c>();
		System.runAs(getOnboardingUser()) {
			OrderAPIAction.Request request = new OrderAPIAction.Request();
			request.activationLines = activationLines;
			request.account = AccountSelector.getByCVR(CVR);
			requests.add(request);

			Test.startTest();

			Test.setMock(HttpCalloutMock.class, new AuthorizationWrapperMock());
			Test.setMock(HttpCalloutMock.class, new OrderAPIActionTest.OrderAPIActionFailResponseMock());

			OrderAPIAction.createOrder(requests);

			Test.stopTest();

			errorLogs = [SELECT Id FROM System_Log__c WHERE Additional_Information__c = 'OrderAPIAction'];
		}

		//ASSERT
		Assert.isTrue(errorLogs.size() > 0);
	}

	/**
	 * createOrder_causingStatusCode200_createsErrorLog
	 */
	@IsTest
	private static void createOrder_causingStatusCode200_createsErrorLog() {
		makeData();

		//ARRANGE
		List<OrderAPIAction.Request> requests = new List<OrderAPIAction.Request>();
		Account account = AccountSelector.getByCVR(CVR);
		Opportunity opp = [SELECT Id FROM Opportunity WHERE AccountId = :account.Id LIMIT 1];
		Fokus_Campaign__c campaign = new Fokus_Campaign__c(
			Campaign_Id__c = 'FI06HOF03',
			Product_Id__c = 'FIBHOF03',
			Campaign_Value__c = 0,
			Product_Campaign_Composite_Key__c = 'FIBHOF03.FI06HOF03'
		);
		insert campaign;

		Case cs = [SELECT Id FROM Case LIMIT 1];
		Activation__c activation = [SELECT Id FROM Activation__c WHERE Case_Account_ID__c = :account.Id LIMIT 1];
		SBQQ__Quote__c quote = [SELECT Id FROM SBQQ__Quote__c LIMIT 1];
		SBQQ__QuoteLine__c quoteLine = [SELECT Id FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c = :quote.Id LIMIT 1];

		Location_Line__c location = testDataFactory.createLocationLine('FIBHOF03');
		location.Opportunity__c = opp.Id;
		insert location;
		RecordType rcType = [SELECT Id FROM RecordType WHERE DeveloperName = 'Home_office_activation_line' LIMIT 1];
		List<Activation_line__c> activationLines = new List<Activation_line__c>();
		Activation_line__c activationLine = new Activation_line__c(
			RecordTypeId = rcType.Id,
			Activation__c = activation.Id,
			Case__c = cs.Id,
			Installation_address__c = 'Daglykkevej 5, 2650 Hvidovre',
			Quote_line__c = quoteLine.Id,
			Company_Name__c = 'JENSEN BØFHUS A/S',
			Delivery_City__c = 'Odense M',
			Delivery_Country__c = 'Denmark',
			Delivery_Street_and_number__c = 'Læssøegade 215',
			Postal_Code__c = '5230',
			Employee_Number__c = '13',
			Activation_Fulfilled__c = false,
			Quantity__c = 1,
			Location_Line__c = location.Id,
			Home_Office_VAS_Product__c = 'FASTIP'
		);
		activationLines.add(activationLine);
		insert activationLines;

		//ACT
		List<System_Log__c> errorLogs = new List<System_Log__c>();
		System.runAs(getOnboardingUser()) {
			OrderAPIAction.Request request = new OrderAPIAction.Request();
			request.activationLines = activationLines;
			request.account = AccountSelector.getByCVR(CVR);
			requests.add(request);

			Test.startTest();

			Test.setMock(HttpCalloutMock.class, new AuthorizationWrapperMock());
			Test.setMock(HttpCalloutMock.class, new OrderAPIActionTest.OrderAPIActionFailResponseMockWithStatusCode200());

			OrderAPIAction.createOrder(requests);

			Test.stopTest();

			errorLogs = [SELECT Id FROM System_Log__c WHERE Additional_Information__c = 'OrderAPIAction'];
		}

		//ASSERT
		Assert.isTrue(errorLogs.size() > 0);
	}

	/**
	 * createOrder_inputCreatingException_createsException
	 */
	@IsTest
	private static void createOrder_inputCreatingException_createsException() {
		makeData();
		
		//ARRANGE
		List<OrderAPIAction.Request> requests = new List<OrderAPIAction.Request>();
		Account account = AccountSelector.getByCVR(CVR);
		Opportunity opp = [SELECT Id FROM Opportunity WHERE AccountId = :account.Id LIMIT 1];

		Case cs = [SELECT Id FROM Case LIMIT 1];
		Activation__c activation = [SELECT Id FROM Activation__c WHERE Case_Account_ID__c = :account.Id LIMIT 1];
		SBQQ__Quote__c quote = [SELECT Id FROM SBQQ__Quote__c LIMIT 1];
		SBQQ__QuoteLine__c quoteLine = [SELECT Id FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c = :quote.Id LIMIT 1];

		Location_Line__c location = testDataFactory.createLocationLine('FIBHOF02');
		location.Opportunity__c = opp.Id;
		insert location;
		List<Activation_line__c> activationLines = new List<Activation_line__c>();
		Activation_line__c activationLine = new Activation_line__c(
			Activation__c = activation.Id,
			BAN__c = '12345678',
			Case__c = cs.Id,
			Installation_address__c = 'Daglykkevej 5, 2650 Hvidovre',
			Quote_line__c = quoteLine.Id,
			Company_Name__c = 'JENSEN BØFHUS A/S',
			Delivery_City__c = 'Odense M',
			Delivery_Country__c = 'Denmark',
			Delivery_Street_and_number__c = 'Læssøegade 215',
			Postal_Code__c = '5230',
			Employee_Number__c = '13',
			Activation_Fulfilled__c = false,
			Email__c = 'test@test.com',
			Quantity__c = 1,
			Location_Line__c = location.Id,
			Home_Office_VAS_Product__c = 'FASTIP'
		);
		activationLines.add(activationLine);
		insert activationLines;

		//ACT
		List<OrderAPIAction.Result> results = new List<OrderAPIAction.Result>();
		System.runAs(getOnboardingUser()) {
			OrderAPIAction.Request request = new OrderAPIAction.Request();
			request.activationLines = activationLines;
			requests.add(request);

			Test.startTest();
			results = new List<OrderAPIAction.Result>();
			Boolean hasExceptionThrown = false;

			results = OrderAPIAction.createOrder(requests);

			Test.stopTest();
		}

		//ASSERT
		Assert.isTrue(results.get(0).hasError);
	}

	/**
	 * 
	 */
	// @isTest
	// static void cleanHouseNumber_variousInput_handlesNullAndRemovesStrings() {
	// 	//ARRANGE
	// 	String input = null;
	// 	String inputString = '11A';
	// 	String stringInput = 'A11';

	// 	//ACT
	// 	Test.startTest();
	// 	String cleanHouseNumberResult = OrderAPIAction.cleanHouseNumber(input);
	// 	String cleanHouseLetterResult = OrderAPIAction.cleanHouseLetter(inputString);
	// 	Test.stopTest();

	// 	//ASSERT
	// 	System.assertEquals(null, cleanHouseNumberResult, 'HouseNumber not null');
	// 	System.assertEquals(null, cleanHouseLetterResult, 'HouseLetter not null');

	// }

	public class OrderAPIActionSuccessResponseMock implements HttpCalloutMock {
		public HttpResponse respond(HttpRequest req) {
			HttpResponse res = new HttpResponse();
			res.setHeader('Content-Type', 'application/json');
			res.setBody(
				'{"data":{"channel":"SALES_FORCE","dealer":{"dealerCode":"7500","dealerName":"SME/LA - Region West","salesAgentTcad":"lgh629"},"orderId":"SF58561","id":"58561","segment":"B2B","channelOrderReference":"SF58561","brand":"teliadk","flags":{"termsAccepted":true,"consentsAccepted":false,"cprCheckFailed":false,"creditCheckFailed":false,"needsConfirmation":false,"dirty":true,"doLogistics":false,"homeOfficeOrder":true},"createdDate":"2023-04-03T15:58:18.96888306+02:00","processingStatus":"SUBMITTED","orderer":{"type":"ORGANIZATION","name":"TELIA FINANCE DANMARK, FILIAL AF TELIA FINANCE AB, SVERIGE","cvr":"25370457","address":{"type":"DANISH_ADDRESS","city":"København S","zipCode":"2300","country":"DNK","streetName":"Holmbladsgade","streetNumber":"139"},"customerId":"1003474587"},"orderParts":[{"references":[{"type":"BILLING_ACCOUNT_NUMBER","value":"461855314"}],"type":"ACCOUNT","activity":"CHANGE","changeTypes":[],"orderItems":[],"orderParts":[{"references":[],"type":"ACCOUNT","activity":"CREATE","changeTypes":[],"orderItems":[{"type":"ACCOUNT_ITEM","legalParty":{"type":"PERSON","firstName":"Tanya","lastName":"Nihorodova","address":{"type":"DANISH_ADDRESS","city":"Ballerup","zipCode":"2750","country":"DNK","streetName":"Linde Alle","streetNumber":"19","streetNumberSuffix":"E"},"email":"test@test.com","telephoneNumber":{"countryCode":"45","localNumber":"52766579"}},"paymentMethod":"GIRO","activity":"CREATE","id":8,"origin":"CLIENT"}],"orderParts":[{"references":[],"type":"SUBSCRIPTION","activity":"CREATE","changeTypes":[],"orderItems":[{"type":"SUBSCRIPTION_ITEM","productType":"BROADBAND_FIBER","newOffering":{"priceplan":"FIBEBTC14","campaign":"FIBTC14PP","name":"Telia Home - 199kr./md. Første 6 md. herefter 349kr.","description":"Telia Home - 199kr./md. Første 6 md. herefter 349kr.","bindingPeriod":6,"recurringPrice":{"amount":349,"currency":"DKK","vat":69.8,"catalogAmount":349,"catalogVat":69.8,"originalAmount":349,"originalVat":69.8},"technicalProduct":"Telia_Home_1000","erpTsProduct":"TSA1000020","characteristics":[]},"productCategory":"broadband","fixedNetDetails":{"fixedNetFlags":{"skipStateEvent":false,"skipCpeTechnician":true,"skipIp":false,"skipInvoice":true,"hasInstallationTypeConflict":false,"manualChangeProvider":false,"coaxDifferentProvider":false,"diggingNeeded":true,"manualOrdering":false},"installationAddress":{"postalAddress":{"type":"DANISH_ADDRESS","city":"Virum","zipCode":"2830","country":"DNK","streetName":"Virumbakken","streetNumber":"1"},"municipalityCode":"0173","streetCode":"0864"},"speedDown":"1000","speedUp":"1000","networkConfiguration":[],"doItYourselfInstallation":true,"providerReuseOfAddress":false,"previousEmployerAdminEmail":"dattatraya.gavhane@teliacompany.com"},"preferredActivationDate":"2023-01-22","productDeliveryAsap":false,"terminationPeriod":{"amount":30,"unit":"DAY"},"activity":"CREATE","id":4,"origin":"CLIENT"},{"type":"ADDITIONAL_PRODUCT_ITEM","productCode":"STATICIP","productCategory":"VAS","quantity":1,"characteristics":[],"activity":"CREATE","id":5,"origin":"CLIENT"},{"type":"FEE_ITEM","feeType":"ACT_FEE","recurring":false,"price":{"amount":0,"currency":"DKK","vat":0,"catalogAmount":0,"catalogVat":0,"originalAmount":0,"originalVat":0},"activity":"CREATE","id":6,"origin":"CLIENT"},{"type":"FEE_ITEM","feeType":"INSTALLATION_FEE","billingCode":"CHXTK1","recurring":false,"price":{"amount":895,"currency":"DKK","vat":0,"catalogAmount":895,"catalogVat":0,"originalAmount":895,"originalVat":0},"activity":"CREATE","id":7,"origin":"CLIENT"}],"id":3,"partTotal":{"amount":895,"currency":"DKK","vat":0,"catalogAmount":895,"catalogVat":0,"originalAmount":895,"originalVat":0},"servicesRecurringTotal":{"amount":349,"currency":"DKK","vat":69.8,"catalogAmount":349,"catalogVat":69.8,"originalAmount":349,"originalVat":69.8},"minimumPrice":{"amount":2989,"currency":"DKK","vat":418.8,"catalogAmount":2989,"catalogVat":418.8,"originalAmount":2989,"originalVat":418.8},"firstMonthPrice":{"amount":349,"currency":"DKK","vat":69.8,"catalogAmount":349,"catalogVat":69.8,"originalAmount":349,"originalVat":69.8}}],"id":2,"partTotal":{"amount":895,"currency":"DKK","vat":0,"catalogAmount":895,"catalogVat":0,"originalAmount":895,"originalVat":0},"servicesRecurringTotal":{"amount":349,"currency":"DKK","vat":69.8,"catalogAmount":349,"catalogVat":69.8,"originalAmount":349,"originalVat":69.8},"minimumPrice":{"amount":2989,"currency":"DKK","vat":418.8,"catalogAmount":2989,"catalogVat":418.8,"originalAmount":2989,"originalVat":418.8},"firstMonthPrice":{"amount":349,"currency":"DKK","vat":69.8,"catalogAmount":349,"catalogVat":69.8,"originalAmount":349,"originalVat":69.8}}],"validationErrors":[],"id":1,"partTotal":{"amount":895,"currency":"DKK","vat":0,"catalogAmount":895,"catalogVat":0,"originalAmount":895,"originalVat":0},"servicesRecurringTotal":{"amount":349,"currency":"DKK","vat":69.8,"catalogAmount":349,"catalogVat":69.8,"originalAmount":349,"originalVat":69.8},"minimumPrice":{"amount":2989,"currency":"DKK","vat":418.8,"catalogAmount":2989,"catalogVat":418.8,"originalAmount":2989,"originalVat":418.8},"firstMonthPrice":{"amount":349,"currency":"DKK","vat":69.8,"catalogAmount":349,"catalogVat":69.8,"originalAmount":349,"originalVat":69.8}}],"validationErrors":[],"hasValidationErrors":false,"orderTotal":{"amount":895,"currency":"DKK","vat":0,"catalogAmount":895,"catalogVat":0,"originalAmount":895,"originalVat":0},"servicesRecurringTotal":{"amount":349,"currency":"DKK","vat":69.8,"catalogAmount":349,"catalogVat":69.8,"originalAmount":349,"originalVat":69.8},"orderMinimumPrice":{"amount":2989,"currency":"DKK","vat":418.8,"catalogAmount":2989,"catalogVat":418.8,"originalAmount":2989,"originalVat":418.8},"firstMonthPrice":{"amount":349,"currency":"DKK","vat":69.8,"catalogAmount":349,"catalogVat":69.8,"originalAmount":349,"originalVat":69.8},"documents":[]}}'
			);
			res.setStatusCode(201);
			return res;
		}
	}

	public class OrderAPIActionFailResponseMock implements HttpCalloutMock {
		public HttpResponse respond(HttpRequest req) {
			HttpResponse res = new HttpResponse();
			res.setHeader('Content-Type', 'application/json');
			res.setBody(
				'{"data":{"channel":"SALES_FORCE","segment":"B2B","brand":"teliadk","flags":{"termsAccepted":true,"consentsAccepted":false,"cprCheckFailed":false,"creditCheckFailed":false,"needsConfirmation":false,"dirty":true,"doLogistics":false},"createdDate":"2023-04-03T16:01:38.948731479+02:00","orderer":{"type":"ORGANIZATION","name":"TELIA FINANCE DANMARK, FILIAL AF TELIA FINANCE AB, SVERIGE","cvr":"25370457","address":{"type":"DANISH_ADDRESS","city":"København S","zipCode":"2300","country":"DNK","streetName":"Holmbladsgade","streetNumber":"139"},"customerId":"1003474587"},"orderParts":[{"references":[{"type":"BILLING_ACCOUNT_NUMBER","value":"455955310"}],"type":"ACCOUNT","activity":"CHANGE","changeTypes":[],"orderItems":[],"orderParts":[{"references":[],"type":"ACCOUNT","activity":"CREATE","changeTypes":[],"orderItems":[{"type":"ACCOUNT_ITEM","legalParty":{"type":"PERSON","firstName":"test","lastName":"test","address":{"type":"DANISH_ADDRESS","city":"Hvidovre","zipCode":"2650","country":"DNK","streetName":"Daglykkevej","streetNumber":"1"},"email":"test@test.com","telephoneNumber":{"countryCode":"45","localNumber":"56565656"}},"activity":"CREATE","id":6,"origin":"CLIENT"}],"orderParts":[{"references":[],"type":"SUBSCRIPTION","activity":"CREATE","changeTypes":[],"orderItems":[{"type":"SUBSCRIPTION_ITEM","newOffering":{"priceplan":"FIBHOF03","characteristics":[]},"fixedNetDetails":{"fixedNetFlags":{"skipStateEvent":false,"skipCpeTechnician":true,"skipIp":false,"skipInvoice":true,"hasInstallationTypeConflict":false,"manualChangeProvider":false,"coaxDifferentProvider":false,"diggingNeeded":true,"manualOrdering":false},"installationAddress":{"postalAddress":{"type":"DANISH_ADDRESS","city":"Hvidovre","zipCode":"2650","country":"DNK","streetName":"Daglykkevej","streetNumber":"1"}},"speedDown":"1000","speedUp":"1000","networkConfiguration":[]},"preferredActivationDate":"2023-03-29","productDeliveryAsap":false,"activity":"CREATE","id":4,"origin":"CLIENT"},{"type":"ADDITIONAL_PRODUCT_ITEM","productCode":"FASTIP","productName":"Fast IP-adresse","productDescription":"Fast IP","productCategory":"VAS","recurringPrice":{"amount":15,"currency":"DKK","vat":3,"catalogAmount":15,"catalogVat":3,"originalAmount":15,"originalVat":3},"quantity":1,"fees":[{"name":"Purchasing fee","price":{"amount":0,"currency":"DKK","vat":0,"catalogAmount":0,"catalogVat":0,"originalAmount":0,"originalVat":0}}],"characteristics":[],"activity":"CREATE","id":5,"origin":"CLIENT"}],"id":3,"partTotal":{"amount":0,"currency":"DKK","vat":0,"catalogAmount":0,"catalogVat":0,"originalAmount":0,"originalVat":0},"servicesRecurringTotal":{"amount":15,"currency":"DKK","vat":3,"catalogAmount":15,"catalogVat":3,"originalAmount":15,"originalVat":3},"minimumPrice":{"amount":15,"currency":"DKK","vat":3,"catalogAmount":15,"catalogVat":3,"originalAmount":15,"originalVat":3},"firstMonthPrice":{"amount":15,"currency":"DKK","vat":3,"catalogAmount":15,"catalogVat":3,"originalAmount":15,"originalVat":3}}],"id":2,"partTotal":{"amount":0,"currency":"DKK","vat":0,"catalogAmount":0,"catalogVat":0,"originalAmount":0,"originalVat":0},"servicesRecurringTotal":{"amount":15,"currency":"DKK","vat":3,"catalogAmount":15,"catalogVat":3,"originalAmount":15,"originalVat":3},"minimumPrice":{"amount":15,"currency":"DKK","vat":3,"catalogAmount":15,"catalogVat":3,"originalAmount":15,"originalVat":3},"firstMonthPrice":{"amount":15,"currency":"DKK","vat":3,"catalogAmount":15,"catalogVat":3,"originalAmount":15,"originalVat":3}}],"validationErrors":[],"id":1,"partTotal":{"amount":0,"currency":"DKK","vat":0,"catalogAmount":0,"catalogVat":0,"originalAmount":0,"originalVat":0},"servicesRecurringTotal":{"amount":15,"currency":"DKK","vat":3,"catalogAmount":15,"catalogVat":3,"originalAmount":15,"originalVat":3},"minimumPrice":{"amount":15,"currency":"DKK","vat":3,"catalogAmount":15,"catalogVat":3,"originalAmount":15,"originalVat":3},"firstMonthPrice":{"amount":15,"currency":"DKK","vat":3,"catalogAmount":15,"catalogVat":3,"originalAmount":15,"originalVat":3}}],"validationErrors":[{"errorCode":"INVALID_DEALER","parameters":[{"reason":"Dealer code must not be null"}]}],"hasValidationErrors":true,"orderTotal":{"amount":0,"currency":"DKK","vat":0,"catalogAmount":0,"catalogVat":0,"originalAmount":0,"originalVat":0},"servicesRecurringTotal":{"amount":15,"currency":"DKK","vat":3,"catalogAmount":15,"catalogVat":3,"originalAmount":15,"originalVat":3},"orderMinimumPrice":{"amount":15,"currency":"DKK","vat":3,"catalogAmount":15,"catalogVat":3,"originalAmount":15,"originalVat":3},"firstMonthPrice":{"amount":15,"currency":"DKK","vat":3,"catalogAmount":15,"catalogVat":3,"originalAmount":15,"originalVat":3},"documents":[]}}'
			);
			res.setStatusCode(400);
			return res;
		}
	}

	public class OrderAPIActionFailResponseMockWithStatusCode200 implements HttpCalloutMock {
		public HttpResponse respond(HttpRequest req) {
			HttpResponse res = new HttpResponse();
			res.setHeader('Content-Type', 'application/json');
			res.setBody(
				'{"data":{"channel":"SALES_FORCE","segment":"B2B","brand":"teliadk","flags":{"termsAccepted":true,"consentsAccepted":false,"cprCheckFailed":false,"creditCheckFailed":false,"needsConfirmation":false,"dirty":true,"doLogistics":false},"createdDate":"2023-04-03T16:01:38.948731479+02:00","orderer":{"type":"ORGANIZATION","name":"TELIA FINANCE DANMARK, FILIAL AF TELIA FINANCE AB, SVERIGE","cvr":"25370457","address":{"type":"DANISH_ADDRESS","city":"København S","zipCode":"2300","country":"DNK","streetName":"Holmbladsgade","streetNumber":"139"},"customerId":"1003474587"},"orderParts":[{"references":[{"type":"BILLING_ACCOUNT_NUMBER","value":"455955310"}],"type":"ACCOUNT","activity":"CHANGE","changeTypes":[],"orderItems":[],"orderParts":[{"references":[],"type":"ACCOUNT","activity":"CREATE","changeTypes":[],"orderItems":[{"type":"ACCOUNT_ITEM","legalParty":{"type":"PERSON","firstName":"test","lastName":"test","address":{"type":"DANISH_ADDRESS","city":"Hvidovre","zipCode":"2650","country":"DNK","streetName":"Daglykkevej","streetNumber":"1"},"email":"test@test.com","telephoneNumber":{"countryCode":"45","localNumber":"56565656"}},"activity":"CREATE","id":6,"origin":"CLIENT"}],"orderParts":[{"references":[],"type":"SUBSCRIPTION","activity":"CREATE","changeTypes":[],"orderItems":[{"type":"SUBSCRIPTION_ITEM","newOffering":{"priceplan":"FIBHOF03","characteristics":[]},"fixedNetDetails":{"fixedNetFlags":{"skipStateEvent":false,"skipCpeTechnician":true,"skipIp":false,"skipInvoice":true,"hasInstallationTypeConflict":false,"manualChangeProvider":false,"coaxDifferentProvider":false,"diggingNeeded":true,"manualOrdering":false},"installationAddress":{"postalAddress":{"type":"DANISH_ADDRESS","city":"Hvidovre","zipCode":"2650","country":"DNK","streetName":"Daglykkevej","streetNumber":"1"}},"speedDown":"1000","speedUp":"1000","networkConfiguration":[]},"preferredActivationDate":"2023-03-29","productDeliveryAsap":false,"activity":"CREATE","id":4,"origin":"CLIENT"},{"type":"ADDITIONAL_PRODUCT_ITEM","productCode":"FASTIP","productName":"Fast IP-adresse","productDescription":"Fast IP","productCategory":"VAS","recurringPrice":{"amount":15,"currency":"DKK","vat":3,"catalogAmount":15,"catalogVat":3,"originalAmount":15,"originalVat":3},"quantity":1,"fees":[{"name":"Purchasing fee","price":{"amount":0,"currency":"DKK","vat":0,"catalogAmount":0,"catalogVat":0,"originalAmount":0,"originalVat":0}}],"characteristics":[],"activity":"CREATE","id":5,"origin":"CLIENT"}],"id":3,"partTotal":{"amount":0,"currency":"DKK","vat":0,"catalogAmount":0,"catalogVat":0,"originalAmount":0,"originalVat":0},"servicesRecurringTotal":{"amount":15,"currency":"DKK","vat":3,"catalogAmount":15,"catalogVat":3,"originalAmount":15,"originalVat":3},"minimumPrice":{"amount":15,"currency":"DKK","vat":3,"catalogAmount":15,"catalogVat":3,"originalAmount":15,"originalVat":3},"firstMonthPrice":{"amount":15,"currency":"DKK","vat":3,"catalogAmount":15,"catalogVat":3,"originalAmount":15,"originalVat":3}}],"id":2,"partTotal":{"amount":0,"currency":"DKK","vat":0,"catalogAmount":0,"catalogVat":0,"originalAmount":0,"originalVat":0},"servicesRecurringTotal":{"amount":15,"currency":"DKK","vat":3,"catalogAmount":15,"catalogVat":3,"originalAmount":15,"originalVat":3},"minimumPrice":{"amount":15,"currency":"DKK","vat":3,"catalogAmount":15,"catalogVat":3,"originalAmount":15,"originalVat":3},"firstMonthPrice":{"amount":15,"currency":"DKK","vat":3,"catalogAmount":15,"catalogVat":3,"originalAmount":15,"originalVat":3}}],"validationErrors":[],"id":1,"partTotal":{"amount":0,"currency":"DKK","vat":0,"catalogAmount":0,"catalogVat":0,"originalAmount":0,"originalVat":0},"servicesRecurringTotal":{"amount":15,"currency":"DKK","vat":3,"catalogAmount":15,"catalogVat":3,"originalAmount":15,"originalVat":3},"minimumPrice":{"amount":15,"currency":"DKK","vat":3,"catalogAmount":15,"catalogVat":3,"originalAmount":15,"originalVat":3},"firstMonthPrice":{"amount":15,"currency":"DKK","vat":3,"catalogAmount":15,"catalogVat":3,"originalAmount":15,"originalVat":3}}],"validationErrors":[{"errorCode":"INVALID_DEALER","parameters":[{"reason":"Dealer code must not be null"}]}],"hasValidationErrors":true,"orderTotal":{"amount":0,"currency":"DKK","vat":0,"catalogAmount":0,"catalogVat":0,"originalAmount":0,"originalVat":0},"servicesRecurringTotal":{"amount":15,"currency":"DKK","vat":3,"catalogAmount":15,"catalogVat":3,"originalAmount":15,"originalVat":3},"orderMinimumPrice":{"amount":15,"currency":"DKK","vat":3,"catalogAmount":15,"catalogVat":3,"originalAmount":15,"originalVat":3},"firstMonthPrice":{"amount":15,"currency":"DKK","vat":3,"catalogAmount":15,"catalogVat":3,"originalAmount":15,"originalVat":3},"documents":[]}}'
			);
			res.setStatusCode(200);
			return res;
		}
	}

	private static User getOnboardingUser() {
		Account acct = testDataFactory.createCVRAccountWithBillingAddress(StringUtils.makeRandomInteger(8));
		Contact ct = testDataFactory.createContact(acct.Id);
		Profile prof = ProfileSelector.getProfileByProfileName(ProfileConstants.ONBOARDING_PORTAL_USER);
		return testDataFactory.createUserForContact(ct.Id, 'onboard', prof.Id);
	}
}