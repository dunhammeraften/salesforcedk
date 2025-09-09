@IsTest
public class Activation_line_CreateTest {
	@TestSetup
	static void dataPrepMethod() {
		Integer numOfAccounts = 1,
			numOfOppsPerAccount = 1,
			numOfQuotesPerOpp = 1,
			numOfQuoteLinesPerQuote = 2,
			numOfDiffProducts = 2,
			numOfNoActionProducts = 0;
		Account theAccount = testDataFactory.createSingleAccountForTests();
		List<Opportunity> listOfOpportunities = testDataFactory.createOpportunitiesForAccounts(numOfOppsPerAccount, new List<Account>{ theAccount });
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
	}

	@IsTest
	static void querySelectorTest() {
		List<SBQQ__Quote__c> quotesList = [SELECT Id FROM SBQQ__Quote__c];
		List<Id> quoteIdsList = new List<Id>();

		quoteIdsList.add(quotesList[0].Id);

		List<Case> caseListMain = [SELECT id FROM case LIMIT 1];
		caseListMain[0].Quote__c = quotesList[0].Id;
		update caseListMain[0];

		List<Case> caseList = [SELECT id FROM case WHERE Quote__c = :quotesList[0].Id];

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
                update new List<SBQQ__QuoteLine__c>{ quoteLinesList[0], quoteLinesList[1] };

		Activation__c acti = new Activation__c(
			Case__c = caseList[0].Id,
			RecordTypeId = Schema.sObjectType.Activation__c.getRecordTypeInfosByName().get('Voice activation').getRecordTypeId()
		);
		insert acti;

		String strRecordTypeId = [SELECT Id FROM RecordType WHERE SobjectType = 'Activation_line__c' AND developername = 'Voice_activation_line'].Id;

		Activation_line__c actiline = new Activation_line__c(
			Activation__c = acti.Id,
			Case__c = caseList[0].Id,
			Quote_line__c = quoteLinesList[0].Id,
			RecordTypeId = strRecordTypeId,
			Manual_Product__c = quoteLinesList[0].SBQQ__Product__c,
			Invoice_Email__c = 'tuba@tuba.com',
			Not_to_Activation__c = false
		);
		insert actiline;

		Activation_line_Create_Iterable testedClass = new Activation_line_Create_Iterable();
		testedClass.recordId = string.valueOf(quoteIdsList[0]);

		testedClass.query =
			'SELECT Id,Activation_Record_Type__c,Activation__c, SBQQ__Quote__r.SBQQ__BillingCity__c , ' +
			'SBQQ__Quote__r.SBQQ__BillingPostalCode__c, SBQQ__Quote__r.SBQQ__BillingStreet__c, SBQQ__Quote__c, SBQQ__Quantity__c , ' +
			'SBQQ__Quote__r.SBQQ__BillingCountry__c,SBQQ__Product__c, Additional_Quantity__c, ' +
			'SBQQ__ProductCode__c, Address_filled_on_activation_lines__c, SBQQ__SegmentIndex__c,' +
			' SBQQ__Quote__r.SBQQ__Opportunity2__r.Case__c, SBQQ__Product__r.address_required__c,SBQQ__Quote__r.Account_Name__c, ' +
			' SBQQ__Quote__r.SBQQ__Opportunity2__r.SBQQ__Renewal__c, SBQQ__Quote__r.SBQQ__Opportunity2__r.SBQQ__AmendedContract__c ' +
			' from SBQQ__QuoteLine__c ' +
			' where Activation_Record_Type__c <>\'No activation needed\'' +
			' and SBQQ__Quote__c =\'' +
			quoteIdsList[0] +
			'\' and SBQQ__Product__r.activate_with_other_products__c = false' +
			' order by SBQQ__Product__c desc';

		Database.querylocator returnedQuery = testedClass.start(null);

		Test.startTest();
		Database.executeBatch(testedClass);

		Test.stopTest();
		//System.assertEquals( 'SELECT Id,Activation_Record_Type__c from SBQQ__QuoteLine__c where SBQQ__Quote__c in :recordId and Activation_Record_Type__c <>\'No activation needed\'', returnedQuery.getQuery(), 'The query returned by start method is wrong.');
	}

	@IsTest
	static void querySelectorTest1() {
		List<SBQQ__Quote__c> quotesList = [SELECT Id FROM SBQQ__Quote__c];
		List<Id> quoteIdsList = new List<Id>();

		quoteIdsList.add(quotesList[0].Id);

		Product2 AddressProduct = new Product2(
			Name = 'Test Address Product',
			isActive = true,
			ProductCode = '3122',
			address_required__c = true,
			Activation_Record_Type__c = 'Home office'
		);
		insert AddressProduct;
		Id standardPricebookId = Test.getStandardPricebookId();
		PricebookEntry AddressProductPriceBook = new PricebookEntry(
			IsActive = true,
			Pricebook2Id = standardPricebookId,
			Product2Id = AddressProduct.Id,
			UnitPrice = 100
		);
		insert AddressProductPriceBook;
		SBQQ__QuoteLine__c addressQuoteLine = new SBQQ__QuoteLine__c(
			SBQQ__Quote__c = quoteIdsList[0],
			SBQQ__Product__c = AddressProduct.Id,
			SBQQ__SegmentIndex__c = 1,
			//SBQQ__PricebookEntryId__c = AddressProductPriceBook.Id,
			SBQQ__Quantity__c = 1,
			Address_filled_on_activation_lines__c = false,
			SBQQ__NetPrice__c = 10
		);
		system.debug(addressQuoteLine);
		insert addressQuoteLine;

		List<Case> caseListMain = [SELECT id FROM case LIMIT 1];
		caseListMain[0].Quote__c = quotesList[0].Id;
		update caseListMain[0];

		List<Case> caseList = [SELECT id FROM case WHERE Quote__c = :quotesList[0].Id];

		Product2 pr = new Product2(
			ProductAPI_Telia_Product_Id__c = 'CORFRI10G',
			name = 'Corporate Fri tale EU 10 GB',
			SBQQ__SubscriptionType__c = 'Renewable',
			isActive = true,
			Activation_Record_Type__c = 'Voice',
			activate_with_other_products__c = false
		);
		insert pr;

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
		insert pr2;
		Test.startTest();

		List<SBQQ__QuoteLine__c> quoteLinesList = [SELECT Id, SBQQ__Product__c FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c = :quotesList[0].Id];
		quoteLinesList[0].Additional_Quantity__c = 3;
		quoteLinesList[0].SBQQ__Product__c = pr2.Id;
		quoteLinesList[0].SBQQ__SegmentIndex__c = 1;
		quoteLinesList[0].Address_filled_on_activation_lines__c = false;
		update quoteLinesList[0];

		Activation__c acti = new Activation__c(
			Case__c = caseList[0].Id,
			RecordTypeId = Schema.sObjectType.Activation__c.getRecordTypeInfosByName().get('Home office activation').getRecordTypeId()
		);
		insert acti;

		String strRecordTypeId = [SELECT Id FROM RecordType WHERE SobjectType = 'Activation_line__c' AND developername = 'Home_office_activation_line'].Id;

		Activation_line__c actiline = new Activation_line__c(
			Activation__c = acti.Id,
			Case__c = caseList[0].Id,
			Quote_line__c = quoteLinesList[0].Id,
			RecordTypeId = strRecordTypeId,
			Manual_Product__c = quoteLinesList[0].SBQQ__Product__c,
			Invoice_Email__c = 'tuba@tuba.com',
			Not_to_Activation__c = false
		);
		insert actiline;

		Activation_line_Create_Iterable testedClass = new Activation_line_Create_Iterable();
		testedClass.recordId = string.valueOf(quoteIdsList[0]);

		testedClass.query =
			'SELECT Id,Activation_Record_Type__c,Activation__c, SBQQ__Quote__r.SBQQ__BillingCity__c , ' +
			'SBQQ__Quote__r.SBQQ__BillingPostalCode__c, SBQQ__Quote__r.SBQQ__BillingStreet__c, SBQQ__Quote__c, SBQQ__Quantity__c , ' +
			'SBQQ__Quote__r.SBQQ__BillingCountry__c,SBQQ__Product__c, Additional_Quantity__c, ' +
			'SBQQ__ProductCode__c, Address_filled_on_activation_lines__c, SBQQ__SegmentIndex__c,' +
			' SBQQ__Quote__r.SBQQ__Opportunity2__r.Case__c, SBQQ__Product__r.address_required__c,SBQQ__Quote__r.Account_Name__c, ' +
			' SBQQ__Quote__r.SBQQ__Opportunity2__r.SBQQ__Renewal__c, SBQQ__Quote__r.SBQQ__Opportunity2__r.SBQQ__AmendedContract__c ' +
			' from SBQQ__QuoteLine__c ' +
			' where Activation_Record_Type__c <>\'No activation needed\'' +
			' and SBQQ__Quote__c =\'' +
			quoteIdsList[0] +
			'\' and SBQQ__Product__r.activate_with_other_products__c = false' +
			' order by SBQQ__Product__c desc';

		Database.querylocator returnedQuery = testedClass.start(null);

		Database.executeBatch(testedClass);

		Test.stopTest();
		//System.assertEquals( 'SELECT Id,Activation_Record_Type__c from SBQQ__QuoteLine__c where SBQQ__Quote__c in :recordId and Activation_Record_Type__c <>\'No activation needed\'', returnedQuery.getQuery(), 'The query returned by start method is wrong.');
	}

	// @IsTest
	// static void querySelectorTestAmendment() {
	// 	Test.startTest();
	// 	List<SBQQ__Quote__c> quotesList = [SELECT Id, SBQQ__Opportunity2__c, SBQQ__Account__c FROM SBQQ__Quote__c];
	// 	List<Id> quoteIdsList = new List<Id>();

	// 	quoteIdsList.add(quotesList[0].Id);

	// 	Product2 AddressProduct = new Product2(
	// 		Name = 'Test Address Product',
	// 		isActive = true,
	// 		ProductCode = '3122',
	// 		address_required__c = true,
	// 		Activation_Record_Type__c = 'Home office'
	// 	);
	// 	insert AddressProduct;
	// 	Id standardPricebookId = Test.getStandardPricebookId();
	// 	PricebookEntry AddressProductPriceBook = new PricebookEntry(
	// 		IsActive = true,
	// 		Pricebook2Id = standardPricebookId,
	// 		Product2Id = AddressProduct.Id,
	// 		UnitPrice = 100
	// 	);
	// 	insert AddressProductPriceBook;
	// 	SBQQ__QuoteLine__c addressQuoteLine = new SBQQ__QuoteLine__c(
	// 		SBQQ__Quote__c = quoteIdsList[0],
	// 		SBQQ__Product__c = AddressProduct.Id,
	// 		SBQQ__SegmentIndex__c = 1,
	// 		//SBQQ__PricebookEntryId__c = AddressProductPriceBook.Id,
	// 		SBQQ__Quantity__c = 1,
	// 		Address_filled_on_activation_lines__c = false,
	// 		SBQQ__NetPrice__c = 10
	// 	);
	// 	system.debug(addressQuoteLine);
	// 	insert addressQuoteLine;

	// 	List<Case> caseListMain = [SELECT id FROM case LIMIT 1];
	// 	caseListMain[0].Quote__c = quotesList[0].Id;
	// 	update caseListMain[0];

	// 	List<Case> caseList = [SELECT id FROM case WHERE Quote__c = :quotesList[0].Id];

	// 	Product2 pr = new Product2(
	// 		ProductAPI_Telia_Product_Id__c = 'CORFRI10G',
	// 		name = 'Corporate Fri tale EU 10 GB',
	// 		SBQQ__SubscriptionType__c = 'Renewable',
	// 		isActive = true,
	// 		Activation_Record_Type__c = 'Voice',
	// 		activate_with_other_products__c = false
	// 	);
	// 	insert pr;

	// 	Product2 pr2 = new Product2(
	// 		ProductAPI_Telia_Product_Id__c = 'CORFRI20G',
	// 		name = 'Home office',
	// 		SBQQ__SubscriptionType__c = 'Renewable',
	// 		isActive = true,
	// 		Activation_Record_Type__c = 'Home office',
	// 		activate_with_other_products__c = false,
	// 		ProductCode = '3100',
	// 		address_required__c = true
	// 	);
	// 	insert pr2;

	// 	Contract cr = new Contract(
	// 		AccountId = quotesList[0].SBQQ__Account__c,
	// 		Total_Contract_value__c = decimal.valueOf(6000),
	// 		//ContractTerm = 36,
	// 		//StartDate = Date.today().addDays(-1),
	// 		//Status = 'Activated',
	// 		Migrated_Contract__c = true,
	// 		Pricebook2Id = Test.getStandardPricebookId(),
	// 		SBQQ__AmendmentPricebookId__c = Test.getStandardPricebookId(),
	// 		SBQQ__RenewalPricebookId__c = Test.getStandardPricebookId(),
	// 		SBQQ__AmendmentRenewalBehavior__c = 'Latest End Date',
	// 		Product_s_in_scope__c = 'Voice',
	// 		SBQQ__RenewalTerm__c = 36,
	// 		Mobile_Part_of_Contract__c = true,
	// 		SBQQ__RenewalForecast__c = false
	// 	);
	// 	insert cr;

	// 	cr.Status = 'Activated';
	// 	cr.StartDate = Date.newInstance(2012, 12, 12);
	// 	cr.SBQQ__RenewalForecast__c = false;
	// 	cr.ContractTerm = 36;
	// 	cr.Renewal_Opportunity_Creation_Date__c = Date.newInstance(2012, 12, 12);

	// 	update cr;

	// 	SBQQ__Subscription__c newSubscription = new SBQQ__Subscription__c(
	// 		SBQQ__Contract__c = cr.Id,
	// 		SBQQ__Product__c = pr2.Id,
	// 		SBQQ__Quantity__c = 1, //TODO!!
	// 		SBQQ__Account__c = quotesList[0].SBQQ__Account__c,
	// 		SBQQ__ProductSubscriptionType__c = 'Renewable',
	// 		SBQQ__SubscriptionType__c = 'Renewable',
	// 		SBQQ__RenewalQuantity__c = 1, //TODO trigger
	// 		SBQQ__RenewalPrice__c = 100,
	// 		SBQQ__NetPrice__c = 100,
	// 		SBQQ__CustomerPrice__c = 100
	// 	);
	// 	insert newSubscription;

	// 	Subscription_Line_Detail__c newSLD = new Subscription_Line_Detail__c(
	// 		INSTANCE_KEY__c = '1234',
	// 		Subscription__c = newSubscription.Id,
	// 		Subscriber_Id__c = newSubscription.Id,
	// 		First_name__c = 'Test',
	// 		Max_Monthly_Data_Used_MB__c = 100,
	// 		Manual_Product__c = pr.Id,
	// 		Fokus_SOC__c = 'CORFRI10',
	// 		Mobile_no__c = '12345678',
	// 		Installation_address__c = 'test address',
	// 		Email__c = 'test@test.com',
	// 		RCC_Owner_Control__c = false,
	// 		TSRR_Owner_Control__c = false,
	// 		Last_name__c = 'Test',
	// 		Invoice_Email__c = 'test@test.com',
	// 		Ekstra_Data_SIM_number__c = '251625173',
	// 		Calls_from_DK_to_EU_MIN__c = 100,
	// 		Fixed_no__c = '5273627',
	// 		NUA_Owner_Control__c = false
	// 	);
	// 	insert newSLD;

	// 	Opportunity a = new Opportunity();
	// 	a.Id = quotesList[0].SBQQ__Opportunity2__c;
	// 	a.SBQQ__AmendedContract__c = cr.Id;
	// 	update a;

	// 	List<SBQQ__QuoteLine__c> quoteLinesList = [SELECT Id, SBQQ__Product__c FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c = :quotesList[0].Id];
	// 	quoteLinesList[0].Additional_Quantity__c = 3;
	// 	quoteLinesList[0].SBQQ__Product__c = pr.Id;
	// 	quoteLinesList[0].SBQQ__SegmentIndex__c = 1;
	// 	quoteLinesList[0].SBQQ__UpgradedSubscription__c = newSubscription.Id;
	// 	quoteLinesList[0].Address_filled_on_activation_lines__c = false;
	// 	update quoteLinesList[0];

	// 	Activation__c acti = new Activation__c(
	// 		Case__c = caseList[0].Id,
	// 		RecordTypeId = Schema.sObjectType.Activation__c.getRecordTypeInfosByName().get('Home office activation').getRecordTypeId()
	// 	);
	// 	insert acti;

	// 	List<Subscription_Line_Detail__c> testlist = Database.query(
	// 		'SELECT Id' +
	// 		',Subscription__r.SBQQ__Quantity__c,' +
	// 		'Manual_Product__r.ProductAPI_Telia_Product_Id__c, ' +
	// 		'Manual_Product__r.activate_with_other_products__c, ' +
	// 		' Subscription__r.SBQQ__Account__r.Name from Subscription_Line_Detail__c  ' +
	// 		' where Subscription__c  in ( select SBQQ__UpgradedSubscription__c from SBQQ__QuoteLine__c ' +
	// 		' where SBQQ__Quote__c =\'' +
	// 		quotesList[0].Id +
	// 		'\' and SBQQ__Product__r.Activation_Record_Type__c = \'Voice\'' +
	// 		') order by Quote_Line__c, Quote_line__r.SBQQ__UpgradedSubscription__c, ' +
	// 		' Manual_Product__r.activate_with_other_products__c'
	// 	);

	// 	system.debug(testlist[0].Id);

	// 	Activation_lineCreateAmendment.Activation_line_Create(quoteIdsList);

	// 	Test.stopTest();
	// }

	// @IsTest
	// static void querySelectorTestRenewal() {
	// 	Test.startTest();
	// 	List<SBQQ__Quote__c> quotesList = [SELECT Id, SBQQ__Opportunity2__c FROM SBQQ__Quote__c];
	// 	List<Id> quoteIdsList = new List<Id>();

	// 	quoteIdsList.add(quotesList[0].Id);

	// 	Product2 AddressProduct = new Product2(
	// 		Name = 'Test Address Product',
	// 		isActive = true,
	// 		ProductCode = '3122',
	// 		address_required__c = true,
	// 		Activation_Record_Type__c = 'Home office'
	// 	);
	// 	insert AddressProduct;
	// 	Id standardPricebookId = Test.getStandardPricebookId();
	// 	PricebookEntry AddressProductPriceBook = new PricebookEntry(
	// 		IsActive = true,
	// 		Pricebook2Id = standardPricebookId,
	// 		Product2Id = AddressProduct.Id,
	// 		UnitPrice = 100
	// 	);
	// 	insert AddressProductPriceBook;
	// 	SBQQ__QuoteLine__c addressQuoteLine = new SBQQ__QuoteLine__c(
	// 		SBQQ__Quote__c = quoteIdsList[0],
	// 		SBQQ__Product__c = AddressProduct.Id,
	// 		SBQQ__SegmentIndex__c = 1,
	// 		//SBQQ__PricebookEntryId__c = AddressProductPriceBook.Id,
	// 		SBQQ__Quantity__c = 1,
	// 		Address_filled_on_activation_lines__c = false,
	// 		SBQQ__NetPrice__c = 10
	// 	);
	// 	system.debug(addressQuoteLine);
	// 	insert addressQuoteLine;

	// 	List<Case> caseListMain = [SELECT id FROM case LIMIT 1];
	// 	caseListMain[0].Quote__c = quotesList[0].Id;
	// 	update caseListMain[0];

	// 	List<Case> caseList = [SELECT id FROM case WHERE Quote__c = :quotesList[0].Id];

	// 	Product2 pr = new Product2(
	// 		ProductAPI_Telia_Product_Id__c = 'CORFRI10G',
	// 		name = 'Corporate Fri tale EU 10 GB',
	// 		SBQQ__SubscriptionType__c = 'Renewable',
	// 		isActive = true,
	// 		Activation_Record_Type__c = 'Voice',
	// 		activate_with_other_products__c = false
	// 	);
	// 	insert pr;

	// 	Product2 pr2 = new Product2(
	// 		ProductAPI_Telia_Product_Id__c = 'CORFRI20G',
	// 		name = 'Home office',
	// 		SBQQ__SubscriptionType__c = 'Renewable',
	// 		isActive = true,
	// 		Activation_Record_Type__c = 'Fiber',
	// 		activate_with_other_products__c = false,
	// 		ProductCode = '3100',
	// 		address_required__c = true
	// 	);
	// 	insert pr2;

	// 	List<SBQQ__QuoteLine__c> quoteLinesList = [SELECT Id, SBQQ__Product__c FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c = :quotesList[0].Id];
	// 	quoteLinesList[0].Additional_Quantity__c = 3;
	// 	quoteLinesList[0].SBQQ__Quantity__c = 1;
	// 	quoteLinesList[0].SBQQ__Product__c = pr2.Id;
	// 	quoteLinesList[0].SBQQ__SegmentIndex__c = 1;
	// 	quoteLinesList[0].Address_filled_on_activation_lines__c = false;
	// 	update quoteLinesList[0];

	// 	Opportunity b = new Opportunity();
	// 	b.Id = quotesList[0].SBQQ__Opportunity2__c;
	// 	b.SBQQ__Renewal__c = true;
	// 	b.SBQQ__AmendedContract__c = null;
	// 	update b;

	// 	Activation__c acti = new Activation__c(
	// 		Case__c = caseList[0].Id,
	// 		RecordTypeId = Schema.sObjectType.Activation__c.getRecordTypeInfosByName().get('Home office activation').getRecordTypeId()
	// 	);
	// 	insert acti;

	// 	String strRecordTypeId = [SELECT Id FROM RecordType WHERE SobjectType = 'Activation_line__c' AND developername = 'Home_office_activation_line'].Id;

	// 	Activation_line__c actiline = new Activation_line__c(
	// 		Activation__c = acti.Id,
	// 		Case__c = caseList[0].Id,
	// 		Quote_line__c = quoteLinesList[0].Id,
	// 		RecordTypeId = strRecordTypeId,
	// 		Manual_Product__c = quoteLinesList[0].SBQQ__Product__c,
	// 		Invoice_Email__c = 'tuba@tuba.com',
	// 		Not_to_Activation__c = false
	// 	);
	// 	insert actiline;

	// 	Quote_Line_Detail__c qld = new Quote_Line_Detail__c(
	// 		Quote_Line__c = quoteLinesList[0].Id,
	// 		Manual_Product__c = quoteLinesList[0].SBQQ__Product__c,
	// 		Description__c = 'test'
	// 	);
	// 	insert qld;

	// 	List<Quote_Line_Detail__c> testlist = Database.query(
	// 		'SELECT Id' +
	// 		',Quote_Line__r.SBQQ__Quantity__c , Quote_Line__r.SBQQ__Product__c,' +
	// 		'Quote_Line__r.SBQQ__Product__r.ProductAPI_Telia_Product_Id__c, ' +
	// 		'Quote_Line__r.Additional_Quantity__c, Quote_Line__r.Activation__c,' +
	// 		'Quote_Line__r.Activation_Record_Type__c, Quote_Line__r.SBQQ__Quote__r.SBQQ__BillingCity__c,' +
	// 		' Quote_Line__r.SBQQ__Quote__r.SBQQ__BillingCountry__c, Quote_Line__r.SBQQ__Quote__r.SBQQ__BillingStreet__c,' +
	// 		' Quote_Line__r.SBQQ__Quote__r.SBQQ__BillingPostalCode__c,' +
	// 		' Quote_Line__r.SBQQ__Product__r.activate_with_other_products__c, Quote_Line__r.SBQQ__Quote__c, ' +
	// 		' Quote_line__r.SBQQ__RenewedSubscription__c,Quote_Line__r.SBQQ__Quote__r.Account_Name__c from Quote_Line_Detail__c  ' +
	// 		' where  Quote_Line__r.SBQQ__EffectiveQuantity__c >0 and  Quote_Line__r.SBQQ__Product__r.Activation_Record_Type__c <>\'No activation needed\'' +
	// 		' and Quote_Line__r.SBQQ__Quote__c =\'' +
	// 		quotesList[0].Id +
	// 		'\' order by Quote_Line__c, Quote_line__r.SBQQ__RenewedSubscription__c, ' +
	// 		' Quote_Line__r.SBQQ__Product__r.activate_with_other_products__c,Termination_verifier__c'
	// 	);

	// 	system.debug(testlist[0].Id);

	// 	Activation_line_CreateRenewal.Activation_line_Create(quoteIdsList);

	// 	Test.stopTest();
	// }
}