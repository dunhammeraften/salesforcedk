public class SubscriptionService {
	@TestVisible
	private final DatabaseService dataBaseService;
	@TestVisible
	private final SubscriptionSelector subscriptionSelector;

	public SubscriptionService() {
		this(SingletonFactory.getFactory());
	}

	private SubscriptionService(SingletonFactory singletonFactory) {
		this.dataBaseService = (DatabaseService) singletonFactory.getOrRegisterSingleton(DatabaseService.class);
		
		this.subscriptionSelector = (SubscriptionSelector) singletonFactory.getOrRegisterSingleton(
			SubscriptionSelector.class
		);
	}

	@TestVisible
	private SubscriptionService(DatabaseService dbService, SubscriptionSelector subscriptionSelector) {
		this.dataBaseService = dbService;
		this.subscriptionSelector = subscriptionSelector;
	}

	public void updateSubscriptionQuantity(Set<Id> subscriptionIds) {
		List<SBQQ__Subscription__c> subscriptionsToUpdate = new List<SBQQ__Subscription__c>();

		for (SBQQ__Subscription__c singleS : subscriptionSelector.getSubscriptionById(subscriptionIds)) {
			Integer count = 0;

			for (Subscription_Line_Detail__c c : singleS.Subscription_Line_Details__r) {
				count += (c.Quantity__c == null ? 1 : Integer.valueof(c.Quantity__c));
			}

			subscriptionsToUpdate.add(
				new SBQQ__Subscription__c(Id = singleS.Id, SBQQ__Quantity__c = count, SBQQ__RenewalQuantity__c = count)
			);
		}

		databaseService.updateRecords(subscriptionsToUpdate);
	}
}