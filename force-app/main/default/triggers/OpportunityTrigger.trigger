trigger OpportunityTrigger on Opportunity (before insert, after update) {
    new OpportunityTriggerHandler().run();
}