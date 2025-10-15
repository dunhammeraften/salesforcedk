import { LightningElement, track, api } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { loadScript } from "lightning/platformResourceLoader";
import sheetjs from "@salesforce/resourceUrl/sheetJS_0203";
import writexl from "@salesforce/resourceUrl/writexl";
import uploadLines from "@salesforce/apex/UploadTool.uploadLines";

import TOP_Home_Office_UploadTitle from "@salesforce/label/c.TOP_Home_Office_UploadTitle"; // Added by FF 18/03/2025
import TOP_Home_Office_UploadText from "@salesforce/label/c.TOP_Home_Office_UploadText"; // Added by FF 18/03/2025
import TOP_Button_DownloadTemplate from "@salesforce/label/c.TOP_Button_DownloadTemplate"; // Added by LO 18/03/2025
import VTPX_USERS_EXCELUPLOAD_SUCCESS from "@salesforce/label/c.VTPX_USERS_EXCELUPLOAD_SUCCESS"; // added by LO 18/03/2025

const customLabel = {
	TOP_Home_Office_UploadTitle,
	TOP_Home_Office_UploadText,
	TOP_Button_DownloadTemplate,
	VTPX_USERS_EXCELUPLOAD_SUCCESS
}

export default class UploadTool extends LightningElement {
	@api Lines;
	@track theLabels = customLabel;
	@api ParentID;
	@api OpportunityID;
	@api labels;
	@api names;
	@api AllowInsertNewLines;
	actLines = [];
	addLines = [];
	isReadyForUpload = true;
	isUploadingFile = false;
	isDoneUploading = false;
	//uploadDone = false;
	xlsxInitialized = false;

	renderedCallback() {

		if (this.xlsxInitialized) {
			return;
		}

		this.xlsxInitialized = true;

		loadScript(this, sheetjs);
		loadScript(this, writexl + "/write-excel-file.min.js");

	}

	importIgnoreFields = ["Product__c"]; //read only in import but exported

	isBlank(valueToCheck) {
		return valueToCheck == null || valueToCheck == "" || typeof valueToCheck == "undefined";
	};

	doExport() {
		let exportList = [];
		let columnFieldNames = this.fieldNamesToProcess;

		try {
			this.Lines.forEach((line) => {
				console.log('Hello');
				console.log(line);
				let fieldValues = [];
				for (let i = 0; i < columnFieldNames.length; i++) {
					let fieldName = columnFieldNames[i];
					console.log('fieldName = ' + fieldName);
					let fieldValue = "";
					if (line.hasOwnProperty(fieldName) && !this.isBlank(line[fieldName])) {
						fieldValue = line[fieldName];
						console.log('fieldValue = ' + fieldValue);
					}
					fieldValues.push(fieldValue);
				}
				exportList.push(fieldValues);
			});
		} catch (err) {
			console.log(err);
		}

		console.log('exportList = ', exportList);

		this.exportToExcel(exportList);
	}
	

	async doImportXls() {
		this.isReadyForUpload = false;
		this.isUploadingFile = true;

		let lineMap = {};

		let changeKeyObjects = (arr, replaceKeys) => {
			return arr.map((item) => {
				const newItem = {};
				Object.keys(item).forEach((key) => {
					newItem[replaceKeys[key]] = item[[key]];
				});
				console.log('newItem = ', newItem);
				return newItem;
			});
		};

		this.addLines.forEach((fullDataLine) => {
			lineMap[fullDataLine.Id] = fullDataLine;
		});

		let allRows = this.dataList;

		if (JSON.stringify(allRows).match(/(?:\?)/gm) != null) {
			const error = new ShowToastEvent({
				variant: "error",
				mode: "dismissable",
				message:
					"There are unsuppored characters in the document. Please fix and upload again"
			});
			this.dispatchEvent(error);
			return;
		}

		//set field map by first row - in case the user changed the column order
		let actlines2update = [];
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
				actlines2update.push(row);
			}
		}

		await uploadLines({ jsonData: JSON.stringify(actlines2update), actId: this.ParentID, insertLinesWithoutId: this.AllowInsertNewLines });

		let detail = {
			dataType: "activationLines",
			value: actlines2update,
			source: "table_cell",
			refreshData: true
		};

		actlines2update.forEach((line) => {
			let recordsData = {};
			recordsData[line.Id] = lineMap[line.Id];
			let responseDetail = {
				records: recordsData,
				recordId: line.Id
			};
		});

		this.isUploadingFile = false;
		this.isDoneUploading = true;
	}

	handleFileChange(event) {
		if (
			event.target.files[0].type === "application/vnd.ms-excel" ||
			event.target.files[0].type ===
			"application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
		) {
			event.preventDefault();
			let files = event.target.files;
			console.log("Step 1 ", files[0].type);
			const analysisExcel = (file) =>
				new Promise((resolve, reject) => {
					const reader = new FileReader();
					console.log("Step 2 ", reader);
					reader.readAsBinaryString(file);
					reader.onload = () => resolve(reader.result);
					reader.onerror = (error) => reject(error);
				});

			analysisExcel(files[0]).then((result) => {
				let datas = []; //  Store the acquired data
				let xl = window.XLSX;
				console.log("Data ", datas);
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

	handleDownloadTemplateClick() {
		this.doExport();
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
			fileName: "data.xlsx"
		});
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
			var name = namesList[i];
			returnValue.push(name);
		};

		return returnValue;
	}
		
}