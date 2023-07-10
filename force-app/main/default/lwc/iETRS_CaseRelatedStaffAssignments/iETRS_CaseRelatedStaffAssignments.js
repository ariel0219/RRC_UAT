/* eslint-disable no-console */
import { LightningElement, api, track, wire } from 'lwc';
import getRelatedStaffAssignments from '@salesforce/apex/IETRS_StaffAssignmentsController.getRelatedStaffAssignments';

export default class iETRS_CaseRelatedStaffAssignments extends LightningElement {

    //Administrator defined input variables
    @api recordId;
    @api strSortOrder = '';
    @api strCardTitle = '';
    @api blnHearings = false;
    //Utility variables
    @track staffAssignments = [];
    @track error;
    @track strListTitle = '';

   
    
    @wire(getRelatedStaffAssignments, {caseId: '$recordId', strSortOrder: '$strSortOrder', blnHearings: '$blnHearings'})
    loadStaffAssignements(result) {
        var i;
        // eslint-disable-next-line no-unused-vars
        var hrefs;
        if (result.error){
            this.error = result.error;
        }
        else if (result.data){
            for (i = 0; i< Object.keys(result.data).length; i++){
                //Build the relative urls for the Staff Assignment and User and add them to the Staff Assignments object
                this.hrefs = {hrefSA: '/' + result.data[i].Id, hrefUser: '/' + result.data[i].IETRS_Staff_Id_form__c};
                this.staffAssignments[i] = {...result.data[i] , ...this.hrefs};
            }
            this.strListTitle = this.strCardTitle + ' (' + Object.keys(result.data).length + ')';
        }
    }
    
    

}