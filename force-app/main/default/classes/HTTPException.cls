public with sharing class HTTPException extends Exception {
    private HTTPResponse response;
    private integer statusCode;
    private String status;

    public HTTPException(HTTPResponse response){
        this.response = response;
        setMessage(response.getBody());
        this.statusCode = response.getStatusCode();
        this.status = response.getStatus();
    }
    
    @TestVisible
    public HTTPException(String exceptionMessage, Integer statusCode, String status){
        setMessage(exceptionMessage);
        this.statusCode = statusCode;
        this.status = status;
    }

    public Integer getStatusCode(){
        return statusCode;
    }

    public String getStatus(){
        return status;
    }
}