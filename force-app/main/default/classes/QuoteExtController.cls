public with sharing class QuoteExtController {
    private static final String PREPEND_ERROR_MESSAGE = 'Submit for Approval failed. The failure was caused by: ';
    private Id quoteId;

    public QuoteExtController(ApexPages.StandardController stdController) {
        quoteId = stdController.getId();
    }

    public PageReference onSubmit() {       
        if (quoteId != null) {
            try {
                SBAA.ApprovalAPI.submit(quoteId, SBAA__Approval__c.Quote__c);
            } catch (DMLException e) {
                // add error message to page
                String message = PREPEND_ERROR_MESSAGE + e.getDmlMessage(0);
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, message));
                return null;
            }
        }
        return new PageReference('/' + quoteId);
    }

    public PageReference onRecall() {
        if (quoteId != null) {
            SBAA.ApprovalAPI.recall(quoteId, SBAA__Approval__c.Quote__c);
        }
        return new PageReference('/' + quoteId);
    }
}