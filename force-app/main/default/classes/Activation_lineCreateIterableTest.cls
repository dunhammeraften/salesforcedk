@IsTest
public class Activation_lineCreateIterableTest {

    @TestSetup
    static void dataPrepMethod(){
 		Account acct = new Account(Name='TestAccount', BillingCity='CP',BillingPostalCode = '2000',BillingCountry = 'DK'
                                           ,BillingStreet = 'Holmbladsgade 133', Phone = '111', CVR__c ='12345678');
                insert acct;
          Id standardPriceBookId = Test.getStandardPricebookId();

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
                
                Case cs = new case(Root_BAN__c = '232312345',Quote__c = quo.Id,AccountId = acct.Id);
                insert cs;  
        
        		opp.Case__c = cs.Id;
        		opp.SBQQ__Renewal__c = false;
        		opp.SBQQ__AmendedContract__c = null;
				update opp;
                 
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