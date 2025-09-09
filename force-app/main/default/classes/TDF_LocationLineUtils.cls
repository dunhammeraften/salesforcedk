@IsTest
public with sharing class TDF_LocationLineUtils {

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
	
	/**
	 * Create a Location Line for an Opportunity with a subscriptionProduct and give quote line
	 * @param opp - Opportunity
	 * @param subscriptionProduct - Subscription Product
	 * @param quoteLine - Quote Line
	 * @return Location Line
	 */
	public static Location_Line__c createLocationLineForOpportunity(Opportunity opp, String subscriptionProduct, SBQQ__QuoteLine__c quoteLine) {
		return new Location_Line__c(
			Opportunity__c = opp.Id,
			Quote_Line__c = quoteLine?.Id,
			ZIP_Code__c = '2650',
			City__c = 'Hvidovre',
			Number__c = '8',
			Street_Name__c = 'Daglykkevej',
			Employee_ID__c = '20',
			Subscription_product__c = subscriptionProduct,
			Address_Wash_Status__c = 'Valid',
			SiteId__c = 'SiteId',
			AddressRefId__c = 'AddressRefId',
			lineConnectionStatus__c = 'lineConnectionStatus'
		);
	}

}