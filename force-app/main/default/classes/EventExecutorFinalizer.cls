/**
 * Implementation of the Finalizer interface responsible for handling event execution
 * finalization logic. Including error handling and retry mechanisms. It manages
 * event execution outcomes, handles exceptions, and handles retry mechanism
 * for failed executions.
 *
 * @author Niklas Hillgren - Initial implementation
 * @version 1.0
 * @since 2025-04-28
 */
public with sharing class EventExecutorFinalizer implements Finalizer {
    public static final Integer MAX_RETRY_COUNT = 5;

    /**
     * eventExecutorService that encapsulate the business logic
     */
    private final EventExecutorService eventExecutorService;

    private String loggerTraceId;

    /**
     * Currently processed event being handled by the finalizer.
     */
    private EventExecutor__e processedEvent;

    @TestVisible
    private EventExecutorFinalizer(EventExecutorService eventExecutorService) {
        this.eventExecutorService = eventExecutorService;
    }

    public EventExecutorFinalizer() {
        this(SingletonFactory.getFactory());
    }

    public EventExecutorFinalizer(SingletonFactory singletonFactory) {
        this.eventExecutorService = (EventExecutorService) singletonFactory.getOrRegisterSingleton(EventExecutorService.class);
    }

    /**
     * Sets the event being processed by the finalizer.
     *
     * @param processedEvent The event to be tracked during finalization
     */
    public void setProcessedEvent(EventExecutor__e processedEvent) {
        this.processedEvent = processedEvent;
    }

    public EventExecutor__e getProcessedEvent() {
        return processedEvent;
    }

    /**
     * Sets the event being processed by the finalizer.
     *
     * @param processedEvent The event to be tracked during finalization
     */
    public void setLoggerTraceId(String traceId) {
        this.loggerTraceId = traceId;
    }

    private String getExceptionAsString(Exception ex) {
        JSONGenerator gen = JSON.createGenerator(false);
        gen.writeStartObject();
        gen.writeStringField('exceptionType', ex.getTypeName());
        gen.writeStringField('message', ex.getMessage());
        gen.writeStringField('stackTrace', ex.getStackTraceString());
        gen.writeNumberField('lineNumber', ex.getLineNumber());
        gen.writeEndObject();

        return gen.getAsString();
    }

    /**
     * Executes the finalization logic based on the provided context.
     * Handles success cases and implements retry logic for specific exceptions.
     *
     * @param finalizerContext Context containing the execution result (and potential exceptions)
     */
    public void execute(FinalizerContext finalizerContext) {
        Logger.setTraceId(loggerTraceId);
        Logger.logInfo(String.format('execute( {0} )', new List<Object>{ finalizerContext }));

        try {
            if (processedEvent == null) {
                return;
            }

            switch on finalizerContext?.getResult() {
                when SUCCESS {
                    if (Test.isRunningTest()) {
                        //Unit test:
                        //EventExecutorServiceTest.publishEventExecutor_withSUCCESSActionProperty_createTaskInQueueableAndUpdateInFinalizer
                        //uses this task to verify that the EventExecutor "chain" works.
                        List<Task> tasks = [SELECT Id, Subject FROM Task WHERE Subject = 'EventExecutorServiceTest' LIMIT 1];

                        if(!tasks.isEmpty()){
                            Task t = tasks.get(0);
                            t.Subject = t.Subject + 'Finalizer';
                            update t;
                        }
                    }

                    return;
                }
                when UNHANDLED_EXCEPTION {
                    System.debug('METHOD ENTRY WITH EXCEPTION!');
                    Exception ex = finalizerContext.getException();
                    String exceptionString = getExceptionAsString(ex);
                    if (processedEvent.RetryCount__c + 1 >= MAX_RETRY_COUNT) {
                        logger.logError('EventExecutorFinalizer', 'MAXIMUM_RETRY_COUNT REACHED: '+ MAX_RETRY_COUNT + ' halted excecution with exception: ' + exceptionString);
                        return;
                    }

                    switch on ex.getTypeName() {
                        when 'System.UnexpectedException', 'EventExecutorRetryException' {
                            // Retry count starts at 0 and increases by one on each retry -> 4
                            EventExecutor__e retryEventExecutor = eventExecutorService.cloneEventExecutor(
                                processedEvent
                            );

                            retryEventExecutor.RetryCount__c = processedEvent.RetryCount__c + 1;
                            retryEventExecutor.LastEventExecutorException__c = exceptionString;
                            retryEventExecutor.LastEventExecutorUuid__c = processedEvent.EventUuid;
                            retryEventExecutor.LastEventExecutorReplayId__c = processedEvent.ReplayId;
                            eventExecutorService.publish(retryEventExecutor);
                            return;
                        }
                    }
                    //TODO LOOK INTO THE logError (has exception)
                }
            }

            Exception ex = finalizerContext.getException();
            String exceptionString = getExceptionAsString(ex);
            logger.logError('EventExecutorFinalizer', processedEvent.Executor__c + ' should handle ' + exceptionString );
        } catch (Exception ex) {
            Logger.logError('EventExecutorFinalizer', 'catch ' + getExceptionAsString(ex));

            throw ex;
        } finally {
            Logger.emit();
        }
    }
}