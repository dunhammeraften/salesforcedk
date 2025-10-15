import { LightningElement, api, wire } from 'lwc';
import { loadScript } from 'lightning/platformResourceLoader';
import  sheetjs  from "@salesforce/resourceUrl/sheetJS_0203";
import { getRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

// Fields to fetch from the triggering record
const RECORD_FIELDS = ['Id'];

export default class ExcelExport extends LightningElement {
    @api recordId; // Record ID of the triggering record
    @api objectApiName; // Object API name of the triggering record
    @api fields; // Comma-separated list of fields to export (e.g., 'Name,Phone,Email')
    @api exportData; // Data to export
    @api exportObjectLabel; // OPTIONAL Label for the exported object
    @api schema; // OPTIONAL schema provided by the parent component
    @api fileName; // OPTIONAL file name for the exported file
    xlsxInitialized = false;

    @wire(getRecord, { recordId: '$recordId', fields: RECORD_FIELDS })
    wiredRecord({ error, data }) {
        if (data) {
            // Dynamically set the file name
            let fileName = this.fileName;
            if (!fileName && this.objectApiName && this.exportObjectLabel) {
                this.fileName = `${this.objectApiName}_${this.recordId}_${this.exportObjectLabel}.xlsx`;
                console.log('Dynamically set file name:', this.fileName);
            } else if (!fileName) {
                this.fileName = 'ExportedData.xlsx'; // Fallback to a default name
            } else {
                this.fileName = fileName;
            }
            
        } else if (error) {
            console.error('Error fetching record details:', error);
        }
    }

    @api async invoke() {
        if (!this.exportData || this.exportData.length === 0) {
            this.showToast('No Data', 'No data found to export.', 'info');
            return;
        }

        if (this.xlsxInitialized) {
            this.exportToExcel();
            return;
        }

        try {
            await Promise.all([
                loadScript(this, sheetjs),
            ]);
            this.xlsxInitialized = true;
            this.exportToExcel();
        } catch (error) {
            console.error('Error loading libraries:', error);
            this.showToast('Error', 'Failed to load required libraries. Please contact the Salesforce team', 'error');
        }
    }

    @api exportToExcel() {
        try {
            let schema = this.schema || this.generateDefaultSchema();    
            if (!Array.isArray(schema) || schema.some(sheet => !sheet.columns || !Array.isArray(sheet.columns))) {
                console.warn('Invalid schema provided. Falling back to default schema.');
                schema = [
                    {
                        sheet: 'Default Sheet',
                        columns: this.generateDefaultSchema()
                    }
                ];
            }
    
            if (!Array.isArray(this.exportData) || this.exportData.length === 0) {
                console.error('Export data is invalid or empty.');
                this.showToast('Error', 'Export data is invalid or empty.', 'error');
                return;
            }
    
            const workbook = XLSX.utils.book_new();
            schema.forEach(sheet => {
                const sheetData = this.exportData.map(row =>
                    sheet.columns.map(col => col.value(row))
                );
    
                const headers = sheet.columns.map(col => col.column);
                sheetData.unshift(headers);
    
                const worksheet = XLSX.utils.aoa_to_sheet(sheetData);
                XLSX.utils.book_append_sheet(workbook, worksheet, sheet.sheet || 'Sheet');
            });
    
            XLSX.writeFile(workbook, this.fileName);
            this.showToast('Success', `Excel file generated successfully. File name: ${this.fileName}`, 'success');
            this.xlsxInitialized = true;
        } catch (error) {
            console.error('Error in exportToExcel:', error);
            this.showToast('Error', 'Failed to generate Excel file.', 'error');
        }
    }

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }

    generateDefaultSchema() {
        if (!this.fields || typeof this.fields !== 'string') {
            console.warn('Fields are not defined or invalid. Returning an empty schema.');
            return [];
        }
    
        return this.fields.split(',').map(field => ({
            column: field.trim(),
            type: String,
            value: row => row[field.trim()],
        }));
    }
}