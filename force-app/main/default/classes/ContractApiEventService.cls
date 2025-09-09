public with sharing class ContractApiEventService {
    @TestVisible
    private static final Set<String> QUOTE_STATUSES_TO_CONSIDER = new Set<String>{'Signed'};
    @TestVisible
    private static List<Database.SaveResult> publishResults = new List<Database.SaveResult>();
    @TestVisible
    private static List<AccountWithProducts__e> events = new List<AccountWithProducts__e>();

    public static void createEvents(List<Id> accountIds) {
        try {
            List<Account> accounts = AccountSelector.getAccountsByIds(accountIds);
            Map<Id, List<SBQQ__Quote__c>> accountId2QuotesWithQuoteLines = getAccountId2QuotesWithQuoteLines(accountIds);
            events = getEvents(accounts, accountId2QuotesWithQuoteLines);
            publishResults = EventBus.publish(events);
        } catch (Exception ex) {
            Logger.logError(ContractApiEventService.class.getName(), ex);
        }
    }

    private static Map<Id, List<SBQQ__Quote__c>> getAccountId2QuotesWithQuoteLines(List<Id> accountIds) {
        List<SBQQ__Quote__c> quotesWithQuoteLines = QuoteSelector.getQuotesWithLinesWithinValidUntilByAccountIdsInStatuses(accountIds, QUOTE_STATUSES_TO_CONSIDER);

        Map<Id, List<SBQQ__Quote__c>> accountId2QuotesWithQuoteLines = new Map<Id, List<SBQQ__Quote__c>>();
        for (SBQQ__Quote__c quote : quotesWithQuoteLines) {
            if (!accountId2QuotesWithQuoteLines.containsKey(quote.SBQQ__Account__c)) {
                accountId2QuotesWithQuoteLines.put(quote.SBQQ__Account__c, new List<SBQQ__Quote__c>{quote});
            } else {
                accountId2QuotesWithQuoteLines.get(quote.SBQQ__Account__c).add(quote);
            }
        }

        return accountId2QuotesWithQuoteLines;
    }

    private static List<AccountWithProducts__e> getEvents(List<Account> accounts, Map<Id, List<SBQQ__Quote__c>> accountId2QuotesWithQuoteLines) {
        List<AccountWithProducts__e> events = new List<AccountWithProducts__e>();
        for (Account account : accounts) {
            AccountDetail accountDetail = new AccountDetail(account);

            List<SBQQ__Quote__c> quotes = new List<SBQQ__Quote__c>(accountId2QuotesWithQuoteLines.get(account.Id));
            List<QuoteDetail> quoteDetails = new List<QuoteDetail>();
            for (SBQQ__Quote__c quote : quotes) {
                List<ProductDetail> productDetails = new List<ProductDetail>();
                for (SBQQ__QuoteLine__c quoteLine : quote.SBQQ__LineItems__r) {
                    productDetails.add(new ProductDetail(quoteLine));
                }
                QuoteDetail quoteDetail = new QuoteDetail(quote, productDetails);
                quoteDetails.add(quoteDetail);
            }

            AccountWithProducts__e event = new AccountWithProducts__e(
                JSON_AccountWithProducts__c = JSON.serialize(
                    new Payload(
                        accountDetail,
                        quoteDetails
                    )
                )
            );
            events.add(event);
        }

        return events;
    }

    public class Payload {
        public AccountDetail account;
        public List<QuoteDetail> quotes;

        public Payload(AccountDetail account, List<QuoteDetail> quotes) {
            this.account = account;
            this.quotes = quotes;
        }
    }

    public class AccountDetail {
        public Id id;
        public String cvr;

        public AccountDetail(Account account) {
            this.id = account.Id;
            this.cvr = account.CVR__c;
        }
    }

    public class QuoteDetail {
        public Id id;
        public Date startDate;
        public Integer contractTerm;
        public Date validUntil;
        public List<ProductDetail> products;

        public QuoteDetail(SBQQ__Quote__c quote, List<ProductDetail> products) {
            this.id = quote.Id;
            this.startDate = quote.SBQQ__StartDate__c;
            this.contractTerm = Integer.valueOf(quote.SBQQ__SubscriptionTerm__c);
            this.validUntil = quote.Manual_Valid_Until__c != null ? quote.Manual_Valid_Until__c : quote.Valid_Until__c;
            this.products = products;
        }
    }

    public class ProductDetail {
        public Id id;
        public String name;
        public String productCode;
        public Decimal price;

        public ProductDetail(SBQQ__QuoteLine__c quoteLine) {
            this.id = quoteLine.SBQQ__Product__c;
            this.name = quoteLine.SBQQ__Product__r.Name;
            this.productCode = quoteLine.SBQQ__Product__r.ProductAPI_Telia_Product_Id__c;
            this.price = quoteLine.Telia_Net_Unit_Price__c;
        }
    }
}