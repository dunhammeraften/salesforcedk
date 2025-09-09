trigger FeedCommentTrigger on FeedComment (before insert) {
    new FeedCommentTriggerHandler().run();
}