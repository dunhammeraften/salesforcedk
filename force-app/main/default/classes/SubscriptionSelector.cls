public class SubscriptionSelector {
    public List<SBQQ__Subscription__c> getSubscriptionById(Set<Id> subscriptionIds){
        return [
			SELECT Id, (SELECT Id, Quantity__c FROM Subscription_Line_Details__r)
			FROM SBQQ__Subscription__c
			WHERE Id IN :subscriptionIds
		];
    }
}