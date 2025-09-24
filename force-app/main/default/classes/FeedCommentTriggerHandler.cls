/**
 * @description Trigger handler for the FeedComment object.
 *
 * -----------------------------------------------------------------------------
 * @author Developer           Date            Description
 * -----------------------------------------------------------------------------
 * @author Esben Hovgaard        18/09/2025      Class, method and inline documentation
 * -----------------------------------------------------------------------------
 */
public with sharing class FeedCommentTriggerHandler extends TriggerHandler {
	/**
	 * @description Before insert, checks if the comment is being added to a NorlysNow_Case__c record.
	 *              If so, it prevents the comment from being created and adds an error message.
	 *              This is because only posts (FeedItem) are allowed on NorlysNow_Case__c records, not comments.
	 */
	public override void beforeInsert() {
		for (FeedComment fc : (List<FeedComment>) Trigger.new) {
			// Check if the parent of the comment is a NorlysNow_Case__c
			if (fc.ParentId != null && fc.ParentId.getSObjectType() == NorlysNow_Case__c.SObjectType) {
				fc.addError('It is only possible to create posts and not comments.');
			}
		}
	}
}
