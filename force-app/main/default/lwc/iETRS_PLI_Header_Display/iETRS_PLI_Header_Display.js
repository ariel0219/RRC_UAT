import { LightningElement, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import pubsub from 'c/iETRS_PLI_PubSub';
import notificationDetialsRecords from '@salesforce/apex/IETRS_PLI_LWCQuery.fetchNotificationDetailReccords';
import updatenotificationRecords from '@salesforce/apex/IETRS_PLI_LWCQuery.updateNotificationRecord';
import updatenotificationTonullRecords from '@salesforce/apex/IETRS_PLI_LWCQuery.updatenotificationTonullRecords';
import createNotificationRecordinClass from '@salesforce/apex/IETRS_PLI_LWCQuery.insertNewNotificationObject';
import getbuttonAccess from '@salesforce/apex/IETRS_PLI_LWCQuery.getPS95AccessCheckForProfile';
import isCurrentUserPortalUser from '@salesforce/apex/IETRS_PLI_LWCQuery.isCurrentUserPortalUser';
import identifyPortalUserAcessOrganization from '@salesforce/apex/IETRS_PLI_LWCQuery.identifyPortalUserAcessOrganization';
import getRepairedLeakCount from '@salesforce/apex/IETRS_PLI_LWCQuery.getRepairedLeakCount';
import getUploadedPS95Documents from '@salesforce/apex/IETRS_PLI_LWCQuery.getUploadedPS95Documents';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class headerDisplay extends NavigationMixin(LightningElement) {
    //$$$$$$$$$$$$$$$$$$$$$ DECLARATION VARIABLES $$$$$$$$$$$$$$$$$$$$$$$$$$$
    @track isHeaderDisplayTextShow;
    @track isHeaderDisplayRecordsFound;
    @track operatorName;
    @track companyId;
    @track filingPeriod;
    @track grade1 = 0;
    @track grade2 = 0;
    @track grade3 = 0;
    @track totalRepaired = 0;
    @track NofificationID = '';
    @track isNoRecords = false;
    @track RecordId = '';
    @track options = [];
    @track setbutton;
    @track accountRecordId;
    @track getNotfiRecord;
    @track readOnly = false;
    @track getAccess = false;
    disableSave = false;
    @track showConfirmScreeen = false;
    @track ReportPeriod = '';
    @track uploadedFiles;
    @track submittedDate;
    isPortalUser;

    get hasFiles() {
        return (this.uploadedFiles || []).length > 0;
    }

    //CONSTRUCTOR (WHEN THE LOAD COMPONENT THEN GROUP OF LINES BETWEEN THIS METHOD WII BE EXCUTED)
    connectedCallback() {
        //debug starts:
        console.log("totalRepaired: --> " + this.totalRepaired);
        //debug ends.
        this.isHeaderDisplayTextShow = false;
        this.isHeaderDisplayRecordsFound = false;
        this.setbutton = 'Submit';
        this.regiser();
        this.registerDetailListener();
        this.getButtonAcces();
        isCurrentUserPortalUser().then((result) => {
            this.isPortalUser = result;
        });
    }

    getButtonAcces() {
        getbuttonAccess({})
            .then((result) => {
                //var res=!result;
                this.getAccess = result;
            })
            .catch((error) => {
                console.log(JSON.stringify(error));
                //this.error = error
            });
    }
    validateLookupField() {
        this.template.querySelector('c-custom-lookup').isValid();
    }
    grade1TotalHandle(event) {
        this.grade1 = event.target.value;
    }
    grade2TotalHandle(event) {
        this.grade2 = event.target.value;
    }
    grade3TotalHandle(event) {
        this.grade3 = event.target.value;
    }

    regiser() {
        pubsub.register('simplevt', this.handleEvent.bind(this));
    }

    registerDetailListener() {
        pubsub.register('evtReloadRepaired', this.handleReloadEvt.bind(this));
    }

    handleReloadEvt() {
        getRepairedLeakCount({ strNotificationID: this.NofificationID })
            .then((result) => {
                this.totalRepaired = result;
            })
            .catch((error) => {
                console.log(error);
            });
    }

    //WHENEVER THE HIT ON SERACH BUTTON (SEARCH QUERY), THEN FIRE THIS METHOD USING "PUBSUB" LIBRARY
    handleEvent(messageFromEvt) {
        this.getNotfiRecord = JSON.stringify(messageFromEvt);
        var LWCQueryObj = JSON.parse(this.getNotfiRecord);
        console.log('Header Event Handler');
        console.log(LWCQueryObj);

        if (LWCQueryObj.getNotificationRecord == 'no rows') {
            this.isHeaderDisplayTextShow = false; //changed to false
            this.isHeaderDisplayRecordsFound = true; //changed according to the requirement share by kumail
            this.isNoRecords = true;
            // THIS LINES USED FOR "SUBMIT" ENABLE OR DSIABLE
            this.template
                .querySelector('.submitCls')
                .classList.remove('slds-hidden'); //add to add
            this.template
                .querySelector('.submitCls')
                .classList.add('slds-visible'); //remove to add
            this.operatorName = LWCQueryObj.operatorNameParent;
            this.ReportPeriod = LWCQueryObj.ReportPeriodParent;
            this.companyId = LWCQueryObj.companyIdParent;
            this.accountRecordId = LWCQueryObj.accRecordID;
            this.grade1 = 0;
            this.grade2 = 0;
            this.grade3 = 0;
            this.totalRepaired = 0;
            //window.alert(LWCQueryObj.accRecordID);
            console.log(LWCQueryObj.accRecordID);
            console.log('LWCQueryObj', JSON.stringify(LWCQueryObj));
            console.log(this.NofificationID);
            this.NofificationID = null;
            this.uploadedFiles = null;
            this.submittedDate = null;
        } else {
            this.isHeaderDisplayTextShow = false;
            this.isHeaderDisplayRecordsFound = true;
            this.isNoRecords = false;
            this.template
                .querySelector('.submitCls')
                .classList.remove('slds-hidden');
            this.template
                .querySelector('.submitCls')
                .classList.add('slds-visible');
            this.operatorName =
                LWCQueryObj.getNotificationRecord.IETRS_PS95_Organization__r.Name;
            this.ReportPeriod =
                LWCQueryObj.getNotificationRecord.IETRS_Report_Period__c;
            this.companyId =
                LWCQueryObj.getNotificationRecord.IETRS_P5_Number_Formula__c;
            this.grade1 =
                LWCQueryObj.getNotificationRecord.IETRS_Total_Grade_1_Unrepaired__c;
            this.grade2 =
                LWCQueryObj.getNotificationRecord.IETRS_Total_Grade_2_Unrepaired__c;
            this.grade3 =
                LWCQueryObj.getNotificationRecord.IETRS_Total_Grade_3_Unrepaired__c;
            this.totalRepaired =
                LWCQueryObj.getNotificationRecord.IETRS_Repaired_Leak_Count__c;
            this.NofificationID = LWCQueryObj.getNotificationRecord.Id;
            this.accountRecordId =
                LWCQueryObj.getNotificationRecord.IETRS_PS95_Organization__c;
            this.submittedDate = LWCQueryObj.getNotificationRecord
                .IETRS_Submitted_Date__c
                ? new Date(
                      LWCQueryObj.getNotificationRecord.IETRS_Submitted_Date__c
                  )
                : null;
            notificationDetialsRecords({
                RecordId: this.NofificationID
            })
                .then((result) => {
                    this.resultsum = result;
                    let message = {
                        JsonData: JSON.stringify(this.resultsum),
                        notificationID: this.NofificationID,
                        accountRecordId: this.accountRecordId,
                        reportPeriod: this.ReportPeriod
                    };
                    pubsub.fire('simplnotificationlstevt', message);
                })
                .catch((error) => {
                    //window.alert(JSON.stringify(error));
                    console.error(JSON.stringify(error));
                    //this.error = error
                });

            // retrieve uploaded ps-95 docs
            getUploadedPS95Documents({ notificationId: this.NofificationID })
                .then((result) => {
                    this.uploadedFiles = result;
                })
                .catch((err) => {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error',
                            message: `There was a problem retrieving the uploaded PS-95 Documents: ${
                                err?.message || 'Unknown error'
                            }`,
                            variant: 'error'
                        })
                    );
                });
        }

        const value = this.NofificationID;
        const valueChangeEvent = new CustomEvent('valuechange', {
            detail: {
                value
            }
        });
        // Fire the custom event
        this.dispatchEvent(valueChangeEvent);
        //this.fireCustomEvent(this.NofificationID);
    }

    // NO LEAKS TO REPORT
    noReportsTOLead() {
        this.template
            .querySelector('.submitCls')
            .classList.remove('slds-hidden');
        this.template.querySelector('.submitCls').classList.add('slds-visible');
        this.template.querySelector('.changebutton').label = 'Save';
        this.isHeaderDisplayRecordsFound = true;
        this.isHeaderDisplayTextShow = false;
        var isportalUser = false;
        isCurrentUserPortalUser({})
            .then((result) => {
                isportalUser = result;
                if (isportalUser) {
                    identifyPortalUserAcessOrganization({
                        organizationId: this.accountRecordId
                    })
                        .then((result) => {
                            console.log('Inside showConfirmScreen 1');
                            if (result) {
                                /* this.createNotificationRecord();*/ this.showConfirmScreeen = true;
                            } else {
                                this.dispatchEvent(
                                    new ShowToastEvent({
                                        title: 'Error!!',
                                        message:
                                            ' Your user does not belong to the Organization listed on the PS-95 record(s). Your user cannot create or delete the record.',
                                        variant: 'error'
                                    })
                                );
                                this.disableSave = false;
                            }
                        })
                        .catch((error) => {
                            console.log(JSON.stringify(error));
                        });
                } else {
                    /* this.createNotificationRecord();*/
                    this.showConfirmScreeen = true;
                }
            })
            .catch((error) => {
                console.log(JSON.stringify(error));
            });

        //this.onNullOutNofication();
        console.log('reached');
    }

    handleYes() {
        this.onNullOutNofication();
        this.showConfirmScreeen = false;
    }

    handleNo() {
        this.showConfirmScreeen = false;
    }

    //CREATE NEW NOFICATION RECORD
    onNewRecord() {
        this.template
            .querySelector('.submitCls')
            .classList.remove('slds-hidden');
        this.template.querySelector('.submitCls').classList.add('slds-visible');
        this.template.querySelector('.changebutton').label = 'Save';
        this.isHeaderDisplayRecordsFound = true;
        this.isHeaderDisplayTextShow = false;
    }

    //CREATED NEW NOFICATION RECORD
    createNotificationRecord() {
        let nofificationObj = {
            sobjectType: 'IETRS_Insp_Notification__c'
        };
        nofificationObj.IETRS_Total_Grade_1_Unrepaired__c = this.grade1;
        nofificationObj.IETRS_Total_Grade_2_Unrepaired__c = this.grade2;
        nofificationObj.IETRS_Total_Grade_3_Unrepaired__c = this.grade3;
        //window.alert(this.accountRecordId)
        console.log('AccountId' + this.accountRecordId);
        nofificationObj.IETRS_PS95_Organization__c = this.accountRecordId;
        nofificationObj.IETRS_Report_Period__c = this.ReportPeriod;

        createNotificationRecordinClass({
            newnotificationObj: nofificationObj
        })
            .then((result) => {
                //window.alert('Insert has been successfully..');
                console.log(
                    'Insert has been successfully..' + JSON.stringify(result)
                );
                this.NofificationID = result.Id;
                this.isNoRecords = false;
                this.disableSave = false;
                this.fireCustomEvent(result.Id);
            })
            .catch((error) => {
                //window.alert(JSON.stringify(error));
                console.error(JSON.stringify(error));
            });
    }

    //UPDATE NOFICATION RECORD
    onUpdateNofication() {
        updatenotificationRecords({
            notificationRecordID: this.NofificationID,
            grade1: this.grade1,
            grade2: this.grade2,
            grade3: this.grade3
        })
            .then((result) => {
                //window.alert('Record updated successfully.');
                console.log('Record updated successfully.');
                this.disableSave = false;
                //refreshApex(this.resultsum);
                this.fireCustomEvent(this.NofificationID);
            })
            .catch((error) => {
                //window.alert(JSON.stringify(error));
                console.error(JSON.stringify(error));
            });
    }

    onNullOutNofication() {
        console.log('reached1');
        updatenotificationTonullRecords({
            notificationRecordID: this.NofificationID,
            grade1: 0,
            grade2: 0,
            grade3: 0
        })
            .then((result) => {
                console.log('reached1');
                if (result !== null) {
                    var nofificationObjins = result;
                    this.grade1 =
                        nofificationObjins.IETRS_Total_Grade_1_Unrepaired__c;
                    this.grade2 =
                        nofificationObjins.IETRS_Total_Grade_2_Unrepaired__c;
                    this.grade3 =
                        nofificationObjins.IETRS_Total_Grade_3_Unrepaired__c;
                    this.disableSave = false;
                    console.log('reached3 not null');
                    //window.alert('Record updated successfully.');
                    console.log('Record updated successfully.');
                }
                this.refreshData();
                this.fireCustomEvent(this.NofificationID);
            })
            .catch((error) => {
                //window.alert(JSON.stringify(error));
                console.error(JSON.stringify(error));
            });
    }

    handleSubmit(event) {
        this.disableSave = true;
        var isportalUser = false;
        if (this.isNoRecords) {
            console.log('No records found' + this.isNoRecords);
            isCurrentUserPortalUser({})
                .then((result) => {
                    isportalUser = result;
                    if (isportalUser) {
                        identifyPortalUserAcessOrganization({
                            organizationId: this.accountRecordId
                        })
                            .then((result) => {
                                console.log('Inside create 1');
                                if (result) {
                                    this.createNotificationRecord();
                                } else {
                                    this.dispatchEvent(
                                        new ShowToastEvent({
                                            title: 'Error!!',
                                            message:
                                                ' Your user does not belong to the Organization listed on the PS-95 record(s). Your user cannot create or delete the record.',
                                            variant: 'error'
                                        })
                                    );
                                    this.disableSave = false;
                                }
                            })
                            .catch((error) => {
                                console.log(JSON.stringify(error));
                            });
                    } else {
                        this.createNotificationRecord();
                    }
                })
                .catch((error) => {
                    console.log(JSON.stringify(error));
                });
        } else {
            isCurrentUserPortalUser({})
                .then((result) => {
                    isportalUser = result;
                    if (isportalUser) {
                        console.log('Account Id' + this.accountRecordId);
                        identifyPortalUserAcessOrganization({
                            organizationId: this.accountRecordId
                        })
                            .then((result) => {
                                console.log('Inside 1' + result);
                                if (result) {
                                    this.onUpdateNofication();
                                } else {
                                    this.dispatchEvent(
                                        new ShowToastEvent({
                                            title: 'Error!!',
                                            message:
                                                ' Your user does not belong to the Organization listed on the PS-95 record(s). Your user cannot create or delete the record.',
                                            variant: 'error'
                                        })
                                    );
                                    this.disableSave = false;
                                }
                            })
                            .catch((error) => {
                                console.log(JSON.stringify(error));
                            });
                    } else {
                        this.onUpdateNofication();
                    }
                })
                .catch((error) => {
                    console.log(JSON.stringify(error));
                });
        }

        /*window.console.log('Event Firing....==' + this.operatorName);
        window.console.log('Event Firing..... ');
        const value = 'true';
        const valueChangeEvent = new CustomEvent("valuechange", {
            detail: {
                value
            }
        });
        // Fire the custom event
        this.dispatchEvent(valueChangeEvent);
        let message = {
            "operatorNameHeader": this.operatorName,
            "reportingYearHeader": this.reportingYear,
            "filingPeriodHeader": this.filingPeriod,
            "companyIdHeader": this.companyId
        }
        pubsub.fire('simplevt', message);
        window.console.log('Event Fired ');*/
    }

    fireCustomEvent(notificationInstanceId) {
        const value = notificationInstanceId;
        const valueChangeEvent = new CustomEvent('valuechange', {
            detail: {
                value
            }
        });
        // Fire the custom event
        this.dispatchEvent(valueChangeEvent);
    }

    refreshData() {
        notificationDetialsRecords({
            RecordId: this.NofificationID
        })
            .then((result) => {
                this.resultsum = result;
                let message = {
                    JsonData: JSON.stringify(this.resultsum),
                    notificationID: this.NofificationID
                };
                pubsub.fire('simplnotificationlstevt', message);
            })
            .catch((error) => {
                //window.alert(JSON.stringify(error));
                console.error(JSON.stringify(error));
                //this.error = error
            });
    }

    closeModal() {
        this.showConfirmScreeen = false;
    }

    handleFileClick(evt) {
        evt.preventDefault();
        let recordId = evt.target.getAttribute('data-file-id');
        if (this.isPortalUser) {
            recordId = evt.target.getAttribute('data-inspection-doc-id');
        }
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId,
                actionName: 'view'
            }
        });
    }
}