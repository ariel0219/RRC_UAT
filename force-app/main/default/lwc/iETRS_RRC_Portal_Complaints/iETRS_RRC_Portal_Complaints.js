import { LightningElement, track } from 'lwc';
import getComplaintsList from '@salesforce/apex/IETRS_RRC_Portal_Complaints.getComplaintsList';

const columns = [
    { label: 'Name', fieldName: 'nameUrl', sortable: "true", type: 'url', typeAttributes: { label: { fieldName: 'Name' } } },
    { label: 'Date Received', sortable: "true", fieldName: 'ITRES_Complaint_Received__c' }, 
    { label: 'Resolution Status', sortable: "true", fieldName: 'IETRS_Complaint_Resolution_Status__c' },
    { label: 'Organization', fieldName: 'orgName', sortable: "true", type: 'text'},
    { label: 'Regulated Entity', sortable: "true", fieldName: 'IETRS_I_Regulated_Entity_Name_for_Search__c' },
    { label: 'City', sortable: "true", fieldName: 'IETRS_City__c' },
    { label: 'Business Area', sortable: "true", fieldName: 'IETRS_Business_Area__c' }
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
        getComplaintsList({        
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
                    this.data = (jsonData.complaints || []).map(
                        (row) => {
                            nameUrl = `/ietrs-complaint/${row.Id}`;
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