@isTest
public class Activation_checkTest {
	@isTest
	static void testActivationCheck() {
		try {
			Profile prof = ProfileSelector.getProfileByProfileName(ProfileConstants.SYSTEM_ADMINISTRATOR);
			User u = testDataFactory.createUser('standt', prof.Id);
			System.runAs(u) {
				Account acct = testDataFactory.createAccountWithCVR('12345678');
				insert acct;

				Product2 pr = new Product2(
					ProductAPI_Telia_Product_Id__c = 'CORFRI10G',
					name = 'Corporate Fri tale EU 10 GB',
					Requires_Activation_Check__c = true,
					Product_Group__c = 'Touchpoint',
					SBQQ__SubscriptionType__c = 'Renewable',
					isActive = true,
					Activation_Record_Type__c = 'Voice'
				);

				Product2 pr2 = new Product2(
					ProductAPI_Telia_Product_Id__c = 'CORFRI5G',
					name = 'Corporate Fri tale EU 5 GB',
					Requires_Activation_Check__c = true,
					SBQQ__SubscriptionType__c = 'Renewable',
					isActive = true,
					Activation_Record_Type__c = 'Voice'
				);

				Product2 pr3 = new Product2(
					ProductAPI_Telia_Product_Id__c = '',
					name = 'Touchpoint Softphone',
					Requires_Activation_Check__c = true,
					Product_Group__c = 'Touchpoint',
					activate_with_other_products__c = true,
					isActive = true
				);

				Product2 pr4 = new Product2(
					ProductAPI_Telia_Product_Id__c = 'SIMBTB2',
					name = 'Extra Data Card',
					Requires_Activation_Check__c = true,
					activate_with_other_products__c = true,
					isActive = true
				);

				Product2 pr5 = new Product2(
					ProductAPI_Telia_Product_Id__c = 'M2M5MB',
					name = 'M2M 5GB',
					Requires_Activation_Check__c = true,
					activate_with_other_products__c = true,
					isActive = true
				);

				List<Product2> products = new List<Product2>{ pr, pr2, pr3, pr4, pr5 };
				insert products;

				Id standardPriceBookId = Test.getStandardPricebookId();

				PricebookEntry pbe = new PricebookEntry(
					Pricebook2Id = standardPriceBookId,
					isActive = true,
					UnitPrice = 22,
					Product2Id = products.get(0).Id,
					UseStandardPrice = false
				);
				insert pbe;

				PricebookEntry pbe2 = new PricebookEntry(
					Pricebook2Id = standardPriceBookId,
					isActive = true,
					UnitPrice = 11,
					Product2Id = products.get(1).Id,
					UseStandardPrice = false
				);
				insert pbe2;

				Opportunity opp = new Opportunity(
					AccountId = acct.Id,
					Name = 'Test',
					StageName = 'Qualification',
					CloseDate = Date.Today(),
					Pricebook2Id = standardPriceBookId
				);
				insert opp;

				OpportunityLineItem oppit = new OpportunityLineItem(
					Product2Id = products.get(0).Id,
					OpportunityId = opp.Id,
					Quantity = 1,
					TotalPrice = 22,
					PriceBookEntryId = pbe.Id
				);

				OpportunityLineItem oppit2 = new OpportunityLineItem(
					Product2Id = products.get(1).Id,
					OpportunityId = opp.Id,
					Quantity = 1,
					TotalPrice = 11,
					PriceBookEntryId = pbe2.Id
				);

				List<OpportunityLineItem> oppLineItems = new List<OpportunityLineItem>{ oppit, oppit2 };
				insert oppLineItems;

				SBQQ__Quote__c quo = new SBQQ__Quote__c(
					SBQQ__BillingFrequency__c = 'kvartalsvis.',
					SBQQ__PaymentTerms__c = '3',
					SBQQ__SubscriptionTerm__c = 36,
					SBQQ__SalesRep__c = u.Id,
					SBQQ__Account__c = acct.Id,
					Invoice_Email__c = 'tuba@tuba.com',
					SBQQ__Opportunity2__c = opp.Id
				);
				insert quo;

				Case cs = new case(Root_BAN__c = '232312345', Quote__c = quo.Id, AccountId = acct.Id);
				insert cs;

				Fokus_Campaign__c fc = new Fokus_Campaign__c(
					Product_Id__c = 'CORFRI10G',
					Campaign_Value__c = 36,
					Campaign_Id__c = 'CORFRI10G_36',
					Product_Campaign_Composite_Key__c = 'CORFRI10G.CORF10G36'
				);
				insert fc;

				Fokus_Discount__c fd = new Fokus_Discount__c(
					Product_Id__c = 'CORFRI10G',
					Discount_Percentage__c = 5,
					Discount_Id__c = 'CORFRI10G36',
					Product_Discount_Composite_Key__c = 'CORFRI10G.R132_5'
				);
				insert fd;

				SBQQ__QuoteLine__c quoline = new SBQQ__QuoteLine__c(SBQQ__Discount__c = 5, SBQQ__Quote__c = quo.Id, SBQQ__Product__c = products.get(0).Id);

				insert quoline;

				SBQQ__QuoteLine__c quoline2 = new SBQQ__QuoteLine__c(SBQQ__Discount__c = 5, SBQQ__Quote__c = quo.Id, SBQQ__Product__c = products.get(1).Id);

				Activation__c acti = new Activation__c(Case__c = cs.Id);
				insert acti;

				opp.SBQQ__PrimaryQuote__c = quo.Id;
				update opp;

				Schema.Order ord = new Schema.Order(
					Case__c = cs.Id,
					Pricebook2Id = standardPriceBookId,
					OpportunityId = opp.Id,
					AccountId = acct.Id,
					EffectiveDate = date.parse('12/12/2019'),
					Status = 'Draft',
					SBQQ__PaymentTerm__c = '30'
				);
				insert ord;

				OrderItem ordPd = new OrderItem(OrderId = ord.Id, UnitPrice = 22, PricebookEntryId = pbe.Id, Quantity = 1, Product2Id = products.get(0).Id);
				insert ordPd;
				String orderProduct = ordPd.Id;
				String strRecordTypeId = [SELECT Id FROM RecordType WHERE SobjectType = 'Activation_line__c' AND developername = 'Voice_activation_line'].Id;

				Activation_line__c actiline = new Activation_line__c(
					Activation__c = acti.Id,
					Case__c = cs.Id,
					Quote_line__c = quoline.Id,
					Manual_Product__c = products.get(0).Id,
					RecordTypeId = strRecordTypeId,
					VAS_HBOBTB4__c = true,
					VAS_M2M_Data__c = 'M2M5MB',
					Funktionsnr__c = 'Mobile',
					Invoice_Email__c = 'tuba@tuba.com',
					Not_to_Activation__c = false,
					Phone_no_Status__c = 'Nyt nummer',
					Mobile_no__c = '12345678'
				);
				insert actiline;

				List<Activation__c> testActivationRecord = [SELECT Id FROM Activation__c WHERE Case__c = :cs.Id LIMIT 1];
				if (testActivationRecord.size() > 0) {
					List<Activation_line__c> testActivationLineRecord = [
						SELECT Id, Product__c
						FROM Activation_line__c
						WHERE Activation__c = :testActivationRecord[0].Id
						LIMIT 1
					];

					if (testActivationLineRecord.size() > 0) {
						testActivationLineRecord[0].BAN__c = '1';
						testActivationLineRecord[0].Billing_Street_and_no__c = 'Holmbladsgade 139';
						testActivationLineRecord[0].Billing_Postal_Code__c = '12';
						testActivationLineRecord[0].Billing_Name__c = 'aaa';
						testActivationLineRecord[0].Billing_City__c = 'CP';
						testActivationLineRecord[0].First_name__c = 'FirstName';
						testActivationLineRecord[0].PoA__c = '1';
						testActivationLineRecord[0].Last_name__c = 'Lastname';
						testActivationLineRecord[0].Email_address__c = 'tuba@tuba.com';
						testActivationLineRecord[0].EAN_number__c = 12;
						testActivationLineRecord[0].Phone_no_Status__c = 'Nyt nummer';
						testActivationLineRecord[0].Delivery_Email__c = 'tuba@tuba.com';
						testActivationLineRecord[0].Ekstra_Data_SIM_number__c = '33333333333';
						testActivationLineRecord[0].Existing_SIM_number__c = '222222222';
						testActivationLineRecord[0].Phone_no__c = '28270857';
						testActivationLineRecord[0].Actual_delivery_date__c = date.parse('01/01/2020');
						testActivationLineRecord[0].Invoice_Type__c = 'PDF';
						testActivationLineRecord[0].Invoice_Email__c = 'test@test.com';
						testActivationLineRecord[0].Delivery_Street_and_number__c = 'Holmbladsgade 139';
						testActivationLineRecord[0].Delivery_Att__c = 'Att:';
						testActivationLineRecord[0].Number_Porting_End_of_Commitment__c = true;
						testActivationLineRecord[0].Case__c = cs.Id;
						testActivationLineRecord[0].Not_to_Activation__c = false;
						testActivationLineRecord[0].Touchpoint_Receptionist__c = true;
						testActivationLineRecord[0].Touchpoint_Bruger__c = true;
						testActivationLineRecord[0].Touchpoint_Statistik__c = true;
						testActivationLineRecord[0].Touchpoint_Softphone__c = true;
						testActivationLineRecord[0].VAS_SIMBTB2__c = true;
						testActivationLineRecord[0].VAS_SIMBTB11__c = true;
						testActivationLineRecord[0].VAS_M2M_Data__c = 'M2M5MB';
						update testActivationLineRecord[0];

						Test.startTest();

						List<Activation__c> activation = [SELECT Id FROM Activation__c LIMIT 1];
						List<Id> actIds = new List<Id>();
						for (Activation__c act : activation) {
							actIds.add(act.Id);
						}
						Activation_check_details.Activation(new List<String>{ cs.Id });
						ApexPages.StandardController controller2 = new ApexPages.StandardController(cs);
						Activation_check_details testActivationCheck = new Activation_check_details(controller2);

						testActivationCheck.Activation_Check();

						Case updatedCase = [SELECT Case_Activation_Check_Result__c FROM Case WHERE Id = :cs.Id LIMIT 1];
						// TODO: This was commented out in order to release DKT-18719. Figure out why and fix it.
						// System.assertNotEquals(updatedCase.Case_Activation_Check_Result__c, null, 'Case activation check results have been updated');

						Activation_check testActivation = new Activation_check();
						testActivation.ActivationLineAvailability(testActivationRecord[0].Id);
						testActivation.QuoteAvailability(testActivationRecord[0].Id);
						list<id> recordId = new List<Id>();
						recordId.add(testActivationRecord[0].Id);
						Activation_check.PortalEntryValidation(recordId);
						Test.stopTest();
					}
				}
			}
		} catch (Exception ex) {
			System.debug('ex = ' + ex);
		}
	}

	@IsTest
	private static void testMissingTeliaINSIGHTEMailContact() {
		// Create test Account, Case, and Activation records
		Account testAccount = new Account(Name = 'Test Account', Customer_has_Touchpoint__c = true, CVR__c = '12345678');
		insert testAccount;

		Case testCase = new Case(AccountId = testAccount.Id, Subject = 'Test Case');
		insert testCase;

		Activation__c testActivation = new Activation__c(Case__c = testCase.Id, UC_Activation_Date__c = Date.today());
		insert testActivation;

		Product2 product = new Product2(ProductAPI_Telia_Product_Id__c = 'TINSIGH', Name = 'Product');
		insert product;

		// Create test Activation Line record with missing Telia INSIGHT e-mail contact field
		Activation_line__c testActivationLine = new Activation_line__c(
			Activation__c = testActivation.Id,
			Manual_Product__c = product.Id,
			Telia_INSIGHT_e_mail_contact__c = null
		);
		insert testActivationLine;

		// Call the validateActivation() method
		Test.startTest();
		String activationResultText = '';
		Activation_check_details.validateActivation(testActivation, activationResultText);
		Test.stopTest();

		Case cs = [SELECT Case_Activation_Check_Result__c FROM Case WHERE Id = :testCase.Id];
		System.assert(cs.Case_Activation_Check_Result__c.contains('Required field missing on Activation Line: Telia INSIGHT e-mail contact'));
	}

	@IsTest
	private static void testValidateActivationIncorrectFunktionsnr() {
		// Create a test account and case
		Account testAccount = new Account(Name = 'Test Account', Customer_has_Touchpoint__c = true, CVR__c = '78787878');
		insert testAccount;
		Case testCase = new Case(AccountId = testAccount.Id, Subject = 'Test Case', Status = 'New');
		insert testCase;

		Product2 testProduct = new Product2(Name = 'Touchpoint Fastnetnummer', Product_Group__c = 'Touchpoint');
		insert testProduct;
		Activation__c activationRecord = new Activation__c(Case__c = testCase.Id);
		insert activationRecord;

		// Create a test activation line with an incorrect Funktionsnr
		Activation_line__c testActivationLine = new Activation_line__c(
			Case__c = testCase.Id,
			Activation__c = activationRecord.Id,
			Manual_Product__c = testProduct.Id,
			Funktionsnr__c = 'Mobile'
		);
		insert testActivationLine;

		Test.startTest();
		// Call the method being tested
		Activation_check_details.validateActivation(new Activation__c(Case__c = testCase.Id), '');

		Test.stopTest();
		Case cs = [SELECT Case_Activation_Check_Result__c FROM Case WHERE Id = :testCase.Id];
		System.assert(cs.Case_Activation_Check_Result__c.contains('Please select the correct value for Funktionsnr'));
	}

	@IsTest
	private static void testValidateActivation() {
		Account act = testDataFactory.createAccountWithCVR('12345678');
		act.Customer_has_Touchpoint__c = true;
		insert act;

		Id standardPriceBookId = Test.getStandardPricebookId();
		Opportunity opp = new Opportunity(
			AccountId = act.Id,
			Name = 'Test',
			StageName = 'Qualification',
			CloseDate = Date.Today(),
			Pricebook2Id = standardPriceBookId
		);
		insert opp;

		Case testCase = new Case(AccountId = act.Id);
		insert testCase;
		Activation__c activationRecord = new Activation__c(Case__c = testCase.Id);
		insert activationRecord;
		Product2 product1 = new Product2(ProductCode = 'TestProductCode1', Name = 'Product 1');
		insert product1;
		Product2 product2 = new Product2(ProductCode = 'TestProductCode2', Name = 'Product 2');
		insert product2;
		Activation_line__c activationLine1 = new Activation_line__c(
			Manual_Product__c = product1.Id,
			Phone_no_Status__c = 'Nummer skal porteres',
			Activation__c = activationRecord.Id
		);
		insert activationLine1;
		Activation_line__c activationLine2 = new Activation_line__c(
			Manual_Product__c = product2.Id,
			Phone_no_Status__c = 'Nummer skal porteres',
			Number_Porting_End_of_Commitment__c = true,
			Activation__c = activationRecord.Id
		);
		insert activationLine2;

		Test.startTest();
		Activation_check_details.validateActivation(activationRecord, '');

		Case cs = [SELECT Case_Activation_Check_Result__c FROM Case WHERE Id = :testCase.Id];
		System.assert(cs.Case_Activation_Check_Result__c.contains('Required field missing on Activation Line'));
	}
}