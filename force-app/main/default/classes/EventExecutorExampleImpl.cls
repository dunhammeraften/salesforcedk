public with sharing class EventExecutorExampleImpl implements IEventExecutableHandler {
    private final DAWAClient dawaClient;

    @TestVisible
    private EventExecutorExampleImpl(DAWAClient dawaClient) {
        this.dawaClient = dawaClient;
    }

    public EventExecutorExampleImpl() {
        this(SingletonFactory.getFactory());
    }

    private EventExecutorExampleImpl(SingletonFactory singletonFactory) {
        this.dawaClient = (DAWAClient) singletonFactory.getOrRegisterSingleton(DAWAClient.class);
    }

    /**
     * @description Parses the provided JSON Parameters into EventExecutorExampleImpl.parameter
     */
    public Parameters parseParameters(String parameters) {
        Logger.logInfo(String.format('parseParameters( {0} )', new List<Object>{ parameters }));

        if (parameters == null) {
            return null;
        }

        return (Parameters) System.JSON.deserialize(parameters, Parameters.class);
    }

    public void execute(EventExecutor__e event) {
        Logger.logInfo(String.format('execute( {0} )', new List<Object>{ event }));

        Parameters params = parseParameters(event.Parameters__c);

        switch on params?.action {
            when 'SUCCESS' {
                //Unit test:
                //EventExecutorServiceTest.publishEventExecutor_withSUCCESSActionProperty_createTaskInQueueableAndUpdateInFinalizer
                //uses this task to verify that the EventExecutor "chain" works.
                if (Test.isRunningTest()) {
                    insert new Task(Subject = 'EventExecutorServiceTest');
                }
                return;
            }
            when 'EXCEPTION' {
                String s;
                s.charat(5); //throws a nullpointer
            }
            when 'RETRY' {
                throw new EventExecutorRetryException('We are going to retry');
            }
            when 'CALLOUT' {
                //THIS SHOULD BE IN A SERVICE CLASS AND NOT BE CALLED DIRECTLY FROM THIS STUFF!
                DAWAClient.DAWADataVaskDTO dataFromServiceCall = dawaClient.addresseVask(params.address);
            }
        }
    }

    public class Parameters {
        public String action;
        public String address;
    }
}