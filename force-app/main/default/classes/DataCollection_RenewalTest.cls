@isTest
public class DataCollection_RenewalTest {
	@isTest
	static void Test() {
		//String Settings = 'a1w0E000000XK64QAG';
		//List<Activation__c> testActivationRecord= [SELECT Id  from Activation__c where Id =:Settings LIMIT 1];
		// if(testActivationRecord.size()>0)

		Profile prof = [SELECT Id FROM Profile WHERE name = 'System Administrator'];
		User u = new User(
			Alias = 'standt',
			Email = 'standarduser@companyname.com',
			EmailEncodingKey = 'UTF-8',
			LastName = 'Testing',
			LanguageLocaleKey = 'en_US',
			LocaleSidKey = 'en_US',
			ProfileId = prof.Id,
			TimeZoneSidKey = 'America/Los_Angeles',
			UserName = 'standard_user@companyname.com'
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
				Telia_Product_Code__c = 'CORFRI10G',
				name = 'Corporate Fri tale EU 10 GB',
				SBQQ__SubscriptionType__c = 'Renewable',
				isActive = true,
				Activation_Record_Type__c = 'Voice'
			);
			insert pr;

			/*
                PriceBook2 pb2Standard = new Pricebook2(name='Pricebo');
                insert pb2Standard;
                
                Pricebook2 pb2Standard = [select id from Pricebook2 where isStandard=true];
Id standardPriceBookId = pb2Standard.Id;
*/
			Id standardPriceBookId = Test.getStandardPricebookId();

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

			PricebookEntry customPrice = new PricebookEntry(Pricebook2Id = customPB.Id, Product2Id = pr.Id, UnitPrice = 12, IsActive = true);
			insert customPrice;

			Long startTime;
			Long finalTime;
			Long millisecondsToWait;
			//WAIT for 1 seconds
			startTime = DateTime.now().getTime();
			finalTime = DateTime.now().getTime();
			millisecondsToWait = 1000; // vary this depending on your "sleep" needs
			while (finalTime - startTime < millisecondsToWait) {
				finalTime = DateTime.now().getTime();
			}

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

			//WAIT for 3 seconds
			startTime = DateTime.now().getTime();
			finalTime = DateTime.now().getTime();
			millisecondsToWait = 3000; // vary this depending on your "sleep" needs
			while (finalTime - startTime < millisecondsToWait) {
				finalTime = DateTime.now().getTime();
			}

			SBQQ__Quote__c quo = new SBQQ__Quote__c(
				SBQQ__BillingFrequency__c = 'kvartalsvis.',
				SBQQ__PaymentTerms__c = '3',
				SBQQ__SubscriptionTerm__c = 36,
				SBQQ__SalesRep__c = u.Id,
				SBQQ__Account__c = acct.Id,
				Invoice_Email__c = 'tuba@tuba.com',
				SBQQ__Opportunity2__c = opp.Id,
				RecordTypeId = Schema.sObjectType.SBQQ__Quote__c.getRecordTypeInfosByName().get('Read only for Renewal').getRecordTypeId()
			);

			insert quo;

			Case cs = new case(
				Root_BAN__c = '232312345',
				Quote__c = quo.Id,
				AccountId = acct.Id,
				RecordTypeId = Schema.sObjectType.Case.getRecordTypeInfosByName().get('Order Fulfilment Case').getRecordTypeId()
			);
			insert cs;
			system.debug('case out' + cs);

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

			SBQQ__QuoteLine__c quoline = new SBQQ__QuoteLine__c(SBQQ__Discount__c = 5, SBQQ__Quote__c = quo.Id, SBQQ__Product__c = pr.Id);

			insert quoline;

			Activation__c acti = new Activation__c(
				Case__c = cs.Id,
				RecordTypeId = Schema.sObjectType.Activation__c.getRecordTypeInfosByName().get('Fiber activation').getRecordTypeId()
			);
			insert acti;
			List<activation__C> actSelected = [SELECT id FROM activation__C];
			system.debug('Act line Id ' + actselected);
			/*List<Schema.Order> testOrderRecord= [SELECT Id  from Order where AccountId =: acct.Id LIMIT 1];
                string OrderId;
                if(testOrderRecord.size()>0)
                {
                    system.debug('kkkk');
                    OrderId =testOrderRecord[0].Id;
                }
                */

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
			/*
                Contract ctr = new Contract(AccountId = acct.Id, SBQQ__Order__c = ord.Id);
            insert ctr;
*/

			OrderItem ordPd = new OrderItem(OrderId = ord.Id, UnitPrice = 22, PricebookEntryId = pbe.Id, Quantity = 1, Product2Id = pr.Id);
			insert ordPd;
			//
			/*
                List<OrderItem> testOrderItemRecord= [SELECT Id  from OrderItem where OrderId =: ord.Id LIMIT 1];  
                
                string OrderProduct;
                if(testOrderItemRecord.size()>0)
                {
                    system.debug('tttt');
                    OrderProduct =testOrderItemRecord[0].Id;
                }
                */

			Billing_Account__c billingAccount = new Billing_Account__c(Account__c = acct.Id, Name = 'Test', Invoice_Email__c = 'test@test.com');
			insert billingAccount;

			string OrderProduct = ordPd.Id;

			Fokus_Subscription__c fs = new Fokus_Subscription__c(
				SF_ACCOUNT_KEY__c = acct.Id,
				MOBILE_NO__c = '12345678',
				FIRST_NAME__c = 'test',
				LAST_NAME__c = 'name',
				SUBSCRIBER_EMAIL__c = 'test@email.com',
				FIX_NO__c = '12121',
				EXISTING_SIM__c = '1213124234234523',
				SERVICE_CODE__c = '',
				ORDER_PRODUCT__c = 'CORFRI10G',
				SUBSCRIBER_ID__c = 1234567,
				Billing_Account__c = billingAccount.Id
			);
			insert fs;

			SBQQ__ProductOption__c productoption = new SBQQ__ProductOption__c(
				SBQQ__Quantity__c = 5,
				SBQQ__Number__c = 4,
				SBQQ__ConfiguredSKU__c = pr.id,
				SBQQ__OptionalSKU__c = pr.id
			);
			insert productoption;

			//OrderItem ordi = new OrderItem(Product2Id=pr.Id, UnitPrice=66,OrderId = ord.Id);
			//insert ordi;
			/*   
                List<OrderItem> testOrderItemRecord= [SELECT Id  from OrderItem where OrderId =: ord.Id LIMIT 1];  
                
                string OrderProduct;
                if(testOrderItemRecord.size()>0)
                {
                    system.debug('tttt');
                    OrderProduct =testOrderItemRecord[0].Id;
                }
*/
			String strRecordTypeId = [SELECT Id FROM RecordType WHERE SobjectType = 'Activation_line__c' AND developername = 'Voice_activation_line'].Id;

			Activation_line__c actiline = new Activation_line__c(
				Activation__c = acti.Id,
				Case__c = cs.Id,
				Quote_line__c = quoline.Id,
				Order_Product__c = OrderProduct,
				RecordTypeId = strRecordTypeId,
				Invoice_Email__c = 'tuba@tuba.com',
				Not_to_Activation__c = false,
				Billing_Account__c = billingAccount.Id
			);
			insert actiline;
			system.debug('Activation Line ' + actiline);
			/*
                Activation_line__c actiline = new Activation_line__c(BAN__c = '1',Billing_Street_and_no__c = 'Holmbladsgade 139', 
                                                                     Billing_Postal_Code__c = '12', Billing_Name__c ='aaa',Billing_City__c = 'CP',
                                                                     Case__c = Cs.Id, First_name__c = 'FirstName',
                                                                     PoA__c ='1',
                                                                     Last_name__c ='Lastname' ,Email_address__c ='tuba@tuba.com',
                                                                     SIM_number__c = '121212111', 
                                                                     EAN_number__c = 12, Number_Porting_Specific_Date__c = date.parse('12/12/2019'),  
                                                                     Phone_no_Status__c = '', Delivery_Email__c ='tuba@tuba.com',
                                                                     Ekstra_Data_SIM_number__c = '33333333333', Existing_SIM_number__c = '222222222' ,
                                                                     Phone_no__c = '28270857',  Actual_delivery_date__c = date.parse('01/01/2020'), Invoice_Type__c ='PDF',  
                                                                     Delivery_Street_and_number__c = 'Holmbladsgade 139', Delivery_Att__c = 'Att:', 
                                                                     Number_Porting_End_of_Commitment__c =true, Activation__c = acti.Id);
                insert actiline;
                */
			List<Activation__c> testActivationRecord = [SELECT Id FROM Activation__c WHERE Case__c = :cs.Id LIMIT 1];
			system.debug('act records ' + testActivationRecord);
			if (testActivationRecord.size() > 0) {
				List<Activation_line__c> testActivationLineRecord = [
					SELECT Id, Product__c, Activation__r.Case__r.Quote__c
					FROM Activation_line__c
					WHERE Activation__c = :testActivationRecord[0].Id
					LIMIT 1
				];
				system.debug('act lin records ' + testActivationLineRecord);
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
					//testActivationLineRecord[0].SIM_number__c = '121212111';
					testActivationLineRecord[0].EAN_number__c = 12;
					testActivationLineRecord[0].Number_Porting_Specific_Date__c = Date.today() + 20;
					testActivationLineRecord[0].Phone_no_Status__c = 'Nummer skal porteres';
					testActivationLineRecord[0].Delivery_Email__c = 'tuba@tuba.com';
					testActivationLineRecord[0].Ekstra_Data_SIM_number__c = '33333333333';
					testActivationLineRecord[0].Existing_SIM_number__c = '222222222';
					testActivationLineRecord[0].Phone_no__c = '28270857';
					testActivationLineRecord[0].Actual_delivery_date__c = Date.today() + 5;
					testActivationLineRecord[0].Invoice_Type__c = 'PDF';
					testActivationLineRecord[0].Invoice_Email__c = 'test@test.com';
					testActivationLineRecord[0].Delivery_Street_and_number__c = 'Holmbladsgade 139';
					testActivationLineRecord[0].Delivery_Att__c = 'Att:';
					testActivationLineRecord[0].Number_Porting_End_of_Commitment__c = true;
					testActivationLineRecord[0].Case__c = cs.Id;
					testActivationLineRecord[0].Not_to_Activation__c = false;

					update testActivationLineRecord[0];

					//MyClient client = new MyClient();
					Test.startTest();
					ApexPages.StandardController controller2 = new ApexPages.StandardController(acct);
					DataCollection_RenewalQuote.RenewalQuote(acct.Id);

					DataCollection_RenewalQuote test = new DataCollection_RenewalQuote(controller2);
					DataCollection_RenewalQuote.recordId = 'test';

					DataCollection_RenewalBatch ProcessBatch = new DataCollection_RenewalBatch();
					ProcessBatch.query = 'select Id,SBQQ__Account__c from SBQQ__Quote__c where id =\'' + quo.Id + '\' ';
					ID batchprocessid = Database.executeBatch(ProcessBatch);
				}
			}

			Integer callouts = Limits.getCallouts();
			Test.stopTest();
		}
	}
}