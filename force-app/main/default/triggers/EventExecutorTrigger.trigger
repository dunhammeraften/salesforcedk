/**
 * @author Niklas Hillgren - Initial implementation
 * @version 1.0
 * @since 2025-04-28
 */
trigger EventExecutorTrigger on EventExecutor__e (after insert) {
    new EventExecutorTriggerHandler().run();
}