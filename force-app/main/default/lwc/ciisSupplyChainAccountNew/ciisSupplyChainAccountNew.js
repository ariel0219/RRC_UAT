import { LightningElement, api, track, wire } from 'lwc';
import { FlowAttributeChangeEvent } from 'lightning/flowSupport';
import getInputFields from '@salesforce/apex/CIIS_SupplyChainAccountsController.getInputFields';
import getEntityWithDefaultValues from '@salesforce/apex/CIIS_SupplyChainAccountsController.getEntityWithDefaultValues';

const invalidFacilityStorageKey = 'invalidFacility';

export default class CiisSupplyChainAccountNew extends LightningElement {
    @api supplyChainType;
    @api operatorId;
    @track error;
    @api
    get record() {
        return this._record;
    }
    set record(value) {
        this._record = value;
    }

    @track _record;
    @track inputFields = [];

    get isReady() {
        return this.inputFields !== undefined;
    }

    @wire(getInputFields, { supplyChainType: '$supplyChainType' })
    wiredInputFields({ error, data }) {
        if (data) {
            this.error = undefined;
            this.inputFields = data;
            // check if there's a facility that was previously invalid
            console.log(
                'check local storage for invalid facility in wiredInputFields'
            );
            this.setRecordFromLocalStorage();
        } else if (error) {
            console.log('error ', error);
            this.error = error.body.message;
        }
    }

    @wire(getEntityWithDefaultValues, {
        supplyChainType: '$supplyChainType',
        operatorId: '$operatorId'
    })
    wiredDefaultValues({ error, data }) {
        if (data) {
            this.error = undefined;
            if (!localStorage.getItem(invalidFacilityStorageKey)) {
                this._record = { ...this._record, ...data };
            }
        } else if (error) {
            console.log('error ', error);
            this.error = error.body.message;
        }
    }

    @api
    validate() {
        const isValid = [
            ...this.template.querySelectorAll('lightning-input')
        ].reduce((validSoFar, inputCmp) => {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);

        if (isValid) {
            console.log('is valid, remove from local storage');
            localStorage.setItem(invalidFacilityStorageKey, '');
            return { isValid: true };
        }
        localStorage.setItem(
            invalidFacilityStorageKey,
            JSON.stringify(this._record)
        );
        return {
            isValid: false,
            errorMessage: 'Please fix all errors before continuing.'
        };
    }

    handleChange(event) {
        // get the data-field attribute value from the target
        const fieldName = event.target.dataset.field;
        let value = event.detail.value;
        if (event.target.type === 'checkbox') {
            value = event.target.checked;
        }
        const newRecord = { ...this._record };
        newRecord[fieldName] = value;
        if (newRecord.Name) {
            newRecord.CIIS_Facility_Name__c = newRecord.Name;
        }
        console.log(newRecord);
        this._record = newRecord;
        this.dispatchEvent(
            new FlowAttributeChangeEvent('record', this._record)
        );
    }

    setRecordFromLocalStorage() {
        console.log(localStorage.getItem(invalidFacilityStorageKey));
        const storedFacility = localStorage.getItem(invalidFacilityStorageKey);
        if ((storedFacility || '').length > 0) {
            console.log('found invalid facility in local storage');
            // wait for the input fields to be rendered
            // eslint-disable-next-line @lwc/lwc/no-async-operation
            setTimeout(() => {
                const invalidFacility = JSON.parse(storedFacility);
                this._record = invalidFacility;
                this.dispatchEvent(
                    new FlowAttributeChangeEvent('record', this._record)
                );
                // iterate through the input fields and set the value if data-field attribute matches the stored object's key
                [...this.template.querySelectorAll('lightning-input')].forEach(
                    (inputCmp) => {
                        if (invalidFacility[inputCmp.dataset.field]) {
                            inputCmp.value =
                                invalidFacility[inputCmp.dataset.field];
                        }
                    }
                );
            });
        }
    }
}