@isTest
public with sharing class CollectionCalculate_Test {
    
    @TestSetup
    static void makeData(){
       
    }
   
    // Test class for mltiply
    @isTest
    static void test_Multiply() {
        // Create test data
        List<Account> accounts = TDF_AccountUtils.createListOfAccountsWithCVRAndOwner(3);
        accounts.get(0).Name = 'Test Account 1';
        accounts.get(0).AnnualRevenue = 100000;
        accounts.get(1).Name = 'Test Account 2';
        accounts.get(1).AnnualRevenue = 200000;
        accounts.get(2).Name = 'Test Account 3';
        accounts.get(2).AnnualRevenue = 300000; 
        insert accounts;

        List<CollectionCalculate.Requests> requests = new List<CollectionCalculate.Requests>();
        CollectionCalculate.Requests r1 = new CollectionCalculate.Requests();
        r1.operation = 'multiply';
        r1.inputCollection = accounts;
        r1.fieldName = 'AnnualRevenue';
        requests.addAll(new List<CollectionCalculate.Requests>{r1});

        // Call the method to test
        List<CollectionCalculate.Results> results = CollectionCalculate.execute(requests);

        // Verify the results
        System.assertEquals(1, results.size());
        System.assertEquals('6000000000000000', results[0].outputStringResult);
    }

    // Test class for add
    @isTest
    static void test_Add() {
        // Create test data
        List<Account> accounts = TDF_AccountUtils.createListOfAccountsWithCVRAndOwner(3);
        accounts.get(0).Name = 'Test Account 1';
        accounts.get(0).AnnualRevenue = 100000;
        accounts.get(1).Name = 'Test Account 2';
        accounts.get(1).AnnualRevenue = 200000;
        accounts.get(2).Name = 'Test Account 3';
        accounts.get(2).AnnualRevenue = 300000; 
        insert accounts;

        List<CollectionCalculate.Requests> requests = new List<CollectionCalculate.Requests>();
        CollectionCalculate.Requests r1 = new CollectionCalculate.Requests();
        r1.operation = 'add';
        r1.inputCollection = accounts;
        r1.fieldName = 'AnnualRevenue';
        requests.addAll(new List<CollectionCalculate.Requests>{r1});

        // Call the method to test
        List<CollectionCalculate.Results> results = CollectionCalculate.execute(requests);

        // Verify the results
        System.assertEquals(1, results.size());
        System.assertEquals('600000', results[0].outputStringResult);
    }

    // Test class for average
    @isTest
    static void test_Average() {
        // Create test data
        List<Account> accounts = TDF_AccountUtils.createListOfAccountsWithCVRAndOwner(3);
        accounts.get(0).Name = 'Test Account 1';
        accounts.get(0).AnnualRevenue = 100000;
        accounts.get(1).Name = 'Test Account 2';
        accounts.get(1).AnnualRevenue = 200000;
        accounts.get(2).Name = 'Test Account 3';
        accounts.get(2).AnnualRevenue = 300000; 
        insert accounts;

        List<CollectionCalculate.Requests> requests = new List<CollectionCalculate.Requests>();
        CollectionCalculate.Requests r1 = new CollectionCalculate.Requests();
        r1.operation = 'average';
        r1.inputCollection = accounts;
        r1.fieldName = 'AnnualRevenue';
        requests.addAll(new List<CollectionCalculate.Requests>{r1});

        // Call the method to test
        List<CollectionCalculate.Results> results = CollectionCalculate.execute(requests);

        // Verify the results
        System.assertEquals(1, results.size());
        System.assertEquals('200000', results[0].outputStringResult);
    }

    // Test class for min
    @isTest
    static void test_Min() {
        // Create test data
        List<Account> accounts = TDF_AccountUtils.createListOfAccountsWithCVRAndOwner(3);
        accounts.get(0).Name = 'Test Account 1';
        accounts.get(0).AnnualRevenue = 100000;
        accounts.get(1).Name = 'Test Account 2';
        accounts.get(1).AnnualRevenue = 200000;
        accounts.get(2).Name = 'Test Account 3';
        accounts.get(2).AnnualRevenue = 300000; 
        insert accounts;

        List<CollectionCalculate.Requests> requests = new List<CollectionCalculate.Requests>();
        CollectionCalculate.Requests r1 = new CollectionCalculate.Requests();
        r1.operation = 'min';
        r1.inputCollection = accounts;
        r1.fieldName = 'AnnualRevenue';
        requests.addAll(new List<CollectionCalculate.Requests>{r1});

        // Call the method to test
        List<CollectionCalculate.Results> results = CollectionCalculate.execute(requests);

        // Verify the results
        System.assertEquals(1, results.size());
        System.assertEquals(100000, results[0].outputDecimalResult.intValue());
    }

    // Test class for max
    @isTest
    static void test_Max() {
        // Create test data
        List<Account> accounts = TDF_AccountUtils.createListOfAccountsWithCVRAndOwner(3);
        accounts.get(0).Name = 'Test Account 1';
        accounts.get(0).AnnualRevenue = 100000;
        accounts.get(1).Name = 'Test Account 2';
        accounts.get(1).AnnualRevenue = 200000;
        accounts.get(2).Name = 'Test Account 3';
        accounts.get(2).AnnualRevenue = 300000; 
        insert accounts;

        List<CollectionCalculate.Requests> requests = new List<CollectionCalculate.Requests>();
        CollectionCalculate.Requests r1 = new CollectionCalculate.Requests();
        r1.operation = 'max';
        r1.inputCollection = accounts;
        r1.fieldName = 'AnnualRevenue';
        requests.addAll(new List<CollectionCalculate.Requests>{r1});

        // Call the method to test
        List<CollectionCalculate.Results> results = CollectionCalculate.execute(requests);

        // Verify the results
        System.assertEquals(1, results.size());
        System.assertEquals(300000, results[0].outputDecimalResult.intValue());
    }

    // Test class for sum
    @isTest
    static void test_Sum() {
        // Create test data
        List<Account> accounts = TDF_AccountUtils.createListOfAccountsWithCVRAndOwner(3);
        accounts.get(0).Name = 'Test Account 1';
        accounts.get(0).AnnualRevenue = 100000;
        accounts.get(1).Name = 'Test Account 2';
        accounts.get(1).AnnualRevenue = 200000;
        accounts.get(2).Name = 'Test Account 3';
        accounts.get(2).AnnualRevenue = 300000; 
        insert accounts;

        List<CollectionCalculate.Requests> requests = new List<CollectionCalculate.Requests>();
        CollectionCalculate.Requests r1 = new CollectionCalculate.Requests();
        r1.operation = 'sum';
        r1.inputCollection = accounts;
        r1.fieldName = 'AnnualRevenue';
        requests.addAll(new List<CollectionCalculate.Requests>{r1});

        // Call the method to test
        List<CollectionCalculate.Results> results = CollectionCalculate.execute(requests);

        // Verify the results
        System.assertEquals(1, results.size());
        System.assertEquals('600000', results[0].outputStringResult);
    }

    // Test class for count
    @isTest
    static void test_Count() {
        // Create test data
        List<Account> accounts = TDF_AccountUtils.createListOfAccountsWithCVRAndOwner(3);
        accounts.get(0).Name = 'Test Account 1';
        accounts.get(0).AnnualRevenue = 100000;
        accounts.get(1).Name = 'Test Account 2';
        accounts.get(1).AnnualRevenue = 200000;
        accounts.get(2).Name = 'Test Account 3';
        accounts.get(2).AnnualRevenue = 300000; 
        insert accounts;

        List<CollectionCalculate.Requests> requests = new List<CollectionCalculate.Requests>();
        CollectionCalculate.Requests r1 = new CollectionCalculate.Requests();
        r1.operation = 'count';
        r1.inputCollection = accounts;
        requests.addAll(new List<CollectionCalculate.Requests>{r1});

        // Call the method to test
        List<CollectionCalculate.Results> results = CollectionCalculate.execute(requests);

        // Verify the results
        System.assertEquals(1, results.size());
        System.assertEquals(3, results[0].outputDecimalResult.intValue());
    }
}