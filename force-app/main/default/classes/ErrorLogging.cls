public class ErrorLogging {
    private String originName;
    @TestVisible
    private List<System_Log__c> listOfLogs;
    public ErrorLogging(){
        this.listOfLogs = new List<System_Log__c>();
        this.originName = 'Not defined';
    }
    public ErrorLogging( String theOriginName ){
        this.listOfLogs = new List<System_Log__c>();
        this.originName = theOriginName;
    }
    
    public void addError( String errorBody, String addInformation ){
        listOfLogs.add( new System_Log__c(
        	Error_Body__c = errorBody,
            Origin__c = originName,
            Additional_Information__c = addInformation
        ) );
    }
    public void addError( String errorBody, String addInformation, String theOriginName ){
        listOfLogs.add( new System_Log__c(
        	Error_Body__c = errorBody,
            Origin__c = theOriginName,
            Additional_Information__c = addInformation
        ) );
    }
    
    public void logErrors(){
        if( listOfLogs.size() > 0 )insert listOfLogs;
    }
}