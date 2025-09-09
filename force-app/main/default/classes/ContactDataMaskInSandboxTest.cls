@isTest
public class ContactDataMaskInSandboxTest { 
    static testMethod void testMethod1() 
    {
        List<Contact> listContact= new List<Contact>();
        for(Integer i=0 ;i <200;i++)
        {
            Contact con = new Contact();
            con.FirstName ='FName'+i;
            con.LastName = 'Lname';
            con.Phone = '19898988';
            con.MobilePhone = '17878898';
            con.Email = 'test@test.com';
            listContact.add(con);
        }
        
        insert listContact;
        
        Test.startTest();

            ContactDataMaskInSandbox obj = new ContactDataMaskInSandbox();
            DataBase.executeBatch(obj); 
            
        Test.stopTest();
    }
}