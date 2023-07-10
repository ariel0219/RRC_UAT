import { LightningElement, api, track, wire } from 'lwc';
import { FlowAttributeChangeEvent } from 'lightning/flowSupport';
import { refreshApex } from '@salesforce/apex';
import getRecords from '@salesforce/apex/CIIS_SupplyChainAccountsController.getRecords';
import getColumns from '@salesforce/apex/CIIS_SupplyChainAccountsController.getColumns';
import getAccountGeolocations from '@salesforce/apex/CIIS_SupplyChainAccountsController.getAccountGeolocations';

export default class CiisSupplyChainAccountsTable extends LightningElement {
    showGeolocation = true;
    @api getData = false;
    @api hideCheckboxColumn = false;
    @api multiselect = false;
    @api supplyChainType;
    @api keyField = 'Id';
    @api operatorId;
    @api whereClauseSuffix;
    @api
    get selectedRows() {
        return this._selectedRows;
    }
    set selectedRows(value) {
        this._selectedRows = value;
    }
    @api
    get selectedRowIds() {
        return this._selectedRowIds;
    }
    set selectedRowIds(value) {
        this._selectedRowIds = value;
    }
    @api
    get records() {
        return this._records;
    }
    set records(value) {
        this._records = value;
    }

    @api
    get forceRefresh() {
        return this._forceRefresh;
    }
    set forceRefresh(value) {
        this._forceRefresh = value;
    }

    @track _records;
    @track _selectedRows;
    @track _selectedRowIds;
    @track accountIds;
    @track columns;
    @track error;
    wiredGeos;
    wiredCols;

    get maxRowSelection() {
        return this.multiselect ? 1000 : 1;
    }

    get isReady() {
        return this.columns !== undefined && this._records !== undefined;
    }

    @wire(getColumns, { supplyChainType: '$supplyChainType' })
    wiredColumns(value) {
        this.wiredCols = value;
        const { error, data } = value;
        if (data) {
            if (this.showGeolocation) {
                this.columns = [
                    ...data,
                    {
                        label: 'Location',
                        fieldName: 'geolocation',
                        type: 'text'
                    }
                ];
            } else {
                this.columns = data;
            }
        } else if (error) {
            this.error = error.body.message;
        }
    }

    @wire(getAccountGeolocations, {
        accountIds: '$accountIds',
        supplyChainType: '$supplyChainType'
    })
    wiredAccGeos(value) {
        this.wiredGeos = value;
        const { error, data } = value;
        if (data) {
            console.log(
                'this.accountIds: ',
                JSON.parse(JSON.stringify(this.accountIds))
            );
            console.log('data: ', JSON.parse(JSON.stringify(data)));
            this._records = (this._records || []).map((record) => {
                const geolocation = (data[record.Id] || []).reduce(
                    (acc, curr) => {
                        if (curr.CIIS_Geolocations__r) {
                            acc = `${curr.CIIS_Geolocations__r.CIIS_Geolocation__Latitude__s},${curr.CIIS_Geolocations__r.CIIS_Geolocation__Longitude__s}`;
                        }
                        return acc;
                    },
                    ''
                );
                return { ...record, geolocation };
            });
            if (this.forceRefresh) {
                this._forceRefresh = false;
                this.handleRefresh();
            }
        } else if (error) {
            this.error = error.body.message;
        }
    }

    connectedCallback() {
        if (this.getData) {
            this.getRecords();
        } else {
            if (this.showGeolocation) {
                this.accountIds = (this._records || []).map(
                    (record) => record.Id
                );
            }
        }
    }

    getRecords() {
        getRecords({
            supplyChainType: this.supplyChainType,
            operatorId: this.operatorId,
            whereClauseSuffix: this.whereClauseSuffix
        })
            .then((result) => {
                this._records = result;
                if (this.showGeolocation) {
                    this.accountIds = result.map((record) => record.Id);
                }
            })
            .catch((error) => {
                this.error = error.body.message;
            });
    }

    handleRowSelection(event) {
        const selectedRows = event.detail.selectedRows;
        this._selectedRows = selectedRows;
        this._selectedRowIds = selectedRows.map((row) => row[this.keyField]);
        const selectedRowsEvent = new FlowAttributeChangeEvent(
            'selectedRows',
            this._selectedRows
        );
        this.dispatchEvent(selectedRowsEvent);
    }

    handleRefresh() {
        console.log('handleRefresh');
        return refreshApex(this.wiredGeos);
    }
}