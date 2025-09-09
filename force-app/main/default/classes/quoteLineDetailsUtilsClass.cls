public class quoteLineDetailsUtilsClass {

    @AuraEnabled(cacheable=true)
    public static quoteInformationWrapper wrapperProvider( String theQuoteId ){
        return new quoteInformationWrapper( theQuoteId );
    }
    //1700 start
    @AuraEnabled
    public static quoteInformationWrapper wrapperProviderSingleGroup( String quoteLineId ){
        return new quoteInformationWrapper( 'QuoteLine', quoteLineId.replaceAll('"','') );
    }
    //1700 end

    public virtual class baseUtilsClassException extends Exception {}
    public class wrapperException extends baseUtilsClassException {}

    static List<String> bannedCategoryList = new List<String>{
        //'Touchpoint'
    };
    static List<String> bannedProducts = new List<String>{
        //'TPX Corporate Fri Tale'
    };

    // Data wrapper for sending to LWC
    // 

    public class quoteInformationWrapper{
        @AuraEnabled
        public SBQQ__Quote__c theQuote{get;set;}
        @AuraEnabled
        public List<SBQQ__QuoteLine__c> theLinesWithDetails{get;set;}
        @AuraEnabled
        public List<SBQQ__QuoteLine__c> theColumns{get;set;}

        List<String> bannedCategoryList = new List<String>{
            //'Touchpoint'
        };
        List<String> bannedProducts = new List<String>{
            //'TPX Corporate Fri Tale'
        };
        
        quoteInformationWrapper( String quoteId ){
            this.theQuote = [SELECT Id, Quote_Preparation_Lock__c FROM SBQQ__Quote__c WHERE id = :quoteId];
            this.theLinesWithDetails = [SELECT Id, SBQQ__AdditionalDiscountAmount__c, Activate_with_other_products__c, Category_and_Feature__c, SBQQ__Quote__c, SBQQ__ProductName__c,SBQQ__Product__c, SBQQ__RequiredBy__c, SBQQ__Quantity__c, Additional_Quantity__c, SBQQ__Quote__r.SBQQ__StartDate__c, (SELECT Id,VAS_UC_License__c,Is_UC_Licenses_updated__c, Main_Service_Upgrade_Checker__c, Termination_verifier__c, Changes_List_to_a_Service__c,Category_and_Feature__c, MobileFixedCircuit__c, Mobile_no__c, Fixed_no__c, Circuit_ID__c, First_name__c, Last_name__c, Quote_Line__r.SBQQ__Quote__r.SBQQ__StartDate__c, Product_Name__c, Avg_Monthly_Data_Used_MB__c, Max_Monthly_Data_Used_MB__c, Data_Usage_Analyzer__c, Calls_from_DK_to_EU_MIN__c FROM Quote_Line_Details__r) FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c = :quoteId AND SBQQ__Hidden__c = false AND Activate_with_other_products__c = false AND SBQQ__ProductOption__r.SBQQ__Feature__r.SBQQ__Category__c NOT IN :bannedCategoryList]; // added VAS_UC_License__c in the both query 1700
            
            this.theColumns = [SELECT Id, SBQQ__AdditionalDiscountAmount__c, Activate_with_other_products__c, Category_and_Feature__c, SBQQ__Quote__c,SBQQ__ProductName__c,SBQQ__Product__c, SBQQ__RequiredBy__c, SBQQ__Quantity__c, Additional_Quantity__c, SBQQ__Quote__r.SBQQ__StartDate__c, (SELECT Id,VAS_UC_License__c,Is_UC_Licenses_updated__c, Termination_verifier__c, Category_and_Feature__c, MobileFixedCircuit__c, Mobile_no__c, Fixed_no__c, Circuit_ID__c, First_name__c, Last_name__c, Quote_Line__r.SBQQ__Quote__r.SBQQ__StartDate__c, Data_Usage_Analyzer__c, Product_Name__c FROM Quote_Line_Details__r) FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c = :quoteId AND SBQQ__Hidden__c = false AND Activate_with_other_products__c = true];  // added VAS_UC_License__c in the both query 1700
            // SBQQ__RequiredBy__c <-- to find which bundle it is realted to ; SBQQ__ProductName__c <-- to display 
        }

        quoteInformationWrapper( String objectName, String objectId ){
        
            switch on objectName {
                when 'QuoteLine' {
                    // The logic for QuoteLine
                    this.theLinesWithDetails = [SELECT Id, Category_and_Feature__c, SBQQ__RequiredBy__c, SBQQ__Quote__c FROM SBQQ__QuoteLine__c WHERE Id = :objectId ];
                    
                    this.theQuote = new SBQQ__Quote__c( Id = this.theLinesWithDetails[0].SBQQ__Quote__c );

                    String searchExpresion = (this.theLinesWithDetails[0].Category_and_Feature__c != null && this.theLinesWithDetails[0].Category_and_Feature__c != '' && this.theLinesWithDetails[0].Category_and_Feature__c != ';') ? this.theLinesWithDetails[0].Category_and_Feature__c.split(';',0)[0] + '%' : ''; // IF( ISBLANK(Mobile_no__c) , IF(ISBLANK(Fixed_no__c), Circuit_ID__c, Fixed_no__c), Mobile_no__c)

                     // Do przepisania ... logika wyciągająca daneo grupie ...
                     // Teraz są dane zgrupowane poprzed RequiredBy+Category
                    this.theLinesWithDetails = [SELECT Id, SBQQ__AdditionalDiscountAmount__c, Activate_with_other_products__c, Category_and_Feature__c, SBQQ__Quote__c, SBQQ__ProductName__c, SBQQ__RequiredBy__c, SBQQ__Quantity__c, Additional_Quantity__c, SBQQ__Quote__r.SBQQ__StartDate__c, (SELECT Id, Main_Service_Upgrade_Checker__c, Termination_verifier__c, Changes_List_to_a_Service__c, Category_and_Feature__c, MobileFixedCircuit__c, Mobile_no__c, Fixed_no__c, Circuit_ID__c, First_name__c, Last_name__c, Quote_Line__r.SBQQ__Quote__r.SBQQ__StartDate__c, Product_Name__c, Avg_Monthly_Data_Used_MB__c, Max_Monthly_Data_Used_MB__c, Data_Usage_Analyzer__c, Calls_from_DK_to_EU_MIN__c,VAS_UC_License__c,Is_UC_Licenses_updated__c FROM Quote_Line_Details__r) FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c = :this.theQuote.Id AND Category_and_Feature__c LIKE :searchExpresion AND SBQQ__RequiredBy__c = :this.theLinesWithDetails[0].SBQQ__RequiredBy__c AND SBQQ__Hidden__c = false AND Activate_with_other_products__c = false AND SBQQ__Product__r.Name NOT IN :bannedProducts]; // added VAS_UC_License__c 1700
                    
                    Set<String> listOfNumbers = new Set<String>();
                    List<Id> mainQLIds = new List<Id>();    // It is not really needed casue we check activate with other but ... :P just in case
                    for( SBQQ__QuoteLine__c singleQL: theLinesWithDetails ){
                        mainQLIds.add( singleQL.Id );
                        for( Quote_Line_Detail__c singleQLD: singleQL.Quote_Line_Details__r ){
                            listOfNumbers.add( singleQLD.MobileFixedCircuit__c );
                        }
                    }
                    if( !Test.isRunningTest() ) this.theColumns = [SELECT Id, SBQQ__AdditionalDiscountAmount__c, Activate_with_other_products__c, Category_and_Feature__c, SBQQ__ProductName__c, SBQQ__RequiredBy__c, SBQQ__Quantity__c, Additional_Quantity__c, SBQQ__Quote__r.SBQQ__StartDate__c, (SELECT Id, Termination_verifier__c, MobileFixedCircuit__c, Mobile_no__c, Fixed_no__c, Circuit_ID__c, First_name__c, Last_name__c, Quote_Line__r.SBQQ__Quote__r.SBQQ__StartDate__c, Data_Usage_Analyzer__c, Product_Name__c FROM Quote_Line_Details__r WHERE MobileFixedCircuit__c IN :listOfNumbers) FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c = :this.theQuote.Id AND Id NOT IN :mainQLIds AND SBQQ__RequiredBy__c = :theLinesWithDetails[0].SBQQ__RequiredBy__c AND SBQQ__Hidden__c = false AND Activate_with_other_products__c = true AND Category_and_Feature__c LIKE :searchExpresion AND SBQQ__Product__r.Name NOT IN :bannedProducts];
                    else this.theColumns = [SELECT Id, SBQQ__AdditionalDiscountAmount__c, Activate_with_other_products__c, Category_and_Feature__c, SBQQ__ProductName__c, SBQQ__RequiredBy__c, SBQQ__Quantity__c, Additional_Quantity__c, SBQQ__Quote__r.SBQQ__StartDate__c, (SELECT Id, Termination_verifier__c, MobileFixedCircuit__c, Mobile_no__c, Fixed_no__c, Circuit_ID__c, First_name__c, Last_name__c, Quote_Line__r.SBQQ__Quote__r.SBQQ__StartDate__c, Data_Usage_Analyzer__c, Product_Name__c FROM Quote_Line_Details__r WHERE MobileFixedCircuit__c IN :listOfNumbers) FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c = :this.theQuote.Id AND Id NOT IN :mainQLIds AND SBQQ__Hidden__c = false AND Activate_with_other_products__c = true]; // Should be removed ... Added only to anable with less work deployment on 19.02.2022, to be removed requires set up of proper data creation class that will build bundles and quotes for the bundles that meet requirements of this class..
                }
                when else {
                    throw new wrapperException( 'There is no logic defined for Object Name:' + objectName + '. Please contact your Administrator about this issue\n and provide him/her with this text. Also steps taken before the error occured.' );
                }
            }
        }

    }

    // Changes wrapper for receiving from LWC

    @TestVisible
    private class changeRequest{
        public String parentId,mainServiceId,action,requiredBy,category;
    }

    // Communication methods

    @AuraEnabled
    public static quoteInformationWrapper changeOfProduct( String theBody ){

        List<changeRequest> theChangesRequested = (List<changeRequest>)JSON.deserializeStrict( theBody, List<changeRequest>.class );// change comes from single table only

        Map<Id,Id> quoteLineDetailIdToNewQuoteLineIdMap = new Map<Id,Id>();
        for( changeRequest singleChange : theChangesRequested ){
            quoteLineDetailIdToNewQuoteLineIdMap.put( singleChange.mainServiceId, singleChange.parentId);
        }

        List<Quote_Line_Detail__c> toBeUpdated = new List<Quote_Line_Detail__c>();
        for( changeRequest singleChange : theChangesRequested ){
            toBeUpdated.add( new Quote_Line_Detail__c(
                Id = singleChange.mainServiceId,
                Quote_Line__c = singleChange.parentId
            ) );
        }

        try {
            update toBeUpdated;
        } catch ( Exception e) {
            errorHandlingForRenewalUtilityClass( 'Error occured in quoteLineDetailsUtilsClass.changeOfProduct on event Update of QLD paren QL.', 'There has been an error during quoteLineDetailsUtilsClass.changeOfProduct processing. Please contact your administrator about this issue. \n The Error:' + e.getMessage(), e );
        }

        return new quoteInformationWrapper( 'QuoteLine', toBeUpdated[0].Quote_Line__c );
    }

    @AuraEnabled
    public static quoteInformationWrapper terminationOfProduct( String theBody ){ // We should with the same code solv untermination

        List<changeRequest> theChangesRequested = (List<changeRequest>)JSON.deserializeStrict( theBody, List<changeRequest>.class );// change comes from single table only
        List<Quote_Line_Detail__c> toBeUpdated = new List<Quote_Line_Detail__c>();
        for( changeRequest singleChange : theChangesRequested ){
            toBeUpdated.add( new Quote_Line_Detail__c(
                Id = singleChange.mainServiceId, // Update termination date + status
                Number_Porting_Specific_Date__c = ( singleChange.action.contains( 'Termination:' ) ? Date.valueOf( singleChange.action.remove('Termination:') ) : null ),
                Phone_no_Status__c = ( singleChange.action.contains( 'Termination:' ) ? 'Opsigelse' : null )
            ) );
        }

        try {
            update toBeUpdated;
        } catch ( Exception e) {
            errorHandlingForRenewalUtilityClass( 'Error occured in quoteLineDetailsUtilsClass.changeOfProduct on event Update of QLD paren QL.', 'There has been an error during quoteLineDetailsUtilsClass.changeOfProduct processing. Please contact your administrator about this issue. \n The Error:' + e.getMessage(), e );
        }
        // Options cleaning from terminated records
        List<Id> terminatdQLDIds = new List<Id>();
        for( Quote_Line_Detail__c singleQLD: toBeUpdated ){
            if( singleQLD.Phone_no_Status__c != null ) terminatdQLDIds.add( singleQLD.Id );
        }
        if( terminatdQLDIds.size() > 0 ){
            List<Quote_Line_Detail__c> theServices = [SELECT Id, MobileFixedCircuit__c, Quote_Line__r.SBQQ__Quote__c FROM Quote_Line_Detail__c WHERE Id IN :terminatdQLDIds];

            Set<String> identificationsList = new Set<String>();
            for( Quote_Line_Detail__c singleQLD: theServices ){
                identificationsList.add( singleQLD.MobileFixedCircuit__c );
            }
            
            List<Quote_Line_Detail__c> optionsFromTerminatedServices = [SELECT Id, Quote_Line__c, MobileFixedCircuit__c, Quote_Line__r.SBQQ__RequiredBy__c, Quote_Line__r.Category_and_Feature__c FROM Quote_Line_Detail__c WHERE MobileFixedCircuit__c IN :identificationsList AND Quote_Line__r.Activate_with_other_products__c = true AND Quote_Line__r.SBQQ__Quote__c = :theServices[0].Quote_Line__r.SBQQ__Quote__c AND Quote_Line__r.SBQQ__Hidden__c = false];
            String categoryAndFeatureParent = [SELECT Quote_Line__r.Category_and_Feature__c FROM Quote_Line_Detail__c WHERE MobileFixedCircuit__c IN :identificationsList AND Quote_Line__r.Activate_with_other_products__c = false AND Quote_Line__r.SBQQ__Quote__c = :theServices[0].Quote_Line__r.SBQQ__Quote__c AND Quote_Line__r.SBQQ__Hidden__c = false LIMIT 1].Quote_Line__r.Category_and_Feature__c;

            // Create change records for changesSending( theBody )
            List<changeRequest> listOfChanges = new List<changeRequest>();
            for( Integer i = 0 ; i<optionsFromTerminatedServices.size() ; ++i ){
                listOfChanges.add( new changeRequest() );
                listOfChanges[i].parentId = optionsFromTerminatedServices[i].Quote_Line__c;
                listOfChanges[i].mainServiceId = optionsFromTerminatedServices[i].MobileFixedCircuit__c;
                listOfChanges[i].action = 'delete';
                listOfChanges[i].requiredBy = optionsFromTerminatedServices[i].Quote_Line__r.SBQQ__RequiredBy__c;
                listOfChanges[i].category = categoryAndFeatureParent;
            }

            System.debug('MT907:'+listOfChanges);
            if( listOfChanges.size() > 0 ) changesSending( JSON.serialize( listOfChanges ) );// Add test case when there are no addons to delete!

        }

        return new quoteInformationWrapper( 'QuoteLine', theChangesRequested[0].parentId );
    }

    //private class changeRequest{
    //    public String parentId,mainServiceId,action,requiredBy,category;
    //}


    @AuraEnabled
    public static quoteInformationWrapper additionalChangesSending( String theBody ){
        
        List<changeRequest> theChangesRequested = (List<changeRequest>)JSON.deserializeStrict( theBody, List<changeRequest>.class );

        List<SBQQ__QuoteLine__c> recordsToUpdate = new List<SBQQ__QuoteLine__c>();
        for( changeRequest singleChange : theChangesRequested ){
            recordsToUpdate.add( new SBQQ__QuoteLine__c(
                id = singleChange.parentId,
                Additional_Quantity__c = Decimal.valueOf(singleChange.mainServiceId)
            ) ); // We need to re trigger quantity counting for those QLs ...
        }

        if( recordsToUpdate.size() > 0 ){
            try{
                update recordsToUpdate;
            } catch( Exception e ){
                errorHandlingForRenewalUtilityClass( 'Error occured in quoteLineDetailsUtilsClass.additionalChangesSending on event of Updateing additional quantity.', 'There has been an error during quoteLineDetailsUtilsClass.additionalChangesSending processing. Please contact your administrator about this issue. \n The Error:' + e.getMessage(), e );
            }
        }

        String searchExpresion = (theChangesRequested[0].category != null ? theChangesRequested[0].category : '') + '%';
        Id QLIdOfMainProduct = [SELECT Id FROM SBQQ__QuoteLine__c WHERE SBQQ__RequiredBy__c = :theChangesRequested[0].requiredBy AND SBQQ__Hidden__c = false AND Activate_with_other_products__c = false AND Category_and_Feature__c LIKE :searchExpresion LIMIT 1].Id;  // We need main product id or one of group of main products to query the change

        return new quoteInformationWrapper( 'QuoteLine', QLIdOfMainProduct );
    }
    //1700 start
    public class changeRequestUCLicense{
        public string Id,UcLicenseValue,productType,quoteId,productId;
    }
    @AuraEnabled
    public static boolean updateQuotelineDetail(String theBody){
        boolean isSuccess=false;
        string productType;
        string searchProductType,searchProductName;
        Map<string ,integer> mapProductTypeName = new Map<string ,integer>();
        set<string> setProductName = new set<string>();
        Map<string, integer> mapUCValueCount = new Map<string, integer>();
        string quoteId;
        integer countTPXMOBIL=0,countTPXCOMB=0,countTPXLIM=0;
        List<changeRequestUCLicense> theChangesRequested = (List<changeRequestUCLicense>)JSON.deserializeStrict( theBody, List<changeRequestUCLicense>.class ), theChangesPerformed = new List<changeRequestUCLicense>();
        //List<Quote_Line_Detail__c> listQuoteLineDetail  = new List<Quote_Line_Detail__c>();
        Map<Id, Quote_Line_Detail__c> mapQuoteLineDetail = new Map<Id, Quote_Line_Detail__c>();
        List<SBQQ__QuoteLine__c> insertListQuoteLine  = new List<SBQQ__QuoteLine__c>();
        List<SBQQ__QuoteLine__c> updateListQuoteLine  = new List<SBQQ__QuoteLine__c>();
        List<SBQQ__QuoteLine__c> deleteListQuoteLine  = new List<SBQQ__QuoteLine__c>();
        Map<Id, SBQQ__ProductOption__c> mapProductOption = new Map<Id, SBQQ__ProductOption__c>();
        Map<string, SBQQ__QuoteLine__c> mapexistingQuoteline = new Map<string, SBQQ__QuoteLine__c>();
        Map<Id, SBQQ__QuoteLine__c> updateListQuoteLineMap = new Map<Id, SBQQ__QuoteLine__c>();
        for(changeRequestUCLicense iterator : theChangesRequested){
            if(iterator.Id != null && iterator.UcLicenseValue != null){
                quoteId= iterator.quoteId;
                mapQuoteLineDetail.put(iterator.Id, new Quote_Line_Detail__c (Id=iterator.Id , VAS_UC_License__c= iterator.UcLicenseValue , Is_UC_Licenses_updated__c =true));
                if(iterator.UcLicenseValue == 'TPXMOBIL'){
                    //searchProductType= '%Smartphone%';
                    countTPXMOBIL++;
                    mapProductTypeName.put('TPX Smartphone bruger' , countTPXMOBIL);
                }
                if(iterator.UcLicenseValue == 'TPXCOMB'){
                    //searchProductType= '%Combi%';
                    countTPXCOMB++;
                    mapProductTypeName.put('TPX Combi bruger' , countTPXCOMB);
                }
                if(iterator.UcLicenseValue == 'TPXLIM'){
                    //searchProductType= '%Limited%';
                    countTPXLIM++;
                    mapProductTypeName.put('TPX Limited bruger' , countTPXLIM);
                }
            }
        }
        System.debug('countTPXLIM --> ' + countTPXLIM);
        System.debug('countTPXCOMB --> ' + countTPXCOMB);
        System.debug('countTPXMOBIL --> ' + countTPXMOBIL);
        list<product2> listproduct2 = [SELECT Id,
                                              name 
                                       FROM product2 
                                       WHERE name IN : mapProductTypeName.keyset()];
       for(SBQQ__ProductOption__c  iterator : [SELECT Id,SBQQ__OptionalSKU__c,
                                                                Name 
                                                        FROM SBQQ__ProductOption__c 
                                                        WHERE SBQQ__OptionalSKU__c IN : listproduct2]){
            mapProductOption.put(iterator.SBQQ__OptionalSKU__c,iterator);
        }

       for(SBQQ__QuoteLine__c iterator : [SELECT Id,
                                                             SBQQ__ProductName__c,
                                                             SBQQ__Quantity__c 
                                                    FROM SBQQ__QuoteLine__c 
                                                    WHERE SBQQ__ProductName__c IN : mapProductTypeName.keyset()  
                                                          and 
                                                          SBQQ__Quote__c=:quoteId]){
            mapexistingQuoteline.put(iterator.SBQQ__ProductName__c , iterator);
        }
        //
        List<SBQQ__QuoteLine__c> mobileQuote = [SELECT Id,
                                                       SBQQ__Quote__r.Name,
                                                       SBQQ__Product__c, 
                                                       SBQQ__Product__r.Name,
                                                       CreatedDate 
                                                FROM SBQQ__QuoteLine__c 
                                                WHERE SBQQ__Product__r.Name = 'Mobile' 
                                                      and 
                                                      SBQQ__Quote__c =: quoteId];
        System.debug('mapQuoteLineDetail --> ' + mapQuoteLineDetail);
      
        //for new quote lines
        for(product2 iterator : listproduct2){
            if(!mapexistingQuoteline.containsKey(iterator.Name) && mobileQuote.size() > 0 && mapProductOption.containsKey(iterator.id)){

                insertListQuoteLine.add(new SBQQ__QuoteLine__c( SBQQ__Quote__c=quoteId , SBQQ__Product__c= iterator.Id , SBQQ__Quantity__c=1.0 ,SBQQ__Number__c=2, SBQQ__RequiredBy__c=mobileQuote[0].id , SBQQ__ProductOption__c = mapProductOption.get(iterator.id).id));
            }
        }
        // for(SBQQ__QuoteLine__c iterator : existingQuoteline){
        //         if(mapProductTypeName.containsKey(iterator.SBQQ__ProductName__c)){
        //             System.debug('existingQuoteline iterator --> ' + iterator);
        //             iterator.SBQQ__Quantity__c = iterator.SBQQ__Quantity__c+mapProductTypeName.get(iterator.SBQQ__ProductName__c);
        //             updateListQuoteLine.add(iterator);
        //         }
        //     }
        //
        if(insertListQuoteLine.size() > 0 || !mapQuoteLineDetail.isEmpty()){
            System.debug('insertListQuoteLine -->' + insertListQuoteLine);
                insert insertListQuoteLine;
                update mapQuoteLineDetail.values();
            }

            AggregateResult[] groupedResults =[select VAS_UC_License__c,count(Id)UcLicense from Quote_Line_Detail__c where  Quote_Line__r.SBQQ__Quote__c =:quoteId and VAS_UC_License__c IN ('TPXMOBIL' , 'TPXLIM','TPXCOMB') group by VAS_UC_License__c];
            for (AggregateResult ar : groupedResults)  {
                mapUCValueCount.put(string.valueof(ar.get('VAS_UC_License__c')) , integer.valueof(ar.get('UcLicense')));
            }
                for(SBQQ__QuoteLine__c iterator : [SELECT Id,
                                                            SBQQ__ProductName__c,
                                                            SBQQ__Quantity__c 
                                                FROM SBQQ__QuoteLine__c 
                                                WHERE   SBQQ__Quote__c=:quoteId]){
                    if(iterator.SBQQ__ProductName__c == 'TPX Smartphone bruger' && mapUCValueCount.containsKey('TPXMOBIL')){
                        iterator.SBQQ__Quantity__c = mapUCValueCount.get('TPXMOBIL');
                        updateListQuoteLineMap.put(iterator.id ,iterator);
                    }else if(iterator.SBQQ__ProductName__c == 'TPX Smartphone bruger' && !mapUCValueCount.containsKey('TPXMOBIL')){
                        deleteListQuoteLine.add(iterator);
                    }
                    if(iterator.SBQQ__ProductName__c == 'TPX Limited bruger' && mapUCValueCount.containsKey('TPXLIM')){
                        iterator.SBQQ__Quantity__c = mapUCValueCount.get('TPXLIM');
                        updateListQuoteLineMap.put(iterator.id ,iterator);
                    }else if(iterator.SBQQ__ProductName__c == 'TPX Limited bruger' && !mapUCValueCount.containsKey('TPXLIM')){
                        deleteListQuoteLine.add(iterator);
                    }
                    if(iterator.SBQQ__ProductName__c == 'TPX Combi bruger' && mapUCValueCount.containsKey('TPXCOMB')){
                        iterator.SBQQ__Quantity__c = mapUCValueCount.get('TPXCOMB');
                        updateListQuoteLineMap.put(iterator.id ,iterator);
                    }else if(iterator.SBQQ__ProductName__c == 'TPX Combi bruger' && !mapUCValueCount.containsKey('TPXCOMB')){
                        deleteListQuoteLine.add(iterator);
                    }                               
                }
            if(!updateListQuoteLineMap.isEmpty()){
                update updateListQuoteLineMap.values();
            }
            if(deleteListQuoteLine.size() > 0){
                delete deleteListQuoteLine;
            }
            isSuccess= true;
        //}
       return isSuccess;
    }
    //1700 End
    @AuraEnabled
    public static quoteInformationWrapper changesSending( String theBody ){
        System.debug('MT111:' + theBody );
        List<changeRequest> theChangesRequested = (List<changeRequest>)JSON.deserializeStrict( theBody, List<changeRequest>.class ), theChangesPerformed = new List<changeRequest>();// change comes from single table only
        List<Quote_Line_Detail__c> relatedQLD = Database.query( buildQuery( theChangesRequested ) ), qldToDelete = new List<Quote_Line_Detail__c>(), qldToInsert = new List<Quote_Line_Detail__c>();

        System.debug('MT112:' + relatedQLD );
        Boolean found = false;
        for( changeRequest singleChange: theChangesRequested ){
            if( relatedQLD.size() > 0 ){
                for( Quote_Line_Detail__c singleQLD: relatedQLD  ){
                    if( singleQLD.Quote_Line__c == singleChange.parentId && singleQLD.MobileFixedCircuit__c == singleChange.mainServiceId ){
                        found = true;
                        if( singleChange.action == 'delete' ){ 
                            qldToDelete.add( singleQLD );
                            theChangesPerformed.add( singleChange );
                            break;
                        }
                        else{
                            // We just do not do insert if record is there ( in case of switching status it would be here ... )
                            break;
                        }
                    }
                }
            }
            if( !found ){
                if( singleChange.action == 'delete' ){ 
                    // No records to delete so do nothing
                }
                else{
                    qldToInsert.add( new Quote_Line_Detail__c(
                        //Mobile_no__c = singleChange.mainServiceId, // Tutaj będzie problem ... Bo skąd wiadomo które pole updaetować ...
                        Quote_Line__c = singleChange.parentId
                    ) );
                    qldToInsert[qldToInsert.size()-1].put( singleChange.action.split(':')[1], singleChange.mainServiceId );
                    theChangesPerformed.add( singleChange );
                }
            }
            else found = false;  //  category: ( this._dataPack.quoteLine.hasOwnProperty('Category__c') ? this._dataPack.quoteLine.Category__c : null )
        }
        String searchExpresion = (theChangesRequested[0].category != null ? theChangesRequested[0].category : '') + '%';
                        // Trzeba update by używało też cateogry
        Id QLIdOfMainProduct = [SELECT Id FROM SBQQ__QuoteLine__c WHERE SBQQ__RequiredBy__c = :theChangesRequested[0].requiredBy AND SBQQ__Hidden__c = false AND Activate_with_other_products__c = false AND Category_and_Feature__c LIKE :searchExpresion AND SBQQ__Product__r.Name NOT IN :bannedProducts LIMIT 1].Id;  // We need main product id or one of group of main products to query the change

        if( qldToDelete.size() > 0 ){
            try{
                delete qldToDelete;
            } catch( Exception e ){
                errorHandlingForRenewalUtilityClass( 'Error occured in quoteLineDetailsUtilsClass.changesSending on event of Update on addones assignment.', 'There has been an error during quoteLineDetailsUtilsClass.changesSending processing. Please contact your administrator about this issue. \n The Error:' + e.getMessage(), e );
            }
        }
        if( qldToInsert.size() > 0 ){
            try{
                insert qldToInsert;
            } catch( Exception e ){
                errorHandlingForRenewalUtilityClass( 'Error occured in quoteLineDetailsUtilsClass.changesSending on event of Update on addones assignment.', 'There has been an error during quoteLineDetailsUtilsClass.changesSending processing. Please contact your administrator about this issue. \n The Error:' + e.getMessage(), e );
            }
        }

        if( theChangesPerformed.size() > 0 )mainServiceChangeListUpdate( theChangesPerformed );

        //return response;
        return new quoteInformationWrapper( 'QuoteLine', QLIdOfMainProduct );
    }

        // Utility methods

    private static void mainServiceChangeListUpdate( List<changeRequest> theChangesRequested ){
        System.debug('MT907:' + theChangesRequested);
        Set<String> serviceIdentifiersSet = new Set<String>();
        Set<String> requiredBySet = new Set<String>(); //requiredBy
        Map<String,List<changeRequest>> serviceIdToChangeMap = new Map<String,List<changeRequest>>();
        for( changeRequest singleChange : theChangesRequested ){
            serviceIdentifiersSet.add( singleChange.mainServiceId );
            requiredBySet.add( singleChange.requiredBy );
            if( serviceIdToChangeMap.containsKey(singleChange.mainServiceId) ) serviceIdToChangeMap.get(singleChange.mainServiceId).add(singleChange);
            else serviceIdToChangeMap.put( singleChange.mainServiceId, new List<changeRequest>{ singleChange } );
        }

        List<Quote_Line_Detail__c> result = [SELECT Id, MobileFixedCircuit__c, Changes_List_to_a_Service__c FROM Quote_Line_Detail__c WHERE MobileFixedCircuit__c IN :serviceIdentifiersSet AND Quote_Line__r.SBQQ__RequiredBy__c IN :requiredBySet  AND Quote_Line__r.SBQQ__Hidden__c = false AND Quote_Line__r.Activate_with_other_products__c = false];

        List<Quote_Line_Detail__c> mainQLDToUpdate = new List<Quote_Line_Detail__c>();
        for( Quote_Line_Detail__c singleMainQLD : result ){
            String changeString = singleMainQLD.Changes_List_to_a_Service__c;       // Nie działa
            if( serviceIdToChangeMap.containsKey( singleMainQLD.MobileFixedCircuit__c ) ){
                for( changeRequest singleChange : serviceIdToChangeMap.get( singleMainQLD.MobileFixedCircuit__c ) ){
                    System.debug( singleChange ); // Po przejściu z pustego na cokolwiek ma na początku wstawiony null ... ;p
                    if( ( changeString == null ? true : !changeString.contains(singleChange.parentId) ) ){  /// By zapisac addon dodany trzeba wstaic <//co się stało>:<//Id QLa addona> /// 
                            // If it doesn't containt the Id the change is new and we should add it
                        if( !String.isEmpty(changeString) ) changeString += ',';
                        else changeString = '';
                        changeString += singleChange.action.split(':')[0] + ':' + singleChange.parentId;
                    }
                    else{
                        // If it contains the Id already then the change is undone
                        List<String> changeListElements = changeString.split(',');
                        for( Integer i = 0 ; i<changeListElements.size() ; ++i ){
                            if( changeListElements[i].contains( singleChange.parentId ) ){
                                changeListElements.remove(i);
                                changeString = String.join( changeListElements, ',');
                            }
                        }
                    }
                }
            }
            mainQLDToUpdate.add( new Quote_Line_Detail__c(
                Id = singleMainQLD.Id,
                Changes_List_to_a_Service__c = changeString
            ) );
        }
        System.debug( 'MT907 before Update:' + mainQLDToUpdate );
        try{
            update mainQLDToUpdate;
        }catch( Exception e ){
            errorHandlingForRenewalUtilityClass( 'Error occured in quoteLineDetailsUtilsClass.mainServiceChangeListUpdate on event of saving change information to main service record.', 'There has been an error during quoteLineDetailsUtilsClass.mainServiceChangeListUpdate processing. Please contact your administrator about this issue. \n The Error:' + e.getMessage(), e );
        }
    }
    
//  MobileFixedCircuit__c, Mobile_no__c, Fixed_no__c, Circuit_ID__c

    private static String buildQuery( List<changeRequest> changesToQuery ){
        String query = 'SELECT Id, Main_Service_Upgrade_Checker__c, Mobile_no__c, MobileFixedCircuit__c, Changes_List_to_a_Service__c, Fixed_no__c, Circuit_ID__c, Quote_Line__c, Quote_Line__r.SBQQ__RequiredBy__c FROM Quote_Line_Detail__c WHERE';
        Boolean needConnector = false;
        for( changeRequest singleChange : changesToQuery ){
            if( needConnector ){
                query += ' OR ';
            } else needConnector = true;
            query += '( MobileFixedCircuit__c = \'' + singleChange.mainServiceId + '\' AND Quote_Line__c =\'' + singleChange.parentId + '\' )';
        }

        return query;
    }

    @AuraEnabled
    public static quoteInformationWrapper singleTableRefresh( String quoteLineId ){
        // We receive Quote Line Id --> we need to get Number related and all related to the options
        return new quoteInformationWrapper( 'QuoteLine', quoteLineId );
    }

    // Error handling method for testing easyness

    @TestVisible
    private static void errorHandlingForRenewalUtilityClass( String errorEnding, String userError, Exception e ){
        ErrorLogging errorsLog = new ErrorLogging( 'Apex' );
        errorsLog.addError( '\n Type of Excetpion:' + e.getTypeName() + '\n Message:\n' + e.getMessage(), errorEnding );
        errorsLog.logErrors();
        throw new baseUtilsClassException( userError );
    }

    // Filter logic data provider

    @AuraEnabled
    public static List<Matrix_Filter_Field__mdt> filterLogicDataProvider(){
        // This method is sending full list of filter fields to component 
        return [SELECT Column_API_Name__c, MasterLabel, DeveloperName FROM Matrix_Filter_Field__mdt];
    }

}