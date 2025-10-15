import { LightningElement, api } from "lwc";
import { loadScript } from "lightning/platformResourceLoader";
import sheetjs from "@salesforce/resourceUrl/sheetjs";

import { FlowNavigationNextEvent } from 'lightning/flowSupport';
import { loadStyle } from 'lightning/platformResourceLoader'; 
import lightningInputFileImproved from '@salesforce/resourceUrl/lightningInputFileImproved'; // ????

import ID_FIELD from "@salesforce/schema/Account.Id";
import SALES_NOTE_1_FIELD from "@salesforce/schema/Account.Sales_Note_1__c";
import SALES_NOTE_2_FIELD from "@salesforce/schema/Account.Sales_Note_2__c";
import SALES_NOTE_3_FIELD from "@salesforce/schema/Account.Sales_Note_3__c";

import { updateRecord } from "lightning/uiRecordApi";

var XLSX = {}; // Are they needed?
window.XLSX = XLSX; // Are they needed?

export default class SalesPlayExcelTool extends LightningElement {

    @api accountIds = [];
    xlsxInitialized = false;  // Excel Script
    inProgress = false;

    renderedCallback() {
        if (this.xlsxInitialized) {
          return;
        }
        this.xlsxInitialized = true;
        loadScript(this, sheetjs + "/sheetjs/sheetmin.js");     // Used for Import
        loadStyle(this, lightningInputFileImproved);            // Visual upgrade for lightning-input
    }

    isBlank(valueToCheck) { // Replaced the function from topActivationUtils
        return valueToCheck == null || valueToCheck == "" || typeof valueToCheck == "undefined";
    }

    handleFileChange(event) {
        this.inProgress = true;

        if (event.target.files[0].type === "application/vnd.ms-excel" || event.target.files[0].type === "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet") {
          event.preventDefault();
          let files = event.target.files;
          const analysisExcel = (file) =>
            new Promise((resolve, reject) => {
              const reader = new FileReader();
              reader.readAsBinaryString(file);
              reader.onload = () => resolve(reader.result);
              reader.onerror = (error) => reject(error);
            });
    
          analysisExcel(files[0]).then((result) => {
            let datas = []; //  Store the acquired data
            console.log(datas);
            let xl = window.XLSX;
            let workbook = xl.read(result, {
              type: "binary"
            });
            console.log(workbook);
            for (let sheet in workbook.Sheets) {
              if (workbook.Sheets.hasOwnProperty(sheet)) {
                datas = datas.concat(
                  xl.utils.sheet_to_json(workbook.Sheets[sheet], {defval:""})
                );
              }
            }
            this.dataList = datas;
            console.log(this.dataList);
            this.doImportXls();
          });
        }
    }

    updateAccounts(importData) {
        for (let i = 0; i < importData.length; i++) {
          const fields = {};
          fields[ID_FIELD.fieldApiName] = importData[i].id;
          fields[SALES_NOTE_1_FIELD.fieldApiName] = importData[i].Sales_Note_1__c.toString();
          fields[SALES_NOTE_2_FIELD.fieldApiName] = importData[i].Sales_Note_2__c.toString();
          fields[SALES_NOTE_3_FIELD.fieldApiName] = importData[i].Sales_Note_3__c.toString();
          const record = {
            fields: fields
          };
          updateRecord(record);
        }
    }

    async doImportXls() {
    
        let changeKeyObjects = (arr, replaceKeys) => {
            return arr.map((item) => {
            const newItem = {};
            Object.keys(item).forEach((key) => {
                newItem[replaceKeys[key]] = item[[key]];
            });
            return newItem;
            });
        };
        
        let allRows = this.dataList;
        
        let importedAccounts = [];

        var labelsList = ['Id','id','Sales Note 1','Sales Note 2','Sales Note 3'];
        var namesList = ['id','id','Sales_Note_1__c','Sales_Note_2__c','Sales_Note_3__c'];
        var replaceKeys = {};

        for (let i = 0; i < labelsList.length; i++) {
            replaceKeys[labelsList[i]] = namesList[i];
        };

        const newArray = changeKeyObjects(allRows, replaceKeys);
        for (let i = 0; i < newArray.length; i++) {
            const row = newArray[i];
            if (!this.isBlank(row)) {
              importedAccounts.push(row);
            }
        }
        
        for (let i = 0; i < importedAccounts.length; i++) {
            this.accountIds.push(importedAccounts[i].id);
        }

        this.updateAccounts(importedAccounts);

        const navigateNextEvent = new FlowNavigationNextEvent();
        this.dispatchEvent(navigateNextEvent);

    }
}