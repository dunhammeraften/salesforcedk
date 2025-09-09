@IsTest
public class ActivationlineCreateAmendmentTest {

    @TestSetup
    static void dataPrepMethod(){
 		Account acct = new Account(Name='TestAccount', BillingCity='CP',BillingPostalCode = '2000',BillingCountry = 'DK'
                                           ,BillingStreet = 'Holmbladsgade 133', Phone = '111', CVR__c ='12345678');
                insert acct;
          Id standardPriceBookId = Test.getStandardPricebookId();
        
                Product2 pr = new Product2(ProductAPI_Telia_Product_Id__c='CORFRI10G', 
                                           Telia_Product_Code__c  ='CORFRI10G',
                                           name = 'Corporate Fri tale EU 10 GB',
                                           SBQQ__SubscriptionType__c = 'Renewable', isActive=true, 
                                           Activation_Record_Type__c ='Voice');
                insert pr;
        
                SBQQ__ProductFeature__c productFeature =  new SBQQ__ProductFeature__c(
                    Name = 'Feature Name ' + 1,
                    SBQQ__Number__c = 1,
                    SBQQ__ConfiguredSKU__c = pr.Id,
                    SBQQ__Category__c = 'TPX'); 
         insert productFeature;  
        
           SBQQ__ProductOption__c productoption = new SBQQ__ProductOption__c(
                    SBQQ__Quantity__c = 5,
                    SBQQ__Number__c = 4,
                    SBQQ__ConfiguredSKU__c = pr.Id,
                    SBQQ__OptionalSKU__c = pr.Id,
                    SBQQ__Feature__c = productFeature.Id
                );
                insert productoption;

                Opportunity opp = new Opportunity(AccountId = acct.Id, Name = 'Test',
                                                 Pricebook2Id =standardPriceBookId,
                                                 SBQQ__Renewal__c = false,
                                                 SBQQ__AmendedContract__c = null,
                                                 StageName='Qualification', CloseDate =Date.Today());
                insert opp;
        
                SBQQ__Quote__c quo = new SBQQ__Quote__c(
                    SBQQ__BillingFrequency__c= 'kvartalsvis.',
                    SBQQ__PaymentTerms__c = '3',
                    SBQQ__SubscriptionTerm__c = 36,
                    SBQQ__Account__c=acct.Id,
                    Invoice_Email__c = 'tuba@tuba.com',
                	SBQQ__Opportunity2__c = opp.Id);
                insert quo;  
        
            SBQQ__QuoteLine__c newQuotelineRecord = new SBQQ__QuoteLine__c(
            SBQQ__ProductOption__c = productoption.Id,
            SBQQ__Quantity__c = 3,
        	Additional_Quantity__c = 1,
            SBQQ__Product__c = pr.Id,
            SBQQ__Quote__c = quo.Id
        );
        
        insert newQuotelineRecord;
                
                Case cs = new case(Root_BAN__c = '232312345',Quote__c = quo.Id,AccountId = acct.Id);
                insert cs;  
        
        quo.Case__c = cs.Id;
        update quo;
     
         String strRecordTypeId = [Select Id From RecordType Where SobjectType = 'Activation_line__c' and developername = 'Voice_activation_line'].Id;


        Contract cr = new Contract(AccountId = acct.Id,
                                                           Total_Contract_value__c = decimal.valueOf(6000),
                                                           //ContractTerm = 36,
                                                           //StartDate = Date.today().addDays(-1),
                                                           //Status = 'Activated',
                                                           Migrated_Contract__c = true,
                                                           Pricebook2Id = Test.getStandardPricebookId(),
                                                           SBQQ__AmendmentPricebookId__c = Test.getStandardPricebookId(),
                                                           SBQQ__RenewalPricebookId__c = Test.getStandardPricebookId(),
                                                           SBQQ__AmendmentRenewalBehavior__c = 'Latest End Date',
                                                           Product_s_in_scope__c = 'Voice',
                                                           SBQQ__RenewalTerm__c = 36,
                                                           Mobile_Part_of_Contract__c = true,
                                   						   SBQQ__RenewalForecast__c = false
                                                            ); 
        insert cr;
        
        cr.Status = 'Activated';
        cr.StartDate = Date.newInstance(2012, 12, 12);
        cr.SBQQ__RenewalForecast__c = false;
        cr.ContractTerm = 36;
        cr.Renewal_Opportunity_Creation_Date__c = Date.newInstance(2012, 12, 12);
        
        update cr;
        
        opp.SBQQ__AmendedContract__c = cr.Id;
        update opp;
        

         SBQQ__Subscription__c newSubscription = new SBQQ__Subscription__c(
                         SBQQ__Contract__c = cr.Id,
                         SBQQ__Discount__c = 0,
                         SBQQ__Product__c = pr.Id,
                         SBQQ__Quantity__c = 1, //TODO!!
                         SBQQ__Account__c = acct.Id,
                         SBQQ__ProductSubscriptionType__c = 'Renewable',
                         SBQQ__SubscriptionType__c = 'Renewable',
                         SBQQ__RenewalQuantity__c = 1,   //TODO trigger
                         SBQQ__RenewalPrice__c = 0,
                         SBQQ__NetPrice__c = 0,
                         SBQQ__CustomerPrice__c = 0,
                         SBQQ__ListPrice__c = 0,
                         SBQQ__RegularPrice__c = 0,
                         SBQQ__SpecialPrice__c = 0,
         				 SBQQ__QuoteLine__c =newQuotelineRecord.Id );
         insert newSubscription;

        Subscription_Line_Detail__c SubscriptionLine = new Subscription_Line_Detail__c();
        
                    SubscriptionLine.Subscription__c =  newSubscription.Id;
                    SubscriptionLine.First_name__c = 'Test';
                    SubscriptionLine.Max_Monthly_Data_Used_MB__c =0;
                    SubscriptionLine.Manual_Product__c = newQuotelineRecord.SBQQ__Product__c;
                    SubscriptionLine.Fokus_SOC__c = 'CORP1';
                    SubscriptionLine.Mobile_no__c = '124578';
                    SubscriptionLine.Avg_Monthly_Data_Used_MB__c = 0;
                    SubscriptionLine.EAN_number__c = 0;
        
        insert SubscriptionLine;
        
        newQuotelineRecord.SBQQ__UpgradedSubscription__c = newSubscription.Id;
        newQuotelineRecord.SBQQ__ProductOption__c = productoption.Id;
        newQuotelineRecord.SBQQ__Quantity__c = 3;
        update newQuotelineRecord;
                 
        
        Activation__c ActivationRec = new Activation__c(
                                        Case__c = cs.Id ,
                                        RecordTypeId = Schema.sObjectType.Activation__c.getRecordTypeInfosByName().get('Voice activation').getRecordTypeId(),
                                         TP_X_Upsell__c = true,
                                         Name = 'Voice - New',
                                         Type__c = 'New');
        insert ActivationRec;
    }

    @IsTest
    static void querySelectorTest(){
     Test.startTest();
        List<SBQQ__Quote__c> quotesList = [SELECT Id FROM SBQQ__Quote__c limit 1];
        list <Opportunity> opplist = [SELECT Id FROM Opportunity limit 1];
        List<Id> quoteIdsList = new List<Id>();
        quotesList[0].SBQQ__Opportunity2__c  = opplist[0].Id;
        update quotesList[0];
        quoteIdsList.add(quotesList[0].Id);
       
        
        Product2 AddressProduct = new Product2(
            Name = 'Test Address Product',
            isActive = true,
            ProductCode = '3122',
            address_required__c = true,
            Activation_Record_Type__c = 'Fiber',
            activate_with_other_products__c = false
        );
        insert AddressProduct;
        
        Address_line__c  newaddLine = new Address_line__c (Quote__c=quotesList[0].Id, AdrProduct__c = AddressProduct.Id);
		insert  newaddLine;
        

        SBQQ__QuoteLine__c newQL = new SBQQ__QuoteLine__c(SBQQ__Product__c = AddressProduct.id,
                                                         SBQQ__Quote__c = quotesList[0].Id,
                                                         Additional_Quantity__c = 3,
                                                         SBQQ__SegmentIndex__c = 1,
                                                         Address_filled_on_activation_lines__c = true);
       insert newQL;
        
        List<SBQQ__QuoteLine__c> quoteLinesList = [SELECT Id,SBQQ__Quote__r.SBQQ__Opportunity2__r.SBQQ__Renewal__c FROM SBQQ__QuoteLine__c where SBQQ__Quote__c =: quotesList[0].Id ];

        system.debug(quoteLinesList[0].SBQQ__Quote__r.SBQQ__Opportunity2__r.SBQQ__Renewal__c);
        
 
        Activation_line_Create_Iterable ProcessBatch = new Activation_line_Create_Iterable();
            String batchQuery = 'SELECT Id,Activation_Record_Type__c,Activation__c, SBQQ__Quote__r.SBQQ__BillingCity__c , ' +
            'SBQQ__Quote__r.SBQQ__BillingPostalCode__c, SBQQ__Quote__r.SBQQ__BillingStreet__c, SBQQ__Quote__c, SBQQ__Quantity__c , ' +
            'SBQQ__Quote__r.SBQQ__BillingCountry__c,SBQQ__Product__c, Additional_Quantity__c, ' +
            'SBQQ__ProductCode__c, Address_filled_on_activation_lines__c, SBQQ__SegmentIndex__c,' +
            ' SBQQ__Quote__r.SBQQ__Opportunity2__r.Case__c, SBQQ__Product__r.address_required__c,SBQQ__Quote__r.Account_Name__c, '+
            ' SBQQ__Quote__r.SBQQ__Opportunity2__r.SBQQ__Renewal__c, SBQQ__Quote__r.SBQQ__Opportunity2__r.SBQQ__AmendedContract__c ' +
            ' from SBQQ__QuoteLine__c ' +
            ' where Activation_Record_Type__c <>\'No activation needed\'' +
            ' and SBQQ__EffectiveQuantity__c >0 and SBQQ__Quote__c =\'' + quotesList[0].Id + '\' and SBQQ__Product__r.activate_with_other_products__c = false' +
            ' order by SBQQ__Product__c desc';
            ProcessBatch.query = batchQuery; 
            ProcessBatch.recordId = String.valueOf(quotesList[0].Id);
            ID batchprocessid = Database.executeBatch(ProcessBatch);
        
        
        Test.stopTest();
   }
    }