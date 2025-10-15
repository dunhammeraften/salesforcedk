import { LightningElement, wire, api, track } from "lwc";
import {
    subscribe,
    MessageContext,
    publish
} from "lightning/messageService";
import ONBOARDING_CHANNEL from "@salesforce/messageChannel/onboardingChannel__c";
import { FlowAttributeChangeEvent } from 'lightning/flowSupport';
import { createRecord } from "lightning/uiRecordApi";
import { getObjectInfo } from 'lightning/uiObjectInfoApi';

import ACTIVATION_LINE_OBJECT from "@salesforce/schema/Activation_line__c";
import CASE_FIELD from "@salesforce/schema/Activation_line__c.Case__c";
import ACTIVATION_FIELD from "@salesforce/schema/Activation_line__c.Activation__c";
import QUOTELINE_FIELD from "@salesforce/schema/Activation_line__c.Quote_line__c";
import FIRST_NAME_FIELD from "@salesforce/schema/Activation_line__c.First_name__c";
import LAST_NAME_FIELD from "@salesforce/schema/Activation_line__c.Last_name__c";
import EMAIL_FIELD from "@salesforce/schema/Activation_line__c.Email__c";
import CONTACT_PHONE_FIELD from "@salesforce/schema/Activation_line__c.Onsite_Contact_Mobile__c";
import LINE_ID_FIELD from "@salesforce/schema/Activation_line__c.Line_ID__c";
import NUMBER_FIELD from "@salesforce/schema/Activation_line__c.Number__c";
import STREET_FIELD from "@salesforce/schema/Activation_line__c.Street_Name__c";
import DOOR_FIELD from "@salesforce/schema/Activation_line__c.Door__c";
import CITY_FIELD from "@salesforce/schema/Activation_line__c.City__c";
import FLOOR_FIELD from "@salesforce/schema/Activation_line__c.Floor__c";
import ZIP_FIELD from "@salesforce/schema/Activation_line__c.ZIP_Code__c";
import BILLING_ACCOUNT_FIELD from "@salesforce/schema/Activation_line__c.Billing_Account__c"; 

import POQ from'@salesforce/apex/ProductOfferingQualification.activationLineQualification';
import getAccountByCaseId from '@salesforce/apex/AccountSelector.getAccountByCaseId'
import getDefaultBanByAccountAndType from '@salesforce/apex/BillingAccountSelector.getDefaultBanByAccountAndType'
import getActivationByCaseId from '@salesforce/apex/ActivationSelector.getActivationByCaseId'
import getQuoteLineByCaseId from '@salesforce/apex/QuoteLineSelector.getQuoteLineByCaseId'

const MESSAGE_TYPE_POQ = 'POQ';
const MESSAGE_TYPE_UPDATE_TABLE = 'updateTable';
const BAN_TYPE = 'Business Internet';
const OBJECT_API_NAME = 'Activation_line__c';
const BI_RECORD_TYPE_NAME = 'Business Internet activation line';

export default class ProductOfferingQualification extends LightningElement {
    @wire(MessageContext)
    messageContext;
    subscription = null;
    @api inProgress = false;
    @track theQueue = [];
    isProcessing = false;
    queueLength = 0;
    recordTypeId;

    @wire(getObjectInfo, { objectApiName: OBJECT_API_NAME })
    objectInfo({ data, error }) {
        if (data) {
            // Find the Record Type ID by Name
            const recordTypes = data.recordTypeInfos;
            for (const key in recordTypes) {
                if (recordTypes[key].name === BI_RECORD_TYPE_NAME) {
                    this.recordTypeId = recordTypes[key].recordTypeId;
                    console.log('Record Type ID:', this.recordTypeId);
                    break;
                }
            }
        } else if (error) {
            console.error('Error fetching object info:', error);
        }
    }
    
    connectedCallback() {
        this.subscribeToMessageChannel();
        this.dispatchFlowChangeEvent('inProgress', false);
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
        if (message.type === MESSAGE_TYPE_POQ) {
            try {
                console.log('Received POQ message:', message);
                if (!this.caseId) {
                    await this.initializeContext(message.id);
                }
                console.log('test');
                console.log(this.account?.Id);
                this.defaultBAN = await getDefaultBanByAccountAndType({ accountId: this.account?.Id, type: BAN_TYPE });
                this.theQueue.push(...message.data);
                this.queueLength = this.theQueue.length;

                if (!this.isProcessing) {
                    this.isProcessing = true;
                    this.dispatchFlowChangeEvent('inProgress', true);
                    this.processQueue();
                }
            } catch (error) {
                console.error('Error:', error);
            }
        }
    }

    async initializeContext(caseId) {
        this.caseId = caseId;
        [this.account, this.activation, this.quoteline] = await Promise.all([
            getAccountByCaseId({ caseId }),
            getActivationByCaseId({ caseId }),
            getQuoteLineByCaseId({ caseId })
        ]);
    }

 
    async processQueue() {
        try {
            while (this.theQueue.length > 0) {
                let currentItem = this.theQueue.shift(); 
                
                const address = this.buildAddress(currentItem);
                const response = await fetch(`https://api.dataforsyningen.dk/datavask/adresser?betegnelse=${encodeURIComponent(address)}`);
                const { resultater, kategori } = await response.json();
    
                if (['A', 'B'].includes(kategori)) {
                    currentItem = this.updateLineWithValidatedData(currentItem, resultater[0].adresse);
                    const record = await this.createActivationLine(currentItem);
                    await POQ({ activationLineIds: [record.id] });
                }

                this.queueLength = this.theQueue.length;
                this.publishUpdate();
            }
            
        } catch (error) {
            console.error('Error:', error);
        } finally {
            console.log('finally');
            this.dispatchFlowChangeEvent('inProgress', false);
            this.isProcessing = false;
        }
    }
    
    updateLineWithValidatedData(line, validatedData) {
        return {
            ...line,
            Street_Name__c: validatedData.vejnavn,
            Number__c: validatedData.husnr,
            ZIP_Code__c: validatedData.postnr,
            City__c: validatedData.postnrnavn,
            Floor__c: validatedData.etage,
            Door__c: validatedData.dør
        };
    }

    async createActivationLine(line) {
        const fields = {
            [CASE_FIELD.fieldApiName]: String(this.caseId || ''),
            [ACTIVATION_FIELD.fieldApiName]: String(this.activation?.Id || ''),
            [QUOTELINE_FIELD.fieldApiName]: String(this.quoteline?.Id || ''),
            [BILLING_ACCOUNT_FIELD.fieldApiName]: String(line?.Billing_Account__c || this.defaultBAN?.Id || ''),
            [FIRST_NAME_FIELD.fieldApiName]: String(line.First_name__c || ''),
            [LAST_NAME_FIELD.fieldApiName]: String(line.Last_name__c || ''),
            [EMAIL_FIELD.fieldApiName]: String(line.Email__c || ''),
            [CONTACT_PHONE_FIELD.fieldApiName]: String(line.Onsite_Contact_Mobile__c || ''),
            [LINE_ID_FIELD.fieldApiName]: String(line.Line_ID__c || ''),
            [STREET_FIELD.fieldApiName]: String(line.Street_Name__c || ''),
            [NUMBER_FIELD.fieldApiName]: String(line.Number__c || ''),
            [DOOR_FIELD.fieldApiName]: String(line.Door__c || ''),
            [CITY_FIELD.fieldApiName]: String(line.City__c || ''),
            [FLOOR_FIELD.fieldApiName]: String(line.Floor__c || ''),
            [ZIP_FIELD.fieldApiName]: String(line.ZIP_Code__c || ''),
            RecordTypeId: this.recordTypeId
        };
    
        try {
            const activationLine = await createRecord({ apiName: ACTIVATION_LINE_OBJECT.objectApiName, fields });
            return activationLine;
        } catch (error) {
            console.error('Error creating activation line:', error);
            throw error;
        }
    }
    
    buildAddress({ Street_Name__c, Number__c, ZIP_Code__c, City__c, Floor__c, Door__c }) { // https://danmarksadresser.dk/om-adresser/saadan-gengives-en-adresse
        return `${Street_Name__c || ''} ${Number__c || ''}, ${Floor__c || ''} ${Door__c || ''}, ${ZIP_Code__c || ''} ${City__c || ''}`.replace(/undefined|null/g, '').trim();
    }

    dispatchFlowChangeEvent(name, value) {
        this.dispatchEvent(new FlowAttributeChangeEvent(name, value));
    }

    publishUpdate() {
        publish(this.messageContext, ONBOARDING_CHANNEL, {
            type: MESSAGE_TYPE_UPDATE_TABLE,
            data: null,
            id: null
        });
    }

}