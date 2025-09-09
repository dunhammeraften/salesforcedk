/**
 * Service/Business class responsible for handling logic for the EventExecutor "module".
 * Provides functionality to work with EventExecutor event such as enqueue, execute, clone and publishing on the event bus.
 *
 * @author Niklas Hillgren - Initial implementation
 * @version 1.0 - Initial version
 * @since 2025-04-28
 */
public with sharing class EventExecutorService {
    private static Map<String, EventExecutor_Setting__mdt> eventExecutorSettings;

    // static initialization
    static {
        eventExecutorSettings = EventExecutor_Setting__mdt.getAll();
    }

    /**
     * Enqueues multiple EventExecutor instances for asynchronous processing using Salesforce Queueable jobs.
     * This utility method processes each executor in the provided list, creating a separate Queueable job for each one.
     *
     * @param executors A list of EventExecutor__e objects to be processed asynchronously
     * @return A list of Job IDs corresponding to each enqueued Queueable job
     * @throws TypeException if any executor in the list contains invalid data
     * @throws LimitException if system limits would be exceeded during job creation
     */
    @SuppressWarnings('PMD.OperationWithLimitsInLoop')
    public List<Id> enqueueEventExecutors(List<EventExecutor__e> executors) {
        Logger.logInfo(String.format('enqueueEventExecutors( {0} )', new List<Object>{ executors }));

        List<Id> queueableJobIds = new List<Id>();

        if (executors == null || executors.isEmpty()) {
            return queueableJobIds;
        }

        //One queueable for each platform event the queueable is executed and started by Salesforce core
        for (EventExecutor__e eventToExecute : executors) {
            EventExecutorQueueable queueableExecutor = new EventExecutorQueueable();

            /*
            queueableExecutor.setEventToExecute(eventToExecute);
            queueableJobIds.add(System.enqueueJob(queueableExecutor));
			*/
            //TODO TALK ABOUT THIS!
            Integer executionDelay = Integer.valueOf(eventToExecute.RetryCount__c);
            queueableExecutor.setEventToExecute(eventToExecute);
            system.debug('khp adding queueable ' + queueableExecutor);
            try{
                queueableJobIds.add(System.enqueueJob(queueableExecutor, executionDelay));
            }catch(Exception e){
                System.debug('### Error Occured while calling System.enqueueJob : ' + e.getMessage());
            }
        }

        return queueableJobIds;
    }

    //This is NOT the great place to keep this settings logic
    /**
     * Filter out executors that has been disabled by the custom metadata EventExecutor_Setting__mdt.
     *
     * @param executors A list of EventExecutor__e objects to be processed asynchronously
     * @return A list of EventExecutor__e that should be executed
     */
    public List<EventExecutor__e> removeDisabledExecutors(List<EventExecutor__e> executors) {
        List<EventExecutor__e> filteredExecutors = new List<EventExecutor__e>();

        for (EventExecutor__e eventToExecute : executors) {
            if (
                eventExecutorSettings.containsKey(eventToExecute.Executor__c) &&
                eventExecutorSettings.get(eventToExecute.Executor__c).isDisabled__c
            ) {
                Logger.logInfo(
                    String.format(
                        'EventExecutor_Setting__mdt: {0} has disabled the executor: {1}',
                        new List<Object>{ eventToExecute.Executor__c, eventToExecute }
                    )
                );
            } else {
                filteredExecutors.add(eventToExecute);
            }
        }

        return filteredExecutors;
    }

    public EventExecutorFinalizer attachEventExecutorFinalizer(EventExecutor__e eventToExecute) {
        Logger.logInfo(String.format('attachEventExecutorFinalizer( {0} )', new List<Object>{ eventToExecute }));

        EventExecutorFinalizer finalizer = new EventExecutorFinalizer();
        finalizer.setProcessedEvent(eventToExecute);
        finalizer.setLoggerTraceId(Logger.getTraceId());

        if (System.isQueueable()) {
            System.attachFinalizer(finalizer);
        }

        return finalizer;
    }

    /**
     * Publishes an EventExecutor event to the Salesforce event bus.
     *
     * @param evenExecutorToPublish The EventExecutor__e event to publish
     * @return Database.SaveResult containing the result of the publishing operation
     * @throws Exception if there's an error during event publication
     */

    public Database.SaveResult publish(EventExecutor__e eventExecutorToPublish) {
        Logger.logInfo(String.format('publish( {0} )', new List<Object>{ eventExecutorToPublish }));
        
        List<Database.SaveResult> saveResults;

        try {
            if (eventExecutorToPublish != null) {
                saveResults = publish(new List<EventExecutor__e>{ eventExecutorToPublish });
            }
        } catch (Exception e) {
            throw e;
        }

        return saveResults.get(0);
    }

    public List<Database.SaveResult> publish(List<EventExecutor__e> eventsExecutorToPublish) {
        Logger.logInfo(String.format('publish( {0} )', new List<Object>{ eventsExecutorToPublish }));

        List<Database.SaveResult> saveResults;

        try {
            if (eventsExecutorToPublish != null) {
                saveResults = EventBus.publish(eventsExecutorToPublish);
            }
        } catch (Exception e) {
            throw e;
        }

        return saveResults;
    }

    

    /**
     * Executes an event using the specified EventExecutor.
     *
     * This method instantiates and executes an event handler/executor based on the executor class
     * defined in the event.Executor__c field. It handles instantiation errors and delegates
     * the actual event execution to the instantiated executor instance.
     *
     * @param eventToExecute The EventExecutor__e event containing the event details and
     *                      executor configuration
     * @throws Exception if there is an error instantiating the executor class or during
     *                   event execution
     *
     */
    public void executeEventExecutor(EventExecutor__e eventToExecute) {
        Logger.logInfo(String.format('executeEventExecutor( {0} )', new List<Object>{ eventToExecute }));

        IEventExecutableHandler eventExecutorHandler;
        try {
            Type t = Type.forName(eventToExecute.Executor__c);

            eventExecutorHandler = (IEventExecutableHandler) t.newInstance();
        } catch (Exception ex) {
            throw ex;
        }

        eventExecutorHandler.execute(eventToExecute);
    }

    /**
     * Creates a deep copy of an existing EventExecutor record.
     *
     * @param eventToClone The source EventExecutor record to be cloned
     * @return A new EventExecutor record containing selected fields from the original
     */
    public EventExecutor__e cloneEventExecutor(EventExecutor__e eventToClone) {
        Logger.logInfo(String.format('cloneEventExecutor( {0} )', new List<Object>{ eventToClone }));

        if (eventToClone == null) {
            return null;
        }

        EventExecutor__e clonedEvent = new EventExecutor__e();
        //An exception was thrown that we should look into
        clonedEvent.Executor__c = eventToClone.Executor__c;
        clonedEvent.Parameters__c = eventToClone.Parameters__c;
        clonedEvent.RetryCount__c = eventToClone.RetryCount__c;

        return clonedEvent;
    }
}