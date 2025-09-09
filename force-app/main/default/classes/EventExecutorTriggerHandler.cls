/**
 * A trigger handler implementation for managing the event EventExecutor__e.
 * It utilize the EventExecutorService for processing.
 *
 * @author Niklas Hillgren - Initial implementation with afterInsert
 * @version 1.0
 * @since 2025-04-28
 */
public with sharing class EventExecutorTriggerHandler extends TriggerHandler {



    /**
     * Singleton instance of the EventExecutorService used for processing events
     */
    private final EventExecutorService eventExecutorService;

    /**
     * Collection of newly inserted EventExecutor records from the trigger context
     */
    private List<EventExecutor__e> triggerNew;

    @TestVisible
    private EventExecutorTriggerHandler(EventExecutorService eventExecutorService) {
        this.eventExecutorService = eventExecutorService;
    }

    public EventExecutorTriggerHandler() {
        this(SingletonFactory.getFactory());
    }

    public EventExecutorTriggerHandler(SingletonFactory singletonFactory) {
        this.eventExecutorService = (EventExecutorService) singletonFactory.getOrRegisterSingleton(EventExecutorService.class);
        this.triggerNew = (List<EventExecutor__e>) Trigger.new;
        
        //Disables executors accoarding to custom settings object EventExecutor_Setting__mdt
        this.triggerNew = this.eventExecutorService.removeDisabledExecutors(this.triggerNew);
    }

    /**
     * After-insert operation handler that calls EventExecutorService
     * for processing.
     */
    public override void afterInsert() {
        Logger.logInfo('afterInsert()');
        eventExecutorService.enqueueEventExecutors(triggerNew);
        //Platform events always runs as a separate execution user i.e. we have to emit the logs
    }
}