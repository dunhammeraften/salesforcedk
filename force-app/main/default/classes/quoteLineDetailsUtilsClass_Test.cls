@IsTest
private class quoteLineDetailsUtilsClass_Test {
	
    @TestSetup
    static void dataSettingUp(){
        Test.startTest();
        SBQQ.TriggerControl.disable();
        QuoteLineDetailsService.disableQuantityCounting = true;

        Integer numberOfDifferentBundles = 2, numberOfDifferentCategories = 2, numberOfDifferentFeaturesPerBundle = 4, numberOfDifferentProductsPerFeature = 2, numberOfDifferentOptionsPerBundle = 5;

        Map<String,List<Product2>> specificTestBundle = testDataFactory.createSpecificBundle();
        

        List<Account> testAccounts = testDataFactory.createAccountsForTests( 1 );

        List<Opportunity> testOpps = testDataFactory.createOpportunitiesForAccounts( 1, testAccounts );

        List<SBQQ__Quote__c> testQuote = testDataFactory.createQuotesForOpps( 1, testOpps );
        for( SBQQ__Quote__c singleQ: testQuote ){
            singleQ.SBQQ__Type__c = 'Renewal';
        }
        update testQuote;


        List<SBQQ__QuoteLine__c> testQLs = testDataFactory.createQuoteLinesForSpecificBundleWithDetails( specificTestBundle, testQuote[0] );

        QuoteLineDetailsService.disableQuantityCounting = false;
        SBQQ.TriggerControl.enable();
        Test.stopTest();
    }

    @IsTest
    static void wrapperClass_Test(){

        SBQQ__Quote__c singleQ = [SELECT Id FROM SBQQ__Quote__c LIMIT 1];

        quoteLineDetailsUtilsClass.quoteInformationWrapper wrappedData = quoteLineDetailsUtilsClass.wrapperProvider( singleQ.Id );

        SBQQ__Quote__c quoteCheck = [SELECT Id, Quote_Preparation_Lock__c FROM SBQQ__Quote__c WHERE id = :singleQ.Id];
        List<SBQQ__QuoteLine__c> mainServices = [SELECT Id, SBQQ__AdditionalDiscountAmount__c, Category_and_Feature__c, SBQQ__Quote__c, SBQQ__ProductName__c, SBQQ__RequiredBy__c, SBQQ__Quantity__c, Additional_Quantity__c, SBQQ__Quote__r.SBQQ__StartDate__c, (SELECT Id, Main_Service_Upgrade_Checker__c, Termination_verifier__c, Changes_List_to_a_Service__c,Category_and_Feature__c, MobileFixedCircuit__c, Mobile_no__c, Fixed_no__c, Circuit_ID__c, First_name__c, Last_name__c, Quote_Line__r.SBQQ__Quote__r.SBQQ__StartDate__c, Product_Name__c, Avg_Monthly_Data_Used_MB__c, Max_Monthly_Data_Used_MB__c, Data_Usage_Analyzer__c, Calls_from_DK_to_EU_MIN__c FROM Quote_Line_Details__r) FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c = :singleQ.Id AND SBQQ__Hidden__c = false AND Activate_with_other_products__c = false];
        List<SBQQ__QuoteLine__c> addones = [SELECT Id, SBQQ__AdditionalDiscountAmount__c, Category_and_Feature__c, SBQQ__Quote__c,SBQQ__ProductName__c, SBQQ__RequiredBy__c, SBQQ__Quantity__c, Additional_Quantity__c, SBQQ__Quote__r.SBQQ__StartDate__c, (SELECT Id, Termination_verifier__c, Category_and_Feature__c, MobileFixedCircuit__c, Mobile_no__c, Fixed_no__c, Circuit_ID__c, First_name__c, Last_name__c, Quote_Line__r.SBQQ__Quote__r.SBQQ__StartDate__c, Data_Usage_Analyzer__c, Product_Name__c FROM Quote_Line_Details__r) FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c = :singleQ.Id AND SBQQ__Hidden__c = false AND Activate_with_other_products__c = true];
        
        System.assertEquals( quoteCheck.Id, wrappedData.theQuote.Id, 'The quote ID is not matching' );
        System.assertEquals( mainServices.size(), wrappedData.theLinesWithDetails.size(), 'The number of main services is different than what we should see' );
        System.assertEquals( addones.size(), wrappedData.theColumns.size(), 'The number of addons is different than what we should see' );

    }

    @IsTest
    static void changesSending_Test(){  
        // To be rewriten to use new data created in factory ... and remove ugly addone to main class that is changing what is being taken for columns data from the main class
        //parentId: this._dataPack.columnsData[this._dataPack.columnsDisplayData[j].index].Id, // ID of addone's QuoteLine
        //mainServiceId: quoteLineIndexChanges[i].numberId, // Number of the addon
        //action: quoteLineIndexChanges[i][prop]==true?'create:' + quoteLineIndexChanges[i].fieldToUpdate : 'delete', // Action
        //requiredBy: this._dataPack.quoteLine.SBQQ__RequiredBy__c,  // RequiredBy
        //category: ( this._dataPack.quoteLine.hasOwnProperty('Category__c') ? this._dataPack.quoteLine.Category__c : null ) // Catrogty feature
		
        List<Quote_Line_Detail__c> theDetails = [SELECT Id, Mobile_no__c, Category_and_Feature__c, Quantity__c, Quote_Line__c, Quote_Line__r.SBQQ__Quote__c, Quote_Line__r.SBQQ__RequiredBy__c FROM Quote_Line_Detail__c], qldCompareList; // We will be deleteing them and creating new one
        List<quoteLineDetailsUtilsClass.changeRequest> theChangesList = new List<quoteLineDetailsUtilsClass.changeRequest>();

        Boolean checker = true;
        Integer counter = 0;
        for( Quote_Line_Detail__c singleQLD: theDetails ){// Half of all will be killed!!!
            if( checker ){
                theChangesList.add( new quoteLineDetailsUtilsClass.changeRequest() );
                theChangesList[counter].parentId = singleQLD.Quote_Line__c;
                theChangesList[counter].mainServiceId = singleQLD.Mobile_no__c;
                theChangesList[counter].action = 'delete';
                theChangesList[counter].requiredBy = singleQLD.Quote_Line__r.SBQQ__RequiredBy__c;
                theChangesList[counter].category = ((singleQLD.Category_and_Feature__c != null && singleQLD.Category_and_Feature__c != '' && singleQLD.Category_and_Feature__c != ';') ? singleQLD.Category_and_Feature__c.split(';')[0] : '');
            } else{
                theChangesList.add( new quoteLineDetailsUtilsClass.changeRequest() );  // Thouse should be ignored by the sender code
                theChangesList[counter].parentId = singleQLD.Quote_Line__c;
                theChangesList[counter].mainServiceId = singleQLD.Mobile_no__c;
                theChangesList[counter].action = 'create';
                theChangesList[counter].requiredBy = singleQLD.Quote_Line__r.SBQQ__RequiredBy__c;
                theChangesList[counter].category = ((singleQLD.Category_and_Feature__c != null && singleQLD.Category_and_Feature__c != '' && singleQLD.Category_and_Feature__c != ';') ? singleQLD.Category_and_Feature__c.split(';')[0] : '');
            }
            counter++;
            checker = !checker;
        }
        // Maybe add few lines too ?
        SBQQ.TriggerControl.disable();
        Test.startTest();
        quoteLineDetailsUtilsClass.changesSending( JSON.serialize( theChangesList ) ); // This only tests if the result it ok. Cause return statement would work correctly only for addones from single bunndle and we are using mutiple here.
        Test.stopTest();
        SBQQ.TriggerControl.enable();

        //qldCompareList = [SELECT Id, Mobile_no__c, Quantity__c, Quote_Line__c, Quote_Line__r.SBQQ__Quote__c, Quote_Line__r.SBQQ__RequiredBy__c FROM Quote_Line_Detail__c];
    }

    @IsTest
    static void terminationOfNumber_Test(){
        List<Quote_Line_Detail__c> mainServices = [SELECT Id, Mobile_no__c, Termination_verifier__c, Quote_Line__c, Changes_List_to_a_Service__c, Quote_Line__r.SBQQ__RequiredBy__c, Category_and_Feature__c FROM Quote_Line_Detail__c WHERE Quote_Line__r.Activate_with_other_products__c = false AND Quote_Line__r.SBQQ__Hidden__c = false], addonServices = [SELECT Id, Mobile_no__c, Termination_verifier__c, Quote_Line__c FROM Quote_Line_Detail__c WHERE Quote_Line__r.Activate_with_other_products__c = true AND Quote_Line__r.SBQQ__Hidden__c = false];
        Map<String,Map<String,List<Quote_Line_Detail__c>>> numberValueToMapToMainAndAddonesLists = new Map<String,Map<String,List<Quote_Line_Detail__c>>>();
        for( Quote_Line_Detail__c singleQLD : mainServices ){
            numberValueToMapToMainAndAddonesLists.put( singleQLD.Mobile_no__c, new Map<String,List<Quote_Line_Detail__c>>() );
            numberValueToMapToMainAndAddonesLists.get( singleQLD.Mobile_no__c ).put( 'MainServices', new List<Quote_Line_Detail__c>{ singleQLD } );
        }
        for( Quote_Line_Detail__c singleQLD : addonServices ){
            if( !numberValueToMapToMainAndAddonesLists.get( singleQLD.Mobile_no__c ).containsKey( 'AddoneServices' ) )numberValueToMapToMainAndAddonesLists.get( singleQLD.Mobile_no__c ).put( 'AddoneServices', new List<Quote_Line_Detail__c>{ singleQLD } );
            else numberValueToMapToMainAndAddonesLists.get( singleQLD.Mobile_no__c ).get( 'AddoneServices' ).add( singleQLD );
        }

        List<quoteLineDetailsUtilsClass.changeRequest> informationToTerminate = new List<quoteLineDetailsUtilsClass.changeRequest>();
        // Number MobileNumber1Bundle1 has 6 addones and MobileNumber3Bundle1 0 we want to terminate both of them now and see what will hapen to other numbers and to their addones
        informationToTerminate.add( new quoteLineDetailsUtilsClass.changeRequest() );
        informationToTerminate[0].parentId = numberValueToMapToMainAndAddonesLists.get('MobileNumber1Bundle1').get('MainServices')[0].Quote_Line__c;// Id of Quote Lines that the QLD is under
        informationToTerminate[0].mainServiceId = numberValueToMapToMainAndAddonesLists.get('MobileNumber1Bundle1').get('MainServices')[0].Id;// Id of QLD that is to be terminated
        informationToTerminate[0].action = 'Termination:' + (Date.Today()+4);
        informationToTerminate[0].requiredBy = numberValueToMapToMainAndAddonesLists.get('MobileNumber1Bundle1').get('MainServices')[0].Quote_Line__r.SBQQ__RequiredBy__c;
        informationToTerminate[0].category = numberValueToMapToMainAndAddonesLists.get('MobileNumber1Bundle1').get('MainServices')[0].Category_and_Feature__c;

        informationToTerminate.add( new quoteLineDetailsUtilsClass.changeRequest() );
        informationToTerminate[1].parentId = numberValueToMapToMainAndAddonesLists.get('MobileNumber3Bundle1').get('MainServices')[0].Quote_Line__c;// Id of Quote Lines that the QLD is under
        informationToTerminate[1].mainServiceId = numberValueToMapToMainAndAddonesLists.get('MobileNumber3Bundle1').get('MainServices')[0].Id;// Id of QLD that is to be terminated
        informationToTerminate[1].action = 'Termination:' + (Date.Today()+4);
        informationToTerminate[1].requiredBy = numberValueToMapToMainAndAddonesLists.get('MobileNumber3Bundle1').get('MainServices')[0].Quote_Line__r.SBQQ__RequiredBy__c;
        informationToTerminate[1].category = numberValueToMapToMainAndAddonesLists.get('MobileNumber3Bundle1').get('MainServices')[0].Category_and_Feature__c;

        
        SBQQ.TriggerControl.disable(); // Otherwise we hit CPU limit cause debuglog is turned on during tests....
        Test.startTest();
        quoteLineDetailsUtilsClass.terminationOfProduct( JSON.serialize( informationToTerminate ) );
        Test.stopTest();
        SBQQ.TriggerControl.enable();

        List<Quote_Line_Detail__c> MainServicesCheck = [SELECT Id, Mobile_no__c, Termination_verifier__c, Quote_Line__c, Changes_List_to_a_Service__c, Quote_Line__r.SBQQ__RequiredBy__c, Category_and_Feature__c FROM Quote_Line_Detail__c WHERE Quote_Line__r.Activate_with_other_products__c = false AND Quote_Line__r.SBQQ__Hidden__c = false];
        List<Quote_Line_Detail__c> AddoneServicesCheck = [SELECT Id, Mobile_no__c, Termination_verifier__c, Quote_Line__c FROM Quote_Line_Detail__c WHERE Quote_Line__r.Activate_with_other_products__c = true AND Quote_Line__r.SBQQ__Hidden__c = false];

        for( Quote_Line_Detail__c singleQLD : AddoneServicesCheck ){ // Check removal of addones
            System.assertNotEquals( singleQLD.Mobile_no__c, 'MobileNumber1Bundle1', 'Every addone for this number "MobileNumber1Bundle1" shoule be deleted during termination!' );
            System.assertNotEquals( singleQLD.Mobile_no__c, 'MobileNumber3Bundle1', 'There should be no new addones for "MobileNumber3Bundle1" it didn\'t have any begore!' );
        }
        // Check change of status and date of termination
        for( Quote_Line_Detail__c singleQLD : MainServicesCheck ){
            if( singleQLD.Mobile_no__c == 'MobileNumber1Bundle1' ){
                System.assertNotEquals( numberValueToMapToMainAndAddonesLists.get(singleQLD.Mobile_no__c).get('MainServices')[0].Changes_List_to_a_Service__c, singleQLD.Changes_List_to_a_Service__c, 'List of changes should have changed due to removal of old options.' );
                System.assertNotEquals( numberValueToMapToMainAndAddonesLists.get(singleQLD.Mobile_no__c).get('MainServices')[0].Termination_verifier__c, singleQLD.Termination_verifier__c, 'Termination status should change.' );
            }
            else if( singleQLD.Mobile_no__c == 'MobileNumber3Bundle1' ){
                System.assertNotEquals( numberValueToMapToMainAndAddonesLists.get(singleQLD.Mobile_no__c).get('MainServices')[0].Termination_verifier__c, singleQLD.Termination_verifier__c, 'Termination status should change.' );
            }
        }
        // Requie few more lines testing the returned value from that function ... :P 
    }

    @IsTest
    static void changeOfProduct_Test(){
        List<Quote_Line_Detail__c> mainServices = [SELECT Id, Mobile_no__c, Termination_verifier__c, Quote_Line__c, Changes_List_to_a_Service__c, Quote_Line__r.SBQQ__RequiredBy__c, Category_and_Feature__c FROM Quote_Line_Detail__c WHERE Quote_Line__r.Activate_with_other_products__c = false AND Quote_Line__r.SBQQ__Hidden__c = false], addonServices = [SELECT Id, Mobile_no__c, Termination_verifier__c, Quote_Line__c FROM Quote_Line_Detail__c WHERE Quote_Line__r.Activate_with_other_products__c = true AND Quote_Line__r.SBQQ__Hidden__c = false];
        Map<String,Map<String,List<Quote_Line_Detail__c>>> numberValueToMapToMainAndAddonesLists = new Map<String,Map<String,List<Quote_Line_Detail__c>>>();
        for( Quote_Line_Detail__c singleQLD : mainServices ){
            numberValueToMapToMainAndAddonesLists.put( singleQLD.Mobile_no__c, new Map<String,List<Quote_Line_Detail__c>>() );
            numberValueToMapToMainAndAddonesLists.get( singleQLD.Mobile_no__c ).put( 'MainServices', new List<Quote_Line_Detail__c>{ singleQLD } );
        }
        for( Quote_Line_Detail__c singleQLD : addonServices ){
            if( !numberValueToMapToMainAndAddonesLists.get( singleQLD.Mobile_no__c ).containsKey( 'AddoneServices' ) )numberValueToMapToMainAndAddonesLists.get( singleQLD.Mobile_no__c ).put( 'AddoneServices', new List<Quote_Line_Detail__c>{ singleQLD } );
            else numberValueToMapToMainAndAddonesLists.get( singleQLD.Mobile_no__c ).get( 'AddoneServices' ).add( singleQLD );
        }
        
        List<quoteLineDetailsUtilsClass.changeRequest> informationToTerminate = new List<quoteLineDetailsUtilsClass.changeRequest>();
        // Number MobileNumber1Bundle1 has 6 addones and MobileNumber3Bundle1 0 we want to terminate both of them now and see what will hapen to other numbers and to their addones
        informationToTerminate.add( new quoteLineDetailsUtilsClass.changeRequest() );
        informationToTerminate[0].parentId = numberValueToMapToMainAndAddonesLists.get('MobileNumber5Bundle1').get('MainServices')[0].Quote_Line__c;// Id of QL of new Product
        informationToTerminate[0].mainServiceId = numberValueToMapToMainAndAddonesLists.get('MobileNumber3Bundle1').get('MainServices')[0].Id;// Id of QLD that is to be updated
        informationToTerminate[0].action = 'Product Update';
        informationToTerminate[0].requiredBy = numberValueToMapToMainAndAddonesLists.get('MobileNumber3Bundle1').get('MainServices')[0].Quote_Line__r.SBQQ__RequiredBy__c;
        informationToTerminate[0].category = numberValueToMapToMainAndAddonesLists.get('MobileNumber3Bundle1').get('MainServices')[0].Category_and_Feature__c;

        informationToTerminate.add( new quoteLineDetailsUtilsClass.changeRequest() );
        informationToTerminate[1].parentId = numberValueToMapToMainAndAddonesLists.get('MobileNumber5Bundle1').get('MainServices')[0].Quote_Line__c;// Id of Quote Lines that the QLD is under
        informationToTerminate[1].mainServiceId = numberValueToMapToMainAndAddonesLists.get('MobileNumber5Bundle1').get('MainServices')[0].Id;// Id of QLD that is to be terminated
        informationToTerminate[1].action = 'Product Update';
        informationToTerminate[1].requiredBy = numberValueToMapToMainAndAddonesLists.get('MobileNumber5Bundle1').get('MainServices')[0].Quote_Line__r.SBQQ__RequiredBy__c;
        informationToTerminate[1].category = numberValueToMapToMainAndAddonesLists.get('MobileNumber5Bundle1').get('MainServices')[0].Category_and_Feature__c;

        SBQQ.TriggerControl.disable(); // Otherwise we hit CPU limit cause debuglog is turned on during tests....
        Test.startTest();
        quoteLineDetailsUtilsClass.changeOfProduct( JSON.serialize( informationToTerminate ) );
        Test.stopTest();
        SBQQ.TriggerControl.enable();

        List<Quote_Line_Detail__c> MainServicesCheck = [SELECT Id, Mobile_no__c, Termination_verifier__c, Quote_Line__c FROM Quote_Line_Detail__c WHERE Quote_Line__r.Activate_with_other_products__c = false AND Quote_Line__r.SBQQ__Hidden__c = false];
        List<Quote_Line_Detail__c> AddoneServicesCheck = [SELECT Id, Mobile_no__c, Termination_verifier__c, Quote_Line__c FROM Quote_Line_Detail__c WHERE Quote_Line__r.Activate_with_other_products__c = true AND Quote_Line__r.SBQQ__Hidden__c = false];

        for( Quote_Line_Detail__c singleQLD: MainServicesCheck ){
            if( singleQLD.Mobile_no__c == 'MobileNumber5Bundle1' ) System.assertEquals( numberValueToMapToMainAndAddonesLists.get(singleQLD.Mobile_no__c).get('MainServices')[0].Quote_Line__c, singleQLD.Quote_Line__c, 'There should be no change for line that is being changed to the same product.');
            if( singleQLD.Mobile_no__c == 'MobileNumber3Bundle1' ) System.assertNotEquals( numberValueToMapToMainAndAddonesLists.get(singleQLD.Mobile_no__c).get('MainServices')[0].Quote_Line__c, singleQLD.Quote_Line__c, 'There should be change of product for this line.' );
        }
    }

    @IsTest
    static void updateProvider_Test(){

        List<SBQQ__QuoteLine__c> allTheQuoteLines = [SELECT Id, Activate_with_other_products__c, SBQQ__Product__r.Name, SBQQ__RequiredBy__c, Category_and_Feature__c, (SELECT Id, Termination_verifier__c, MobileFixedCircuit__c, Data_Usage_Analyzer__c, Product_Name__c FROM Quote_Line_Details__r) FROM SBQQ__QuoteLine__c];

        // We need to find one record we know have some friends in the same Category like main Quote Line for product 
        Id theQuoteId;
        String category = '', requiredById = '';
        for( SBQQ__QuoteLine__c singleQL: allTheQuoteLines ){
            if( singleQL.SBQQ__Product__r.Name == 'MainService1' ){
                theQuoteId = singleQL.Id;
                category = singleQL.Category_and_Feature__c.split(';',0)[0];
                requiredById = singleQL.SBQQ__RequiredBy__c;
                break;
            }
        }//this.theLinesWithDetails[0].Category_and_Feature__c.split(';',0)[0] + '%'

        //Category_and_Feature__c LIKE :category

        List<SBQQ__QuoteLine__c> mainServices = new List<SBQQ__QuoteLine__c>(), addones = new List<SBQQ__QuoteLine__c>();
        List<Quote_Line_Detail__c> mainServicesDetails = new List<Quote_Line_Detail__c>(), addonesDetails = new List<Quote_Line_Detail__c>(), mainServicesDetailsAfter = new List<Quote_Line_Detail__c>(), addonesDetailsAfter = new List<Quote_Line_Detail__c>();

        quoteLineDetailsUtilsClass.quoteInformationWrapper codeResult = quoteLineDetailsUtilsClass.wrapperProviderSingleGroup(theQuoteId);

        for( SBQQ__QuoteLine__c singleQL: allTheQuoteLines ){
            if( singleQL.Category_and_Feature__c.contains( category ) && singleQL.SBQQ__RequiredBy__c == requiredById ){ /// We need to sum number of QLD under the lines

                if( !singleQL.Activate_with_other_products__c ){
                    mainServices.add( singleQL );
                    mainServicesDetails.addAll(singleQL.Quote_Line_Details__r);
                }
                else{
                    addones.add( singleQL );
                    addonesDetails.addAll(singleQL.Quote_Line_Details__r);
                }
            }
        }
        // After
        List<SBQQ__QuoteLine__c> afterAllQL = new List<SBQQ__QuoteLine__c>();
        afterAllQL.addAll( codeResult.theLinesWithDetails );
        afterAllQL.addAll( codeResult.theColumns );
        for( SBQQ__QuoteLine__c singleQL: afterAllQL ){
            if( singleQL.Category_and_Feature__c.contains( category ) && singleQL.SBQQ__RequiredBy__c == requiredById ){ /// We need to sum number of QLD under the lines

                if( !singleQL.Activate_with_other_products__c ){
                    mainServicesDetailsAfter.addAll(singleQL.Quote_Line_Details__r);
                }
                else{
                    addonesDetailsAfter.addAll(singleQL.Quote_Line_Details__r);
                }
            }
        }

        System.assertEquals( mainServicesDetails.size(), mainServicesDetailsAfter.size(), 'AS1102: Number of main services in return statement is not correct.' ); // Tutaj błąd
        System.assertEquals( addonesDetails.size(), addonesDetailsAfter.size(), 'AS1103: Number of addone services in return statement is not correct.'  );

    }

    @IsTest
    static void errorGeneration_Test(){     // To be tested
        String errorDetailsEnding = 'Test value for error record.', errorUserWouldSee = 'Test value of error displayed to the user';
        try{
            quoteLineDetailsUtilsClass.errorHandlingForRenewalUtilityClass( errorDetailsEnding, errorUserWouldSee, new quoteLineDetailsUtilsClass.baseUtilsClassException( 'Just test' ) );
            System.assert( false, 'There should be an error thrown and prevent this line from happening.');
        } catch( quoteLineDetailsUtilsClass.baseUtilsClassException error ){
            System.assertEquals( error.getMessage().contains(errorUserWouldSee) , true, 'New error message should contain the provided text value' );

            List<System_Log__c> logsInSystem = [SELECt Id, Additional_Information__c, Error_Body__c, Origin__c FROM System_Log__c];
            System.assertEquals( 1, logsInSystem.size(), 'There should be asingle log.');
            System.assertEquals( errorDetailsEnding, logsInSystem[0].Additional_Information__c, 'The additional information should be equal to provided message.');
            System.assertEquals( 'Apex', logsInSystem[0].Origin__c, 'The additional information should be equal to provided message.');
        }
    }//'\n Type of Excetpion:' + e.getTypeName() + '\n Message:\n' + e.getMessage()
    @IsTest
    static void updateQuotelineDetail_Test(){

        SBQQ__Quote__c singleQ = [SELECT Id FROM SBQQ__Quote__c LIMIT 1];

        quoteLineDetailsUtilsClass.quoteInformationWrapper wrappedData = quoteLineDetailsUtilsClass.wrapperProvider( singleQ.Id );

        SBQQ__Quote__c quoteCheck = [SELECT Id, Quote_Preparation_Lock__c FROM SBQQ__Quote__c WHERE id = :singleQ.Id];
        List<SBQQ__QuoteLine__c> mainServices = [SELECT Id,SBQQ__Product__c, SBQQ__AdditionalDiscountAmount__c, Category_and_Feature__c, SBQQ__Quote__c, SBQQ__ProductName__c, SBQQ__RequiredBy__c, SBQQ__Quantity__c, Additional_Quantity__c, SBQQ__Quote__r.SBQQ__StartDate__c, (SELECT Id, Main_Service_Upgrade_Checker__c, Termination_verifier__c, Changes_List_to_a_Service__c,Category_and_Feature__c, MobileFixedCircuit__c, Mobile_no__c, Fixed_no__c, Circuit_ID__c, First_name__c, Last_name__c, Quote_Line__r.SBQQ__Quote__r.SBQQ__StartDate__c, Product_Name__c, Avg_Monthly_Data_Used_MB__c, Max_Monthly_Data_Used_MB__c, Data_Usage_Analyzer__c, Calls_from_DK_to_EU_MIN__c FROM Quote_Line_Details__r) FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c = :singleQ.Id AND SBQQ__Hidden__c = false AND Activate_with_other_products__c = false];
        List<SBQQ__QuoteLine__c> addones = [SELECT Id,SBQQ__Product__c, SBQQ__AdditionalDiscountAmount__c, Category_and_Feature__c, SBQQ__Quote__c,SBQQ__ProductName__c, SBQQ__RequiredBy__c, SBQQ__Quantity__c, Additional_Quantity__c, SBQQ__Quote__r.SBQQ__StartDate__c, (SELECT Id, Termination_verifier__c, Category_and_Feature__c, MobileFixedCircuit__c, Mobile_no__c, Fixed_no__c, Circuit_ID__c, First_name__c, Last_name__c, Quote_Line__r.SBQQ__Quote__r.SBQQ__StartDate__c, Data_Usage_Analyzer__c, Product_Name__c FROM Quote_Line_Details__r) FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c = :singleQ.Id AND SBQQ__Hidden__c = false AND Activate_with_other_products__c = true];
        List<quoteLineDetailsUtilsClass.changeRequestUCLicense> listName = new List<quoteLineDetailsUtilsClass.changeRequestUCLicense>();
        quoteLineDetailsUtilsClass.changeRequestUCLicense objchangeRequestUCLicense = new quoteLineDetailsUtilsClass.changeRequestUCLicense();
        List<Quote_Line_Detail__c>listQuoteLineDetail = [SELECT id from Quote_Line_Detail__c limit 1];
        objchangeRequestUCLicense.Id = listQuoteLineDetail[0].id;
        objchangeRequestUCLicense.UcLicenseValue = 'TPXMOBIL';
        objchangeRequestUCLicense.productType = 'Smartphone';
        objchangeRequestUCLicense.quoteId = quoteCheck.id;
        objchangeRequestUCLicense.productId = mainServices[0].SBQQ__Product__c;
        listName.add(objchangeRequestUCLicense);
        string theBody = JSON.serialize(listName);
        SBQQ.TriggerControl.disable();
        Test.startTest();
        quoteLineDetailsUtilsClass.updateQuotelineDetail(theBody);
        Test.stopTest();
        SBQQ.TriggerControl.enable();
    }
    @IsTest
    static void additionalChangesSending_Test(){

        SBQQ__Quote__c singleQ = [SELECT Id FROM SBQQ__Quote__c LIMIT 1];

        quoteLineDetailsUtilsClass.quoteInformationWrapper wrappedData = quoteLineDetailsUtilsClass.wrapperProvider( singleQ.Id );

        SBQQ__Quote__c quoteCheck = [SELECT Id, Quote_Preparation_Lock__c FROM SBQQ__Quote__c WHERE id = :singleQ.Id];
        List<SBQQ__QuoteLine__c> mainServices = [SELECT Id,SBQQ__Product__c, SBQQ__AdditionalDiscountAmount__c, Category_and_Feature__c, SBQQ__Quote__c, SBQQ__ProductName__c, SBQQ__RequiredBy__c, SBQQ__Quantity__c, Additional_Quantity__c, SBQQ__Quote__r.SBQQ__StartDate__c, (SELECT Id, Main_Service_Upgrade_Checker__c, Termination_verifier__c, Changes_List_to_a_Service__c,Category_and_Feature__c, MobileFixedCircuit__c, Mobile_no__c, Fixed_no__c, Circuit_ID__c, First_name__c, Last_name__c, Quote_Line__r.SBQQ__Quote__r.SBQQ__StartDate__c, Product_Name__c, Avg_Monthly_Data_Used_MB__c, Max_Monthly_Data_Used_MB__c, Data_Usage_Analyzer__c, Calls_from_DK_to_EU_MIN__c FROM Quote_Line_Details__r) FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c = :singleQ.Id AND SBQQ__Hidden__c = false AND Activate_with_other_products__c = false];
        List<SBQQ__QuoteLine__c> addones = [SELECT Id,SBQQ__Product__c, SBQQ__AdditionalDiscountAmount__c, Category_and_Feature__c, SBQQ__Quote__c,SBQQ__ProductName__c, SBQQ__RequiredBy__c, SBQQ__Quantity__c, Additional_Quantity__c, SBQQ__Quote__r.SBQQ__StartDate__c, (SELECT Id, Termination_verifier__c, Category_and_Feature__c, MobileFixedCircuit__c, Mobile_no__c, Fixed_no__c, Circuit_ID__c, First_name__c, Last_name__c, Quote_Line__r.SBQQ__Quote__r.SBQQ__StartDate__c, Data_Usage_Analyzer__c, Product_Name__c FROM Quote_Line_Details__r) FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c = :singleQ.Id AND SBQQ__Hidden__c = false AND Activate_with_other_products__c = true];
        List<quoteLineDetailsUtilsClass.changeRequest> listName = new List<quoteLineDetailsUtilsClass.changeRequest>();
        quoteLineDetailsUtilsClass.changeRequest objchangeRequest = new quoteLineDetailsUtilsClass.changeRequest();
        List<Quote_Line_Detail__c>listQuoteLineDetail = [SELECT id from Quote_Line_Detail__c limit 1];
        //public String parentId,mainServiceId,action,requiredBy,category;
        objchangeRequest.parentId = mainServices[0].id;
        objchangeRequest.action = 'TPXMOBIL';
        objchangeRequest.mainServiceId = '10.00';
        objchangeRequest.requiredBy='';
        objchangeRequest.category='';
        listName.add(objchangeRequest);
        string theBody = JSON.serialize(listName);
        quoteLineDetailsUtilsClass.additionalChangesSending(theBody);
    }
    //singleTableRefresh
    @IsTest
    static void singleTableRefresh_Test(){

        SBQQ__Quote__c singleQ = [SELECT Id FROM SBQQ__Quote__c LIMIT 1];

        quoteLineDetailsUtilsClass.quoteInformationWrapper wrappedData = quoteLineDetailsUtilsClass.wrapperProvider( singleQ.Id );

        SBQQ__Quote__c quoteCheck = [SELECT Id, Quote_Preparation_Lock__c FROM SBQQ__Quote__c WHERE id = :singleQ.Id];
        List<SBQQ__QuoteLine__c> mainServices = [SELECT Id,SBQQ__Product__c, SBQQ__AdditionalDiscountAmount__c, Category_and_Feature__c, SBQQ__Quote__c, SBQQ__ProductName__c, SBQQ__RequiredBy__c, SBQQ__Quantity__c, Additional_Quantity__c, SBQQ__Quote__r.SBQQ__StartDate__c, (SELECT Id, Main_Service_Upgrade_Checker__c, Termination_verifier__c, Changes_List_to_a_Service__c,Category_and_Feature__c, MobileFixedCircuit__c, Mobile_no__c, Fixed_no__c, Circuit_ID__c, First_name__c, Last_name__c, Quote_Line__r.SBQQ__Quote__r.SBQQ__StartDate__c, Product_Name__c, Avg_Monthly_Data_Used_MB__c, Max_Monthly_Data_Used_MB__c, Data_Usage_Analyzer__c, Calls_from_DK_to_EU_MIN__c FROM Quote_Line_Details__r) FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c = :singleQ.Id AND SBQQ__Hidden__c = false AND Activate_with_other_products__c = false];
        List<SBQQ__QuoteLine__c> addones = [SELECT Id,SBQQ__Product__c, SBQQ__AdditionalDiscountAmount__c, Category_and_Feature__c, SBQQ__Quote__c,SBQQ__ProductName__c, SBQQ__RequiredBy__c, SBQQ__Quantity__c, Additional_Quantity__c, SBQQ__Quote__r.SBQQ__StartDate__c, (SELECT Id, Termination_verifier__c, Category_and_Feature__c, MobileFixedCircuit__c, Mobile_no__c, Fixed_no__c, Circuit_ID__c, First_name__c, Last_name__c, Quote_Line__r.SBQQ__Quote__r.SBQQ__StartDate__c, Data_Usage_Analyzer__c, Product_Name__c FROM Quote_Line_Details__r) FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c = :singleQ.Id AND SBQQ__Hidden__c = false AND Activate_with_other_products__c = true];
        List<quoteLineDetailsUtilsClass.changeRequest> listName = new List<quoteLineDetailsUtilsClass.changeRequest>();
        quoteLineDetailsUtilsClass.changeRequest objchangeRequest = new quoteLineDetailsUtilsClass.changeRequest();
        List<Quote_Line_Detail__c>listQuoteLineDetail = [SELECT id from Quote_Line_Detail__c limit 1];
        quoteLineDetailsUtilsClass.singleTableRefresh(mainServices[0].id);
        quoteLineDetailsUtilsClass.filterLogicDataProvider();
    }
}