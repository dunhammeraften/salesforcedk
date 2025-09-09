trigger SubscriptionLineDetailTrigger on Subscription_Line_Detail__c(
	after insert,
	after delete,
	after undelete,
	after update
) {
	new SubscriptionLineDetailTriggerHandler().run();
}