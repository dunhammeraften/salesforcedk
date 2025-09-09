/**
 * 
 * @author keh
 * @since 14032025
 */
@isTest
public class ExecuteSOQLTest {
    private static final String TEST_CVR = '12345678';

    /**
     * execute_EnglishUpperCasePM_returnsCorrectResult
     */
    @isTest 
    public static void execute_EnglishUpperCasePM_returnsCorrectResult() {
        //ARRANGE
        Account acc = TDF_AccountUtils.creatActiveAccountWithCVRAndOwner(TEST_CVR);
        insert acc;

        //Not formatted DateTime
        ExecuteSOQL.Requests requests = new ExecuteSOQL.Requests();
        requests.soqlQuery = 'Select Id From Account Where CreatedDate >= 04/12/2020 03:24 PM';

        //ACT
        Test.startTest();
        List<ExecuteSOQL.Results> results = ExecuteSOQL.execute(new List<ExecuteSOQL.Requests>{
                requests
        });
        Test.stopTest();

        //ASSERT
        System.assertEquals(acc.Id, results[0].sObjects[0].Id);
    }

    /**
     * execute_EnglishWithComma_returnsCorrectResult
     */
    @isTest
    public static void execute_EnglishWithComma_returnsCorrectResult() {
        //ARRANGE
        Account acc = TDF_AccountUtils.creatActiveAccountWithCVRAndOwner(TEST_CVR);
        insert acc;
        Test.setCreatedDate(acc.id, Datetime.newInstance(2020, 4, 12, 1, 0, 0));

        ExecuteSOQL.Requests requests = new ExecuteSOQL.Requests();
        requests.soqlQuery = 'Select Id From Account Where CreatedDate <= 04/12/2020, 12:00 pm';

        //ACT
        Test.startTest();
        List<ExecuteSOQL.Results> results = ExecuteSOQL.execute(new List<ExecuteSOQL.Requests>{
            requests
        });
        Test.stopTest();

        //ASSERT
        System.assertEquals(acc.Id, results[0].sObjects[0].Id);
    }

    /**
     * execute_SOQLMonthDayCommaYear_returnsCorrectResult
     */
    @isTest
    private static void execute_SOQLMonthDayCommaYear_returnsCorrectResult() {
        //ARRANGE
        Account acc = TDF_AccountUtils.creatActiveAccountWithCVRAndOwner(TEST_CVR);
        insert acc;

        //Not formatted Date
        ExecuteSOQL.Requests requests = new ExecuteSOQL.Requests();
        requests.soqlQuery = 'Select Id From Account Where CreatedDate >= April 12, 2020';

        //ACT
        Test.startTest();
        List<ExecuteSOQL.Results> results = ExecuteSOQL.execute(new List<ExecuteSOQL.Requests>{
                requests
        });
        Test.stopTest();

        //ASSERT
        System.assertEquals(acc.Id, results[0].sObjects[0].Id);
    }
    
    /**
     * execute_SOQLLonDateTime_returnsCorrectResult
     */
    @isTest
    private static void execute_SOQLLonDateTime_returnsCorrectResult() {
        //ARRANGE
        Account acc = TDF_AccountUtils.creatActiveAccountWithCVRAndOwner(TEST_CVR);
        insert acc;

        //Formatted date time
        ExecuteSOQL.Requests requests = new ExecuteSOQL.Requests();
        requests.soqlQuery = 'Select Id From Account Where CreatedDate >= 2020-04-12T15:24:00Z';

        //ACT
        Test.startTest();
        List<ExecuteSOQL.Results> results = ExecuteSOQL.execute(new List<ExecuteSOQL.Requests>{
                requests
        });
        Test.stopTest();

        //ASSERT
        System.assertEquals(acc.Id, results[0].sObjects[0].Id);
    }
    
    /**
     * execute_SOQLDateLiteral_returnsCorrectResult
     */
    @isTest
    private static void execute_SOQLDateLiteral_returnsCorrectResult() {
        //ARRANGE
        Account acc = TDF_AccountUtils.creatActiveAccountWithCVRAndOwner(TEST_CVR);
        insert acc; 

        //Formatted date time
        ExecuteSOQL.Requests requests = new ExecuteSOQL.Requests();
        requests.soqlQuery = 'Select Id From Account Where CreatedDate = LAST_n_DAYS:14';

        //ACT
        Test.startTest();
        List<ExecuteSOQL.Results> results = ExecuteSOQL.execute(new List<ExecuteSOQL.Requests>{
                requests
        });
        Test.stopTest();

        //ASSERT
        System.assertEquals(1, results[0].sObjects.size());
        System.assertEquals(acc.Id, results[0].sObjects[0].Id);
    }

    /**
     * execute_witId_returnsCorrectResult
     */
    @isTest
    private static void execute_witId_returnsCorrectResult() {      
        //ARRANGE
        List<Account> listOfAccounts = TDF_AccountUtils.createListOfAccountsWithCVRAndOwner(3);
        insert listOfAccounts;
        Account searchAccount = listOfAccounts.get(2);
        
        ExecuteSOQL.Requests requests = new ExecuteSOQL.Requests();
        requests.soqlQuery = 'Select Id From Account Where Name != \'TEST\' AND Id = \'' + searchAccount.Id + '\'';
                
        //ACT
        Test.startTest();
        List<ExecuteSOQL.Results> results = ExecuteSOQL.execute(new List<ExecuteSOQL.Requests>{requests});
        Test.stopTest();
        
        //ASSERT
        System.assertEquals(1, results[0].sObjects.size());  
        System.assertEquals(searchAccount.Id, results[0].sObjects[0].Id);  
    }
    
    /**
     * execute_OrderBy_returnsOrderedResult
     */
    @isTest
    private static void execute_OrderBy_returnsOrderedResult() {
        //ARRANGE
        List<Account> listOfAccounts = TDF_AccountUtils.createListOfAccountsWithCVRAndOwner(3);
        listOfAccounts.get(0).Name = 'Apple';
        listOfAccounts.get(1).Name = 'Pear';
        listOfAccounts.get(2).Name = 'Cucumber'; 
        insert listOfAccounts;
        
        ExecuteSOQL.Requests requests = new ExecuteSOQL.Requests();
        requests.soqlQuery = 'Select Id,Name From Account Order By Name';
               
        //ACT
        Test.startTest();
        List<ExecuteSOQL.Results> results = ExecuteSOQL.execute(new List<ExecuteSOQL.Requests>{requests});
        Test.stopTest();
        
        //ASSERT
        System.assertEquals(true, results[0].sObjects.size() == 3);
        List<Account> accounts = (List<Account>)results[0].sObjects;
        System.assertEquals('Apple', accounts[0].Name);
        System.assertEquals('Cucumber', accounts[1].Name);
        System.assertEquals('Pear', accounts[2].Name);
    }

    /**
     * execute_relationshipQuery_returnsCorrectResult
     */
    @isTest
    private static void execute_relationshipQuery_returnsCorrectResult() {
        //ARRANGE
        Account act = TDF_AccountUtils.creatActiveAccountWithCVRAndOwner(TEST_CVR);
        act.Name = 'Test1';
        insert act;

        Contact ct =  TDF_ContactUtils.createContact(act);
        insert ct;

        ExecuteSOQL.Requests requests = new ExecuteSOQL.Requests();
        requests.soqlQuery = 'Select Id, AccountId, Account.Name From Contact Where AccountId in (SELECT Id from Account WHERE Name in (\'Test1\', \'Test2\', \'Test3\')) ';

        //ACT
        Test.startTest();
        List<ExecuteSOQL.Results> results = ExecuteSOQL.execute(new List<ExecuteSOQL.Requests>{requests});
        Test.stopTest();

        //ASSERT
        System.assertEquals(1, results[0].sObjects.size());

        Contact returnedContact = (Contact) (results[0].sObjects[0]);
        System.assertEquals(ct.Id, returnedContact.Id);
        System.assertEquals(act.Id, returnedContact.AccountId);
        System.assertEquals('Test1', returnedContact.Account.Name);
    }
    
    /**
     * getFieldTypes_UnknownSObjectType_throwsCorrectException
     */
    @isTest
    private static void getFieldTypes_UnknownSObjectType_throwsCorrectException() {
        //ARRANGE
        String sObjectTypeName = 'theObjectThatMustNotBeNamed';
        String msg = '[ExecuteSOQLException Not Thrown for Unknown sObject Type]';

        //ACT
        Test.startTest();
        try {
            Map<String, String> results = ExecuteSOQL.getFieldTypes(sObjectTypeName, new List<String>());
        } catch (ExecuteSOQL.ExecuteSOQLException e) {
            msg = e.getMessage();
        }
        Test.stopTest();

        //ASSERT
        System.assertEquals('Unable to get sObject Type for name: '+ sObjectTypeName, msg);
    }

    /**
     * replaceWithFormattedValues_WithBadQueryString_throwsCorrectException
     */
    @isTest
    private static void replaceWithFormattedValues_WithBadQueryString_throwsCorrectException() {
        //ARRANGE
        String soqlQuery = 'DOES NOT COMPUTE WHERE SELECT FROM ';
        String msg = '[ExecuteSOQLException Not Thrown for Bad Query String]';

        //ACT
        Test.startTest();
        try {
            String result = ExecuteSOQL.replaceWithFormattedValues(soqlQuery);
        } catch (ExecuteSOQL.ExecuteSOQLException e) {
            msg = e.getMessage();
        }
        Test.stopTest();

        //ASSERT
        System.assertEquals('Unable to parse query string: ' + soqlQuery, msg);
    }

    /**
     * getFormattedValue_WithInteger_returnsCorrectValue
     */
    @isTest
    private static void getFormattedValue_WithInteger_returnsCorrectValue() {
        //ARRANGE
        String fieldvalue = '1';
        String fieldType = 'INTEGER';

        //ACT
        Test.startTest();
        String actualFieldvalue = ExecuteSOQL.getFormattedValue(fieldValue, fieldType);
        Test.stopTest();

        //ASSERT
        System.assertEquals(actualFieldvalue, fieldValue);
    }

    /**
     * execute_Bulkified_returnsCorrectResult
     */
    @isTest
    public static void execute_Bulkified_returnsCorrectResult() {
        //ARRANGE
        List<Account> accounts = TDF_AccountUtils.createListOfAccountsWithCVRAndOwner(11);    
        insert accounts;

        List<ExecuteSOQL.Requests> requestsList = new List<ExecuteSOQL.Requests>();
        ExecuteSOQL.Requests requests;
        for (Integer i=1; i <= accounts.size(); i++) {
            requests = new ExecuteSOQL.Requests();
            requests.soqlQuery = 'Select Id From Account Where Name LIKE \'Test _%\' LIMIT ' + String.valueOf(i);
            requestsList.add(requests);
        }
        
        //ACT
        Test.startTest();
        List<ExecuteSOQL.Results> resultsList = ExecuteSOQL.execute(requestsList);
        Test.stopTest();
        
        //ASSERT
        for (Integer i=0; i < resultsList.size(); i++) {
            ExecuteSOQL.Results results =resultsList[i];
            List<SObject> sObjects = results.sObjects;
        }
    }

    /**
     * getEligibleProducts_validRequest_returnsResult
     */
    @isTest
    public static void getEligibleProducts_validRequest_returnsResult() {
        //ARRANGE
        Account acc = TDF_AccountUtils.creatActiveAccountWithCVRAndOwner(TEST_CVR);
        insert acc;
        
        ExecuteSOQL.Requests requests = new ExecuteSOQL.Requests();
        requests.soqlQuery = 'Select Id From Account Where CreatedDate >= YESTERDAY';

        //ACT
        Test.startTest();
        List<ExecuteSOQL.Results> results = ExecuteSOQL.getEligibleProducts(new List<ExecuteSOQL.Requests>{
                requests
        });
        Test.stopTest();

        //ASSERT
        System.assertEquals(acc.Id, results[0].sObjects[0].Id);
    }
}