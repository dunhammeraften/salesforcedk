@IsTest(IsParallel=true)
public with sharing class EventExecutorServiceTest {
    //Test happy path of the EventExecutor "module"
    //When the platform event "EventExecutor__e" is published:
    //1) EventExecutorTriggerHandler enqueues the queueable class EventExecutorQueueable
    //2) Queuable execution instanciate EventExecutorExampleImpl and call execute => 
    //   A Task is created with subject = EventExecutorServiceTest
    //3) Finalizer update the subject with "Finalizer"
    //4) The Assert test ensures that a task exist with subject EventExecutorServiceTestFinalizer
    @IsTest
    public static void publishEventExecutor_withSUCCESSActionProperty_createTaskInQueueableAndUpdateInFinalizer() {
        EventExecutorService service = new EventExecutorService();

        Test.startTest();
        service.publish(
            new EventExecutor__e(Executor__c = 'EventExecutorExampleImpl', Parameters__c = '{"action":"SUCCESS"}')
        );

        Test.getEventBus().deliver();
        Test.stopTest();

        Assert.isTrue(
            [SELECT Id FROM Task WHERE subject = 'EventExecutorServiceTestFinalizer'].size() == 1,
            'We created a test task'
        );
    }

    @IsTest
    public static void enqueueEventExecutors_withNull_returnEmptyList() {
        //ARRANGE
        EventExecutorService service = new EventExecutorService();

        //ACT
        List<Id> enqueuedJobs = service.enqueueEventExecutors(null);

        //ASSERT
        Assert.isNotNull(enqueuedJobs, 'Enqueued jobs is not null');
        Assert.isTrue(enqueuedJobs.isEmpty(), 'Enqueued jobs is empty');
    }

    @IsTest
    public static void enqueueEventExecutors_withEmptyList_returnEmptyList() {
        //ARRANGE
        EventExecutorService service = new EventExecutorService();

        List<EventExecutor__e> eventToEnqueue = new List<EventExecutor__e>();

        //ACT
        List<Id> enqueuedJobs = service.enqueueEventExecutors(eventToEnqueue);

        //ASSERT
        Assert.isNotNull(enqueuedJobs, 'Enqueued jobs is not null');
        Assert.isTrue(enqueuedJobs.isEmpty(), 'Enqueued jobs is empty');
    }

    @IsTest
    public static void enqueueEventExecutors_createOneQueueubleForEachEventExecutor_returnList() {
        //ARRANGE
        EventExecutorService service = new EventExecutorService();

        List<EventExecutor__e> eventToEnqueue = new List<EventExecutor__e>();

        EventExecutor__e e1 = new EventExecutor__e(Executor__c = 'EventExecutorExampleImpl', Parameters__c = '{"action":"SUCCESS"}');
        e1.RetryCount__c = 2;

        EventExecutor__e e2 = new EventExecutor__e(Executor__c = 'EventExecutorExampleImpl', Parameters__c = '{"action":"SUCCESS"}');
        e2.RetryCount__c = 2;

        EventExecutor__e e3 = new EventExecutor__e(Executor__c = 'EventExecutorExampleImpl', Parameters__c = '{"action":"SUCCESS"}');
        e3.RetryCount__c = 2;

        eventToEnqueue.add(e1);
        eventToEnqueue.add(e2);
        eventToEnqueue.add(e3);

        //ACT
        List<Id> enqueuedJobs = service.enqueueEventExecutors(eventToEnqueue);

        //ASSERT
        Assert.isNotNull(enqueuedJobs, 'Enqueued jobs is not null');
        Assert.isTrue(enqueuedJobs.size() == 3, 'One queueuble job/event');
    }

    @IsTest
    public static void attachEventExecutorFinalizer_withNull_returnFinalizer() {
        //ARRANGE
        EventExecutorService service = new EventExecutorService();

        //ACT
        EventExecutorFinalizer finalizer = service.attachEventExecutorFinalizer(null);

        //ASSERT
        Assert.isNotNull(finalizer, 'finalizer is not null');
    }

    @IsTest
    public static void attachEventExecutorFinalizer_withEvent_returnFinalizerWithEvent() {
        //ARRANGE
        EventExecutorService service = new EventExecutorService();
        //ACT
        EventExecutorFinalizer finalizer = service.attachEventExecutorFinalizer(
            new EventExecutor__e(Executor__c = 'EventExecutorExampleImpl', Parameters__c = 'JUST_FOR_TEST')
        );

        //ASSERT
        Assert.isNotNull(finalizer, 'finalizer is not null');
        Assert.isTrue(
            'JUST_FOR_TEST' == finalizer.getProcessedEvent().Parameters__c,
            'The event contains the same parameters'
        );
    }

    @IsTest
    public static void cloneEventExecutor_withNull_returnNull() {
        //ARRANGE
        EventExecutorService service = new EventExecutorService();

        //ACT
        EventExecutor__e eventExecutor = service.cloneEventExecutor(null);

        //ASSERT
        Assert.isNull(eventExecutor, 'eventExecutor is null');
    }

    @IsTest
    public static void cloneEventExecutor_withEvent_returnClone() {
        //ARRANGE
        EventExecutorService service = new EventExecutorService();

        EventExecutor__e eventToClone = new EventExecutor__e(Parameters__c = 'CLONE_ME');

        //ACT
        EventExecutor__e clonedEvent = service.cloneEventExecutor(eventToClone);

        //ASSERT
        Assert.isNotNull(clonedEvent, 'eventExecutor should not be null');
        Assert.isTrue(
            eventToClone.Parameters__c == clonedEvent.Parameters__c,
            'clonedEvent should have the same parameters.'
        );

        // If eventToClone and clonedEvent reference the exact same location in memory the expression evaluates to true.
        Boolean sameMemoryAddress = eventToClone === clonedEvent;
        Assert.isFalse(sameMemoryAddress, 'clonedEvent should not point to the same memory.');
    }
}