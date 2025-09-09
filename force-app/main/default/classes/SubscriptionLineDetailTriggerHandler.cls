public class SubscriptionLineDetailTriggerHandler extends TriggerHandler {
	private final SubscriptionService subscriptionService;

	private List<Subscription_Line_Detail__c> newSubscriptionLineDetails;
	private List<Subscription_Line_Detail__c> oldSubscriptionLineDetails;

	public SubscriptionLineDetailTriggerHandler() {
		this(SingletonFactory.getFactory());
	}

	private SubscriptionLineDetailTriggerHandler(SingletonFactory singletonFactory) {
		this.subscriptionService = (SubscriptionService) singletonFactory.getOrRegisterSingleton(
			SubscriptionService.class
		);

		this.newSubscriptionLineDetails = (List<Subscription_Line_Detail__c>) Trigger.new;
		this.oldSubscriptionLineDetails = (List<Subscription_Line_Detail__c>) Trigger.old;
	}

	@TestVisible
	private SubscriptionLineDetailTriggerHandler(SubscriptionService subscriptionService) {
		this.subscriptionService = subscriptionService;
	}

	protected override void afterInsert() {
		Set<Id> subscriptionIds = new Set<Id>(
			SObjectCollectionUtil.of(newSubscriptionLineDetails).pluckIds(Subscription_Line_Detail__c.Subscription__c)
		);

		subscriptionService.updateSubscriptionQuantity(subscriptionIds);
	}

	protected override void afterUpdate() {
		Set<Id> subscriptionIds = new Set<Id>(
			SObjectCollectionUtil.of(newSubscriptionLineDetails).pluckIds(Subscription_Line_Detail__c.Subscription__c)
		);

		subscriptionService.updateSubscriptionQuantity(subscriptionIds);
	}

	protected override void afterDelete() {
		Set<Id> subscriptionIds = new Set<Id>(
			SObjectCollectionUtil.of(oldSubscriptionLineDetails).pluckIds(Subscription_Line_Detail__c.Subscription__c)
		);

		subscriptionService.updateSubscriptionQuantity(subscriptionIds);
	}
}