import { LightningElement, track, api, wire } from 'lwc';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
//import { createRecord } from 'lightning/uiRecordApi';
//import PRIMARY_ACCT_FIELD from '@salesforce/schema/Case.IETRS_Primary_Account_Assignment__c';
//import PRIMARY_ACCT_FIELD from '@salesforce/schema/Case.AccountId';   

//import IETRS_Case_Secondary_Account_Assignment__c from '@salesforce/schema/IETRS_Case_Secondary_Account_Assignment__c';
//import ACCOUNTID_FIELD from '@salesforce/schema/IETRS_Case_Secondary_Account_Assignment__c.IETRS_Account__c';
//import CASEID_FIELD from '@salesforce/schema/IETRS_Case_Secondary_Account_Assignment__c.IETRS_Case__c';
import Account from '@salesforce/schema/Account';

import getAccountListNew from '@salesforce/apex/IETRS_MassSecActAssgnmtController.getAccountListNew';
import getAccountList from '@salesforce/apex/IETRS_MassSecActAssgnmtController.getAccountList';
import createSecondaryAccountList from '@salesforce/apex/IETRS_MassSecActAssgnmtController.createSecondaryAccountList';
import updateCaseMassSAADetails from '@salesforce/apex/IETRS_MassSecActAssgnmtController.updateCaseMassSAADetails';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { CurrentPageReference } from 'lightning/navigation';
import { fireEvent } from 'c/pubsub';

const PRIMARY_ACCT_FIELD = 'Case.IETRS_Primary_Account_Assignment__c';

export default class iETRS_SecAcctAssignAddCases extends LightningElement {
    //for record information
    @api recordId;
    @track leaseNumberValue;
    @track sAsNotChildren;
    @track sAsErrorAware = false;
    @track warningList = [];
    @track selectedAcctList = [];
    @track accounts;
    @track displayAccounts;    
    @track isLoading = false;

    //@bray : 10 Nov 2022 : RRC-1980 : WO 04 | Mass add Secondary Accounts District Search for Leases
    //@bray : 10 Nov 2022 : RRC-1981 : WO 05 | Add search type for lease number or Permit number
    @track searchBy='';
    @track searchByLease=false;
    @track searchByPermit=false;
    @track permitNumberValue;
    @track districtValue;
    
    @track districtFieldName='IETRS_District__r.Name';

    /**
     * Indicates if the search returned no case records.
     * @returns {boolean} True if cases were searched but no results were found.
     */
    get noData() {
        return (
            !this.isLoading &&
            (this.accounts || []).length === 0 &&
            this.resultsVisible
        );
    }

    @wire(CurrentPageReference) pageRef;

    @wire(getObjectInfo, { objectApiName: Account })
    objectInfo;

    @wire(getRecord, { recordId: '$recordId', fields: [PRIMARY_ACCT_FIELD] })
    case;

    //modal base functionality
    @track openmodel = false;
    @track resultsVisible = false;
    @track searchVisible = false;




    openmodal() {
        this.openmodel = true;
        this.searchVisible = true;
    }
    closeModal() {
        this.openmodel = false;
        this.resultsVisible = false;
        this.sAsNotChildren = false;
        this.sAsErrorAware = false;
        this.warningList = [];
        this.selectedAcctList = [];
        this.accounts = [];
        this.displayAccounts=[];

        this.searchBy='';
        this.searchByLease=false;
        this.searchByPermit=false;
        this.permitNumberValue='';
        this.districtValue='';
        this.leaseNumberValue='';        



    }
    showResults() {
        this.resultsVisible = true;
        this.searchVisible = false;
        this.sAsNotChildren = false;
    }
    returnResults() {
        this.resultsVisible = true;
        this.sAsNotChildren = false;
        this.searchVisible = false;
        this.sAsErrorAware = false;
        this.warningList = [];
        this.selectedAcctList = [];
        this.districtValue='';
        
    }
    handleChange1(event) {
        this.leaseNumberValue = event.target.value;
    }

    // START
    //@bray : 10 Nov 2022 : RRC-1980 : WO 04 | Mass add Secondary Accounts District Search for Leases
    //@bray : 10 Nov 2022 : RRC-1981 : WO 05 | Add search type for lease number or Permit number
    get searchbyoptions() {
        return [
            { label: 'Lease Number', value: 'Lease' },
            { label: 'Permit Number', value: 'Permit' }
        ];
    }


    handleDistrictChange(event) {
        this.districtValue = event.target.value;
    }
    handlePermitChange(event) {
        this.permitNumberValue = event.target.value;
    }
   displaySearchTemplate(event){
        this.searchBy = event.detail.value;
        if(this.searchBy=='Lease'){
            this.searchByLease=true;
            this.searchByPermit=false;
        }else if(this.searchBy=='Permit'){
            this.searchByLease=false;
            this.searchByPermit=true;
        }else{
            this.searchByLease=false;
            this.searchByPermit=false;
        }
        this.districtValue='';
    }

    isValidateInput(){
        const allValid = [
            ...this.template.querySelectorAll('lightning-input'),
        ].reduce((validSoFar, inputCmp) => {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);

        //console.log('allValid:'+allValid);

        const picklistValid = [
            ...this.template.querySelectorAll('lightning-combobox'),
        ].reduce((validSoFar, inputCmp) => {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);


        this.template.querySelectorAll('lightning-input-field').forEach(element => {
            let isDistrictValid = element.reportValidity();
            if(!isDistrictValid){
                element.reset();
                this.districtValue='';
            }
            //console.log('validity:'+validity);
        });
        /*
        const lookupFieldValid = [
            ...this.template.querySelectorAll('lightning-combobox'),
        ].reduce((validSoFar, inputCmp) => {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);
        */
        

        if (allValid && picklistValid) {
            return true;
        } else {            
            const event = new ShowToastEvent({
                variant: 'error',
                message: 'Please enter the value'
            });
            this.dispatchEvent(event);
            
            return false;
        }
    }
    //FINISH

    handleBackClick() {
        this.openmodel = true;
        this.searchVisible = true;
        this.resultsVisible = false;
        this.districtValue='';
    }

 

    handleSearch() {
        const isValid = this.isValidateInput();
        //console.log('isValid:'+isValid);
        if(!isValid){
            return false;
        }
        //change modal screen
        this.showResults();

        //if (this.leaseNumberValue != null) {
        this.isLoading = true;
        getAccountListNew({
            searchBy:this.searchBy,
            leaseNumber:this.leaseNumberValue, 
            district:this.districtValue,
            permitNumber:this.permitNumberValue,
            caseId:this.recordId
        })/*
        getAccountList({
            searchKey: this.leaseNumberValue,
            caseId: this.recordId
        })*/
        .then((result) => {
                // set @track cases variable with return case list from server
                //console.log('accounts');
                //console.log(JSON.stringify(result));
                this.accounts = result;
                this.displayAccounts = this.formatRelatedFieldName(result);
            })
            .catch((error) => {
                console.log(error)
                // display server exception in toast msg
                const event = new ShowToastEvent({
                    title: 'Error',
                    variant: 'error',
                    //message: error.body.message
                    message : error
                });
                this.dispatchEvent(event);
                // reset cases var with null
                this.accounts = null;
                this.displayAccounts=null;
            })
            .finally(() => {
                this.isLoading = false;
            });
        /*} 
        else {
            const event = new ShowToastEvent({
                variant: 'error',
                message: 'No Results Found'
            });
            this.dispatchEvent(event);
        }*/
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
        var z,
            j,
            z2,
            acct,
            z4,
            primeAcct,
            checkedList = [],
            relatedFlag,
            intHierDepth,
            i,
            parent;
        z = this.template.querySelectorAll('.recCheckboxes');

        if (this.sAsNotChildren) { 
            this.sAsErrorAware = true;
        }

        // get ids of checkbox selected items
        for (j = 0; z[j]; ++j) {
            if (z[j].checked) {
                z2 = z[j].value;
                checkedList.push(z2);
            }
        }

        primeAcct = getFieldValue(this.case.data, PRIMARY_ACCT_FIELD);

        //loop through checked list, pull warningList and selectedAccountList
        for (z4 = 0; checkedList[z4]; ++z4) {
            //Get the Account object record from the originally queried list using the ID stored on the checkboxes
            // eslint-disable-next-line no-loop-func
            acct = this.accounts.find(
                (element) => element.Id === checkedList[z4]
            );
            relatedFlag = false;

            //Add the selected Account records to a list to be created as secondary account assignments later
            // eslint-disable-next-line no-loop-func
            if (
                this.selectedAcctList.find((element) => element === acct.Id) ===
                undefined
            ) {
                this.selectedAcctList.push(acct.Id);
            }

            //Search through the hierarchy of the account to determine if it has an ancestor that is related to
            //the Primary account
            parent = acct.Parent ? acct.Parent : parent;
            intHierDepth = this.helperFindDepth(acct);
            for (i = 0; i < intHierDepth - 1; i++) {
                if (parent.Id !== primeAcct) {
                    if (parent.Parent) {
                        parent = parent.Parent;
                    } else {
                        break;
                    }
                } else if (parent.Id === primeAcct) {
                    relatedFlag = true;
                    break;
                }
            }

            //populate warningList if account is not related
            if (relatedFlag === false) {
                this.warningList.push(acct.Name);
            }
        }

        if (this.warningList && this.warningList.length) {
            this.sAsNotChildren = true;
            this.resultsVisible = false;
        } else {
            //This allows a list of all valid (no warning) account Ids to pass through and be created.
            this.sAsErrorAware = true;
        }

        if(this.selectedAcctList==null || this.selectedAcctList.length==0){
            const event = new ShowToastEvent({
                variant: 'error',
                message: 'Please select at least one account to add.'
            });
            this.dispatchEvent(event);
            return false;
        }    

        if (!this.sAsNotChildren || this.sAsErrorAware) {
            createSecondaryAccountList({
                lstSaaAcctIds: this.selectedAcctList,
                strCaseId: this.recordId
            })
                // eslint-disable-next-line no-loop-func
                .then((results) => {
                    //Call Additional Apex once results are returned from this promise
                    this.helperUpdateCaseSaaDetails(results);

                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: 'Secondary Account Assignment(s) Created',
                            variant: 'success'
                        })
                    );

                    this.forceRefreshView();
                })
                .catch((error) => {
                    // eslint-disable-next-line no-console
                    console.log(JSON.stringify(error.body));
                    // display server exception in toast msg
                    const event = new ShowToastEvent({
                        title: 'Error',
                        variant: 'error',
                        message: error.body.message
                    });
                    this.dispatchEvent(event);
                });
            this.closeModal();
        }
    }

    //Helper function that recursively searches for the deepest level of an object and returns the
    //a value representing the number of levels deep the object is.
    helperFindDepth(obj) {
        if (typeof obj !== 'object' || obj === null) return 0;

        return Object.keys(obj).reduce(
            (acc, k) => Math.max(acc, 1 + this.helperFindDepth(obj[k])),
            0
        );
    }

    helperUpdateCaseSaaDetails(lstSaasIds) {
        updateCaseMassSAADetails({
            lstParamSaas: lstSaasIds,
            strCaseId: this.recordId
        })
            .then((results) => {
                // eslint-disable-next-line no-console
                console.log(results);
            })
            .catch((error) => {
                // eslint-disable-next-line no-console
                console.log(JSON.stringify(error.body));
                // display server exception in toast msg
                const event = new ShowToastEvent({
                    title: 'Error',
                    variant: 'error',
                    message: error.body.message
                });
                this.dispatchEvent(event);
            });
    }

    forceRefreshView() {
        console.log('Fire Refresh Event');
        fireEvent(this.pageRef, 'refreshfromlwc', this.name);
    }
    // START
    //@bray : 10 Nov 2022 : RRC-1980 : WO 04 | Mass add Secondary Accounts District Search for Leases
    //@bray : 10 Nov 2022 : RRC-1981 : WO 05 | Add search type for lease number or Permit number
    formatRelatedFieldName(data){
        let accountArray = [];
        for (let row of data) {
            const flattenedRow = {}
            let rowKeys = Object.keys(row); 
            rowKeys.forEach((rowKey) => {
                const singleNodeValue = row[rowKey];
                if(singleNodeValue.constructor === Object){
                    this._flatten(singleNodeValue, flattenedRow, rowKey)        
                }else{
                    flattenedRow[rowKey] = singleNodeValue;
                }
            });
            accountArray.push(flattenedRow);
        }
        //console.log(accountArray);
        return accountArray;

    }

    _flatten = (nodeValue, flattenedRow, nodeName) => {        
        let rowKeys = Object.keys(nodeValue);
        rowKeys.forEach((key) => {
            let finalKey = nodeName + '.'+ key;
            if (finalKey.indexOf('IETRS_District__r.Name') !== -1) {    
                flattenedRow['DistrictName'] = nodeValue[key];    
            }if (finalKey.indexOf('Parent.Name') !== -1) {    
                flattenedRow['ParentName'] = nodeValue[key];    
            }if (finalKey.indexOf('Parent.IETRS_Drilling_Permit_Number__c') !== -1) {    
                flattenedRow['ParentPermitNumber'] = nodeValue[key];    
            }else{
                flattenedRow[finalKey] = nodeValue[key];
            }
            
        })
    } 
    //FINISH   

    
}