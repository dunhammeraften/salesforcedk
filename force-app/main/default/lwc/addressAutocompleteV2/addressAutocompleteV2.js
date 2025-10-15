import { LightningElement, track, wire, api } from 'lwc';
import getBansByCaseAndType from '@salesforce/apex/BillingAccountSelector.getBansByCaseAndType';
import { publish, MessageContext } from "lightning/messageService";
import ONBOARDING_CHANNEL from "@salesforce/messageChannel/onboardingChannel__c";
import getActivationByCaseId from '@salesforce/apex/ActivationSelector.getActivationByCaseId';
import getQuoteLineByCaseId from '@salesforce/apex/QuoteLineSelector.getQuoteLineByCaseId';
import { refreshApex } from '@salesforce/apex';

const BAN_TYPE = 'Business Internet';

export default class AddressAutocompleteV2 extends LightningElement {
    @track suggestions = [];
    @track selectedAddresses = [];
    @track selectedIndex = -1;
    @track query = '';
    @track billingAccounts;
    @track error;
    @track defaultBAN;
    @track comboboxValues = {};
    @api recordId;
    activationId;
    quoteLineId;

    isDataFresh = false;

    @wire(MessageContext)
    messageContext;

    connectedCallback(){
        console.log('connectedCallback');
        const savedData = sessionStorage.getItem('addressLookup');
        if (savedData) {
            console.log(savedData);
            this.selectedAddresses = JSON.parse(savedData);
        }
    }

    disconnectedCallback(){
        console.log('disconnectedCallback');

        // Remove items from this.selectedAddresses that have the isSelected flag set to true
        this.selectedAddresses = this.selectedAddresses.filter(item => !item.data.isSelected);
        console.log('sessionStorage will be set to : ', JSON.stringify(this.selectedAddresses));
         // Save data to localStorage (or sessionStorage)
         sessionStorage.setItem('addressLookup', JSON.stringify(this.selectedAddresses));
    }

    @wire(getQuoteLineByCaseId, {caseId: '$recordId'})
    wiredQuoteLine({ error, data }) {
        if (data) {
            this.quoteLineId = data.Id;
            console.log('quote data', data);
        } else if (error) { 
            console.error('error', error);
        }
    }

    @wire(getActivationByCaseId, {caseId: '$recordId'})
    wiredActivation({ error, data }) {
        if (data) {
            this.activationId = data.Id;
            console.log('activation data', data);
        } else if (error) { 
            console.error('error', error);
        }
    }

    _wiredBillingAccounts;

    @wire(getBansByCaseAndType, { caseId: '$recordId', type: BAN_TYPE })
    retrieveBans(wireResult) {
        this._wiredBillingAccounts = wireResult; // Store the wire result
        const { data, error } = wireResult;
        
        if (data) {
            console.log('data', data);
            this.billingAccounts = this.convertToComboboxOptions(data);
            
            const defaultAccount = data.find(item => item.Default_Billing_Account__c === true);
            this.defaultBAN = defaultAccount ? defaultAccount.Id : undefined;
            
            this.error = undefined;
            if (this.isDataFresh != true) {
                refreshApex(this._wiredBillingAccounts);
                this.isDataFresh = true;
            }
            
        } else if (error) {
            console.error('error', error);
            this.error = error;
            this.billingAccounts = undefined;
            this.defaultBAN = undefined;
        }
    }
    
    convertToComboboxOptions(data) {
        console.log('data', data);
        var returnValue = data.map(item => {
            return {
                value: item.Id,
                label: item.Name
            };
        });
        return returnValue;
    }

    handleSearchInput(event) {
        this.query = event.target.value;
        console.log(this.query);
        if (this.query.length > 0) {
            this.fetchAddressSuggestions('vejnavn');
        } else {
            this.suggestions = [];
        }
    }

    async fetchAddressSuggestions(startfra) {
        console.log('startfra', startfra);
        try {
            const url = `https://api.dataforsyningen.dk/autocomplete?q=${this.query}&per_side=5&startfra=${startfra}`;
            const response = await fetch(url);
            const data = await response.json();
            this.suggestions = data;
            this.selectedIndex = -1;
            this.updateClassNames();
            console.log('suggestions', this.suggestions);
        } catch (error) {
            console.error('Error fetching suggestions:', error);
            this.suggestions = [];
        }
    }
    

    handleKeyPress(event) {
        const { key } = event;
        if (this.suggestions.length) {
            if (key === 'ArrowDown') {
                this.selectedIndex = (this.selectedIndex + 1) % this.suggestions.length;
            } else if (key === 'ArrowUp') {
                this.selectedIndex = (this.selectedIndex - 1 + this.suggestions.length) % this.suggestions.length;
            } else if (key === 'Enter' && this.selectedIndex >= 0) {
                this.selectSuggestion(this.selectedIndex);
            }
            this.updateClassNames();
        }
    }

    handleSuggestionClick(event) {
        const index = event.currentTarget.dataset.index;
        this.selectSuggestion(index);
    }

    async selectSuggestion(index) {
        const selected = this.suggestions[index];

        if (selected && !this.selectedAddresses.includes(selected) && selected.type == 'adresse') {
            this.selectedAddresses = [...this.selectedAddresses, selected];
            this.suggestions = [];
            this.selectedIndex = -1;
            this.query = '';
            console.log('billingAccounts', this.billingAccounts);
            console.log('selectedAddresses', this.selectedAddresses);
        } else if (selected && selected.type == 'vejnavn') {
            console.log('vejnavn');
            this.query = selected.forslagstekst + ' ';
            this.fetchAddressSuggestions('adresse');
        } else if (selected && this.selectedAddresses.includes(selected) && selected.type == 'adresse') {
            console.log('Alread y selected!');
        } else if (selected && selected.type == 'adgangsadresse') {
            console.log('adgangsadresse');
            this.query = selected.forslagstekst;
            await this.fetchAddressSuggestions('vejnavn');
            console.log('suggestions length: ', this.suggestions.length);
            console.log('type:', this.suggestions[0].type);
   
            if (this.suggestions.length = 1 && this.suggestions[0].type != 'adgangsadresse') {
                this.selectSuggestion(0);
            }
        } else {
            console.error('Error selecting suggestion');
        }
        
    }

    updateClassNames() {
        this.suggestions.forEach((suggestion, index) => {
            suggestion.className = index === this.selectedIndex ? 'selected' : 'suggestion';
        });
    }

    handleComboboxChange(event) {
        console.log('CHANGE!');
        const formId = event.target.dataset.id;
        this.comboboxValues = { ...this.comboboxValues, [formId]: event.detail.value };
        console.log('event.target.dataset.id', event.target.dataset.id);
        console.log('event.detail.value', event.detail.value);
        console.log('this.comboboxValues', this.comboboxValues);
    }

    handleSubmit(event) {
        event.preventDefault();
        console.log('handleSubmit');
    
        // Retrieve the formIndex from the data attribute of the event target
        const formIndex = event.target.dataset.id;

        // console.log('Selected:', JSON.stringify(this.selectedAddresses[formIndex]));

        // Check if the index is valid and update the corresponding address
        if (formIndex != -1) {
            this.selectedAddresses[formIndex].data.isSelected = true;
            console.log('Updated address:', JSON.stringify(this.selectedAddresses[formIndex]));
        } else {
            console.warn('No matching address found for formIndex:', formIndex);
        }
        
        const address = this.selectedAddresses[formIndex];
        const fields = event.detail.fields;
    
        // Update specific fields
        fields.Billing_Account__c = this.comboboxValues[formIndex];
        fields.Activation__c = this.activationId;
        fields.Quote_line__c = this.quoteLineId;
        
        //// Add fields from the this.selectedAddresses[formIndex]
        fields.Street_Name__c = address.data.vejnavn !== null ? address.data.vejnavn : fields.Street_Name__c;
        fields.Number__c = address.data.husnr !== null ? address.data.husnr : fields.Number__c;
        fields.ZIP_Code__c = address.data.postnr !== null ? address.data.postnr : fields.ZIP_Code__c;
        fields.City__c = address.data.postnrnavn !== null ? address.data.postnrnavn : fields.City__c;
        fields.Floor__c = address.data.etage !== null ? address.data.etage : fields.Floor__c;
        fields.Door__c = address.data.dør !== null ? address.data.dør : fields.Door__c;

        this.startProcessor([fields], formIndex)
    }
    
    startProcessor(line, index) {
        const message = {
            data: line,
            id: this.recordId,
            type: 'POQ'
        };
        publish(this.messageContext, ONBOARDING_CHANNEL, message);

        this.uploadInProgress = false;
        this.uploadDone = true;
        setTimeout(() => {
            this.selectedAddresses.splice(index, 1);
            console.log('upload done being done');
        }, 5000);
    }
}