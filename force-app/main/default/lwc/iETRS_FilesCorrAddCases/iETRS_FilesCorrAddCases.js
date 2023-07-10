import { LightningElement, track, api, wire } from 'lwc';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import Case from '@salesforce/schema/Case';
import IETRS_Case_Agenda_Section__c from '@salesforce/schema/Case.IETRS_Agenda_Section__c';
import getCaseList from '@salesforce/apex/IETRS_MassRelatedFCController.getCaseList';
import createRelatedFCs from '@salesforce/apex/IETRS_MassRelatedFCController.createRelatedFCs';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CurrentPageReference } from 'lightning/navigation';
import { fireEvent } from 'c/pubsub';

export default class iETRS_FilesCorrAddCases extends LightningElement {
    //for record information
    @api recordId;

    @track readyForConfValue = false;
    @track agendaSectionValue;
    @track confDateValue;
    @track parentCaseValue;

    //modal base functionality
    @track openmodel = false;
    @track areResultsVisible = false;

    @track cases;
    @track existingCases;
    @track
    isLoading = false;

    /**
     * Indicates if the search returned no case records.
     * @returns {boolean} True if cases were searched but no results were found.
     */
    get noCases() {
        return (
            !this.isLoading &&
            this.areResultsVisible &&
            (this.cases || []).length === 0
        );
    }

    /**
     * Indicates if the search returned no case records currently associated with the file record in scope.
     * @returns {boolean} True if cases were searched but no existing case results were found.
     */
    get noExistingCases() {
        return (this.existingCases || []).length === 0;
    }

    @wire(CurrentPageReference) pageRef;

    @wire(getObjectInfo, { objectApiName: Case })
    objectInfo;

    @wire(getPicklistValues, {
        recordTypeId: '$objectInfo.data.defaultRecordTypeId',
        fieldApiName: IETRS_Case_Agenda_Section__c
    })
    AgendaSectionPicklistValues;

    openmodal() {
        this.openmodel = true;
    }
    closeModal() {
        this.openmodel = false;
        this.areResultsVisible = false;
        this.cases = undefined;
        this.existingCases = undefined;
        this.readyForConfValue = false;
        this.agendaSectionValue = undefined;
        this.confDateValue = undefined;
        this.parentCaseValue = undefined;
    }
    showResults() {
        this.areResultsVisible = true;
    }
    handleChange1(event) {
        this.readyForConfValue = event.target.checked;
    }
    handleChange2(event) {
        this.agendaSectionValue = event.detail.value;
    }
    handleChange3(event) {
        this.confDateValue = event.target.value;
    }
    handleChange4(event) {
        this.parentCaseValue = event.target.value;
    }

    handleBackClick() {
        this.areResultsVisible = false;
    }

    // call apex method on button click
    handleSearch() {
        //change modal screen
        this.showResults();

        if (
            this.readyForConfValue != null ||
            this.agendaSectionValue != null ||
            this.confDateValue != null ||
            this.parentCaseValue != null
        ) {
            this.isLoading = true;
            getCaseList({
                searchKey1: this.readyForConfValue,
                searchKey2: this.agendaSectionValue,
                searchKey3: this.confDateValue,
                searchKey4: this.parentCaseValue,
                strFCRecordID: this.recordId
            })
                .then(({ cases, existingCases }) => {
                    this.cases = cases;
                    this.existingCases = existingCases;
                })
                .catch((error) => {
                    // display server exception in toast msg
                    const event = new ShowToastEvent({
                        title: 'Error',
                        variant: 'error',
                        message: error.body.message
                    });
                    this.dispatchEvent(event);
                    // reset cases var with null
                    this.cases = null;
                    this.existingCases = null;
                })
                .finally(() => {
                    this.isLoading = false;
                });
        } else {
            // fire toast event if input field is blank
            const event = new ShowToastEvent({
                variant: 'error',
                message: 'No Results Found'
            });
            this.dispatchEvent(event);
        }
    }

    selectAllCheckboxes(event) {
        let x, i;
        x = this.template.querySelectorAll('.recCheckboxes');

        if (event.target.checked) {
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
        var z, z2, j;
        var checkedList = [];
        this.isLoading = true;
        z = this.template.querySelectorAll('.recCheckboxes');
        // get ids of checkbox selected items

        for (j = 0; z[j]; ++j) {
            if (z[j].checked) {
                z2 = z[j].value;
                checkedList.push(z2);
            }
        }

        createRelatedFCs({
            strFCId: this.recordId,
            lstCaseIds: checkedList
        })
            .then((result) => {
                console.log(result);

                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Record(s) Successfully Created',
                        variant: 'success'
                    })
                );
                this.closeModal();
                this.forceRefreshView();
            })
            .catch((error) => {
                console.log('error: ', JSON.parse(JSON.stringify(error)));
                // display server exception in toast msg
                const event = new ShowToastEvent({
                    title: 'Error',
                    variant: 'error',
                    message: error.body.message
                });
                this.dispatchEvent(event);
            })
            .finally(() => {
                this.isLoading = false;
            });

        // //todo: refactor
        //         for(z3=0; checkedList[z3]; ++z3){
        //             const fields = {};
        //             fields[FILECORRID_FIELD.fieldApiName] = this.recordId;

        //             fields[CASEID_FIELD.fieldApiName] = checkedList[z3];

        //             const recordInput = { apiName: IETRS_File_Correspondence_Assignment__c.objectApiName, fields };

        //             createRecord(recordInput)
        //             .then(fcaRecord => {
        //                 //for each in selectedCaseList
        //                 this.IETRS_Files_Correspondence__c = fcaRecord.IETRS_Files_Correspondence__c;
        //                 this.IETRS_Case__c = fcaRecord.IETRS_Case__c;

        //                 this.dispatchEvent(
        //                     new ShowToastEvent({
        //                         title: 'Success',
        //                         message: 'Related Files and Correspondence Record(s) Created',
        //                         variant: 'success',
        //                     }),
        //                 );
        //                 this.closeModal();
        //             })
        //             .catch(error => {
        //                 this.dispatchEvent(
        //                     new ShowToastEvent({
        //                         title: 'Error creating record',
        //                         message: error.body.message,
        //                         variant: 'error',
        //                     }),
        //                 );
        //             });
        //         }
    }

    forceRefreshView() {
        console.log('Fire Refresh Event');
        fireEvent(this.pageRef, 'refreshfromlwc', this.name);
    }
}