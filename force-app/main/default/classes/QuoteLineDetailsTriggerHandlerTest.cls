@isTest
private class QuoteLineDetailsTriggerHandlerTest {

    @TestSetup
	static void dataSettingUp() {
		SBQQ.TriggerControl.disable();
		List<Account> testAccounts = testDataFactory.createAccountsForTests(1);

		List<Opportunity> testOpps = testDataFactory.createOpportunitiesForAccounts(1, testAccounts);

		List<SBQQ__Quote__c> testQuote = testDataFactory.createQuotesForOpps(1, testOpps);
		for (SBQQ__Quote__c singleQuote : testQuote) {
			singleQuote.SBQQ__Type__c = 'Renewal';
		}
		update testQuote;

		List<SBQQ__QuoteLine__c> testQuoteLines = testDataFactory.createQuoteLineRecordsForQuote(1, testQuote, 1, 1, false);

		List<Quote_Line_Detail__c> testQuoteLineDetails = testDataFactory.createQuoteLineDetailsForQuoteLines(1, testQuoteLines);
		SBQQ.TriggerControl.enable();
	}

	//Termination_verifier__c
	@isTest
	static void updateQuoteLineQuantityByQLDRecordUpdate_Test() {
		// Chcemy zmienic qunatity za pomoca zmiany liczby QLD recordow
		List<SBQQ__QuoteLine__c> theQuoteLines = [
				SELECT Id, SBQQ__Quantity__c, Additional_Quantity__c, (SELECT Id, Termination_verifier__c FROM Quote_Line_Details__r)
				FROM SBQQ__QuoteLine__c
			],
			processingQLList;

		List<Quote_Line_Detail__c> theQLDs = new List<Quote_Line_Detail__c>();
		for (SBQQ__QuoteLine__c singleQL : theQuoteLines) {
			for (Quote_Line_Detail__c singleQLD : singleQL.Quote_Line_Details__r) {
				theQLDs.add(new Quote_Line_Detail__c(Id = singleQLD.Id, Number_Porting_Specific_Date__c = Date.Today(), Phone_no_Status__c = 'Opsigelse'));
			}
		}

		update theQLDs;

		// processingQLList = [
		// 	SELECT
		// 		Id,
		// 		SBQQ__Quantity__c,
		// 		Additional_Quantity__c,
		// 		(SELECT Id, Termination_verifier__c FROM Quote_Line_Details__r WHERE Termination_verifier__c = 'No')
		// 	FROM SBQQ__QuoteLine__c
		// ];
		// for (SBQQ__QuoteLine__c singleQL : processingQLList) {
		// 	System.assertEquals(singleQL.SBQQ__Quantity__c, singleQL.Additional_Quantity__c);
		// }
	}

	@isTest
	static void updateQuoteLineQuantityByQLDRecordDelete_Test() {
		// Chcemy zmienic qunatity za pomoca zmiany liczby QLD recordow
		List<SBQQ__QuoteLine__c> theQuoteLines = [
				SELECT Id, SBQQ__Quantity__c, Additional_Quantity__c, (SELECT Id, Quantity__c FROM Quote_Line_Details__r)
				FROM SBQQ__QuoteLine__c
			],
			processingQLList;

		List<Double> totalQuantityBefore = new List<Double>(), totalQuantityAfter = new List<Double>();
		List<Quote_Line_Detail__c> qldToDelete = new List<Quote_Line_Detail__c>();
		for (Integer i = 0; i < theQuoteLines.size(); ++i) {
			totalQuantityBefore.add(0.0);
			for (Integer j = 0; j < theQuoteLines[i].Quote_Line_Details__r.size(); ++j) {
				// First QLD from each QL should be deleted
				if (j == 0)
					qldToDelete.add(new Quote_Line_Detail__c(Id = theQuoteLines[i].Quote_Line_Details__r[j].Id));
				totalQuantityBefore[i] += (theQuoteLines[i].Quote_Line_Details__r[j].Quantity__c == null
					? 0.0
					: theQuoteLines[i].Quote_Line_Details__r[j].Quantity__c);
			}
		}

		delete qldToDelete;

		processingQLList = [SELECT Id, SBQQ__Quantity__c, Additional_Quantity__c, (SELECT Id, Quantity__c FROM Quote_Line_Details__r) FROM SBQQ__QuoteLine__c];

		for (Integer i = 0; i < processingQLList.size(); ++i) {
			totalQuantityAfter.add(0.0);
			for (Integer j = 0; j < processingQLList[i].Quote_Line_Details__r.size(); ++j) {
				// First QLD from each QL should be deleted
				totalQuantityAfter[i] += (processingQLList[i].Quote_Line_Details__r[j].Quantity__c == null
					? 0.0
					: processingQLList[i].Quote_Line_Details__r[j].Quantity__c);
			}
		}

		for (Integer i = 0; i < processingQLList.size(); ++i) {
			System.assertNotEquals(totalQuantityBefore[i], totalQuantityAfter[i], 'The quantity of each QL should change with delete of one of the QLD.');
		}
	}

	@isTest
	static void updateQuoteLineQuantityByAdditionalQuantity_Test() {
		// Chcemy zmienic qunatity za pomoca zmiany w polu Additional Quantity na Quote Line

		List<SBQQ__QuoteLine__c> theQuoteLines = [SELECT Id, SBQQ__Quantity__c, Additional_Quantity__c FROM SBQQ__QuoteLine__c],
			processingQLList = new List<SBQQ__QuoteLine__c>();

		for (SBQQ__QuoteLine__c singleQL : theQuoteLines) {
			processingQLList.add(new SBQQ__QuoteLine__c(Id = singleQL.Id, Additional_Quantity__c = singleQL.Additional_Quantity__c + 5));
		}

		update processingQLList;

		processingQLList = [SELECT Id, SBQQ__Quantity__c, Additional_Quantity__c FROM SBQQ__QuoteLine__c];

		for (SBQQ__QuoteLine__c singleQL1 : theQuoteLines) {
			for (SBQQ__QuoteLine__c singleQL2 : processingQLList) {
				if (singleQL1.Id == singleQL2.Id) {
					System.assertNotEquals(singleQL1.Additional_Quantity__c, singleQL2.Additional_Quantity__c, 'Additional Quantity not updated!');
					System.assertNotEquals(singleQL1.SBQQ__Quantity__c, singleQL2.SBQQ__Quantity__c, 'Quantity not updated!');
				}
			}
		}
	}
}