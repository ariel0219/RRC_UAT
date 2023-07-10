import { LightningElement, track, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import {FlowAttributeChangeEvent, FlowNavigationNextEvent} from 'lightning/flowSupport';
import createsEventRegistration from '@salesforce/apex/outsideInstructorStudentRosterHandler.createsEventRegistration';
import registrantRecordType from '@salesforce/apex/outsideInstructorStudentRosterHandler.registrantRecordType';
import isEventOpen from '@salesforce/apex/outsideInstructorStudentRosterHandler.isEventOpen';
import isOwnedByLoggedinUser from '@salesforce/apex/outsideInstructorStudentRosterHandler.isOwnedByLoggedinUser';


export default class OutsideInstructorStudentRoster extends LightningElement {
    keyIndex = 1;
    @api mReq = false;
    @api isVal = false;
    @api isEmpty = false;
    @api elementrecordId;
    @api recordId; // record id from the quick action - aura to lwc 
    @api registrantId;
    @api num1;
    @api recordIdArray = [];
    @api rowIndex;
    @api isOpenNew = false;
    @wire (registrantRecordType) registrantRecordTypeId;
    @wire (isEventOpen,{eventId: '$recordId'}) isOpenEvt;
    @wire (isOwnedByLoggedinUser,{eventId: '$recordId'}) isEventOwnedByLoggedinUser;
    
    @api invoke(){
        
    }
    @api itemList = [
        {
            id: 1
        }
    ];


    renderedCallback() {
        //console.log('Alex2: ' + this.isOpenEvt.data);
        //this.$eventIsOpen = true;
        //$eventIsOpen = false;

        var itemtohide = this.template.querySelector('.student-roster-sucess-message-area');
        itemtohide.hidden = true;


    }
    connectedCallback() {
      this.mReq = false;
      /* for(var i=1;i<=3;i++){      
        ++this.keyIndex;
        
        var newItem = [{ id: this.keyIndex }];
        this.itemList = this.itemList.concat(newItem);
      } 
     */
    
    //   var itemtohide = this.template.querySelector('.student-roster-sucess-message-area');
    //         itemtohide.hidden = true;
    //         itemtohide = this.template.querySelector('.student-roster-work-area');
    //         itemtohide.hidden = false;

      //var itemToHideonLoad = this.template.querySelector('.student-roster-sucess-message-area');
      //itemToHideonLoad.hidden = true;
      
    }

    addRow() 
    {
        let pageBottom = document.querySelector("#page-bottom");
        ++this.keyIndex;
      
        var newItem = [{ id: this.keyIndex }];
        this.itemList = this.itemList.concat(newItem);
        pageBottom.scrollIntoView();
    }
    removeRow(event)
    {
        
        if (this.itemList.length >= 2) {
            this.itemList = this.itemList.filter(function (element) {
                return parseInt(element.id) !== parseInt(event.target.accessKey);
            });
        }
    }
    get makeRequired()
    {
        if(this.mReq == false){
            return false;
        }
        return true;
        
    }
    handleSubmit(event) {
        //stop propogation 
        // var itemtohide = this.template.querySelector('.student-roster-work-area');
        // itemtohide.hidden = true;

        // var itemtohideNew = this.template.querySelector('.student-roster-sucess-message-area');
        // itemtohideNew.hidden = false;
        
        this.mReq = true;
        var isVal = true;
        var allEmpty = false;
        let counter = 0;
        let elementArray = [];
        
        let submitBool = true;
        const emailRegex=/^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
        let recs = Array.from(this.template.querySelectorAll('lightning-record-edit-form'));// query elements
        recs.forEach(element => {
            
        if(isVal == true){
            console.log('test if break');
            let inputsFromCurrentRow = Array.from(element.querySelectorAll("lightning-input-field"));
            inputsFromCurrentRow.forEach( inputElement => {
                                                
                                                if(inputElement.value == null || inputElement.value == ''){
                                                //is the element in the row empty
                                                counter++;
                                                }
                                            });
            if(inputsFromCurrentRow.length != counter){
                //the row is not empty. run validation
                counter =0;
                inputsFromCurrentRow.forEach(inputElement => {
                                            if(inputElement.fieldName == 'EEM_Email__c' && inputElement.value != null ){
                                                let emailVal = inputElement.value;
                                                inputElement.style.outline = null;
                                                inputElement.classList.remove("red");
                                                if(!emailVal.match(emailRegex)){
                                                    isVal = false;
                                                    inputElement.classList.add("red");
                                                }
                                            }
                                            isVal = isVal && inputElement.reportValidity();
                                            
                });
                if(isVal){
                    //row passes validation
                    elementArray.push(element);
                }
                }
            counter = 0;  
            //end passing through all rows   
        }            
        }); // end runs validation 

        if(isVal){
            elementArray.forEach(index => {
                
                                index.submit();
            });
            
           
        }
        else{
            
            }
    //end of handle submit    
    }
    handleSuccess(event){
        this.elementrecordId = event.detail.id;
        this.recordIdArray.push(this.elementrecordId);
        this.createEventRecord();
        this.recordIdArray = [];

        var itemtohide = this.template.querySelector('.student-roster-work-area');
        itemtohide.hidden = true;

        var itemtohideNew = this.template.querySelector('.student-roster-sucess-message-area');
        itemtohideNew.hidden = false;
        
    }

    createEventRecord() {
        createsEventRegistration({registrantId: this.recordIdArray,eventId: this.recordId})
        .then(() => {
        
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Students successfully created',
                    variant: 'success',
                }),
            );;
            
            //this.template.querySelectorAll('#studentrosterworkarea').hide();
            

            // var itemtodisplay = this.template.querySelector('.student-roster-sucess-message-area');
            // itemtodisplay.hidden = false;
            

        })
        .catch((error) => {
            const noSubmission = new ShowToastEvent({
                title: "Error Creating Record",
                message: error,
                variant:"error"
            });
            this.dispatchEvent(noSubmission);
        });
        let formReset = this.template.querySelectorAll('lightning-record-edit-form');
        formReset.forEach(formElement => 
            {
                let fieldReset = this.template.querySelectorAll('lightning-input-field');
                fieldReset.forEach(element => {
                    this.mReq = false;
                    element.reset();
                });
            });
        

    }
    get importRecordTypeId() 
    {    
        return this.registrantRecordTypeId.data;
    }

     get isOpen() {
        //return false;
        //return isEventOpen({eventId: this.recordId});
        //var temp = isOpenEvt;
        //alert(isEventOpen({eventId: this.recordId}) + ':::' + this.isOpenEvt.data);
        //console.log('Alex: ' + this.isOpenEvt.data);
        return this.isOpenEvt.data;
    }

    get isOwnedByUserLoggedin() {
        return this.isEventOwnedByLoggedinUser.data;
    }

    get isAllowed() {
        return this.isEventOwnedByLoggedinUser.data && this.isOpenEvt.data;
    }


}