public class ContentDocumentLinkService {

    public List<Id> getRelatedCasesByLinkedEntityIds(List<ContentDocumentLink> contentDocumentLinkList) {
		Logger.logInfo(String.format('getRelatedCasesByLinkedEntityIds( {0} )', new List<Object>{ contentDocumentLinkList }));
        List<Id> caseIds = new List<Id>();
		for (ContentDocumentLink contentDocumentLink : contentDocumentLinkList) {
			if (contentDocumentLink.LinkedEntityId != null && contentDocumentLink.LinkedEntityId.getSObjectType() == Case.sObjectType) {
				caseIds.add(contentDocumentLink.LinkedEntityId);
			}
		}
        return caseIds;
    }
}