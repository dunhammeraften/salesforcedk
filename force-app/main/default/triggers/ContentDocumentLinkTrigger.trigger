trigger ContentDocumentLinkTrigger on ContentDocumentLink (after insert) {
    new ContentDocumentLinkTriggerHandler().run();
}