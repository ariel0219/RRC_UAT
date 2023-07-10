import { LightningElement, api, track, wire } from 'lwc';
import { getPicklistValues, getObjectInfo } from 'lightning/uiObjectInfoApi';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getInspectionResults from '@salesforce/apex/IETRS_UpdateInspectionResults.getInspectionResults';
import saveRecords from '@salesforce/apex/IETRS_UpdateInspectionResults.saveRecords';
import INSPECTION_RESULT_OBJECT from '@salesforce/schema/IETRS_Insp_Inspection_Result__c';
import TAB_FIELD from '@salesforce/schema/IETRS_Insp_Inspection_Result__c.IETRS_Tab__c';

// Constants
const ModalClass = 'slds-modal';
const ModalOpenClass = 'slds-fade-in-open';
const DropbackClass = 'slds-backdrop';
const DropbackOpenClass = 'slds-backdrop_open';

export default class IetrsInspectionResults extends NavigationMixin(LightningElement) {
    @api recordId;
    @track inspections = [];
    @track loading;
    @track activeTab;
    @track tabOptions = [];
    @track isModalOpen = false;
    resizeTimeoutId;
    resultChangesById = {};
    pendingActiveTab;
    newViolations = [];

    connectedCallback() {
        this.loading = true;
        this.setupResizeHandler();
    }

    @wire(getObjectInfo, { objectApiName: INSPECTION_RESULT_OBJECT })
    objectInfo;

    @wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: TAB_FIELD })
    wiredGetPicklistValues({ error, data }) {
        if (data) {
            const plValues = (data || {}).values || [];
            this.tabOptions = plValues.map((opt, i) => {
                let isActive = i === 0;
                return { ...opt, isActive };
            });
            let tabName = this.tabOptions[0].value;
            this.getInspectionResults(tabName);
        } else if (error) {
            console.log('tab options error: ', error);
        }
    }

    /**
     * @returns {Boolean} True if there is no data to show
     */
    get noData() {
        return !this.loading && this.inspections.length === 0;
    }

    /**
     * @returns {string} The css class for the modal container.
     */
    get modalClass() {
        if (this.isModalOpen) {
            return `${ModalClass} ${ModalOpenClass}`;
        }
        return ModalClass;
    }

    /**
     * @returns {string} The css class for the modal dropback.
     */
    get dropbackClass() {
        if (this.isModalOpen) {
            return `${DropbackClass} ${DropbackOpenClass}`;
        }
        return DropbackClass;
    }

    getInspectionResults(tabName) {
        getInspectionResults({ recordId: this.recordId, tabName })
            .then(result => {
                this.inspections = result || [];
                console.log('this.inspections: ', JSON.parse(JSON.stringify(this.inspections)));
                this.setTableHeight();
                this.loading = false;
            })
            .catch(err => {
                console.log(err);
                this.loading = false;
                this.fireToastEvent(
                    'Error',
                    'There was a problem retrieving the inspection results. Please see your System Administrator.',
                    'error'
                );
            });
    }

    @api
    saveRecords(onsuccess) {
        const inspectionResults = [];
        this.loading = true;
        for (let prop in this.resultChangesById) {
            if (this.resultChangesById[prop]) {
                inspectionResults.push(this.resultChangesById[prop]);
            }
        }
        saveRecords({ inspectionResults })
            .then(() => {
                console.log('saved');
                this.loading = false;
                this.clearUnsavedChanges();
                // set new violations to read only
                this.newViolations.forEach(resultObj => {
                    resultObj.isViolationReadOnly = true;
                });
                this.newViolations = [];
                this.fireToastEvent('Success', 'Your changes were saved.', 'success');
                if (onsuccess) onsuccess();
            })
            .catch(err => {
                console.log('save err ', err);
                const errorMsg =
                    ((err || {}).body || {}).message ||
                    'There was a problem saving the inspection results. Please see your System Administrator.';
                this.loading = false;
                this.fireToastEvent('Error', errorMsg, 'error');
            });
    }

    clearUnsavedChanges() {
        this.resultChangesById = {};
        this.dispatchEvent(new CustomEvent('clearunsavedchange'));
    }

    fireToastEvent(title, message, variant) {
        const toastEvent = new ShowToastEvent({
            title,
            message,
            variant
        });
        this.dispatchEvent(toastEvent);
    }

    setupResizeHandler() {
        window.onresize = () => {
            console.log('onresize');
            // clear existing timeout, if it exists
            clearTimeout(this.resizeTimeoutId);
            // wait a second until done resizing, then set the new table height
            const coolDown = 1000; // 1sec
            // eslint-disable-next-line @lwc/lwc/no-async-operation
            const resizeTimeoutId = setTimeout(() => {
                this.setTableHeight();
            }, coolDown);
            this.resizeTimeoutId = resizeTimeoutId;
        };
    }

    setTableHeight() {
        let tableContainerEl;
        let footerEl;
        let isNotSet = true;
        while (isNotSet) {
            tableContainerEl = this.template.querySelector('.table-container');
            footerEl = this.template.querySelector('.js-footer');
            if (footerEl && tableContainerEl) {
                const tableCoords = tableContainerEl.getBoundingClientRect();
                const footerCoords = footerEl.getBoundingClientRect();
                const tableHeight = footerCoords.top - tableCoords.top + 'px';
                tableContainerEl.style.height = tableHeight;
                isNotSet = false;
            }
        }
    }

    navigateToRecordDetail(recordId, objectApiName) {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId,
                objectApiName,
                actionName: 'view'
            }
        });
    }

    getActiveTabEl() {
        if (this.activeTabEl) {
            return this.activeTabEl;
        }
        const tabs = this.template.querySelectorAll('c-ietrs-inspection-tab');
        for (let i = 0; i < tabs.length; i++) {
            let tab = tabs[i];
            if (tab.isActive) {
                return tab;
            }
        }
        return null;
    }

    setNewActiveTabEl(newActiveTabEl) {
        const activeTabEl = this.getActiveTabEl();
        this.loading = true;
        if (activeTabEl) {
            activeTabEl.isActive = false;
        }
        newActiveTabEl.isActive = true;
        this.activeTabEl = newActiveTabEl;
        this.activeTab = newActiveTabEl.label;
        this.getInspectionResults(newActiveTabEl.tabName);
    }

    handleSObjectClick(evt) {
        const { recordId, objectApiName } = evt.target.dataset;
        evt.preventDefault();
        this.navigateToRecordDetail(recordId, objectApiName);
    }

    handleResultSObjectClick(evt) {
        const { recordId, objectApiName } = evt.detail;
        this.navigateToRecordDetail(recordId, objectApiName);
    }

    handleSave() {
        this.saveRecords();
    }

    handleSaveAndClose() {
        this.saveRecords(() => {
            this.dispatchEvent(new CustomEvent('closetab'));
        });
    }

    handleTabChange(evt) {
        const newActiveTabEl = evt.target;
        const hasUnsavedChanges = Object.keys(this.resultChangesById).length > 0;
        if (hasUnsavedChanges) {
            // store the pending tab element
            this.pendingActiveTab = newActiveTabEl;
            // show the warning modal
            this.isModalOpen = true;
        } else {
            this.setNewActiveTabEl(newActiveTabEl);
        }
    }

    handleRecordChange(evt) {
        const fieldChanges = evt.detail;
        const inspectionIndex = parseInt(evt.target.dataset.inspectionIndex, 10);
        const resultIndex = parseInt(evt.target.dataset.resultIndex, 10);
        if (!this.resultChangesById[fieldChanges.Id]) {
            this.resultChangesById[fieldChanges.Id] = fieldChanges;
            this.dispatchEvent(new CustomEvent('unsavedchange'));
        } else {
            Object.assign(this.resultChangesById[fieldChanges.Id], fieldChanges);
        }
        const resultObj = this.inspections[inspectionIndex].inspectionResults[resultIndex];
        const resultRecord = resultObj.inspRec;
        Object.assign(resultRecord, fieldChanges);
        // save a reference to newly checked result records so they can be locked after save
        if (!resultObj.isViolationReadOnly && resultRecord.IETRS_Create_Violation__c) {
            this.newViolations.push(resultObj);
        }
    }

    handleCloseModal() {
        this.isModalOpen = false;
    }

    handleDiscardChanges() {
        this.isModalOpen = false;
        this.clearUnsavedChanges();
        this.setNewActiveTabEl(this.pendingActiveTab);
    }

    handleSaveChanges() {
        this.isModalOpen = false;
        this.saveRecords(() => {
            // set new tab and get new records
            this.setNewActiveTabEl(this.pendingActiveTab);
        });
    }
}