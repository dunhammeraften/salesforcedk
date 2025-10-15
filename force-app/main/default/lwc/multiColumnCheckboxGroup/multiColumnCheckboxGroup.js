import { LightningElement, api, track } from 'lwc';
import { FlowAttributeChangeEvent } from 'lightning/flowSupport';

// comment
export default class MultiColumnCheckboxGroup extends LightningElement {
    @api options;
    @api selectedValues = [];
    @api numColumns = 5;
    @api numRows = 10;
    @track currentPage = 1;

    get processedOptions() {
        if (!this.options) {
            return [];
        }
        const start = (this.currentPage - 1) * this.numRows * this.numColumns;
        const end = start + this.numRows * this.numColumns;
        return this.options.slice(start, end).map(option => ({
            label: option,
            value: option,
            checked: this.selectedValues.includes(option)
        }));
    }

    get gridStyle() {
        return `grid-template-columns: repeat(${this.numColumns}, 1fr);`;
    }

    get totalPages() {
        if (!this.options) {
            return 1;
        }
        return Math.ceil(this.options.length / (this.numRows * this.numColumns));
    }

    get isFirstPage() {
        return this.currentPage === 1;
    }

    get isLastPage() {
        return this.currentPage === this.totalPages;
    }

    get hasOptions() {
        return this.options && this.options.length > 0;
    }

    handleChange(event) {
        const value = event.target.value;
        const selected = event.target.checked;

        if (selected) {
            this.selectedValues = [...this.selectedValues, value];
        } else {
            this.selectedValues = this.selectedValues.filter(selectedValue => selectedValue !== value);
        }

        const attributeChangeEvent = new FlowAttributeChangeEvent('selectedValues', this.selectedValues);
        this.dispatchEvent(attributeChangeEvent);
    }

    handleSelectAllChange(event) {
        const selected = event.target.checked;
        this.selectedValues = selected ? this.options.slice() : [];
        const attributeChangeEvent = new FlowAttributeChangeEvent('selectedValues', this.selectedValues);
        this.dispatchEvent(attributeChangeEvent);
    }

    previousPage() {
        if (this.currentPage > 1) {
            this.currentPage--;
        }
    }

    nextPage() {
        if (this.currentPage < this.totalPages) {
            this.currentPage++;
        }
    }
}