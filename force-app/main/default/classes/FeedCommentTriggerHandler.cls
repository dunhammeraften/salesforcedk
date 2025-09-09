public with sharing class FeedCommentTriggerHandler extends TriggerHandler {

    public override void beforeInsert() {
        for (FeedComment fc : (List<FeedComment>) Trigger.new) {
            if (fc.ParentId != null && fc.ParentId.getSObjectType() == NorlysNow_Case__c.SObjectType) {
                fc.addError('It is only possible to create posts and not comments on NorlysNow_Case__c records.');
            }
        }
    }
}
