import { LightningElement, wire, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
const columns = [
    { label: 'Regulated Entity Account Name', fieldName: 'CIDx_Regulated_Entity_Account_Name__c' },
    { label: 'Regulated Entity Id', fieldName: 'CIDX_Regulated_Entity_ID__c' },
    { label: 'District', fieldName: 'CIDX_District__c' },
    { label: 'County', fieldName: 'CIDX_County__c' },
    { label: 'Reliant on Electricity to Operate', fieldName: 'CIDX_Reliant_on_Electricity_to_Operate__c' },
    { label: 'Backup Power', fieldName: 'CIDX_Regulated_Entity_Backup_Power__c' },
    { label: 'Utility Area', fieldName: 'CIDX_Utility_Area__c' },
    { label: 'Emergency Contact Full Name', fieldName: 'CIDX_Emergency_Full_Name__c' },
    { label: 'Onsite Contact Full Name', fieldName: 'CIDX_Onsite_Full_Name__c' },
];

export default class SelectedRowsPersistentPaginationLWC extends LightningElement {
    items = []; //contains all the records.
    data = []; //data  displayed in the table
    columns; //holds column info.
    startingRecord = 1; //start record position per page
    endingRecord = 0; //end record position per page
    pageSize = 10; //default value we are assigning
    @api selectedRecountCount = 0;
    totalPage = 0; //total number of page is needed to display all records
    selectedRows = [];
    @api selectedRowIds;
    @api filteredFilings;
    isShowModal = false;
    filterField = '';
    fieldOptions = [];
    isLoaded = true;
    @track searchKeyword = null;
    connectedCallback() {
        if (this.filteredFilings) {
            this.data = this.filteredFilings;
            this.columns = columns;
        }
        this.fieldOptions = columns.map((item) => ({
            label: item.label,
            value: item.fieldName,
        }));
        this.fieldOptions.unshift({label: 'None', value: null});
    }

    get totalRecountCount(){
        return this.data.length;

    }
    
    handleRowSelection(event) {
        let updatedItemsSet = new Set();
        // List of selected items we maintain.
        let selectedItemsSet = new Set(this.selectedRows);
        // List of items currently loaded for the current view.
        let loadedItemsSet = new Set();
        this.data.map((ele) => {
            loadedItemsSet.add(ele.Id);
        });
        if (event.detail.selectedRows) {
            event.detail.selectedRows.map((ele) => {
                updatedItemsSet.add(ele.Id);
            });
            // Add any new items to the selectedRows list
            updatedItemsSet.forEach((id) => {
                if (!selectedItemsSet.has(id)) {
                    selectedItemsSet.add(id);
                }
            });
        }
        loadedItemsSet.forEach((id) => {
            if (selectedItemsSet.has(id) && !updatedItemsSet.has(id)) {
                // Remove any items that were unselected.
                selectedItemsSet.delete(id);
            }
        });
        this.selectedRows = [...selectedItemsSet];
        console.log('selectedRows==> ' + JSON.stringify(this.selectedRows));
        this.selectedRecountCount = this.selectedRows.length;
        this.selectedRowIds = this.selectedRows;
        console.log('selectedRowIds==> ' + this.selectedRows);
    }

    handleSearch() {
        this.isLoaded = false;
        this.isShowModal = false;
        let searchKey;
        if(this.searchKeyword)
            searchKey = this.searchKeyword.toLowerCase();
        let searchRecordList = [];
        console.log('searchKey' +  searchKey);
        if (searchKey) { 
            this.data = this.filteredFilings;
            if (this.data) {
                for (let record of this.data) {
                        let strVal = String(record[this.filterField]);
                        if (strVal) {
                            if (strVal.toLowerCase().includes(searchKey)) {
                                searchRecordList.push(record);
                            }
                        }
                    }
                }
                console.log('Matched records are ' + JSON.stringify(searchRecordList));
                this.data = searchRecordList;
            }
         else {
            this.data = this.filteredFilings;
        }
        this.isLoaded = true;
        this.template.querySelector('[data-id="datatable"]').selectedRows = this.selectedRows;
       
    }
    openModal(){
        this.isShowModal = true;
    }
    closeModal(){
        this.isShowModal = false;
    }
    handleSearchKeyword(event){
        this.searchKeyword = event.target.value;
    }
    handleFieldNameChange(event){
        this.filterField = event.target.value;
    }
    handleClear(){
        this.filterField = null;
        this.searchKeyword = null;
    }
    handleClearMain(){
        this.isLoaded = false;
        this.data = this.filteredFilings;
        this.template.querySelector('[data-id="datatable"]').selectedRows = this.selectedRows;
        this.filterField = null;
        this.searchKeyword = null;
        this.isLoaded = true;
    }
    showToast(message, variant, title) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: 'dismissable'
        });
        this.dispatchEvent(event);
    }

    get showClearButton(){
        return this.searchKeyword != null;
    }
}