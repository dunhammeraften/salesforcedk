/**
 * @author Kenneth Houkjær
 * @date 25/07/2024
 * @description Client for the Document Management API
 */
public with sharing class DocumentManagementClient extends HTTPClient {
    private static final String CLASS_NAME = 'DocumentManagementClient';
    private static final String API_NAME = 'DocumentManagementAPISettings';
    private static final String ENDPOINT = '/document';

    public DocumentManagementClient() {
        super(API_NAME);
    }

    /**
     * @description Finds documents based on the given search criteria
     * @param searchCriteria A map of search criteria
     * @return A list of documents
     */
    public List<Document> findDocuments(Map<String, Object> searchCriteria) {
        APISettings__mdt apiSettings = MetadataSelector.getAPISettings(API_NAME);
        String token = AuthorizationWrapper.getAPIToken(apiSettings);
        String endpoint = apiSettings.API_PartialEndPoint__c + ENDPOINT;
        String queryString = buildQueryString(searchCriteria);
        if (String.isNotBlank(queryString)) {
            endpoint += '?' + queryString;
        }

        Map<String, String> headers = new Map<String, String>{
            'Authorization' => 'Bearer ' + token,
            'Content-Type' => 'application/json'
        };

        HttpResponse response = HttpWrapper.get(endpoint, headers);

        if (response.getStatusCode() == 200) {
            return (List<Document>) JSON.deserialize(response.getBody(), List<Document>.class);
        } else {
            Logger.logError(CLASS_NAME, 'Failed to find documents. Status code: ' + response.getStatusCode() + ', body: ' + response.getBody());
            return null;
        }
    }

    /**
     * @description Creates a new document
     * @param doc The document to create
     * @return The created document
     */
    public Document createDocument(Document doc) {
        APISettings__mdt apiSettings = MetadataSelector.getAPISettings(API_NAME);
        String token = AuthorizationWrapper.getAPIToken(apiSettings);
        String endpoint = apiSettings.API_PartialEndPoint__c + ENDPOINT;

        Map<String, String> headers = new Map<String, String>{
            'Authorization' => 'Bearer ' + token,
            'Content-Type' => 'application/json'
        };

        String body = JSON.serialize(doc);
        HttpResponse response = HttpWrapper.post(endpoint, body, headers);

        if (response.getStatusCode() == 201) {
            return (Document) JSON.deserialize(response.getBody(), Document.class);
        } else {
            Logger.logError(CLASS_NAME, 'Failed to create document. Status code: ' + response.getStatusCode() + ', body: ' + response.getBody());
            return null;
        }
    }

    /**
     * @description Gets a document by its ID
     * @param documentId The ID of the document to get
     * @return The document
     */
    public Document getDocument(String documentId) {
        APISettings__mdt apiSettings = MetadataSelector.getAPISettings(API_NAME);
        String token = AuthorizationWrapper.getAPIToken(apiSettings);
        String endpoint = apiSettings.API_PartialEndPoint__c + ENDPOINT + '/' + documentId;

        Map<String, String> headers = new Map<String, String>{
            'Authorization' => 'Bearer ' + token,
            'Content-Type' => 'application/json'
        };

        HttpResponse response = HttpWrapper.get(endpoint, headers);

        if (response.getStatusCode() == 200) {
            return (Document) JSON.deserialize(response.getBody(), Document.class);
        } else {
            Logger.logError(CLASS_NAME, 'Failed to get document. Status code: ' + response.getStatusCode() + ', body: ' + response.getBody());
            return null;
        }
    }

    /**
     * @description Deletes a document by its ID
     * @param documentId The ID of the document to delete
     * @return True if the document was deleted successfully, false otherwise
     */
    public Boolean deleteDocument(String documentId) {
        APISettings__mdt apiSettings = MetadataSelector.getAPISettings(API_NAME);
        String token = AuthorizationWrapper.getAPIToken(apiSettings);
        String endpoint = apiSettings.API_PartialEndPoint__c + ENDPOINT + '/' + documentId;

        Map<String, String> headers = new Map<String, String>{
            'Authorization' => 'Bearer ' + token,
            'Content-Type' => 'application/json'
        };

        HttpResponse response = HttpWrapper.del(endpoint, headers);

        if (response.getStatusCode() == 204) {
            return true;
        } else {
            Logger.logError(CLASS_NAME, 'Failed to delete document. Status code: ' + response.getStatusCode() + ', body: ' + response.getBody());
            return false;
        }
    }

    /**
     * @description Builds a query string from a map of search criteria
     * @param searchCriteria A map of search criteria
     * @return A query string
     */
    private String buildQueryString(Map<String, Object> searchCriteria) {
        if (searchCriteria == null || searchCriteria.isEmpty()) {
            return '';
        }

        List<String> params = new List<String>();
        for (String key : searchCriteria.keySet()) {
            params.add(key + '=' + String.valueOf(searchCriteria.get(key)));
        }

        return String.join(params, '&');
    }

    /**
     * @description A wrapper class for the Document object
     */
    public class Document {
        public String id;
        public String href;
        public String type;
        public String name;
        public String description;
        public String lifecycleState;
        public String version;
        public Datetime creationDate;
        public Datetime lastUpdate;
        public List<DocumentCharacteristic> documentCharacteristic;
        public List<RelatedPartyRef> relatedParty;
        public DocumentSpecification documentSpecification;
        public List<Attachment> attachment;
        public List<CategoryRef> category;
        public List<DocumentRelationship> documentRelationship;
        public RelatedObject relatedObject;
        public DocumentAttributes documentAttributes;
        public Boolean signatureRequired;
        public Boolean signatureMissing;
        public Boolean uniqueSignatureRequired;
        public Boolean signed;
        public List<Signature> signatures;
    }

    public class DocumentCharacteristic {
        public String name;
        public String value;
    }

    public class RelatedPartyRef {
        public String id;
        public String href;
        public String role;
        public String name;
        public TimePeriod validFor;
    }

    public class DocumentSpecification {
        public String id;
        public String name;
        public String version;
        public String href;
        public String url;
    }

    public class Attachment {
        public String id;
        public String href;
        public String name;
        public String description;
        public String type;
        public String mimeType;
        public Decimal size;
        public String sizeUnit;
        public String url;
        public TimePeriod validFor;
    }

    public class CategoryRef {
        public String id;
        public String href;
        public String version;
        public String name;
    }

    public class DocumentRelationship {
        public String type;
        public DocumentRef document;
    }

    public class RelatedObject {
        public String involvement;
        public String reference;
    }

    public class TimePeriod {
        public Datetime startDateTime;
        public Datetime endDateTime;
    }

    public class DocumentRef {
        public String id;
        public String href;
    }

    public class Signature {
        public String name;
        public String signatureHolder;
        public Boolean required;
        public Boolean signed;
        public Datetime signedDate;
        public SignatureValue value;
    }

    public class SignatureValue {
        public String image;
        public String text;
    }

    public class DocumentAttributes {
        public String type;
    }
}