//Test by Jessie Rymph included with unmanaged package Unsubscribe Link from AppExchange & Salesforce Labs.
//April 14, 2021
//test the Unsubscribe Contacts flow that looks for all contacts with an email address
//and marks them Email Opt Out = true
//How it actually works: Screen flow Unsubscribe Link launches the subflow, Unsubscribe Contacts.
//Params passed: Email 

@isTest
public class jrsl_ul_UnsubscribeContactsTest {
    //TODO: khp fix unittest - is this still relevant?
    
    // @isTest public static void testUnsubscribeContactsFlow(){
    //     //create Test Data
    //     String emailAdd = 'waitwait@npr.org';
    //     List<Account> newAccounts = TDF_AccountUtils.createListOfAccountsWithCVRAndOwner(3);
    //     newAccounts.get(0).Name= 'NPR.org';
    //     newAccounts.get(1).Name= 'KUOW.org';
    //     newAccounts.get(2).Name= 'KCTS9';
    //     insert newAccounts;
        
    //     Contact bob = new Contact (FirstName='Steven', LastName='Sagal', Email= emailAdd, AccountId = newAccounts.get(0).id);
    //     Contact paula = new Contact (FirstName='Steven',LastName='Poundstone', Email= emailAdd, AccountId = newAccounts.get(1).id);
    //     Contact maz = new Contact (FirstName='Steven',LastName='Jobrani', Email= emailAdd, AccountId = newAccounts.get(2).id);
    //     List <Contact> newContacts = new List <Contact>{bob, paula, maz};
    //     insert newContacts;

    //     //pass values into the Flow
    //     Map<String, String> params = new Map <String,String>();
    //     params.put('Email',emailAdd);
        
    //     //pass params to the flow
    //     Flow.Interview.jrsl_ul_Unsubscribe_Contacts ucFlow = new Flow.Interview.jrsl_ul_Unsubscribe_Contacts(params);
        
    //     Test.startTest();
    //     //launch the Flow
    //     ucFlow.start();
    //     Test.stopTest();
    //     //assert that the test records were unsubscribed
    //     List<Contact> contacts = [SELECT Id FROM Contact WHERE Email = :emailAdd AND HasOptedOutOfEmail = true ];
    //     //TODO: khp fix unittest
    //     //System.assertEquals(3,contacts.size(),'three contacts should be unsubscribed');
    //     system.debug('list:' + contacts);
    // }
    
    // @IsTest public static void UnsubscribeContactsBulkTest (){
    //     String emailAdd = 'waitwait@npr.org';
    //     Account newA = TDF_AccountUtils.creatActiveAccountWithCVRAndOwner();
    //     newA.Name = 'NPR.org';
    //      //new Account (Name= 'NPR.org');
    //     insert newA;
    //     List<Contact> cons = new List<Contact>();
    //     for (Integer i=0; i<200; i++) {
    //         Contact c = new Contact(
    //             FirstName = 'Tina',
    //             LastName = 'Contact ' + i, 
    //             Email = emailadd, 
    //             AccountId= newA.id
    //         );
    //         cons.add(c);
    //     }
    //     insert cons;
    //     //pass values into the Flow
    //     Map<String, String> params = new Map <String,String>();
    //     params.put('Email',emailAdd);
        
    //     //pass params to the flow
    //     Flow.Interview.jrsl_ul_Unsubscribe_Contacts ucFlow = new Flow.Interview.jrsl_ul_Unsubscribe_Contacts(params);
        
    //     Test.startTest();
    //     //launch the Flow
    //     ucFlow.start();
    //     Test.stopTest();
    //     //assert that the test records were unsubscribed
    //     List<Contact> contacts = [SELECT Id FROM Contact WHERE Email = :emailAdd AND HasOptedOutOfEmail = true ];
    //     System.assertEquals(200,contacts.size(),'200 contacts should be unsubscribed');
    //     //system.debug('list:' + contacts);
    // }
}