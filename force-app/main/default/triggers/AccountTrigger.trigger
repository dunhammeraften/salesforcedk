trigger AccountTrigger on Account(after insert, before update) {
    new AccountTriggerHandler().run();
}