@isTest
public with sharing class ActivationLineTriggerTest {
	static testMethod void testMethod1() {
		//String Settings = 'a1w0E000000XK64QAG';
		//List<Activation__c> activationIDs = [SELECT Id  from Activation__c where Id =:Settings LIMIT 1];
		// if(activationIDs.size()>0)

		Profile prof = [SELECT Id FROM Profile WHERE name = 'System Administrator'];
		User m = new User(
			Alias = 'manager',
			Email = 'manager@testorg.com',
			EmailEncodingKey = 'UTF-8',
			LastName = 'Manager',
			LanguageLocaleKey = 'en_US',
			LocaleSidKey = 'en_US',
			ProfileId = prof.Id,
			TimeZoneSidKey = 'America/Los_Angeles',
			UserName = 'manager_user@testorg.com'
		);
		insert m; // The Flow "Activation - Set email of the manager of the activation owner" fails if there is no Manager Email
		User u = new User(
			Alias = 'standt',
			Email = 'standarduser@testorg.com',
			EmailEncodingKey = 'UTF-8',
			LastName = 'Testing',
			LanguageLocaleKey = 'en_US',
			LocaleSidKey = 'en_US',
			ProfileId = prof.Id,
			TimeZoneSidKey = 'America/Los_Angeles',
			UserName = 'standard_user@testorg.com',
			ManagerId = m.Id
		);
		System.runAs(u) {
			Account acct = new Account(
				Name = 'TestAccount',
				BillingCity = 'CP',
				BillingPostalCode = '2000',
				BillingCountry = 'DK',
				BillingStreet = 'Holmbladsgade 133',
				Phone = '111',
				CVR__c = '12345678'
			);
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
			insert new List<Product2>{ pr, pr2, pr3, pr4, pr5 };

			Id standardPriceBookId = Test.getStandardPricebookId();

			PricebookEntry pbe = new PricebookEntry(
				Pricebook2Id = standardPriceBookId,
				isActive = true,
				UnitPrice = 22,
				Product2Id = pr.Id,
				UseStandardPrice = false
			);

			PricebookEntry pbe2 = new PricebookEntry(
				Pricebook2Id = standardPriceBookId,
				isActive = true,
				UnitPrice = 11,
				Product2Id = pr2.Id,
				UseStandardPrice = false
			);

			insert new List<PricebookEntry>{ pbe, pbe2 };

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

			OpportunityLineItem oppit2 = new OpportunityLineItem(
				Product2Id = pr2.Id,
				OpportunityId = opp.Id,
				Quantity = 1,
				TotalPrice = 11,
				PriceBookEntryId = pbe2.Id
			);

			insert new List<OpportunityLineItem>{ oppit, oppit2 };

			SBQQ__Quote__c quo = new SBQQ__Quote__c(
				SBQQ__BillingFrequency__c = 'kvartalsvis.',
				//SBQQ__PaymentTerms__c = '3',
				SBQQ__SubscriptionTerm__c = 36,
				SBQQ__SalesRep__c = u.Id,
				SBQQ__Account__c = acct.Id,
				Invoice_Email__c = 'tuba@tuba.com',
				SBQQ__Opportunity2__c = opp.Id
			);
			insert quo;

			Case cs = new case(Root_BAN__c = '232312345', Quote__c = quo.Id, AccountId = acct.Id, OwnerId = u.Id);
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

			SBQQ__QuoteLine__c quoline = new SBQQ__QuoteLine__c(
				SBQQ__Discount__c = 5,
				SBQQ__Quote__c = quo.Id,
				SBQQ__Product__c = pr.Id
			);

			insert quoline;

			SBQQ__QuoteLine__c quoline2 = new SBQQ__QuoteLine__c(
				SBQQ__Discount__c = 5,
				SBQQ__Quote__c = quo.Id,
				SBQQ__Product__c = pr2.Id
			);

			//insert quoline2;

			Activation__c acti = new Activation__c(
				Case__c = cs.Id,
				Owner__c = u.Id,
				RecordTypeId = Schema.sObjectType.Activation__c.getRecordTypeInfosByName()
					.get('Fiber activation')
					.getRecordTypeId()
			);
			insert acti;

			opp.SBQQ__PrimaryQuote__c = quo.Id;
			update opp;

			Schema.Order ord = new Schema.Order(
				Case__c = cs.Id,
				Pricebook2Id = standardPriceBookId,
				OpportunityId = opp.Id,
				AccountId = acct.Id,
				EffectiveDate = date.parse('12/12/2019'),
				Status = 'Draft'
			);
			insert ord;

			OrderItem ordPd = new OrderItem(
				OrderId = ord.Id,
				UnitPrice = 22,
				PricebookEntryId = pbe.Id,
				Quantity = 1,
				Product2Id = pr.Id
			);
			insert ordPd;

			string OrderProduct = ordPd.Id;

			String strRecordTypeId = [
				SELECT Id
				FROM RecordType
				WHERE SobjectType = 'Activation_line__c' AND developername = 'Voice_activation_line'
			]
			.Id;

			Activation_line__c actiline = new Activation_line__c(
				Activation__c = acti.Id,
				Case__c = Cs.Id,
				Quote_line__c = quoline.Id,
				Order_Product__c = OrderProduct,
				RecordTypeId = strRecordTypeId,
				VAS_HBOBTB4__c = true,
				VAS_M2M_Data__c = 'M2M5MB',
				Funktionsnr__c = 'Mobile',
				Invoice_Email__c = 'tuba@tuba.com',
				Not_to_Activation__c = false
			);
			insert actiline;

			List<Activation__c> activationIDs = [SELECT Id FROM Activation__c WHERE Case__c = :Cs.Id LIMIT 1];
			if (activationIDs.size() > 0) {
				List<Activation_line__c> activationLines = [
					SELECT Id, Product__c
					FROM Activation_line__c
					WHERE Activation__c = :activationIDs[0].Id
					LIMIT 1
				];

				if (activationLines.size() > 0) {
					activationLines[0].BAN__c = '1';
					activationLines[0].Billing_Street_and_no__c = 'Holmbladsgade 139';
					activationLines[0].Billing_Postal_Code__c = '12';
					activationLines[0].Billing_Name__c = 'aaa';
					activationLines[0].Billing_City__c = 'CP';
					activationLines[0].First_name__c = 'FirstName';
					activationLines[0].PoA__c = '1';
					activationLines[0].Last_name__c = 'Lastname';
					activationLines[0].Email_address__c = 'tuba@tuba.com';
					//activationLines[0].SIM_number__c = '121212111';
					activationLines[0].EAN_number__c = 12;
					//activationLines[0].Number_Porting_Specific_Date__c = date.parse('12/12/2021');
					activationLines[0].Phone_no_Status__c = 'Nyt nummer';
					activationLines[0].Delivery_Email__c = 'tuba@tuba.com';
					activationLines[0].Ekstra_Data_SIM_number__c = '33333333333';
					activationLines[0].Existing_SIM_number__c = '222222222';
					activationLines[0].Phone_no__c = '28270857';
					activationLines[0].Actual_delivery_date__c = date.parse('01/01/2020');
					activationLines[0].Invoice_Type__c = 'PDF';
					activationLines[0].Invoice_Email__c = 'test@test.com';
					activationLines[0].Delivery_Street_and_number__c = 'Holmbladsgade 139';
					activationLines[0].Delivery_Att__c = 'Att:';
					activationLines[0].Number_Porting_End_of_Commitment__c = true;
					activationLines[0].Not_to_Activation__c = false;
					activationLines[0].Touchpoint_Receptionist__c = true;
					activationLines[0].Touchpoint_Bruger__c = true;
					activationLines[0].Touchpoint_Statistik__c = true;
					activationLines[0].Touchpoint_Softphone__c = true;
					activationLines[0].VAS_SIMBTB2__c = true;
					activationLines[0].VAS_SIMBTB11__c = true;
					activationLines[0].VAS_M2M_Data__c = 'M2M5MB';
					activationLines[0].Fastnet_User__C = true;
					activationLines[0].TOP_Activation_Flow_Step__c = 'FINISHED';
					activationLines[0].TOP_Completed_Flows__c = 'Voice_Flow';
					activationLines[0].VAS_UC_License__c = 'TPXLIM';
					update activationLines[0];
				}
			}
		}
	}
}
