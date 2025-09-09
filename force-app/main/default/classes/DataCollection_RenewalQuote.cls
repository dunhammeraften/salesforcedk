public with sharing class DataCollection_RenewalQuote {
	//Select the Fokus subscription info
	public Account acc { get; set; }
	public static String recordId { get; set; }

	private static final String ERROR_ORIGIN = 'Apex';
	private static final String ERROR_ADDITIONAL_INFO = 'DataCollection_RenewalQuote';

	private static ErrorLogging errorLogging = new ErrorLogging(ERROR_ORIGIN);

	public DataCollection_RenewalQuote(ApexPages.StandardController controller) {
		Account acc = (Account) controller.getRecord();
		recordId = acc.Id;
		system.debug('record id ' + recordId);
	}
	@AuraEnabled
	public static string RenewalQuote(Id acctId) {
		try {
			string nonStandardPriceBookId;
			string opportunityRecordTypeId;
			string returnNull = '';

			//     acctId = '0011i0000076sXTAAY';
			system.debug('renew quote ' + acctId);
			List<AggregateResult> Fokus_Products_list = [
				SELECT ORDER_PRODUCT__c, count(BAN__c) recordCount
				FROM Fokus_Subscription__c
				WHERE SF_ACCOUNT_KEY__c = :acctId AND ORDER_PRODUCT__c != NULL
				GROUP BY ORDER_PRODUCT__c
			];
			errorLogging.addError('Fokus Products List : ' + Fokus_Products_list, ERROR_ADDITIONAL_INFO);
			system.debug('focuks ' + Fokus_Products_list);
			system.debug(Fokus_Products_list.size());
			List<AggregateResult> Fokus_ProductDiscounts_list = [
				SELECT avg(DISCOUNT__c) avgDiscount, ORDER_PRODUCT__c
				FROM Fokus_Subscription__c
				WHERE SF_ACCOUNT_KEY__c = :acctId AND ORDER_PRODUCT__c != NULL
				GROUP BY ORDER_PRODUCT__c
			];
			errorLogging.addError('Fokus_ProductDiscounts_list : ' + Fokus_ProductDiscounts_list, ERROR_ADDITIONAL_INFO);
			if (Fokus_Products_list.size() <= 0) {
				errorLogging.addError('Fokus_ProductDiscounts_list is empty', ERROR_ADDITIONAL_INFO);
				//Create a notification
				CustomNotificationType notificationType = [
					SELECT Id, DeveloperName
					FROM CustomNotificationType
					WHERE DeveloperName = 'Case_notifications'
				];

				Messaging.CustomNotification notification = new Messaging.CustomNotification();
				notification.setTitle('Renewal Quote error');
				notification.setBody('The renewal quote can not be prepared due to missing Fokus subscription information');

				notification.setNotificationTypeId(notificationType.Id);
				notification.setTargetId(acctId);
				set<String> recipientsIds = new Set<String>{ UserInfo.getUserId() };
				notification.send(recipientsIds);
				return returnNull;
			}

			Set<String> Fokus_ProductCode_list = new Set<String>();
			Set<String> Fokus_AddedProductCode_list = new Set<String>(); //will be used to compare the ones used
			map<string, decimal> Fokus_ProductDetails = new Map<string, decimal>();

			for (AggregateResult FokusSubscriptionDetails : Fokus_Products_list) {
				Fokus_ProductCode_list.add(String.valueOf(FokusSubscriptionDetails.get('ORDER_PRODUCT__c')));
				Fokus_ProductDetails.put(
					String.valueOf(FokusSubscriptionDetails.get('ORDER_PRODUCT__c')),
					(Decimal) FokusSubscriptionDetails.get('recordCount')
				);
			}

			map<string, decimal> Fokus_ProductDiscountDetails = new Map<string, decimal>();

			for (AggregateResult FokusDiscountDetails : Fokus_ProductDiscounts_list) {
				Fokus_ProductDiscountDetails.put(
					String.valueOf(FokusDiscountDetails.get('ORDER_PRODUCT__c')),
					(Decimal) FokusDiscountDetails.get('avgDiscount')
				);
			}

			//PriceBook to use
			List<Pricebook2> PriceBookList = [SELECT Id, name, IsStandard FROM Pricebook2 WHERE IsActive = TRUE AND IsStandard = FALSE];

			system.debug('test pricebook ' + PriceBookList.size());

			if (PriceBookList.size() > 0) {
				nonStandardPriceBookId = PriceBookList[0].Id;
			}

			List<SBQQ__ProductOption__c> ProductOptionList = [
				SELECT Id, SBQQ__OptionalSKU__c, SBQQ__ConfiguredSKU__c
				FROM SBQQ__ProductOption__c
				WHERE SBQQ__OptionalSKU__r.ProductAPI_Telia_Product_Id__c IN :Fokus_ProductCode_list
			];
			system.debug('product option List ' + ProductOptionList);

			errorLogging.addError('ProductOptionList : ' + ProductOptionList, ERROR_ADDITIONAL_INFO);

			Set<String> ProductBundleIds = new Set<String>();
			Map<String, String> ProductOptions = new Map<String, String>();
			//ProductId,BundleId
			for (SBQQ__ProductOption__c productOptionrec : ProductOptionList) {
				ProductOptions.put(productOptionrec.SBQQ__OptionalSKU__c, productOptionrec.SBQQ__ConfiguredSKU__c);
				ProductBundleIds.add(productOptionrec.SBQQ__ConfiguredSKU__c);
			}

			Map<String, String> ProductOptionIds = new Map<String, String>();
			//ProductId,ProductOptionIdId
			for (SBQQ__ProductOption__c productOptionrec : ProductOptionList) {
				ProductOptionIds.put(productOptionrec.SBQQ__OptionalSKU__c, productOptionrec.Id);
			}
			system.debug('All id 1 ' + nonStandardPriceBookId);
			system.debug('All id 2 ' + Fokus_ProductCode_list);
			system.debug('All id 3 ' + ProductBundleIds);
			List<PricebookEntry> CPQDetails = [
				SELECT Id, UnitPrice, Product2.ProductAPI_Telia_Product_Id__c, Product2.Id
				FROM PricebookEntry
				WHERE
					IsActive = TRUE
					AND Pricebook2Id = :nonStandardPriceBookId
					AND (Product2.ProductAPI_Telia_Product_Id__c IN :Fokus_ProductCode_list
					OR Product2.Id IN :ProductBundleIds)
				ORDER BY Product2.ProductAPI_Telia_Product_Id__c ASC NULLS FIRST
			];

			errorLogging.addError('CPQDetails : ' + CPQDetails, ERROR_ADDITIONAL_INFO);

			List<SBQQ__ProductFeature__c> ProductFeatureList = [
				SELECT Id, SBQQ__ConfiguredSKU__c
				FROM SBQQ__ProductFeature__c
				WHERE SBQQ__ConfiguredSKU__c IN :ProductBundleIds
			];
			Map<String, String> ProductFeatureIds = new Map<String, String>();
			//ProductBundleId,ProductFeatureIdId
			for (SBQQ__ProductFeature__c productFeaturerec : ProductFeatureList) {
				ProductFeatureIds.put(productFeaturerec.SBQQ__ConfiguredSKU__c, productFeaturerec.Id);
			}

			//Record Types
			string QuoteRecordType;
			string OrderRecordType;
			string OpportunityRecordType;
			//List<RecordType> QuoteRecordType = [SELECT Id FROM RecordType where developerName = 'Approved_Quote'];
			List<RecordType> RecordTypes = [SELECT id, name, SobjectType, DeveloperName FROM RecordType WHERE DeveloperName = 'Read_only_for_Renewal'];
			for (RecordType recordTypeVal : RecordTypes) {
				if (recordTypeVal.SobjectType == 'SBQQ__Quote__c') {
					QuoteRecordType = recordTypeVal.Id;
				}
				if (recordTypeVal.SobjectType == 'Order') {
					OrderRecordType = recordTypeVal.Id;
				}
				if (recordTypeVal.SobjectType == 'Opportunity') {
					OpportunityRecordType = recordTypeVal.Id;
				}
			}

			List<Opportunity> LatestOpportunity = [
				SELECT Id, Billing_Frequency__c
				FROM Opportunity
				WHERE AccountId = :acctId
				ORDER BY CreatedDate DESC
			];

			Opportunity opp;

			if (
				LatestOpportunity.size() >
				0 //There is an opportunity to reuse or not
			) {
				opp = new Opportunity(
					AccountId = acctId,
					Name = 'Renewal',
					SBQQ__Renewal__c = true,
					type = 'Renewal ',
					Billing_Frequency__c = LatestOpportunity[0].Billing_Frequency__c,
					StageName = 'Qualification',
					CloseDate = Date.Today(),
					RecordTypeId = OpportunityRecordType,
					Pricebook2Id = nonStandardPriceBookId,
					Payment_Terms__c = '30'
				);
			} else {
				opp = new Opportunity(
					AccountId = acctId,
					Name = 'Renewal',
					SBQQ__Renewal__c = true,
					type = 'Renewal ',
					StageName = 'Qualification',
					CloseDate = Date.Today(),
					RecordTypeId = OpportunityRecordType,
					Pricebook2Id = nonStandardPriceBookId
				);
			}
			system.debug('prciebook ' + opp.Pricebook2Id);
			insert opp;

			SBQQ__Quote__c quo = new SBQQ__Quote__c(
				SBQQ__BillingFrequency__c = opp.Billing_Frequency__c,
				SBQQ__PaymentTerms__c = opp.Payment_Terms__c,
				SBQQ__SubscriptionTerm__c = 36,
				SBQQ__Account__c = opp.AccountId,
				SBQQ__Opportunity2__c = opp.Id,
				RecordTypeId = QuoteRecordType
			);
			insert quo;
			system.debug('renew quote ' + quo.id);
			SBQQ__QuoteLine__c tmpQuoteLineItem = new SBQQ__QuoteLine__c();
			SBQQ__QuoteLine__c tmpBundleQuoteLineItem = new SBQQ__QuoteLine__c();
			List<SBQQ__QuoteLine__c> quoteLineItemsToAdd = new List<SBQQ__QuoteLine__c>();
			string productBundle;
			productBundle = '';

			Map<String, String> ProductBundleQuoteLineIds = new Map<String, String>();
			//ProductBundleId,QuoteLineItem

			for (PricebookEntry quoteLineItem_temp : CPQDetails) {
				Fokus_AddedProductCode_list.add(quoteLineItem_temp.Product2.ProductAPI_Telia_Product_Id__c);
				tmpQuoteLineItem = new SBQQ__QuoteLine__c();
				tmpQuoteLineItem.SBQQ__Quote__c = quo.Id;
				tmpQuoteLineItem.SBQQ__PricebookEntryId__c = quoteLineItem_temp.Id;
				tmpQuoteLineItem.SBQQ__ListPrice__c = quoteLineItem_temp.UnitPrice;
				tmpQuoteLineItem.SBQQ__Product__c = quoteLineItem_temp.Product2.Id;
				tmpQuoteLineItem.SBQQ__SubscriptionType__c = 'Renewable';
				tmpQuoteLineItem.SBQQ__ProductSubscriptionType__c = 'Renewable';
				tmpQuoteLineItem.SBQQ__SubscriptionPricing__c = 'Fixed Price';
				tmpQuoteLineItem.SBQQ__Discount__c = Integer.valueOf(
					Fokus_ProductDiscountDetails.get(quoteLineItem_temp.Product2.ProductAPI_Telia_Product_Id__c)
				);
				tmpQuoteLineItem.SBQQ__Quantity__c = Fokus_ProductDetails.get(quoteLineItem_temp.Product2.ProductAPI_Telia_Product_Id__c);
				errorLogging.addError(
					'SBQQ__Quantity__c : ' + Fokus_ProductDetails.get(quoteLineItem_temp.Product2.ProductAPI_Telia_Product_Id__c),
					ERROR_ADDITIONAL_INFO
				);
				tmpQuoteLineItem.Initiate_validation_count_on_activation__c = true;
				tmpQuoteLineItem.SBQQ__ProductOption__c = (ID) ProductOptionIds.get(tmpQuoteLineItem.SBQQ__Product__c);
				if (!String.isEmpty(tmpQuoteLineItem.SBQQ__ProductOption__c)) {
					tmpQuoteLineItem.SBQQ__OptionType__c = 'Related Product';
					tmpQuoteLineItem.SBQQ__OptionLevel__c = 1;
				}
				if (String.isEmpty(String.valueOf(Fokus_ProductDetails.get(quoteLineItem_temp.Product2.ProductAPI_Telia_Product_Id__c)))) {
					tmpQuoteLineItem.SBQQ__Quantity__c = 1;
					insert tmpQuoteLineItem;
					ProductBundleQuoteLineIds.put(tmpQuoteLineItem.SBQQ__Product__c, tmpQuoteLineItem.Id);
					system.debug(ProductBundleQuoteLineIds);
				} else {
					productBundle = ProductOptions.get(tmpQuoteLineItem.SBQQ__Product__c);
					if (!String.isEmpty(productBundle)) {
						tmpQuoteLineItem.SBQQ__DynamicOptionId__c = (ID) ProductFeatureIds.get(productBundle);
						tmpQuoteLineItem.SBQQ__RequiredBy__c = ProductBundleQuoteLineIds.get(productBundle);
					}
					quoteLineItemsToAdd.add(tmpQuoteLineItem);
				}
				errorLogging.addError('tmpQuoteLineItem : ' + tmpQuoteLineItem, ERROR_ADDITIONAL_INFO);
			}
			system.debug('quoteLineItemsToAdd');
			insert quoteLineItemsToAdd;
			errorLogging.addError('quoteLineItemsToAdd : ' + quoteLineItemsToAdd, ERROR_ADDITIONAL_INFO);

			//check the products fetched from Datamall to find out the missing ones in Salesforce
			//Fokus_AddedProductCode_list and Fokus_ProductCode_list
			for (String matchedProduct : Fokus_AddedProductCode_list) {
				if (Fokus_ProductCode_list.contains(matchedProduct))
					Fokus_ProductCode_list.remove(matchedProduct);
			}

			if (Fokus_ProductCode_list.size() > 0) {
				quo.SBQQ__Notes__c = 'The following Fokus SOC codes are left out:' + Fokus_ProductCode_list.toString();
			}

			quo.SBQQ__Primary__c = true;
			quo.SBQQ__StartDate__c = Date.today();
			quo.SBQQ__Status__c = 'Signed';
			quo.SBQQ__Unopened__c = false;
			//quo.ApprovalStatus__c = 'Approved';
			update quo;

			errorLogging.addError('quo : ' + quo, ERROR_ADDITIONAL_INFO);
			//Update the contract
			/*
    List<Contract> OpportunityContract = [SELECT Id FROM Contract where SBQQ__Opportunity__c  =: opp.Id];
 	Contract updateContract = new Contract();
    updateContract = OpportunityContract[0];
    updateContract.SBQQ__Quote__c = quo.Id;
    updateContract.Cancellation_Date__c = Date.today();
    updateContract.Status = 'Cancelled' ;
    update updateContract;
    */
			//opp.Win_Reason__c = 'Our relation to the customer';
			//opp.StageName = 'Closed Won';
			//opp.SBQQ__Contracted__c  = true;
			opp.SBQQ__PrimaryQuote__c = quo.Id;
			//opp.SBQQ__Ordered__c = true;
			update opp;
			system.debug('account id ' + opp.AccountId);
			system.debug('Quote id ' + quo.id + ',' + OrderRecordType);
			Order ord = new Order(
				SBQQ__Quote__c = quo.id,
				AccountId = opp.AccountId,
				EffectiveDate = Date.Today(),
				Status = 'Draft',
				RecordTypeId = OrderRecordType
			);
			insert ord;

			DataCollection_RenewalBatch ProcessBatch = new DataCollection_RenewalBatch();
			ProcessBatch.query = 'select Id,SBQQ__Account__c from SBQQ__Quote__c where id =\'' + quo.Id + '\' ';
			//ID batchprocessid = Database.executeBatch(ProcessBatch);
			String cronID = System.scheduleBatch(ProcessBatch, 'Update Activation lines-' + quo.Id, 15);
			errorLogging.addError('cronId : ' + cronID, ERROR_ADDITIONAL_INFO);
			//return quo;
			return cronID;
		} catch (Exception e) {
			System.debug('Error occured : ' + e.getMessage());
			errorLogging.addError('Error occured : ' + e.getMessage(), ERROR_ADDITIONAL_INFO);
		}
		errorLogging.logErrors();
		return null;
	}
}