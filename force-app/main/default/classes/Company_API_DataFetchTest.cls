@isTest
public class Company_API_DataFetchTest {
@isTest static  void testGetCallout() {
        // Create the mock response based on a static resource
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('Company_API_DataFetchResource');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
        // Associate the callout with a mock response
        Test.setMock(HttpCalloutMock.class, mock);
    
        Account acct = new Account(Name='TestAccount', BillingCity='CP',BillingPostalCode = '2000',BillingCountry = 'DK'
                                           ,BillingStreet = 'Holmbladsgade 133', Phone = '111', CVR__c ='38110020');
        insert acct;
    
    	Set<Id> Ids = new Set<Id>();
    	Ids.add(acct.Id);
    
    	// Call method to test
        Company_API_DataFetch.FetchData(Ids); 
    
        lead ld = new Lead(LastName = 'Demir', Company = 'Demir', City='CP',PostalCode = '2000',Country = 'DK'
                                           ,Street = 'Holmbladsgade 133', CVR__c ='38110020');
        insert ld;
    
        Ids = new Set<Id>();
    	Ids.add(ld.Id);
    
    
        // Call method to test
        Company_API_DataFetch.FetchLeadData(Ids);        
    }
}