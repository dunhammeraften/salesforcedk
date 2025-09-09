@isTest
public class DocumentStore_API_BulkTest {

    static testMethod void myTestMethod() {  
        // Create the mock response based on a static resource
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('DocumentStore_API_DataFetchResource');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
       
         test.starttest();
        Test.setMock(HttpCalloutMock.class, mock);
         DocumentStore_API_Bulk myClass = new DocumentStore_API_Bulk();   
         String chron = '0 0 23 * * ?';        
         system.schedule('Test Sched', chron, myClass);
         test.stopTest();
    }
    
}