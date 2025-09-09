@isTest
public with sharing class EventExecutorQueueableTest {
    @IsTest
    public static void execute_WithEventExecutor_RunsBusinessLogic() {
        //ARRANGE
        Mock eventExecutorServiceMock = Mock.forType(EventExecutorService.class);
        MethodSpy attachEventExecutorFinalizerSpy = eventExecutorServiceMock.spyOn('attachEventExecutorFinalizer');
        MethodSpy executeEventExecutorSpy = eventExecutorServiceMock.spyOn('executeEventExecutor');

        EventExecutorQueueable testQueueable = new EventExecutorQueueable(
            (eventExecutorService) eventExecutorServiceMock.stub
        );
        testQueueable.setEventToExecute(new EventExecutor__e());

        //ACT
        testQueueable.execute(null);

        //ASSERT
        Expect.that(attachEventExecutorFinalizerSpy).hasBeenCalled();
        Expect.that(executeEventExecutorSpy).hasBeenCalled();
    }

    @IsTest
    public static void execute_withoutEventExecutor_doesNotRunBusinessLogic() {
        //ARRANGE
        Mock eventExecutorServiceMock = Mock.forType(EventExecutorService.class);
        MethodSpy attachEventExecutorFinalizerSpy = eventExecutorServiceMock.spyOn('attachEventExecutorFinalizer');
        MethodSpy executeEventExecutorSpy = eventExecutorServiceMock.spyOn('executeEventExecutor');

        EventExecutorQueueable testQueueable = new EventExecutorQueueable(
            (eventExecutorService) eventExecutorServiceMock.stub
        );
        testQueueable.setEventToExecute(null);
        //ACT
        testQueueable.execute(null);

        //ASSERT
        Expect.that(attachEventExecutorFinalizerSpy).hasNotBeenCalled();
        Expect.that(executeEventExecutorSpy).hasNotBeenCalled();
    }
}