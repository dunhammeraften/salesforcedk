public class ActivationLineTriggerHandler extends TriggerHandler{
    /**
     * Singleton instance of the ActivationLineService
     */
    private final ActivationLineService activationLineService;

    /**
     * Collection of newly Activation_line__c records from the trigger context
     */
    @TestVisible
    private List<Activation_line__c> triggerNew;
    @TestVisible
    private List<Activation_line__c> triggerOld;

    @TestVisible
    private ActivationLineTriggerHandler(ActivationLineService activationLineService) {
        this.activationLineService = activationLineService;
    }

    public ActivationLineTriggerHandler() {
        this(SingletonFactory.getFactory());
    }

    private ActivationLineTriggerHandler(SingletonFactory singletonFactory) {
        this.activationLineService = (ActivationLineService) singletonFactory.getOrRegisterSingleton(ActivationLineService.class);
        this.triggerNew = (List<Activation_line__c>) Trigger.new;
        this.triggerOld = (List<Activation_line__c>) Trigger.old;
    }

    public override void afterUpdate() {
        List<Activation_line__c> toInsert = activationLineService.hasCompletedVoiceFlow(triggerNew, triggerOld);
        if (!toInsert.isEmpty()) {
            activationLineService.createActivationLine(toInsert);
        }
    }

    public override void beforeDelete() {
        Map<Id, String> mapOfActivationLineToPhoneNumberForActivationLineDeletes = activationLineService.getMapOfActivationLineToPhoneNumberForActivationLineDeletes(triggerOld);

        NumberClientService numberClientService = new NumberClientService();
        numberClientService.resetPhoneNumberAssignments(25, mapOfActivationLineToPhoneNumberForActivationLineDeletes);
    }  
}