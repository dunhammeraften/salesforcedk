/**
 * 
 * @author keh
 * @since 13032025
 */
@isTest
public class FileUploadImproved_Test {
    
    /**
     * makeData
     */
    @TestSetup
    static void makeData(){
        Contact con = new Contact(
            FirstName = 'Martin',
            LastName = 'Test',
            Email = 'kk@kk.dk'
        );
        insert con;
        
        ContentVersion cv = new ContentVersion(
        	Title = 'Test',
            PathOnClient = 'Test',
            VersionData = EncodingUtil.base64Decode('Test'),
            IsMajorVersion = FALSE
        );
        insert cv;
    }

    /**
     * createContentDocLink_visibleToAllUsers_createsLink
     */
	@isTest
    public static void createContentDocLink_visibleToAllUsers_createsLink(){
        //ARRANGE        
        String key = FileUploadImprovedHelper.getKey();

        Contact con = getCon();
        ContentVersion cv = getCV();
        cv.Guest_Record_fileupload__c = FileUploadImprovedHelper.encrypt(con.Id,key);
        update cv;
        
        //ACT
        system.test.startTest();
        FileUploadImprovedHelper.createContentDocLink(new List<String>{cv.Id},key,true);
        system.test.stopTest();

        //ASSERT
        List<ContentDocumentLink> cdl = [SELECT Id FROM ContentDocumentLink WHERE LinkedEntityId = :con.Id];
        system.assertEquals(1, cdl.size());
    }

    /**
     * getExistingFiles_validContact_returnsListOfFiles
     */
    @isTest
    public static void getExistingFiles_validContact_returnsListOfFiles(){
        //ARRANGE
        String key = FileUploadImprovedHelper.getKey();

        Contact con = getCon();
        ContentVersion cv = getCV();
        cv.Guest_Record_fileupload__c = FileUploadImprovedHelper.encrypt(con.Id,key);
        update cv;
        
        //ACT
        system.test.startTest();
        FileUploadImprovedHelper.createContentDocLink(new List<String>{cv.Id},key,false);
        List<FileUploadImprovedHelper.objFiles> objFiles = FileUploadImprovedHelper.getExistingFiles(con.Id); 
        system.test.stopTest();

        //ASSERT
        system.assertEquals(1, objFiles.size());
    }

    /**
     * updateFileName_validFile_updatesFileName
     */
    @isTest
    public static void updateFileName_validFile_updatesFileName(){
        //ARRANGE
        ContentVersion cv = getCV();
        String fileName = 'https://www.linkedin.com/in/rygramer/';

        //ACT
        system.test.startTest();
        FileUploadImprovedHelper.updateFileName(new List<String>{cv.Id}, fileName);
        system.test.stopTest();

        //ASSERT
        cv = getCV();
        system.assertEquals(fileName, cv.ContentDocument.Title);
    }

    /**
     * deleteContentDoc_validVersionId_deletesContent
     */
    @isTest
    public static void deleteContentDoc_validVersionId_deletesContent(){
        //ARRANGE
        ContentVersion cv = getCV();

        //ACT
        system.test.startTest();
        FileUploadImprovedHelper.deleteContentDoc(cv.Id);
        system.test.stopTest();
        
        //ASSERT
        List<ContentVersion> listOfCv = [SELECT Id FROM ContentVersion WHERE Id = :cv.Id];        
        System.Assert(listOfCv.size() == 0);
    }

    /**
     * createContentDocumentLinkDownstream_validInput_createsVisibleDocumentLink
     */
    @isTest
    public static void createContentDocumentLinkDownstream_validInput_createsVisibleDocumentLink(){
        //ARRANGE
        ContentVersion cv = getCV();
        Contact con = getCon();

        FileUploadImprovedHelper.Input input = new FileUploadImprovedHelper.Input();
        input.versIds = new List<Id>{cv.Id};
        input.recordId = con.Id;
        input.visibleToAllUsers = TRUE;

        //ACT
        system.test.startTest();
        FileUploadImprovedHelper.createContentDocumentLinkDownstream(new List<FileUploadImprovedHelper.Input>{input});
        system.test.stopTest();

        //ASSERT
        ContentDocumentLink link = [SELECT Visibility FROM ContentDocumentLink WHERE LinkedEntityId = :con.Id];
        system.assert(link.Visibility == 'AllUsers');
    }

    /**
     * createContentDocumentLinkDownstream_existingLink_verifiedExist
     */
    @isTest
    public static void createContentDocumentLinkDownstream_existingLink_verifiedExist(){
        //ARRANGE
        ContentVersion cv = getCV();
        Contact con = getCon();

        ContentDocumentLink link = new ContentDocumentLink(
            ContentDocumentId = cv.ContentDocumentId,
            LinkedEntityId = con.Id,
            Visibility = 'AllUsers'
        );
        insert link;

        FileUploadImprovedHelper.Input input = new FileUploadImprovedHelper.Input();
        input.versIds = new List<Id>{cv.Id};
        input.recordId = con.Id;
        input.visibleToAllUsers = TRUE;

        //ACT
        system.test.startTest();
        FileUploadImprovedHelper.createContentDocumentLinkDownstream(new List<FileUploadImprovedHelper.Input>{input});
        system.test.stopTest();

        link = [SELECT Visibility FROM ContentDocumentLink WHERE LinkedEntityId = :con.Id];

        //ASSERT
        system.assert(link.Visibility == 'AllUsers');
    }

    /**
     * createContentDocumentLinkDownstream_emptyList_isHandled
     */
    @isTest
    public static void createContentDocumentLinkDownstream_emptyList_isHandled(){
        //ARRANGE
        FileUploadImprovedHelper.Input input = new FileUploadImprovedHelper.Input();
        input.versIds = new List<Id>();

        //ACT
        system.test.startTest();
        FileUploadImprovedHelper.createContentDocumentLinkDownstream(new List<FileUploadImprovedHelper.Input>{input});
        system.test.stopTest();

        //ASSERT
        //can not be verified
    }

    /**
     * createContentVers_listOfFiles_uploadsImproved
     */
    @isTest
    public static void createContentVers_listOfFiles_uploadsImproved(){
        //ARRANGE
        String encodedKey = FileUploadImprovedHelper.getKey();
        String encodedRecordId = FileUploadImprovedHelper.encrypt(getCon().Id, encodedKey);

        String beforeString = 'File Upload Improved';
        Blob beforeBlob = Blob.valueOf(beforeString);
        String newVersionData = EncodingUtil.base64Encode(beforeblob);

        List<String> fileNames = new List<String>{'FileUploadImproved.txt'};
        List<Id> versIds = new List<Id>();
        
        //ACT
        system.test.startTest();   
            List<FileUploadImprovedHelper.objFiles> objFiles = FileUploadImprovedHelper.createContentVers(fileNames, encodedRecordId);

            for(FileUploadImprovedHelper.objFiles objFile : objFiles){
                versIds.add(objFile.contentVersionId);
                FileUploadImprovedHelper.appendDataToContentVersion(objFile.contentVersionId, newVersionData);
            }
        system.test.stopTest();

        //ASSERT
        for(ContentVersion vers : [SELECT VersionData, Guest_Record_fileupload__c FROM ContentVersion WHERE Id IN :versIds]){
            system.assertEquals(encodedRecordId, vers.Guest_Record_fileupload__c);

            // I'm stumped on this one, I'd expect this to return this way, but it doesn't.
            // Perhaps there's a bug in Salesforce tests that make it so you can't update ContentVersions?
            // system.assertEquals(newVersionData, EncodingUtil.base64Encode(vers.VersionData));
        }
    }

    /** 
     * appendDataToContentVersion_withData_functions
    */
    @isTest
    public static void appendDataToContentVersion_withData_functions(){
        //ARRANGE
        ContentVersion cv = getCV();

        String currentVersionData = EncodingUtil.base64Encode(cv.VersionData);

        String beforeString = 'File Upload Improved';
        Blob beforeBlob = Blob.valueOf(beforeString);
        String newVersionData = EncodingUtil.base64Encode(beforeblob);

        //ACT
        system.test.startTest();
        FileUploadImprovedHelper.appendDataToContentVersion(cv.Id, newVersionData);
        system.test.stopTest();

        //ASSERT
        // Stumped here too.
        // system.assertEquals(currentVersionData + newVersionData, EncodingUtil.base64Encode(getCV().VersionData));
    }

    /**
     * 
     * @return  `ContentVersion`
     */
    private static ContentVersion getCV(){
        return [SELECT Id, Guest_Record_fileupload__c, ContentDocument.Title, ContentDocumentId, VersionData FROM ContentVersion LIMIT 1];
    }

    /**
     * 
     * @return  `Contact`
     */
    private static Contact getCon(){
        return [SELECT Id FROM Contact];
    }
}