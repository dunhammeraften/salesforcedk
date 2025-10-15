import { LightningElement, api } from 'lwc';

export default class BusinessInternetBanFlow extends LightningElement {
    @api case;
    
    get inputVariables() {
        return [
            {
                name: 'Case',
                type: 'SObject',
                value: this.case
            }
        ];
    }

}