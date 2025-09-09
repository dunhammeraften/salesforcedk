/**
 * The exception that should be thrown when event execution requires retry 
 * due to temporary failures or transient conditions.
 *
 * @author Niklas Hillgren - Initial implementation
 * @version 1.0
 * @since 2025-04-28
 */
public with sharing class EventExecutorRetryException extends Exception {
}