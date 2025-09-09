/**
 * @author Kenneth Houkjær
 * @date 27/07/2024
 * @description Test for the Document Management Client
 */
@isTest
public with sharing class DocumentManagementClientTest {
    private static final String API_NAME = 'DocumentManagementAPISettings';

    @isTest
    static void findDocuments_existingDocuments_returnsDocuments() {
        Mock documentClientMock = Mock.forType(DocumentManagementClient.class);
        MethodSpy findDocuments = documentClientMock.spyOn('findDocuments');
       
        List<DocumentManagementClient.Document> responseFromFindDocuments = new  List<DocumentManagementClient.Document>();
        DocumentManagementClient.Document doc = new DocumentManagementClient.Document();
        doc.id = '12345';
        responseFromFindDocuments.add(doc);

        findDocuments.whenCalledWith(Argument.any()).thenReturn(responseFromFindDocuments);

        DocumentManagementClient documentManagementClient = (DocumentManagementClient) documentClientMock.stub;
        DatabaseService dbMock = new DatabaseService().mockDMLs();
        DocumentManagementService service = new DocumentManagementService(documentManagementClient, dbMock);

        Map<String, Object> searchCriteria = new Map<String, Object>();
        searchCriteria.put('brand', 'teliadk');

        Test.startTest();
        List<DocumentManagementClient.Document> documents = DocumentManagementClient.findDocuments(searchCriteria);
        Test.stopTest();

        System.assertEquals(1, documents.size());
        System.assertEquals('12345', documents[0].id);
    }

    @isTest
    static void createDocument_validDocument_createsDocument() {
        Mock documentClientMock = Mock.forType(DocumentManagementClient.class);
        MethodSpy createDocument = documentClientMock.spyOn('createDocument');
       
        DocumentManagementClient.Document responseFromCreateDocument = new DocumentManagementClient.Document();
        responseFromCreateDocument.id = '12345';
        responseFromCreateDocument.type = 'Test';
        responseFromCreateDocument.name = 'Test Document';

        createDocument.whenCalledWith(Argument.any()).thenReturn(responseFromCreateDocument);

        DocumentManagementClient documentManagementClient = (DocumentManagementClient) documentClientMock.stub;
        DatabaseService dbMock = new DatabaseService().mockDMLs();
        DocumentManagementService service = new DocumentManagementService(documentManagementClient, dbMock);

        DocumentManagementClient.Document doc = new DocumentManagementClient.Document();
        doc.name = 'Test Document';
        doc.type = 'Test';

        Test.startTest();
        DocumentManagementClient.Document createdDoc = DocumentManagementClient.createDocument(doc);
        Test.stopTest();

        System.assertNotEquals(null, createdDoc);
        System.assertEquals('12345', createdDoc.id);
    }

    @isTest
    static void getDocument_existingDocumentId_returnsDocument() {
        Mock documentClientMock = Mock.forType(DocumentManagementClient.class);
        MethodSpy getDocument = documentClientMock.spyOn('getDocument');
       
        DocumentManagementClient.Document responseFromGetDocument = new DocumentManagementClient.Document();
        responseFromGetDocument.id = '12345';
        responseFromGetDocument.type = 'Test';
        responseFromGetDocument.name = 'Test Document';

        getDocument.whenCalledWith(Argument.any()).thenReturn(responseFromGetDocument);

        DocumentManagementClient documentManagementClient = (DocumentManagementClient) documentClientMock.stub;
        DatabaseService dbMock = new DatabaseService().mockDMLs();
        DocumentManagementService service = new DocumentManagementService(documentManagementClient, dbMock);

        Test.startTest();
        DocumentManagementClient.Document doc = DocumentManagementClient.getDocument('12345');
        Test.stopTest();

        System.assertNotEquals(null, doc);
        System.assertEquals('12345', doc.id);
    }

    @isTest
    static void deleteDocument_existingDocumentId_deletesDocument() {
        Mock documentClientMock = Mock.forType(DocumentManagementClient.class);
        MethodSpy deleteDocument = documentClientMock.spyOn('deleteDocument');
       
        Boolean responseFromDeleteDocument = true;

        deleteDocument.whenCalledWith(Argument.any()).thenReturn(responseFromDeleteDocument);

        DocumentManagementClient documentManagementClient = (DocumentManagementClient) documentClientMock.stub;
        DatabaseService dbMock = new DatabaseService().mockDMLs();
        DocumentManagementService service = new DocumentManagementService(documentManagementClient, dbMock);

        Test.startTest();
        Boolean result = DocumentManagementClient.deleteDocument('12345');
        Test.stopTest();

        System.assertEquals(true, result);
    }

    public class DocumentManagementMock implements HttpCalloutMock {
        private Integer statusCode;
        private String action;

        public DocumentManagementMock(Integer statusCode, String action) {
            this.statusCode = statusCode;
            this.action = action;
        }

        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(statusCode);

            if (action == 'findDocuments') {
                List<DocumentManagementClient.Document> docs = new List<DocumentManagementClient.Document>();
                DocumentManagementClient.Document doc = new DocumentManagementClient.Document();
                doc.id = '12345';
                docs.add(doc);
                res.setBody(JSON.serialize(docs));
            } else if (action == 'createDocument') {
                DocumentManagementClient.Document doc = new DocumentManagementClient.Document();
                doc.id = '12345';
                res.setBody(JSON.serialize(doc));
            } else if (action == 'getDocument') {
                DocumentManagementClient.Document doc = new DocumentManagementClient.Document();
                doc.id = '12345';
                res.setBody(JSON.serialize(doc));
            }

            return res;
        }
    }
}