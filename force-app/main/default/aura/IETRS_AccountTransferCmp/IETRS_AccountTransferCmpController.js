({
    doInit: function(component, event, helper) {
        helper.getAccontRecord(component, component.get('v.recordId')); // Calling Helper method
    },
    handleChange: function(component, event, helper) {
        var val = event.getSource().get('v.value');
        console.log('val', val);
        //component.set('v.regulatedEntityCheck',true);
        var accounts = component.get('v.accountVar');
        if (val === 'Regulated Entities') {
            component.set('v.accountsList', accounts.regulatedAccounts);
            component.set('v.showColumn', false);
            component.set('v.showColumnOrg', true);
        } else if (val === 'Units') {
            component.set('v.accountsList', accounts.unitAccounts);
            component.set('v.showColumn', true);
            component.set('v.showColumnOrg', false);
        }
        component.set('v.recordTypName', val);
        component.find('selectAll').set('v.value', false);
        component.set('v.showButton', false);
    },
    closeModel: function(component, event, helper) {
        component.set('v.isOpen', false);
        component.set('v.accList', []);
        component.set('v.hasError', false);
    },
    selectAllBoxes: function(component, event) {
        var checkvalue = component.find('selectAll').get('v.value');
        var accountCheck = component.find('accountCheckBox');
        var accountsIds = component.get('v.selectedIds');
        var regionsList = component.get('v.regionsList');
        var accounts = component.get('v.accountsList');
        if (checkvalue == true) {
            for (var i = 0; i < accountCheck.length; i++) {
                accountCheck[i].set('v.value', true);
                accountsIds.push(accounts[i].Id);
                regionsList.push(accounts[i].IETRS_Region_ID__c);
            }
            component.set('v.showButton', true);
        } else {
            for (var i = 0; i < accountCheck.length; i++) {
                accountCheck[i].set('v.value', false);
                accountsIds = [];
            }
            component.set('v.showButton', false);
        }
        component.set('v.selectedIds', accountsIds);
        component.set('v.regionsList', regionsList);
    },
    handleSelectedAccounts: function(component, event, helper) {                                                     
        var regions = component.get('v.regionsList');
        var regionName = '';
        var isDiff = false;
        if(component.find('radioGrp').get('v.value') === 'Regulated Entities'){
           component.set('v.showOrgColumn', true); 
        }else{
           component.set('v.showOrgColumn', false);
        }                                                   
        for (var i = 0; i < regions.length; i++) {
            if (regionName == '') {
                regionName = regions[0];
            }
            if (regionName != regions[i]) {
                isDiff = true;
                break;
            }
        }
        if (isDiff) {
            component.set('v.continuePopup', true);
        } else {
            helper.searchAccountModel(component);
        }
    },
    searchPage: function(component, event, helper) {
        component.set('v.continuePopup', false);
        helper.searchAccountModel(component);
    },
    showData: function(component, event) {
        var accountsIds = component.get('v.selectedIds');
        var regions = component.get('v.regionsList');
        var accountId = event.currentTarget.getAttribute('data-record');
        var indexNo = event.currentTarget.getAttribute('data-index');
        var accountCheck = component.find('accountCheckBox');
        var accountRecords = component.get('v.accountsList');
        const index = accountsIds.indexOf(accountId);
        if (
            accountRecords[indexNo].Inspection_Packages__r &&
            accountRecords[indexNo].Inspection_Packages__r.length > 0 &&
            accountCheck[indexNo].get('v.value') == false
        ) {
            var toastEvent = $A.get('e.force:showToast');
            toastEvent.setParams({
                title: 'Error',
                message: "This Account Can't be transfered as it has open Inspection Package",
                duration: ' 5000',
                type: 'error'
            });
            toastEvent.fire();
            accountCheck[indexNo].set('v.value', false);
            return;
        }

        if (index > -1) {
            accountsIds.splice(index, 1);
            regions.splice(index, 1);
            accountCheck[indexNo].set('v.value', false);
        } else {
            accountsIds.push(accountId);
            regions.push(accountRecords[indexNo].IETRS_Region_ID__c);
            accountCheck[indexNo].set('v.value', true);
        }
        if (accountsIds.length > 0) {
            component.set('v.showButton', true);
        } else {
            component.set('v.showButton', false);
        }
        component.set('v.selectedIds', accountsIds);
        component.set('v.regionsList', regions);
    },
    saveModel: function(component, event) {
        component.set('v.Spinner', true);
        var NotesTxt = component.find('notesid').get('v.value');
        var action = component.get('c.transferRecord');
        action.setParams({
            mainRecord: component.get('v.recordId'),
            parentRecord: component.get('v.accountId'),
            childRecords: component.get('v.selectedIds'),
            Notes: NotesTxt,
            transType: component.get('v.recordTypName')
        });

        action.setCallback(this, function(response) {
            var state = response.getState(); //Checking response status
            if (component.isValid() && state === 'SUCCESS') {
                var responseVal = response.getReturnValue();
                // component.set("v.accountVar", responseVal);
                // component.set("v.isOpen", false);
                // component.find("selectAll").set("v.value",false);
                // component.find("radioGrp").set("v.value","Units");
                // component.set("v.accountsList", responseVal.unitAccounts);
                component.set('v.showButton', false);
                component.set('v.Spinner', false);
                if (responseVal.success) {
                    // component.set("v.regionsList",[]);
                    var toastEvent = $A.get('e.force:showToast');
                    toastEvent.setParams({
                        title: 'Success',
                        message: 'The transfer was successful.',
                        type: 'success'
                    });
                    toastEvent.fire();
                    $A.get('e.force:closeQuickAction').fire();
                } else {
                    // hide the current view and show the error
                    component.set('v.hasRecords', false);
                    component.set('v.hasError', true);
                    component.set('v.errorMessage', responseVal.error);
                    component.set('v.backButton', true);
                    if ((responseVal.openInspectionPackages || []).length > 0) {
                        component.set('v.openInspectionPackages', responseVal.openInspectionPackages);
                    }
                }
            }
        });
        $A.enqueueAction(action);
    },
    onGroup: function(component, event) {
        var selected = event.getSource().get('v.text');
        component.set('v.accountId', selected);
    },
    searchRecords: function(component, event) {
        component.set('v.Spinner', true);
        var recordTypeName = component.get('v.recordTypName');
        var searchRecordTypeName;
        if (recordTypeName == 'Units') {
            searchRecordTypeName = 'Organization';
        } else {
            searchRecordTypeName = 'Unit';
        }

        var action = component.get('c.searchAccounts');
        action.setParams({
            searchTypes: component.get('v.paramTypes'),
            recordTypeName: searchRecordTypeName
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (component.isValid() && state === 'SUCCESS') {
                console.log('result = ' + response.getReturnValue());
                component.set('v.accList', response.getReturnValue());
                component.set('v.searchedRecords', response.getReturnValue());
                component.set('v.Spinner', false);
                if (response.getReturnValue() != undefined && response.getReturnValue().length > 0) {
                    component.set('v.hasRecords', true);
                } else {
                    component.set('v.hasRecords', false);
                }
            }
        });
        $A.enqueueAction(action);
    },
    handleClose: function(component, event, helper) {
        $A.get('e.force:closeQuickAction').fire();
    },
    closeWarning: function(component) {
        component.set('v.continuePopup', false);
    },
    handleNavigateToRecordClick: function(cmp, evt) {
        evt.preventDefault();
        var navLink = cmp.find('nav');
        var recordId = evt.target.dataset.recordId;
        var pageRef = {
            type: 'standard__recordPage',
            attributes: {
                actionName: 'view',
                objectApiName: 'Account',
                recordId: recordId // change record id.
            }
        };
        navLink.navigate(pageRef, true);
    },
    
    searchKeyChange : function(component, event) {
        var regulatedRecords=new Array();
        var searchKey = component.find("searchKey").get("v.value");
        var searchRecord = component.get("v.searchedRecords");
   
            for(var i=0; i<searchRecord.length; i++){
              var record = searchRecord[i];
              regulatedRecords.push(record.Id);
            }
        
        console.log('regulatedRecords ##### '+regulatedRecords);
        var action = component.get("c.findByName");
        action.setParams({
            "searchKey": searchKey,
            "recordId" : JSON.stringify(regulatedRecords)
        });
        action.setCallback(this, function(response) {
            component.set("v.accList", response.getReturnValue());
        });
        $A.enqueueAction(action);
    },
    
    searchKeyNameChange : function(component, event, helper) {
        var AccountIds = new Array();
        var searchKey = component.find("searchName").get("v.value"); 
        if(component.get('v.recordTypName') == 'Regulated Entities'){
           var regAcct = component.get("v.regulatedAccount"); 
            for(var i=0; i<regAcct.length; i++){
                var record = regAcct[i];
                AccountIds.push(record.Id);
            }
        }else{
               var unitAcct = component.get("v.unitAccount");
               for(var i=0; i<unitAcct.length; i++){
                var record = unitAcct[i];
                AccountIds.push(record.Id);
            } 
        }
        console.log('recordType######', component.get('v.recordTypName'));
          var action = component.get("c.findAccountByName");
          action.setParams({
            "searchKey": searchKey,
            "recordIds": JSON.stringify(AccountIds)
        });
         action.setCallback(this, function(response) {
            component.set("v.accountsList", response.getReturnValue());
        });  
        
       $A.enqueueAction(action);
    },
    
   isBack : function(component, event, helper){
        component.set('v.hasRecords', true);
        component.set('v.hasError', false);
        component.set('v.backButton', false);
        $A.enqueueAction(component.get('c.searchRecords'));
   }
});