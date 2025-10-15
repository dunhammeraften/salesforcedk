import { LightningElement, api, wire } from "lwc";
import { loadScript } from "lightning/platformResourceLoader";

import sheetjs from "@salesforce/resourceUrl/sheetjs";
import writexl from "@salesforce/resourceUrl/writexl";

import { FlowAttributeChangeEvent } from 'lightning/flowSupport';
import { loadStyle } from 'lightning/platformResourceLoader'; 

import lightningInputFileImproved from '@salesforce/resourceUrl/lightningInputFileImproved';
import lightningProgressBarImproved from '@salesforce/resourceUrl/lightningProgressBarImproved';

import HODownloadTemplate from '@salesforce/label/c.HODownloadTemplate'; // TO DO !
import HOStatus from '@salesforce/label/c.HOStatus'; // TO DO !

import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import { publish, MessageContext } from "lightning/messageService";
import ONBOARDING_CHANNEL from "@salesforce/messageChannel/onboardingChannel__c";

export default class ActivationLineUploadTool extends LightningElement {
    @api inProgress = false;
    @api recordId;
    uploadDone = false;       // Somewhat unnecessary due to auto-navigating to next flow element
    uploadInProgress = false; // Controls render of process bar
    xlsxInitialized = false;  // Excel Script
    HODownloadTemplateLabel = HODownloadTemplate;
    HOStatusLabel = HOStatus;
    labelsList = ['Site ID', 'First name', 'Last name', 'Email', 'Phone', 'Street Name', 'Number', 'ZIP Code', 'City', 'Floor', 'Door'];
    namesList = ['Line_ID__c', 'First_name__c', 'Last_name__c', 'Email__c', 'Onsite_Contact_Mobile__c', 'Street_Name__c', 'Number__c', 'ZIP_Code__c', 'City__c', 'Floor__c', 'Door__c'];

    @wire(MessageContext)
    messageContext;

    renderedCallback() {
        if (this.xlsxInitialized) {
            return;
        }
        this.xlsxInitialized = true;
        
        Promise.all([
            loadScript(this, sheetjs + "/sheetjs/sheetmin.js"),
            loadScript(this, writexl + "/write-excel-file.min.js"), // Is it even necessary?
            loadStyle(this, lightningInputFileImproved),
            loadStyle(this, lightningProgressBarImproved)
        ])
        .then(() => {
            console.log('Scripts and styles loaded successfully.');
        })
        .catch(error => {
            console.error('Error loading scripts or styles:', error);
        });
    }

    async doImportXls() {
        this.uploadInProgress = true;
        
   
        const changeKeyObjects = (arr, replaceKeys) => arr.map(item =>
            Object.fromEntries(Object.entries(item).map(([key, value]) => [replaceKeys[key] || key, value]))
        );
        
        let allRows = this.dataList;
     
        const replaceKeys = Object.fromEntries(this.labelsList.map((label, i) => [label, this.namesList[i]]));
        const newArray = changeKeyObjects(allRows, replaceKeys);
        const lines = newArray.filter(row => row !== null && row !== "" && typeof row !== "undefined");

        var linesUploaded = lines.length;
        console.log('Number of lines: ', linesUploaded);

        if (linesUploaded > 500) {
            this.uploadInProgress = false;
            const event = new ShowToastEvent({
                title: 'Too many lines uploaded',
                message:
                    'You are not allowed to upload more than 500 lines.',
            });
            this.dispatchEvent(event);
            return;
        } else {
            this.startProcessor(lines);
        }
    }

    startProcessor(lines) {
        const message = {
            data: lines,
            id: this.recordId,
            type: 'POQ'
        };
        publish(this.messageContext, ONBOARDING_CHANNEL, message);
        const attributeEvent = new FlowAttributeChangeEvent('inProgress' , true);
        this.dispatchEvent(attributeEvent);
        this.uploadInProgress = false;
        this.uploadDone = true;
        setTimeout(() => {
            const attributeEvent = new FlowAttributeChangeEvent('inProgress' , false);
            this.dispatchEvent(attributeEvent);
            this.uploadDone = false;
            console.log('upload done being done');
        }, 5000);
    }

    async downloadTemplate() {
        let excelList = [];
        await writeXlsxFile(excelList, {
            schema: this.fieldLabelsToProcess,
            fileName: "template.xlsx"
        });
    }

    async handleFileChange(event) {
        const file = event.target.files[0];

        if (file.type !== "application/vnd.ms-excel" && file.type !== "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet") {
            return;
        }

        event.preventDefault();

        try {
            const result = await this.readFileAsBinaryString(file);
            const xl = window.XLSX;
            const workbook = xl.read(result, { type: "binary" });
    
            let datas = [];
            for (let sheet in workbook.Sheets) {
                if (workbook.Sheets.hasOwnProperty(sheet)) {
                    datas = datas.concat(xl.utils.sheet_to_json(workbook.Sheets[sheet]));
                }
            }
            this.dataList = datas;
            this.doImportXls();
        } catch (error) {
            console.error('Error reading file:', error);
        }
        
    }

    readFileAsBinaryString(file) {
        return new Promise((resolve, reject) => {
            const reader = new FileReader();
            reader.readAsBinaryString(file);
            reader.onload = () => resolve(reader.result);
            reader.onerror = reject;
        });
    }

    get fieldLabelsToProcess() {
        let returnValue = [];
        
        for (let i = 0; i < this.labelsList.length; i++) {
            var label = {
                column: this.labelsList[i],
                type: String,
                wrap: false,
                width: 30,
                value: (data) => data[this.labelsList[i]]
            }
            returnValue.push(label);
        };

        return returnValue;
    }

}