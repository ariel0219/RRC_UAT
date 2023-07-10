import { LightningElement,wire,track,api } from 'lwc';
import getRegistrationCheckInList from '@salesforce/apex/EEM_RegistrationCheckIn.getRegistrationCheckInList';
import findRegistrationCheckIn from '@salesforce/apex/EEM_RegistrationCheckIn.findRegistrationCheckIn';
import getTotalCount from '@salesforce/apex/EEM_RegistrationCheckIn.getTotalCount';
import getCheckInCount from '@salesforce/apex/EEM_RegistrationCheckIn.getCheckInCount';
import getNotCheckedInCount from '@salesforce/apex/EEM_RegistrationCheckIn.getNotCheckedInCount';
import getOnholdCount from '@salesforce/apex/EEM_RegistrationCheckIn.getOnholdCount';
import getRegisteredCount from '@salesforce/apex/EEM_RegistrationCheckIn.getRegisteredCount';
import getEventTitle from '@salesforce/apex/EEM_RegistrationCheckIn.getEventTitle';

import {getRecord, getFieldValue, updateRecord} from 'lightning/uiRecordApi';
import { refreshApex } from '@salesforce/apex';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import {CurrentPageReference} from 'lightning/navigation';
import modal from "@salesforce/resourceUrl/custommodalcss";
import { loadStyle } from "lightning/platformResourceLoader";

const columns = [
    
    { label: 'Event Registration', fieldName: 'Name', sortable:"true" },
    { label: 'Event Title',  fieldName: 'EEM_Event_Title__c',sortable: "true" },
    { label: 'Full Name', fieldName: 'Registrant_Name__c', sortable:"true"},
    { label: 'Company Name', fieldName: 'EEM_Company_Name__c', sortable:"true"},
    { label: 'Registrant Email',  fieldName: 'EEM_Registrant_Email__c', sortable:"true" },
    { label: 'Registration Date',  fieldName: 'EEM_Registration_Date__c',sortable: "true" },
	{ label: 'Status',  fieldName: 'EEM_Status__c', sortable:"true"},
	{ label: 'CheckedIn',  fieldName: 'EEM_Checked_In__c',sortable: "true"},
    { label: 'Action',
      type: 'button',
      initialWidth: 75,
       typeAttributes: {
            iconName: { fieldName: 'rowIcon' },
            title: { fieldName: 'rowTitle' },
            variant: {fieldName: 'rowbrand' },
            alternativeText: 'Check-In',
           
            
        }
      }  
          
    
];
const DELAY = 350;
export default class eem_checkInRegistration extends LightningElement {
  
    @track columns = columns;
    @track error;
    @track registrations = [];
    @api recordId;
   
    eventId = this.recordId;
    @api keySearch = '';
    @track registrationRow={};
    @track totalRec = 0;

    @wire(getRegistrationCheckInList, {eventId: '$eventId' }) wireRegistration;
    @wire(getTotalCount, {eventId: '$eventId' }) wireTotalCount;
    @wire(getCheckInCount, {eventId: '$eventId' }) wireCheckInCount;
    @wire(getNotCheckedInCount, {eventId: '$eventId' }) wireNotCheckedInCount;
    @wire(getOnholdCount, {eventId: '$eventId' }) wireOnholdCount;
    @wire(getRegisteredCount, {eventId: '$eventId' }) wireRegisteredCount;
    @wire(getEventTitle, {eventId: '$eventId' }) wireEventTitle;

    totalprogress = 0;
    @track sortBy;
    @track sortDirection = 'asc';
    styleWidth;
    registrantinfo = [];

@wire(CurrentPageReference)
getStateParameters(currentPageReference) {
    if (currentPageReference) {
        this.recordId = currentPageReference.state.recordId;
    }
}


// JS Properties 
pageSizeOptions = [10, 25, 50, 75, 100]; //Page size options
totalRecords; /// = this.wireTotalCount; //Total no.of records
pageSize; //No.of records to be displayed per page
totalPages; //Total no.of pages
pageNumber = 1; //Page number    
@track recordsToDisplay = []; //Records to be displayed on the page
@track records = []; //All records available in the data table
@track isUpdating = false;

get bDisableFirst() {
    return this.pageNumber == 1;
}

get bDisableLast() {
    return this.pageNumber == this.totalPages;
}



connectedCallback() {
    loadStyle(this, modal);
    this.eventId = this.recordId;
    // fetch records from apex method 
    getRegistrationCheckInList({ eventId: this.eventId })
        .then((result) => {
            if (result != null) {
                this.wireRegistration.data = result.map(item => ({ ...item, rowIcon: item.EEM_Checked_In__c == true?'action:check':'action:update_status',
                rowTitle: item.EEM_Checked_In__c == true?'unCheck':'CheckIn',
                rowbrand: item.EEM_Checked_In__c == true?'success':'brand',
                EEM_Checked_In__c: item.EEM_Checked_In__c == true?'Yes':'No',
                EEM_Company_Name__c: item.EEM_Registrant__r.EEM_Company_Name__c,
            }));
                this.records = this.wireRegistration.data;
                this.totalRecords = result.length; // update total records count                 
                this.pageSize = this.pageSizeOptions[0]; //set pageSize with default value as first option
                this.paginationHelper('connectedCallback'); 
            }
        })
        .catch((error) => {
            console.log('error while fetch registrations--> ' + JSON.stringify(error));
        });
      
}



doSorting(event) {
    this.sortBy = event.detail.fieldName;
    this.sortDirection = event.detail.sortDirection;
    this.sortData(this.sortBy, this.sortDirection);
}

sortData(fieldname, direction) {
    let parseData = JSON.parse(JSON.stringify(this.recordsToDisplay));
    // Return the value stored in the field
    let keyValue = (a) => {
        return a[fieldname];
    };
    // cheking reverse direction
    let isReverse = direction === 'asc' ? 1: -1;
    // sorting data
    parseData.sort((x, y) => {
        x = keyValue(x) ? keyValue(x) : ''; // handling null values
        y = keyValue(y) ? keyValue(y) : '';
        // sorting values based on direction
        return isReverse * ((x > y) - (y > x));
    });
    this.recordsToDisplay = parseData;
} 

handleRecordsPerPage(event) {
    this.pageSize = event.target.value;
    this.paginationHelper('handleRecordsPerPage');
}

    handleKeyChange(event) {
        // Debouncing this method: Do not actually invoke the Apex call as long as this function is
        // being called within a delay of DELAY. This is to avoid a very large number of Apex method calls.
        window.clearTimeout(this.delayTimeout);
         this.keySearch = event.target.value;
        
        this.delayTimeout = setTimeout(() => {
            refreshApex(this.wireRegistration);
            findRegistrationCheckIn({searchKey: this.keySearch, eventId: this.eventId})
            .then((result)=>{
                this.wireRegistration.data = result.map(item => ({ ...item, rowIcon: item.EEM_Checked_In__c == true?'action:check':'action:update_status',
                rowTitle: item.EEM_Checked_In__c == true?'unCheck':'CheckIn',
                rowbrand: item.EEM_Checked_In__c == true?'success':'brand',
                EEM_Checked_In__c: item.EEM_Checked_In__c == true?'Yes':'No',
                EEM_Company_Name__c: item.EEM_Registrant__r.EEM_Company_Name__c,
            }));
        //this.records = result;
            this.records = this.wireRegistration.data;
            this.totalRecords = result.length; // update total records count                 
            this.pageSize = this.pageSize; //set pageSize with current value
            this.paginationHelper('handleKeyChange1');  
             this.error = undefined;   
             
            })
            .catch((error) => {
                this.error = error;
                this.wireRegistration = undefined;
            })
        }
        , DELAY);

    if(this.keySearch == null){
        refreshApex(this.wireRegistration);
      getRegistrationCheckInList( {eventId: this.eventId }) 
        .then((result)=>{
            this.wireRegistration.data = result.map(item => ({ ...item, rowIcon: item.EEM_Checked_In__c == true?'action:check':'action:update_status',
            rowTitle: item.EEM_Checked_In__c == true?'unCheck':'CheckIn',
            rowbrand: item.EEM_Checked_In__c == true?'success':'brand',
            EEM_Checked_In__c: item.EEM_Checked_In__c == true?'Yes':'No',
            EEM_Company_Name__c: item.EEM_Registrant__r.EEM_Company_Name__c,
        }));
            //this.records = result;
            this.records = this.wireRegistration.data;
            this.totalRecords = result.length; // update total records count                 
            this.pageSize = this.pageSizeOptions[0]; //set pageSize with default value as first option
            this.paginationHelper('handleKeyChange2');  
            this.error = undefined;   
           })
        }
       
    }
  
    handleRowAction(event){
        const dataRow = event.detail.row;
    
    let vcheckIn = dataRow.EEM_Checked_In__c;
    let accId = dataRow.Id;
    let status = dataRow.EEM_Status__c;
    if(status == 'Registered'){
    if(vcheckIn == 'No'){
        vcheckIn = true;
    }else{
        vcheckIn = false;
    }
    this.isUpdating = true;
    let fields = {
    Id:accId,
    EEM_Checked_In__c: vcheckIn
    }
    const recordInput = { fields };
    updateRecord(recordInput)
    .then(() =>{
        
        refreshApex(this.wireRegistration)
            .then(() => {
               this.records = this.wireRegistration.data.map(item => ({ ...item, rowIcon: item.EEM_Checked_In__c == true?'action:check':'action:update_status',
                rowTitle: item.EEM_Checked_In__c == true?'unCheck':'CheckIn',
                rowbrand: item.EEM_Checked_In__c == true?'success':'brand',
                EEM_Checked_In__c: item.EEM_Checked_In__c == true?'Yes':'No',
                EEM_Company_Name__c: item.EEM_Registrant__r.EEM_Company_Name__c,
            }));
                refreshApex(this.wireCheckInCount);
                 refreshApex(this.wireNotCheckedInCount);
                refreshApex(this.wireOnholdCount);
                refreshApex(this.wireRegisteredCount);
                this.paginationHelper('handleRowAction');
                this.isUpdating = false;
                this.sortData(this.sortBy, this.sortDirection);
            });
        })
        .catch((error) => {
            this.message = 'Error received: code' + error.errorCode + ', ' +
                'message ' + error.body.message;
        });
        
    
}else{
    this.dispatchEvent(
        new ShowToastEvent({
            title: 'Error!',
            message: 'This registration is not complete so it is not eligible for Check In.',
            variant: 'error'
        })
    );
    
    
}

 this.keySearch = '';
 refreshApex(this.wireRegistration);
  getRegistrationCheckInList( {eventId: this.eventId }) 
    .then((result)=>{
        this.wireRegistration.data = result.map(item => ({ ...item, rowIcon: item.EEM_Checked_In__c == true?'action:check':'action:update_status',
        rowTitle: item.EEM_Checked_In__c == true?'unCheck':'CheckIn',
        rowbrand: item.EEM_Checked_In__c == true?'success':'brand',
        EEM_Checked_In__c: item.EEM_Checked_In__c == true?'Yes':'No',
        EEM_Company_Name__c: item.EEM_Registrant__r.EEM_Company_Name__c,
    }));
        
        this.records = this.wireRegistration.data;
        this.totalRecords = result.length; // update total records count                 
        this.pageSize = this.pageSize; //set pageSize with current value
        this.paginationHelper('handleRowAction2'); 
        this.error = undefined;   
        
       })
       

} 


 

 get totalWidth(){
   this.totalprogress = Math.round((this.wireCheckInCount.data/this.wireTotalCount.data)*100);
   this.styleWidth = 'width:'+this.totalprogress+'%';
 return this.styleWidth;

 }


 handleSort(event){
 this.sortedField = event.detail.fieldName;
 this.sortedDirection = event.detail.sortDirection;
 this.sortType = this.columns.find(column => this.sortedField === column.fieldName).type;
 }

previousPage() {
    this.pageNumber = this.pageNumber - 1;
    this.paginationHelper('previousPage');
    
}

nextPage() {
    this.pageNumber = this.pageNumber + 1;
    this.paginationHelper('nextPage');
    
}

firstPage() {
    this.pageNumber = 1;
    this.paginationHelper('firstPage');
    
}

lastPage() {
    this.pageNumber = this.totalPages;
    this.paginationHelper('lastPage');
    
}




// JS function to handel pagination logic 
paginationHelper(vmethod) {

    this.recordsToDisplay = [];
    // calculate total pages
    this.totalPages = Math.ceil(this.totalRecords / this.pageSize);
 
    // set page number 
    if (this.pageNumber <= 1) {
        this.pageNumber = 1;
    } else if (this.pageNumber >= this.totalPages) {
        this.pageNumber = this.totalPages;
    }
    
    // set records to display on current page 
    for (let i = (this.pageNumber - 1) * this.pageSize; i < this.pageNumber * this.pageSize; i++) {
        if (i === this.totalRecords) {
           
            break;
        }
        this.recordsToDisplay.push(this.records[i]);
    }

  this.wireRegistration.data = this.recordsToDisplay;
  this.sortData(this.sortBy, this.sortDirection);
}

}