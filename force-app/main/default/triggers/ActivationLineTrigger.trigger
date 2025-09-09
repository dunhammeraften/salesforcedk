trigger ActivationLineTrigger on Activation_line__c (after update) {
    new ActivationLineTriggerHandler().run();
}