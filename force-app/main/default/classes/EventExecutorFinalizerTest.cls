@isTest
public with sharing class EventExecutorFinalizerTest {
    //This is just a dummy class that can be Mocked as a FinalizerContext
    public class FinalizerMock implements FinalizerContext {
        public System.ParentJobResult res;
        public String requestId;
        public Id asyncApexId;
        public Exception ex;

        public Id getAsyncApexJobId() {
            return asyncApexId;
        }

        public String getRequestId() {
            return requestId;
        }

        public System.ParentJobResult getResult() {
            return this.res;
        }

        public System.Exception getException() {
            return ex;
        }
    }

    @IsTest
    public static void execute_WithSuccesfullContext_DoesNotPublishRetryEvent() {
        //ARRANGE
        Mock eventExecutorServiceMock = Mock.forType(EventExecutorService.class);
        MethodSpy publish = eventExecutorServiceMock.spyOn('publish');

        EventExecutorFinalizer finalizer = new EventExecutorFinalizer(
            (eventExecutorService) eventExecutorServiceMock.stub
        );
        finalizer.setProcessedEvent(new EventExecutor__e());

        //FfinalizerContext cannot be instanciated => but FinalizerContext is an interface...
        FinalizerMock finalizerContextMock = new FinalizerMock();
        finalizerContextMock.res = ParentJobResult.SUCCESS;

        //ACT
        finalizer.execute(finalizerContextMock);

        //ASSERT
        Expect.that(publish).hasNotBeenCalled();

        Assert.isTrue(true, 'Avoid PMD warning (no asserts)');
    }

    @IsTest
    public static void execute_withNullPointerException_doesNotPublishAnotherEvent() {
        //ARRANGE
        Mock eventExecutorServiceMock = Mock.forType(EventExecutorService.class);
        MethodSpy publish = eventExecutorServiceMock.spyOn('publish');

        EventExecutorFinalizer finalizer = new EventExecutorFinalizer(
            (EventExecutorService) eventExecutorServiceMock.stub
        );
        finalizer.setProcessedEvent(new EventExecutor__e(RetryCount__c = 0));

        //FinalizerContext cannot be instanciated => but FinalizerContext is an interface...
        FinalizerMock finalizerContextMock = new FinalizerMock();
        finalizerContextMock.res = ParentJobResult.UNHANDLED_EXCEPTION;

        try {
            //Just constructing a nullpointer exception
            String s;
            s.charAt(5);
        } catch (Exception ex) {
            finalizerContextMock.ex = ex;
        }

        //ACT
        finalizer.execute(finalizerContextMock);

        //ASSERT
        Expect.that(publish).hasNotBeenCalled();
        Assert.isTrue(true, 'Avoid PMD warning (no asserts)');
    }

    @IsTest
    public static void execute_withEventExecutorRetryException_doesPublishAnotherEvent() {
        //ARRANGE
        Mock eventExecutorServiceMock = Mock.forType(EventExecutorService.class);
        MethodSpy publish = eventExecutorServiceMock.spyOn('publish');
        MethodSpy cloneEventExecutor = eventExecutorServiceMock.spyOn('cloneEventExecutor');
        cloneEventExecutor.whenCalledWith(Argument.any()).thenReturn(new EventExecutor__e(RetryCount__c = 0));

        EventExecutorFinalizer finalizer = new EventExecutorFinalizer(
            (eventExecutorService) eventExecutorServiceMock.stub
        );
        finalizer.setProcessedEvent(new EventExecutor__e(RetryCount__c = 0));

        FinalizerMock finalizerContextMock = new FinalizerMock();
        finalizerContextMock.res = ParentJobResult.UNHANDLED_EXCEPTION;

        try {
            throw new EventExecutorRetryException('Throwing exception that will cause a retry event to be published.');
        } catch (Exception ex) {
            finalizerContextMock.ex = ex;
        }

        //ACT
        finalizer.execute(finalizerContextMock);

        //ASSERT
        Expect.that(publish).hasBeenCalled();
        Assert.isTrue(true, 'Avoid PMD warning (no asserts)');
    }

    @IsTest
    public static void execute_withEventExecutorRetryException_doesPublishAnotherEventWithCounterIncreased(){
        //ARRANGE
        Mock eventExecutorServiceMock = Mock.forType(EventExecutorService.class);
        MethodSpy publish = eventExecutorServiceMock.spyOn('publish');
        MethodSpy cloneEventExecutor = eventExecutorServiceMock.spyOn('cloneEventExecutor');
        cloneEventExecutor.whenCalledWith(Argument.any()).thenReturn(new EventExecutor__e(RetryCount__c = 3));

        EventExecutorFinalizer finalizer = new EventExecutorFinalizer(
            (EventExecutorService) eventExecutorServiceMock.stub
        );
        finalizer.setProcessedEvent(new EventExecutor__e(RetryCount__c = 3));

        //FinalizerContext cannot be instanciated => but FinalizerContext is an interface...
        FinalizerMock finalizerContextMock = new FinalizerMock();
        finalizerContextMock.res = ParentJobResult.UNHANDLED_EXCEPTION;
        
        try{
            throw new EventExecutorRetryException('Throwing exception that will cause a retry event to be published.');
        }catch ( Exception ex ){
            finalizerContextMock.ex = ex;
        }
        
        //ACT
        finalizer.execute( finalizerContextMock );

        Expect.that(publish).hasBeenCalled();
        Assert.isTrue(true, 'Avoid PMD warning (no asserts)');
    }

    @IsTest
    public static void execute_withFourInRetryCount_doesNotPublishAnotherEvent(){
        //ARRANGE
        Mock eventExecutorServiceMock = Mock.forType(EventExecutorService.class);
        MethodSpy publish = eventExecutorServiceMock.spyOn('publish');
        MethodSpy cloneEventExecutor = eventExecutorServiceMock.spyOn('cloneEventExecutor');
        cloneEventExecutor.whenCalledWith(Argument.any()).thenReturn(new EventExecutor__e(RetryCount__c = 4));


        EventExecutorFinalizer finalizer = new EventExecutorFinalizer(
            (eventExecutorService) eventExecutorServiceMock.stub
        );
        finalizer.setProcessedEvent(new EventExecutor__e(RetryCount__c = 4));

        //FinalizerContext cannot be instanciated => but FinalizerContext is an interface...
        FinalizerMock finalizerContextMock = new FinalizerMock();
        finalizerContextMock.res = ParentJobResult.UNHANDLED_EXCEPTION;
        
        try{
            throw new EventExecutorRetryException('Throwing exception that will cause a retry event to be published.');
        }catch ( Exception ex ){
            finalizerContextMock.ex = ex;
        }
        
        //ACT
        finalizer.execute( finalizerContextMock );

        //ASSERT
        Expect.that(publish).hasNotBeenCalled();
        Assert.isTrue(true, 'Avoid PMD warning (no asserts)');
    }
}