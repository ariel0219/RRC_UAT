import { LightningElement, wire, track } from 'lwc';
import getInspectionPackageList from '@salesforce/apex/IETRS_RRC_Portal_InspectionPackages.getInspectionPackageList';
const columns = [
 { label: 'Name', sortable: "true", fieldName: 'nameUrl', type: 'url', typeAttributes: { label: { fieldName: 'Name' } } },
 { label: 'Type', sortable: "true", fieldName: 'IETRS_Inspection_Type__c' },
 { label: 'Begin Date', sortable: "true", fieldName: 'IETRS_Begin_Date__c' },
 { label: 'End Date', sortable: "true", fieldName: 'IETRS_End_Date__c' },
 { label: 'Business Area', sortable: "true", fieldName: 'IETRS_Business_Area__c' },
 { label: 'Organization', fieldName: 'orgName', sortable: "true", type: 'text'}
];
export default class IETRS_RRC_Portal_InspectionPackages extends LightningElement {
 // Private Property
 @track error;
 @track columns = columns;
 @track data = [];
 @track sortedBy;
 @track sortedDirection = 'asc';
 @wire(getInspectionPackageList)
 wiredData({ error, data }) {
 if (error) {
 console.log(error.message);
 this.error = 'There was an error getting the data.';
 } else if (data) {
 let nameUrl;
 let orgName;
 this.data = (data || []).map((row) => {
 nameUrl = `/ietrs-inspection-package/${row.Id}`;
 orgName = row?.IETRS_Organization__r?.Name;
 return { ...row, nameUrl, orgName };
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