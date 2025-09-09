public with sharing class SFToolingClientResponseDTO {
	
	/**
	 * Represents the result of a Tooling API query operation
	 */
	public class ToolingQuery {
		/** Number of records returned in this batch */
		public Integer size;
		/** Total number of records matching the query */
		public Integer totalSize;
		/** Indicates if there are more records available */
		public Boolean done;
		/** Query locator for pagination */
		public Object queryLocator;
		/** Name of the entity being queried */
		public String entityTypeName;
		/** List of returned records */
		public List<Record> records;
	}

	/**
	 * Represents a single record returned by the Tooling API
	 */
	public class Record {
		/** Metadata attributes of the record */
		public Attributes attributes;
		/** Unique identifier of the record */
		public String Id;
		/** Batch size configuration */
		public Integer BatchSize;
		/** Master label of the record */
		public String MasterLabel;
		/** Developer name of the record */
		public String DeveloperName;
		/** User ID associated with the record */
		public Id UserId;
		/** Platform event consumer ID */
		public Id PlatformEventConsumerId;
	}


    /**
	 * Represents metadata attributes of a record
	 */
	public class Attributes {
		/** Type of record */
		public String type;
		/** URL reference to the record */
		public String url;
	}

}