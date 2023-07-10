({
    doInit : function(component, event, helper) {
        component.set('v.columns', [
            {label: 'ViolationID', fieldName: 'Name', type: 'text'},
            {label: 'Regulated Entity', fieldName: 'IETRS_Regulated_Entity__c', type: 'text'},
            {label: 'State', fieldName: 'IETRS_State__c', type: 'text'},
            {label: 'Status', fieldName: 'IETRS_Status__c', type: 'text'},
            {label: 'Enforcement Requested', fieldName: 'IETRS_EnforcementRequested__c', type: 'text'},
            {label: 'Action', type: 'button', initialWidth: 135, typeAttributes: { label: 'View Details', name: 'view_details', title: 'Click to View Details'}}
        ]);
        
        component.set('v.POCcolumns', [
            {label: 'Name', fieldName: 'linkName', type: 'url',typeAttributes: {label: { fieldName: 'Name' }, target: '_blank'}},
            {label: 'Status', fieldName: 'IETRS_POC_Status__c', type: 'text'},
            {label: 'Estimated Completion Date', fieldName: 'IETRS_Est_Completion_Date__c', type: 'text'},
            {label: 'Completion Date', fieldName: 'IETRS_Completion_Date__c', type: 'text'},
        ]);
        
        var action1 = component.get("c.getstatus");
        var action2 = component.get("c.getViolations");
        action1.setParams({
            recordId : component.get("v.recordId")
        });
        action2.setParams({
            recordId : component.get("v.recordId")
        });
        action1.setCallback(this, function(response){
            if (response.getState() === "SUCCESS") {
                var status = response.getReturnValue();
                component.set("v.show", (status == 'Waiting for POC' || status == 'POC Waiting for Approval' || 
            							 status == 'POC Rejected' || status == 'POC Ext Waiting for Approval' || 
            							 status == 'POC Ext Approved' || status == 'POC Ext Denied') ? true : false);
            }
        });
        action2.setCallback(this, function(response){
            if (response.getState() === "SUCCESS") {
                 var rows = response.getReturnValue();
                
                for (var i = 0; i < rows.length; i++) {
                    var row = rows[i];
                    if (row.IETRS_Regulated_Entity__r) {
                        row.IETRS_Regulated_Entity__c = row.IETRS_Regulated_Entity__r.Name;
                    }
                    row.IETRS_EnforcementRequested__c = row.IETRS_EnforcementRequested__c ? 'Yes':'No';
                }
                component.set("v.data", rows);
            }
        });
        $A.enqueueAction(action1);
        $A.enqueueAction(action2);
    },
    handlePOCs : function(component, event, helper) {
        var selectedrecords = component.find("datatable").getSelectedRows();
        var estcompdate = component.get("v.estcompdate");
        var compdate = component.get("v.compdate");
        var insppkgid = component.get("v.recordId");
        var recordids = [];
        for(let i=0;i<selectedrecords.length;i++){
            console.log(JSON.stringify(selectedrecords[i]));
            recordids.push(selectedrecords[i].Id);
        }
        if(recordids.length > 0){
          var actionpoc = component.get("c.checkPOCValidation");
            actionpoc.setParams({
                records : JSON.stringify(recordids) 
          });   
          actionpoc.setCallback(this, function(response){
              var toastEvent = $A.get("e.force:showToast");
              if (response.getReturnValue() == true) {
                    toastEvent.setParams({
                        "title": "ERROR!",
                        "message": "Cannot add POC 'Approved or Pending Approval' POC already exist.",
                        "type": "error", 
                        "duration": "8000"
                    });
              }else{
                  //console.log('Resposne####', response.getReturnValue());
                  var action3 = component.get("c.createPOCs");
            action3.setParams({
                records : recordids,
                estimatedcompletiondate : estcompdate,
                completiondate : compdate,
                InspectionPackageId : insppkgid
            });
            action3.setCallback(this, function(response){
                var toastEvent = $A.get("e.force:showToast");
                if (response.getState() === "SUCCESS") {
                    toastEvent.setParams({
                        "title": "Success!",
                        "message": "The records has been Created successfully.",
                        "type": "success"
                    });
                }
                else{
                    let errors = response.getError();
                    let message = 'Unknown error'; // Default error message
                    if (errors && Array.isArray(errors) && errors.length > 0) {
                        message=response.getError()[0].pageErrors[0].message;
                    }
                    toastEvent.setParams({
                        "title": "ERROR!",
                        "message": message,
                        "type": "error"
                    });    
                }
                toastEvent.fire(); 
                $A.get("e.force:closeQuickAction").fire();
            });
            $A.enqueueAction(action3);    
              }
              toastEvent.fire();  
            });
          $A.enqueueAction(actionpoc);      
        }   
    },
        
    handleCancel : function(component, event, helper) {
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
    },
        
    closeModel: function(component, event, helper) {
        // Set isModalOpen attribute to false  
        component.set("v.isModalOpen", false);
    },
        
    handleRowAction: function (component, event, helper) {
        var action = event.getParam('action');
        var row = event.getParam('row');
        component.set("v.isModalOpen", true);
        if(action.name === 'view_details') {
            var pocdataAction = component.get("c.getpocrecordsperviolation");
            pocdataAction.setParams({
                recordId : row.Id
            });
            pocdataAction.setCallback(this, function(response){
                if (response.getState() === "SUCCESS") {
                    var records =response.getReturnValue();
                    records.forEach(function(record){
                        record.linkName = '/'+record.Id;
                        });
                    component.set("v.POCdata", records);
                }
            });
            $A.enqueueAction(pocdataAction);
        }
    },
    handleUpdatePOCs : function(component, event, helper) {
        let selectedrecords = component.find("datatable").getSelectedRows();
        let estcompdate = component.get("v.estcompdate");
        let compdate = component.get("v.compdate");
        let recordids = [];
        for(let i=0;i<selectedrecords.length;i++){
            console.log(JSON.stringify(selectedrecords[i]));
            recordids.push(selectedrecords[i].Id);
        }
        if(recordids.length > 0){
            let action4 = component.get("c.updatePOCs");
            action4.setParams({
                records : recordids,
                estimatedcompletiondate : estcompdate,
                completiondate : compdate
            });
            action4.setCallback(this, function(response){
                let toastEvent = $A.get("e.force:showToast");
                if (response.getState() === "SUCCESS") {
                    toastEvent.setParams({
                        "title": "Success!",
                        "message": "The records has been Updated successfully.",
                        "type": "success"
                    });
           //         $A.get('e.force:refreshView').fire();
                    var dismissActionPanel = $A.get("e.force:closeQuickAction");
       				dismissActionPanel.fire();
                }
                else{
                    let errors = response.getError();
                    let message = 'Unknown error'; // Default error message
                    if (errors && Array.isArray(errors) && errors.length > 0) {
                        message=response.getError()[0].pageErrors[0].message;
                    }
                    toastEvent.setParams({
                        "title": "ERROR!",
                        "message": message,
                        "type": "error"
                    });    
                }
                toastEvent.fire(); 
            });
            $A.enqueueAction(action4);
        }
    }
})