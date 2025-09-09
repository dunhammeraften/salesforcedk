trigger FeedItemTrigger on FeedItem (after insert) {
    new FeedItemTriggerHandler().run();
}