@IsTest
private class ExtractStringsFromCollectionTest {
    @TestSetup
    static void setup(){
        List<Account> accounts = TDF_AccountUtils.createListOfAccountsWithCVRAndOwner(10);
      
        Account accExtra = TDF_AccountUtils.createAccountWithCVR('98765432');
        accExtra.Name='Test 1';

        accounts.add(accExtra);
        insert accounts;
    }

    @IsTest
    static void emptyInputCollectionThrowsError() {
        List<ExtractStringsFromCollection.Request> flowRequests = new List<ExtractStringsFromCollection.Request>();
        ExtractStringsFromCollection.Request flowRequest = new ExtractStringsFromCollection.Request();
        flowRequest.inputRecordCollection = new List<Account>();
        flowRequest.fieldAPIName = '';
        flowRequests.add(flowRequest);
        ExtractStringsFromCollection.ExtractStringsException exc;
        Test.startTest();
        try {
            List<ExtractStringsFromCollection.Result> results = ExtractStringsFromCollection.extract(flowRequests);
        } catch (ExtractStringsFromCollection.ExtractStringsException e) {
            exc = e;
        }
        Test.stopTest();
        System.assert(exc != null, 'DedupeFieldsFromCollectionTest : emptyInputCollectionThrowsError failed');
    }
    
    @IsTest
    static void emptyInputCollectionReturnsEmpty() {
        List<ExtractStringsFromCollection.Request> flowRequests = new List<ExtractStringsFromCollection.Request>();
        ExtractStringsFromCollection.Request flowRequest = new ExtractStringsFromCollection.Request();
        flowRequest.inputRecordCollection = new List<Account>();
        flowRequest.fieldAPIName = 'name';
        flowRequest.dedupeValues = false;
        flowRequest.allowEmptyCollection = true;
        flowRequests.add(flowRequest);
        ExtractStringsFromCollection.ExtractStringsException exc;
        Test.startTest();
        List<ExtractStringsFromCollection.Result> results = ExtractStringsFromCollection.extract(flowRequests);
        Test.stopTest();
        System.assert(results[0].fieldValueCollection.size() == 0, 'DedupeFieldsFromCollectionTest : emptyInputCollectionReturnsEmptyOutputCollection failed');
    }

    @IsTest
    static void extractTextCollectionNoDedupe() {
        List<ExtractStringsFromCollection.Request> flowRequests = new List<ExtractStringsFromCollection.Request>();
        ExtractStringsFromCollection.Request flowRequest = new ExtractStringsFromCollection.Request();
        flowRequest.inputRecordCollection = [SELECT Name FROM Account LIMIT 50];
        flowRequest.fieldAPIName = 'name';
        flowRequest.dedupeValues = false;
        flowRequests.add(flowRequest);
        Test.startTest();
        List<ExtractStringsFromCollection.Result> results = ExtractStringsFromCollection.extract(flowRequests);
        Test.stopTest();
        System.assert(results[0].fieldValueCollection.size() == 11, 'DedupeFieldsFromCollectionTest : dedupeTextCollectionSuccess failed');
    }

    //TODO: khp fix unittest
    // @IsTest
    // static void extractTextCollectionSuccess() {
    //     List<ExtractStringsFromCollection.Request> flowRequests = new List<ExtractStringsFromCollection.Request>();
    //     ExtractStringsFromCollection.Request flowRequest = new ExtractStringsFromCollection.Request();
    //     flowRequest.inputRecordCollection = [SELECT Name FROM Account LIMIT 50];
    //     flowRequest.fieldAPIName = 'name';
    //     flowRequests.add(flowRequest);
    //     Test.startTest();
    //     List<ExtractStringsFromCollection.Result> results = ExtractStringsFromCollection.extract(flowRequests);
    //     system.debug(results);
    //     Test.stopTest();
    //     System.debug('dedupe size' + results[0].fieldValueCollection.size());
    //     System.assert(results[0].fieldValueCollection.size() == 10, 'DedupeFieldsFromCollectionTest : dedupeTextCollectionSuccess failed');
    // }
    
    // @IsTest
    // static void extractTextCollectionSuccessNullValues() {
    //     List<Account> accounts = [Select Id, BillingCity from Account LIMIT 8]; // out of 10: leave one null, set one unique
    //     for (Account act: accounts) {
    //         act.BillingCity = 'Test City';
    //     }
    //     update accounts;
    //     List<Account> accounts2 = [Select Id, BillingCity from Account WHERE BillingCity != 'Test City' LIMIT 1]; // out of 10: leave one null, set one unique
	// 	accounts2[0].BillingCity = 'Test City 2';
    //     update accounts2;
        
    //     List<ExtractStringsFromCollection.Request> flowRequests = new List<ExtractStringsFromCollection.Request>();
    //     ExtractStringsFromCollection.Request flowRequest = new ExtractStringsFromCollection.Request();
    //     flowRequest.inputRecordCollection = [SELECT BillingCity FROM Account LIMIT 50];
    //     flowRequest.fieldAPIName = 'BillingCity';
    //     flowRequests.add(flowRequest);
    //     Test.startTest();
    //     List<ExtractStringsFromCollection.Result> results = ExtractStringsFromCollection.extract(flowRequests);
    //     Test.stopTest();
    //     System.assert(results[0].fieldValueCollection.size() == 2, 'DedupeFieldsFromCollectionTest : dedupeTextCollectionSuccess failed');
    // }
}