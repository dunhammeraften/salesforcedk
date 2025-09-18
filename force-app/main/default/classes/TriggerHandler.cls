public virtual class TriggerHandler {
    // static map of handlername, times run() was invoked
    private static Map<String, LoopCount> loopCountMap;
    private static Set<String> bypassedHandlers;
    private static Map<String, TriggerHandler_Setting__mdt> triggerSettings;

    private static Stack triggerHandlerStack = new Stack();

    // the current context of the trigger, overridable in tests
    @TestVisible
    private TriggerContext context;

    @TestVisible
    private TriggerHandler_Setting__mdt triggerSetting = null;

    // the current context of the trigger, overridable in tests
    @TestVisible
    private Boolean isTriggerExecuting;

    // static initialization
    static {
        loopCountMap = new Map<String, LoopCount>();
        bypassedHandlers = new Set<String>();
        triggerSettings = TriggerHandler_Setting__mdt.getAll();
    }

    // constructor
    public TriggerHandler() {
        this.triggerSetting = triggerSettings.get(getHandlerName());

        this.setTriggerContext();
    }

    /***************************************
     * public instance methods
     ***************************************/

    // main method that will be called during execution
    public void run() {       
        //We don't want a triggerhandler loop
        if(getHandlerName() != 'DebugEventTriggerHandler' && getHandlerName() != 'TestHandler'){
            triggerHandlerStack.push(this);
        }

        try {
            if (!validateRun()) {
                return;
            }

            addToLoopCount();
            Logger.logInfo(getHandlerName() + '.' +this.context);

            // dispatch to the correct handler method
            switch on this.context {
                when BEFORE_INSERT {
                    this.beforeInsert();
                }
                when BEFORE_UPDATE {
                    this.beforeUpdate();
                }
                when BEFORE_DELETE {
                    this.beforeDelete();
                }
                when AFTER_INSERT {
                    this.afterInsert();
                }
                when AFTER_UPDATE {
                    this.afterUpdate();
                }
                when AFTER_DELETE {
                    this.afterDelete();
                }
                when AFTER_UNDELETE {
                    this.afterUndelete();
                }
                when else {
                    //Should only reach this if we have disabled a contex with the metadata TriggerHandler_Setting_mdt
                    Logger.logInfo(
                        String.format(
                            'TriggerHandler_Setting_mdt {0} has disabled the context: {1}',
                            new List<String>{ getHandlerName(), this.context.toString().removeStart('DISABLED_') }
                        )
                    );
                }
            }
        } catch (Exception ex) {
            Logger.logError(ex);
            
            throw ex;
        }finally{
            //We are done with the execution just pop it
            if(getHandlerName() != 'DebugEventTriggerHandler' && getHandlerName() != 'TestHandler'){
                triggerHandlerStack.pop();
    
                if(triggerHandlerStack.isEmpty()){
                    Logger.emit();
                }
            }
        }
    }

    public void setMaxLoopCount(Integer max) {
        String handlerName = getHandlerName();
        if (!TriggerHandler.loopCountMap.containsKey(handlerName)) {
            TriggerHandler.loopCountMap.put(handlerName, new LoopCount(max));
        } else {
            TriggerHandler.loopCountMap.get(handlerName).setMax(max);
        }
    }

    public void clearMaxLoopCount() {
        this.setMaxLoopCount(-1);
    }

    /***************************************
     * public static methods
     ***************************************/

    public static void bypass(String handlerName) {
        TriggerHandler.bypassedHandlers.add(handlerName);
    }

    public static void clearBypass(String handlerName) {
        TriggerHandler.bypassedHandlers.remove(handlerName);
    }

    public static Boolean isBypassed(String handlerName) {
        return TriggerHandler.bypassedHandlers.contains(handlerName);
    }

    public static void clearAllBypasses() {
        TriggerHandler.bypassedHandlers.clear();
    }

    /***************************************
     * private instancemethods
     ***************************************/

    @TestVisible
    private void setTriggerContext() {
        this.setTriggerContext(null, false);
    }

    @TestVisible
    private void setTriggerContext(String ctx, Boolean testMode) {
        if (!Trigger.isExecuting && !testMode) {
            this.isTriggerExecuting = false;
            return;
        } else {
            this.isTriggerExecuting = true;
        }

        if ((Trigger.isExecuting && Trigger.isBefore && Trigger.isInsert) || (ctx != null && ctx == 'before insert')) {
            if (triggerSetting != null && triggerSetting.isBeforeInsertDisabled__c) {
                this.context = TriggerContext.DISABLED_BEFORE_INSERT;
            } else {
                this.context = TriggerContext.BEFORE_INSERT;
            }
        } else if (
            (Trigger.isExecuting && Trigger.isBefore && Trigger.isUpdate) || (ctx != null && ctx == 'before update')
        ) {
            if (triggerSetting != null && triggerSetting.isBeforeUpdateDisabled__c) {
                this.context = TriggerContext.DISABLED_BEFORE_UPDATE;
            } else {
                this.context = TriggerContext.BEFORE_UPDATE;
            }
        } else if (
            (Trigger.isExecuting && Trigger.isBefore && Trigger.isDelete) || (ctx != null && ctx == 'before delete')
        ) {
            if (triggerSetting != null && triggerSetting.isBeforeDeleteDisabled__c) {
                this.context = TriggerContext.DISABLED_BEFORE_DELETE;
            } else {
                this.context = TriggerContext.BEFORE_DELETE;
            }
        } else if (
            (Trigger.isExecuting && Trigger.isAfter && Trigger.isInsert) || (ctx != null && ctx == 'after insert')
        ) {
            if (triggerSetting != null && triggerSetting.isAfterInsertDisabled__c) {
                this.context = TriggerContext.DISABLED_AFTER_INSERT;
            } else {
                this.context = TriggerContext.AFTER_INSERT;
            }
        } else if (
            (Trigger.isExecuting && Trigger.isAfter && Trigger.isUpdate) || (ctx != null && ctx == 'after update')
        ) {
            if (triggerSetting != null && triggerSetting.isAfterUpdateDisabled__c) {
                this.context = TriggerContext.DISABLED_AFTER_UPDATE;
            } else {
                this.context = TriggerContext.AFTER_UPDATE;
            }
        } else if (
            (Trigger.isExecuting && Trigger.isAfter && Trigger.isDelete) || (ctx != null && ctx == 'after delete')
        ) {
            if (triggerSetting != null && triggerSetting.isAfterDeleteDisabled__c) {
                this.context = TriggerContext.DISABLED_AFTER_DELETE;
            } else {
                this.context = TriggerContext.AFTER_DELETE;
            }
        } else if (
            (Trigger.isExecuting && Trigger.isAfter && Trigger.isUndelete) || (ctx != null && ctx == 'after undelete')
        ) {
            if (triggerSetting != null && triggerSetting.isAfterUndeleteDisabled__c) {
                this.context = TriggerContext.DISABLED_AFTER_UNDELETE;
            } else {
                this.context = TriggerContext.AFTER_UNDELETE;
            }
        }
    }

    // increment the loop count
    @TestVisible
    private void addToLoopCount() {
        String handlerName = getHandlerName();
        if (TriggerHandler.loopCountMap.containsKey(handlerName)) {
            Boolean exceeded = TriggerHandler.loopCountMap.get(handlerName).increment();
            if (exceeded) {
                Integer max = TriggerHandler.loopCountMap.get(handlerName).max;
                throw new TriggerHandlerException(
                    'Maximum loop count of ' + String.valueOf(max) + ' reached in ' + handlerName
                );
            }
        }
    }

    // make sure this trigger should continue to run
    @TestVisible
    private Boolean validateRun() {
        if (!this.isTriggerExecuting || this.context == null) {
            throw new TriggerHandlerException('Trigger handler called outside of Trigger execution');
        }

        //If we get here we should ensure that we are allowed accoarding to TriggerHandler_Settings__mdt
        if (triggerSetting != null && triggerSetting.isDisabled__c) {
            Logger.logInfo(
                String.format(
                    'TriggerHandler_Setting_mdt: {0} has disabled the trigger.',
                    new List<String>{ getHandlerName() }
                )
            );

            return false;
        }

        return !TriggerHandler.bypassedHandlers.contains(getHandlerName());
    }

    private transient String handlerName;
    
    @TestVisible
    private String getHandlerName() {
        if (this.handlerName == null) {
            this.handlerName = this.toString().substringBefore(':');
        }
        return this.handlerName;
    }

    /***************************************
     * context methods
     ***************************************/

    // context-specific methods for override
    @TestVisible
    protected virtual void beforeInsert() {
    }
    @TestVisible
    protected virtual void beforeUpdate() {
    }
    @TestVisible
    protected virtual void beforeDelete() {
    }
    @TestVisible
    protected virtual void afterInsert() {
    }
    @TestVisible
    protected virtual void afterUpdate() {
    }
    @TestVisible
    protected virtual void afterDelete() {
    }
    @TestVisible
    protected virtual void afterUndelete() {
    }

    /***************************************
     * inner classes
     ***************************************/

    // inner class for managing the loop count per handler
    @TestVisible
    private class LoopCount {
        private Integer max;
        private Integer count;

        public LoopCount() {
            this.max = 5;
            this.count = 0;
        }

        public LoopCount(Integer max) {
            this.max = max;
            this.count = 0;
        }

        public Boolean increment() {
            this.count++;
            return this.exceeded();
        }

        public Boolean exceeded() {
            return this.max >= 0 && this.count > this.max;
        }

        public Integer getMax() {
            return this.max;
        }

        public Integer getCount() {
            return this.count;
        }

        public void setMax(Integer max) {
            this.max = max;
        }
    }

    // possible trigger contexts
    @TestVisible
    private enum TriggerContext {
        BEFORE_INSERT,
        BEFORE_UPDATE,
        BEFORE_DELETE,
        AFTER_INSERT,
        AFTER_UPDATE,
        AFTER_DELETE,
        AFTER_UNDELETE,
        DISABLED_BEFORE_INSERT,
        DISABLED_BEFORE_UPDATE,
        DISABLED_BEFORE_DELETE,
        DISABLED_AFTER_INSERT,
        DISABLED_AFTER_UPDATE,
        DISABLED_AFTER_DELETE,
        DISABLED_AFTER_UNDELETE
    }

    // exception class
    public class TriggerHandlerException extends Exception {
    }
}