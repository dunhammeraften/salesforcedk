@isTest
private with sharing class AccountTriggerHandlerTest {
 
    @IsTest
    private static void companyAPIDataFetchIsCalled() {
  
      Mock accountServiceMock = Mock.forType(AccountService.class);
      MethodSpy companyAPIDataFetchSpy = accountServiceMock.spyOn('CompanyAPIDataFetch');
      
      companyAPIDataFetchSpy.whenCalledWith(Argument.any()).thenReturn(new Set<Id>());
        
      AccountTriggerHandler triggerHandler = new AccountTriggerHandler(
        (AccountService) accountServiceMock.stub
      );

      triggerHandler.afterInsert();

      Expect.that(companyAPIDataFetchSpy).hasBeenCalled();
    }

    @IsTest
    private static void contractAPIDataFetchIsCalled() {
      //ARRANGE
      Mock accountServiceMock = Mock.forType(AccountService.class);
      MethodSpy contractAPIDataFetchSpy = accountServiceMock.spyOn('ContractAPIDataFetch');
      
      contractAPIDataFetchSpy.whenCalledWith(Argument.any()).thenReturn(new List<Id>());
      
      AccountTriggerHandler triggerHandler = new AccountTriggerHandler(
        (AccountService) accountServiceMock.stub
      );

      //ACT
      triggerHandler.beforeUpdate();
      //ASSERT
      Expect.that(contractAPIDataFetchSpy).hasBeenCalled();
    }
}