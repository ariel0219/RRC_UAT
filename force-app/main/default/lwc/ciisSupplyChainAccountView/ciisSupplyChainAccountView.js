import { LightningElement, api, track, wire } from 'lwc';
import getColumns from '@salesforce/apex/CIIS_SupplyChainAccountsController.getColumns';
import getRecord from '@salesforce/apex/CIIS_SupplyChainAccountsController.getRecord';

export default class CiisSupplyChainAccountView extends LightningElement {
    @api record;
    @api recordId;
    @api supplyChainType;
    @track error;
    // @track fields;
    @track columns = [];
    @track wiredRecord;
    @track wiredRecordId;
    getRecordFields = [];

    get isReady() {
        return this.fields !== undefined;
    }

    get fields() {
        let result;
        let record = this.record || this.wiredRecord;
        if (this.columns.length === 0) {
            return result;
        }
        if (record) {
            result = this.columns.map((col) => {
                return {
                    ...col,
                    value: record[col?.fieldName] || ''
                };
            });
        }
        return result;
    }

    connectedCallback() {
        if (this.recordId === undefined && this.record === undefined) {
            this.error = 'No record or recordId was provided.';
        }
    }

    @wire(getRecord, {
        supplyChainType: '$supplyChainType',
        recordId: '$recordId'
    })
    wiredRecordCb({ error, data }) {
        if (data) {
            this.error = undefined;
            this.wiredRecord = data;
        } else if (error) {
            this.error = error.body.message;
        }
    }

    @wire(getColumns, { supplyChainType: '$supplyChainType' })
    wiredColumns({ error, data }) {
        if (data) {
            this.error = undefined;
            this.columns = data;
        } else if (error) {
            this.error = error.body.message;
        }
    }
}