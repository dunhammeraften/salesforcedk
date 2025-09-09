public class ActivationLineService {
    
    private final DatabaseService dataBaseService;
 
    @TestVisible
    private ActivationLineService(DatabaseService dbService) {
        this.dataBaseService = dbService;
    }

    public ActivationLineService(){
        this(SingletonFactory.getFactory());
    }
 
    private ActivationLineService(SingletonFactory singletonFactory) {
        this.dataBaseService = (DatabaseService) singletonFactory.getOrRegisterSingleton(DatabaseService.class);
    }
 
    public void createActivationLine(List<Activation_line__c> activationLineList) {
        Logger.logInfo(String.format('createActivationLine( {0} )', new List<Object>{ activationLineList }));
        List<Activation_line__c> activationLines = new List<Activation_line__c>();
 
        for (Activation_line__c al : activationLineList) {
            if (al.Fastnet_user__c && String.isNotBlank(al.VAS_UC_License__c)
                && al.TOP_Completed_Flows__c == 'Voice_Flow' && al.TOP_Activation_Flow_Step__c == 'FINISHED') {
                   
                Activation_line__c actiline = new Activation_line__c( Activation__c = al.Activation__c,
                                                                        Related_Activation_line__c = al.id,
                                                                        Case__c = al.Case__c,
                                                                        Quote_line__c = al.Quote_line__c,
                                                                        Manual_Product__c = system.label.TPX_Funktionnr,
                                                                        TOP_Activation_Flow_Step__c = 'FINISHED',
                                                                        TOP_Completed_Flows__c = 'Voice_Flow',
                                                                        RecordTypeId = '0121i000000HJjrAAG',
                                                                        Billing_Account__c = al.Billing_Account__c,
                                                                        Phone_no_Status__c = al.Phone_no_Status__c
                                                                    );
                activationLines.add(actiline);
            }    
        }
 
        if (!activationLines.isEmpty()){ 
            dataBaseService.insertRecords(activationLines); 
        }
    }

    public List<Activation_line__c> hasCompletedVoiceFlow(List<Activation_line__c> triggerNew, List<Activation_line__c> triggerOld) {
        Logger.logInfo(String.format('hasCompletedVoiceFlow( {0},{1} )', new List<Object>{ triggerNew, triggerOld}));
        List<Activation_line__c> activationLines = new List<Activation_line__c>();

        for (Integer i = 0; i < triggerNew.size(); i++) {
            Activation_line__c newRec = triggerNew[i];
            Activation_line__c oldRec = triggerOld[i];
            if (
                newRec.TOP_Activation_Flow_Step__c != oldRec.TOP_Activation_Flow_Step__c &&
                newRec.TOP_Completed_Flows__c != oldRec.TOP_Completed_Flows__c &&
                newRec.TOP_Completed_Flows__c == 'Voice_Flow'
            ) {
                activationLines.add(newRec);
            }
        }

        return activationLines;
    }

     /**
     * Retrieves a map of activationLineId to MobileNo when activation_line__c records are deleted.
     * 
     *
     * @param oldList The list of old activation_line__c records.
     * @return A map of activationLineId to MobileNo
     */
    public Map<Id, String> getMapOfActivationLineToPhoneNumberForActivationLineDeletes(List<Activation_Line__c> oldList){
        Logger.logInfo(String.format('getMapOfActivationLineToPhoneNumberForActivationLineDeletes( {0} )', new List<Object>{ oldList}));

        Map<Id, String> mapOfActivationLineToPhoneNumber = new Map<Id, String>();

        if (oldList == null) {
            Logger.logError('oldList is null.');
        }
        else {
            for (Activation_Line__c actLine : oldList) {
                mapOfActivationLineToPhoneNumber.put(actLine.Id, actLine.Mobile_No__c);  
            }
        }

        return mapOfActivationLineToPhoneNumber;
    } 
}