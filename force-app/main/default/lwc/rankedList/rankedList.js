import { LightningElement, track, api, wire } from 'lwc';
import { loadScript } from 'lightning/platformResourceLoader';
import { updateRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import PRODUCTPREFERENCES_FIELD from '@salesforce/schema/Account.Home_Office_Product_Preferences__c';
import ACCOUNT_ID_FIELD from '@salesforce/schema/Account.Id';
import SortableJS from '@salesforce/resourceUrl/SortableJS';
import lang from '@salesforce/i18n/lang';
import getHomeOfficeProductOptionsRanking from "@salesforce/apex/HomeOfficeSelector.getHomeOfficeProductOptionsRanking";
import getHomeOfficeProductOptions from "@salesforce/apex/HomeOfficeSelector.getHomeOfficeProductOptions";

export default class rankedList extends LightningElement {
  @api recordId;
  @api ProductPreferences;
  @api ProductPreferencesNew;
  @api daLang;
  @api HomeOfficeProductOptions;
  @api HomeOfficeProductOptionsRanking;
  @track ElementList = []
  showSpinner = false;

  handleSave() {
    const fields = {};
    const productRankingList = Array.from(this.template.querySelectorAll('[class=item]'))
    .map(item => item.getAttribute('data-id'));
    
    fields[ACCOUNT_ID_FIELD.fieldApiName] = this.recordId;
    fields[PRODUCTPREFERENCES_FIELD.fieldApiName] = productRankingList.join('|');
    const recordInput = { fields: fields};

    updateRecord(recordInput)
    .then(() => {
      const successMessage = (lang === 'da') ? 'Præferencer opdateret' : 'Preferences updated';

      this.dispatchEvent(
        new ShowToastEvent({
          title: 'Success',
          message: successMessage,
          variant: 'success'
        })
      );
    })
    .catch(error => {
      this.dispatchEvent(
        new ShowToastEvent({
          title: 'Error updating record',
          message: error.body.message,
          variant: 'error'
        })
      );
    });


  }

  loadItAll() {
    try {
      var tmpElementList = [];
      for (let i = 0; i < this.HomeOfficeProductOptions.length; i++) {
        tmpElementList.push(this.HomeOfficeProductOptions[i]);
      }
      
      var order = this.ProductPreferencesNew.split('|');

      const sorted = tmpElementList.sort((a,b) => {
        const indexA = order.findIndex(sequence => String(a.Product_Sequence__c) === sequence);
        const indexB = order.findIndex(sequence => String(b.Product_Sequence__c) === sequence);
        return indexA - indexB;
      });    

      this.ElementList = tmpElementList;

      this.showSpinner = false;
      
      var el = this.template.querySelector('[class=wrapper]');
      
      var sortable = Sortable.create(el, {
          animation: 350,
          ghostClass: "ghost",
          dataIdAttr: 'data-id',
          group: "productRanking",
      });

      this.template.querySelector('[class=reset]').addEventListener('click', function(e) {
        var initialOrder = ['200', '100', '400', '300', '250', '350', '800', '500', '600', '550', '700']
        sortable.sort(initialOrder, true);    
      })
    } catch(err) {
        console.log(err);
    }
  }

  connectedCallback() {
    if (lang == 'da') {
      this.daLang = true;
    }
    loadScript(this, SortableJS);
    getHomeOfficeProductOptionsRanking().then((result) => {
      try {
        var clean = result.split('|');
        this.HomeOfficeProductOptionsRanking = clean;
      } catch {
        console.log('Standard');
      } finally {
        console.log('Finally');
        getHomeOfficeProductOptions()
        .then((results) => {
          this.HomeOfficeProductOptions = results;
          this.loadItAll();
          }).catch(error => {
              console.log(error);
          })
      }

    }).catch(error => {
      console.log(error);
    });


  }

}