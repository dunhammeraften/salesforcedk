/**
 * @description This class represents the Data Transfer Object (DTO) for requests sent to the Norlys Now client.
 *              It defines the structure of the JSON payload for the integration.
 *
 * -----------------------------------------------------------------------------
 * @author Developer           Date            Description
 * -----------------------------------------------------------------------------
 * @author Esben Hovgaard        18/09/2025      Class and property documentation
 * -----------------------------------------------------------------------------
 */
public class NorlysNowClientRequestDTO {
	/** @description The integration mode, e.g., 'async'. */
	public String integrationmode;
	/** @description The name of the integration partner, e.g., 'Salesforce'. */
	public String integrationPartner;
	/** @description A unique identifier for tracking the request. */
	public String correlation_id;
	/** @description The action to be performed, e.g., 'create_case'. */
	public String external_action;
	/** @description An external reference ID. */
	public String external_reference;
	/** @description The type of message, e.g., 'case'. */
	public String message_type;
	/** @description The nested payload object containing the main data of the request. */
	public Payload payload;

	/**
	 * @description Default constructor that initializes the nested Payload object.
	 */
	public NorlysNowClientRequestDTO() {
		this.payload = new Payload();
	}

	/**
	 * @description This nested class represents the main payload of the request.
	 */
	public class Payload {
		/** @description The title of the case or item. */
		public String title;
		/** @description A detailed description. */
		public String description;
		/** @description The priority of the request. */
		public String priority;
		/** @description The status of the item, e.g., 'New', 'Withdrawn'. */
		public String status;
		/** @description The source of the request. */
		public String requestSource;
		/** @description The category of the item. */
		public String category;
		/** @description The type of technology involved. */
		public String technologyType;
		/** @description The specific technology involved. */
		public String technology;
		/** @description The Salesforce ID of the related record. */
		public String salesforceId;
		/** @description The type of the payload, e.g., 'NorlysNow_Case__c'. */
		public String type;
		/** @description A comment associated with the request. */
		public String comment;
		/** @description Base64 encoded file data for attachments. */
		public String fileData;
		/** @description The name of the attached file. */
		public String fileName;
		/** @description The ID from the OneWorkFlow system. */
		public String oneWorkFlowId;
	}
}
