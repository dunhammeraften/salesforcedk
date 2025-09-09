/**
 * @author Kenneth Houkjær
 * @date 25/07/2024
 * @description A service class for the Document Management API
 */
public with sharing class DocumentManagementService {
    private final DocumentManagementClient documentManagementClient;
    private final DatabaseService databaseService;

     public DocumentManagementService() {
        this(SingletonFactory.getFactory());
    }

    private DocumentManagementService(SingletonFactory singletonFactory) {
        this.documentManagementClient = (DocumentManagementClient) singletonFactory.getOrRegisterSingleton(DocumentManagementClient.class);
        this.databaseService = (DatabaseService) singletonFactory.getOrRegisterSingleton(DatabaseService.class);
    }

    @TestVisible
    private DocumentManagementService(DocumentManagementClient documentManagementClient, DatabaseService databaseService) {
        this.documentManagementClient = documentManagementClient;
        this.databaseService = databaseService;
    }

    /**
     * @description Finds documents based on the given search criteria
     * @param searchCriteria A map of search criteria
     * @return A list of documents
     */
    public List<DocumentManagementClient.Document> findDocuments(Map<String, Object> searchCriteria) {
        return DocumentManagementClient.findDocuments(searchCriteria);
    }

    /**
     * @description Creates a new document
     * @param doc The document to create
     * @return The created document
     */
    public DocumentManagementClient.Document createDocument(DocumentManagementClient.Document doc) {
        return DocumentManagementClient.createDocument(doc);
    }

    /**
     * @description Gets a document by its ID
     * @param documentId The ID of the document to get
     * @return The document
     */
    public DocumentManagementClient.Document getDocument(String documentId) {
        return DocumentManagementClient.getDocument(documentId);
    }

    /**
     * @description Deletes a document by its ID
     * @param documentId The ID of the document to delete
     * @return True if the document was deleted successfully, false otherwise
     */
    public Boolean deleteDocument(String documentId) {
        return DocumentManagementClient.deleteDocument(documentId);
    }
}