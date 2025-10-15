import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import {qlDetailsUtils} from "c/qlDetailsDisplayUtils";

import changesSender from '@salesforce/apex/quoteLineDetailsUtilsClass.changesSending';  // qlDetailsUtils.createColumnInformation(
import additionalChangesSender from '@salesforce/apex/quoteLineDetailsUtilsClass.additionalChangesSending';
import filterFieldsGetter from '@salesforce/apex/quoteLineDetailsUtilsClass.filterLogicDataProvider';
import changeOfProductSender from '@salesforce/apex/quoteLineDetailsUtilsClass.changeOfProduct';
import terminationOfProductSender from '@salesforce/apex/quoteLineDetailsUtilsClass.terminationOfProduct';
import Id from '@salesforce/schema/Account.Id';
import lwcRefresh from '@salesforce/apex/quoteLineDetailsUtilsClass.wrapperProviderSingleGroup'; //1700
import updateQuotelineDetail from '@salesforce/apex/quoteLineDetailsUtilsClass.updateQuotelineDetail';//1700
//standard:discounts ; standard:duration_downscale ( for downgrade )
//standard:logging ; standard:dashboard ; standard:incident ( for upgrade )
//standard:care_request_reviewer ( for no action )
//standard:record_delete ; standard:recyle_bin ( for delete/terminate line )

class displayInfo {
    constructor( columnsInfo, group ){
        console.log( 'Start DisplayInfo Constructor');
        console.log( 'Start DisplayInfo param1: ' + JSON.stringify(columnsInfo) );
        console.log( 'Start DisplayInfo param2' + JSON.stringify(group) );
        this.detailsDisplay = [];
        if( group ) this.detailsDisplay.push( {
            label: 'Product',
            fieldName: 'Product_Name__c',
            type: 'text',
            cellAttributes:{
                iconName: { fieldName: 'Main_Service_Upgrade_Checker__c' }
            },
            sortable: true
        });
        this.detailsDisplay = this.detailsDisplay.concat( this.defoultDisplayDetials.slice() );

        let apiUsed = [];
        
        console.log( 'Start DisplayInfo Constructor Before Loop 1');
        if( !Array.isArray( columnsInfo ) ) return;
        for( let i = 0 ; i<columnsInfo.length ; ++i ){
            let apiName = qlDetailsUtils.convertLabelToApi( columnsInfo[i].label );

            if( !apiUsed.includes( apiName ) ){
                apiUsed.push( apiName );
                this.detailsDisplay.push( {     // Trzeba dodac wyswietlanie grafiki i wczesniej dodac pole o nazwie Nazwa_Pola__c_Change by z niego czerpac info o zmianie
                    label: columnsInfo[i].label,
                    fieldName: apiName,
                    type: 'boolean',
                    editable: {
                        fieldName: 'controlEditField'
                    },//true,
                    sortable: true,
                    wrapText: true,
                    cellAttributes:{
                        iconName: { fieldName: apiName + '_change' }, // Definicja nazwy pola trzymającego info o zmianie
                        iconPosition: 'right'
                    }
                } );
            }
        }
        console.log( 'End DisplayInfo Constructor After Loop 1');
    }

    defoultDisplayDetials = [ // Quote_Line__r.SBQQ__ProductName__c
        { label: 'First Name', fieldName: 'First_name__c', type: 'text', sortable: true },
        { label: 'Last Name', fieldName: 'Last_name__c', type: 'text', sortable: true },
        { label: 'Number', fieldName: 'MobileFixedCircuit__c', type: 'text', sortable: true },
        { label: 'Terminated', fieldName: 'Termination_verifier__c', type: 'text', sortable: true },
        //1700 Start
        //{ label: 'UC Licences', fieldName: 'VAS_UC_License__c', type: 'text', sortable: true ,editable: true,
        { label: 'UC Licences', fieldName: 'VAS_UC_License__c', type: 'button',  sortable: true,editable: true,
        typeAttributes: {
            label: { fieldName: 'VAS_UC_License__c'},
           //variant: 'base',
            variant:'brand-outline',
            name: 'UC Licences'
        },
        cellAttributes: { 
        
            alignment: 'center',
            //class: { fieldName: 'myTable table'}
            //class:'slds-p-around_xx-large myTable table'
            
        },
        },

        //1700 end
        {
            label: 'Avg Monthly Data Used [MB]',
            fieldName: 'Avg_Monthly_Data_Used_MB__c',
            type: 'text',
            sortable: true//, // Kept just in case if we need such solution
            //cellAttributes: {
            //    iconName: { fieldName: 'Data_Usage_Analyzer__c' },
            //    iconPosition: 'right'
            //}
        },
        {
            label: 'Upgrade Indicator',
            fieldName: 'GraphicColumn_DataUsageAnalyzer',
            cellAttributes:{
                iconName: { fieldName: 'Data_Usage_Analyzer__c' }
            },
            sortable: true
        },
        { label: 'Max Monthly Data Used [MB]', fieldName: 'Max_Monthly_Data_Used_MB__c', type: 'text', sortable: true },
        { label: 'Calls from DK to EU [Min]', fieldName: 'Calls_from_DK_to_EU_MIN__c', type: 'text', sortable: true }
    ];

    defoultDisplayDetialsApi(){
        let apiArray = [];
        for( let i = 0 ; i<this.defoultDisplayDetials.length ; ++i ){
            apiArray.push( this.defoultDisplayDetials[i].fieldName );
        }

        return apiArray;
    }
}

export default class QuoteLineRecordDisplay extends LightningElement {

    quoteLineRecord;
    addQuoteLineRecord;
    _dataPack;
    displaySettings;
    addDisplaySettings;
    displaysettingsTest;
    sectionsOpened = ['existing'];//additional
     //1700 Start
     @track showModalInformation =false; 
     @track selectedPicklistValue; 
     @track quoteId; 
     @track productId; 
     @track draftValues =[];
     @track newDraftValues =[];
     @track picklistValue=[];
     @track currentPicklistValue=[];
     
     @track selectedRecordId;
     //1700 end
    checkingDone = false;
    preparationDone = false;
    loading = false;

    disabledProduct = false;

    @api
    get displayDataPack(){
        return _dataPack;
    }
    set displayDataPack( theDataPack ){
        this.loading = true;

        this._dataPack = JSON.parse(JSON.stringify(theDataPack));
        this.quoteLineRecord = JSON.parse(JSON.stringify(theDataPack.quoteLine));
        if( this.quoteLineRecord.Category__c.includes('TPX') || this.quoteLineRecord.Category__c.includes('Touchpoint') ) this.disabledProduct = true;

        this.displaySettings = new displayInfo( this._dataPack.columnsDisplayData, this._dataPack.group );
        this._checkingCheckboxValues( this._dataPack );
        this._blockingTerminatedLines( this.quoteLineRecord ); //controlEditField

                // Nowy kod jeszcze wstrzymany
        
        this._setAdditionalQuantity(); 

        this.addDisplaySettings = [
            { label: 'Product Name', fieldName: 'SBQQ__ProductName__c', type: 'text', sortable: true },
            { label: 'Additional Quantity', fieldName: 'Additional_Quantity__c', type: 'number', sortable: true, editable: true }
        ];
                // Nowy kod jeszcze wstrzymany    !!!END!!!
        this.terminationDate = this._dataPack.quoteLine.SBQQ__Quote__r.SBQQ__StartDate__c;
        console.log( '!End Termination date set up!' );

        this._addonsChangesMarking();
        console.log( '!After addons changes marking!' );

        this.displaysettingsTest = JSON.stringify( this.quoteLineRecord );
        filterFieldsGetter( ) // 10s do 20s
        .then( result => {
            console.log( '!filterFieldsGetter start!' );
            for( let i = 0 ; i<result.length ; ++i ){
                this.filterFieldsAPIList.push( result[i].Column_API_Name__c );
            }
            this.recordFilterSetter();
            this.searchFilter();
            this.setChangeOptions();
            
            this.preparationDone = true;
            console.log( 'M21: checkingDone:' + this.checkingDone + ' ; preparationDone:' + this.preparationDone );
            if( this.checkingDone && this.preparationDone ){
                console.log( 'M21: Success and unlocking of screen' );
                this.checkingDone = false;
                this.preparationDone = false;
                this.loading = false;
            }
            console.log( '!filterFieldsGetter end!' );
        })
        .catch( error => {
            console.log( '!filterFieldsGetter fail start!' );
            this.dispatchEventWithDetails( error, 'Error');            
            this.preparationDone = true;
            if( this.checkingDone == true && this.preparationDone == true ){
                this.checkingDone = false;
                this.preparationDone = false;
                this.loading - false;
            }
            console.log( '!filterFieldsGetter fail end!' );
        } );
    }
    //1700 start 
    get getUCLicensePicklist() {
        return [
           // { label: 'Limited', value: 'TPXLIM' },
            //{ label: 'Softphone', value: 'TPXSOFTP' },
            { label: 'None', value: '' },
            { label: 'Limited', value: 'TPXLIM' },
            { label: 'Smartphone', value: 'TPXMOBIL' },
            { label: 'Combi', value: 'TPXCOMB' },
        ];
    }
    //1700 End
    _setAdditionalQuantity(){       // Tutaj mozna usunac key i używać id 
        // Main products
        this.addDisplaySettings = [ // we do this to force table refresh after save ... :P
            { label: 'Product Name', fieldName: 'SBQQ__ProductName__c', type: 'text', sortable: true },
            { label: 'Additional Quantity', fieldName: 'Additional_Quantity__c', type: 'number', sortable: true, editable: true }
        ];//this._dataPack.columnsDisplayData
        let holderVariable = [];
        if( this._dataPack.group ){
            for( let singleQL of this._dataPack.everyQuoteLine){
                holderVariable.push({
                    Id: singleQL.Id,
                    SBQQ__ProductName__c: singleQL.SBQQ__ProductName__c,
                    Additional_Quantity__c: singleQL.Additional_Quantity__c,
                    mainProduct: false
                });
            }
        } else{ // Non groups are in quoteLine
            holderVariable = [
                {
                    Id: this.quoteLineRecord.Id,
                    SBQQ__ProductName__c: this.quoteLineRecord.SBQQ__ProductName__c,
                    Additional_Quantity__c: this.quoteLineRecord.Additional_Quantity__c,
                    mainProduct: false
                }
            ];
        }
        // Columns 
        if( Array.isArray( this._dataPack.columnsDisplayData ) ){
            for( let singleColumnQL of this._dataPack.columnsDisplayData ){
                holderVariable.push({
                    Id: singleColumnQL.quoteLineId,
                    SBQQ__ProductName__c: singleColumnQL.label,
                    Additional_Quantity__c: singleColumnQL.additionalQuantity,
                    mainProduct: false
                });
            }
        }

        console.log('Set additional Quantity End');
        this.addQuoteLineRecord = holderVariable;
    }

    _checkingCheckboxValues = ( theDataPack ) => {
        new Promise( ( resolve, reject ) => {
            if( !Array.isArray( theDataPack.columnsDisplayData ) ) reject( 'No array to wowrk with' );
            for( let i = 0 ; i<theDataPack.columnsDisplayData.length ; ++i ){
                let apiValue = qlDetailsUtils.convertLabelToApi( theDataPack.columnsDisplayData[i].label );
                this.quoteLineRecord[apiValue] = theDataPack.columnsDisplayData[i].quantity;        // We have qunatity info here ... but we do not want quantity but additional quantity ... 
                for( let j = 0 ; j<this.quoteLineRecord.Quote_Line_Details__r.length ; ++j ){   // Może tutaj nie być QLD!! Trzeba na to się przygotować!!!         { label: theColumns[i].SBQQ__ProductName__c, index: i, quoteLineId: theColumns[i].Id, quantity: theColumns[i].SBQQ__Quantity__c, additionalQuantity: theColumns[i].Additional_Quantity__c, key: theColumns[i].key } <-- takie info mam tutaj=
                    let found = false;
                    if( theDataPack.columnsData[ theDataPack.columnsDisplayData[i].index ].hasOwnProperty('Quote_Line_Details__r') ){
                        for( let k = 0 ; k<theDataPack.columnsData[ theDataPack.columnsDisplayData[i].index ].Quote_Line_Details__r.length ; ++k ){
                            if( this.quoteLineRecord.Quote_Line_Details__r[j].MobileFixedCircuit__c == theDataPack.columnsData[ theDataPack.columnsDisplayData[i].index ].Quote_Line_Details__r[k].MobileFixedCircuit__c ){
                                found = true;
                                break;
                            }
                        }
                    }
                    this.quoteLineRecord.Quote_Line_Details__r[j][apiValue] = found;
                }
            }
            resolve( 'Done' );
        } )
        .then( (res) => {
            this.checkingDone = true;
            if( this.checkingDone && this.preparationDone ){
                this.checkingDone = false;
                this.preparationDone = false;
                this.loading = false;
            }
        } )
        .catch( (err) => {
            this.checkingDone = true;
            if( this.checkingDone && this.preparationDone ){
                this.checkingDone = false;
                this.preparationDone = false;
                this.loading = false;
            }
        } );
    }

    _blockingTerminatedLines( theQLInScope ){ //controlEditField
        for( let i = 0 ; i<theQLInScope.Quote_Line_Details__r.length ; ++i ){
            theQLInScope.Quote_Line_Details__r[i].controlEditField = theQLInScope.Quote_Line_Details__r[i].Termination_verifier__c == 'No';
        }
    }

    changeGraphicMap = {    // This object controls graphic used for display of change to addons on number
        'delete':'utility:delete',
        'create':'utility:new'
    };

    _addonsChangesMarking(){
        if( !Array.isArray(this.quoteLineRecord.Quote_Line_Details__r) || !Array.isArray(this._dataPack.columnsDisplayData) ) return;
        if( this.quoteLineRecord.Quote_Line_Details__r.length == 0 || this._dataPack.columnsDisplayData.length == 0 ) return;
        // Let's create map of addon Id to it's API Name
        let addonIdToAPINameMap = {};
        for( let columnInfo of this._dataPack.columnsDisplayData ){ // Do weryfikacjiczy dobrze 
            addonIdToAPINameMap[columnInfo.quoteLineId] = qlDetailsUtils.convertLabelToApi( columnInfo.label )+'_change';
        }
        for( let singleQLD of this.quoteLineRecord.Quote_Line_Details__r ){
            let changeList = (singleQLD.hasOwnProperty('Changes_List_to_a_Service__c') ? singleQLD.Changes_List_to_a_Service__c : '');
            if( changeList === '' ) continue;
            for( let singleChange of changeList.split( ',' ) ){
                let changeParts = singleChange.split(':'); // First part is what happened and second part is Id of QL of addon
                singleQLD[addonIdToAPINameMap[changeParts[1]]] = this.changeGraphicMap[changeParts[0]];
            }
        }
    }
    
        // Css Methods
    TreeViewDropDown( event ) {
        event.target.parentElement.parentElement.parentElement.querySelector(".nested").classList.toggle("active");
        event.target.classList.toggle("caret-down");
    }

        // Table of data methods
    sortingVar = {
        defaultSortDirection: 'asc',
        sortedByEx: '',
        sortedByAd: '',
        sortDirectionEx: 'asc',
        sortDirectionAd: 'asc',
    };
    selectedRows = [];
    upgradeBoxVisiblity = false;
    terminationBoxVisibility = false;
    terminationDate;

    sortingByColumnEx( event ){

        this.sortingVar.sortedByEx = event.detail.fieldName;
        this.sortingVar.sortDirectionEx = event.detail.sortDirection;

        let tempVar = JSON.parse(JSON.stringify( this.quoteLineRecord )); // Cannot assign to read only property

        let sortField = this.sortingVar.sortedByEx;
        switch( sortField ) {
            case 'GraphicColumn_DataUsageAnalyzer':
                sortField = 'Data_Usage_Analyzer__c';
                break;
        }
        tempVar.Quote_Line_Details_Filtered.sort( this.sortBy( sortField, this.sortingVar.sortDirectionEx === 'asc' ? 1 : -1 ) );
        
        this.quoteLineRecord = tempVar;
    }
    sortingByColumnAd( event ){

        this.sortingVar.sortedByAd = event.detail.fieldName;
        this.sortingVar.sortDirectionAd = event.detail.sortDirection;

        let tempVar = JSON.parse(JSON.stringify( this.addQuoteLineRecord )); // Cannot assign to read only property
        tempVar.Quote_Line_Details__r.sort( this.sortBy( this.sortingVar.sortedByAd, this.sortingVar.sortDirectionAd === 'asc' ? 1 : -1 ) );

        this.addQuoteLineRecord = tempVar;
    }

    sortBy( field, reverse, primer ) {
        const key = ( primer
            ? function( x ) {
                return primer(x[field]);
            }
            : function( x ) {
                return x[field];
            }
        );

        return function( a, b ) {
            a = key(a);
            b = key(b);
            return reverse * ( ( a > b ) - ( b > a ) );
        };
    }

    savingProcessAdditionalLines( event ){
        this.loading = true;
        let theChanges = event.detail.draftValues;
        
        let quoteLineIndexQuantity = {};
        let found = false;
        for( let singleChange of theChanges ){
            for( let i = 0 ; i<this.addQuoteLineRecord.length ; ++i ){
                if( singleChange.Id == this.addQuoteLineRecord[i].Id ){
                    quoteLineIndexQuantity[i] = singleChange.Additional_Quantity__c; // There might be only single change on each index
                    found = true;
                    break;
                }
            }
            if( !found ){
                // Error! Key not found Error!!! Zrob error tutaj!
            }
            found = false;
        }

        let dataToApex = [];
        let requiredBy = this._dataPack.quoteLine.SBQQ__RequiredBy__c, category = ( this._dataPack.quoteLine.hasOwnProperty('Category__c') ? this._dataPack.quoteLine.Category__c : null );// Wszystkie produkty w danej grupie maja to samo category i required by ... wiec biore ktorekolwiek ... 
        for( let index in quoteLineIndexQuantity ){
            dataToApex.push({
                parentId: this.addQuoteLineRecord[index].Id,
                mainServiceId: quoteLineIndexQuantity[index], // Nie istotne w tej zmianie | użyjemy do przekazywania nowego quantity?
                action: 'update',
                requiredBy: requiredBy,
                category: category
            });
        }

        additionalChangesSender( { theBody: JSON.stringify( dataToApex ) } )
        .then( result => {  // Result is wrapper 
            this._recordUpdateResultHandling( result ); // To trzeba zmienic na refresh additional quantity tabeli a nie głównej
        })
        .catch( error => {
            this.dispatchEventWithDetails( error, 'Error');
            this.setChangeOptions();
            this.loading = false;
        } );
    }

    savingProcessExistingLines( event ){
        this.loading = true;
        this.displaysettingsTest = JSON.stringify( event.detail.draftValues ); // <-- Array with elements: {"fieldName":newValue, ...<can be more of these>, "Id":<num>} ( row indx strts with 0 )
        //console.log('this.selectedPicklistValue -->' , this.selectedPicklistValue);
        //1700 start 
        if(this.selectedPicklistValue !== undefined){
            let dataToApex = [];
        let dataToApexUC=[];
        let saveToDatabase =0;
        this.draftValues.forEach(element => {
            //console.log('this.draftValues --> ' , this.draftValues);
            
                if(element.Id){
                    console.log('element -->' ,element.Id);
                    dataToApexUC.push({
                        Id: element.Id,
                        UcLicenseValue: element.VAS_UC_License__c,
                        productType: this.selectedPicklistValue,
                        quoteId:this.quoteId
                    });
                }
        });
        
        if( dataToApexUC.length > 0 && saveToDatabase == 0){
            console.log('dataToApexUC ---> ' ,dataToApexUC);
            this.selectedPicklistValue = undefined;
            updateQuotelineDetail( { theBody: JSON.stringify( dataToApexUC ) } )
            .then( result => {  // Result is wrapper 
                if(result){
                    saveToDatabase++;
                    this.draftValues=[];
                    this.picklistValue=[];
                    this.handleComponentRefresh();
                }
            })
            .catch( error => {
                this.dispatchEventWithDetails( error, 'Error');
                this.loading = false;
            } );
        }
        else{
            this.loading = false;
        }
        }
        else if(this.selectedPicklistValue === undefined ){
        //1700 end
            // We look for records based on value of Id! We need to build message about changes and retrieve result or display error in main record 
        let quoteLineIndexChanges = [];
        for( let i = 0 ; i<event.detail.draftValues.length ; ++i ){
            for( let j = 0 ; j<this.quoteLineRecord.Quote_Line_Details__r.length ; ++j ){
                if( this.quoteLineRecord.Quote_Line_Details__r[j].Id == event.detail.draftValues[i].Id ){
                    let index = quoteLineIndexChanges.length;

                    let fieldUsedName = null;
                    if( this.quoteLineRecord.Quote_Line_Details__r[j].hasOwnProperty( 'Mobile_no__c' ) ){ // MobileFixedCircuit__c, Mobile_no__c, Fixed_no__c, Circuit_ID__c,
                        fieldUsedName = 'Mobile_no__c';
                    }else if( this.quoteLineRecord.Quote_Line_Details__r[j].hasOwnProperty( 'Fixed_no__c' ) ){
                        fieldUsedName = 'Fixed_no__c';
                    }else fieldUsedName = 'Circuit_ID__c';

                    quoteLineIndexChanges.push( { qldId: this.quoteLineRecord.Quote_Line_Details__r[j].Id, qlId: this.quoteLineRecord.Quote_Line_Details__r[j].Quote_Line__c, numberId: this.quoteLineRecord.Quote_Line_Details__r[j].MobileFixedCircuit__c, fieldToUpdate: fieldUsedName } );
                    for( let prop in event.detail.draftValues[i] ){
                        if( prop == 'Id') continue;
                        quoteLineIndexChanges[index][prop] = event.detail.draftValues[i][prop];
                    }   /// Jak ustalic jaki Quote Line Detail należy stworzyć/usunąć dla opcji? Jak zrobić by inaczej traktować produkty pełne ...
                    // Każdy element to zmiana i sa tylko dwa pola ktore nie sa zmiana qldId i qlId...
                    break;
                }
            }
        }
        let dataToApex = [];
        for( let i = 0 ; i<quoteLineIndexChanges.length ; ++i ){
            for( let prop in quoteLineIndexChanges[i] ){
                if( prop == 'qlId' || prop == 'qldId' || prop == 'numberId' ||  prop == 'SBQQ__AdditionalDiscountAmount__c' ){
                    continue;
                };
                let theLabel = qlDetailsUtils.convertApiToLabel(prop);
                for( let j = 0 ; j<this._dataPack.columnsDisplayData.length ; ++j ){
                    if( theLabel == this._dataPack.columnsDisplayData[j].label ){
                        dataToApex.push(
                            {
                                parentId: this._dataPack.columnsData[this._dataPack.columnsDisplayData[j].index].Id,
                                mainServiceId: quoteLineIndexChanges[i].numberId,
                                action: quoteLineIndexChanges[i][prop]==true?'create:' + quoteLineIndexChanges[i].fieldToUpdate : 'delete',
                                requiredBy: this._dataPack.quoteLine.SBQQ__RequiredBy__c,
                                category: ( this._dataPack.quoteLine.hasOwnProperty('Category__c') ? this._dataPack.quoteLine.Category__c : null )
                            }
                        );
                        break;
                    }
                }
            }
        }
        if( dataToApex.length > 0 ){
            //this.dispatchEventWithDetails( dataToApex, 'changesSave' );
            changesSender( { theBody: JSON.stringify( dataToApex ) } )
            .then( result => {  // Result is wrapper 
                this._recordUpdateResultHandling( result );
            })
            .catch( error => {
                this.dispatchEventWithDetails( error, 'Error');
                this.setChangeOptions();
                this.loading = false;
            } );
        }
        else{
            this.loading = false;
        }
        }
    } // { label: theColumns[i].SBQQ__ProductName__c, index: i, quoteLineId: theColumns[i].Id, quantity: theColumns[i].SBQQ__Quantity__c }
    //_dataPack.columnsData <-- lista rekordow jak powyzej
    //_dataPack.columnsDisplayData

    _recordUpdateResultHandling( result ){

        this.quoteLineRecord.Quote_Line_Details__r =[];
        this._dataPack.everyQuoteLine = [];
        for( let i = 0 ; i < result.theLinesWithDetails.length ; ++i ){
            this._dataPack.everyQuoteLine.push( result.theLinesWithDetails[i] );
            if( result.theLinesWithDetails[i].hasOwnProperty('Quote_Line_Details__r') )this.quoteLineRecord.Quote_Line_Details__r.push(...result.theLinesWithDetails[i].Quote_Line_Details__r);
        }
        this._dataPack.quoteLine.Quote_Line_Details__r = this.quoteLineRecord.Quote_Line_Details__r;
        this._dataPack.columnsData = result.theColumns;

        let columnQuoteLineMap = qlDetailsUtils.createColumnInformation( result.theLinesWithDetails, result.theColumns ); // Either something or nothing depend on what we work under key : Required By

        this.displaySettings = new displayInfo( columnQuoteLineMap[this._dataPack.quoteLine.SBQQ__RequiredBy__c+( this._dataPack.quoteLine.hasOwnProperty('Category__c') ? this._dataPack.quoteLine.Category__c : null )], this._dataPack.group ); // Czy my na pewno potrzebujemy odswierzac display settings?
        this._dataPack.columnsDisplayData = columnQuoteLineMap[this._dataPack.quoteLine.SBQQ__RequiredBy__c+( this._dataPack.quoteLine.hasOwnProperty('Category__c') ? this._dataPack.quoteLine.Category__c : null )];

        this._checkingCheckboxValues( this._dataPack );
        this._blockingTerminatedLines( this.quoteLineRecord );
        this._setAdditionalQuantity();

        this._addonsChangesMarking();
        
        this.recordFilterSetter();
        this.searchFilter();
        this._rowSelectedRefresh();
        this.preparationDone = true;
        if( this.checkingDone && this.preparationDone ){
            this.checkingDone = false;
            this.preparationDone = false;
            this.loading = false;
        }
    }
    //1700 Start
    handleChange(event){
        this.showModalInformation =false;
        console.log('this.quoteLineRecord.Quote_Line_Details_Filtered' , this.quoteLineRecord.Quote_Line_Details_Filtered);
        let allrows = [];  
            this.quoteLineRecord.Quote_Line_Details_Filtered.forEach(dataRow => {
                if(dataRow.Id == this.selectedRecordId){
                    this.newDraftValues.push({Id : this.selectedRecordId , VAS_UC_License__c : dataRow.VAS_UC_License__c});
                    console.log('this.newDraftValues ' , JSON.stringify(this.newDraftValues));
                    console.log('handleChange event.detail.value --> ' , JSON.stringify(event.detail.value));
                    dataRow.VAS_UC_License__c = event.detail.value;
                    this.selectedPicklistValue = event.detail.value;
                    this.quoteId=dataRow.Quote_Line__r.SBQQ__Quote__c;
                    this.picklistValue.push({Id : this.selectedRecordId , VAS_UC_License__c : event.detail.value })
                }
                allrows.push(dataRow);
            });
            this.draftValues = this.picklistValue;
            console.log('handleChange this.draftValues -->' , JSON.stringify(this.draftValues));
            console.log('addQuoteLineRecord' , JSON.stringify(this.addQuoteLineRecord));
            this.quoteLineRecord.Quote_Line_Details_Filtered = allrows;
            this.selectedRecordId = null;
        // targetInlinePicklistFieldName = 'VAS_UC_License__c';
        // inlinePicklistValue='TPXSOFTP';
        //this.selectedRecordId
        //this.draftValues = [{Id: 'a225r000000SJueAAG', VAS_UC_License__c: 'TPXSOFTP'}];
    }
    handleInlineCancelSave(event){
        this.draftValues = [];
        let allrows = [];
        this.quoteLineRecord.Quote_Line_Details_Filtered.forEach(dataRow => {
            this.newDraftValues.every(function (recDraftValue){
                console.log('dataRow.Id --> ' , dataRow.Id, 'recDraftValue.Id -->',recDraftValue.Id);
                if(dataRow.Id == recDraftValue.Id){
                    console.log('dataRow.VAS_UC_License__c --> ' , dataRow.VAS_UC_License__c, 'recDraftValue.VAS_UC_License__c -->',recDraftValue.VAS_UC_License__c);
                    dataRow.VAS_UC_License__c = recDraftValue.VAS_UC_License__c;
                }
            });
            allrows.push(dataRow);
        });
        this.quoteLineRecord.Quote_Line_Details_Filtered = allrows;
    }
    hideModalBox() {  
        this.showModalInformation =false;
    }
    
    showPicklist(event){
        console.log('event.detail.VAS_UC_License__c value ---> ', event.detail.row.VAS_UC_License__c);
        console.log('event.detail.Is_UC_Licenses_updated__c value ---> ', event.detail.row.Is_UC_Licenses_updated__c);
        if ((event.detail.row.VAS_UC_License__c ===undefined  && event.detail.action.name === 'UC Licences') || event.detail.row.Is_UC_Licenses_updated__c === true ) {
            this.selectedRecordId = event.detail.row.Id;
            this.showModalInformation = true;
            
            console.log('this.selectedRecordId ---> ' , this.selectedRecordId);
            console.log('currentPicklistValue ---> ', JSON.stringify(this.currentPicklistValue));
        }
    }
   
    handleComponentRefresh(){
        this.loading = true;
        console.log( JSON.stringify(this.quoteLineRecord) );
        lwcRefresh( { quoteLineId: JSON.stringify( this.quoteLineRecord.Id ) } )
        .then( result => {
            this._recordUpdateResultHandling( result );
            this.terminationButtonClickHandler( null );
            this.terminationBoxVisibility = false;
            this.loading = false;
            console.log('True Refresh');
        })
        .catch( error => {
            console.log('False Refresh');
            this.dispatchEventWithDetails( error, 'Error');
            this.loading = false;
            this.terminationButtonClickHandler( null );
        } );
    }
     
    // Events handling and sending
    handleInlineCellChange(event){
        console.log('handleInlineCellChange' , event.detail.draftValues);
    }
    //1700 end
    handleSectionToggle( event ){
        this.sectionsOpened = event.detail.openSections;
    }

            //###################// Update product fucntionalities //####################//

    rowSelectionHandler( event ){
        this.selectedRows = event.detail.selectedRows;
    }

    _rowSelectedRefresh(){
        //quoteLineRecord.Quote_Line_Details_Filtered
        let refreshedSelection = [];

        for( let singleSelected of this.selectedRows ){
            for( let singleLine of this.quoteLineRecord.Quote_Line_Details_Filtered ){
                if( singleSelected.Id == singleLine.Id ){
                    refreshedSelection.push( singleLine );
                    break;
                }
            }
        }

        this.selectedRows = refreshedSelection;
    }

    rowSelectionAdditionalHandler( event ){
        console.log(JSON.stringify( event.detail.selectedRows ));
    }

    terminationButtonClickHandler( event ){
        console.log( 'Cancel button on termination2' );
        this.terminationBoxVisibility = !this.terminationBoxVisibility;
    }

    terminationDateChange( event ){
        this.terminationDate = event.detail.value; // Problem był w tym przypisaniu ...
    }

    terminateSelectedRecords( event ){
        if( this.selectedRows.length == 0 ){
            this.dispatchEvent( new ShowToastEvent({
                title: 'Selected Record Required',
                message: 'Please select any line in table to terminate them. Currently no lines has been selected.',
                variant: 'warning',
            }));
            return;
        }
        this.loading = true;
        console.log( 'Termination logic mid Event after lock screen' );

        // Create change records
        let dataToApex = [];
        for( let i = 0 ; i<this.selectedRows.length ; ++i ){
            console.log( 'Termination logic inside first loop Event:' + JSON.stringify(this.selectedRows) );
            dataToApex.push({
                parentId: this.selectedRows[i].Quote_Line__c,
                mainServiceId: this.selectedRows[i].Id,
                action: ( this.selectedRows[i].Termination_verifier__c == 'Yes' ? 'Activation' :'Termination:' + this.terminationDate ),
                requiredBy: this._dataPack.quoteLine.SBQQ__RequiredBy__c,
                category: ( this._dataPack.quoteLine.hasOwnProperty('Category__c') ? this._dataPack.quoteLine.Category__c : null )
            });
        }

        // Selected lines need to be worked on
        if( dataToApex.length == 0 ){  
            this.loading = false;
            console.log( 'Termination logic neer end Event if 0 size' );
            return;
        }
        console.log( 'Termination logic Before request to Apex:' + JSON.stringify(dataToApex) );
        terminationOfProductSender( { theBody: JSON.stringify( dataToApex ) } )
        .then( result => {
            console.log( 'Termination logic end success: ' + JSON.stringify( result ) );
            this._recordUpdateResultHandling( result );
            this.terminationButtonClickHandler( null );
        })
        .catch( error => {
            console.log( 'Termination logic end fail:' + JSON.stringify( error ) );
            this.dispatchEventWithDetails( error, 'Error');
            this.setChangeOptions();
            this.loading = false;
            this.terminationButtonClickHandler( null );
        } );

    }

    updateButtonClickHandler( event ){
        // We just want to open the window for updating
        this.upgradeBoxVisiblity = !this.upgradeBoxVisiblity;
    }
    
    changeOptions = [{ labe:'Option1', value:'Option1API' }];
    pickedChangeOption = [];
    

    setChangeOptions(){
        this.changeOptions = [];
        if( this._dataPack.hasOwnProperty( 'everyQuoteLine' ) ){
            for( let i = 0 ; i<this._dataPack.everyQuoteLine.length ; ++i ){
                this.changeOptions.push( {
                    label: this._dataPack.everyQuoteLine[i].SBQQ__ProductName__c,
                    value: this._dataPack.everyQuoteLine[i].SBQQ__ProductName__c
                } );
            }
        }
    }

    handleChangeOptionChange( event ){
        this.pickedChangeOption = event.detail.value;
    }

    updateButtonSaveClickHandler( event ){

        if( this.selectedRows.length == 0 ){
            this.dispatchEvent( new ShowToastEvent({
            title: 'Selected Record Required',
            message: 'Please select any line in table to update them. Currently no lines has been selected.',
            variant: 'warning',
            }));
            return;
        }
        this.loading = true;
        
        // Find which is new QuoteLine for QLD
        let indexOfPickedProduct = null;
        for( let i = 0 ; i<this._dataPack.everyQuoteLine.length ; ++i ){
            if( this._dataPack.everyQuoteLine[i].SBQQ__ProductName__c == this.pickedChangeOption ){
                indexOfPickedProduct = i;
                break;
            }
        }
        if( indexOfPickedProduct == null ){ // Thor error ...
            this.loading = false;
            this.dispatchEvent( new ShowToastEvent({
                title: 'Error',
                message: 'Something went wrong, please contact administrator and provid him with this code: 11-000-1ACD.', // The error number provided to find the error place
                variant: 'error',
            }));
            return;
        }
                // Create change records
        let dataToApex = [];
        for( let i = 0 ; i<this.selectedRows.length ; ++i ){
            if( this.selectedRows[i].Product_Name__c == this.pickedChangeOption ){
                continue;
            }
            dataToApex.push({
                parentId: this._dataPack.everyQuoteLine[indexOfPickedProduct].Id,
                mainServiceId: this.selectedRows[i].Id,
                action:'Product Update',// + fieldUsedName,
                requiredBy: this.selectedRows[i].SBQQ__RequiredBy__c,
                category: ( this._dataPack.quoteLine.hasOwnProperty('Category__c') ? this._dataPack.quoteLine.Category__c : null )
            });
        }

        // Selected lines need to be worked on
        if( dataToApex.length == 0 ){
            this.loading = false;
            return;
        }
        changeOfProductSender( { theBody: JSON.stringify( dataToApex ) } )
        .then( result => {
            this._recordUpdateResultHandling( result );
            this.updateButtonClickHandler( null );

        })
        .catch( error => {
            this.dispatchEventWithDetails( error, 'Error');
            this.setChangeOptions();
            this.loading = false;
            this.updateButtonClickHandler( null );
        } );
    }
        
        // ### Search functionality ### // 
    filterAPI = 'recordFilterValue';
    searchPhrase = '';
    filterFieldsAPIList = [];
    searchChangeHandler( event ){ // For search functionality to be used
        this.searchPhrase = event.detail.value.toLowerCase();
                    // Czy my chcemy tak skomplikowaną logikę na on change puszczać???
                    // Czy my powinnismy ręcznie za każdym razem tworzyć strink danej QLD czy może zapisac je i trzymać na stałe w jednym miejscu i czy chcemy true false uwzględniac ? 
        if( this.quoteLineRecord.hasOwnProperty('Quote_Line_Details__r') ){ // We know that there is something and we can work on it
            this.loading = true;
            this.searchFilter();
            this.loading = false;
        }
    }

    searchFilter(){
        if( this.searchPhrase == '' ){
            // Show all options
            if( this.quoteLineRecord.hasOwnProperty( 'Quote_Line_Details__r' ) ) this.quoteLineRecord.Quote_Line_Details_Filtered = this.quoteLineRecord.Quote_Line_Details__r.slice();  // Rzuca bład jak nie ma QLD żadnych!
            else {
                this.dispatchEvent( new ShowToastEvent({
                    title: 'Group doesn\'t have any services registered ( Missing Quote Line Details )',
                    message: 'Product Group \'' + this.quoteLineRecord.SBQQ__ProductName__c + '\' has 0 main service records in system. This is why the table in renewal editor for it is empty. If You expected some srvices there, please contact administrator and report this as bug. This ocured during Search filter setup.',
                    variant: 'warning',
                }));
            }
        }
        else{
            // filtring
            let result = [];
            for( let i = 0 ; i<this.quoteLineRecord.Quote_Line_Details__r.length ; ++i ){
                if( this.quoteLineRecord.Quote_Line_Details__r[i][this.filterAPI].includes( this.searchPhrase ) ) result.push( this.quoteLineRecord.Quote_Line_Details__r[i] );
            }
            this.quoteLineRecord.Quote_Line_Details_Filtered = result;
        }
    }

    recordFilterStringCreator( singleRecord ){
        let result = '';
        for( let param in singleRecord ){
            if( this.filterFieldsAPIList.includes(param) ) result += ';' + singleRecord[param]; // We add ';' to make sure that connections of end and begining of different fields will not create new word
        }
        singleRecord[this.filterAPI] = result.toLowerCase();
    }

    recordFilterSetter(){
        if( !this.quoteLineRecord.hasOwnProperty('Quote_Line_Details__r') ) return;
        for( let i = 0 ; i < this.quoteLineRecord.Quote_Line_Details__r.length ; ++i ){
            this.recordFilterStringCreator( this.quoteLineRecord.Quote_Line_Details__r[i] );
        }
    }

    dispatchEventWithDetails( theDetail, actionType ) {
        this.dispatchEvent(
            new CustomEvent( 'childevent', {
                    detail: {
                        records: theDetail,
                        action: actionType
                    }
                }
            )
        );
    }
}
// Later add loading screen : https://www.sfdcpoint.com/salesforce/lightning-spinner-in-lwc-lightning-web-component/
// + rom SF https://developer.salesforce.com/docs/component-library/bundle/lightning-spinner/example