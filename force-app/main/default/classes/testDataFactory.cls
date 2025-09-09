@IsTest
public class testDataFactory {
	public static User createUser(String alias, String profileId) {
		User user = new User();
		user.Alias = alias;
		user.Email = 'standarduser@testorg.com';
		user.EmailEncodingKey = 'UTF-8';
		user.LastName = 'Testing';
		user.LanguageLocaleKey = 'en_US';
		user.LocaleSidKey = 'en_US';
		user.ProfileId = profileId;
		user.TimeZoneSidKey = 'America/Los_Angeles';
		user.UserName = StringUtils.makeRandomStringNoNumerics(10) + '@' + StringUtils.makeRandomStringNoNumerics(5) + '.com';
		user.Dealer_Code__c = 1234;
		user.Sales_Agent_Code__c = '12345';
		user.FederationIdentifier = StringUtils.makeRandomStringNoNumerics(7);
		insert user;
		return user;
	}

	public static User createUserForContact(String contactId, String alias, String profileId) {
		User user = new User();
		user.Alias = alias;
		user.Email = 'standarduser@testorg.com';
		user.EmailEncodingKey = 'UTF-8';
		user.LastName = 'Testing';
		user.LanguageLocaleKey = 'en_US';
		user.LocaleSidKey = 'en_US';
		user.ProfileId = profileId;
		user.TimeZoneSidKey = 'America/Los_Angeles';
		user.UserName = StringUtils.makeRandomStringNoNumerics(10) + '@' + StringUtils.makeRandomStringNoNumerics(5) + '.com';
		user.Dealer_Code__c = 1234;
		user.Sales_Agent_Code__c = '12345';
		user.FederationIdentifier = StringUtils.makeRandomStringNoNumerics(7);
		user.ContactId = contactId;
		insert user;
		return user;
	}

	public static Account createAccountWithCVR(String cvr) {
		Account account = new Account();
		account.Name = StringUtils.makeRandomStringNoNumerics(20);
		account.BillingCity = 'CP';
		account.BillingPostalCode = '2000';
		account.BillingCountry = 'DK';
		account.BillingStreet = 'Holmbladsgade 133';
		account.Phone = '111';
		account.CVR__c = cvr;
		return account;
	}

	public static Account createCVRAccountWithBillingAddress(String cvr) {
		Account account = createAccountWithCVR(cvr);
		account.BillingPostalCode = '2300';
		account.Billing_Street_Name__c = 'Billing_Street_Name__c';
		account.Billing_Street_Number__c = '19';
		account.Billing_Floor_Number__c = '2';
		account.Billing_Door_Number__c = '2';
		account.Billing_Street_Number_Suffix__c = 'B';
		insert account;
		return account;
	}

	public static Contact createContact(String accountId) {
		Contact ct = new Contact();
		ct.AccountId = accountId;
		ct.FirstName = StringUtils.makeRandomStringNoNumerics(7);
		ct.LastName = StringUtils.makeRandomStringNoNumerics(7);
		ct.LeadSource = 'CVR';
		ct.Email = (StringUtils.makeRandomStringNoNumerics(10) + '@' + StringUtils.makeRandomStringNoNumerics(5) + '.com').toLowerCase();
		ct.Phone = StringUtils.makeRandomInteger(8);
		ct.MobilePhone = StringUtils.makeRandomInteger(8);
		insert ct;
		return ct;
	}

	public static List<Lead> createSalesPlayLeadsForAccounts(Integer amountOfLeadsForEachAccount, List<Account> accounts) {
		Id salesPlayRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('Sales_Play').getRecordTypeId();
		List<Lead> leads = new List<Lead>();
		for(Account acc : accounts) {
			for(Integer i = 0; i < amountOfLeadsForEachAccount; i++) {
				Lead lead = new Lead(
					Account__c = acc.Id,
					FirstName = 'Test',
					LastName = 'Sales Play' + i,
					Company = 'Test Company',
					RecordTypeId = salesPlayRecordTypeId
				);
				leads.add(lead);
			}
		}
		insert leads;
		return leads;
	}

	public static Location_Line__c createLocationLine(String productId) {
		return new Location_Line__c(
			ZIP_Code__c = '2650',
			City__c = 'Hvidovre',
			Number__c = '8',
			Street_Name__c = 'Daglykkevej',
			Employee_ID__c = '20',
			Subscription_product__c = productId,
			Address_Wash_Status__c = 'Valid',
			SiteId__c = 'SiteId',
			AddressRefId__c = 'AddressRefId',
			lineConnectionStatus__c = 'lineConnectionStatus'
		);
	}

	public static List<POQ_Item__c> createPOQItems(List<Location_Line__c> locations) {
		List<POQ_Item__c> poqItems = new List<POQ_Item__c>();
		for (Location_Line__c location : locations) {
			POQ_Item__c poqItem = new POQ_Item__c(
				DIGGING_NEEDED__c = true,
				plugPresentPositiveValidation__c = true,
				plugTechnicianRequired__c = true,
				Active_Blocking_Line_Present__c = true,
				Location_Line__c = location.Id,
				priceplanCode__c = location.Subscription_product__c
			);
			poqItems.add(poqItem);
		}
		insert poqItems;
		return poqItems;
	}

	public static List<Billing_Account__c> createBillingAccountsForAccounts(List<Account> accounts) {
		List<Billing_Account__c> billingAccounts = new List<Billing_Account__c>();
		for (Account acc : accounts) {
			Billing_Account__c billingAccount = new Billing_Account__c(Account__c = acc.Id, BAN_Number__c = Double.valueOf(StringUtils.makeRandomInteger(9)));
			billingAccounts.add(billingAccount);
		}
		insert billingAccounts;
		return billingAccounts;
	}

	public static List<Contract> createContractsForAccounts(List<Account> accounts) {
		List<Contract> contracts = new List<Contract>();
		List<String> types = new List<String>{ 'Mobile', 'Fastnet', 'Data' };
		for (Account acct : accounts) {
			String type = (new List<String>(types))[Math.mod(Math.abs(Crypto.getRandomLong().intValue()), types.size())];
			Contract contract = new Contract(
				AccountId = acct.Id,
				ContractTerm = 36,
				StartDate = Date.today() + 10,
				Total_Contract_value__c = 200000,
				Status = 'Draft',
				Data_Part_of_Contract__c = type == 'Data',
				Fastnet_Part_of_Contract__c = type == 'Fastnet',
				Mobile_Part_of_Contract__c = type == 'Mobile'
			);
			contracts.add(contract);
		}
		insert contracts;
		return contracts;
	}

	public static List<Contract> createContractsForOpportunities(List<Opportunity> opportunities) {
		List<Contract> contracts = new List<Contract>();
		List<String> types = new List<String>{ 'Mobile', 'Fastnet', 'Data' };
		for(Opportunity opp : opportunities) {
			String type = (new List<String>(types))[Math.mod(Math.abs(Crypto.getRandomLong().intValue()), types.size())];
			Contract contract = new Contract(
				SBQQ__Quote__c = opp.SBQQ__PrimaryQuote__c,
				AccountId = opp.AccountId,
				SBQQ__Opportunity__c = opp.id,
				ContractTerm = 36,
				StartDate = Date.today() + 10,
				Total_Contract_value__c = 200000,
				Status = 'Draft',
				Data_Part_of_Contract__c = type == 'Data',
				Fastnet_Part_of_Contract__c = type == 'Fastnet',
				Mobile_Part_of_Contract__c = type == 'Mobile'
			);
			contracts.add(contract);
		}
		insert contracts;
		return contracts;
	}

	private static Account setUpStandardAccountInfo(Integer i) {
		return new Account(
			Name = 'Test Account num:' + i,
			Rationale__c = 'No CSV number cause this is test record.',
			Status__c = 'Prospect',
			AccountSource = 'Manual'
		);
	}

	public static List<Account> createAccountsForTests(Integer numOfAccounts) {
		List<Account> result = new List<Account>();
		for (Integer i = 0; i < numOfAccounts; ++i) {
			result.add(setUpStandardAccountInfo(i));
		}

		insert result;
		return result;
	}

	public static Account createSingleAccountForTests() {
		Account result = setUpStandardAccountInfo(0);
		result.CVR__c = '38110020';
		insert result;
		return result;
	}

	public static List<Opportunity> createOpportunitiesForAccounts(Integer numOfOppsPerAccount, List<Account> theAccounts) {
		List<Opportunity> result = new List<Opportunity>();
		for (Account singleAccount : theAccounts) {
			for (Integer i = 0; i < numOfOppsPerAccount; ++i) {
				result.add(
					new Opportunity(
						Name = 'Test Opp for Account:' + singleAccount.Name + ' num:' + i,
						AccountId = singleAccount.Id,
						Type = 'New Business',
						CloseDate = Date.Today() + 5,
						StageName = 'Proposal',
						Product_s_in_scope__c = 'M2M;MBB',
						Pricebook2Id = Test.getStandardPricebookId()
					)
				);
			}
		}
		insert result;
		return result;
	}

	public static SBQQ__Quote__c createSingleQuote(String accountId, String opportunityId) {
		SBQQ__Quote__c quote = new SBQQ__Quote__c(
			SBQQ__BillingFrequency__c = 'kvartalsvis.',
			SBQQ__PaymentTerms__c = '30',
			SBQQ__SubscriptionTerm__c = 36,
			SBQQ__Account__c = accountId,
			Invoice_Email__c = 'tuba@tuba.com',
			SBQQ__Opportunity2__c = opportunityId
		);
		return quote;
	}

	public static List<SBQQ__Quote__c> createQuotesForOpps(Integer numOfQuotesPerOpp, List<Opportunity> theOpps) {
		List<SBQQ__Quote__c> result = new List<SBQQ__Quote__c>();
		Id standardPricebookId = Test.getStandardPricebookId();
		for (Opportunity singleOpp : theOpps) {
			for (Integer i = 0; i < numOfQuotesPerOpp; ++i) {
				result.add(
					new SBQQ__Quote__c(
						SBQQ__Opportunity2__c = singleOpp.Id,
						SBQQ__Account__c = singleOpp.AccountId,
						SBQQ__PaperSize__c = 'A4',
						SBQQ__PricebookId__c = standardPricebookId,
						SBQQ__PaymentTerms__c = '30',
						SBQQ__SubscriptionTerm__c = 36,
						SBQQ__Primary__c = (i == 0 ? true : false)
					)
				);
			}
		}
		insert result;
		return result;
	}
	private static Product2 setUpProductInformation(Integer i) {
		List<String> activationRecordTypeValues = new List<String>();
		for (Schema.PicklistEntry singleValue : Product2.Activation_Record_Type__c.getDescribe().getPicklistValues()) {
			if (singleValue.getValue() != 'No activation needed') {
				activationRecordTypeValues.add(singleValue.getLabel());
			}
		}
		return new Product2(
			Name = 'Test Product nr:' + i,
			isActive = true,
			Activation_Record_Type__c = activationRecordTypeValues[Math.mod(Integer.valueOf(Math.random() * 100), activationRecordTypeValues.size())],
			Delivery_Product_Group__c = Product2.Delivery_Product_Group__c.getDescribe().getPicklistValues()[0].getValue()
		);
	}

	private static Product2 setUpAddressProductInformation() {
		Product2 result = new Product2(
			Name = 'Test Address Product',
			isActive = true,
			ProductCode = '3122',
			address_required__c = true,
			Activation_Record_Type__c = 'Home office',
			Delivery_Product_Group__c = 'Home office'
		);
		return result;
	}

	public static List<Product2> createProductsForTests(Integer numOfProds) {
		List<Product2> result = new List<Product2>();
		for (Integer i = 0; i < numOfProds; ++i) {
			if (i == 0)
				result.add(setUpAddressProductInformation());
			else
				result.add(setUpProductInformation(i));
		}
		insert result;

		SBQQ__ProductOption__c productoption = new SBQQ__ProductOption__c(
			SBQQ__Quantity__c = 1,
			SBQQ__Number__c = 1,
			SBQQ__ConfiguredSKU__c = result[0].id,
			SBQQ__OptionalSKU__c = result[0].id
		);

		insert productoption;

		return result;
	}

	public static List<Product2> createNoActionProds(Integer numOfNoActionProds) {
		List<Product2> result = new List<Product2>();
		for (Integer i = 0; i < numOfNoActionProds; ++i) {
			result.add(setUpProductInformation(i));
			result[i].Activation_Record_Type__c = 'No activation needed';
		}
		insert result;
		return result;
	}

	public static List<Product2> createHomeOfficeProds(Integer numOfHomeOfficeProds) {
		List<Product2> result = new List<Product2>();
		for (Integer i = 0; i < numOfHomeOfficeProds; ++i) {
			result.add(setUpProductInformation(i));
			result[i].Activation_Record_Type__c = 'Home office';
			result[i].ProductCode = '3122';
			result[i].address_required__c = true;
		}
		insert result;
		return result;
	}

	public static List<PricebookEntry> createStandardPricebookEntriesForProd(List<Product2> theProducts) {
		List<PricebookEntry> result = new List<PricebookEntry>();
		Id standardPricebookId = Test.getStandardPricebookId();
		for (Product2 singleProduct : theProducts) {
			result.add(new PricebookEntry(IsActive = true, Pricebook2Id = standardPricebookId, Product2Id = singleProduct.Id, UnitPrice = 100));
		}
		insert result;
		return result;
	}

	public static List<SBQQ__QuoteLine__c> createQuoteLineRecordsForQuote(
		Integer numOfQLsPerQuote,
		List<SBQQ__Quote__c> theQuotes,
		Integer numOfDiffProds,
		Integer numOfNoActionProds,
		Boolean additionalDiscount
	) {
		List<SBQQ__QuoteLine__c> result = new List<SBQQ__QuoteLine__c>();
		List<Product2> prodsToUse = createProductsForTests(numOfDiffProds);
		//SBQQ__Product__r.Activation_Record_Type__c <> 'No activation needed' we want this one too :P
		prodsToUse.addAll(createNoActionProds(numOfNoActionProds));
		prodsToUse.addAll(createHomeOfficeProds(numOfNoActionProds));
		List<PricebookEntry> pricebookEntriesList = createStandardPricebookEntriesForProd(prodsToUse);
		Map<Id, PricebookEntry> prodIdToEntryMap = new Map<Id, PricebookEntry>();
		for (Product2 singleProduct : prodsToUse) {
			for (PricebookEntry singleEntry : pricebookEntriesList) {
				if (singleEntry.Product2Id == singleProduct.Id) {
					prodIdToEntryMap.put(singleProduct.Id, singleEntry);
				}
			}
		}
		for (SBQQ__Quote__c singleQuote : theQuotes) {
			for (Integer i = 0; i < numOfDiffProds; ++i) {
				result.add(
					new SBQQ__QuoteLine__c(
						SBQQ__Quote__c = singleQuote.Id,
						SBQQ__Product__c = prodsToUse[Math.mod(i, prodsToUse.size())].Id,
						SBQQ__PricebookEntryId__c = prodIdToEntryMap.get(prodsToUse[Math.mod(i, prodsToUse.size())].Id).Id,
						SBQQ__Quantity__c = Integer.valueOf(Math.random() * 100),
						SBQQ__NetPrice__c = Integer.valueOf(Math.random() * 1000),
						SBQQ__AdditionalDiscountAmount__c = ((additionalDiscount && Math.mod(i, 2) == 0) ? 200 : 0)
					)
				);
			}
		}

		insert result;
		return result;
	}

	public static List<Case> createCasesForOpportunitiesAndAssignThem(List<Opportunity> theOppsList) {
		List<Case> result = new List<Case>();
		List<Opportunity> oppsToUpdate = new List<Opportunity>();
		for (Opportunity singleOpp : theOppsList) {
			result.add(
				new Case(
					AccountId = singleOpp.AccountId,
					Origin = 'Quote',
					Quote__c = singleOpp.SBQQ__PrimaryQuote__c,
					recordTypeId = Label.Order_Fulfilment_Case_Record_Type,
					Requested_delivery_date__c = singleOpp.SBQQ__PrimaryQuote__r.SBQQ__StartDate__c,
					Opportunity__c = singleOpp.Id
				)
			);
		}
		insert result;
		for (Case singleCase : result) {
			oppsToUpdate.add(new Opportunity(Id = singleCase.Opportunity__c, Case__c = singleCase.Id));
		}
		update oppsToUpdate;
		return result;
	}

	public static List<Activation__c> createActivationHeadersForQuoteLines(List<SBQQ__QuoteLine__c> theLines, List<Opportunity> theRelatedOpportunity) {
		List<Activation__c> result = new List<Activation__c>();
		Map<Id, Opportunity> quoteIdToParentOpportunity = new Map<Id, Opportunity>();
		for (Opportunity singleOpp : theRelatedOpportunity) {
			quoteIdToParentOpportunity.put(singleOpp.SBQQ__PrimaryQuote__c, singleOpp);
		}
		List<String> activationTypeList = new List<String>();
		for (SBQQ__QuoteLine__c singleLine : theLines) {
			if ((!activationTypeList.contains(singleLine.Activation_Record_Type__c)) && quoteIdToParentOpportunity.containsKey(singleLine.SBQQ__Quote__c)) {
				result.add(
					new Activation__c(
						Name = singleLine.Activation_Record_Type__c,
						Case__c = quoteIdToParentOpportunity.get(singleLine.SBQQ__Quote__c).Case__c,
						RecordTypeId = Schema.sObjectType.Activation__c.getRecordTypeInfosByName()
							.get(singleLine.Activation_Record_Type__c + ' activation')
							.getRecordTypeId()
					)
				);
			}
		}
		insert result;
		return result;
	}

	public static List<SBQQ__QuoteLine__c> updateQuoteLines(List<SBQQ__QuoteLine__c> theLines, List<Activation__c> theActivations) {
		Map<String, Id> ActivationIdsPerRecordType = new Map<String, Id>();
		List<SBQQ__QuoteLine__c> updateQuoteLineList = new List<SBQQ__QuoteLine__c>();
		for (Activation__c ac : theActivations) {
			ActivationIdsPerRecordType.put(ac.RecordType.name.remove(' activation'), ac.Id);
		}

		for (SBQQ__QuoteLine__c s : theLines) {
			updateQuoteLineList.add(new SBQQ__QuoteLine__c(Id = s.Id, Activation__c = ActivationIdsPerRecordType.get(s.Activation_Record_Type__c)));
		}
		update updateQuoteLineList;
		return updateQuoteLineList;
	}

	public static List<Activation_line__c> createActivationlines(List<SBQQ__QuoteLine__c> theLines) {
		List<Activation_line__c> result = new List<Activation_line__c>();
		List<String> activationTypeList = new List<String>();
		for (SBQQ__QuoteLine__c singleLine : theLines) {
			result.add(
				new Activation_line__c(
					Activation__c = singleLine.Activation__c,
					Quote_line__c = singleLine.Id,
					RecordTypeId = Schema.sObjectType.Activation_line__c.getRecordTypeInfosByName()
						.get(singleLine.Activation_Record_Type__c + ' activation line')
						.getRecordTypeId(),
					Delivery_City__c = singleLine.SBQQ__Quote__r.SBQQ__BillingCity__c,
					Manual_Product__c = singleLine.SBQQ__Product__c
				)
			);
		}
		insert result;
		return result;
	}

	public static List<Quote_Line_Detail__c> createQuoteLineDetailsForQuoteLines(Integer numOfQLDPerQL, List<SBQQ__QuoteLine__c> theQuoteLines) {
		List<Quote_Line_Detail__c> result = new List<Quote_Line_Detail__c>();
		for (Integer i = 0; i < theQuoteLines.size(); ++i) {
			for (Integer j = 0; j < numOfQLDPerQL; ++j) {
				result.add(new Quote_Line_Detail__c(Mobile_no__c = 'RandomNumber' + i + ':' + j, Quote_Line__c = theQuoteLines[i].Id, Quantity__c = 1 + i + j));
			}
		}
		insert result;
		return result;
	}

	public static List<Product2> createBundles(
		Integer numberOfDifferentBundles,
		Integer numberOfDifferentCategories,
		Integer numberOfDifferentFeaturesPerBundle,
		Integer numberOfDifferentProductsPerFeature,
		Integer numberOfDifferentOptionsPerBundle
	) {
		List<Product2> result = new List<Product2>();

		//Interesting scenarious:
		//1. Bundle with at least one category with more then two products in same feature: 1, 2, 2, 2, 5
		//

		List<Schema.PicklistEntry> categoryValues = SBQQ__ProductFeature__c.SBQQ__Category__c.getDescribe().getPicklistValues(); //.getLabel()
		Integer numberOfCategories = (categoryValues.size() < numberOfDifferentCategories ? categoryValues.size() : numberOfDifferentCategories);

		for (Integer i = 0; i < numberOfDifferentBundles; ++i) {
			result.add(setUpProductInformation(i));
			result[i].Name = result[i].Name + ' MainBundle';
			result[i].activate_with_other_products__c = false;
			result[i].SBQQ__Hidden__c = true;
		}
		for (Integer i = 0; i < numberOfDifferentBundles * numberOfDifferentFeaturesPerBundle * numberOfDifferentProductsPerFeature; ++i) {
			result.add(setUpProductInformation(i));
			result[i].activate_with_other_products__c = (Math.mod(i, 3) == 0 ? false : true); // To indicate this is an addone true or main product false
		}
		insert result;

		Map<Id, PricebookEntry> productIdToPBEntryMap = new Map<Id, PricebookEntry>();
		for (PricebookEntry singlePriceBookEntry : createStandardPricebookEntriesForProd(result)) {
			// To be removed... Never used in the end
			productIdToPBEntryMap.put(singlePriceBookEntry.Id, singlePriceBookEntry);
		}

		// ProductOptions and Features

		List<SBQQ__ProductFeature__c> featuresForProducts = new List<SBQQ__ProductFeature__c>();
		for (Integer i = 0; i < numberOfDifferentBundles; ++i) {
			for (Integer j = 0; j < numberOfDifferentFeaturesPerBundle; ++j) {
				featuresForProducts.add(
					new SBQQ__ProductFeature__c(
						Name = 'Feature Name ' + j,
						SBQQ__Number__c = j,
						SBQQ__ConfiguredSKU__c = result[i].Id,
						SBQQ__Category__c = categoryValues[Math.mod((i + 1) * (j + 1), categoryValues.size())].getLabel() /// integerValue1 divided by integerValue2
					)
				);
			}
		}
		insert featuresForProducts;
		Map<Id, List<Id>> skuIdToListOfFeatures = new Map<Id, List<Id>>();

		for (SBQQ__ProductFeature__c singleF : featuresForProducts) {
			if (skuIdToListOfFeatures.containsKey(singleF.SBQQ__ConfiguredSKU__c))
				skuIdToListOfFeatures.get(singleF.SBQQ__ConfiguredSKU__c).add(singleF.Id);
			else
				skuIdToListOfFeatures.put(singleF.SBQQ__ConfiguredSKU__c, new List<Id>{ singleF.Id });
		}

		// Product Options
		List<SBQQ__ProductOption__c> productOptionsForBundles = new List<SBQQ__ProductOption__c>();
		for (Integer i = 0; i < numberOfDifferentBundles; ++i) {
			if (numberOfDifferentOptionsPerBundle > 0) {
				for (Integer j = numberOfDifferentBundles; j < numberOfDifferentOptionsPerBundle + numberOfDifferentBundles; ++j) {
					productOptionsForBundles.add(
						new SBQQ__ProductOption__c(
							SBQQ__Number__c = j - numberOfDifferentBundles,
							SBQQ__ConfiguredSKU__c = result[i].Id,
							SBQQ__OptionalSKU__c = result[
									Math.mod(j, result.size()) < numberOfDifferentBundles ? numberOfDifferentBundles : Math.mod(j, result.size())
								]
								.Id, // If someone pick 0 products per featue then this will fail cause we use numberOfDifferentBudles... :P
							SBQQ__Feature__c = skuIdToListOfFeatures.get(result[i].Id)[
								Math.mod(Integer.valueOf(Math.random() * 100), skuIdToListOfFeatures.get(result[i].Id).size())
							] //featuresForProducts[ Math.mod( i+j, featuresForProducts.size() ) ].Id
						)
					);
				}
			}
		}
		insert productOptionsForBundles;

		return result;
	}

	public static Map<String, List<Product2>> createSpecificBundle() {
		//We will have to bundles with 5 options each 2 main and 3 addons
		Map<String, List<Product2>> result = new Map<String, List<Product2>>();
		result.put('Bundles', new List<Product2>());
		result.put('MainServices', new List<Product2>());
		result.put('Addones', new List<Product2>());

		List<Product2> productsToInsert = new List<Product2>();
		productsToInsert.add(
			new Product2(
				Name = 'MainBundle1',
				Activation_Record_Type__c = 'No activation needed',
				IsActive = true,
				ProductCode = 'B0001',
				SBQQ__Component__c = false,
				SBQQ__Hidden__c = true,
				activate_with_other_products__c = false,
				ProductAPI_Telia_Product_Id__c = 'B0001'
			)
		);
		productsToInsert.add(
			new Product2(
				Name = 'MainBundle2',
				Activation_Record_Type__c = 'No activation needed',
				IsActive = true,
				ProductCode = 'B0002',
				SBQQ__Component__c = false,
				SBQQ__Hidden__c = true,
				activate_with_other_products__c = false,
				ProductAPI_Telia_Product_Id__c = 'B0002'
			)
		);
		//Bundle1 0,1
		//Main Services
		productsToInsert.add(
			new Product2(
				Name = 'MainService1',
				Activation_Record_Type__c = 'Voice',
				IsActive = true,
				ProductCode = 'MS0001',
				SBQQ__Component__c = true,
				SBQQ__Hidden__c = false,
				activate_with_other_products__c = false,
				ProductAPI_Telia_Product_Id__c = 'MS0001',
				Available_Monthly_Data_MB__c = 500.50,
				Family = 'MS Family 1',
				Contract_Group__c = 'MS CGroup 1',
				Product_Group__c = 'ProductGroup1',
				requires_activation__c = true,
				Requires_Activation_Check__c = true,
				SBQQ__QuantityEditable__c = true
			)
		);
		productsToInsert.add(
			new Product2(
				Name = 'MainService2',
				Activation_Record_Type__c = 'Voice',
				IsActive = true,
				ProductCode = 'MS0002',
				SBQQ__Component__c = true,
				SBQQ__Hidden__c = false,
				activate_with_other_products__c = false,
				ProductAPI_Telia_Product_Id__c = 'MS0002',
				Available_Monthly_Data_MB__c = 1001.00,
				Family = 'MS Family 1',
				Contract_Group__c = 'MS CGroup 1',
				Product_Group__c = 'ProductGroup1',
				requires_activation__c = true,
				Requires_Activation_Check__c = true,
				SBQQ__QuantityEditable__c = true
			)
		);
		//Addones 2,3
		// for MainService1
		productsToInsert.add(
			new Product2(
				Name = 'Addone1',
				Activation_Record_Type__c = 'Voice',
				IsActive = true,
				ProductCode = 'Add0001',
				SBQQ__Component__c = true,
				SBQQ__Hidden__c = false,
				activate_with_other_products__c = true,
				ProductAPI_Telia_Product_Id__c = 'Add0001',
				Product_Group__c = 'ProductGroup1',
				requires_activation__c = true,
				Requires_Activation_Check__c = true,
				SBQQ__QuantityEditable__c = true
			)
		);
		productsToInsert.add(
			new Product2(
				Name = 'Addone2',
				Activation_Record_Type__c = 'Voice',
				IsActive = true,
				ProductCode = 'Add0002',
				SBQQ__Component__c = true,
				SBQQ__Hidden__c = false,
				activate_with_other_products__c = true,
				ProductAPI_Telia_Product_Id__c = 'Add0002',
				Product_Group__c = 'ProductGroup1',
				requires_activation__c = true,
				Requires_Activation_Check__c = true,
				SBQQ__QuantityEditable__c = true
			)
		);
		productsToInsert.add(
			new Product2(
				Name = 'Addone3',
				Activation_Record_Type__c = 'Voice',
				IsActive = true,
				ProductCode = 'Add0003',
				SBQQ__Component__c = true,
				SBQQ__Hidden__c = false,
				activate_with_other_products__c = true,
				ProductAPI_Telia_Product_Id__c = 'Add0003',
				Product_Group__c = 'ProductGroup1',
				requires_activation__c = true,
				Requires_Activation_Check__c = true,
				SBQQ__QuantityEditable__c = true
			)
		);
		// for MainService2 4,5,6
		productsToInsert.add(
			new Product2(
				Name = 'Addone4',
				Activation_Record_Type__c = 'Voice',
				IsActive = true,
				ProductCode = 'Add0004',
				SBQQ__Component__c = true,
				SBQQ__Hidden__c = false,
				activate_with_other_products__c = true,
				ProductAPI_Telia_Product_Id__c = 'Add0004',
				Product_Group__c = 'ProductGroup1',
				requires_activation__c = true,
				Requires_Activation_Check__c = true,
				SBQQ__QuantityEditable__c = true
			)
		);
		productsToInsert.add(
			new Product2(
				Name = 'Addone5',
				Activation_Record_Type__c = 'Voice',
				IsActive = true,
				ProductCode = 'Add0005',
				SBQQ__Component__c = true,
				SBQQ__Hidden__c = false,
				activate_with_other_products__c = true,
				ProductAPI_Telia_Product_Id__c = 'Add0005',
				Product_Group__c = 'ProductGroup1',
				requires_activation__c = true,
				Requires_Activation_Check__c = true,
				SBQQ__QuantityEditable__c = true
			)
		);
		productsToInsert.add(
			new Product2(
				Name = 'Addone6',
				Activation_Record_Type__c = 'Voice',
				IsActive = true,
				ProductCode = 'Add0006',
				SBQQ__Component__c = true,
				SBQQ__Hidden__c = false,
				activate_with_other_products__c = true,
				ProductAPI_Telia_Product_Id__c = 'Add0006',
				Product_Group__c = 'ProductGroup1',
				requires_activation__c = true,
				Requires_Activation_Check__c = true,
				SBQQ__QuantityEditable__c = true
			)
		);
		///////////////////////////////////////////////////////////////////////
		//Bundle2 7,8,9
		//Main Services
		productsToInsert.add(
			new Product2(
				Name = 'MainService3',
				Activation_Record_Type__c = 'Voice',
				IsActive = true,
				ProductCode = 'MS0003',
				SBQQ__Component__c = true,
				SBQQ__Hidden__c = false,
				activate_with_other_products__c = false,
				ProductAPI_Telia_Product_Id__c = 'MS0003',
				Available_Monthly_Data_MB__c = 100.00,
				Family = 'MS Family 2',
				Contract_Group__c = 'MS CGroup 2',
				Product_Group__c = 'ProductGroup2',
				requires_activation__c = true,
				Requires_Activation_Check__c = true,
				SBQQ__QuantityEditable__c = true
			)
		);
		productsToInsert.add(
			new Product2(
				Name = 'MainService4',
				Activation_Record_Type__c = 'Voice',
				IsActive = true,
				ProductCode = 'MS0004',
				SBQQ__Component__c = true,
				SBQQ__Hidden__c = false,
				activate_with_other_products__c = false,
				ProductAPI_Telia_Product_Id__c = 'MS0004',
				Available_Monthly_Data_MB__c = 100.00,
				Family = 'MS Family 3',
				Contract_Group__c = 'MS CGroup 3',
				Product_Group__c = 'ProductGroup3',
				requires_activation__c = true,
				Requires_Activation_Check__c = true,
				SBQQ__QuantityEditable__c = true
			)
		);
		//Addones 10,11
		// for MainService3
		productsToInsert.add(
			new Product2(
				Name = 'Addone7',
				Activation_Record_Type__c = 'Voice',
				IsActive = true,
				ProductCode = 'Add0007',
				SBQQ__Component__c = true,
				SBQQ__Hidden__c = false,
				activate_with_other_products__c = true,
				ProductAPI_Telia_Product_Id__c = 'Add0007',
				Product_Group__c = 'ProductGroup2',
				requires_activation__c = true,
				Requires_Activation_Check__c = true,
				SBQQ__QuantityEditable__c = true
			)
		);
		productsToInsert.add(
			new Product2(
				Name = 'Addone8',
				Activation_Record_Type__c = 'Voice',
				IsActive = true,
				ProductCode = 'Add0008',
				SBQQ__Component__c = true,
				SBQQ__Hidden__c = false,
				activate_with_other_products__c = true,
				ProductAPI_Telia_Product_Id__c = 'Add0008',
				Product_Group__c = 'ProductGroup2',
				requires_activation__c = true,
				Requires_Activation_Check__c = true,
				SBQQ__QuantityEditable__c = true
			)
		);
		productsToInsert.add(
			new Product2(
				Name = 'Addone9',
				Activation_Record_Type__c = 'Voice',
				IsActive = true,
				ProductCode = 'Add0009',
				SBQQ__Component__c = true,
				SBQQ__Hidden__c = false,
				activate_with_other_products__c = true,
				ProductAPI_Telia_Product_Id__c = 'Add0009',
				Product_Group__c = 'ProductGroup2',
				requires_activation__c = true,
				Requires_Activation_Check__c = true,
				SBQQ__QuantityEditable__c = true
			)
		);
		// for MainService4 12,13,14
		productsToInsert.add(
			new Product2(
				Name = 'Addone10',
				Activation_Record_Type__c = 'Voice',
				IsActive = true,
				ProductCode = 'Add00010',
				SBQQ__Component__c = true,
				SBQQ__Hidden__c = false,
				activate_with_other_products__c = true,
				ProductAPI_Telia_Product_Id__c = 'Add00010',
				Product_Group__c = 'ProductGroup3',
				requires_activation__c = true,
				Requires_Activation_Check__c = true,
				SBQQ__QuantityEditable__c = true
			)
		);
		productsToInsert.add(
			new Product2(
				Name = 'Addone11',
				Activation_Record_Type__c = 'Voice',
				IsActive = true,
				ProductCode = 'Add00011',
				SBQQ__Component__c = true,
				SBQQ__Hidden__c = false,
				activate_with_other_products__c = true,
				ProductAPI_Telia_Product_Id__c = 'Add00011',
				Product_Group__c = 'ProductGroup3',
				requires_activation__c = true,
				Requires_Activation_Check__c = true,
				SBQQ__QuantityEditable__c = true
			)
		);
		productsToInsert.add(
			new Product2(
				Name = 'Addone12',
				Activation_Record_Type__c = 'Voice',
				IsActive = true,
				ProductCode = 'Add00012',
				SBQQ__Component__c = true,
				SBQQ__Hidden__c = false,
				activate_with_other_products__c = true,
				ProductAPI_Telia_Product_Id__c = 'Add00012',
				Product_Group__c = 'ProductGroup3',
				requires_activation__c = true,
				Requires_Activation_Check__c = true,
				SBQQ__QuantityEditable__c = true
			)
		); // 15,16,17

		insert productsToInsert;
		for (Integer i = 0; i < 2; ++i) {
			result.get('Bundles').add(productsToInsert[i]);
		}

		for (Integer i = 2; i < 4; ++i) {
			result.get('MainServices').add(productsToInsert[i]);
		}
		for (Integer i = 10; i < 12; ++i) {
			result.get('MainServices').add(productsToInsert[i]);
		}

		for (Integer i = 4; i < 10; ++i) {
			result.get('Addones').add(productsToInsert[i]);
		}
		for (Integer i = 12; i < productsToInsert.size(); ++i) {
			result.get('Addones').add(productsToInsert[i]);
		}
		//PricebookEntries
		createStandardPricebookEntriesForProd(productsToInsert);
		// Product Features
		// First Bundle two feature, one for main services and one for addone (same category) ~ second bundle 5 features 3 for one main service and it's addones rest for the other main service with addones
		List<SBQQ__ProductFeature__c> featuresToInsert = new List<SBQQ__ProductFeature__c>(); // Need for update! We shold cange from hardcoded categorie field values to taking current values of the field from system!
		// Features First Bundle
		featuresToInsert.add(
			new SBQQ__ProductFeature__c(
				Name = 'First Bundle Main Services Feature',
				SBQQ__Category__c = 'Corporate',
				SBQQ__ConfiguredSKU__c = result.get('Bundles')[0].Id,
				SBQQ__Number__c = 1
			)
		);
		featuresToInsert.add(
			new SBQQ__ProductFeature__c(
				Name = 'First Bundle Addones Feature',
				SBQQ__Category__c = 'Corporate',
				SBQQ__ConfiguredSKU__c = result.get('Bundles')[0].Id,
				SBQQ__Number__c = 2
			)
		);
		// Features Second Bundle
		featuresToInsert.add(
			new SBQQ__ProductFeature__c(
				Name = 'Second Bundle Main Services Feature1',
				SBQQ__Category__c = 'Internet DSL',
				SBQQ__ConfiguredSKU__c = result.get('Bundles')[1].Id,
				SBQQ__Number__c = 3
			)
		);
		featuresToInsert.add(
			new SBQQ__ProductFeature__c(
				Name = 'Second Bundle Main Services Feature2',
				SBQQ__Category__c = 'Internet Fiber',
				SBQQ__ConfiguredSKU__c = result.get('Bundles')[1].Id,
				SBQQ__Number__c = 4
			)
		);
		featuresToInsert.add(
			new SBQQ__ProductFeature__c(
				Name = 'Second Bundle Main Services1 Addons Feature1',
				SBQQ__Category__c = 'Internet DSL',
				SBQQ__ConfiguredSKU__c = result.get('Bundles')[1].Id,
				SBQQ__Number__c = 5
			)
		);
		featuresToInsert.add(
			new SBQQ__ProductFeature__c(
				Name = 'Second Bundle Main Services1 Addons Feature2',
				SBQQ__Category__c = 'Internet DSL',
				SBQQ__ConfiguredSKU__c = result.get('Bundles')[1].Id,
				SBQQ__Number__c = 6
			)
		);
		featuresToInsert.add(
			new SBQQ__ProductFeature__c(
				Name = 'Second Bundle Main Services2 Addons Feature1',
				SBQQ__Category__c = 'Internet Fiber',
				SBQQ__ConfiguredSKU__c = result.get('Bundles')[1].Id,
				SBQQ__Number__c = 7
			)
		);

		insert featuresToInsert;

		// Product Options
		List<SBQQ__ProductOption__c> productOptionsToInsert = new List<SBQQ__ProductOption__c>();
		//  for Bundle1
		//    for MainService
		productOptionsToInsert.add(
			new SBQQ__ProductOption__c(
				SBQQ__Number__c = 0,
				SBQQ__ConfiguredSKU__c = result.get('Bundles')[0].Id,
				SBQQ__OptionalSKU__c = result.get('MainServices')[0].Id, // If someone pick 0 products per featue then this will fail cause we use numberOfDifferentBudles... :P
				SBQQ__Feature__c = featuresToInsert[0].Id //featuresForProducts[ Math.mod( i+j, featuresForProducts.size() ) ].Id
			)
		);
		productOptionsToInsert.add(
			new SBQQ__ProductOption__c(
				SBQQ__Number__c = 2,
				SBQQ__ConfiguredSKU__c = result.get('Bundles')[0].Id,
				SBQQ__OptionalSKU__c = result.get('MainServices')[1].Id, // If someone pick 0 products per featue then this will fail cause we use numberOfDifferentBudles... :P
				SBQQ__Feature__c = featuresToInsert[0].Id //featuresForProducts[ Math.mod( i+j, featuresForProducts.size() ) ].Id
			)
		);
		//    for Addones
		productOptionsToInsert.add(
			new SBQQ__ProductOption__c(
				SBQQ__Number__c = 1,
				SBQQ__ConfiguredSKU__c = result.get('Bundles')[0].Id,
				SBQQ__OptionalSKU__c = result.get('Addones')[0].Id, // If someone pick 0 products per featue then this will fail cause we use numberOfDifferentBudles... :P
				SBQQ__Feature__c = featuresToInsert[1].Id //featuresForProducts[ Math.mod( i+j, featuresForProducts.size() ) ].Id
			)
		);
		productOptionsToInsert.add(
			new SBQQ__ProductOption__c(
				SBQQ__Number__c = 3,
				SBQQ__ConfiguredSKU__c = result.get('Bundles')[0].Id,
				SBQQ__OptionalSKU__c = result.get('Addones')[1].Id, // If someone pick 0 products per featue then this will fail cause we use numberOfDifferentBudles... :P
				SBQQ__Feature__c = featuresToInsert[1].Id //featuresForProducts[ Math.mod( i+j, featuresForProducts.size() ) ].Id
			)
		);
		productOptionsToInsert.add(
			new SBQQ__ProductOption__c(
				SBQQ__Number__c = 4,
				SBQQ__ConfiguredSKU__c = result.get('Bundles')[0].Id,
				SBQQ__OptionalSKU__c = result.get('Addones')[2].Id, // If someone pick 0 products per featue then this will fail cause we use numberOfDifferentBudles... :P
				SBQQ__Feature__c = featuresToInsert[1].Id //featuresForProducts[ Math.mod( i+j, featuresForProducts.size() ) ].Id
			)
		);
		productOptionsToInsert.add(
			new SBQQ__ProductOption__c(
				SBQQ__Number__c = 5,
				SBQQ__ConfiguredSKU__c = result.get('Bundles')[0].Id,
				SBQQ__OptionalSKU__c = result.get('Addones')[3].Id, // If someone pick 0 products per featue then this will fail cause we use numberOfDifferentBudles... :P
				SBQQ__Feature__c = featuresToInsert[1].Id //featuresForProducts[ Math.mod( i+j, featuresForProducts.size() ) ].Id
			)
		);
		productOptionsToInsert.add(
			new SBQQ__ProductOption__c(
				SBQQ__Number__c = 6,
				SBQQ__ConfiguredSKU__c = result.get('Bundles')[0].Id,
				SBQQ__OptionalSKU__c = result.get('Addones')[4].Id, // If someone pick 0 products per featue then this will fail cause we use numberOfDifferentBudles... :P
				SBQQ__Feature__c = featuresToInsert[1].Id //featuresForProducts[ Math.mod( i+j, featuresForProducts.size() ) ].Id
			)
		);
		productOptionsToInsert.add(
			new SBQQ__ProductOption__c(
				SBQQ__Number__c = 7,
				SBQQ__ConfiguredSKU__c = result.get('Bundles')[0].Id,
				SBQQ__OptionalSKU__c = result.get('Addones')[5].Id, // If someone pick 0 products per featue then this will fail cause we use numberOfDifferentBudles... :P
				SBQQ__Feature__c = featuresToInsert[1].Id //featuresForProducts[ Math.mod( i+j, featuresForProducts.size() ) ].Id
			)
		);
		//  for Bundle2
		//    for MainService
		productOptionsToInsert.add(
			new SBQQ__ProductOption__c(
				SBQQ__Number__c = 8,
				SBQQ__ConfiguredSKU__c = result.get('Bundles')[1].Id,
				SBQQ__OptionalSKU__c = result.get('MainServices')[2].Id, // If someone pick 0 products per featue then this will fail cause we use numberOfDifferentBudles... :P
				SBQQ__Feature__c = featuresToInsert[2].Id //featuresForProducts[ Math.mod( i+j, featuresForProducts.size() ) ].Id
			)
		);
		productOptionsToInsert.add(
			new SBQQ__ProductOption__c(
				SBQQ__Number__c = 9,
				SBQQ__ConfiguredSKU__c = result.get('Bundles')[1].Id,
				SBQQ__OptionalSKU__c = result.get('MainServices')[3].Id, // If someone pick 0 products per featue then this will fail cause we use numberOfDifferentBudles... :P
				SBQQ__Feature__c = featuresToInsert[3].Id //featuresForProducts[ Math.mod( i+j, featuresForProducts.size() ) ].Id
			)
		);
		//    for Addones
		productOptionsToInsert.add(
			new SBQQ__ProductOption__c(
				SBQQ__Number__c = 10,
				SBQQ__ConfiguredSKU__c = result.get('Bundles')[1].Id,
				SBQQ__OptionalSKU__c = result.get('Addones')[6].Id, // If someone pick 0 products per featue then this will fail cause we use numberOfDifferentBudles... :P
				SBQQ__Feature__c = featuresToInsert[4].Id //featuresForProducts[ Math.mod( i+j, featuresForProducts.size() ) ].Id
			)
		);
		productOptionsToInsert.add(
			new SBQQ__ProductOption__c(
				SBQQ__Number__c = 11,
				SBQQ__ConfiguredSKU__c = result.get('Bundles')[1].Id,
				SBQQ__OptionalSKU__c = result.get('Addones')[7].Id, // If someone pick 0 products per featue then this will fail cause we use numberOfDifferentBudles... :P
				SBQQ__Feature__c = featuresToInsert[4].Id //featuresForProducts[ Math.mod( i+j, featuresForProducts.size() ) ].Id
			)
		);
		productOptionsToInsert.add(
			new SBQQ__ProductOption__c(
				SBQQ__Number__c = 12,
				SBQQ__ConfiguredSKU__c = result.get('Bundles')[1].Id,
				SBQQ__OptionalSKU__c = result.get('Addones')[8].Id, // If someone pick 0 products per featue then this will fail cause we use numberOfDifferentBudles... :P
				SBQQ__Feature__c = featuresToInsert[5].Id //featuresForProducts[ Math.mod( i+j, featuresForProducts.size() ) ].Id
			)
		);
		productOptionsToInsert.add(
			new SBQQ__ProductOption__c(
				SBQQ__Number__c = 13,
				SBQQ__ConfiguredSKU__c = result.get('Bundles')[1].Id,
				SBQQ__OptionalSKU__c = result.get('Addones')[9].Id, // If someone pick 0 products per featue then this will fail cause we use numberOfDifferentBudles... :P
				SBQQ__Feature__c = featuresToInsert[6].Id //featuresForProducts[ Math.mod( i+j, featuresForProducts.size() ) ].Id
			)
		);
		productOptionsToInsert.add(
			new SBQQ__ProductOption__c(
				SBQQ__Number__c = 14,
				SBQQ__ConfiguredSKU__c = result.get('Bundles')[1].Id,
				SBQQ__OptionalSKU__c = result.get('Addones')[10].Id, // If someone pick 0 products per featue then this will fail cause we use numberOfDifferentBudles... :P
				SBQQ__Feature__c = featuresToInsert[6].Id //featuresForProducts[ Math.mod( i+j, featuresForProducts.size() ) ].Id
			)
		);
		productOptionsToInsert.add(
			new SBQQ__ProductOption__c(
				SBQQ__Number__c = 15,
				SBQQ__ConfiguredSKU__c = result.get('Bundles')[1].Id,
				SBQQ__OptionalSKU__c = result.get('Addones')[11].Id, // If someone pick 0 products per featue then this will fail cause we use numberOfDifferentBudles... :P
				SBQQ__Feature__c = featuresToInsert[6].Id //featuresForProducts[ Math.mod( i+j, featuresForProducts.size() ) ].Id
			)
		);

		insert productOptionsToInsert;

		return result;
	}

	public static List<SBQQ__QuoteLine__c> createQuoteLinesForSpecificBundleWithDetails(
		Map<String, List<Product2>> specificBundleForUse,
		SBQQ__Quote__c singleQuote
	) {
		List<SBQQ__QuoteLine__c> result = new List<SBQQ__QuoteLine__c>();

		Map<Id, PricebookEntry> productIdToItPricebookEntry = new Map<Id, PricebookEntry>();
		for (PricebookEntry singlePBEntry : [SELECT Id, Product2Id, UnitPrice, Pricebook2Id FROM PricebookEntry WHERE isActive = TRUE]) {
			productIdToItPricebookEntry.put(singlePBEntry.Product2Id, singlePBEntry);
		}
		Map<Id, Map<Id, SBQQ__ProductOption__c>> bundleProdIdToOptionIdToProductOption = new Map<Id, Map<Id, SBQQ__ProductOption__c>>();
		for (SBQQ__ProductOption__c singlePO : [SELECT Id, SBQQ__ConfiguredSKU__c, SBQQ__OptionalSKU__c FROM SBQQ__ProductOption__c]) {
			if (!bundleProdIdToOptionIdToProductOption.containsKey(singlePO.SBQQ__ConfiguredSKU__c))
				bundleProdIdToOptionIdToProductOption.put(singlePO.SBQQ__ConfiguredSKU__c, new Map<Id, SBQQ__ProductOption__c>());
			bundleProdIdToOptionIdToProductOption.get(singlePO.SBQQ__ConfiguredSKU__c).put(singlePO.SBQQ__OptionalSKU__c, singlePO);
		}
		// We want a quote line with both bundles added each one of them having both main products and all addones added to it with 6 main services QLD and 16 Addons QLD for the services mentioned before
		// 1. Add bundles, we need their Id to populate RequiredBy field
		List<SBQQ__QuoteLine__c> bundlesQLList = new List<SBQQ__QuoteLine__c>{
				new SBQQ__QuoteLine__c(
					SBQQ__Quote__c = singleQuote.Id,
					SBQQ__Product__c = specificBundleForUse.get('Bundles')[0].Id,
					SBQQ__PricebookEntryId__c = productIdToItPricebookEntry.get(specificBundleForUse.get('Bundles')[0].Id).Id,
					SBQQ__Quantity__c = 0,
					SBQQ__NetPrice__c = productIdToItPricebookEntry.get(specificBundleForUse.get('Bundles')[0].Id).UnitPrice,
					SBQQ__AdditionalDiscountAmount__c = null
				),
				new SBQQ__QuoteLine__c(
					SBQQ__Quote__c = singleQuote.Id,
					SBQQ__Product__c = specificBundleForUse.get('Bundles')[1].Id,
					SBQQ__PricebookEntryId__c = productIdToItPricebookEntry.get(specificBundleForUse.get('Bundles')[1].Id).Id,
					SBQQ__Quantity__c = 0,
					SBQQ__NetPrice__c = productIdToItPricebookEntry.get(specificBundleForUse.get('Bundles')[1].Id).UnitPrice,
					SBQQ__AdditionalDiscountAmount__c = 20
				)
			},
			otherQLS = new List<SBQQ__QuoteLine__c>();
		insert bundlesQLList; // Now we have ids of RequiredBy QuoteLines
		result.addAll(bundlesQLList);

		// Main Services for first Bundle 0,1
		otherQLS.add(
			new SBQQ__QuoteLine__c(
				SBQQ__Quote__c = singleQuote.Id,
				SBQQ__Product__c = specificBundleForUse.get('MainServices')[0].Id,
				SBQQ__PricebookEntryId__c = productIdToItPricebookEntry.get(specificBundleForUse.get('MainServices')[0].Id).Id,
				SBQQ__Quantity__c = 0,
				SBQQ__NetPrice__c = productIdToItPricebookEntry.get(specificBundleForUse.get('MainServices')[0].Id).UnitPrice,
				SBQQ__AdditionalDiscountAmount__c = null,
				SBQQ__RequiredBy__c = bundlesQLList[0].Id,
				SBQQ__ProductOption__c = bundleProdIdToOptionIdToProductOption.get(bundlesQLList[0].SBQQ__Product__c)
					.get(specificBundleForUse.get('MainServices')[0].Id)
					.Id
			)
		);
		otherQLS.add(
			new SBQQ__QuoteLine__c(
				SBQQ__Quote__c = singleQuote.Id,
				SBQQ__Product__c = specificBundleForUse.get('MainServices')[1].Id,
				SBQQ__PricebookEntryId__c = productIdToItPricebookEntry.get(specificBundleForUse.get('MainServices')[1].Id).Id,
				SBQQ__Quantity__c = 0,
				SBQQ__NetPrice__c = productIdToItPricebookEntry.get(specificBundleForUse.get('MainServices')[1].Id).UnitPrice,
				SBQQ__AdditionalDiscountAmount__c = null,
				SBQQ__RequiredBy__c = bundlesQLList[0].Id,
				SBQQ__ProductOption__c = bundleProdIdToOptionIdToProductOption.get(bundlesQLList[0].SBQQ__Product__c)
					.get(specificBundleForUse.get('MainServices')[1].Id)
					.Id
			)
		);
		// Addones for first boundle 2,3,4,5,6,7
		otherQLS.add(
			new SBQQ__QuoteLine__c(
				SBQQ__Quote__c = singleQuote.Id,
				SBQQ__Product__c = specificBundleForUse.get('Addones')[0].Id,
				SBQQ__PricebookEntryId__c = productIdToItPricebookEntry.get(specificBundleForUse.get('Addones')[0].Id).Id,
				SBQQ__Quantity__c = 0,
				SBQQ__NetPrice__c = productIdToItPricebookEntry.get(specificBundleForUse.get('Addones')[0].Id).UnitPrice,
				SBQQ__AdditionalDiscountAmount__c = null,
				SBQQ__RequiredBy__c = bundlesQLList[0].Id,
				SBQQ__ProductOption__c = bundleProdIdToOptionIdToProductOption.get(bundlesQLList[0].SBQQ__Product__c)
					.get(specificBundleForUse.get('Addones')[0].Id)
					.Id
			)
		);
		otherQLS.add(
			new SBQQ__QuoteLine__c(
				SBQQ__Quote__c = singleQuote.Id,
				SBQQ__Product__c = specificBundleForUse.get('Addones')[1].Id,
				SBQQ__PricebookEntryId__c = productIdToItPricebookEntry.get(specificBundleForUse.get('Addones')[1].Id).Id,
				SBQQ__Quantity__c = 0,
				SBQQ__NetPrice__c = productIdToItPricebookEntry.get(specificBundleForUse.get('Addones')[1].Id).UnitPrice,
				SBQQ__AdditionalDiscountAmount__c = null,
				SBQQ__RequiredBy__c = bundlesQLList[0].Id,
				SBQQ__ProductOption__c = bundleProdIdToOptionIdToProductOption.get(bundlesQLList[0].SBQQ__Product__c)
					.get(specificBundleForUse.get('Addones')[1].Id)
					.Id
			)
		);
		otherQLS.add(
			new SBQQ__QuoteLine__c(
				SBQQ__Quote__c = singleQuote.Id,
				SBQQ__Product__c = specificBundleForUse.get('Addones')[2].Id,
				SBQQ__PricebookEntryId__c = productIdToItPricebookEntry.get(specificBundleForUse.get('Addones')[2].Id).Id,
				SBQQ__Quantity__c = 0,
				SBQQ__NetPrice__c = productIdToItPricebookEntry.get(specificBundleForUse.get('Addones')[2].Id).UnitPrice,
				SBQQ__AdditionalDiscountAmount__c = null,
				SBQQ__RequiredBy__c = bundlesQLList[0].Id,
				SBQQ__ProductOption__c = bundleProdIdToOptionIdToProductOption.get(bundlesQLList[0].SBQQ__Product__c)
					.get(specificBundleForUse.get('Addones')[2].Id)
					.Id
			)
		);
		otherQLS.add(
			new SBQQ__QuoteLine__c(
				SBQQ__Quote__c = singleQuote.Id,
				SBQQ__Product__c = specificBundleForUse.get('Addones')[3].Id,
				SBQQ__PricebookEntryId__c = productIdToItPricebookEntry.get(specificBundleForUse.get('Addones')[3].Id).Id,
				SBQQ__Quantity__c = 0,
				SBQQ__NetPrice__c = productIdToItPricebookEntry.get(specificBundleForUse.get('Addones')[3].Id).UnitPrice,
				SBQQ__AdditionalDiscountAmount__c = null,
				SBQQ__RequiredBy__c = bundlesQLList[0].Id,
				SBQQ__ProductOption__c = bundleProdIdToOptionIdToProductOption.get(bundlesQLList[0].SBQQ__Product__c)
					.get(specificBundleForUse.get('Addones')[3].Id)
					.Id
			)
		);
		otherQLS.add(
			new SBQQ__QuoteLine__c(
				SBQQ__Quote__c = singleQuote.Id,
				SBQQ__Product__c = specificBundleForUse.get('Addones')[4].Id,
				SBQQ__PricebookEntryId__c = productIdToItPricebookEntry.get(specificBundleForUse.get('Addones')[4].Id).Id,
				SBQQ__Quantity__c = 0,
				SBQQ__NetPrice__c = productIdToItPricebookEntry.get(specificBundleForUse.get('Addones')[4].Id).UnitPrice,
				SBQQ__AdditionalDiscountAmount__c = null,
				SBQQ__RequiredBy__c = bundlesQLList[0].Id,
				SBQQ__ProductOption__c = bundleProdIdToOptionIdToProductOption.get(bundlesQLList[0].SBQQ__Product__c)
					.get(specificBundleForUse.get('Addones')[4].Id)
					.Id
			)
		);
		otherQLS.add(
			new SBQQ__QuoteLine__c(
				SBQQ__Quote__c = singleQuote.Id,
				SBQQ__Product__c = specificBundleForUse.get('Addones')[5].Id,
				SBQQ__PricebookEntryId__c = productIdToItPricebookEntry.get(specificBundleForUse.get('Addones')[5].Id).Id,
				SBQQ__Quantity__c = 0,
				SBQQ__NetPrice__c = productIdToItPricebookEntry.get(specificBundleForUse.get('Addones')[5].Id).UnitPrice,
				SBQQ__AdditionalDiscountAmount__c = null,
				SBQQ__RequiredBy__c = bundlesQLList[0].Id,
				SBQQ__ProductOption__c = bundleProdIdToOptionIdToProductOption.get(bundlesQLList[0].SBQQ__Product__c)
					.get(specificBundleForUse.get('Addones')[5].Id)
					.Id
			)
		);
		// Main Services for second Bundle 8,9
		otherQLS.add(
			new SBQQ__QuoteLine__c(
				SBQQ__Quote__c = singleQuote.Id,
				SBQQ__Product__c = specificBundleForUse.get('MainServices')[2].Id,
				SBQQ__PricebookEntryId__c = productIdToItPricebookEntry.get(specificBundleForUse.get('MainServices')[2].Id).Id,
				SBQQ__Quantity__c = 0,
				SBQQ__NetPrice__c = productIdToItPricebookEntry.get(specificBundleForUse.get('MainServices')[2].Id).UnitPrice,
				SBQQ__AdditionalDiscountAmount__c = null,
				SBQQ__RequiredBy__c = bundlesQLList[1].Id,
				SBQQ__ProductOption__c = bundleProdIdToOptionIdToProductOption.get(bundlesQLList[1].SBQQ__Product__c)
					.get(specificBundleForUse.get('MainServices')[2].Id)
					.Id
			)
		);
		otherQLS.add(
			new SBQQ__QuoteLine__c(
				SBQQ__Quote__c = singleQuote.Id,
				SBQQ__Product__c = specificBundleForUse.get('MainServices')[3].Id,
				SBQQ__PricebookEntryId__c = productIdToItPricebookEntry.get(specificBundleForUse.get('MainServices')[3].Id).Id,
				SBQQ__Quantity__c = 0,
				SBQQ__NetPrice__c = productIdToItPricebookEntry.get(specificBundleForUse.get('MainServices')[3].Id).UnitPrice,
				SBQQ__AdditionalDiscountAmount__c = null,
				SBQQ__RequiredBy__c = bundlesQLList[1].Id,
				SBQQ__ProductOption__c = bundleProdIdToOptionIdToProductOption.get(bundlesQLList[1].SBQQ__Product__c)
					.get(specificBundleForUse.get('MainServices')[3].Id)
					.Id
			)
		);
		// Addones for second Bundle 10,11,12,13,14,15
		otherQLS.add(
			new SBQQ__QuoteLine__c(
				SBQQ__Quote__c = singleQuote.Id,
				SBQQ__Product__c = specificBundleForUse.get('Addones')[6].Id,
				SBQQ__PricebookEntryId__c = productIdToItPricebookEntry.get(specificBundleForUse.get('Addones')[6].Id).Id,
				SBQQ__Quantity__c = 0,
				SBQQ__NetPrice__c = productIdToItPricebookEntry.get(specificBundleForUse.get('Addones')[6].Id).UnitPrice,
				SBQQ__AdditionalDiscountAmount__c = null,
				SBQQ__RequiredBy__c = bundlesQLList[1].Id,
				SBQQ__ProductOption__c = bundleProdIdToOptionIdToProductOption.get(bundlesQLList[1].SBQQ__Product__c)
					.get(specificBundleForUse.get('Addones')[6].Id)
					.Id
			)
		);
		otherQLS.add(
			new SBQQ__QuoteLine__c(
				SBQQ__Quote__c = singleQuote.Id,
				SBQQ__Product__c = specificBundleForUse.get('Addones')[7].Id,
				SBQQ__PricebookEntryId__c = productIdToItPricebookEntry.get(specificBundleForUse.get('Addones')[7].Id).Id,
				SBQQ__Quantity__c = 0,
				SBQQ__NetPrice__c = productIdToItPricebookEntry.get(specificBundleForUse.get('Addones')[7].Id).UnitPrice,
				SBQQ__AdditionalDiscountAmount__c = null,
				SBQQ__RequiredBy__c = bundlesQLList[1].Id,
				SBQQ__ProductOption__c = bundleProdIdToOptionIdToProductOption.get(bundlesQLList[1].SBQQ__Product__c)
					.get(specificBundleForUse.get('Addones')[7].Id)
					.Id
			)
		);
		otherQLS.add(
			new SBQQ__QuoteLine__c(
				SBQQ__Quote__c = singleQuote.Id,
				SBQQ__Product__c = specificBundleForUse.get('Addones')[8].Id,
				SBQQ__PricebookEntryId__c = productIdToItPricebookEntry.get(specificBundleForUse.get('Addones')[8].Id).Id,
				SBQQ__Quantity__c = 0,
				SBQQ__NetPrice__c = productIdToItPricebookEntry.get(specificBundleForUse.get('Addones')[8].Id).UnitPrice,
				SBQQ__AdditionalDiscountAmount__c = null,
				SBQQ__RequiredBy__c = bundlesQLList[1].Id,
				SBQQ__ProductOption__c = bundleProdIdToOptionIdToProductOption.get(bundlesQLList[1].SBQQ__Product__c)
					.get(specificBundleForUse.get('Addones')[8].Id)
					.Id
			)
		);
		otherQLS.add(
			new SBQQ__QuoteLine__c(
				SBQQ__Quote__c = singleQuote.Id,
				SBQQ__Product__c = specificBundleForUse.get('Addones')[9].Id,
				SBQQ__PricebookEntryId__c = productIdToItPricebookEntry.get(specificBundleForUse.get('Addones')[9].Id).Id,
				SBQQ__Quantity__c = 0,
				SBQQ__NetPrice__c = productIdToItPricebookEntry.get(specificBundleForUse.get('Addones')[9].Id).UnitPrice,
				SBQQ__AdditionalDiscountAmount__c = null,
				SBQQ__RequiredBy__c = bundlesQLList[1].Id,
				SBQQ__ProductOption__c = bundleProdIdToOptionIdToProductOption.get(bundlesQLList[1].SBQQ__Product__c)
					.get(specificBundleForUse.get('Addones')[9].Id)
					.Id
			)
		);
		otherQLS.add(
			new SBQQ__QuoteLine__c(
				SBQQ__Quote__c = singleQuote.Id,
				SBQQ__Product__c = specificBundleForUse.get('Addones')[10].Id,
				SBQQ__PricebookEntryId__c = productIdToItPricebookEntry.get(specificBundleForUse.get('Addones')[10].Id).Id,
				SBQQ__Quantity__c = 0,
				SBQQ__NetPrice__c = productIdToItPricebookEntry.get(specificBundleForUse.get('Addones')[10].Id).UnitPrice,
				SBQQ__AdditionalDiscountAmount__c = null,
				SBQQ__RequiredBy__c = bundlesQLList[1].Id,
				SBQQ__ProductOption__c = bundleProdIdToOptionIdToProductOption.get(bundlesQLList[1].SBQQ__Product__c)
					.get(specificBundleForUse.get('Addones')[10].Id)
					.Id
			)
		);
		otherQLS.add(
			new SBQQ__QuoteLine__c(
				SBQQ__Quote__c = singleQuote.Id,
				SBQQ__Product__c = specificBundleForUse.get('Addones')[11].Id,
				SBQQ__PricebookEntryId__c = productIdToItPricebookEntry.get(specificBundleForUse.get('Addones')[11].Id).Id,
				SBQQ__Quantity__c = 0,
				SBQQ__NetPrice__c = productIdToItPricebookEntry.get(specificBundleForUse.get('Addones')[11].Id).UnitPrice,
				SBQQ__AdditionalDiscountAmount__c = null,
				SBQQ__RequiredBy__c = bundlesQLList[1].Id,
				SBQQ__ProductOption__c = bundleProdIdToOptionIdToProductOption.get(bundlesQLList[1].SBQQ__Product__c)
					.get(specificBundleForUse.get('Addones')[11].Id)
					.Id
			)
		);

		insert otherQLS;
		result.addAll(otherQLS);

		//Quote Line Details!!! Related to each other so it makes sens to work with them
		List<Quote_Line_Detail__c> theQLDs = new List<Quote_Line_Detail__c>();
		// Main Services first Bundle 4 numbers of first service and single one for second one
		theQLDs.add(new Quote_Line_Detail__c(Mobile_no__c = 'MobileNumber1Bundle1', Quote_Line__c = otherQLS[0].Id, Quantity__c = null));
		theQLDs.add(new Quote_Line_Detail__c(Mobile_no__c = 'MobileNumber2Bundle1', Quote_Line__c = otherQLS[0].Id, Quantity__c = 1));
		theQLDs.add(new Quote_Line_Detail__c(Mobile_no__c = 'MobileNumber3Bundle1', Quote_Line__c = otherQLS[0].Id, Quantity__c = 1));
		theQLDs.add(new Quote_Line_Detail__c(Mobile_no__c = 'MobileNumber4Bundle1', Quote_Line__c = otherQLS[0].Id, Quantity__c = null));
		theQLDs.add(new Quote_Line_Detail__c(Mobile_no__c = 'MobileNumber5Bundle1', Quote_Line__c = otherQLS[1].Id, Quantity__c = 1));
		// Addone Services first Bundle
		//  Of number: MobileNumber1Bundle1
		theQLDs.add(new Quote_Line_Detail__c(Mobile_no__c = 'MobileNumber1Bundle1', Quote_Line__c = otherQLS[2].Id, Quantity__c = 1));
		theQLDs.add(new Quote_Line_Detail__c(Mobile_no__c = 'MobileNumber1Bundle1', Quote_Line__c = otherQLS[3].Id, Quantity__c = 1));
		theQLDs.add(new Quote_Line_Detail__c(Mobile_no__c = 'MobileNumber1Bundle1', Quote_Line__c = otherQLS[4].Id, Quantity__c = 1));
		theQLDs.add(new Quote_Line_Detail__c(Mobile_no__c = 'MobileNumber1Bundle1', Quote_Line__c = otherQLS[5].Id, Quantity__c = null));
		theQLDs.add(new Quote_Line_Detail__c(Mobile_no__c = 'MobileNumber1Bundle1', Quote_Line__c = otherQLS[6].Id, Quantity__c = null));
		theQLDs.add(new Quote_Line_Detail__c(Mobile_no__c = 'MobileNumber1Bundle1', Quote_Line__c = otherQLS[7].Id, Quantity__c = 1));
		//  Of number: MobileNumber2Bundle1
		theQLDs.add(new Quote_Line_Detail__c(Mobile_no__c = 'MobileNumber2Bundle1', Quote_Line__c = otherQLS[3].Id, Quantity__c = 1));
		theQLDs.add(new Quote_Line_Detail__c(Mobile_no__c = 'MobileNumber2Bundle1', Quote_Line__c = otherQLS[5].Id, Quantity__c = 1));
		theQLDs.add(new Quote_Line_Detail__c(Mobile_no__c = 'MobileNumber2Bundle1', Quote_Line__c = otherQLS[6].Id, Quantity__c = 1));
		theQLDs.add(new Quote_Line_Detail__c(Mobile_no__c = 'MobileNumber2Bundle1', Quote_Line__c = otherQLS[7].Id, Quantity__c = null));
		//  Of number: MobileNumber3Bundle1
		//  Of number: MobileNumber4Bundle1
		//  Of number: MobileNumber5Bundle1
		theQLDs.add(new Quote_Line_Detail__c(Mobile_no__c = 'MobileNumber5Bundle1', Quote_Line__c = otherQLS[2].Id, Quantity__c = 1));
		theQLDs.add(new Quote_Line_Detail__c(Mobile_no__c = 'MobileNumber5Bundle1', Quote_Line__c = otherQLS[3].Id, Quantity__c = 1));
		theQLDs.add(new Quote_Line_Detail__c(Mobile_no__c = 'MobileNumber5Bundle1', Quote_Line__c = otherQLS[4].Id, Quantity__c = 1));
		theQLDs.add(new Quote_Line_Detail__c(Mobile_no__c = 'MobileNumber5Bundle1', Quote_Line__c = otherQLS[5].Id, Quantity__c = null));
		theQLDs.add(new Quote_Line_Detail__c(Mobile_no__c = 'MobileNumber5Bundle1', Quote_Line__c = otherQLS[6].Id, Quantity__c = null));
		theQLDs.add(new Quote_Line_Detail__c(Mobile_no__c = 'MobileNumber5Bundle1', Quote_Line__c = otherQLS[7].Id, Quantity__c = 1));
		// Main Services second Bundle
		System.debug('MT906' + otherQLS[8]);
		System.debug('MT906' + otherQLS[9]);
		theQLDs.add(new Quote_Line_Detail__c(Mobile_no__c = 'MobileNumber1Bundle2', Quote_Line__c = otherQLS[8].Id, Quantity__c = null));
		theQLDs.add(new Quote_Line_Detail__c(Mobile_no__c = 'MobileNumber2Bundle2', Quote_Line__c = otherQLS[8].Id, Quantity__c = 1));
		theQLDs.add(new Quote_Line_Detail__c(Mobile_no__c = 'MobileNumber3Bundle2', Quote_Line__c = otherQLS[9].Id, Quantity__c = null));
		theQLDs.add(new Quote_Line_Detail__c(Mobile_no__c = 'MobileNumber4Bundle2', Quote_Line__c = otherQLS[9].Id, Quantity__c = 1));
		// Addone Services second Bundle
		//  Of number: MobileNumber1Bundle2
		//  Of number: MobileNumber2Bundle2
		theQLDs.add(new Quote_Line_Detail__c(Mobile_no__c = 'MobileNumber2Bundle2', Quote_Line__c = otherQLS[10].Id, Quantity__c = 1));
		theQLDs.add(new Quote_Line_Detail__c(Mobile_no__c = 'MobileNumber2Bundle2', Quote_Line__c = otherQLS[11].Id, Quantity__c = 1));
		theQLDs.add(new Quote_Line_Detail__c(Mobile_no__c = 'MobileNumber2Bundle2', Quote_Line__c = otherQLS[12].Id, Quantity__c = 1));
		//  Of number: MobileNumber3Bundle2
		//  Of number: MobileNumber4Bundle2
		theQLDs.add(new Quote_Line_Detail__c(Mobile_no__c = 'MobileNumber4Bundle2', Quote_Line__c = otherQLS[13].Id, Quantity__c = 1));
		theQLDs.add(new Quote_Line_Detail__c(Mobile_no__c = 'MobileNumber4Bundle2', Quote_Line__c = otherQLS[14].Id, Quantity__c = 1));
		theQLDs.add(new Quote_Line_Detail__c(Mobile_no__c = 'MobileNumber4Bundle2', Quote_Line__c = otherQLS[15].Id, Quantity__c = 1));

		insert theQLDs;

		return result;
	}

	public static List<SBQQ__QuoteLine__c> createQuoteLinesForBundle(List<Product2> theBundlesMainProducts, List<SBQQ__Quote__c> theQuotes) {
		List<SBQQ__QuoteLine__c> result = new List<SBQQ__QuoteLine__c>();

		List<Id> allProductsIds = new List<Id>();
		List<Id> theBundlesMainProductsIds = new List<Id>();
		for (Product2 singleProduct : theBundlesMainProducts) {
			if (singleProduct.Name.contains('MainBundle'))
				theBundlesMainProductsIds.add(singleProduct.Id);
			allProductsIds.add(singleProduct.Id);
		}

		List<SBQQ__ProductOption__c> theOptions = [
			SELECT Id, SBQQ__OptionalSKU__c, SBQQ__OptionalSKU__r.Name, SBQQ__ConfiguredSKU__c, SBQQ__Feature__c, SBQQ__Feature__r.SBQQ__Category__c
			FROM SBQQ__ProductOption__c
			WHERE SBQQ__ConfiguredSKU__c IN :theBundlesMainProductsIds
		];

		for (SBQQ__ProductOption__c singleProductOption : theOptions) {
			allProductsIds.add(singleProductOption.SBQQ__OptionalSKU__c);
		}

		Map<Id, PricebookEntry> productIdToPricebookEntryMap = new Map<Id, PricebookEntry>();
		for (PricebookEntry singlePriceBookEntry : [SELECT Id, Product2Id, Pricebook2Id, UnitPrice FROM PricebookEntry WHERE Product2Id IN :allProductsIds]) {
			productIdToPricebookEntryMap.put(singlePriceBookEntry.Product2Id, singlePriceBookEntry);
		}

		// Create

		List<SBQQ__QuoteLine__c> mainProductsQLs = new List<SBQQ__QuoteLine__c>();
		for (SBQQ__Quote__c singleQuote : theQuotes) {
			for (Product2 singleMainProduct : theBundlesMainProducts) {
				mainProductsQLs.add(
					new SBQQ__QuoteLine__c( // We want to add the bundleit self as part of quote
						SBQQ__Bundle__c = true,
						SBQQ__PriceEditable__c = false,
						SBQQ__PricingMethod__c = 'List',
						SBQQ__Product__c = singleMainProduct.Id,
						SBQQ__Quantity__c = 1,
						SBQQ__Quote__c = singleQuote.Id,
						SBQQ__Hidden__c = false
					)
				);
			}
		}
		insert mainProductsQLs;
		result.addAll(mainProductsQLs);

		Map<Id, Map<Id, Id>> quoteIdMapToMapOfBundleIdToQLId = new Map<Id, Map<Id, Id>>();
		for (SBQQ__QuoteLine__c singleQL : mainProductsQLs) {
			if (quoteIdMapToMapOfBundleIdToQLId.containsKey(singleQL.SBQQ__Quote__c))
				quoteIdMapToMapOfBundleIdToQLId.get(singleQL.SBQQ__Quote__c).put(singleQL.SBQQ__Product__c, singleQL.Id);
			else {
				quoteIdMapToMapOfBundleIdToQLId.put(singleQL.SBQQ__Quote__c, new Map<Id, Id>());
				quoteIdMapToMapOfBundleIdToQLId.get(singleQL.SBQQ__Quote__c).put(singleQL.SBQQ__Product__c, singleQL.Id);
			}
		}

		List<SBQQ__QuoteLine__c> addonsQuoteLines = new List<SBQQ__QuoteLine__c>();
		//Id, SBQQ__OptionalSKU__c, SBQQ__OptionalSKU__r.Name, SBQQ__ConfiguredSKU__c, SBQQ__Feature__c, SBQQ__Feature__r.SBQQ__Category__c FROM SBQQ__ProductOption__c WHERE SBQQ__ConfiguredSKU__c IN :theBundlesMainProductsIds]
		for (SBQQ__Quote__c singleQuote : theQuotes) {
			for (SBQQ__ProductOption__c singleOption : theOptions) {
				addonsQuoteLines.add(
					new SBQQ__QuoteLine__c(
						SBQQ__Bundle__c = false,
						SBQQ__PriceEditable__c = false,
						SBQQ__PricingMethod__c = 'List',
						SBQQ__Product__c = singleOption.SBQQ__OptionalSKU__c,
						SBQQ__Quote__c = singleQuote.Id,
						SBQQ__RequiredBy__c = quoteIdMapToMapOfBundleIdToQLId.get(singleQuote.Id).get(singleOption.SBQQ__ConfiguredSKU__c),
						SBQQ__Hidden__c = false
					)
				);
			}
		}

		insert addonsQuoteLines;
		result.addAll(addonsQuoteLines);

		return result;
	}

	public static List<User> createTeliaEnterpriseSalesUsers(Integer numberOfRecords) {
		List<User> users = new List<User>();
		Id profileUserId = [SELECT Id FROM Profile WHERE Name = 'Telia Enterprise Sales'].Id;
		for (Integer i = 0; i < numberOfRecords; i++) {
			users.add(
				new User(
					ProfileId = profileUserId,
					Username = 'unittest@teliacompany.dk',
					Email = 'unittest@teliacompany.dk',
					EmailEncodingKey = 'UTF-8',
					LocaleSidKey = 'en_US',
					LanguageLocaleKey = 'en_US',
					Timezonesidkey = 'America/Los_Angeles',
					Alias = 'cspu',
					LastName = 'lastname'
				)
			);
		}

		return users;
	}

	public static List<User_History__c> createUserHistory(List<User> userRecords) {
		List<User_History__c> recordsToCreate = new List<User_History__c>();
		Integer cnt = 1;
		for (User theUser : userRecords) {
			recordsToCreate.add(
				new User_History__c(
					Changed_by__c = UserInfo.getUserId(),
					Date__c = Date.today(),
					Field__c = 'User Role',
					New_Value__c = 'New Value ' + cnt,
					Old_Value__c = 'Old Value ' + cnt,
					User__c = theUser.Id
				)
			);
			cnt++;
		}

		return recordsToCreate;
	}

	public static List<System_Log__c> createSystemLogs(Integer numberOfRecords) {
		List<System_Log__c> recordsToCreate = new List<System_Log__c>();
		for (Integer idx = 0; idx < numberOfRecords; idx++) {
			recordsToCreate.add(
				new System_Log__c(Additional_Information__c = 'Add. Info ' + idx, Error_Body__c = 'Error Body ' + idx, Origin__c = 'Apex', Type__c = 'Error')
			);
		}
		return recordsToCreate;
	}
}