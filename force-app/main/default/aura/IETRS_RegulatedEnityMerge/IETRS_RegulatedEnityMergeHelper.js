({
    getAccontRecord: function(component, recordId) {
        var action = component.get('c.getAccountRecord');
        action.setParams({
            accountId: recordId
        });
        action.setCallback(this, function(response) {
            var state = response.getState(); //Checking response status
            var result = JSON.stringify(response.getReturnValue());
            console.log('result = ' + result);
            var regulatedAccIds = [];
            var accountsLst;
            if (component.isValid() && state === 'SUCCESS') {
                var records = response.getReturnValue();
                component.set('v.accountVar', records);
                component.set('v.accountsList', records.regulatedAccounts);
                accountsLst = records.regulatedAccounts;
                console.log('===accountsLst====', accountsLst);
                for (var i = 0; i < accountsLst.length; i++) {
                    regulatedAccIds.push("'" + accountsLst[i].Id + "'");
                }
                //regulatedAccIds.push("'"+component.get('v.recordId')+"'");

                var accReIds = regulatedAccIds.join(',');
                if (accReIds != '') {
                    accReIds = '(' + accReIds + ')';
                }
                console.log('--accReIds-', accReIds);
                component.set('v.regulatedEntitiesIds', accReIds);
                /* 
                accountsLst = records.unitAccounts;
                regulatedAccIds =[];
                accReIds ='';
               
                
                for(var i=0;i<  accountsLst.length;i++)
                {
                    regulatedAccIds.push("'"+accountsLst[i].Id+"'");
                }
                accReIds = regulatedAccIds.join(',');
                if(accReIds != '')
                {
                    accReIds = '('+accReIds+')';
                }
                 component.set('v.unitsIds',accReIds);
                console.log('==accReIds===',accReIds);
                */
                component.set('v.reaccList', records.regulatedAccounts);
            }
        });
        $A.enqueueAction(action);
    },
    searchAccountModel: function(component) {
        var filterStr, recordType;
        recordType = component.get('v.recordTypName');
        if (recordType == 'Regulated Entities') {
            filterStr = " RecordType.Name = 'Unit' AND Name ";
        } else if (recordType == 'Units') {
            filterStr = " RecordType.Name = 'Organization' AND Name ";
        }
        component.set('v.filterString', filterStr);
        component.set('v.isOpen', true);
    },
    doMerge: function(component, event, sourceAccount, targetAccount, helper) {
        var note = component.find('notesid').get('v.value');
        console.log('===note==', note);
        component.set('v.isLoading', true);
        var action = component.get('c.mergeRecord');
        action.setParams({
            sourceAcc: sourceAccount,
            targetAcc: targetAccount,
            note: note || ''
        });
        action.setCallback(this, function(response) {
            var state = response.getState(); //Checking response status

            if (state === 'SUCCESS') {
                this.showSuccess(component, event, helper, response.getReturnValue());

                if (response.getReturnValue() == 'success') {
                    $A.get('e.force:closeQuickAction').fire();
                }
            } else {
                this.showSuccess(component, event, helper, response.getReturnValue());
            }
            component.set('v.isLoading', false);
        });
        $A.enqueueAction(action);
    },
    showSuccess: function(component, event, helper, msg) {
        var toastEvent = $A.get('e.force:showToast');
        console.log('-msg--' + msg);
        if (msg == 'success') {
            toastEvent.setParams({
                title: 'Success',
                message: 'Record Merged successfully',
                duration: ' 5000',
                key: 'info_alt',
                type: 'success',
                mode: 'pester'
            });
        } else {
            toastEvent.setParams({
                title: 'Error',
                message: msg,
                duration: ' 7000',
                key: 'info_alt',
                type: 'error',
                mode: 'pester'
            });
        }
        console.log('--fire toast event---');
        toastEvent.fire();
    },
    showToast: function(component, event, helper, title, type, message) {
        var toastEvent = $A.get('e.force:showToast');
        toastEvent.setParams({
            title: title,
            type: type,
            message: message
        });
        toastEvent.fire();
    }
});