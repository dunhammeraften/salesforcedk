@IsTest
public class Activation_CreateTest {
	@TestSetup
	static void dataPrepMethod() {
        SBQQ.TriggerControl.disable();
		Account acct = new Account(
			Name = 'TestAccount',
			BillingCity = 'CP',
			BillingPostalCode = '2000',
			BillingCountry = 'DK',
			BillingStreet = 'Holmbladsgade 133',
			Phone = '111',
			AccountSource = 'Manual',
			Rationale__c = '12345678'
		);

		insert acct;

		Id standardPriceBookId = Test.getStandardPricebookId();

		Product2 pr = new Product2(
			ProductAPI_Telia_Product_Id__c = 'CORFRI10G',
			name = 'Corporate Fri tale EU 10 GB',
			SBQQ__SubscriptionType__c = 'Renewable',
			isActive = true,
			Activation_Record_Type__c = 'Voice',
			activate_with_other_products__c = false,
			Delivery_Product_Group__c = 'Voice'
		);

		insert pr;

		Pricebook2 customPB = new Pricebook2(Name = 'Custom Pricebook', isActive = true);

		insert customPB;

		PricebookEntry pbe = new PricebookEntry(
			Pricebook2Id = standardPriceBookId,
			isActive = true,
			UnitPrice = 22,
			Product2Id = pr.Id,
			UseStandardPrice = false
		);

		insert pbe;

		Opportunity opp = new Opportunity(
			AccountId = acct.Id,
			Name = 'Test',
			StageName = 'Qualification',
			CloseDate = Date.Today(),
			Pricebook2Id = standardPriceBookId
		);

		insert opp;

		OpportunityLineItem oppit = new OpportunityLineItem(
			Product2Id = pr.Id,
			OpportunityId = opp.Id,
			Quantity = 1,
			TotalPrice = 22,
			PriceBookEntryId = pbe.Id
		);

		insert oppit;

		SBQQ__Quote__c quo = new SBQQ__Quote__c(
			SBQQ__BillingFrequency__c = 'kvartalsvis.',
			SBQQ__PaymentTerms__c = '3',
			SBQQ__SubscriptionTerm__c = 36,
			SBQQ__Account__c = acct.Id,
			Invoice_Email__c = 'tuba@tuba.com',
			SBQQ__Opportunity2__c = opp.Id,
			RecordTypeId = Schema.sObjectType.SBQQ__Quote__c.getRecordTypeInfosByName().get('Draft Quote').getRecordTypeId()
		);

		insert quo;

		SBQQ__QuoteLine__c ql = new SBQQ__QuoteLine__c(
			SBQQ__Quote__c = quo.Id,
			SBQQ__Quantity__c = 1,
			SBQQ__Product__c = pr.Id
		);

		insert ql;

		Case cs = new case(
			Root_BAN__c = '232312345',
			Quote__c = quo.Id,
			AccountId = acct.Id,
			RecordTypeId = Schema.sObjectType.Case.getRecordTypeInfosByName().get('Order Fulfilment Case').getRecordTypeId(),
			Type = 'Voice'
		);

		insert cs;

		quo.Case__c = cs.Id;
		update quo;

		List<Account> AccountList = [SELECT Id FROM Account LIMIT 1];

		List<SBQQ__Quote__c> quotesList = [SELECT Id, SBQQ__Opportunity2__c FROM SBQQ__Quote__c LIMIT 2];

		List<Id> quoteIdsList = new List<Id>();

		List<Id> quoteIdsListRenewal = new List<Id>();
		quoteIdsList.add(quotesList[0].Id);

		List<Case> caseListMain = [SELECT id FROM case];
		caseListMain[0].Quote__c = quotesList[0].Id;
		update caseListMain;

		List<SBQQ__QuoteLine__c> quoteLinesList = [SELECT Id, SBQQ__Product__c FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c = :quotesList[0].Id];
		quoteLinesList[0].SBQQ__Product__c = pr.Id;
		update quoteLinesList;

		SBQQ__ProductFeature__c productFeature = new SBQQ__ProductFeature__c(
			Name = 'Feature Name ' + 1,
			SBQQ__Number__c = 1,
			SBQQ__ConfiguredSKU__c = quoteLinesList[0].SBQQ__Product__c,
			SBQQ__Category__c = 'TPX'
		);
		insert productFeature;

		SBQQ__ProductOption__c productoption = new SBQQ__ProductOption__c(
			SBQQ__Quantity__c = 5,
			SBQQ__Number__c = 4,
			SBQQ__ConfiguredSKU__c = quoteLinesList[0].SBQQ__Product__c,
			SBQQ__OptionalSKU__c = quoteLinesList[0].SBQQ__Product__c,
			SBQQ__Feature__c = productFeature.Id
		);
		insert productoption;

		String strRecordTypeId = [SELECT Id FROM RecordType WHERE SobjectType = 'Activation_line__c' AND developername = 'Voice_activation_line'].Id;

		Contract cr = new Contract(
			AccountId = AccountList[0].Id,
			Total_Contract_value__c = decimal.valueOf(6000),
			Migrated_Contract__c = true,
			Pricebook2Id = Test.getStandardPricebookId(),
			SBQQ__AmendmentPricebookId__c = Test.getStandardPricebookId(),
			SBQQ__RenewalPricebookId__c = Test.getStandardPricebookId(),
			SBQQ__AmendmentRenewalBehavior__c = 'Latest End Date',
			Product_s_in_scope__c = 'Voice',
			SBQQ__RenewalTerm__c = 36,
			Mobile_Part_of_Contract__c = true,
			SBQQ__RenewalForecast__c = false,
			SBQQ__Quote__c = quo.id
		);
		insert cr;

		cr.Status = 'Activated';
		cr.StartDate = Date.newInstance(2012, 12, 12);
		cr.SBQQ__RenewalForecast__c = false;
		cr.ContractTerm = 36;
		cr.Renewal_Opportunity_Creation_Date__c = Date.newInstance(2012, 12, 12);
		update cr;

		Opportunity a = new Opportunity();
		a.Id = quotesList[0].SBQQ__Opportunity2__c;
		a.SBQQ__AmendedContract__c = cr.Id;
		update a;

		SBQQ__Subscription__c newSubscription = new SBQQ__Subscription__c(
			SBQQ__Contract__c = cr.Id,
			SBQQ__Discount__c = 0,
			SBQQ__Product__c = quoteLinesList[0].SBQQ__Product__c,
			SBQQ__Quantity__c = 1, //TODO!!
			SBQQ__Account__c = AccountList[0].Id,
			SBQQ__ProductSubscriptionType__c = 'Renewable',
			SBQQ__SubscriptionType__c = 'Renewable',
			SBQQ__RenewalQuantity__c = 1, //TODO trigger
			SBQQ__RenewalPrice__c = 0,
			SBQQ__NetPrice__c = 0,
			SBQQ__CustomerPrice__c = 0,
			SBQQ__ListPrice__c = 0,
			SBQQ__RegularPrice__c = 0,
			SBQQ__SpecialPrice__c = 0,
			SBQQ__QuoteLine__c = quoteLinesList[0].Id
		);

		insert newSubscription;

		Subscription_Line_Detail__c subscriptionLine = new Subscription_Line_Detail__c();
		subscriptionLine.Subscription__c = newSubscription.Id;
		subscriptionLine.First_name__c = 'Test';
		subscriptionLine.Max_Monthly_Data_Used_MB__c = 0;
		subscriptionLine.Manual_Product__c = quoteLinesList[0].SBQQ__Product__c;
		subscriptionLine.Fokus_SOC__c = 'CORP1';
		subscriptionLine.Mobile_no__c = '124578';
		subscriptionLine.Avg_Monthly_Data_Used_MB__c = 0;
		subscriptionLine.EAN_number__c = 0;
		insert subscriptionLine;

		quoteLinesList[0].SBQQ__UpgradedSubscription__c = newSubscription.Id;
		quoteLinesList[0].SBQQ__ProductOption__c = productoption.Id;
		quoteLinesList[0].SBQQ__Quantity__c = 3;

		update quoteLinesList;
        SBQQ.TriggerControl.enable();
	}

	@IsTest
	static void testAmendmentQuotes() {
		List<SBQQ__Quote__c> quotesList = [
			SELECT Id, SBQQ__Opportunity2__c, Case__c
			FROM SBQQ__Quote__c
			WHERE SBQQ__Opportunity2__r.SBQQ__AmendedContract__c != NULL
		];

		List<Id> quoteIdsList = new List<Id>();
		quoteIdsList.add(quotesList[0].Id);

		List<Activation_Create.RequestDAO> requestDaoList = new List<Activation_Create.RequestDAO>();
		Activation_Create.RequestDAO requestDAO = new Activation_Create.RequestDAO();
		requestDAO.recordId = quotesList[0].Id;
		requestDAO.cases = [SELECT Id, Type FROM Case];
		requestDaoList.add(requestDAO);
		
		Test.startTest();
		Activation_Create.Activation_Create(requestDaoList);
		Test.stopTest();
	}

	@IsTest
	static void querySelectorTest1() {
		List<SBQQ__Quote__c> quotesList = [
			SELECT Id, SBQQ__Opportunity2__c
			FROM SBQQ__Quote__c
			WHERE SBQQ__Opportunity2__r.SBQQ__AmendedContract__c != NULL
		];
		
		Opportunity b = new Opportunity();
		b.Id = quotesList[0].SBQQ__Opportunity2__c;
		b.SBQQ__Renewal__c = true;
		b.SBQQ__AmendedContract__c = null;
		update b;

		List<Id> quoteIdsList = new List<Id>();
		quoteIdsList.add(quotesList[0].Id);

		List<Activation_Create.RequestDAO> requestDaoList = new List<Activation_Create.RequestDAO>();
		Activation_Create.RequestDAO requestDAO = new Activation_Create.RequestDAO();
		requestDAO.recordId = quotesList[0].Id;
		requestDAO.cases = [SELECT Id, Type FROM Case];
		requestDaoList.add(requestDAO);
		
		Test.startTest();
		Activation_Create.Activation_Create(requestDaoList);
		Test.stopTest();
	}

	@IsTest
	static void querySelectorTest2() {
		List<SBQQ__Quote__c> quotesList = [SELECT Id, SBQQ__Opportunity2__c FROM SBQQ__Quote__c];

		List<SBQQ__QuoteLine__c> quoteLinesList = [
			SELECT
				Id,
				SBQQ__Product__c,
				SBQQ__Product__r.Activation_Record_Type__c,
				Additional_Quantity__c,
				SBQQ__ProductOption__r.SBQQ__Feature__r.SBQQ__Category__c
			FROM SBQQ__QuoteLine__c
			WHERE SBQQ__Quote__c = :quotesList[0].Id
		];

		Opportunity b = new Opportunity();
		b.Id = quotesList[0].SBQQ__Opportunity2__c;
		b.SBQQ__Renewal__c = true;
		b.SBQQ__AmendedContract__c = null;
		update b;

		Quote_Line_Detail__c qld = new Quote_Line_Detail__c(
			Quote_Line__c = quoteLinesList[0].Id,
			Manual_Product__c = quoteLinesList[0].SBQQ__Product__c,
			Description__c = 'test'
		);
		insert qld;

		List<Activation_Create.RequestDAO> requestDaoList = new List<Activation_Create.RequestDAO>();
		Activation_Create.RequestDAO requestDAO = new Activation_Create.RequestDAO();
		requestDAO.recordId = quotesList[0].Id;
		requestDAO.cases = [SELECT Id, Type FROM Case];
		requestDaoList.add(requestDAO);

		Test.startTest();

		Activation_Create.Activation_Create(requestDaoList);

		quoteLinesList.get(0).SBQQ__Product__r.Activation_Record_Type__c = 'No Activation Needed';
		quoteLinesList.get(0).Additional_Quantity__c = 0;
		quoteLinesList.get(0).SBQQ__ProductOption__r.SBQQ__Feature__r.SBQQ__Category__c = 'TPX';
		update quoteLinesList;

		Activation_Create.Activation_Create(requestDaoList);

		Test.stopTest();
	}

	@IsTest
	static void querySelectorTest3() {
		List<SBQQ__Quote__c> quotesList = [SELECT Id, SBQQ__Opportunity2__c FROM SBQQ__Quote__c];

		List<SBQQ__QuoteLine__c> quoteLinesList = [
			SELECT Id, SBQQ__Product__c, SBQQ__ProductOption__r.SBQQ__Feature__r.SBQQ__Category__c
			FROM SBQQ__QuoteLine__c
			WHERE SBQQ__Quote__c = :quotesList[0].Id
		];

		List<SBQQ__ProductFeature__c> featureList = [SELECT SBQQ__Category__c FROM SBQQ__ProductFeature__c];
		featureList[0].SBQQ__Category__c = 'Corporate';
		update featureList;

		Opportunity b = new Opportunity();
		b.Id = quotesList[0].SBQQ__Opportunity2__c;
		b.SBQQ__Renewal__c = false;
		b.SBQQ__AmendedContract__c = null;
		update b;

		List<Activation_Create.RequestDAO> requestDaoList = new List<Activation_Create.RequestDAO>();
		Activation_Create.RequestDAO requestDAO = new Activation_Create.RequestDAO();
		requestDAO.recordId = quotesList[0].Id;
		requestDAO.cases = [SELECT Id, Type FROM Case];
		requestDaoList.add(requestDAO);

		Test.startTest();
		Activation_Create.Activation_Create(requestDaoList);
		Test.stopTest();
	}

	@IsTest
	static void querySelectorTest4() {
		List<SBQQ__Quote__c> quotesList = [SELECT Id, SBQQ__Opportunity2__c FROM SBQQ__Quote__c];

		List<SBQQ__QuoteLine__c> quoteLinesList = [SELECT Id, SBQQ__Product__c FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c = :quotesList[0].Id];

		Opportunity b = new Opportunity();
		b.Id = quotesList[0].SBQQ__Opportunity2__c;
		b.SBQQ__Renewal__c = true;
		b.SBQQ__AmendedContract__c = null;
		update b;

		Quote_Line_Detail__c qld = new Quote_Line_Detail__c(
			Quote_Line__c = quoteLinesList[0].Id,
			Manual_Product__c = quoteLinesList[0].SBQQ__Product__c,
			Description__c = 'test'
		);
		insert qld;

		List<SBQQ__ProductFeature__c> featureList = [SELECT SBQQ__Category__c FROM SBQQ__ProductFeature__c];
		featureList[0].SBQQ__Category__c = 'Corporate';
		update featureList;

		List<Activation_Create.RequestDAO> requestDaoList = new List<Activation_Create.RequestDAO>();
		Activation_Create.RequestDAO requestDAO = new Activation_Create.RequestDAO();
		requestDAO.recordId = quotesList[0].Id;
		requestDAO.cases = [SELECT Id, Type FROM Case];
		requestDaoList.add(requestDAO);

		Test.startTest();
		Activation_Create.Activation_Create(requestDaoList);
		Test.stopTest();
	}

	@IsTest
	static void testException() {
		List<Activation_Create.RequestDAO> requestDaoList = new List<Activation_Create.RequestDAO>();
		Activation_Create.RequestDAO requestDAO = new Activation_Create.RequestDAO();
		requestDAO.recordId = null;
		requestDAO.cases = [SELECT Id, Type FROM Case];
		requestDaoList.add(requestDAO);
		
		Test.startTest();
		Activation_Create.Activation_Create(requestDaoList);
		Test.stopTest();
	}

	// @IsTest
	// static void testTpUpsellRenewal() {
	// 	List<SBQQ__Quote__c> quotesList = [SELECT Id, SBQQ__Opportunity2__c FROM SBQQ__Quote__c];

	// 	List<SBQQ__QuoteLine__c> quoteLinesList = [
	// 		SELECT
	// 			Id,
	// 			SBQQ__Product__c,
	// 			SBQQ__Quote__c,
	// 			SBQQ__Product__r.Activation_Record_Type__c,
	// 			SBQQ__EffectiveQuantity__c,
	// 			Additional_Quantity__c,
	// 			SBQQ__ProductOption__r.SBQQ__Feature__r.SBQQ__Category__c
	// 		FROM SBQQ__QuoteLine__c
	// 		WHERE SBQQ__Quote__c = :quotesList[0].Id
	// 	];

	// 	quoteLinesList.get(0).SBQQ__Product__r.Activation_Record_Type__c = 'No activation needed';
	// 	quoteLinesList.get(0).SBQQ__ProductOption__r.SBQQ__Feature__r.SBQQ__Category__c = 'TPX';
	// 	quoteLinesList.get(0).Additional_Quantity__c = 5;

	// 	update quoteLinesList;

	// 	Opportunity b = new Opportunity();
	// 	b.Id = quotesList[0].SBQQ__Opportunity2__c;
	// 	b.SBQQ__Renewal__c = true;
	// 	b.SBQQ__AmendedContract__c = null;

	// 	update b;

	// 	Quote_Line_Detail__c qld = new Quote_Line_Detail__c(
	// 		Quote_Line__c = quoteLinesList[0].Id,
	// 		Manual_Product__c = quoteLinesList[0].SBQQ__Product__c,
	// 		Description__c = 'test'
	// 	);

	// 	insert qld;

	// 	List<SBQQ__ProductFeature__c> featureList = [SELECT SBQQ__Category__c FROM SBQQ__ProductFeature__c];
	// 	featureList[0].SBQQ__Category__c = 'TPX';
	// 	update featureList;

	// 	List<Activation_Create.RequestDAO> requestDaoList = new List<Activation_Create.RequestDAO>();
	// 	Activation_Create.RequestDAO requestDAO = new Activation_Create.RequestDAO();
	// 	requestDAO.recordId = quotesList[0].Id;
	// 	requestDAO.cases = [SELECT Id, Type FROM Case];
	// 	requestDaoList.add(requestDAO);

	// 	Test.startTest();
	// 	Activation_Create.Activation_Create(requestDaoList);
	// 	Test.stopTest();
	// }
}