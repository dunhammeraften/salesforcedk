public class NorlysNowClientRequestDTO {

    public String integrationmode;
    public String integrationPartner;
    public String correlation_id;
    public String external_action;
    public String external_reference;
    public String message_type;
    public Payload payload;

    public NorlysNowClientRequestDTO() {
        this.payload = new Payload();
    }

    public class Payload {
        public String title;
        public String description;
        public String priority;
        public String status;
        public String requestSource;
        public String category;
        public String technologyType;
        public String technology;
        public String salesforceId;
        public String type;
        public String comment;
        public String fileData;
        public String fileName;
        public String oneWorkFlowId;
    }
}
