import { LightningElement, api } from "lwc";
import { loadScript } from "lightning/platformResourceLoader";
import sheetjs from "@salesforce/resourceUrl/sheetjs";
import writexl from "@salesforce/resourceUrl/writexl";
import uploadLocationLineAndReturnRecord from "@salesforce/apex/LocationLineUploadTool.uploadLocationLineAndReturnRecord";
import POQ from "@salesforce/apex/ProductOfferingQualification.main";
import { FlowNavigationNextEvent } from 'lightning/flowSupport';
import { loadStyle } from 'lightning/platformResourceLoader'; 
import lightningInputFileImproved from '@salesforce/resourceUrl/lightningInputFileImproved';
import lightningProgressBarImproved from '@salesforce/resourceUrl/lightningProgressBarImproved';
import HOBack from '@salesforce/label/c.HOBack';
import HODownloadTemplate from '@salesforce/label/c.HODownloadTemplate';
import HOStatus from '@salesforce/label/c.HOStatus';

var XLSX = {};
window.XLSX = XLSX;

export default class LocationLineUploadTool extends LightningElement {
  @api OpportunityID        // Used for Import
  @api LocationLines;       // Used for Export
  uploadDone = false;       // Somewhat unnecessary due to auto-navigating to next flow element
  uploadInProgress = false; // Controls render of process bar
  linesUploaded;            // Used to calculate process
  currentlyProcessed;       // Used to calculate process
  progressPercentage = 0;   // Used to calculate process
  xlsxInitialized = false;  // Excel Script
  @api labels;              // Field Labels for Excel Export/Import
  @api names;               // Field Names for Excel Export/Import
  @api importIgnoreFields;  // Not used (yet)
  HOBackLabel = HOBack;
  HODownloadTemplateLabel = HODownloadTemplate;
  HOStatusLabel = HOStatus;

  renderedCallback() {
    if (this.xlsxInitialized) {
      return;
    }
    this.xlsxInitialized = true;
    loadScript(this, sheetjs + "/sheetjs/sheetmin.js");     // Used for Import ?
    loadScript(this, writexl + "/write-excel-file.min.js"); // Used for Export ?
    loadStyle(this, lightningInputFileImproved);            // Visual upgrade for lightning-input
    loadStyle(this, lightningProgressBarImproved);            // Visual upgrade for lightning-progress-bar
  }
  
  doExport() {
    let exportList = [];
    let columnFieldNames = this.fieldNamesToProcess;
    if (!this.isBlank(this.LocationLines)) {
      try {
        this.LocationLines.forEach((line) => {
            let fieldValues = [];
            for (let i = 0; i < columnFieldNames.length; i++) {
              let fieldName = columnFieldNames[i];
              let fieldValue = "";
              if (line.hasOwnProperty(fieldName) && !this.isBlank(line[fieldName])) {
                fieldValue = line[fieldName];
              }
              fieldValues.push(fieldValue);
            }
            exportList.push(fieldValues);
          });
        } catch(err) {
          console.log(err);
        }
    }
    this.exportToExcel(exportList);
  }
  
  isBlank(valueToCheck) { // Replaced the function from topActivationUtils
    return valueToCheck == null || valueToCheck == "" || typeof valueToCheck == "undefined";
  }

  buildAddress(locationLine) {
    const { Street_Name__c, Number__c, ZIP_Code__c, City__c, Floor__c, Door__c } = locationLine;
    var address = `${Street_Name__c} ${Number__c}, ${Floor__c}. ${Door__c}, ${ZIP_Code__c} ${City__c}`
    address = address.replaceAll('undefined','');
    return address; // https://danmarksadresser.dk/om-adresser/saadan-gengives-en-adresse
  }   

  async doImportXls() {
    this.uploadInProgress = true;
    
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
    
    let locationLine = [];

    var labelsList = this.labels.split(',');
    var namesList = this.names.split(',');
    var replaceKeys = {};

    for (let i = 0; i < labelsList.length; i++) {
      replaceKeys[labelsList[i]] = namesList[i];
    };

    const newArray = changeKeyObjects(allRows, replaceKeys);
    for (let i = 0; i < newArray.length; i++) {
      const row = newArray[i];
      if (!this.isBlank(row)) {
        locationLine.push(row);
      }
    }

    this.linesUploaded = locationLine.length;
    
    for (let i = 0; i < locationLine.length; i++) {
      this.currentlyProcessed = i + 1;
      this.progressPercentage = Math.ceil((this.currentlyProcessed/this.linesUploaded)*100);
      
      var address = this.buildAddress(locationLine[i]);

      try {
        const response = await fetch('https://api.dataforsyningen.dk/datavask/adresser?betegnelse=' + encodeURIComponent(address));
        const data = await response.json();
        const result = data.resultater[0].adresse;

        if (data.kategori != 'A' &&  data.kategori != 'B') {
          locationLine[i].addressWash_Category__c = 'C';
          locationLine[i].Address_Wash_Status__c = 'Not Valid';
        } else {
          locationLine[i].Street_Name__c = result.vejnavn;
          locationLine[i].Number__c = result.husnr;
          locationLine[i].ZIP_Code__c = result.postnr;
          locationLine[i].City__c = result.postnrnavn;
          locationLine[i].Floor__c = result.etage;
          locationLine[i].Door__c = result.dør;
          locationLine[i].addressWash_Category__c = 'A';
          locationLine[i].Address_Wash_Status__c = 'Valid';
        }

        const jsonData = JSON.stringify(locationLine[i]);

        const record = await uploadLocationLineAndReturnRecord({jsonData: jsonData, oppId: this.OpportunityID});

        if (locationLine[i].Address_Wash_Status__c == 'Valid') {
          const locationLinesList = [[record]];
          await POQ({lines: locationLinesList, fullQualification: false});
        }
      
      } catch(error) {
        console.error('Error occurred:', error);
      }

    }

    this.uploadInProgress = false;
    this.uploadDone = true;

    const navigateNextEvent = new FlowNavigationNextEvent();
    this.dispatchEvent(navigateNextEvent);

  }

  async exportToExcel(rows) {
    let excelList = [];
    
    rows.map((row) => {
      let tempRow = {};
      this.fieldLabelsToProcess.map((field, i) => {
        tempRow[field.column] = row[i];
      });
      excelList.push(tempRow);
    });
    await writeXlsxFile(excelList, {
      schema: this.fieldLabelsToProcess,
      fileName: "addresses.xlsx"
    });
  }

  goBack() {
    const navigateNextEvent = new FlowNavigationNextEvent();
    this.dispatchEvent(navigateNextEvent);
  }

  handleFileChange(event) {
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
        let xl = window.XLSX;
        let workbook = xl.read(result, {
          type: "binary"
        });

        for (let sheet in workbook.Sheets) {
          if (workbook.Sheets.hasOwnProperty(sheet)) {
            datas = datas.concat(
              xl.utils.sheet_to_json(workbook.Sheets[sheet])
            );
          }
        }
        this.dataList = datas;
        this.doImportXls();
      });
    }
  }

  get fieldLabelsToProcess() {
    let returnValue = [];

    var labelsList = this.labels.split(',');
    
    for (let i = 0; i < labelsList.length; i++) {
      var label = {
        column: labelsList[i],
        type: String,
        wrap: false,
        width: 30,
        value: (data) => data[labelsList[i]]
      }
      returnValue.push(label);
    };

    return returnValue;
  }
  
  get fieldNamesToProcess() {
    let returnValue = [];
    
    var namesList = this.names.split(',');
    
    for (let i = 0; i < namesList.length; i++) {
      returnValue.push(namesList[i]);
    };

    return returnValue;
  }
}