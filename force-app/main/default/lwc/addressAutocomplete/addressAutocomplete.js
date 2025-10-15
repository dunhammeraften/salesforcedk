import { LightningElement, api, track } from 'lwc';
import cityFld from '@salesforce/schema/Location_Line__c.City__c';
import doorFld from '@salesforce/schema/Location_Line__c.Door__c';
import floorFld from '@salesforce/schema/Location_Line__c.Floor__c';
import numberFld from '@salesforce/schema/Location_Line__c.Number__c';
import streetFld from '@salesforce/schema/Location_Line__c.Street_Name__c';
import zipFld from '@salesforce/schema/Location_Line__c.ZIP_Code__c';
import oppFld from '@salesforce/schema/Location_Line__c.Opportunity__c';
import statusFld from '@salesforce/schema/Location_Line__c.Address_Wash_Status__c';
import employeeFld from '@salesforce/schema/Location_Line__c.Employee_ID__c';
import HOEmployeeIDLabel from '@salesforce/label/c.HOEmployeeIDLabel';
import HOEmployeeIDFieldText from '@salesforce/label/c.HOEmployeeIDFieldText';
import HOAutoCompleteAddressLabel from '@salesforce/label/c.HOAutoCompleteAddressLabel';
import HOAutoCompleteAddressFieldText from '@salesforce/label/c.HOAutoCompleteAddressFieldText';
import uploadLines from '@salesforce/apex/AddressAutocomplete.uploadLines';

export default class AddressAutocomplete extends LightningElement {
    @api lines = [];
    @api opportunityId;
    searchResults = [];
    @track inputValue;
    @track employeeID;
    chosenResults = [];
    label = {
        HOEmployeeIDLabel,
        HOEmployeeIDFieldText,
        HOAutoCompleteAddressLabel,
        HOAutoCompleteAddressFieldText
    }

    async createLocationLine(data) {
        const fields = {};
        fields[cityFld.fieldApiName] = data.postnrnavn;
        fields[doorFld.fieldApiName] = data.dør;
        fields[floorFld.fieldApiName] = data.etage;
        fields[numberFld.fieldApiName] = data.husnr;
        fields[streetFld.fieldApiName] = data.vejnavn;
        fields[zipFld.fieldApiName] = data.postnr;
        fields[oppFld.fieldApiName] = this.opportunityId;
        fields[statusFld.fieldApiName] = 'Valid';
        fields[employeeFld.fieldApiName] = this.employeeID;
        var lines = [];
        lines.push(fields);
        await uploadLines({jsonData: JSON.stringify(lines)});
        this.employeeID = '';
    }

    employeeIdChange(event) {
        this.employeeID = event.target.value;
    }

    handleInputChange(event) {
        this.textValue = event.detail.value;
        this.callDawa(this.textValue, false);
    }

    handleSearchClick(event) {
        if (event.currentTarget.dataset.boolean != null) {
            var chosenOne = this.searchResults.find(element => element.forslagstekst === event.currentTarget.dataset.id); 
            chosenOne.employeeID = this.employeeID;
            this.chosenResults.push(chosenOne)
            this.createLocationLine(chosenOne.data);
            this.inputValue = '';
            this.searchResults = [];
            this.template.querySelector('lightning-input').focus();
        } else {
            try {
                this.callDawa(event.currentTarget.dataset.id + '%20', true);
            } catch (error) {
                console.error(error);
            }
        }
    }

    handleChosenClick(event) {
        console.log(event);
    }
    
    callDawa(query, clickTrigger) {
        var url = 'https://api.dataforsyningen.dk/autocomplete?q=' + query + '&type=adresse';
        var startFrom = '&startfra=adresse';
        if (this.searchResults.length < 6) {
            url = url + startFrom;
        }
        console.log(url);
        fetch(url, {
            method: "GET"
        }).then((response) => response.json())
            .then(results => {
                console.log(results)
                this.searchResults = results;
                if (clickTrigger == true && this.searchResults.length == 1) {
                    var chosenOne = this.searchResults[0];
                    chosenOne.employeeID = this.employeeID;
                    this.chosenResults.push(chosenOne)
                    this.createLocationLine(this.searchResults[0].data);
                    this.inputValue = '';
                    this.searchResults = [];
                    this.template.querySelector('lightning-input').focus();
                }
                if (clickTrigger == true && this.searchResults.length > 1) {
                    this.inputValue = query.slice(0,-3);
                    this.template.querySelectorAll('lightning-input')[1].focus();
                }
            });
    }
}