import { LightningElement, track, api, wire} from 'lwc';
import getRelatedFCs from '@salesforce/apex/IETRS_Assign_Case_to_Hearings_Controller.getRelatedFCs';
import assignToHearingOrLE from '@salesforce/apex/IETRS_Assign_Case_to_Hearings_Controller.assignToHearingOrLE';
import { CurrentPageReference } from 'lightning/navigation';
import { fireEvent } from 'c/pubsub';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';


export default class IETRS_Assign_Case_to_Hearings extends LightningElement {

    @api recordId;
    @wire(CurrentPageReference) pageRef;
    
    //Tracked variable that holds the FC records
    @track files;
    //Tracked variable that controls whether the modal window is visible or not
    @track modalVisible = false;
    //Tracked variable that disables the Share button to prevent double clicking
    @track blnShareDisabled = false;
    //Tracked variable that disables the Assign to Hearings button on completion
    @track blnComplete = false;
    //Tracked variable that collects all unchecked (previously checked) boxes on the screen to un-share them with Hearings
    @track unshareFCs = [];

    //Handler to open the modal window and return the list of Files and Correspondence records with imperative apex
    openmodal() {
        this.modalVisible = true;

        //Imperative Apex call to return FC list
        getRelatedFCs({
            caseId: this.recordId
        })
        .then(result => {
            this.files = result;
        })
        .catch(error => {
            const event = new ShowToastEvent({
                title: 'Error',
                variant: 'error',
                message: error.body.message,
            });
            this.dispatchEvent(event);
            // reset cases var with null   
            this.files = null;
        })
    }


    //Handler that disables the visibility of the modal
    closeModal() {
        this.modalVisible = false;
    }

    //Handler that collects previously checked FC Ids to perform an update to un-share them
    checkHandler(event){
        if(!event.target.checked){
            this.unshareFCs.push(event.target.value);
        }
    }

    //Handler that enables or disables all checkboxes when the Select All checkbox is checked
    selectAllCheckboxes(event){
        let x, i, bln;
        x = this.template.querySelectorAll('.recCheckboxes');
        bln = event.target.checked ? true : false;
        
        for (i = 0; x[i]; i++) {
            x[i].checked = bln;
        }        
    }

    //Handler for the Share with Hearings button
    //Calls the assignToHearings apex method that handles server side updates
    assignToHearingsHandler(){
        var allCheckboxes, i, checkedList = [];

        this.blnShareDisabled = true;
        //Return full list of checkboxes of class .recCheckboxes
        allCheckboxes = this.template.querySelectorAll('.recCheckboxes');
        
        //Build list of FC Ids from the Id of the checked checkboxes
        for(i=0; allCheckboxes[i]; i++){
            if(allCheckboxes[i].checked){
                checkedList.push(allCheckboxes[i].value);
            }
        }
        
        //Imperatively call the assignToHearings apex method
        //On success, show success toast
        //On error, show error toast
        assignToHearingOrLE({ //Think of a better name for this. 
            lstFCIds: checkedList,
            caseId: this.recordId,
            lstUnshareFCIds: this.unshareFCs,
            strShareWithFieldName: 'IETRS_Shared_With_Hearings__c'
        })
        .then(result => {
            const event = new ShowToastEvent({
                title: 'Success',
                variant: 'success',
                message: 'Case Successfully Assigned to Hearings.',
            });
            this.dispatchEvent(event);
            this.modalVisible = false;
            this.blnShareDisabled = false;
            this.blnComplete = true;
            this.forceRefreshView();
        })
        .catch(error => {
            // display server exception in toast msg 
            const event = new ShowToastEvent({
                title: 'Error',
                variant: 'error',
                message: error.body.message,
            });
            this.dispatchEvent(event);
            this.blnShareDisabled = false;
        });




    }

    forceRefreshView() {
        console.log("Fire Refresh Event");
        fireEvent(this.pageRef, 'refreshfromlwc', this.name);
    }

}