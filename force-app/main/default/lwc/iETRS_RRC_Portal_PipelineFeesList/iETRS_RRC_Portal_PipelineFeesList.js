import { LightningElement, wire, track } from 'lwc';
import getPipelineFeesList from '@salesforce/apex/IETRS_RRC_Portal_PipelineFees.getPipelineFeesList';

const columns = [
    { label: 'Name', fieldName: 'nameUrl', sortable: "true", type: 'url', typeAttributes: { label: { fieldName: 'Name' } } },
    { label: 'Fee Date', sortable: "true", fieldName: 'IETRS_Fee_Date__c' },
    { label: 'Fee Type', sortable: "true", fieldName: 'IETRS_Fee_Type__c' },
    { label: 'Fee Amount Due', sortable: "true", fieldName: 'IETRS_Total_Regulated_Fee_Amount_Due__c' },
    { label: 'Fee Status', sortable: "true", fieldName: 'IETRS_Status__c'}
];

export default class IETRS_RRC_Portal_PipelineFees extends LightningElement {
 // Private Property
 @track error;
 @track columns = columns;
 @track data = [];
 @track sortedBy;
 @track sortedDirection = 'asc';
 @wire(getPipelineFeesList)
 wiredData({ error, data }) {
 if (error) {
 console.log(error.message);
 this.error = 'There was an error getting the data.';
 } else if (data) {
 let nameUrl;
 this.data = (data || []).map((row) => {
 nameUrl = `/ietrs-insp-regulated-fee/${row.Id}`;
 return { ...row, nameUrl };
 });
 }
 }
 handleSortdata(event) {
    // field name
    this.sortBy = event.detail.fieldName;

    // sort direction
    this.sortDirection = event.detail.sortDirection;

    // calling sortdata function to sort the data based on direction and selected field
    this.sortData(event.detail.fieldName, event.detail.sortDirection);
}

sortData(fieldname, direction) {
    // serialize the data before calling sort function
    let parseData = JSON.parse(JSON.stringify(this.data));

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

    // set the sorted data to data table data
    this.data = parseData;

}

}