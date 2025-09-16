public with sharing class NorlysNowService {
    private final NorlysNowSelector norlysNowSelector;
    
    public NorlysNowService() {
        this(SingletonFactory.getFactory());
    }

    private NorlysNowService(SingletonFactory singletonFactory) {
        this.norlysNowSelector = (NorlysNowSelector) singletonFactory.getOrRegisterSingleton(NorlysNowSelector.class);
    }
    
    public NorlysNowClientRequestDTO createCaseCommentRequestObject(
        String correlationId,
        String externalAction,
        String externalReference,
        String messageType,
        String integrationMode,
        String integrationPartner,
        String salesforceId,
        String commentBody
    ) {
        Logger.logInfo(
            String.format(
                'createCaseRequestObject( {0}, {1}, {2}, {3}, {4}, {5}, {6}, {7} )',
                new List<Object>{
                    correlationId, externalAction, externalReference, messageType, integrationMode,
                    integrationPartner, salesforceId, commentBody
                }
            )
        );

        NorlysNowClientRequestDTO requestObject = new NorlysNowClientRequestDTO();
        requestObject.correlation_id = correlationId;
        requestObject.external_action = externalAction;
        requestObject.external_reference = externalReference;
        requestObject.message_type = messageType;
        requestObject.integrationmode = integrationMode;
        requestObject.integrationPartner = integrationPartner;

        requestObject.payload = new NorlysNowClientRequestDTO.Payload();
        requestObject.payload.salesforceId = salesforceId;
        requestObject.payload.comment = commentBody;

        return requestObject;
    }

    public NorlysNowClientRequestDTO createCaseRequestObject(
        String correlationId,
        String externalAction,
        String externalReference,
        String messageType,
        String integrationMode,
        String integrationPartner,
        String salesforceId,
        String commentBody,
        String priority,
        String description,
        String title,
        String type,
        String status,
        String requestSource,
        String category,
        String technologyType,
        String technology,
        String oneWorkFlowId
    ) {
        Logger.logInfo(
                String.format(
                    'createCaseRequestObject( {0}, {1}, {2}, {3}, {4}, {5}, {6}, {7}, {8}, {9}, {10}, {11}, {12}, {13}, {14}, {15}, {16} )',
                    new List<Object>{
                        correlationId, externalAction, externalReference, messageType, integrationMode,
                        integrationPartner, salesforceId, commentBody, priority, description, title, type,
                        status, requestSource, category, technologyType, technology, oneWorkFlowId
                    }
                )
            );
        
        NorlysNowClientRequestDTO requestObject = new NorlysNowClientRequestDTO();
        requestObject.correlation_id = correlationId;
        requestObject.external_action = externalAction;
        requestObject.external_reference = externalReference;
        requestObject.message_type = messageType;
        requestObject.integrationmode = integrationMode;
        requestObject.integrationPartner = integrationPartner;

        requestObject.payload = new NorlysNowClientRequestDTO.Payload();
        requestObject.payload.salesforceId = salesforceId;
        requestObject.payload.comment = commentBody;
        requestObject.payload.priority = priority;
        requestObject.payload.description = description;
        requestObject.payload.title = title;
        requestObject.payload.type = type;
        requestObject.payload.status = status;
        requestObject.payload.requestSource = requestSource;
        requestObject.payload.category = category;
        requestObject.payload.technologyType = technologyType;
        requestObject.payload.technology = technology;
        requestObject.payload.oneWorkFlowId = oneWorkFlowId;

        return requestObject;
    }

    public NorlysNowClientRequestDTO createFileRequestObject(
        String correlationId,
        String externalAction,
        String externalReference,
        String messageType,
        String integrationMode,
        String integrationPartner,
        String salesforceId,
        String fileData,
        String fileName
    ) {
        Logger.logInfo(
            String.format(
                'createFileRequestObject( {0}, {1}, {2}, {3}, {4}, {5}, {6}, {7} , {8})',
                new List<Object>{
                    correlationId, externalAction, externalReference, messageType, integrationMode,
                    integrationPartner, salesforceId, fileData, fileName
                }
            )
        );

        NorlysNowClientRequestDTO requestObject = new NorlysNowClientRequestDTO();
        requestObject.correlation_id = correlationId;
        requestObject.external_action = externalAction;
        requestObject.external_reference = externalReference;
        requestObject.message_type = messageType;
        requestObject.integrationmode = integrationMode;
        requestObject.integrationPartner = integrationPartner;

        requestObject.payload = new NorlysNowClientRequestDTO.Payload();
        requestObject.payload.salesforceId = salesforceId;
        requestObject.payload.fileData = fileData;
        requestObject.payload.fileName = fileName;

        return requestObject;
    }
    
    public NorlysNow_Case__c setSuccessOnNorlysNowCase(NorlysNow_Case__c norlysNowCase) {
        Logger.logInfo(String.format('setSuccessOnNorlysNowCase( {0} )', new List<Object>{ norlysNowCase }));
        if (norlysNowCase == null) {
            Logger.logError('norlysNowCase is null.');
            return null;
        }

        norlysNowCase.Sync_Status__c = 'Success';
        
        return norlysNowCase;
    }

    public NorlysNow_Case__c setErrorOnNorlysNowCase(NorlysNow_Case__c norlysNowCase, String errorMessage) {
        Logger.logInfo(String.format('setErrorOnNorlysNowCase( {0}, {1} )', new List<Object>{ norlysNowCase, errorMessage }));
        if (norlysNowCase == null) {
            Logger.logError('norlysNowCase is null. Cannot set error: ' + errorMessage);
            return null;
        }
        
        norlysNowCase.Sync_Status__c = 'Error';
        norlysNowCase.Sync_Message__c = errorMessage;
        
        return norlysNowCase;
    }

    public Parameters getParameters(String parametersJson) {
        Logger.logInfo(String.format('getParameters( {0} )', new List<Object>{ parametersJson }));
        Parameters params = (Parameters) System.JSON.deserialize(parametersJson, NorlysNowService.Parameters.class);
        return params;
    }
    
    public class Parameters {
        public String type;
        public Set<Id> recordIds;
    }

    // ContentDocumentLink/File related methods
    public Map<Id, ContentVersion> getFileIdToVersion(Set<Id> fileIds) {
        Logger.logInfo(String.format('getFileIdToVersion( {0} )', new List<Object>{ fileIds }));

        Map<Id, ContentVersion> fileIdToVersion = new Map<Id, ContentVersion>();
         List<ContentVersion> cvList = norlysNowSelector.getContentVersions(fileIds);
        for (ContentVersion cv : cvList) {
            fileIdToVersion.put(cv.ContentDocumentId, cv);
        }
        return fileIdToVersion;
    }

    //Task related methods
    public void createFollowUpTasks(List<NorlysNow_Case__c> norlysNowCases, String subject, String description, Date dueDate) {
        Logger.logInfo(String.format('createFollowUpTasks( {0}, {1}, {2}, {3})', new List<Object>{ norlysNowCases, subject, description, dueDate }));

        Map<Id, NorlysNow_Case__c> caseMap = new Map<Id, NorlysNow_Case__c>(norlysNowcases);       

        Set<Id> ownerIds = new Set<Id>();
        for (NorlysNow_Case__c nc : norlysNowcases) {
            ownerIds.add(nc.CreatedBy.Id);
        }

        Map<Id, User> ownerUserMap = new Map<Id, User>();
        if (!ownerIds.isEmpty()) {
            for (User u : norlysNowSelector.getUsers(ownerIds)) {
                ownerUserMap.put(u.Id, u);
            }
        }

        List<Task> tasks = new List<Task>();
        for (NorlysNow_Case__c nc : norlysNowcases) {
            Task t = createTask(nc, subject, description, dueDate);
            tasks.add(t);
        }

        if (tasks.isEmpty()) return;

        insert tasks;

        CustomNotificationType notifType = norlysNowSelector.getCustomNotificationType('New_Task_on_NorlysNow_Case');

        List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();

        OrgWideEmailAddress owe = norlysNowSelector.getOrgWideEmailAddress('noreply.mobil@norlys.dk');

        for (Task t : tasks) {
            NorlysNow_Case__c nc = caseMap.get(t.WhatId);
            if (nc == null) continue;

            sendCustomNotification(t, notifType, nc.CreatedBy.Id);

            User ownerUser = ownerUserMap.get(nc.CreatedBy.Id);

            Messaging.SingleEmailMessage mail = buildOwnerEmail(t, ownerUser, nc, owe);
            emailsToSend.add(mail);
           
        }

        try {
            if (!emailsToSend.isEmpty()) {
                Messaging.sendEmail(emailsToSend);
            }
        } catch (System.EmailException e) {
            Logger.logError('Could not send email: ' + e.getMessage());
        }
    }

    public Task createTask(NorlysNow_Case__c nc, String subject, String description, Date dueDate) {
        Logger.logInfo(String.format('createTask( {0}, {1}, {2}, {3})', new List<Object>{ nc, subject, description, dueDate }));

        Task t = new Task();
        t.WhatId = nc.Id;
        t.OwnerId = nc.CreatedBy.Id;
        t.Subject = subject;
        t.Description = description;
        t.Status = 'Not Started';
        t.Priority = 'Normal';
        t.ActivityDate = (dueDate != null) ? dueDate : Date.today().addDays(1);
        return t;
    }

    public void sendCustomNotification(Task task, CustomNotificationType notifType, Id userId) {
        Logger.logInfo(String.format('sendCustomNotification( {0}, {1}, {2} )', new List<Object>{ task, notifType, userId }));

        if (task == null || notifType == null || userId == null) return;

        Messaging.CustomNotification cn = new Messaging.CustomNotification();
        cn.setTitle('New task created: ' + task.Subject);
        cn.setBody('A new Task has been created on case: ' + String.valueOf(task.WhatId));
        cn.setNotificationTypeId(notifType.Id);
        cn.setTargetId(task.Id);

        cn.send(new Set<String>{ (String)userId });
    }
    
    public Messaging.SingleEmailMessage buildOwnerEmail(Task task, User u, NorlysNow_Case__c nc, OrgWideEmailAddress owe) {
        Logger.logInfo(String.format('buildOwnerEmail( {0}, {1}, {2} )', new List<Object>{ task, u, nc }));

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        if (u == null || String.isBlank(u.Email)) return mail;

        mail.setToAddresses(new List<String>{ u.Email });
        String caseName = (nc != null && nc.Name != null) ? nc.Name : String.valueOf(task.WhatId);
        mail.setSubject('New task created on case: ' + caseName);
        mail.setOrgWideEmailAddressId(owe.Id);

        String body = 'Hi ' + (u.Name != null ? u.Name : '') + ',\n\n' +
            'A new Task has been created on the following record: ' + caseName + '\n' +
            'Subject: ' + task.Subject + '\n' +
            'Deadline: ' + String.valueOf(task.ActivityDate) + '\n\n' +
            'Please check your tasks.\n\nRegards';
        mail.setPlainTextBody(body);

        return mail;
    }

    public List<Case> closeParentCases(List<NorlysNow_Case__c> ncList) {
        Logger.logInfo(String.format('closeParentCase( {0} )', new List<Object>{ ncList }));

        // Find parent case Id'er for de NorlysNow_Case__c vi har fået ind
        Set<Id> parentCaseIds = new Set<Id>();
        for (NorlysNow_Case__c nc : ncList) {
            if (nc.Status__c == 'Closed'){
                parentCaseIds.add(nc.Parent_Case__c);
            }
        }

        if (parentCaseIds.isEmpty()) {
            return new List<Case>();
        }

        // Hent ALLE child NorlysNow_Case__c for disse parent cases
        Map<Id, List<NorlysNow_Case__c>> parentIdToChildren = new Map<Id, List<NorlysNow_Case__c>>();
        for (NorlysNow_Case__c nc : norlysNowSelector.getAllNorlysNowCasesUnderParentCases(parentCaseIds)) {
            if (!parentIdToChildren.containsKey(nc.Parent_Case__c)) {
                parentIdToChildren.put(nc.Parent_Case__c, new List<NorlysNow_Case__c>());
            }
            parentIdToChildren.get(nc.Parent_Case__c).add(nc);
        }

        // Tjek om alle child records er færdige
        List<Case> parentCasesToClose = new List<Case>();
        for (Id parentCaseId : parentIdToChildren.keySet()) {
            Boolean allDone = true;
            for (NorlysNow_Case__c child : parentIdToChildren.get(parentCaseId)) {
                if (child.Status__c != 'Closed') {
                    allDone = false;
                    break;
                }
            }

            if (allDone) {
                parentCasesToClose.add(new Case(
                    Id = parentCaseId, 
                    Status = 'Closed'
                ));
            }
        }

        return parentCasesToClose;
    }

    public void CheckParentCaseIsClosed(List<NorlysNow_Case__c> ncList) {
        // Collect all parent case Ids from  Trigger.new
        Set<Id> parentCaseIds = new Set<Id>();
        for (NorlysNow_Case__c nnc : ncList) {
            if (nnc.Parent_Case__c != null) {
                parentCaseIds.add(nnc.Parent_Case__c);
            }
        }
        // Get parent cases which are closed
        Map<Id, Case> closedParentCases = norlysNowSelector.getCasesByIds(parentCaseIds);

        // For each NorlysNow Case Checkparent case is closed
        for (NorlysNow_Case__c nnc : ncList) {
            if (closedParentCases.containsKey(nnc.Parent_Case__c)) {
                nnc.addError('You are not allowed to create or update NorlysNow Cases on a closed Case');
            }
        }
    }

    public List<EventExecutor__e> chunkEventsInListsToBePublished(List<Id> toBeSentIds, String objectType, String executorType){
        // Create three lists of string
        List<List<Id>> chunked = (List<List<Id>>) orgUtils.chunkListOfStrings(100, toBeSentIds, List<List<Id>>.class);
        List<EventExecutor__e> eventList = new List<EventExecutor__e>();
        for(List<Id> iterationList : chunked) {
            NorlysNowService.Parameters params = new NorlysNowService.Parameters();
            params.type = objectType; // Specify the type for the strategy
            params.recordIds = new Set<Id>(iterationList);
            String paramsJson = JSON.serialize(params);
            
            eventList.add(new EventExecutor__e(
                Executor__c = executorType,
                Parameters__c = paramsJson
            ));
        }

        return eventList;
    }

}