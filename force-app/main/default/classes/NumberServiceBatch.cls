public with sharing class NumberServiceBatch implements Database.Batchable<String>, Database.AllowsCallouts, Database.Stateful {
    public Enum Action {
        RESERVE,
        UNRESERVE
    }

    private static final Map<Action, String> ACTION_2_FAILED_MESSAGE = new Map<Action, String>{
        Action.RESERVE => 'Failed to reserve one or more MSISDNs: ',
        Action.UNRESERVE => 'Failed to unreserve one or more MSISDNs: '
    };
    private static final String UNKNOWN_RESPONSE = 'Unknown response: ';
    private static final String ACTION_NOT_IMPLEMENTED = 'Action not implemented: ';
    private static final Integer BATCH_SIZE = 10;

    private Action action;
    private List<String> msisdns = new List<String>();
    private List<String> msisdnsSuccess = new List<String>();
    private Map<String, String> msisdnFailed2ErrorMessage = new Map<String, String>();
    private ErrorLogging logs = new ErrorLogging('Apex');

    public NumberServiceBatch(Action action, List<String> msisdns) {
        this.action = action;
        this.msisdns = msisdns;
    }

    public Id run() {
        return Database.executeBatch(this, BATCH_SIZE);
    }

    public List<String> start(Database.BatchableContext BC) {
        return this.msisdns;
    }
    
    public void execute(Database.BatchableContext BC, List<String> scope) {
        for(Integer i = 0 ; i < scope.size(); i++) {
            String msisdn = scope[i];
            try {
                NumberResDAO.NumberDetail response;
                switch on action {
                    when RESERVE {
                        response = NumberService.reserveNumberByMsisdn(msisdn, false);
                    }
                    when UNRESERVE {
                        response = NumberService.unreserveNumberByMsisdn(msisdn, false);
                    }
                    when else {
                        throw new NumberServiceBatchException(ACTION_NOT_IMPLEMENTED + String.valueOf(action));
                    }
                }
                if(response.data != null) {
                    msisdnsSuccess.add(msisdn);
                } else if(response.error != null) {
                    msisdnFailed2ErrorMessage.put(msisdn, response.error.message);
                } else {
                    throw new NumberServiceBatchException(UNKNOWN_RESPONSE + String.valueOf(response));
                }
            } catch(Exception ex) {
                msisdnFailed2ErrorMessage.put(msisdn, ex.getMessage());
            }
        }
    }

    public void finish(Database.BatchableContext BC) {
        if(!msisdnFailed2ErrorMessage.keySet().isEmpty()) {
            String failedMsisdnsWithMessages = '';
            for(String msisdn : msisdnFailed2ErrorMessage.keySet()) {
                failedMsisdnsWithMessages += '\n' + msisdn + ': ' + msisdnFailed2ErrorMessage.get(msisdn);
            }
            logs.addError(ACTION_2_FAILED_MESSAGE.get(action) + failedMsisdnsWithMessages, NumberServiceBatch.class.getName());
        }
        logs.logErrors();
    }

    public class NumberServiceBatchException extends Exception {}
}