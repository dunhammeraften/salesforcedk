public class AccountTriggerHandler extends TriggerHandler {
    
    /**
     * Singleton instance of the AccountService
     */
    private final AccountService accountService;

    /**
     * Collection of newly Account records from the trigger context
     */
    @TestVisible
    private List<Account> triggerNew;

    @TestVisible
    private AccountTriggerHandler(AccountService accountService) {
        this.accountService = accountService;
    }

    public AccountTriggerHandler() {
        this(SingletonFactory.getFactory());
    }

    private AccountTriggerHandler(SingletonFactory singletonFactory) {
        this.accountService = (AccountService) singletonFactory.getOrRegisterSingleton(AccountService.class);
        this.triggerNew = (List<Account>) Trigger.new;
    }

    public override void afterInsert() {
        accountService.CompanyAPIDataFetch(triggerNew);
    }

    public override void beforeUpdate() {
        accountService.ContractAPIDataFetch(triggerNew);
    }
}