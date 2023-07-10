import { LightningElement, track, api, wire } from 'lwc';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { createRecord } from 'lightning/uiRecordApi';
import IETRS_Commission_Action_Assignment__c from '@salesforce/schema/IETRS_Commission_Action_Assignment__c';
import COMACTID_FIELD from '@salesforce/schema/IETRS_Commission_Action_Assignment__c.IETRS_Commission_Action__c';
import CASEID_FIELD from '@salesforce/schema/IETRS_Commission_Action_Assignment__c.IETRS_Case__c';
import IETRS_Commission_Action__c from '@salesforce/schema/IETRS_Commission_Action__c';
import IETRS_Agenda_Section__c from '@salesforce/schema/IETRS_Commission_Action__c.IETRS_Agenda_Section__c';
import getCaseList from '@salesforce/apex/IETRS_CommActionCasesController.getCaseList';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import { CurrentPageReference } from 'lightning/navigation';
import { fireEvent } from 'c/pubsub';

export default class iETRS_CommActionAddCases extends LightningElement {
//record info and picklist vals   
    @api recordId;
    @track readyForConfValue = false;
    @track agendaSectionValue;
    @track confDateValue;

    @wire(CurrentPageReference) pageRef;

    @wire(getObjectInfo, { objectApiName: IETRS_Commission_Action__c })
    objectInfo;

    @wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: IETRS_Agenda_Section__c})
    AgendaSectionPicklistValues;
    
    
    
    handleChange(event) {
         this.agendaSectionValue = event.detail.value;       
    }

//modal base functionality
    @track openmodel = false;
    @track areResultsVisible = false;

    openmodal() {
        this.openmodel = true
    }
    closeModal() {
        this.openmodel = false;
        this.areResultsVisible = false;
    } 
    showResults() {
        this.areResultsVisible = true
    }
    handleChange1(event) {
        this.readyForConfValue = event.target.checked;
    }
    handleChange3(event) {
        this.confDateValue = event.target.value;
    }

//apex load applicable cases
    @track cases;

    // call apex method on button click 
    handleSearch() {
            //addt'l change modal screen
            this.showResults();
            if( this.agendaSectionValue != null | this.confDateValue != null  |  this.readyForConfValue != null ) {
            getCaseList({
                    searchKey1: this.readyForConfValue,
                    searchKey2: this.agendaSectionValue,
                    searchKey3: this.confDateValue,
                    strCommissionActionId: this.recordId
                })
                .then(result => {
                    // set @track cases variable with return case list from server  
                    this.cases = result;
                })
                .catch(error => {
                    // display server exception in toast msg 
                    const event = new ShowToastEvent({
                        title: 'Error',
                        variant: 'error',
                        message: error.body.message,
                    });
                    this.dispatchEvent(event);
                    // reset cases var with null   
                    this.cases = null;
                });
            } else {
                // fire toast event if input field is blank
                 const event = new ShowToastEvent({
                     variant: 'error',
                     message: 'No Results Found',
                 });
                 this.dispatchEvent(event);
            }
    }

    selectAllCheckboxes(event){
        let x, i;
        x = this.template.querySelectorAll('.recCheckboxes'); 
        
        if(event.target.checked){
            for (i = 0; i < x.length; i++) {
                x[i].checked = true;
            }
        } else {
            for (i = 0; i < x.length; i++) {
                x[i].checked = false;
            }
        } 
    }

    createRecordsAction() {
        var z, z2, z3, j;
        var checkedList = [];
        z = this.template.querySelectorAll('.recCheckboxes');

        for(j=0; z[j]; ++j){
            if(z[j].checked){
                z2 = z[j].value;
                checkedList.push(z2);           
            }
        }
//todo: refactor
        for(z3=0; checkedList[z3]; ++z3){
            const fields = {};
            fields[COMACTID_FIELD.fieldApiName] = this.recordId;
            fields[CASEID_FIELD.fieldApiName] = checkedList[z3];

            const recordInput = { apiName: IETRS_Commission_Action_Assignment__c.objectApiName, fields };

            createRecord(recordInput)
            .then(caRecord => { 
                //for each in selectedCaseList 
                this.IETRS_Commission_Action__c = caRecord.IETRS_Commission_Action__c;
                this.IETRS_Case__c = caRecord.IETRS_Case__c;

                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Commission Action(s) Created',
                        variant: 'success',
                    }),
                );
                
                this.closeModal();
                this.forceRefreshView();
            })
        
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error creating record',
                        message: error.body.message,
                        variant: 'error',
                    }),
                );
            });
        }
    }
    forceRefreshView() {
        console.log("Fire Refresh Event");
        fireEvent(this.pageRef, 'refreshfromlwc', this.name);
    }
}