import {
    LightningElement,
    wire,
    track,
    api
} from 'lwc';
import pubsub from 'c/iETRS_PLI_PubSub';
import getNotifcationRecord from '@salesforce/apex/IETRS_PLI_LWCQuery.fetchNotificationDetailRecs';
import reportingperiodPicklist from '@salesforce/apex/IETRS_PLI_LWCQuery.getReportPeriodValues';
import accountRecords from '@salesforce/apex/IETRS_PLI_LWCQuery.getAccountRecords';
import { refreshApex } from '@salesforce/apex';
export default class searchQuery extends LightningElement {

    /*######################### VARIABLE DECLARATION ##################*/
    @track operatorName = null;
    @track reportingYear = null;
    @track ReportPeriod = 'Report Period';
    @track isgetp5Number = '';
    @track bShowModal = false;
    @track grade1;
    @track setNotificationRecord;
    @track isSearchDisableBtn = true;
    @track options = [];
    @track accountName;
    @track accountRecordId;
    @track psNumberstr;
    @track selectedRecordId; //store the record id of the selected 
    @track iscombinedStr = null;
    @track isopnameassign;
    @track regulatedEntityID;

    @track isselectCombinedStr;

    //THIS METHOD USED FOR "SEARCH BUTTON DISABLE" BASED ON THE "OPERATOR NAME"
    //*************** EVENT TYPE: CHANGE********************/
    onOperatorNamechangeMethod(event) {
        this.pnamevar = this.cnt;
        this.operatorName = event.detail.selectedValue;
        this.accountRecordId = event.detail.selectedRecordId;

        if (this.ReportPeriod != 'Report Period' && this.operatorName != null) {
            this.isSearchDisableBtn = false;
        } else
            this.isSearchDisableBtn = true;

        if (this.psNumberstr != null) {
            this.template.querySelector('[data-id="psId"]').removeRecordOnLookup();
            this.psNumberstr = null;
        }
    }

    //THIS METHOD USED FOR "SEARCH BUTTON DISABLE" BASED ON THE "P5 NUMBER"
    //*************** EVENT TYPE: CHANGE********************/
    onP5NumberchangeMethod(event) {
        this.psNumberstr = event.detail.selectedValue;
        this.iscombinedStr = event.detail.closevalue;
        if (this.ReportPeriod != 'Report Period' && this.psNumberstr != null) {
            this.isSearchDisableBtn = false;
        } else
            this.isSearchDisableBtn = true;

        if (this.operatorName != null) {
            this.template.querySelector('[data-id="accid"]').removeRecordOnLookup();
            this.operatorName = null;
        }
    }

    ondisablebuttonMethod(event) {
        console.log('ondisablebuttonMethod=>' + event.detail.selectedValue)
        if ((this.ReportPeriod != 'Report Period' && this.operatorName != null) ||
            (this.ReportPeriod != 'Report Period' && this.psNumberstr != null)) {
            this.isSearchDisableBtn = false;
        } else
            this.isSearchDisableBtn = true;
    }

    //THIS METHOD USED FOR "SEARCH BUTTON DISABLE" BASED ON THE "P5 NUMBER"
    //*************** EVENT TYPE: CHANGE********************/
    onReportPeriodChangeMethod(event) {
        var getValue = event.target.value;
        this.ReportPeriod = event.target.value;
        if ((getValue != 'Report Period' && this.operatorName != null && this.operatorName != '') ||
            (getValue != 'Report Period' && this.psNumberstr != null && this.psNumberstr != '')) {
            this.isSearchDisableBtn = false;
        } else
            this.isSearchDisableBtn = true;
    }

    //THIS METHOD USED FOR GET THE ALL VALUES OF "REPORT PERIOD" FROM NOTIFICATION OBJECT
    OnReportPeriodPickListValues() {
        reportingperiodPicklist({})
            .then(data => {
                this.options = data;
                var pickarray = new Array();
                for (var i = 0; i < this.options.length; i++) {
                    pickarray.push(this.options[i]);
                }
                this.options = pickarray.reverse();
            })
            .catch(error => {
                //this.displayError(error); // Commented by Ayesha on 1/6/2021
                console.error(error);
            });
    }

    //CONSTRUCTOR METHOD
    connectedCallback() {
        this.OnReportPeriodPickListValues();
    }

    validateLookupField() {
        this.template.querySelector('c-custom-lookup').isValid();
    }

    //FETCHING ACCOUNT RECORDS BASED ON THE "OPERATOR NAME" OR "P5 NUMBER"
    getaccountRecord() {
        accountRecords({
            operatorNamestr: this.operatorName,
            p5Numberstr: this.psNumberstr
        })
            .then(result => {
                this.resultsum = result;
                this.isopnameassign = result.Name;
                this.isgetp5Number = result.IETRS_P5_Number__c;
                this.accountRecordId = result.Id;
                this.regulatedEntityID = result.IETRS_Regulated_Entity_ID__c;
            })
            .catch(error => {
                //window.alert('fgfgfddd'+JSON.stringify(error));
            })
    }

    //SET BOOLEAN VALUE AND CALLING PARENT CMP OF AURA COMPONENT
    fireCustomEvent(blnValue) {
        const value = blnValue;
        const valueChangeEvent = new CustomEvent("valuechange", {
            detail: {
                value
            }
        });
        this.dispatchEvent(valueChangeEvent);
    }

    //WHENEVER NO RECORDS IN "NOTIFICATION OBJECT"
    noRecordsMethod() {
        this.fireCustomEvent(false);
        //window.alert('no recods found in a database..');
        this.resultsum = undefined;
        let notificationObj = {
            "operatorNameParent": this.isopnameassign,
            "reportingYearParent": this.reportingYear,
            "ReportPeriodParent": this.ReportPeriod,
            "companyIdParent": this.isgetp5Number,
            "accRecordID": this.accountRecordId,
            "getNotificationRecord": 'no rows',
            "noRegEntityId": this.regulatedEntityID
        }
        pubsub.fire('simplevt', notificationObj);
    }

    //THIS METHOD IS USED FOR "HANDLE SEARCH"
    handleSearch(event) {
        this.getaccountRecord();
        if (this.operatorName != null)
            this.psNumberstr = null;

        // window.alert('opertor name'+this.operatorName);
        // window.alert('psNumberstr'+this.psNumberstr);
        //window.alert('reportingPeriod'+this.ReportPeriod);
        console.warn(this.operatorName);
        console.warn(this.psNumberstr);
        console.warn(this.ReportPeriod);

        getNotifcationRecord({
            operatorName: this.operatorName,
            p5Number: this.psNumberstr,
            reportingPeriod: this.ReportPeriod
        })
            .then(result => {
                this.fireCustomEvent(true);
                this.setNotificationRecord = result;
                //window.alert(JSON.stringify(result));
                console.log('[Debug] var result/setNotificationRecord---> ' + JSON.stringify(result));
                if (result == null)
                    this.noRecordsMethod();
                else {
                    let message = {
                        "getNotificationRecord": this.setNotificationRecord
                    }
                    //refreshApex(this.setNotificationRecord);
                    pubsub.fire('simplevt', message);
                    
                }
            })
            .catch(error => {
                this.error = error;
                console.log('HIT ON SEARCH ERROR.....' + this.error);
            });
    }

    //Added by Ayesha for on removal of look ups on 11th DEC 2020
    onP5disablebuttonaction() {
        this.psNumberstr = null;
        console.log('operatorName=>' + this.operatorName + '<=psNumberstr=>' + this.psNumberstr);
        if ((this.operatorName == null || this.operatorName == undefined) &&
            (this.psNumberstr == null || this.psNumberstr == undefined)) {
            this.isSearchDisableBtn = true;
            this.psNumberstr = ''
            console.log('onP5disablebuttonaction=>' + this.psNumberstr);
        }
    }

    onOperatordisablebuttonaction() {
        this.operatorName = null;
        console.log('operatorName=>' + this.operatorName + '<=psNumberstr=>' + this.psNumberstr);
        if ((this.operatorName == null || this.operatorName == undefined) &&
            (this.psNumberstr == null || this.psNumberstr == undefined)) {
            this.isSearchDisableBtn = true;
            this.operatorName = '';
            console.log('onOperatordisablebuttonaction=>' + this.operatorName);
            const value = 'Yes';
            const valueChangeEvent = new CustomEvent("valuechange", {
                detail: {
                    value
                }
            });
            this.dispatchEvent(valueChangeEvent);
        }

    }
}