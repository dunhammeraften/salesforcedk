@isTest
public with sharing class CheckValidationTest {
    
    //TODO: khp fix unittest
    // static testMethod void test() {

    //     Account a1 = TDF_AccountUtils.creatActiveAccountWithCVRAndOwner('12345678');
    //     a1.Name = 'Account1';
    //     insert a1;
    //     Account[] accts = [Select Id, Name from Account Where Name = 'Account1'];
    //     Account a2 = TDF_AccountUtils.creatActiveAccountWithCVRAndOwner('12345679');
    //     a2.Name = 'Account2';

    //     CheckValidation.Requests testRequest = new CheckValidation.Requests();
    //     List<CheckValidation.Requests> testRequestList = new List<CheckValidation.Requests>();

    //     // Test Insert Record Collection - No Errors
    //     System.debug('Test Insert Record Collection - No Errors');
    //     accts.add(a2);
    //     testRequest.inputCollection = accts;
    //     testRequest.isCommit = true;
    //     testRequest.checkDuplicates = false;
    //     testRequestList.add(testRequest);
    //     List<CheckValidation.Results> testResultList = CheckValidation.checkForValidationErrors(testRequestList);
    //     System.assert(!testResultList[0].isError);
    //     System.assertEquals(1, testResultList[0].insertedIdCollection.size());

    //     // Test Missing Name Field
    //     System.debug('Test Missing Name Field');
    //     testRequest.inputCollection = null;
    //     a2.Name = '';
    //     testRequest.inputRecord = a2;
    //     testRequest.isCommit = false;
    //     testRequest.checkDuplicates = false;
    //     testRequestList.clear();
    //     testRequestList.add(testRequest);
    //     testResultList = CheckValidation.checkForValidationErrors(testRequestList);
    //     System.assert(testResultList[0].isError);
    //     System.assert(testResultList[0].errorMessages.contains('Required fields are missing'));

    //     // Test Insert Record Error
    //     System.debug('Test Insert Record Error');
    //     a2.Name = '';
    //     a2.Id = null;
    //     testRequest.inputRecord = a2;
    //     testRequest.checkDuplicates = true;
    //     testRequestList.clear();
    //     testRequestList.add(testRequest);
    //     testResultList = CheckValidation.checkForValidationErrors(testRequestList);
    //     System.assert(testResultList[0].isError);
    //     System.assert(testResultList[0].errorMessages.contains('Required fields are missing'));
        
    // }
}