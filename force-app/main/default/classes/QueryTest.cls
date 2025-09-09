/*
 * MIT License
 *
 * Copyright (c) 2018 - 2020 Click to Cloud Pty Ltd, Propic Pty Ltd
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */
@isTest
public class QueryTest {
    @isTest
    static void simpleTest() {
        createData();
        List<Account> accounts;

        accounts = new Query('Account').
            selectAllFields().
            run();

        assertAccount(accounts.get(0));

        accounts = new Query(Account.getSObjectType()).
            selectAllFields().
            run();

        assertAccount(accounts.get(0));
    }

    @isTest
    static void selectReadableFieldsTest() {
        createData();
        List<Account> accounts;

        accounts = new Query('Account').
            selectReadableFields().
            run();

        assertAccount(accounts.get(0));

        accounts = new Query(Account.getSObjectType()).
            selectEditableFields().
            run();

        assertAccount(accounts.get(0));

        accounts = new Query(Account.getSObjectType()).
            selectCreatableFields().
            run();

        assertAccount(accounts.get(0));
    }

    @isTest
    static void selectAllFieldsTest() {
        createData();
        List<Account> accounts;

        accounts = new Query('Account').
            selectAllFields().
            run();

        assertAccount(accounts.get(0));

        accounts = new Query(Account.getSObjectType()).
            selectEditableFields().
            run();

        assertAccount(accounts.get(0));

        accounts = new Query(Account.getSObjectType()).
            selectCreatableFields().
            run();

        assertAccount(accounts.get(0));
    }

    @isTest
    static void getSObjectTypeTest() {
        Assert.areEqual(
            new Query('Account').getSObjectType(),
            Account.getSObjectType()
        );
    }

    @isTest
    static void fetchTest() {
        Account acc0 = TDF_AccountUtils.creatActiveAccountWithCVRAndOwner('12345678');
        Account acc1 = TDF_AccountUtils.creatActiveAccountWithCVRAndOwner('12345679');
        Account acc2 = TDF_AccountUtils.creatActiveAccountWithCVRAndOwner('12345670');

        insert new List<Account>{acc0, acc1, acc2};

        List<Account> accounts = new Query('Account').
            selectAllFields().
            fetch(1, 3);
            
        Assert.areEqual(accounts.size(), 2);
        Assert.areEqual(accounts.get(0).CVR__c, '12345679');
        Assert.areEqual(accounts.get(1).CVR__c, '12345670');

        Account account;

        List<Account> accountsList = new Query('Account').
            selectAllFields().
            fetch(2);
        Assert.areEqual(accountsList.get(0).CVR__c, '12345678');
        Assert.areEqual(accountsList.get(1).CVR__c, '12345679');
        Assert.areEqual(accountsList.size(), 2);

        account = (Account)new Query('Account').
            selectAllFields().
            fetch();
        Assert.areEqual(account.CVR__c, '12345678');

    }

    @isTest
    static void toIdListTest() {
        createData();

        List<Id> idList = new Query('Account').toIdList();

        Assert.areEqual(idList.size(), 1);
    }

    @isTest
    static void OptionalClauseTest() {
        createData();

        List<Account> accountsForView = new Query('Account').forView().run();
        List<Account> accountsForUpdate = new Query('Account').forUpdate().run();
        List<Account> accountsForReference = new Query('Account').forReference().run();

    }

    @isTest
    static void runPreservingIdOrderTest() {
        Account acc0 = TDF_AccountUtils.creatActiveAccountWithCVRAndOwner('12345678');
        Account acc1 = TDF_AccountUtils.creatActiveAccountWithCVRAndOwner('12345679');
        Account acc2 = TDF_AccountUtils.creatActiveAccountWithCVRAndOwner('12345670');

        insert new List<Account>{acc0, acc1, acc2};

        List<Id> idList = new List<Id>{ acc0.Id, acc1.Id, acc2.Id, acc0.Id };

        List<Account> accounts = new Query('Account').runPreservingIdOrder(idList);

        Assert.areEqual(accounts.get(0).Id, acc0.Id);
        Assert.areEqual(accounts.get(1).Id, acc1.Id);
        Assert.areEqual(accounts.get(2).Id, acc2.Id);
        Assert.areEqual(accounts.get(3).Id, acc0.Id);
    }

    @isTest
    static void fieldsTest() {
        createData();

        List<Account> accounts = new Query('Account').
                                 selectField('Id').
                                 selectFields('Name').
                                 selectFields('Phone, SicDesc').
                                 selectFields(new List<String>{'NumberOfEmployees', 'Website'}).
                                 selectFields(new Set<String>{'Fax', 'ShippingState'}).
                                 selectAllFields().
                                 run();

        assertAccount(accounts.get(0));
    }

    @isTest
    static void readableParentFieldsTest() {
        createData();

        List<Opportunity> opportunities;

        opportunities = new Query('Opportunity').
            selectReadableFields().
            selectReadableFields('CreatedBy').
            selectReadableFields('Account.LastModifiedBy').
            selectFields('Account.CreatedBy.FirstName').
            selectFields('LastModifiedBy.FirstName, LastModifiedBy.LastName').
            selectFields(new List<String>{'Owner.FirstName', 'Owner.LastName'}).
            run();

        assertOpportunity(opportunities.get(0));
        
        Assert.areNotEqual(opportunities.get(0).CreatedBy.FirstName, null);
        Assert.areNotEqual(opportunities.get(0).Account.CreatedBy.FirstName, null);
        Assert.areNotEqual(opportunities.get(0).Account.LastModifiedBy.FirstName, null);
        Assert.areNotEqual(opportunities.get(0).LastModifiedBy.FirstName, null);
        Assert.areNotEqual(opportunities.get(0).LastModifiedBy.LastName, null);
        Assert.areNotEqual(opportunities.get(0).Owner.FirstName, null);
        Assert.areNotEqual(opportunities.get(0).Owner.LastName, null);
    }

    @isTest
    static void allParentFieldsTest() {
        createData();

        List<Opportunity> opportunities;

        opportunities = new Query('Opportunity').
            selectAllFields().
            selectAllFields('CreatedBy').
            selectAllFields('Account.LastModifiedBy').
            selectFields('Account.CreatedBy.FirstName').
            selectFields('LastModifiedBy.FirstName, LastModifiedBy.LastName').
            selectFields(new List<String>{'Owner.FirstName', 'Owner.LastName'}).
            run();

        assertOpportunity(opportunities.get(0));

        Assert.areNotEqual(opportunities.get(0).CreatedBy.FirstName, null);
        Assert.areNotEqual(opportunities.get(0).Account.CreatedBy.FirstName, null);
        Assert.areNotEqual(opportunities.get(0).Account.LastModifiedBy.FirstName, null);
        Assert.areNotEqual(opportunities.get(0).LastModifiedBy.FirstName, null);
        Assert.areNotEqual(opportunities.get(0).LastModifiedBy.LastName, null);
        Assert.areNotEqual(opportunities.get(0).Owner.FirstName, null);
        Assert.areNotEqual(opportunities.get(0).Owner.LastName, null);
    }

    @isTest
    static void idTest() {
        createData();

        Id accId = [ SELECT Id FROM Account LIMIT 1 ].Id;

        List<Account> accounts;

        accounts = new Query('Account').
                   selectAllFields().
                   byId(accId).
                   run();

        assertAccount(accounts.get(0));

        accounts = new Query('Account').
                   selectAllFields().
                   byId(new Set<Id>{accId}).
                   run();

        assertAccount(accounts.get(0));

        accounts = new Query('Account').
                   selectAllFields().
                   byId(new List<Id>{accId}).
                   run();

        assertAccount(accounts.get(0));

        // negative cases
        final Id wrongId = 'a0EO000000DjJeJMAV';
        accounts = new Query('Account').
                   selectAllFields().
                   byId(wrongId).
                   run();

        Assert.isTrue(accounts.isEmpty());
    }

    @isTest
    static void lookupTest() {
        createData();

        Account account = [ SELECT Id FROM Account LIMIT 1 ];

        List<Opportunity> opportunities;

        opportunities =
            new Query('Opportunity').
            selectAllFields().
            lookup('AccountId', account.Id).
            run();

        assertOpportunity(opportunities.get(0));

        opportunities =
            new Query('Opportunity').
            selectAllFields().
            lookup('AccountId', new List<Id>{account.Id}).
            run();

        assertOpportunity(opportunities.get(0));

        opportunities =
            new Query('Opportunity').
            selectAllFields().
            lookup('AccountId', account).
            run();

        assertOpportunity(opportunities.get(0));
    }

    @isTest
    static void simpleConditionTest() {
        createData();

        List<Account> accounts;

        accounts = new Query('Account').
                    selectAllFields().
                    addConditionEq('BillingCity', 'CP').
                    addConditionNull('AccountNumber').
                    run();

        assertAccount(accounts.get(0));

        // negative cases
        accounts = new Query('Account').
                    selectAllFields().
                    addConditionNotNull('Name').
                    addConditionEq('Phone', '+61 410 111 111').
                    run();

        System.assert(accounts.isEmpty());
    }

    @isTest
    static void singleConditionTest() {
        createData();

        List<Account> accounts;

        accounts = new Query('Account').
                    selectAllFields().
                    addConditionEq('BillingCity', 'CP').
                    run();

        assertAccount(accounts.get(0));

        accounts = new Query('Account').
                    selectAllFields().
                    addConditionNotEq('Name', 'CDE Ltd').
                    run();

        assertAccount(accounts.get(0));

        accounts = new Query('Account').
                    selectAllFields().
                    addConditionIn('BillingCity', new Set<String>{'CP'}).
                    run();

        assertAccount(accounts.get(0));

        accounts = new Query('Account').
                    selectAllFields().
                    addConditionNotIn('Name', new Set<String>{'CDE Ltd'}).
                    run();

        assertAccount(accounts.get(0));

        accounts = new Query('Account').
                    selectAllFields().
                    addConditionLt('NumberOfEmployees', 15).
                    run();

        assertAccount(accounts.get(0));

        accounts = new Query('Account').
                    selectAllFields().
                    addConditionLe('NumberOfEmployees', 10).
                    run();

        assertAccount(accounts.get(0));

        accounts = new Query('Account').
                    selectAllFields().
                    addConditionGt('NumberOfEmployees', 5).
                    run();

        assertAccount(accounts.get(0));

        accounts = new Query('Account').
                    selectAllFields().
                    addConditionGe('NumberOfEmployees', 10).
                    run();

        assertAccount(accounts.get(0));

        accounts = new Query('Account').
                    selectAllFields().
                    addConditionLike('BillingStreet', '%blads%').
                    run();

        assertAccount(accounts.get(0));

        accounts = new Query('Account').
                    selectAllFields().
                    addConditionNotLike('BillingStreet', '%CBA%').
                    run();

        assertAccount(accounts.get(0));
    }

    @isTest
    static void disjunctionConditionTest() {
        createData();

        List<Account> accounts;

        accounts = new Query('Account').
                   selectAllFields().
                   switchToDisjunction().
                   addConditionEq('BillingCity', 'CP').
                   run();

        assertAccount(accounts.get(0));

        // negative cases

        accounts = new Query('Account').
                   selectAllFields().
                   switchToDisjunction().
                   addConditionEq('Name', 'ABC Ltd').
                   addConditionEq('Phone', '+61 410 111 111').
                   switchToConjunction().
                   run();

        Assert.isTrue(accounts.isEmpty());
    }

    @isTest
    static void conditionTypeSimpleTest() {
        createData();

        List<Account> accounts = new Query('Account').
                                 selectAllFields().
                                 addCondition(Query.conditionEq('BillingCity', 'CP')).
                                 run();

        assertAccount(accounts.get(0));
    }

    @isTest
    static void conditionIncludeTest() {
        QuickText text = new QuickText(
            Name = 'MyQuickText',
            Message = 'MyMessage',
            Channel = 'Channel1;Channel2'
        );
        insert text;

        List<QuickText> result = new Query('QuickText').
            selectFields('Name, Message, Channel').
            addConditionIncludes('Channel', 'Channel1').
            run();

        Assert.areEqual(result.size(), 1);
        Assert.areEqual(result[0].Name, 'MyQuickText');

    }

    @isTest
    static void conditionExcludesTest() {
        QuickText text1 = new QuickText(
            Name = 'MyQuickText1',
            Message = 'MyMessage1',
            Channel = 'Channel1;Channel2'
        );

        QuickText text2 = new QuickText(
            Name = 'MyQuickText2',
            Message = 'MyMessage2',
            Channel = 'Channel3;Channel4'
        );

        insert new List<QuickText> {text1, text2};

        List<QuickText> result = new Query('QuickText').
            selectFields('Name, Message, Channel').
            addConditionExcludes('Channel', 'Channel2').
            run();

        Assert.areEqual(result.size(), 1);
        Assert.areEqual(result[0].Name, 'MyQuickText2');

    }

    @isTest
    static void complexConditionTest() {
        createData();

        List<Account> accounts =
                new Query('Account').
                selectAllFields().
                addCondition(
                    Query.doAnd(
                        Query.doOr(
                            Query.conditionEq('BillingPostalCode', '2000'),
                            Query.conditionEq('BillingCity', 'CP')
                        ),
                        Query.conditionIn('Phone',  new Set<String>{'111'}),
                        Query.doNot(
                            Query.doOr(
                                Query.conditionNotEq('BillingStreet', 'Holmbladsgade 133'),
                                Query.conditionGt('BillingCountry', 'DK')
                            )
                        )
                    )
                ).
                run();

        assertAccount(accounts.get(0));
    }

    @isTest
    static void limitTest() {
        Account acc0 = TDF_AccountUtils.creatActiveAccountWithCVRAndOwner('12345678');
        Account acc1 = TDF_AccountUtils.creatActiveAccountWithCVRAndOwner('12345679');
        Account acc2 = TDF_AccountUtils.creatActiveAccountWithCVRAndOwner('12345670');

        insert new List<Account>{acc0, acc1, acc2};

        List<Account> accounts = new Query('Account').
                                 selectAllFields().
                                 setLimit(1).
                                 run();

        Assert.areEqual(accounts.size(), 1);
        assertAccount(accounts.get(0));
    }

    @isTest
    static void offsetTest() {
        Account acc0 = TDF_AccountUtils.creatActiveAccountWithCVRAndOwner('12345678');
        Account acc1 = TDF_AccountUtils.creatActiveAccountWithCVRAndOwner('12345679');
        Account acc2 = TDF_AccountUtils.creatActiveAccountWithCVRAndOwner('12345670');
        Account acc3 = TDF_AccountUtils.creatActiveAccountWithCVRAndOwner('12345671');

        insert new List<Account>{acc0, acc1, acc2, acc3};

        List<Account> accounts;
        accounts  = new Query('Account').
                    selectAllFields().
                    setOffset(2).
                    run();

        Assert.areEqual(accounts.size(), 2);
        Assert.areEqual(accounts.get(0).CVR__c, '12345670');
    }

    @isTest
    static void orderTest() {
        Account acc0 = TDF_AccountUtils.creatActiveAccountWithCVRAndOwner('12345678');
        Account acc1 = TDF_AccountUtils.creatActiveAccountWithCVRAndOwner('12345679');
        Account acc2 = TDF_AccountUtils.creatActiveAccountWithCVRAndOwner('12345670');

        insert new List<Account>{acc0, acc1, acc2};

        List<Account> accounts;

        accounts = new Query('Account').
                    selectAllFields().
                    orderBy('CVR__c', 'DESC').
                    run();

        Assert.areEqual(accounts.get(0).CVR__c, '12345679');
        Assert.areEqual(accounts.get(1).CVR__c, '12345678');
        Assert.areEqual(accounts.get(2).CVR__c, '12345670');
        
    }

    @isTest
    static void multipleOrderTest() {
        Account acc0 = TDF_AccountUtils.creatActiveAccountWithCVRAndOwner('12345678');
        acc0.Rating='A';
        acc0.Phone='123';
        Account acc1 = TDF_AccountUtils.creatActiveAccountWithCVRAndOwner('12345679');
        acc1.Rating='B';
        acc1.Phone='124';
        Account acc2 = TDF_AccountUtils.creatActiveAccountWithCVRAndOwner('12345670');
        acc2.Rating='B';
        acc2.Phone='125';
        insert new List<Account>{acc0, acc1, acc2};

        List<Account> accounts;

        accounts = new Query('Account').
                    selectAllFields().
                    orderBy('Rating', 'DESC').
                    orderBy('Phone', 'ASC').
                    run();

        Assert.areEqual(accounts.get(0).CVR__c, '12345679');
        Assert.areEqual(accounts.get(1).CVR__c, '12345670');
        Assert.areEqual(accounts.get(2).CVR__c, '12345678');
    }




    @isTest
    static void simpleSubqueryTest() {
        createData();

        List<Account> accounts;

        accounts = new Query('Account').
                   selectAllFields().
                   addSubquery('Opportunities').
                   run();

        assertAccount(accounts.get(0));
        Assert.isNotNull(accounts.get(0).Opportunities.get(0).Id);

        accounts = new Query('Account').
                   selectAllFields().
                   addSubquery(Query.subquery('Opportunities').selectAllFields()).
                   run();

        assertAccount(accounts.get(0));
        assertOpportunity(accounts.get(0).Opportunities.get(0));
    }

    @isTest
    static void conditionalSubqueryTest() {
        createData();

        List<Account> accounts;

        accounts = new Query('Account').
                    selectAllFields().
                    addSubquery(
                        Query.subquery('Opportunities').
                        selectAllFields()
                    ).
                    addSubquery(
                        Query.subquery('Tasks').
                        selectAllFields().
                        addConditionEq('Subject', 'New Task')
                    ).
                    run();

        assertAccount(accounts.get(0));
        assertOpportunity(accounts.get(0).Opportunities.get(0));
        assertTask(accounts.get(0).Tasks.get(0));

    }

    @isTest
    static void complexConditionalSubqueryTest() {
        createData();

        List<Account> accounts;

        accounts = new Query('Account').
                    selectAllFields().
                    addCondition(
                        Query.doOr(
                            Query.conditionIn('BillingCity', new Set<String>{'CP'}),
                            Query.conditionEq('Phone', '111')
                        )
                    ).
                    addSubquery(
                        Query.subquery('Opportunities').
                        selectFields('Name, CloseDate, Amount, Type, StageName').
                        addCondition(
                            Query.doOr(
                                Query.conditionNotEq('Name', 'N/A'),
                                Query.doAnd(
                                    Query.conditionEq('CloseDate', Date.today().addDays(5)),
                                    Query.conditionNotEq('Name', 'N/A'),
                                    Query.conditionNotEq('Name', 'N/A')
                                ),
                                Query.doOr(
                                    Query.conditionEq('CloseDate', Date.today().addDays(5)),
                                    Query.conditionNotEq('Name', 'N/A'),
                                    Query.conditionNotEq('Name', 'N/A')
                                )
                            )
                        )
                    ).
                    run();

        assertAccount(accounts.get(0));
        assertOpportunity(accounts.get(0).Opportunities.get(0));

    }

    @isTest
    static void toQueryStringTest() {
        createData();

        String queryString = new Query('Account').
                    selectAllFields().
                    addCondition(
                        Query.doOr(
                            Query.conditionIn('BillingCity', new Set<String>{'CP'}),
                            Query.conditionEq('Phone', '111')
                        )
                    ).
                    addSubquery(
                        Query.subquery('Opportunities').
                        selectFields('Name, CloseDate, Amount, Type, StageName').
                        addCondition(
                            Query.doOr(
                                Query.conditionEq('Name', 'N/A'),
                                Query.doAnd(
                                    Query.conditionEq('CloseDate', Date.today().addDays(1)),
                                    Query.conditionNotEq('Name', 'N/A')
                                ),
                                Query.doOr(
                                    Query.conditionEq('CloseDate', Query.TODAY),
                                    Query.conditionNotEq('Name', 'N/A')
                                )
                            )
                        )
                    ).
                    toQueryString();

        List<Account> accounts = Database.query(queryString);

        assertAccount(accounts.get(0));
        assertOpportunity(accounts.get(0).Opportunities.get(0));

    }

    @isTest
    static void conditionWithConstArgumentTest() {
        createData();

        Account account;
        Opportunity opp;

        account = (Account)new Query('Account').
                selectAllFields().
                addConditionEq('AnnualRevenue', null).
                fetch();

        assertAccount(account);

        account = (Account)new Query('Account').
                selectAllFields().
                addConditionNotEq('Name', null).
                fetch();

        assertAccount(account);

        opp = (Opportunity)new Query('Opportunity').
                selectAllFields().
                addConditionEq('IsPrivate', false).
                fetch();

        assertOpportunity(opp);

        opp = (Opportunity)new Query('Opportunity').
                selectAllFields().
                addConditionNotEq('IsPrivate', true).
                fetch();

        assertOpportunity(opp);
    }

    @isTest
    static void conditionFromStringTest(){
        createData();

        Account account;

        account = (Account) new Query('Account')
            .selectAllFields()
            .addConditionString('AnnualRevenue = NULL')
            .fetch();
        assertAccount(account);

        account = (Account) new Query('Account')
            .selectAllFields()
            .addConditionString('BillingCountry = \'DK\'')
            .fetch();
        assertAccount(account);

        account = (Account) new Query('Account')
            .selectAllFields()
            .addConditionString('(BillingCountry = \'DK\' AND (BillingCity IN (\'CP\', \'AH\')))')
            .fetch();
        assertAccount(account); 
        
        Query.QueryConditionException thrownException;
        try{
            new Query('Account')
                .selectAllFields()
                .addConditionString('= null) OR (Id !=null');
        }
        catch(Query.QueryConditionException e){
            thrownException=e;
        }
        Assert.isNotNull(thrownException);


        thrownException=null;
        try{
            new Query('Account')
                .selectAllFields()
                .addConditionString('Id = \'asdf');
        }
        catch(Query.QueryConditionException e){
            thrownException=e;
        }
        Assert.isNotNull(thrownException);
    }

    @isTest
    static void dateLiteralTest() {
        createData();

        Opportunity opp;

        opp = (Opportunity)new Query('Opportunity').
            selectAllFields().
            addConditionGe('CloseDate', Query.TODAY).
            fetch();

        assertOpportunity(opp);

        opp = (Opportunity)new Query('Opportunity').
            selectAllFields().
            addConditionGe('CloseDate', Query.YESTERDAY).
            fetch();

        assertOpportunity(opp);

        opp = (Opportunity)new Query('Opportunity').
            selectAllFields().
            addConditionLe('CloseDate', Query.NEXT_N_DAYS(5)).
            fetch();

        assertOpportunity(opp);

        opp = (Opportunity)new Query('Opportunity').
            selectAllFields().
            addConditionGe('CloseDate', Query.LAST_N_DAYS(10)).
            fetch();

        assertOpportunity(opp);

        opp = (Opportunity)new Query('Opportunity').
            selectAllFields().
            addConditionLe('CreatedDate', Query.NEXT_N_WEEKS(2)).
            fetch();

        assertOpportunity(opp);

        opp = (Opportunity)new Query('Opportunity').
            selectAllFields().
            addConditionGe('CreatedDate', Query.LAST_N_WEEKS(2)).
            fetch();

        assertOpportunity(opp);

        opp = (Opportunity)new Query('Opportunity').
            selectAllFields().
            addConditionLe('CreatedDate', Query.NEXT_N_MONTHS(2)).
            fetch();

        assertOpportunity(opp);

        opp = (Opportunity)new Query('Opportunity').
            selectAllFields().
            addConditionGe('CreatedDate', Query.LAST_N_MONTHS(2)).
            fetch();

        assertOpportunity(opp);

        opp = (Opportunity)new Query('Opportunity').
            selectAllFields().
            addConditionLe('CreatedDate', Query.NEXT_N_QUARTERS(2)).
            fetch();

        assertOpportunity(opp);

        opp = (Opportunity)new Query('Opportunity').
            selectAllFields().
            addConditionGe('CreatedDate', Query.LAST_N_QUARTERS(2)).
            fetch();

        assertOpportunity(opp);

        opp = (Opportunity)new Query('Opportunity').
            selectAllFields().
            addConditionLe('CreatedDate', Query.NEXT_N_YEARS(2)).
            fetch();

        assertOpportunity(opp);

        opp = (Opportunity)new Query('Opportunity').
            selectAllFields().
            addConditionGe('CreatedDate', Query.LAST_N_YEARS(2)).
            fetch();

        assertOpportunity(opp);

        opp = (Opportunity)new Query('Opportunity').
            selectAllFields().
            addConditionLe('CreatedDate', Query.NEXT_N_FISCAL_QUARTERS(2)).
            fetch();

        assertOpportunity(opp);

        opp = (Opportunity)new Query('Opportunity').
            selectAllFields().
            addConditionGe('CreatedDate', Query.LAST_N_FISCAL_QUARTERS(2)).
            fetch();

        assertOpportunity(opp);

        opp = (Opportunity)new Query('Opportunity').
            selectAllFields().
            addConditionLe('CreatedDate', Query.NEXT_N_FISCAL_YEARS(2)).
            fetch();

        assertOpportunity(opp);

        opp = (Opportunity)new Query('Opportunity').
            selectAllFields().
            addConditionGe('CreatedDate', Query.LAST_N_FISCAL_YEARS(2)).
            fetch();

        assertOpportunity(opp);
    }

    @isTest
    static void aggregateTest() {
        Account acc0 = TDF_AccountUtils.creatActiveAccountWithCVRAndOwner('12345678');
        Account acc1 = TDF_AccountUtils.creatActiveAccountWithCVRAndOwner('12345679');
        Account acc2 = TDF_AccountUtils.creatActiveAccountWithCVRAndOwner('12345670');
        Account acc3 = TDF_AccountUtils.creatActiveAccountWithCVRAndOwner('12345671');

        insert new List<Account>{acc0, acc1, acc2, acc3};

        AggregateResult result =
            new Query('Account').
            count('Name').
            count('Name', 'countName').
            countDistinct('BillingCountry').
            countDistinct('BillingCountry', 'countBillingCountry').
            max('NumberOfEmployees').
            max('NumberOfEmployees', 'maxEmployee').
            min('NumberOfEmployees').
            min('NumberOfEmployees', 'minEmployee').
            avg('NumberOfEmployees').
            avg('NumberOfEmployees', 'avgEmployee').
            sum('NumberOfEmployees').
            sum('NumberOfEmployees', 'sumEmployee').
            aggregate()[0];

        Assert.areEqual(result.get('countName'), 4);
        Assert.areEqual(result.get('expr0'), 4);
        Assert.areEqual(result.get('countBillingCountry'), 1);
        Assert.areEqual(result.get('expr1'), 1);
        Assert.areEqual(result.get('maxEmployee'), 10);
        Assert.areEqual(result.get('expr2'), 10);
        Assert.areEqual(result.get('minEmployee'), 10);
        Assert.areEqual(result.get('expr3'), 10);
        Assert.areEqual(result.get('avgEmployee'), 10);
        Assert.areEqual(result.get('expr4'), 10);
        Assert.areEqual(result.get('sumEmployee'), 40);
        Assert.areEqual(result.get('expr5'), 40);
    }

    @isTest
    static void toLabelTest() {
        Account acc = TDF_AccountUtils.creatActiveAccountWithCVRAndOwner('12345678');
        insert acc;

        Opportunity opp = new Opportunity(
            AccountId = acc.Id,
            Name = 'New Opportunity',
            CloseDate = Date.today().addDays(3),
            Amount = 20112.79,
            StageName = 'New',
            IsPrivate = false);
        insert opp;

        Sobject opportunitiesOne = new Query('Opportunity').
            selectField('Id').
            toLabel('StageName').
            byId(opp.Id).
            fetch();
        Assert.areEqual(opportunitiesOne.get('StageName'), 'New');

        Sobject opportunitiesTwo = new Query('Opportunity').
            toLabel('StageName', 'myStageName').
            byId(opp.Id).
            fetch();
        Assert.areEqual(opportunitiesTwo.get('myStageName'), 'New');
    }

    @isTest
    static void countQueryTest() {
        Account acc0 = TDF_AccountUtils.creatActiveAccountWithCVRAndOwner('12345678');
        Account acc1 = TDF_AccountUtils.creatActiveAccountWithCVRAndOwner('12345679');
        Account acc2 = TDF_AccountUtils.creatActiveAccountWithCVRAndOwner('12345670');
        Account acc3 = TDF_AccountUtils.creatActiveAccountWithCVRAndOwner('12345671');

        insert new List<Account>{acc0, acc1, acc2, acc3};

        Assert.areEqual(4, new Query('Account').countQuery());
        Assert.areEqual(1, new Query('Account').addConditionEq('CVR__c', '12345678').countQuery());
    }

    @isTest
    static void groupByTest() {

        Account acc0 = TDF_AccountUtils.creatActiveAccountWithCVRAndOwner('12345678');
        acc0.Rating = '1'; 
        acc0.NumberOfEmployees = 1;
        Account acc1 = TDF_AccountUtils.creatActiveAccountWithCVRAndOwner('12345679');
        acc1.Rating = '9'; 
        acc1.NumberOfEmployees = 3;
        Account acc2 = TDF_AccountUtils.creatActiveAccountWithCVRAndOwner('12345670');
        acc2.Rating = '1'; 
        acc2.NumberOfEmployees = 5;
        Account acc3 = TDF_AccountUtils.creatActiveAccountWithCVRAndOwner('12345671');
        acc3.Rating = null; 
        acc3.NumberOfEmployees = 7;
        insert new List<Account>{acc0, acc1, acc2, acc3};

        List<AggregateResult> results =
            new Query('Account').
            selectField('Rating', 'rate').
            count('Name', 'countName').
            max('NumberOfEmployees', 'maxEmployee').
            min('NumberOfEmployees', 'minEmployee').
            avg('NumberOfEmployees', 'avgEmployee').
            sum('NumberOfEmployees', 'sumEmployee').
            groupBy('Rating').
            aggregate();

        Map<String, AggregateResult> resultMap = new Map<String, AggregateResult>();

        for (AggregateResult result : results) {
            resultMap.put((String)result.get('rate'), result);
        }

        Assert.areEqual(resultMap.get('1').get('countName'), 2);
        Assert.areEqual(resultMap.get('1').get('maxEmployee'), 5);
        Assert.areEqual(resultMap.get('1').get('minEmployee'), 1);
        Assert.areEqual(resultMap.get('1').get('avgEmployee'), 3);
        Assert.areEqual(resultMap.get('1').get('sumEmployee'), 6);
        Assert.areEqual(resultMap.get('9').get('countName'), 1);
        Assert.areEqual(resultMap.get('9').get('maxEmployee'), 3);
        Assert.areEqual(resultMap.get('9').get('minEmployee'), 3);
        Assert.areEqual(resultMap.get('9').get('avgEmployee'), 3);
        Assert.areEqual(resultMap.get('9').get('sumEmployee'), 3);
    }

    @isTest
    static void groupByWithHavingTest() {

        Account acc0 = TDF_AccountUtils.creatActiveAccountWithCVRAndOwner('12345678');
        acc0.Rating = '1'; 
        acc0.NumberOfEmployees = 1;
        Account acc1 = TDF_AccountUtils.creatActiveAccountWithCVRAndOwner('12345679');
        acc1.Rating = '9'; 
        acc1.NumberOfEmployees = 3;
        Account acc2 = TDF_AccountUtils.creatActiveAccountWithCVRAndOwner('12345670');
        acc2.Rating = '1'; 
        acc2.NumberOfEmployees = 5;
        Account acc3 = TDF_AccountUtils.creatActiveAccountWithCVRAndOwner('12345671');
        acc3.Rating = null; 
        acc3.NumberOfEmployees = 7;
        insert new List<Account>{acc0, acc1, acc2, acc3};

        List<AggregateResult> results =
            new Query('Account').
            selectField('Rating').
            count('Name', 'countName').
            addConditionGe('NumberOfEmployees', 1).
            groupBy('Rating').
            addHaving(Query.doAnd(
                Query.conditionGe('Count(Name)', 2),
                Query.conditionNotEq('Rating', null)
            )).
            aggregate();

        Map<String, AggregateResult> resultMap = new Map<String, AggregateResult>();

        for (AggregateResult result : results) {
            resultMap.put((String)result.get('Rating'), result);
        }

        Assert.areEqual(resultMap.get('1').get('countName'), 2);
        Assert.areEqual(resultMap.get('9'), null);
    }

    @isTest
    static void allRowsTest() {
        Account acc = TDF_AccountUtils.creatActiveAccountWithCVRAndOwner('12345678');
        insert acc;

        Task task1 = new Task(Subject = 'Task1', WhatId = acc.Id);
        Task task2 = new Task(Subject = 'Task2', WhatId = acc.Id);
        Task task3 = new Task(Subject = 'Task3', WhatId = acc.Id);
        insert new List<Task>{task1, task2, task3};

        List<Task> allTasks = new Query('Task')
            .selectFields('Id')
            .allRows()
            .run();

        Assert.areEqual(3, allTasks.size());
    }

    @isTest
    static void semiJoinTest() {
        Account acc = TDF_AccountUtils.creatActiveAccountWithCVRAndOwner('12345678');
        insert acc;

        Opportunity opp = new Opportunity(
            AccountId = acc.Id,
            Name = 'New Opportunity',
            CloseDate = Date.today().addDays(3),
            Amount = 20112.79,
            StageName = 'New',
            IsPrivate = false);
        insert opp;

        Account acc2 = (Account)new Query('Account').
            addConditionIn('Id', new Query('Opportunity').
                    selectField('AccountId').
                    byId(opp.Id)).
            fetch();

        Assert.areEqual(acc.Id, acc2.Id);

        Account acc3 = (Account)new Query('Account').
            lookup('Id', new Query('Opportunity').
                    selectField('AccountId').
                    addConditionEq('StageName', 'New').
                    byId(opp.Id)).
            addConditionEq('BillingCity', 'CP').
            fetch();

        Assert.areEqual(acc.Id, acc3.Id);

        Opportunity opp2 = (Opportunity)new Query('Opportunity').
            lookup('AccountId', new Query('Account').
                    selectField('Id').
                    byId(acc.Id)).
            fetch();

        Assert.areEqual(opp.Id, opp2.Id);
    }

    static void antiJoinTest() {
        Account acc1 = TDF_AccountUtils.creatActiveAccountWithCVRAndOwner('12345678');
        insert acc1;
        Account acc2 = TDF_AccountUtils.creatActiveAccountWithCVRAndOwner('12345679');
        insert acc2;

        Opportunity opp = new Opportunity(
            AccountId = acc1.Id,
            Name = 'New Opportunity',
            CloseDate = Date.today().addDays(3),
            Amount = 20112.79,
            StageName = 'New',
            IsPrivate = false);
        insert opp;

        Account acc3 = (Account)new Query('Account').
            addConditionNotIn('Id', new Query('Opportunity').
                    selectField('AccountId').
                    byId(opp.Id)).
            fetch();

        Assert.areEqual(acc2, acc3);
    }
    @isTest
    static void fieldSettingTest() {
        Account account = TDF_AccountUtils.creatActiveAccountWithCVRAndOwner('12345678');
        account.Rating = '1'; 
        account.NumberOfEmployees = 1;
        insert account;
        Query.FieldSetting setting = new Query.FieldSetting();
        setting.isAccessible = true;
        setting.isNameField = true;

        Account acc = (Account)new Query('Account').selectAllFields(setting).byId(account.Id).fetch();
        Assert.isNotNull(acc.Name);
    }
   
    @isTest
    static void debugTest() {
        Id id = '001O000000qkv3KIAQ';
        List<Id> idList = new List<Id>{id};
        Set<Id> idSet = new Set<Id>{id};
        List<String> stringList = new List<String>();
        Set<String> stringSet = new Set<String>();
        List<Decimal> decimalList = new List<Decimal>{1.234};
        Set<Decimal> decimalSet = new Set<Decimal>{1.234};
        List<Integer> integerList = new List<Integer>{1};
        Set<Integer> integerSet = new Set<Integer>{1};

        Query query = new Query('Account').
            addConditionEq('RecordTypeId', id).
            addConditionEq('OwnerId', id).
            addConditionEq('CreatedBy', id).
            addConditionEq('LastModifiedBy', id).
            addConditionEq('Owner', id).
            addConditionEq('RecordTypeId', idList).
            addConditionEq('OwnerId', idList).
            addConditionEq('CreatedBy', idList).
            addConditionEq('RecordTypeId', idSet).
            addConditionEq('OwnerId', idSet).
            addConditionEq('CreatedBy', idSet).
            addConditionIn('LastModifiedBy', stringList).
            addConditionIn('Owner', stringList).
            addConditionIn('LastModifiedBy', stringSet).
            addConditionIn('Owner', stringSet).
            addConditionIn('AnnualRevenue', decimalList).
            addConditionIn('AnnualRevenue', decimalSet).
            addConditionIn('NumberOfEmployees', integerList).
            addConditionIn('NumberOfEmployees', integerSet).
            addConditionEq('NumberOfEmployees', 1).
            debug();

        Assert.isNotNull(query);
    }

    @isTest
    static void debugInTheMiddleTest() {
        Integer c = new Query('Account').debug().countQuery();
        Assert.isNotNull(c);
    }

    static void createData() {
        Account acc = TDF_AccountUtils.creatActiveAccountWithCVRAndOwner();
        
        insert acc;

        List<Opportunity> opps = TDF_OpportunityUtils.createOpportunitiesForAccounts(1, new List<Account> {acc});

        Task task = new Task();
        task.WhatId = acc.Id;
        task.Subject = 'New Task';

        insert task;

    }

    static void assertAccount(Account acc) {
        Assert.areEqual(acc.Phone, '111');
        Assert.areEqual(acc.BillingCity, 'CP');
        Assert.areEqual(acc.BillingPostalCode, '2000');
        Assert.areEqual(acc.BillingCountry, 'DK');
        Assert.areEqual(acc.CVR__c, '12345678');
    }

    static void assertOpportunity(Opportunity opp) {
        Assert.areEqual(opp.Type, 'New Business');
        Assert.areEqual(opp.CloseDate, Date.today().addDays(5));
        Assert.areEqual(opp.StageName, 'Proposal');
    }

    static void assertTask(Task task) {
        Assert.areEqual(task.Subject, 'New Task');
    }

}