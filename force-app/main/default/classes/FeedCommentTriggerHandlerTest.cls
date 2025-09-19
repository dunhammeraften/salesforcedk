/**
 * @description Test class for the FeedCommentTriggerHandler.
 *
 * -----------------------------------------------------------------------------
 * @author Developer           Date            Description
 * -----------------------------------------------------------------------------
 * @author Esben Hovgaard        18/09/2025      Class and method documentation
 * -----------------------------------------------------------------------------
 */
@isTest
private class FeedCommentTriggerHandlerTest {
	/**
	 * @description Verifies that a DML exception with the correct error message is thrown
	 *              when a user tries to add a FeedComment to a NorlysNow_Case__c record.
	 */
	@isTest
	static void beforeInsert_onNorlysNowCase_shouldAddError() {
		// Arrange
		NorlysTestScenarios.ScenarioResult scenario = NorlysTestScenarios.newBuilder()
			.forNorlysNowCaseHandling()
			.withNorlysNowCases(1)
			.withFeedItems(1)
			.build();

		FeedItem post = scenario.feedItems[0];

		FeedComment comment = new FeedComment(
			FeedItemId = post.Id,
			CommentBody = 'This is a test comment'
		);

		// Act
		Test.startTest();
		try {
			insert comment;
			System.assert(false, 'A DML exception should have been thrown.');
		} catch (DmlException e) {
			// Assert
			System.assert(
				e.getMessage()
					.contains(
						'It is only possible to create posts and not comments on NorlysNow_Case__c records.'
					),
				'The error message is not the one expected.'
			);
		}
		Test.stopTest();
	}
}
