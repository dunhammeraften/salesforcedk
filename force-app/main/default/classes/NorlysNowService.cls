/**
 * @description This service class contains business logic related to the Norlys Now integration.
 *              It provides methods for creating request objects, managing cases, creating tasks,
 *              and handling platform events.
 *
 * -----------------------------------------------------------------------------
 * @author Developer           Date            Description
 * -----------------------------------------------------------------------------
 * @author Esben Hovgaard        18/09/2025      Class, method and inline documentation
 * -----------------------------------------------------------------------------
 */
public with sharing class NorlysNowService {
	private final NorlysNowSelector norlysNowSelector;

	/**
	 * @description Default constructor that initializes the required services using the SingletonFactory.
	 */
	public NorlysNowService() {
		this(SingletonFactory.getFactory());
	}

	/**
	 * @description Private constructor for dependency injection.
	 * @param singletonFactory The SingletonFactory instance to use for creating dependencies.
	 */
	private NorlysNowService(SingletonFactory singletonFactory) {
		this.norlysNowSelector = (NorlysNowSelector) singletonFactory.getOrRegisterSingleton(NorlysNowSelector.class);
	}

	/**
	 * @description Creates a request object for sending a case comment to Norlys Now.
	 * @param correlationId A unique ID for tracking.
	 * @param externalAction The action to be performed.
	 * @param externalReference An external reference ID.
	 * @param messageType The type of message.
	 * @param integrationMode The integration mode.
	 * @param integrationPartner The integration partner.
	 * @param salesforceId The Salesforce ID of the related record.
	 * @param commentBody The body of the comment.
	 * @return A configured NorlysNowClientRequestDTO object.
	 */
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
					correlationId,
					externalAction,
					externalReference,
					messageType,
					integrationMode,
					integrationPartner,
					salesforceId,
					commentBody
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

	/**
	 * @description Creates a comprehensive request object for sending a case to Norlys Now.
	 * @param correlationId A unique ID for tracking.
	 * @param externalAction The action to be performed.
	 * @param externalReference An external reference ID.
	 * @param messageType The type of message.
	 * @param integrationMode The integration mode.
	 * @param integrationPartner The integration partner.
	 * @param salesforceId The Salesforce ID of the related record.
	 * @param commentBody A comment associated with the case.
	 * @param priority The priority of the case.
	 * @param description A detailed description of the case.
	 * @param title The title of the case.
	 * @param type The type of the case.
	 * @param status The status of the case.
	 * @param requestSource The source of the request.
	 * @param category The category of the case.
	 * @param technologyType The type of technology involved.
	 * @param technology The specific technology involved.
	 * @param oneWorkFlowId The ID from the OneWorkFlow system.
	 * @return A configured NorlysNowClientRequestDTO object.
	 */
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
					correlationId,
					externalAction,
					externalReference,
					messageType,
					integrationMode,
					integrationPartner,
					salesforceId,
					commentBody,
					priority,
					description,
					title,
					type,
					status,
					requestSource,
					category,
					technologyType,
					technology,
					oneWorkFlowId
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

	/**
	 * @description Creates a request object for sending a file to Norlys Now.
	 * @param correlationId A unique ID for tracking.
	 * @param externalAction The action to be performed.
	 * @param externalReference An external reference ID.
	 * @param messageType The type of message.
	 * @param integrationMode The integration mode.
	 * @param integrationPartner The integration partner.
	 * @param salesforceId The Salesforce ID of the related record.
	 * @param fileData Base64 encoded file data.
	 * @param fileName The name of the file.
	 * @return A configured NorlysNowClientRequestDTO object.
	 */
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
					correlationId,
					externalAction,
					externalReference,
					messageType,
					integrationMode,
					integrationPartner,
					salesforceId,
					fileData,
					fileName
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

	/**
	 * @description Sets the sync status of a NorlysNow_Case__c record to 'Success'.
	 * @param norlysNowCase The NorlysNow_Case__c record to update.
	 * @return The updated NorlysNow_Case__c record.
	 */
	public NorlysNow_Case__c setSuccessOnNorlysNowCase(NorlysNow_Case__c norlysNowCase) {
		Logger.logInfo(String.format('setSuccessOnNorlysNowCase( {0} )', new List<Object>{ norlysNowCase }));
		if (norlysNowCase == null) {
			Logger.logError('norlysNowCase is null.');
			return null;
		}

		norlysNowCase.Sync_Status__c = 'Success';

		return norlysNowCase;
	}

	/**
	 * @description Sets the sync status of a NorlysNow_Case__c record to 'Error' and records an error message.
	 * @param norlysNowCase The NorlysNow_Case__c record to update.
	 * @param errorMessage The error message to record.
	 * @return The updated NorlysNow_Case__c record.
	 */
	public NorlysNow_Case__c setErrorOnNorlysNowCase(NorlysNow_Case__c norlysNowCase, String errorMessage) {
		Logger.logInfo(
			String.format('setErrorOnNorlysNowCase( {0}, {1} )', new List<Object>{ norlysNowCase, errorMessage })
		);
		if (norlysNowCase == null) {
			Logger.logError('norlysNowCase is null. Cannot set error: ' + errorMessage);
			return null;
		}

		norlysNowCase.Sync_Status__c = 'Error';
		norlysNowCase.Sync_Message__c = errorMessage;

		return norlysNowCase;
	}

	/**
	 * @description Deserializes a JSON string into a Parameters object.
	 * @param parametersJson The JSON string to deserialize.
	 * @return A Parameters object.
	 */
	public Parameters getParameters(String parametersJson) {
		Logger.logInfo(String.format('getParameters( {0} )', new List<Object>{ parametersJson }));
		Parameters params = (Parameters) System.JSON.deserialize(parametersJson, NorlysNowService.Parameters.class);
		return params;
	}

	/**
	 * @description A nested class to hold parameters for platform events.
	 */
	public class Parameters {
		/** @description The type of the SObject record, used for strategy selection. */
		public String type;
		/** @description A set of SObject record Ids to be processed. */
		public Set<Id> recordIds;
	}

	// ContentDocumentLink/File related methods
	/**
	 * @description Retrieves a map of ContentDocument Ids to their latest ContentVersion.
	 * @param fileIds A set of ContentDocument Ids.
	 * @return A map where the key is the ContentDocument Id and the value is the ContentVersion record.
	 */
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
	/**
	 * @description Creates follow-up tasks for a list of NorlysNow_Case__c records,
	 *              sends custom notifications, and emails the case creators.
	 * @param norlysNowCases The list of NorlysNow_Case__c records to create tasks for.
	 * @param subject The subject of the tasks.
	 * @param description The description of the tasks.
	 * @param dueDate The due date for the tasks.
	 */
	public void createFollowUpTasks(
		List<NorlysNow_Case__c> norlysNowCases,
		String subject,
		String description,
		Date dueDate
	) {
		Logger.logInfo(
			String.format(
				'createFollowUpTasks( {0}, {1}, {2}, {3})',
				new List<Object>{ norlysNowCases, subject, description, dueDate }
			)
		);

		Map<Id, NorlysNow_Case__c> caseMap = new Map<Id, NorlysNow_Case__c>(norlysNowcases);

		Set<Id> ownerIds = new Set<Id>();
		for (NorlysNow_Case__c nc : norlysNowcases) {
			ownerIds.add(nc.CreatedBy.Id);
		}

		Map<Id, User> ownerUserMap = new Map<Id, User>();
		if (!ownerIds.isEmpty()) {
			List<User> users = norlysNowSelector.getUsers(ownerIds);
			for (User u : users) {
				ownerUserMap.put(u.Id, u);
			}
		}

		List<Task> tasks = new List<Task>();
		for (NorlysNow_Case__c nc : norlysNowcases) {
			Task t = createTask(nc, subject, description, dueDate);
			tasks.add(t);
		}

		if (tasks.isEmpty())
			return;

		insert tasks;

		CustomNotificationType notifType = norlysNowSelector.getCustomNotificationType('New_Task_on_NorlysNow_Case');

		List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();

		Company_Settings__mdt config = Company_Settings__mdt.getInstance('No_Reply_Mobil_Email');

		OrgWideEmailAddress owe = norlysNowSelector.getOrgWideEmailAddress(config.Configuration_Value__c);

		for (Task t : tasks) {
			NorlysNow_Case__c nc = caseMap.get(t.WhatId);
			if (nc == null)
				continue;

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

	/**
	 * @description Creates a new Task record for a given NorlysNow_Case__c.
	 * @param nc The NorlysNow_Case__c record the task is related to.
	 * @param subject The subject of the task.
	 * @param description The description of the task.
	 * @param dueDate The due date of the task.
	 * @return A new Task record (not yet inserted).
	 */
	public Task createTask(NorlysNow_Case__c nc, String subject, String description, Date dueDate) {
		Logger.logInfo(
			String.format('createTask( {0}, {1}, {2}, {3})', new List<Object>{ nc, subject, description, dueDate })
		);

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

	/**
	 * @description Sends a custom notification to a user about a new task.
	 * @param task The task that the notification is about.
	 * @param notifType The type of custom notification to send.
	 * @param userId The ID of the user to send the notification to.
	 */
	public void sendCustomNotification(Task task, CustomNotificationType notifType, Id userId) {
		Logger.logInfo(
			String.format('sendCustomNotification( {0}, {1}, {2} )', new List<Object>{ task, notifType, userId })
		);

		if (task == null || notifType == null || userId == null)
			return;

		Messaging.CustomNotification cn = new Messaging.CustomNotification();
		cn.setTitle('New task created: ' + task.Subject);
		cn.setBody('A new Task has been created on case: ' + String.valueOf(task.WhatId));
		cn.setNotificationTypeId(notifType.Id);
		cn.setTargetId(task.Id);

		cn.send(new Set<String>{ (String) userId });
	}

	/**
	 * @description Builds an email to be sent to a user about a new task.
	 * @param task The task that the email is about.
	 * @param u The user to send the email to.
	 * @param nc The NorlysNow_Case__c record the task is related to.
	 * @param owe The organization-wide email address to send the email from.
	 * @return A configured SingleEmailMessage object.
	 */
	public Messaging.SingleEmailMessage buildOwnerEmail(
		Task task,
		User u,
		NorlysNow_Case__c nc,
		OrgWideEmailAddress owe
	) {
		Logger.logInfo(String.format('buildOwnerEmail( {0}, {1}, {2} )', new List<Object>{ task, u, nc }));

		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		if (u == null || String.isBlank(u.Email))
			return mail;

		mail.setToAddresses(new List<String>{ u.Email });
		String caseName = (nc != null && nc.Name != null) ? nc.Name : String.valueOf(task.WhatId);
		mail.setSubject('New task created on case: ' + caseName);
		mail.setOrgWideEmailAddressId(owe.Id);

		String body =
			'Hi ' +
			(u.Name != null ? u.Name : '') +
			',\n\n' +
			'A new Task has been created on the following record: ' +
			caseName +
			'\n' +
			'Subject: ' +
			task.Subject +
			'\n' +
			'Deadline: ' +
			String.valueOf(task.ActivityDate) +
			'\n\n' +
			'Please check your tasks.\n\nRegards';
		mail.setPlainTextBody(body);

		return mail;
	}

	/**
	 * @description Checks if all child NorlysNow_Case__c records related to a parent Case are closed.
	 *              If they are, it returns a list of parent Case records to be updated to 'Closed'.
	 * @param ncList A list of NorlysNow_Case__c records that have been updated.
	 * @return A list of parent Case records to be closed.
	 */
	public List<Case> closeParentCases(List<NorlysNow_Case__c> ncList) {
		Logger.logInfo(String.format('closeParentCase( {0} )', new List<Object>{ ncList }));

		// Find parent case Ids for NorlysNow_Case__c
		Set<Id> parentCaseIds = new Set<Id>();
		for (NorlysNow_Case__c nc : ncList) {
			parentCaseIds.add(nc.Parent_Case__c);
		}

		// Get all child NorlysNow_Case__c for these parent cases
		Map<Id, List<NorlysNow_Case__c>> parentIdToChildren = new Map<Id, List<NorlysNow_Case__c>>();
		List<NorlysNow_Case__c> norlysNowCases = norlysNowSelector.getAllNorlysNowCasesUnderParentCases(parentCaseIds);
		for (NorlysNow_Case__c nc : norlysNowCases) {
			if (!parentIdToChildren.containsKey(nc.Parent_Case__c)) {
				parentIdToChildren.put(nc.Parent_Case__c, new List<NorlysNow_Case__c>());
			}
			parentIdToChildren.get(nc.Parent_Case__c).add(nc);
		}

		// Check all child records is Closed
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
				parentCasesToClose.add(new Case(Id = parentCaseId, Status = 'Closed'));
			}
		}

		return parentCasesToClose;
	}

	/**
	 * @description Checks if any of the provided NorlysNow_Case__c records are related to a closed parent Case.
	 *              If so, it adds an error to the record to prevent further processing.
	 * @param ncList The list of NorlysNow_Case__c records to check.
	 */
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

	/**
	 * @description Takes a list of record Ids and chunks them into smaller lists to be published as
	 *              separate platform events. This is useful for staying within platform limits.
	 * @param toBeSentIds The list of record Ids to be chunked and published.
	 * @param objectType The type of SObject being processed (e.g., 'FeedItem', 'NorlysNow_Case__c').
	 * @param executorType The name of the executor class that should handle the event.
	 * @return A list of EventExecutor__e events to be published.
	 */
	public List<EventExecutor__e> chunkEventsInListsToBePublished(
		List<Id> toBeSentIds,
		String objectType,
		String executorType
	) {
		// Create three lists of string
		List<List<Id>> chunked = (List<List<Id>>) orgUtils.chunkListOfStrings(100, toBeSentIds, List<List<Id>>.class);
		List<EventExecutor__e> eventList = new List<EventExecutor__e>();
		for (List<Id> iterationList : chunked) {
			NorlysNowService.Parameters params = new NorlysNowService.Parameters();
			params.type = objectType; // Specify the type for the strategy
			params.recordIds = new Set<Id>(iterationList);
			String paramsJson = JSON.serialize(params);

			eventList.add(new EventExecutor__e(Executor__c = executorType, Parameters__c = paramsJson));
		}

		return eventList;
	}
}
