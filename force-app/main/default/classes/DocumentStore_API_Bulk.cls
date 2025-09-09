public class DocumentStore_API_Bulk implements Schedulable{

    // TODO the hardcoded email should instead utilise OrgUtils getCompanySettingsConfigurationValueByDeveloperName()
    public void execute(SchedulableContext ctx) {
        List<EmailMessage> EmailMessage_list = [SELECT Id,createddate FROM EmailMessage where 
                                                ValidatedFromAddress = 'kundeservice.erhverv@norlys.dk' 
                                                and createddate = TODAY];
        //EmailMessage_list = [SELECT Id,createddate FROM EmailMessage where Id = '02s1w0000015fn1AAA'];
        // Create a task for each email in the list
        Set<Id> Ids = new Set<Id>();
        for(EmailMessage EmailMessage_record: EmailMessage_list){
                Ids.add(EmailMessage_record.Id);
            }
        DocumentStore_API_Static.DocumentStore_Call(Ids);
    }    
}