@IsTest(IsParallel = true)
public with sharing class EventExecutorTriggerHandlerTest {
    @IsTest
    public static void afterInsert_enqueuesEvents() {
        //ARRANGE
        Mock eventExecutorServiceMock = Mock.forType(EventExecutorService.class);
        MethodSpy enqueueEventExecutorsSpy = eventExecutorServiceMock.spyOn('enqueueEventExecutors');

        EventExecutorTriggerHandler triggerHandler = new EventExecutorTriggerHandler(
            (EventExecutorService) eventExecutorServiceMock.stub
        );


        //ACT
        triggerHandler.afterInsert();
        //ASSERT
        Expect.that(enqueueEventExecutorsSpy).hasBeenCalled();
    }
}