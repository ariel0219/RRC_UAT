import {LightningElement,track,wire,api} from "lwc";
import findRecords from "@salesforce/apex/LwcLookupController.findRecords";
import accRecords from "@salesforce/apex/LwcLookupController.findaccRecords";
import fetchP5Recordtype from "@salesforce/apex/LwcLookupController.fetchP5NumberBasenontheRecordTypes";
import fetchaccRecordtype from "@salesforce/apex/LwcLookupController.fetchAccountRecordBasedOntheRecordType";
import findaccRecordsBasedOnOperatorName from "@salesforce/apex/LwcLookupController.findaccRecordsBasedOnOperatorName";

export default class LwcLookup extends LightningElement {

    @api splitBln;
    @track isaccBln = false;
    @track iscompanyIDbln = false;
    @track isp5recordsbln = false;
    @track isregulatedpsrec = false;
    @track recordsList;
    @track searchKey = "";
    @api selectedValue;
    @api selectedRecordId;
    @api objectApiName;
    @api iconName;
    @api lookupLabel;
    @api placeholder;
    @track message;
    @api disablesearchlkp = false;
    @api recordtypeName;
    //@api closeicon='utility:close';

    //Added by Ayesha for getting the selected Operator name
    @api operatorid;
    @api p5numberid;

    onLeave(event) {
        setTimeout(() => {
            this.searchKey = "";
            this.recordsList = null;
        }, 300);
    }

    connectedCallback() {
        this.disablesearchlkp = false;
        //this.template.querySelector('.lkpcls').disabled = true;
        //this.template.querySelector("#combobox-id-2").disabled = true;
    }

    recordselectionsecod(event) {
        this.selectedRecordId = event.target.dataset.key;
        this.selectedValue = event.target.dataset.name;
        this.searchKey = "";
        this.onSelectionRecordbtn();
    }

    onRecordSelection(event) {
        this.selectedRecordId = event.target.dataset.key;
        this.selectedValue = event.target.dataset.name;
        this.searchKey = "";
        this.onSeletedRecordUpdate();
    }

    handleKeyChange(event) {
        window.clearTimeout(this.delayTimeout);
		const searchTerm = event.target.value;
		// eslint-disable-next-line @lwc/lwc/no-async-operation
		this.delayTimeout = setTimeout(() => {
			this.searchKey = searchTerm;
            this.getLookupResult();
		}, 500);

        // const searchKey = event.target.value;
        // this.searchKey = searchKey;
        // this.getLookupResult();
    }

    @api istrueblnSearch;
    @api
    callingfromParentSearchQuery(isValuepass) {
        window.alert('parent', isValuepass);
        this.istrueblnSearch = isValuepass;
    }

    @api
    removeRecordOnLookup() {
        this.searchKey = "";
        this.selectedValue = null;
        this.selectedRecordId = null;
        this.recordsList = null;
        this.ondisablebuttonaction();
    }

    getAccountRecords() {
        this.iscompanyIDbln = false;
        this.isaccBln = true;
        this.isp5recordsbln = false;
        this.isregulatedpsrec = false;
        accRecords({
            searchKey: this.searchKey,
            objectName: this.objectApiName
        })
            .then((result) => {
                if (result.length === 0) {
                    this.recordsList = [];
                    this.message = "No Records Found";
                } else {
                    this.recordsList = result;
                    this.message = "";
                }
                this.error = undefined;
            })
            .catch((error) => {
                window.alert(JSON.stringify(error));
                this.error = error;
                this.recordsList = undefined;
            });
    }

    getCompanyIdRecords() {
        this.iscompanyIDbln = true;
        this.isaccBln = false;
        this.isp5recordsbln = false;
        this.isregulatedpsrec = false;
        findRecords({
            searchKey: this.searchKey,
            objectName: this.objectApiName
        })
            .then((result) => {
                if (result.length === 0) {
                    this.recordsList = [];
                    this.message = "No Records Found";
                } else {
                    this.recordsList = result;
                    this.message = "";
                }
                this.error = undefined;
            })
            .catch((error) => {
                window.alert(JSON.stringify(error));
                this.error = error;
                this.recordsList = undefined;
            });
    }


    //P5RECORDS IN SRC
    getP5Records() {
        this.iscompanyIDbln = false;
        this.isaccBln = false;
        this.isp5recordsbln = true;
        this.isregulatedpsrec = false;
        fetchP5Recordtype({
            searchKey: this.searchKey,
            objectName: this.objectApiName,
            Recordtypename: this.recordtypeName
        })
            .then((result) => {
                if (result.length === 0) {
                    this.recordsList = [];
                    this.message = "No Records Found";
                } else {
                    this.recordsList = result;
                    this.message = "";
                }
                this.error = undefined;
            })
            .catch((error) => {
                window.alert(JSON.stringify(error));
                this.error = error;
                this.recordsList = undefined;
            });
    }

    // GET THE RECORDS FROM ACCOUNT USING RECORD TYPE 
    getaccountRecordsUsingRecordType() {
        this.iscompanyIDbln = false;
        this.isaccBln = false;
        this.isp5recordsbln = false;
        this.isregulatedpsrec = true;
        fetchaccRecordtype({
            searchKey: this.searchKey,
            objectName: this.objectApiName,
            Recordtypename: this.recordtypeName
        })
            .then((result) => {

                if (result.length === 0) {
                    this.recordsList = [];
                    this.message = "No Records Found";
                } else {
                    this.recordsList = result;
                    this.message = "";
                }
                this.error = undefined;
            })
            .catch((error) => {
                window.alert(JSON.stringify(error));
                this.error = error;
                this.recordsList = undefined;
            });
    }
    getLookupResult() {
        var getvalue = this.splitBln;
        switch (getvalue) {
            case 'allAccRecords':
                this.getAccountRecords();
                break;
            case 'companyRecords':
                this.getCompanyIdRecords();
                break;
            case 'fetchp5numberBasedontheRecordType':
                this.getP5Records();
                break;
            case 'fetchAccountsBasedontheRecordType':
                this.getaccountRecordsUsingRecordType();
                break;
            //Added by Ayesha on 4th DEC 2020
            case 'regulatedPSRecords':
                this.getaccountRecordsUsingRecordType();
                break;
            //Added by Ayesha on 15th DEC 2020
            case 'allAccRecordsAtSRCorIMP':
                this.getAccountRecordsAtSRCorIMP();
                break;
        }
    }
    @api handleValueChange(getvalue) {
        window.alert(getvalue);
    }

    onSelectionRecordbtn() {
        const passEventstr = new CustomEvent('recordselectionsecod', {
            detail: {
                selectedRecordId: this.selectedRecordId,
                selectedValue: this.selectedValue,
                closevalue: 'clsevalue'
            }
        });
        this.dispatchEvent(passEventstr);
    }

    //SEARCH ENABLE OR DISBALE BUTTON ON SEARCH COMPONENT 
    ondisablebuttonaction() {
        const passEventr = new CustomEvent('disablebuttonaction', {
            detail: {
                selectedRecordId: this.selectedRecordId,
                selectedValue: this.selectedValue,
            }
        });
        this.dispatchEvent(passEventr);
    }

    onSeletedRecordUpdate() {
        // window.alert('sss'+this.istrueblnSearch);
        const passEventr = new CustomEvent('recordselection', {
            detail: {
                selectedRecordId: this.selectedRecordId,
                selectedValue: this.selectedValue,
                closevalue: 'openvalue'
            }
        });
        this.dispatchEvent(passEventr);


    }

    //Added by Ayesha on 15th DEC 2020
    getAccountRecordsAtSRCorIMP() {
        this.iscompanyIDbln = false;
        this.isaccBln = true;
        this.isp5recordsbln = false;
        this.isregulatedpsrec = false;
        var operatorId;
        if (this.operatorid == undefined)
            operatorId = null;
        else
            operatorId = this.operatorid;

        var p5numberId;
        if (this.p5numberid == undefined)
            p5numberId = null;
        else
            p5numberId = this.p5numberid;

        findaccRecordsBasedOnOperatorName({
            searchKey: this.searchKey,
            objectName: this.objectApiName,
            operatorid: operatorId,
            p5numberid: p5numberId
        })
            .then((result) => {
                if (result.length === 0) {
                    this.recordsList = [];
                    this.message = "No Records Found";
                } else {
                    this.recordsList = result;
                    this.message = "";
                }
                this.error = undefined;
            })
            .catch((error) => {
                window.alert(JSON.stringify(error));
                this.error = error;
                this.recordsList = undefined;
            });
    }

    
    /*renderedCallback() {
        
        Promise.all([
            
            loadStyle(this,sldscss)
        ])
            .then(() => {
                console.log('resndede2');
                //this.initializeD3();
            })
            .catch(error => {
                console.log('resndede3');
            });
            
    }*/

}