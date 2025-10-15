import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getActivationLines from '@salesforce/apex/ActivationLineExportController.getActivationLines';



export default class VtpxTemplateExport extends LightningElement {
    @api recordId; 
    @api objectApiName; // API name of the triggering object (e.g., 'Case')
    @api fields = 'Product__c,First_name__c,Last_name__c,Mobile_no__c,Email__c,Phone_no__c,Department__c,Job_description__c,Locale__c,Keywords__c,Id';
    rows = [];

    async handleDownloadTemplateClick(){
       
            try{
                const data = await getActivationLines({ caseId: this.recordId });
    
                if (!data || data.length === 0) {
                    this.showToast('No Data', 'No Activation Lines found for this Case.', 'info');
                    return;
                }


                this.rows = data.map(record => ({
                    Product__c: record.Product__c,
                    First_name__c: record.First_name__c,
                    Last_name__c: record.Last_name__c,
                    Mobile_no__c: record.Mobile_no__c,
                    Email__c: record.Email__c,
                    Phone_no__c: record.Phone_no__c,
                    Department__c: record.Department__c,
                    Job_description__c: record.Job_description__c,
                    Locale__c: record.Locale__c,
                    Keywords__c: record.Keywords__c,
                    Id: record.Id
                }));
    
                const schema = [
                    {
                        sheet: 'Main fields',
                        columns: [
                            { column: 'Product__c', type: String, value: (row) => row.Product__c },
                            { column: 'First Name', type: String, value: (row) => row.First_name__c },
                            { column: 'Last Name', type: String, value: (row) => row.Last_name__c },
                            { column: 'Mobile_no__c', type: String, value: (row) => row.Mobile_no__c },
                            { column: 'Email', type: String, value: (row) => row.Email__c },
                            { column: 'Phone_no__c', type: String, value: (row) => row.Phone_no__c },
                            { column: 'Department__c', type: String, value: (row) => row.Department__c },
                            { column: 'Job_description__c', type: String, value: (row) => row.Job_description__c },
                            { column: 'Locale__c', type: String, value: (row) => row.Locale__c },
                            { column: 'Keywords__c', type: String, value: (row) => row.Keywords__c },
                            { column: 'Technical ID (Do not change)', type: String, value: (row) => row.Id }
                        ]
                    }
                ];
        
                const excelExport = this.template.querySelector('c-excel-export');
                if (excelExport) {
                    excelExport.fields = this.fields;
                    excelExport.recordId = this.recordId; // Pass the recordId
                    excelExport.objectApiName = this.objectApiName; // Pass the objectApiName
                    excelExport.exportObjectLabel = 'Template'; // Label for the exported object
                    excelExport.schema = schema; // Pass the schema
                    excelExport.exportData = this.rows;
                    excelExport.fileName = 'Template_Export.xlsx'; // Default file name
                    excelExport.invoke();
                } else {
                    console.error('ExcelExport component not found.');
                }
            } catch (error) {
                console.error('Error fetching data:', error);
                this.showToast('Error', 'Failed to fetch data.', 'error');
            }
        };


    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }



}