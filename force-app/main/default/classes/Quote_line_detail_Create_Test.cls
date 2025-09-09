@IsTest
public class Quote_line_detail_Create_Test {
	//@TestSetup

	static void dataPrepMethod() {
		SBQQ.TriggerControl.disable();

		Integer numOfAccounts = 1,
			numOfOppsPerAccount = 1,
			numOfQuotesPerOpp = 2,
			numOfQuoteLinesPerQuote = 1,
			numOfDiffProducts = 5,
			numOfNoActionProducts = 0;
		Account theAccount = testDataFactory.createSingleAccountForTests(); //1 DML ON ACCOUNT
		List<Opportunity> listOfOpportunities = testDataFactory.createOpportunitiesForAccounts(
			numOfOppsPerAccount,
			new List<Account>{ theAccount }
		); //1 DML ON OPPORTUNITY
		List<SBQQ__Quote__c> listOfQuotes = testDataFactory.createQuotesForOpps(numOfQuotesPerOpp, listOfOpportunities);
		//1 DML QUOTE
		listOfOpportunities = [
			SELECT Id, AccountId, SBQQ__PrimaryQuote__c, SBQQ__PrimaryQuote__r.SBQQ__StartDate__c, Case__c
			FROM Opportunity
		];
		List<Case> theRelatedToOppCases = testDataFactory.createCasesForOpportunitiesAndAssignThem(listOfOpportunities); // Should be called after Quote creation
		//1 DML FOR CASES 1 UPDATE ON THE OPPORTNITIES
		listOfOpportunities = [
			SELECT Id, AccountId, SBQQ__PrimaryQuote__c, SBQQ__PrimaryQuote__r.SBQQ__StartDate__c, Case__c
			FROM Opportunity
		];

		List<SBQQ__QuoteLine__c> listOfQuoteLines = testDataFactory.createQuoteLineRecordsForQuote(
			numOfQuoteLinesPerQuote,
			listOfQuotes,
			numOfDiffProducts,
			numOfNoActionProducts,
			false
		);
		//3 DML CREATE PRODUCT2, 1 DML CREATE SBQQ__ProductOption__c => createQuoteLineRecordsForQuote 

		SBQQ.TriggerControl.enable();
	}

	@IsTest
	static void querySelectorTest() {
		dataPrepMethod();

		Test.startTest();

		List<Account> AccountList = [SELECT Id FROM Account LIMIT 1];
		List<SBQQ__Quote__c> quotesList = [SELECT Id FROM SBQQ__Quote__c LIMIT 2];
		List<Id> quoteIdsList = new List<Id>();
		List<Id> quoteIdsMainList = new List<Id>();
		quoteIdsMainList.add(quotesList[0].Id);
		quoteIdsList.add(quotesList[1].Id);
		List<Case> caseListMain = [SELECT id FROM case LIMIT 1];
		caseListMain[0].Quote__c = quotesList[0].Id;
		update caseListMain[0];

		List<Case> caseList = [SELECT id FROM case WHERE Quote__c = :quotesList[0].Id];

		List<SBQQ__QuoteLine__c> quoteLinesList = [
			SELECT Id, SBQQ__Product__c
			FROM SBQQ__QuoteLine__c
			WHERE SBQQ__Quote__c = :quotesList[0].Id
		];

		List<SBQQ__QuoteLine__c> quoteLinesMainList = [
			SELECT Id
			FROM SBQQ__QuoteLine__c
			WHERE SBQQ__Quote__c = :quotesList[1].Id
		];

		quoteLinesMainList[0].Original_Quote_Line__c = quoteLinesList[0].Id;
		update quoteLinesMainList[0];

		Activation__c acti = new Activation__c(
			Case__c = caseList[0].Id,
			RecordTypeId = Schema.sObjectType.Activation__c.getRecordTypeInfosByName()
				.get('Voice activation')
				.getRecordTypeId()
		);
		insert acti;

		String strRecordTypeId = [
			SELECT Id
			FROM RecordType
			WHERE SobjectType = 'Activation_line__c' AND developername = 'Voice_activation_line'
		]
		.Id;

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

		List<Activation__c> testActivationRecord = [
			SELECT Id
			FROM Activation__c
			WHERE Case__c = :caseList[0].Id
			LIMIT 1
		];
		if (testActivationRecord.size() > 0) {
			List<Activation_line__c> testActivationLineRecord = [
				SELECT Id, Product__c
				FROM Activation_line__c
				WHERE Quote_line__c = :quoteLinesList[0].Id
				LIMIT 1
			];

			if (testActivationLineRecord.size() > 0) {
				testActivationLineRecord[0].Quote_line__c = quoteLinesList[0].id;
				testActivationLineRecord[0].BAN__c = '1';
				testActivationLineRecord[0].Billing_Street_and_no__c = 'Holmbladsgade 139';
				testActivationLineRecord[0].Billing_Postal_Code__c = '12';
				testActivationLineRecord[0].Billing_Name__c = 'aaa';
				testActivationLineRecord[0].Billing_City__c = 'CP';
				testActivationLineRecord[0].First_name__c = 'FirstName';
				testActivationLineRecord[0].PoA__c = '1';
				testActivationLineRecord[0].Last_name__c = 'Lastname';
				testActivationLineRecord[0].Email_address__c = 'tuba@tuba.com';
				//testActivationLineRecord[0].SIM_number__c = '121212111';
				testActivationLineRecord[0].EAN_number__c = 12;
				//testActivationLineRecord[0].Number_Porting_Specific_Date__c = Date.newInstance(2012, 12, 12);
				testActivationLineRecord[0].Phone_no_Status__c = 'Nummer skal porteres';
				testActivationLineRecord[0].Delivery_Email__c = 'tuba@tuba.com';
				testActivationLineRecord[0].Ekstra_Data_SIM_number__c = '33333333333';
				testActivationLineRecord[0].Existing_SIM_number__c = '222222222';
				testActivationLineRecord[0].Phone_no__c = '28270857';
				testActivationLineRecord[0].Actual_delivery_date__c = Date.newInstance(2012, 12, 12);
				testActivationLineRecord[0].Invoice_Type__c = 'PDF';
				testActivationLineRecord[0].Invoice_Email__c = 'test@test.com';
				testActivationLineRecord[0].Delivery_Street_and_number__c = 'Holmbladsgade 139';
				testActivationLineRecord[0].Delivery_Att__c = 'Att:';
				testActivationLineRecord[0].Number_Porting_End_of_Commitment__c = true;
				testActivationLineRecord[0].Case__c = caseList[0].Id;
				testActivationLineRecord[0].Not_to_Activation__c = false;
			}
			update testActivationLineRecord[0];
		}

		Contract cr = new Contract(
			AccountId = AccountList[0].Id,
			Total_Contract_value__c = decimal.valueOf(6000),
			//ContractTerm = 36,
			//StartDate = Date.today().addDays(-1),
			//Status = 'Activated',
			Migrated_Contract__c = true,
			Pricebook2Id = Test.getStandardPricebookId(),
			SBQQ__AmendmentPricebookId__c = Test.getStandardPricebookId(),
			SBQQ__RenewalPricebookId__c = Test.getStandardPricebookId(),
			SBQQ__AmendmentRenewalBehavior__c = 'Latest End Date',
			Product_s_in_scope__c = 'Voice',
			SBQQ__RenewalTerm__c = 36,
			Mobile_Part_of_Contract__c = true,
			SBQQ__RenewalForecast__c = false
		);

		try {
			insert cr;
			cr.Status = 'Activated';
			cr.StartDate = Date.newInstance(2012, 12, 12);
			cr.SBQQ__RenewalForecast__c = false;
			cr.ContractTerm = 36;
			cr.Renewal_Opportunity_Creation_Date__c = Date.newInstance(2012, 12, 12);

			update cr;
		} catch (Exception e) {
			System.debug('exeption  = ' + e);
			System.debug('excpetion message = ' + e.getMessage());
		}

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

		Subscription_Line_Detail__c SubscriptionLine = new Subscription_Line_Detail__c();

		SubscriptionLine.Subscription__c = newSubscription.Id;
		SubscriptionLine.First_name__c = 'Test';
		SubscriptionLine.Max_Monthly_Data_Used_MB__c = 0;
		SubscriptionLine.Manual_Product__c = quoteLinesList[0].SBQQ__Product__c;
		SubscriptionLine.Fokus_SOC__c = 'CORP1';
		SubscriptionLine.Mobile_no__c = '124578';
		SubscriptionLine.Avg_Monthly_Data_Used_MB__c = 0;
		SubscriptionLine.EAN_number__c = 0;

		insert SubscriptionLine;

		quoteLinesList[0].SBQQ__RenewedSubscription__c = newSubscription.Id;
		update quoteLinesList[0];

		list<Subscription_Line_Detail__c> ListSLD = [
			SELECT Id
			FROM Subscription_Line_Detail__c
			WHERE
				Subscription__c IN (
					SELECT SBQQ__RenewedSubscription__c
					FROM SBQQ__QuoteLine__c
					WHERE SBQQ__Quote__c = :quotesList[0].Id
				)
		];
		system.debug(ListSLD[0].Id);

		Quote_line_detail_Create testedClass = new Quote_line_detail_Create();
		testedClass.recordsId = quoteIdsList;
		Quote_line_detail_Create.Quote_line_details_Batch(quoteIdsList);

		Quote_line_detail_Create_Subs testedClass_Subs = new Quote_line_detail_Create_Subs();
		testedClass_Subs.recordsId = quoteIdsMainList;
		Quote_line_detail_Create_Subs.Quote_line_details_Batch(quoteIdsMainList);

		Database.querylocator returnedQuery = testedClass.start(null);
		Test.stopTest();
		//System.assertEquals( 'SELECT Id,Activation_Record_Type__c from SBQQ__QuoteLine__c where SBQQ__Quote__c in :recordId and Activation_Record_Type__c <>\'No activation needed\'', returnedQuery.getQuery(), 'The query returned by start method is wrong.');
	}

	@IsTest
	static void functionalityTest() {
		dataPrepMethod();

		List<SBQQ__Quote__c> quotesList = [SELECT Id, SBQQ__Primary__c FROM SBQQ__Quote__c];
		List<Id> quoteIdsList = new List<Id>();
		for (SBQQ__Quote__c singleQuote : quotesList) {
			if (singleQuote.SBQQ__Primary__c)
				quoteIdsList.add(singleQuote.Id);
		}

		Quote_line_detail_Create testedClass = new Quote_line_detail_Create();
		testedClass.recordsId = quoteIdsList;

		Map<Id, SBQQ__QuoteLine__c> quoteLinesMap = new Map<Id, SBQQ__QuoteLine__c>(
			[SELECT Id, Activation__c, SBQQ__Quote__r.SBQQ__Primary__c FROM SBQQ__QuoteLine__c]
		);
		// We need to create Activation Headers for them
		Test.startTest();
		Database.executeBatch(testedClass);
		Test.stopTest();
		Map<Id, SBQQ__QuoteLine__c> veryficationQuoteLineMap = new Map<Id, SBQQ__QuoteLine__c>(
			[SELECT Id, Activation__c FROM SBQQ__QuoteLine__c]
		);
	}

	public class testException extends Exception {
	}

	@IsTest
	static void mailingTest() {
		dataPrepMethod();

		try {
			throw new testException('The test Error moessage');
		} catch (Exception e) {
			Apex_Error_email_address__c Activation_line_Settings = new Apex_Error_email_address__c(
				Email_Address__c = 'test1@test.test'
			);
			Quote_line_detail_Create testedClass = new Quote_line_detail_Create();
		}
	}
}