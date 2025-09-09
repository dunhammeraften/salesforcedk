public class SFToolingClientRequestDTO {

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