import { LightningElement, api, track } from 'lwc';

export default class QuoteLinesListApp extends LightningElement {

    @track dataDisplayPack;
    @track test;
    
    @api
    get appInformation(){
        return dataDisplayPack;
    }
    set appInformation( appInfo ){  // appInfo.productGrouping <-- info o groupowaniu ... 
        console.log('quoteLinesListApp Start');
        this.dataDisplayPack = [];

        // Tutaj trzeba przerobic na uzywanie Category
        // Każda QL ma swoją kategorię i feture na sobie więc skorzystajmy z tego i tylko sprawdzajmy czy już jest na to zgrupowanie
        // Chcemy zgrupowac Datadisplaypack do bycia lista opcji
        let groupingIndex = {}; // MainProductName_Category name as key and index as value
        for( let i = 0 ; i<appInfo.quoteLineData.length ; ++i ){
            let singleQuoteLine = appInfo.quoteLineData[i];
            let category = singleQuoteLine.Category_and_Feature__c.split(';')[0], feature = singleQuoteLine.Category_and_Feature__c.split(';')[1]; // Obecnie feature nie ma zastosowania 
            // Moze nie byc wartosci category ... w tedy nie powinno byc zadnego grupowania ... Trzeba ten case osobno rozpatrzec
            if( category != '' ){
                if( groupingIndex.hasOwnProperty( singleQuoteLine.SBQQ__RequiredBy__c + category ) ){ // We need to use required by as well casue there might be re used category in other bundle
                    this.dataDisplayPack[ groupingIndex[singleQuoteLine.SBQQ__RequiredBy__c + category] ].everyQuoteLine.push(
                        singleQuoteLine
                    );
                    if( singleQuoteLine.hasOwnProperty('Quote_Line_Details__r') ) this.dataDisplayPack[ groupingIndex[singleQuoteLine.SBQQ__RequiredBy__c + category] ].quoteLine.Quote_Line_Details__r.push(...singleQuoteLine.Quote_Line_Details__r);
                }
                else{
                    groupingIndex[ singleQuoteLine.SBQQ__RequiredBy__c + category ] = this.dataDisplayPack.length;
                    this.dataDisplayPack.push( {
                        group: true,
                        quoteLine: {   //._dataPack.quoteLine.Category__c
                            Id: singleQuoteLine.Id, // just for order and display purpose
                            SBQQ__ProductName__c: category,
                            SBQQ__RequiredBy__c: singleQuoteLine.SBQQ__RequiredBy__c,  // Need for update of status back to LWC
                            Quote_Line_Details__r: singleQuoteLine.hasOwnProperty('Quote_Line_Details__r') ? [...singleQuoteLine.Quote_Line_Details__r] : [],
                            Category__c : category,
                            SBQQ__Quote__r : { SBQQ__StartDate__c: singleQuoteLine.SBQQ__Quote__r.SBQQ__StartDate__c }
                        }, // dodaj if ze jak nie ma detail to nic nie rob
                        everyQuoteLine: [singleQuoteLine],
                        // !!!!! #### Tutaj jest użyte columns resultat wiec trzeba ją przerobić by uwzględniała feature a nie grouping!!
                        columnsDisplayData: ( appInfo.columnQuoteLineMap.hasOwnProperty( singleQuoteLine.SBQQ__RequiredBy__c + category ) ? appInfo.columnQuoteLineMap[singleQuoteLine.SBQQ__RequiredBy__c + category] : [] ),
                        columnsData: appInfo.columnsInformation
                    } );
                }
            }
            else { // Tutaj jak nie ma kategorii :P 
                this.dataDisplayPack.push( {
                    group: false,
                    quoteLine: singleQuoteLine,
                    everyQuoteLine: [singleQuoteLine],
                    columnsDisplayData: (appInfo.columnQuoteLineMap.hasOwnProperty(singleQuoteLine.SBQQ__RequiredBy__c) ? appInfo.columnQuoteLineMap[singleQuoteLine.SBQQ__RequiredBy__c] : []),
                    columnsData: appInfo.columnsInformation
                } );
            }
        }
        console.log('quoteLinesListApp Stop');
    }

    handleChildEvents( eve ) {
        switch( eve.detail.action ) {
            case 'SomeFuture action':
                // In future if this element would be solving anything 
            break;
            default:     // 'changesSave' should be dealet in upper LWC
                this.propagateChildEvent( eve );
        }
    }

    propagateChildEvent( eve ) {
        this.dispatchEvent( new CustomEvent( 'childevent', eve ) );
    }

}

// columnQuoteLineMap: this.columnQuoteLineMap,
// quoteLineData: this.quoteLineData,
// columnsInformation