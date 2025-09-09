public class AccountService {

    public Set<Id> CompanyAPIDataFetch(List<Account> accounts) {
        Logger.logInfo(String.format('CompanyAPIDataFetch( {0} )', new List<Object>{ accounts }));

        Set<Id> accountIdsForCompanyApiUpdate = new Set<Id>();
        for(Account acc : accounts) {
            if(acc.CVR__c != null) {
                accountIdsForCompanyApiUpdate.add(acc.Id);
            }
        }

        if(!accountIdsForCompanyApiUpdate.isEmpty()) {
            // TODO: CALLOUT needs to be refactored to use a service class
            Company_API_DataFetch.FetchData(accountIdsForCompanyApiUpdate);
        }

        return accountIdsForCompanyApiUpdate;
    }

    public List<Id> ContractAPIDataFetch(List<Account> accounts) {
        Logger.logInfo(String.format('ContractAPIDataFetch( {0} )', new List<Object>{ accounts }));

        List<Id> accountIdsForContractApiUpdate = new List<Id>();
        for(Account acc : accounts) {
            if(acc.Send_Update_to_Contract_API__c) {
                acc.Send_Update_to_Contract_API__c = false;
                accountIdsForContractApiUpdate.add(acc.Id);
            }
        }

        if(!accountIdsForContractApiUpdate.isEmpty()) {
            ContractApiEventService.createEvents(accountIdsForContractApiUpdate);
        }

        return accountIdsForContractApiUpdate;
    }
}