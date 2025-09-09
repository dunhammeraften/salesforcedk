/**
 * A Queueable implementation designed to handle event execution.
 * This class manages the faults/exception through the EventExecutorFinalizer finalization.
 *
 * @author Niklas Hillgren  - Initial implementation
 * @version 1.0
 * @since 2025-04-28
 */
public with sharing class EventExecutorQueueable implements Queueable, Database.AllowsCallouts {
    /**
     * eventExecutorService that encapsulate the business logic
     */
    private final EventExecutorService eventExecutorService;

    /**
     * The event to be processed.
     */
    private EventExecutor__e eventToExecute;

    @TestVisible
    private EventExecutorQueueable(EventExecutorService eventExecutorService) {
        this.eventExecutorService = eventExecutorService;
    }

    public EventExecutorQueueable() {
        this(SingletonFactory.getFactory());
    }

    public EventExecutorQueueable(SingletonFactory singletonFactory) {
        this.eventExecutorService = (EventExecutorService) singletonFactory.getOrRegisterSingleton(EventExecutorService.class);
    }

    /**
     * Sets the event that will be processed during asynchronous execution.
     *
     * @param eventToExecute The event to process asynchronously
     */
    public void setEventToExecute(EventExecutor__e eventToExecute) {
        this.eventToExecute = eventToExecute;
    }

    /**
     * Executes the queued job asynchronously. This method processes the stored event
     * and ensures proper cleanup through transaction finalization.
     *
     * @param context The QueueableContext object containing information about the queued job
     */
    public void execute(QueueableContext context) {
        Logger.logInfo(String.format('execute( {0} )', new List<Object>{ context }));

        try {
            //If we don't have any requests to process exit
            if (eventToExecute == null) {
                return;
            }

            eventExecutorService.attachEventExecutorFinalizer(eventToExecute);

            eventExecutorService.executeEventExecutor(eventToExecute);
            Logger.emit();
        } catch (Exception ex) {
            //Write the exception as JSON object JSON.serialize cannot be used on exception
            JSONGenerator gen = JSON.createGenerator(true);
            gen.writeStartObject();
            gen.writeStringField('exceptionType', ex.getTypeName());
            gen.writeStringField('message', ex.getMessage());
            gen.writeStringField('stackTrace', ex.getStackTraceString());
            gen.writeNumberField('lineNumber', ex.getLineNumber());
            gen.writeEndObject();

            Logger.logError('EventExecutorQueueable', gen.getAsString());
            //Rethrow so the finalizer can handle the exception
            throw ex;
        } finally {
            Logger.emit();
        }
    }
}