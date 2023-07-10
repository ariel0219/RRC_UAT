({
    
    fetchRecord : function(cmp) {
        console.log('fetchRecord()');
        let action = cmp.get('c.loadRecord'),
            recordId = cmp.get('v.recordId'),
            objectName = cmp.get('v.sObjectName');
        
        action.setParams({
            'recordId'   : recordId,
            'objectName' : objectName
        });
        action.setCallback(this, function(response) {
            let state = response.getState();
            if(state === 'SUCCESS') {
                let result = response.getReturnValue();
                if(result && result.Id != 'ERROR') {
                    cmp.set('v.sfData', result);
                    console.log('sfData', cmp.get('v.sfData'));
                    this.fetchMfData(cmp);
                } else {
                    this.showToast(cmp, 'error', 'Error Loading Record', 'Please refresh the page to try again.');
                }
            } else {
                this.showToast(cmp, 'error', 'Server Error', 'Please refresh the page to try again.');
            }
        });
        $A.enqueueAction(action);
    },

    fetchMfData : function(cmp) {
        console.log('fetchMfData()');
        let recTypeApi = cmp.get('v.sfData.RecordType.DeveloperName'),
            acctType = cmp.get('v.sfData.Type');

        // Operators
        if(recTypeApi === 'Organization') {
            var action = cmp.get('c.loadOperatorData');
            action.setParams({
                'p5Number' : cmp.get('v.sfData.IETRS_P5_Number__c')
            });
        }
        // Leases
        else if(recTypeApi.includes('Regulated_Entity') && acctType === 'Lease') {
            var action = cmp.get('c.loadLeaseData');
            action.setParams({
                'leaseNumber'  : cmp.get('v.sfData.IETRS_Lease_Number__c'),
                'districtCode' : cmp.get('v.sfData.IETRS_District__r.Name').substr(0, 2)
            });
        }
        // Drilling Permit
        else if(recTypeApi.includes('Regulated_Entity') && acctType === 'Drilling Permit') {
            var action = cmp.get('c.loadDrillingPermitData');
            action.setParams({
                'drillingPermitNumber'  : cmp.get('v.sfData.IETRS_Drilling_Permit_Number__c')
            });
        }
        // UIC Permit
        else if(recTypeApi.includes('Regulated_Entity') && acctType === 'UIC Permit') {
            var action = cmp.get('c.loadUICPermitData');
            action.setParams({
                'apiNumber'  : cmp.get('v.sfData.IETRS_API__c'),
                'uicNumber'  : cmp.get('v.sfData.IETRS_UIC_Number__c')
            });
        }
        action.setCallback(this, function(response) {
            let state = response.getState();
            if(state === 'SUCCESS') {
                let results = response.getReturnValue();
                if(results) {
                    cmp.set('v.mfData', JSON.parse(results));
                    console.log('mfData', JSON.stringify(cmp.get('v.mfData')));
                    cmp.set('v.isLoading', false);
                } else {
                    this.showToast(cmp, 'error', 'Error Loading Mainframe Data', 'Please refresh the page to try again.');
                }
            } else {
                this.showToast(cmp, 'error', 'Server Error', 'Please refresh the page to try again.');
            }
        });
        $A.enqueueAction(action);
    },

    updateRecord : function(cmp) {
        console.log('updateRecord()');
        let recTypeApi = cmp.get('v.sfData.RecordType.DeveloperName'),
            acctType = cmp.get('v.sfData.Type'),
            sfData = cmp.get('v.sfData'),
            mfData = cmp.get('v.mfData');

        // Operators
        if(recTypeApi === 'Organization') {
            var action = cmp.get('c.updateOperator');
        }

        // Leases
        else if(recTypeApi.includes('Regulated_Entity') && acctType === 'Lease') {
            var action = cmp.get('c.updateLease');
        }

        // Drilling Permits
        else if(recTypeApi.includes('Regulated_Entity') && acctType === 'Drilling Permit') {
            var action = cmp.get('c.updateDrillingPermit');
        }

        // UIC Permits
        else if(recTypeApi.includes('Regulated_Entity') && acctType === 'UIC Permit') {
            var action = cmp.get('c.updateUICPermit');
        }

        action.setParams({
            'sfRecord' : sfData,
            'mfJSON'   : mfData ? JSON.stringify(mfData) : ''
        });
        action.setCallback(this, function(response) {
            let state = response.getState();
            if(state === 'SUCCESS') {
                let result = response.getReturnValue();
                if(result === 'Success') {
                    this.showToast(cmp, 'success', 'Record Updated', 'The record was updated successfully.');
                    $A.get('e.force:refreshView').fire();
                    $A.get('e.force:closeQuickAction').fire();
                } else {
                    this.showToast(cmp, 'error', 'Error Updating Record', 'Please refresh the page to try again.');
                }
            } else {
                this.showToast(cmp, 'error', 'Server Error', 'Please refresh the page to try again.');
            }
            cmp.set('v.isLoading', false);
        });
        $A.enqueueAction(action);
    },

    showToast : function(cmp, type, title, message) {
        let toastEvent = $A.get('e.force:showToast');
        toastEvent.setParams({
            'type'    : type, 
            'title'   : title,
            'message' : message
        });
        toastEvent.fire();
    },

})