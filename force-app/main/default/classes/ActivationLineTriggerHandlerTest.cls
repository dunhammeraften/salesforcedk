@isTest
private with sharing class ActivationLineTriggerHandlerTest {

    @IsTest
    private static void afterUpdateTest() {
        //ARRANGE
        Mock activationLineServiceMock = Mock.forType(ActivationLineService.class);
        MethodSpy hasCompletedVoiceFlowSpy = activationLineServiceMock.spyOn('hasCompletedVoiceFlow');
        hasCompletedVoiceFlowSpy.whenCalledWith(Argument.any(), Argument.any()).thenReturn(new List<Activation_line__c>());
        
        MethodSpy createActivationLineSpy = activationLineServiceMock.spyOn('createActivationLine');
        createActivationLineSpy.whenCalledWith(Argument.any()).thenReturn(new List<Activation_line__c>());
        
        ActivationLineTriggerHandler activationLineTriggerHandler = new ActivationLineTriggerHandler(
           (ActivationLineService) activationLineServiceMock.stub
        );
        
        //ACT
        activationLineTriggerHandler.afterUpdate();
        
        //ASSERT
        Expect.that(hasCompletedVoiceFlowSpy).hasBeenCalled();
        Expect.that(createActivationLineSpy).hasNotBeenCalled();
    }
    
}