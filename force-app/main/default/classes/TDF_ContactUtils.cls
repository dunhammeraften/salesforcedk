@IsTest
public with sharing class TDF_ContactUtils {
    public static Contact createContact(Account acc){
        Contact con = new Contact(
            FirstName = 'Test',
            LastName = 'Contact',
            Email = 'tt@tt.dk',
            AccountId = acc.Id
        );

        return con; 
    }
}