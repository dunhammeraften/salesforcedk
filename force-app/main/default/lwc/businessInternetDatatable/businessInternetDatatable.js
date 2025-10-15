import { LightningElement, api, wire } from 'lwc';
import getBusinessInternetActivationLinesByCaseId from '@salesforce/apex/ActivationLineSelector.getBusinessInternetActivationLinesByCaseId';
import { FlowAttributeChangeEvent } from 'lightning/flowSupport';
import { refreshApex } from '@salesforce/apex';
import ONBOARDING_CHANNEL from "@salesforce/messageChannel/onboardingChannel__c";
import {
    subscribe,
    unsubscribe,
    MessageContext
} from "lightning/messageService";

const columns = [
    { label: 'Site ID', fieldName: 'Line_ID__c' },
    { label: 'Address', fieldName: 'Location__c', type: 'string' },
    { label: 'Product', fieldName: 'Product__c', type: 'string' },
    { label: 'Billing Account', fieldName: 'Billing_Account_Name_For_Portal__c', type: 'string' },
    { label: 'Name', fieldName: 'Full_name__c', type: 'string' },
    { label: 'Email', fieldName: 'Email__c', type: 'string' },
    { label: 'Phone', fieldName: 'Onsite_Contact_Mobile__c', type: 'string' },
];

export default class BusinessInternetDatatable extends LightningElement {
    @wire(MessageContext)
    messageContext;
    subscription = null;
    receivedMessage;

    @api recordId;
    data = [];
    columns = columns;
    error;
    @api selectedRows;
    @api rowSelected = false;
    isDataFresh = false;


    connectedCallback() {
        console.log('connectedCallback - recordId:', this.recordId);
        this.subscribeToMessageChannel();
        const AttributeEvent = new FlowAttributeChangeEvent('rowSelected' , false);
        this.dispatchEvent(AttributeEvent);
    }

    subscribeToMessageChannel() {
        this.subscription = subscribe(
            this.messageContext,
            ONBOARDING_CHANNEL,
            (message) => {
                this.handleMessage(message);
            }
        );
    }

    async handleMessage(message) {
        console.log('datatable handleMessage with type : ', message.type);
        if (message.type == 'updateTable') {
            try {
                refreshApex(this.wiredBusinessInternetActivationLines);
            } catch (error) {
                console.error(error);
            }
        }
    }

    wiredBusinessInternetActivationLines;
    @wire(getBusinessInternetActivationLinesByCaseId, { caseId: '$recordId' })
    retrieveActivationLines(wireResult) {
        this.wiredBusinessInternetActivationLines = wireResult; // Store the wire result
        const { data, error } = wireResult;
        if (data) {
            console.log('Data received:', data);
            this.data = data;
            this.error = undefined;
            if (this.isDataFresh != true) {
                console.log('refreshing...');
                refreshApex(this.wiredBusinessInternetActivationLines);
                this.isDataFresh = true;
            }
        } else if (error) {
            console.error('Error fetching data:', error);
            this.error = error;
            this.data = undefined;
        }
    }

    selectionEvent(event) {
        console.log('vuf');
        console.log('rowSelected - event:', event);
        const selectedRowsAttributeEvent = new FlowAttributeChangeEvent('selectedRows' , event.detail.selectedRows);
        this.dispatchEvent(selectedRowsAttributeEvent);
        if (event.detail.selectedRows.length > 0) {
            this.rowSelected = true;
        } else {
            this.rowSelected = false;
        }
        const rowSelectedAttributeEvent = new FlowAttributeChangeEvent('rowSelected' , this.rowSelected);
        this.dispatchEvent(rowSelectedAttributeEvent);
        event.detail.selectedRows.forEach((selectedRow) => {
            console.log('Selected : ' + selectedRow.Full_name__c);
        });
   
    }




}