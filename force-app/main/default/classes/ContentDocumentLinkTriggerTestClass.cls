@IsTest
Public class ContentDocumentLinkTriggerTestClass {
    
    static testmethod void testmethod1(){
        Test.startTest();
        Account accA =new Account(Name='Test', Rationale__c = 'Test Account', CVR__c = '12345678');
        insert accA ; 

        Case cs = New Case(AccountId = AccA.Id, Awaiting_user__c = true,Priority = 'Medium',
                    Status = 'New', Origin = 'Internal Support', subject = 'Test Case');
        insert cs;
        
        ContentVersion content=new ContentVersion(); 
        content.Title='Header_Picture1'; 
        content.PathOnClient='/' + content.Title + '.jpg'; 
        Blob bodyBlob=Blob.valueOf('Unit Test ContentVersion Body'); 
        content.VersionData=bodyBlob; 
        //content.LinkedEntityId=sub.id;
        content.origin = 'H';
        insert content;
        ContentDocumentLink contentlink=new ContentDocumentLink();
        contentlink.LinkedEntityId=cs.id;
        contentlink.contentdocumentid=[select contentdocumentid from contentversion where id =: content.id].contentdocumentid;
        contentlink.ShareType = 'I';
        contentlink.Visibility = 'AllUsers'; 
        
        
        insert contentlink;
        Test.stopTest();
        
    }
}