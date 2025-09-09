/**
 * Interface that pocess single events. The processing takes place in EventExecutableQueueable.
 * 
 *
 * @author Niklas Hillgren  - Initial implementation
 * @version 1.0
 * @since 2025-04-28
 */
public interface IEventExecutableHandler {
    /**
     * Executes the provided event through the EventExecutor.
     *
     * @param event The event to be processed by the executor TODO NOTES ABOUT RETRY AND EXCEPTION
     * @throws EventExecutableRetryException if the event execution fails and should be retried
     */
    void execute(EventExecutor__e event);
}