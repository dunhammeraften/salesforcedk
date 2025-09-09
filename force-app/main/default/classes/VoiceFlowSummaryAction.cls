/**
 * 
 * @author Unknown
 * @since 25-02-2025
 */
public with sharing class VoiceFlowSummaryAction {
	/**
	 * 
	 * @param requests 
	 * @return  `List<Result>`
	 */
	@InvocableMethod(label='Voice Flow Summary' description='Voice Flow - Subscription Summary')
	public static List<Result> getVoiceFlowSummary(List<Request> requests) {
		Request request = requests.get(0);
		
		Result result = new Result();
		result.billingAccountSummary = getBillingAccountsBySubscriptions(request.activation.Id);
		result.productSummary = getProductStatusSummary(request.activationLines);
		result.vasSummary = getVASSummary(request.quoteLines);
		
		return new List<Result>{ result };
	}

	/**
	 * 
	 * @param activationId 
	 * @return  `List<BillingAccountsCountByNameDescriptor>`
	 */
	public static List<BillingAccountsCountByNameDescriptor> getBillingAccountsBySubscriptions(String activationId) {
		List<AggregateResult> billingAccountsBySubscriptionCount = ActivationLineSelector.getBillingAccountsBySubscriptionCount(activationId);
		List<BillingAccountsCountByNameDescriptor> baSummaries = new List<BillingAccountsCountByNameDescriptor>();
		for (AggregateResult ars : billingAccountsBySubscriptionCount) {
			BillingAccountsCountByNameDescriptor summary = new BillingAccountsCountByNameDescriptor();
			summary.billingAccountName = String.valueOf(ars.get('billingAccountName'));
			summary.numberOfSubscriptions = String.valueOf(ars.get('subscriptionCount'));
			baSummaries.add(summary);
		}

		return baSummaries;
	}

	/**
	 * 
	 * @param activationLines 
	 * @return  `List<ProductStatusSummaryDescriptor>`
	 */
	public static List<ProductStatusSummaryDescriptor> getProductStatusSummary(List<Activation_line__c> activationLines) {
		List<ProductStatusSummaryDescriptor> summaryList = new List<ProductStatusSummaryDescriptor>();

		Map<String, Map<String, Integer>> summaryMap = new Map<String, Map<String, Integer>>();

		Map<Id, Activation_line__c> mapOfActivationLines = ActivationLineSelector.getMapOfVoiceProductStatusLines(activationLines);

		for (Activation_line__c line : mapOfActivationLines.values()) {			
			String product = line.Product__c;
			String status = line.Phone_no_Status__c;	

			String key = product + '-' + status;
		
			if(summaryMap.containsKey(key)){
				if(summaryMap.get(key).containsKey(product)) {
					Integer currentCount = summaryMap.get(key).get(product);
					summaryMap.get(key).put(product, currentCount + 1);
				}
			}
			else{
				Map<String, Integer> innerMap = new Map<String, Integer>();
				innerMap.put(product, 1);

				summaryMap.put(key, innerMap);
			}
		}

		for (String key : summaryMap.keySet()) {
			String[] parts = key.split('-');
			String product = parts[0];
			String status = parts[1];
			
			ProductStatusSummaryDescriptor summary = new ProductStatusSummaryDescriptor();
			summary.product = product;
			summary.phoneNoStatus = status;
			summary.count = summaryMap.get(key).get(product);
			
			summaryList.add(summary);
		}

		return summaryList;
	}

	/**
	 * 
	 * @param quoteLines 
	 * @return  `List<ValueAddedServicesSummaryDescriptor>`
	 */
	public static List<ValueAddedServicesSummaryDescriptor> getVASSummary(List<SBQQ__QuoteLine__c> quoteLines) {
		List<ValueAddedServicesSummaryDescriptor> summaryList = new List<ValueAddedServicesSummaryDescriptor>();

		List<SBQQ__QuoteLine__c> listOfQuoteLinesWithOnboardingConfiguration = QuoteLineSelector.getVasWithOnboardingConfiguration(quoteLines);

		List<ValueAddedServicesSummaryDescriptor> vasSummaryList = new List<ValueAddedServicesSummaryDescriptor>();

		for (SBQQ__QuoteLine__c line :listOfQuoteLinesWithOnboardingConfiguration) {			
			ValueAddedServicesSummaryDescriptor vasDescriptor = new ValueAddedServicesSummaryDescriptor();
			vasDescriptor.product = line.SBQQ__ProductName__c;
			vasDescriptor.availableQuantity = line.SBQQ__Quantity__c;
			vasDescriptor.consumedQuantity = line.Consumed_Quantity__c;
			
			summaryList.add(vasDescriptor);
		}

		return summaryList;
	}

	public class Request {
		@InvocableVariable
		public Activation__c activation;

		@InvocableVariable
		public List<Activation_line__c> activationLines;

		@InvocableVariable
		public List<SBQQ__QuoteLine__c> quoteLines;
	}


	/**
	 * 
	 */
	public class Result {
		@InvocableVariable
		public List<BillingAccountsCountByNameDescriptor> billingAccountSummary;
		
		@InvocableVariable
		public List<ProductStatusSummaryDescriptor> productSummary;

		@InvocableVariable
		public List<ValueAddedServicesSummaryDescriptor> vasSummary;
	}
}