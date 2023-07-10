/* eslint-disable */
import { api, LightningElement, track, wire } from 'lwc';

import delSelectedCons from '@salesforce/apex/IETRS_PLI_LWCQuery.deleteContacts';

import pubsub from 'c/iETRS_PLI_PubSub';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
//For refresh
import notificationDetialsRecordsOnRefresh from '@salesforce/apex/IETRS_PLI_LWCQuery.fetchNotificationDetailReccordsForRefresh';
import removeDuplicatesRecord from '@salesforce/apex/IETRS_PLI_LWCQuery.removeDuplicatesRecord';
import featchNotificationinSeries from '@salesforce/apex/IETRS_PLI_LWCQuery.fetchNotificationDetailReccords';
import deleteNotificationDetail from '@salesforce/apex/IETRS_PLI_LWCQuery.deleteNotificationDetailRecordById';
import deleteNotificationDetailsRecordById from '@salesforce/apex/IETRS_PLI_LWCQuery.deleteNotificationDetailsRecordById';
import getbuttonAccess from '@salesforce/apex/IETRS_PLI_LWCQuery.getPS95AccessCheckForProfile';
import isCurrentUserPortalUser from '@salesforce/apex/IETRS_PLI_LWCQuery.isCurrentUserPortalUser';
import identifyPortalUserAcessOrganization from '@salesforce/apex/IETRS_PLI_LWCQuery.identifyPortalUserAcessOrganization';
import getOrgofRegEnt from '@salesforce/apex/IETRS_PLI_LWCQuery.getOrgofRegEnt';
import getOperLeakId from '@salesforce/apex/IETRS_PLI_EDI_FileHandler.getOperLeakId';

const actions = [
    { label: 'Show details', name: 'show_details' },
    { label: 'Delete', name: 'delete' }
];

const actions1 = [{ label: 'Show details', name: 'show_details' }];

const columns = [
    {
        label: 'Regulated Entity Name',
        fieldName: 'systemnameStr',
        type: 'text',
        sortable: true
    },
    {
        label: 'Regulated Entity Id',
        fieldName: 'RegulatedEntityId',
        type: 'text',
        sortable: true
    },
    {
        label: 'Leak Cause',
        fieldName: 'LeakCuase',
        type: 'text',
        sortable: true
    },
    {
        label: 'Repair Date',
        fieldName: 'dateStr',
        type: 'text',
        sortable: true
    },
    {
        label: 'Repair Method',
        fieldName: 'LeakRepairMethod',
        type: 'text',
        sortable: true
    },
    {
        label: 'Leak Location',
        fieldName: 'LeakLocation',
        type: 'text',
        sortable: true
    },
    { label: 'Pipe Size', fieldName: 'PipeSize', type: 'text', sortable: true },
    { label: 'Pipe Type', fieldName: 'pipeType', type: 'text', sortable: true },
    {
        label: 'Leak Classification',
        fieldName: 'LeakClassification',
        type: 'text',
        sortable: true
    },
    { type: 'action', typeAttributes: { rowActions: actions } }
];

const columns1 = [
    {
        label: 'Regulated Entity Name',
        fieldName: 'systemnameStr',
        type: 'text',
        sortable: true
    },
    {
        label: 'Regulated Entity Id',
        fieldName: 'RegulatedEntityId',
        type: 'text',
        sortable: true
    },
    {
        label: 'Leak Cause',
        fieldName: 'LeakCuase',
        type: 'text',
        sortable: true
    },
    {
        label: 'Repair Date',
        fieldName: 'dateStr',
        type: 'text',
        sortable: true
    },
    {
        label: 'Repair Method',
        fieldName: 'LeakRepairMethod',
        type: 'text',
        sortable: true
    },
    {
        label: 'Leak Location',
        fieldName: 'LeakLocation',
        type: 'text',
        sortable: true
    },
    { label: 'Pipe Size', fieldName: 'PipeSize', type: 'text', sortable: true },
    { label: 'Pipe Type', fieldName: 'pipeType', type: 'text', sortable: true },
    {
        label: 'Leak Classification',
        fieldName: 'LeakClassification',
        type: 'text',
        sortable: true
    },
    { type: 'action', typeAttributes: { rowActions: actions1 } }
];

export default class IETRS_PLI_Detail_Display extends LightningElement {
    getNotificationDetailsLst;
    @track bShowModal = false;
    @api notificationID;
    constNotificationID;
    OrgofRegEnt;
    @api recordId;
    @track columns = columns1;
    selectedRecords = [];
    shownew;
    @track preSelectedRows = [];
    @track recordsCount = 0;
    @track isTrue = false;
    my_ids = [];

    @api refreshdata = false;
    //PipeLine Id
    @api pipeLineId;
    //Country Id
    @api CountyID;
    getAccess = false;

    @track wiredNotificationDetails = [];
    @track value;
    @track error;
    //@track data;
    @track sortedDirection = 'asc';
    @api sortedBy = 'systemnameStr';
    @api searchRENKey = '';
    @api searchREIKey = '';
    @api searchCountyKey = '';

    @track page = 1;
    @track items = [];
    @track data = [];
    @track startingRecord = 1;
    @track endingRecord = 0;
    @track pageSize = 10;
    @track totalRecountCount = 0;
    @track totalPage = 1;
    @api accountRecordId;
    @track nfdrecId = '';
    @track loadingRecords = true;

    allRecIds = []; //debug use
    blnPortalUser = false;
    blnOrgAccess = false;
    arrErrorMessages = [];
    strErrorHeader = 'Invalid Value: ';
    validationFailed;
    dtPeriodStart;
    dtPeriodEnd;
    reZipCode = RegExp('^[0-9]{5}(-[0-9]{4})?$');
    arrOperatorLeakIds = [];

    //Conditional visibility and requiredness variables for html
    blnCoupling = false;
    blnPolyPipe = false;
    blnJoint = false;
    blnFitting = false;
    blnCauseOther = false;
    showForm = false;

    /*
     * @Function: wiredPortalUser
     * @Description: Checks if the user is a Portal user or not. Runs on the wire when the component is initialized.
     */
    @wire(isCurrentUserPortalUser)
    wiredPortalUser({ error, data }) {
        if (data) {
            this.blnPortalUser = data;
            console.log('wire success');
            console.log(data);
        } else if (error) {
            console.log('wire error');
            console.log(error);
        }
    }

    /*
     * @Function: connectedCallback
     * @Description: onInit function. Sets up the component.
     */
    connectedCallback() {
        this.registerEvent();
        this.getButtonAccess();
    }

    /*
     * @Function: registerEvent
     * @Description: Register the event listener and establish the callback function.
     */
    registerEvent() {
        pubsub.register('simplnotificationlstevt', this.handleEvent.bind(this));
        console.log('Detail Display Event Registered');
    }

    /*
     * @Function: handleEvent
     * @Description: Handle the pubsub event thrown by c/iETRS_PLI_Header_Display
     *               Get parent level values from the pubsub event message.
     *               Calculate the filing period and establish whether the user has permission to file a PS95 for the selected Organization.
     * @Param: messageFromEvt - Object that contains information about the parent Notification Record. Defined in c/iETRS_PLI_Header_Display
     */
    handleEvent(messageFromEvt) {
        console.log('Detail Display: Event Handled.');
        this.notificationID = messageFromEvt.notificationID;
        this.accountRecordId = messageFromEvt.accountRecordId;
        let year = messageFromEvt.reportPeriod.substring(0, 5);
        //Period logic built off of whether the end of the period is Jun or Dec, i.e. first or second half of year.
        let blnJunPeriodEnd = messageFromEvt.reportPeriod.slice(-3) == 'Jun';
        //Start of Period is either Jan 1st YYYY or July 1st YYYY
        this.dtPeriodStart = new Date(year, blnJunPeriodEnd ? 0 : 6);
        //End of Period is either Jun 30th YYYY or December 31st YYYY
        this.dtPeriodEnd = new Date(
            year,
            blnJunPeriodEnd ? 5 : 11,
            blnJunPeriodEnd ? 30 : 31
        );

        identifyPortalUserAcessOrganization({
            organizationId: this.accountRecordId
        })
            .then((result) => {
                console.log('identifyPortalUserAcessOrganization()');
                this.blnOrgAccess = result;
            })
            .catch((error) => {
                console.log(JSON.stringify(error));
            });

        this.refreshNotificationDetailsLst();
    }
    //clicking on previous button this method will be called
    previousHandler() {
        if (this.page > 1) {
            this.page = this.page - 1; //decrease page by 1
            this.displayRecordPerPage(this.page);
        }
    }

    handleLocatedOn(event) {
        switch (event.target.value) {
            case 'Compression Coupling':
                this.blnCoupling = true;
                this.blnFitting = false;
                this.blnJoint = false;
                break;
            case 'Joint':
                this.blnCoupling = false;
                this.blnFitting = false;
                this.blnJoint = true;
                break;
            case 'Fitting':
                this.blnCoupling = false;
                this.blnFitting = true;
                this.blnJoint = false;
                break;
            default:
                this.blnCoupling = false;
                this.blnFitting = false;
                this.blnJoint = false;
        }
    }
    //OnChange Handler for the Pipe Type Field.
    handlePipeType(event) {
        //List of Pipe Types that require additional information.
        if (
            [
                'High Density Polyethylene',
                'Medium Density Polyethylene',
                'Poly-Vinyl-Chloride',
                'ABS'
            ].includes(event.target.value)
        ) {
            this.blnPolyPipe = true;
        } else this.blnPolyPipe = false;
    }

    //OnChange Handler for the Leak Cause field
    handleLeakCause(event) {
        //If Leak Cause is Other then the Other Description is required
        this.blnCauseOther = event.target.value == 'Other' ? true : false;
    }

    //Pagination next arrow handler
    nextHandler() {
        //If this is not the last page
        if (this.page < this.totalPage && this.page !== this.totalPage) {
            //Increase the current page index
            this.page = this.page + 1;
            //If records exist
            if (this.data.length != 0) {
                //The last element of the data array contains the Notification Detail Record Id
                this.nfdrecId = this.data.pop(this.data.length).Id;
                this.displayRecordPerPage(this.page);
            } else {
                const currentRecord = this.data;
                featchNotificationinSeries({
                    notificationRecordId: this.notificationID,
                    notificationdtlLastIdfromTable: this.nfdrecId
                })
                    .then((result) => {
                        const currentData = result;
                        //Appends new data to the end of the table
                        const newData = currentRecord.concat(currentData);
                        this.data = newData;
                        this.displayRecordPerPage(this.page);
                    })
                    .catch((error) => {
                        console.log(error);
                    });
            }
        }
    }

    //this method displays records page by page
    displayRecordPerPage(page) {
        this.startingRecord = (page - 1) * this.pageSize;
        this.endingRecord = this.pageSize * page;

        this.endingRecord =
            this.endingRecord > this.totalRecountCount
                ? this.totalRecountCount
                : this.endingRecord;

        this.data = this.items.slice(this.startingRecord, this.endingRecord);

        this.startingRecord = this.startingRecord + 1;
    }

    sortColumns(event) {
        this.sortedBy = event.detail.fieldName;
        this.sortedDirection = event.detail.sortDirection;

        let primer;
        if (this.sortedBy === 'dateStr') {
            // convert the date string to an integer so it can be sorted correctly
            primer = (dateStr) => {
                let result = 0;
                if (dateStr) {
                    try {
                        result = +new Date(dateStr);
                    } catch {
                        result = 0;
                    }
                }
                return result;
            };
        }

        // sort the full list
        const clonedData = [...this.items];
        clonedData.sort(
            this.sortBy(
                this.sortedBy,
                this.sortedDirection === 'asc' ? 1 : -1,
                primer
            )
        );
        this.items = clonedData;
        // go back to page 1 on a new sort
        this.page = 1;
        this.displayRecordPerPage(this.page);

        // return this.refreshNotificationDetailsLst();
    }

    handleRENKeyChange(event) {
        this.searchRENKey = event.target.value;
    }

    handleREIKeyChange(event) {
        this.searchREIKey = event.target.value;
    }

    handleCountyKeyChange(event) {
        this.searchCountyKey = event.target.value;
    }

    handleSearch(event) {
        return this.refreshNotificationDetailsLst();
    }

    //stand by feature
    handleRemoveDuplicate(event) {
        console.log("[debug] exe remove duplicates");
        return this.removeDuplicatesAndRefreshNotificationDetailsLst();
    }

    @api objectApiName = 'IETRS_Insp_Notification_Detail__c';

    // delete records process function
    /*
     * @Function: handleDeleteSelected
     * @Description: Handler for the onClick event of the "Delete Selected" button.
     *               Deletes all selected records on the Lightning Datatable.
     */
    handleDeleteSelected() {
        if (this.selectedRecords.length == 0) {
            window.alert('Please select at least one record.');
        } else {
            //PORTAL USER
            if (this.blnPortalUser) {
                if (this.blnOrgAccess) {
                    deleteNotificationDetailsRecordById({
                        listofrecordIdsToDelet: this.selectedRecords
                    })
                        .then((result) => {
                            this.refreshNotificationDetailsLst();
                            this.throwCustomToast(
                                'success',
                                'deletes',
                                'Success!'
                            );
                            let message = {};
                            pubsub.fire('evtReloadRepaired', message);
                        })
                        .catch((error) => {
                            console.log('Error: ' + error);
                        });
                } else this.throwCustomToast('error', 'noAccess', 'Error!');
            }
            //INTERNAL USER
            else {
                deleteNotificationDetailsRecordById({
                    listofrecordIdsToDelet: this.selectedRecords
                })
                    .then((result) => {
                        this.refreshNotificationDetailsLst();
                        this.throwCustomToast('success', 'deletes', 'Success!');
                        let message = {};
                        pubsub.fire('evtReloadRepaired', message);
                    })
                    .catch((error) => {
                        console.log('Error: ' + error);
                    });
            }
        }
    }

     /*
     * @Function: handleDeleteAllRecord
     * @Description: [FOR DEBUG PURPOSE]
     *              After upload large files that contains thousands of records, delete all will purge out all 
     *              rows without struggling.
     */
    handleDeleteAll(){
        console.log("purge button clicked"); //DEBUG LINE
        console.log("this.items length: " + this.allRecIds.length); //DEBUG LINE

        window.console.log('selectedRecords ====> ' + this.allRecIds); //DEBUG LINE

        let tasks = this.sliceArrayIntoChuncks(this.allRecIds, 500);

        tasks.forEach((singleTask) =>{
            deleteNotificationDetailsRecordById({
                listofrecordIdsToDelet: singleTask
            })
                .then((result) => {
                    //this.refreshNotificationDetailsLst();
                    console.log("batch purging result: " + result);
                    this.throwCustomToast('success', 'deletes', 'Success!');
                    let message = {};
                    pubsub.fire('evtReloadRepaired', message);
                })
                .then(()=>{
                    setTimeout(()=> {console.log("batch purge time out 2s");},2000)
                })
                .catch((error) => {
                    console.log('Error: ' + error);
                });
        })

        
        
    }

    //this method for debug use only
    sliceArrayIntoChuncks(arr, chunkSize){
        const res = [];
        for (let i = 0; i < arr.length; i += chunkSize) {
            const chunk = arr.slice(i , i + chunkSize);
            res.push(chunk);
        }
        return res;
    }

    /*
     * @Function: handleNewButton
     * @Description: Handler for the onClick event of the "New" button on the Lightning Datatable
     *               Sets conditional visibility variables to show the Lightning Record Edit Form.
     *               Blocks Portal Users without access to the selected Organization and throws an error toast.
     */
    handleNewButton() {
        console.log('handleNewButton()');
        this.shownew = true;
        this.showForm = true;
        this.recordId = null;

        if (this.blnPortalUser) {
            if (this.blnOrgAccess) {
                this.bShowModal = true;
            } else this.throwCustomToast('error', 'noAccess', 'Error!');
        } else this.bShowModal = true;
        getOperLeakId({ strNotificationID: this.notificationID })
            .then((result) => {
                this.arrOperatorLeakIds = Array.from(result);
            })
            .catch((error) => {
                console.log(JSON.stringify(error));
            });
    }

    // Closing the modal
    closeModal() {
        this.bShowModal = false;
    }

    getSelectedRecords(event) {
        // getting selected rows
        const selectedRows = event.detail.selectedRows;
        this.recordsCount = event.detail.selectedRows.length;
        // this set elements the duplicates if any
        let conIds = new Set();
        // getting selected record id
        for (let i = 0; i < selectedRows.length; i++) {
            conIds.add(selectedRows[i].Id);
        }
        // coverting to array
        this.selectedRecords = Array.from(conIds);

        window.console.log('selectedRecords ====> ' + this.selectedRecords);
    }

    /*
     * @Function: handleRowAction
     * @Description: Handler for the onrowaction event from the Lightning Datatable.
     *               Routes row to correct function depending on whether it is delete or view.
     * @Param: event - Object containing the event details, including the specific row action that was clicked.
     */
    handleRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        switch (actionName) {
            case 'delete':
                this.deleteRow(row);
                break;
            case 'show_details':
                this.onviewRecord(row);
                setTimeout(() => {
                    getOrgofRegEnt({
                        regEntId: this.template.querySelector(
                            "[data-id='pipeSystemID']"
                        ).value
                    })
                        .then((result) => {
                            this.OrgofRegEnt = result;
                        })
                        .catch((error) => {
                            console.log(error);
                        });
                }, 6000);
                break;
            default:
        }
    }

    deleteRow(row) {
        if (this.blnPortalUser) {
            if (this.blnOrgAccess) {
                this.deleteNotificationDetailDelete(row.noDetailObj.Id);
            } else {
                this.throwCustomToast('error', 'noAccess', 'Error!');
            }
        }
        //Internal User
        else {
            this.deleteNotificationDetailDelete(row.noDetailObj.Id);
        }
    }

    onviewRecord(rowdata) {
        this.recordId = rowdata.Id;
        this.shownew = true;
        this.bShowModal = true;
        this.showForm = true;
        getOperLeakId({ strNotificationID: this.notificationID })
            .then((result) => {
                this.arrOperatorLeakIds = Array.from(result);
            })
            .catch((error) => {
                console.log(JSON.stringify(error));
            });
    }

    /*
     * @Function: closeErrorModal
     * @Description: Handle onClick Event for the Close buttons on the Validation Error Modal
     */
    closeErrorModal() {
        this.validationFailed = false;
    }

    /*
     * @Function: onSubmitHandler
     * @Description: Handle the onSubmit Event from the Lightning Record Edit Form.
     *               Override default submit behavior to assign the parent Notification ID to the record before submission.
     * @Param: event - The event passed from the html
     */
    onSubmitHandler(event) {
        event.preventDefault();
        let fields = event.detail.fields;
        fields.IETRS_Notification__c = this.notificationID;
        this.submitForm(fields);
    }

    /*
     * @Function: submitForm
     * @Description: Check User Access then Validate and Submit form.
     * @Param: fields - Object holding the fields and values from the Lighning Record Edit Form.
     */
    submitForm(fields) {
        //PORTAL USER
        if (this.blnPortalUser) {
            //Portal User with access to selected Org.
            if (this.blnOrgAccess) {
                //Check standard requiredness validity.
                if (!this.reportValidity())
                    this.throwCustomToast('error', 'errorReview', 'Error!');
                //If requiredness is satisfied, check custom validations.
                else {
                    //If detail validations pass, submit the form.
                    if (!this.validateFields())
                        this.template
                            .querySelector("[data-id='editForm']")
                            .submit(fields);
                }
            }
            //If user does not have access to the Org, throw a no access error.
            else this.throwCustomToast('error', 'noAccess', 'Error!');
        }
        //INTERNAL USER
        else {
            //Check standard requiredness validity.
            if (!this.reportValidity())
                this.throwCustomToast('error', 'errorReview', 'Error!');
            //If requiredness is satisfied, check custom validations.
            else {
                //If detail validations pass, submit the form.
                if (!this.validateFields()) {
                    this.template
                        .querySelector("[data-id='editForm']")
                        .submit(fields);
                }
            }
        }
    }

    /*
     * @Function: handleOnSuccess
     * @Description: Handle the onSuccess event from the Lightning Record Edit Form.
     *               Override the default behavior, throw a success toast, close the modal, and refresh the Lightning Datatable
     * @Param: event - Object containing the event data.
     */
    handleOnSuccess(event) {
        event.preventDefault();
        if (!this.validationFailed && this.bShowModal) {
            const evt = new ShowToastEvent({
                title: 'Record has been Updated sucessfully.',
                variant: 'success'
            });
            this.dispatchEvent(evt);
            this.bShowModal = false;
            //Refresh the data
            this.refreshNotificationDetailsLst();
            let message = {};
            pubsub.fire('evtReloadRepaired', message);
        }
    }

    /*
     * @Function: handleREChange
     * @Description: Handles the onChange event for the Regulated Entity Name field of the Lightning Record Edit Form.
     *               Invokes Apex Method IETRS_PLI_LWCQuery.getOrgofRegEnt to get the grandparent Organization ID of the Regulated Entity.
     * @Param: event - Object containing the Regulated Entity ID (Account ID).
     */
    handleREChange(event) {
        if (event.target.value) {
            getOrgofRegEnt({ regEntId: event.target.value })
                .then((result) => {
                    this.OrgofRegEnt = result;
                })
                .catch((error) => {
                    console.log(error);
                });
        } else this.OrgofRegEnt = '';
    }

    //Refresh the getNotificationDetailsLst
    @api refreshNotificationDetailsLst() {
        this.loadingRecords = true;
        console.log('refreshNotificationDetailLst()');
        notificationDetialsRecordsOnRefresh({
            RecordId: this.notificationID,
            searchRENKey: this.searchRENKey,
            searchREIKey: this.searchREIKey,
            searchCountyKey: this.searchCountyKey,
            sortBy: this.sortedBy,
            sortDirection: this.sortedDirection
        })
            .then((result) => {
                console.log('refreshNotfication Promise');
                this.loadingRecords = false;
                this.page = 1;
                this.items = result;
                //console.log("refresh result: " + JSON.stringify(result));//debug
                //console.log("result length: " + result.length); //debug
                //console.log("this.items length: " + this.items.length); //debug
                this.allRecIds = [];
                result.forEach(element => { 
                    this.allRecIds.push(element.Id);
                });
                this.totalRecountCount = result.length;
                if (this.totalRecountCount != 0) {
                    this.totalPage =
                        this.totalRecountCount != this.pageSize
                            ? Math.ceil(this.totalRecountCount / this.pageSize)
                            : this.totalPage;
                    this.data = this.items.slice(0, this.pageSize);
                    this.nfdrecId = this.items.pop(this.pageSize).Id;
                    console.log('last record ' + this.nfdrecId);
                    this.endingRecord = this.pageSize;
                    this.columns = columns;
                    this.error = undefined;
                } else {
                    this.data = [];
                }
            })
            .catch((error) => {
                this.error = error;
            });
    }

    //Remove Duplicate and Refresh 
    //stand by feature
    removeDuplicatesAndRefreshNotificationDetailsLst() {
        this.loadingRecords = true;
        console.log('refreshNotificationDetailLst()');
        removeDuplicatesRecord({
            RecordId: this.notificationID,
            searchRENKey: this.searchRENKey,
            searchREIKey: this.searchREIKey,
            searchCountyKey: this.searchCountyKey,
            sortBy: this.sortedBy,
            sortDirection: this.sortedDirection
        });
    }

    //Delete the Notification detail on Id
    deleteNotificationDetailDelete(recId) {
        deleteNotificationDetail({ recordId: recId })
            .then((result) => {
                this.refreshNotificationDetailsLst();
                let message = {};
                pubsub.fire('evtReloadRepaired', message);
                //refreshApex(this.wiredNotificationDetails);
            })
            .catch((error) => {
                this.error = error;
            });
    }

    getButtonAccess() {
        getbuttonAccess({})
            .then((result) => {
                //var res = !result;
                this.getAccess = result;
                if (this.getAccess) {
                    this.columns = columns;
                }
            })
            .catch((error) => {
                console.log(JSON.stringify(error));
                //this.error = error
            });
    }

    @api refreshApex() {
        refreshApex(this.data); //this.getNotificationDetailsLst);
    }

    validateFields() {
        let today = new Date();
        let objRepairedLeak = {};

        //Clear the Error Message array to start fresh for each validation.
        this.arrErrorMessages = [];
        if (this.OrgofRegEnt != this.accountRecordId) {
            this.arrErrorMessages.push(
                this.strErrorHeader +
                    "for field 'Regulated Entity Name.' Regulated Entity is not related to selected Organization."
            );
        }
        /***************************
         * ADDRESS LINE 1
         ****************************/
        objRepairedLeak.addrLine1 = this.template.querySelector(
            "[data-id='UnitStreetAd1ID']"
        ).value;
        if (!this.validateLength(objRepairedLeak.addrLine1.length, 3)) {
            this.arrErrorMessages.push(
                this.strErrorHeader +
                    objRepairedLeak.addrLine1 +
                    ' for field Street Address 1. Must be at least 3 characters.'
            );
        }

        /***************************
         * OPERATOR LEAK ID
         * Note: Come back to this one. Needs to be unique within the filing period.
         ****************************/
        objRepairedLeak.opLeakId = this.template.querySelector(
            "[data-id='OperatorLeakID']"
        ).value;
        if (
            this.arrOperatorLeakIds.some(
                (e) => e.IETRS_Operator_Leak_ID__c == objRepairedLeak.opLeakId
            )
        ) {
            this.arrErrorMessages.push(
                this.strErrorHeader +
                    objRepairedLeak.opLeakId +
                    ', for field Operator Leak ID. Operator Leak ID is not unique.'
            );
        }

        /***************************
         * DATE LEAK REPORTED
         ****************************/
        let strReportedDate = this.template.querySelector(
            "[data-id='DateLeakReportedID']"
        ).value;
        objRepairedLeak.dateLeakReported = new Date(
            strReportedDate.substring(0, 4),
            parseInt(strReportedDate.substring(5, 7), 10) - 1,
            strReportedDate.substring(8)
        );
        //Date Leak Reported cannot be greater than Today or the End of the Period, which ever is sooner.
        if (
            (today <= this.dtPeriodEnd &&
                objRepairedLeak.dateLeakReported >= today) ||
            (today > this.dtPeriodEnd &&
                objRepairedLeak.dateLeakReported >= this.dtPeriodEnd)
        ) {
            this.arrErrorMessages.push(
                this.strErrorHeader +
                    objRepairedLeak.dateLeakReported +
                    ' for field Date Leak Reported. Cannot be future dated or later than the end of the filing period.'
            );
        }
        /***************************
         * CITY
         ****************************/
        objRepairedLeak.city = this.template.querySelector(
            "[data-id='UnityCityID']"
        ).value;
        if (!this.validateLength(objRepairedLeak.city.length, 3)) {
            this.arrErrorMessages.push(
                this.strErrorHeader +
                    objRepairedLeak.city +
                    " for field 'City'. Must be at least 3 characters."
            );
        }
        /***************************
         * ZIP CODE
         ****************************/
        objRepairedLeak.zipCode = this.template.querySelector(
            "[data-id='UnitZipCodeID']"
        ).value;
        //Must match the Regex for either 5 or 9 digit Zip Codes
        if (
            objRepairedLeak.zipCode &&
            !objRepairedLeak.zipCode.match(this.reZipCode)
        ) {
            this.arrErrorMessages.push(
                this.strErrorHeader +
                    objRepairedLeak.zipCode +
                    " for field 'Zip Code'. Must be at least 5 digit zip."
            );
        }
        /***************************
         * REPAIR DATE
         ****************************/
        //Repair Date cannot be 1. Future Dated, 2. After the Period End Date, 3. Before the Period Start Date
        let strRepairDate = this.template.querySelector(
            "[data-id='RepairDateID']"
        ).value;
        objRepairedLeak.repairDate = new Date(
            strRepairDate.substring(0, 4),
            parseInt(strRepairDate.substring(5, 7), 10) - 1,
            strRepairDate.substring(8)
        );

        if (objRepairedLeak.repairDate > today) {
            this.arrErrorMessages.push(
                this.strErrorHeader +
                    objRepairedLeak.repairDate +
                    ' for field Date Leak Reported. Repair Date cannot be in the future.'
            );
        } else if (objRepairedLeak.repairDate > this.dtPeriodEnd) {
            this.arrErrorMessages.push(
                this.strErrorHeader +
                    objRepairedLeak.repairDate +
                    ' for field Date Leak Reported. Repair Date cannot be later than the end of the filing period: ' +
                    this.dtPeriodEnd +
                    '.'
            );
        } else if (objRepairedLeak.repairDate < this.dtPeriodStart) {
            this.arrErrorMessages.push(
                this.strErrorHeader +
                    objRepairedLeak.repairDate +
                    ' for field Date Leak Reported. Repair Date cannot be earlier than the beginning of the filing period: ' +
                    this.dtPeriodStart +
                    '.'
            );
        } else if (
            objRepairedLeak.repairDate < objRepairedLeak.dateLeakReported
        ) {
            this.arrErrorMessages.push(
                this.strErrorHeader +
                    objRepairedLeak.repairDate +
                    ' for field Date Leak Reported. Repair Date cannot be earlier than the Date Leak Reported: ' +
                    objRepairedLeak.dateLeakReported +
                    '.'
            );
        }

        this.validationFailed = this.arrErrorMessages.length > 0;
        return this.validationFailed;
    }

    validateLength(length = 0, minLength, maxLength) {
        //Min and Max Length provided, length must be between Min and Max
        if (
            minLength &&
            maxLength &&
            length >= minLength &&
            length <= maxLength
        )
            return true;
        //Min Length provided, Max Length omitted, length must be greater than or equal to Min Length
        if (minLength && !maxLength && length >= minLength) return true;
        //Min Length omitted, Max Length provided, length must be less than or equal to Max Length
        if (!minLength && maxLength && length <= maxLength) return true;
        //If no success conditions are met, return false
        return false;
    }

    throwCustomToast(variant, type, title) {
        let message = '';
        switch (type) {
            case 'noAccess':
                message =
                    'Your user does not belong to the Organization listed on the PS-95 record(s). Your user cannot create or delete the record.';
                break;
            case 'errorReview':
                message = 'Please review and correct errors on the form.';
                break;
            case 'deletes':
                message = 'Records deleted successfully';
                break;
        }
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: message,
                variant: variant
            })
        );
    }

    reportValidity() {
        return [
            ...this.template.querySelectorAll('lightning-input-field')
        ].reduce((validSoFar, field) => {
            // Return whether all fields up to this point are valid and whether current field is valid
            // reportValidity returns validity and also displays/clear message on element based on validity
            return validSoFar && field.reportValidity();
        }, true);
    }

    sortBy(field, reverse, primer) {
        const key = primer
            ? function (x) {
                  return primer(x[field]);
              }
            : function (x) {
                  return x[field];
              };

        return function (a, b) {
            a = key(a);
            b = key(b);
            return reverse * ((a > b) - (b > a));
        };
    }
}