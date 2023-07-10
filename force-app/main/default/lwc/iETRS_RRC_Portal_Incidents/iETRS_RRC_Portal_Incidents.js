import { LightningElement, track  } from 'lwc';
import getIncidentsList from '@salesforce/apex/IETRS_RRC_Portal_Incidents.getIncidentsList';

const columns = [
    { label: 'Name', fieldName: 'nameUrl', sortable: "true", type: 'url', typeAttributes: { label: { fieldName: 'Name' } } },
    { label: 'Incident Date', sortable: "true", fieldName: 'IETRS_Incident_Date__c' }, 
    { label: 'Org ID', sortable: "true", fieldName: 'IETRS_Organization_ID__c' },
    { label: 'Org Name', fieldName: 'orgName', sortable: "true", type: 'text'},
    { label: 'Business Area', sortable: "true", fieldName: 'IETRS_Business_Area__c' },
    { label: 'Nearest City', sortable: "true", fieldName: 'IETRS_Nearest_City__c' },
    { label: 'County', sortable: "true", fieldName: 'IETRS_County_Name_For_Search__c' }
];

export default class IETRS_RRC_Portal_Complaints extends LightningElement {
    @track loader = false;
    @track error = null;
    @track columns = columns;
    @track data = [];
    @track sortingField;
    @track sortDirection = 'asc';
    @track setAccts = [];
    @track offSet = 0;
    @track pageSize = 50;
    @track totalRows = 0;
    @track pageNumber = 1;
    @track totalPages = 1;
    @track recordStart = 0;
    @track recordEnd = 0;

    connectedCallback() {
        this.getRecords();
    }

    getRecords(){
        this.loader=true;
        getIncidentsList({        
            pageNumber: this.pageNumber,
            pageSize: this.pageSize,
            sortingField: this.sortingField,
            sortDirection: this.sortDirection
        })
        .then(
            (data) => {
                this.loader = false;
                if(data){
                    var jsonData = JSON.parse(data);
                    let nameUrl;
                    let orgName;
                    this.data = (jsonData.incidents || []).map(
                        (row) => {
                            nameUrl = `/ietrs-incident/${row.Id}`;
                            orgName = row?.IETRS_Organization__r?.Name;
                            return { ...row, nameUrl, orgName };
                        }
                    );
                    this.pageNumber = jsonData.pageNumber;
                    this.totalRows = jsonData.totalRows;
                    this.recordStart = jsonData.recordStart;
                    this.recordEnd = jsonData.recordEnd;
                    this.totalPages = jsonData.totalPages;//Math.ceil(jsonData.totalRows / this.pageSize);
                    this.isNext = (this.pageNumber == this.totalPages || this.totalPages == 0);
                    this.isPrev = (this.pageNumber == 1 || this.totalRows < this.pageSize);
                }
            }
        )
        .catch((error) => {
            if(error) {
                console.log(error.message);
                this.loader = false;
                this.error = error;
                this.totalRows = undefined;
            }
        });
    }

    //Handle sorting
    sortColumns( event ) {
        this.sortingField = event.detail.fieldName;
        this.sortDirection = event.detail.sortDirection;
        this.offSet = 0;
        this.pageNumber=1;
        this.getRecords();
    }

    //Next button to get the next page of data
    nextPage() {
        this.pageNumber = this.pageNumber+1;
        this.getRecords();
    }

    //Previous button to get the previous page of data
    previousPage() {
        this.pageNumber = this.pageNumber-1;
        this.getRecords();
    }

    //First button to get the first page of data
    firstPage() {
        this.offSet = 0;
        this.pageNumber = 1;
        this.getRecords();
    }

    //Last button to get the last page of data
    lastPage() {
        this.offSet = (this.totalPages*this.pageSize);
        this.pageNumber = this.totalPages;
        this.getRecords();
    }

    //Handle being on the first page
    get isDisablePrev() {

        //return this.offSet == 0 || this.totalRows === 0 ? true : false;
        return this.pageNumber == 1 ? true : false;
    }

    //Handle being on the last page
    get isDisableNext() {
        return this.pageNumber == this.totalPages ? true : false;
    }
}