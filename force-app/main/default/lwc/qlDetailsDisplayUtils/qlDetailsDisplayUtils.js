class qlDetailsUtils {
    static convertLabelToApi( theLabel ) {
        let apiName = theLabel.replaceAll( '_', '^' ); // There are products that habe '_' in name so we change them to '^'
        return apiName.replaceAll( ' ', '_' ) + '__c';
    }
    static convertApiToLabel( theApi ) {
        console.log( 'convertApiToLabel Start:' + theApi );
        let theLabel = theApi.substring(0,theApi.length-3).replaceAll( '_', ' ' );// Trzeba najpierw usunac trzy ostatnie znaki '__c'
        console.log( 'convertApiToLabel result:' + theLabel );
        return theLabel.replaceAll( '^', '_' );
    }
    static createColumnInformation( quoteLineData, theColumns ){
        console.log( 'Start qlDetailsDisplayUtils.createColumnInformation' );
        console.log( 'Start param1:' + JSON.stringify(quoteLineData) );
        console.log( 'Start param2:' + JSON.stringify(theColumns) );
        if( theColumns === null ) return null;
        let mapBundleIdCategoryToProducts = {};
        for( let i = 0 ; i<theColumns.length ; ++i ){
            let category = theColumns[i].Category_and_Feature__c.split(';')[0], feature = theColumns[i].Category_and_Feature__c.split(';')[1];
            if( mapBundleIdCategoryToProducts.hasOwnProperty( theColumns[i].SBQQ__RequiredBy__c + category ) ) mapBundleIdCategoryToProducts[theColumns[i].SBQQ__RequiredBy__c + category ].push( 
                { label: theColumns[i].SBQQ__ProductName__c, index: i, quoteLineId: theColumns[i].Id, quantity: theColumns[i].SBQQ__Quantity__c, additionalQuantity: theColumns[i].Additional_Quantity__c, key: theColumns[i].key } 
            );
            else mapBundleIdCategoryToProducts[theColumns[i].SBQQ__RequiredBy__c + category ] = [{ label: theColumns[i].SBQQ__ProductName__c, index: i, quoteLineId: theColumns[i].Id, quantity: theColumns[i].SBQQ__Quantity__c, additionalQuantity: theColumns[i].Additional_Quantity__c, key: theColumns[i].key }];
        }
        // Chcemy miec info na QuoteLine o ilosci, powinnismy zerbac je teraz i przygotowac || Nie używamy być może trzeba usunąć ...
        for( let i = 0 ; i<quoteLineData.length ; ++i ){
            let addedElements = [];
            for( let j = 0 ; j<mapBundleIdCategoryToProducts[quoteLineData[i].SBQQ__RequiredBy__c] ; ++j ){

                let theLabel = mapBundleIdCategoryToProducts[quoteLineData[i].SBQQ__RequiredBy__c][j].label;
                let theApi = qlDetailsUtils.convertLabelToApi( theLabel );

                if( addedElements.includes( theApi ) ){
                    quoteLineData[i][theApi] += mapBundleIdCategoryToProducts[quoteLineData[i].SBQQ__RequiredBy__c][j].quantity;        // We do not need that
                }
                else {
                    addedElements.push( theApi );
                    quoteLineData[i][theApi] = mapBundleIdCategoryToProducts[quoteLineData[i].SBQQ__RequiredBy__c][j].quantity;        // We do not need that
                }
            }
        }
        console.log( 'End qlDetailsDisplayUtils.createColumnInformation : ' + JSON.stringify( mapBundleIdCategoryToProducts ) );
        return mapBundleIdCategoryToProducts
    }
}

export {qlDetailsUtils}