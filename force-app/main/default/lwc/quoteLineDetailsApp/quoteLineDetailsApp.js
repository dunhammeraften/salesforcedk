import { LightningElement, api, track } from 'lwc';
import dataProvider from '@salesforce/apex/quoteLineDetailsUtilsClass.wrapperProvider';
import {qlDetailsUtils} from "c/qlDetailsDisplayUtils";


export default class QuoteLineDetailsApp extends LightningElement {

    _recordId;

    @api set recordId( value ) {
        console.log('Setter Start');
        this._recordId = value;

        // do your thing right here with this.recordId / value

        console.log('dataProvider Id:' + JSON.stringify( this._recordId ) );
        dataProvider( { theQuoteId : this._recordId } )
            .then( result => {
                console.log('Setter Request Success');
                console.log( 'Result:' + JSON.stringify(result.data) );
                if( result ) {
                    console.log('Setter If( result ) Start');
                    this.rawData = JSON.stringify(result);
                    this.quoteData = JSON.parse(JSON.stringify(result.theQuote));
                    //if( this.quoteData.hasOwnProperty('Quote_Preparation_Lock__c') ){
                    //    this.additionalDiscountPreventDisplay = this.quoteData.Quote_Preparation_Lock__c;
                    //}
                    this.quoteLineData = JSON.parse(JSON.stringify(result.theLinesWithDetails));
                    this._checkLinesForAmountDiscount( JSON.parse(JSON.stringify(result.theLinesWithDetails)) );
                    this.quoteLineColumnsData = JSON.parse(JSON.stringify( result.theColumns ));
                    this._checkLinesForAmountDiscount( this.quoteLineColumnsData );
                    this.columnQuoteLineMap = qlDetailsUtils.createColumnInformation( this.quoteLineData, this.quoteLineColumnsData );
                    this.columnQuoteLineMapTest = JSON.stringify(this.columnQuoteLineMap);
                    this.quoteLineColumnsDataTest = JSON.stringify( this.quoteLineColumnsData );
                    this.appInformation = {
                        columnQuoteLineMap: this.columnQuoteLineMap,
                        quoteLineData: this.quoteLineData,
                        columnsInformation: this.quoteLineColumnsData
                    }
                    console.log('Setter If( result ) End');
                }else {
                    this.error = result.error;
                }
            })
            .catch( error => {
                console.log('Setter Request Fail');
                this.quoteLineColumnsDataTest = JSON.stringify(error);
                this.error = error;
            });
    }

    get recordId() {
        return this._recordId;
    }

    @track error;
    @track rawData;
    @track quoteData;
    // Variable for display component
    @track appInformation;
    @track columnQuoteLineMapTest;
    @track quoteLineColumnsDataTest;
    @track quoteLineData;
    @track columnQuoteLineMap; // Map, Quote Line Id ( the line ) to options ( coluns ) with ids of options for quantity adding
    @track displaySettings = { // Probably will be removed ... soon
        quoteLineDetailSettings:{
        },
        quoteLineSettings:{ // QL If do listy wyswietlen
        }
    };

        // Css Methods

    fullScreen = false;
    additionalDiscountPreventDisplay = false;
    handleFullScreen( event ){
        event.target.parentElement.parentElement.parentElement.classList.toggle("screenMain1");
        this.fullScreen = !this.fullScreen;
    }
    _checkLinesForAmountDiscount( quoteLineRecords ){
        if( this.additionalDiscountPreventDisplay ) return;
        for( let singleLine of quoteLineRecords ){
            if( singleLine.hasOwnProperty('SBQQ__AdditionalDiscountAmount__c') ){
                console.log( 'MT921:' + JSON.stringify( singleLine.Id ) );
                console.log( 'MT921:' + JSON.stringify( singleLine ) );
                this.additionalDiscountPreventDisplay = true;
                break;
            }
        }
    }

        // Handler

    // Events handling

    handleChildEvents( eve ) {
        switch( eve.detail.action ) {
            case 'SomeFuture action':
                // In future if this element would be solving anything 
            break;
            case 'Error':
                this.error = eve.detail.records;
            break;
            default:
                this.error = [{
                    body: 'Action type:' + eve.detail.action + '\n ',
                    ok: false,
                    status: 1009,
                    statusText: 'There has been chiled event that has not been processed!'
                }];

        }
    }
}