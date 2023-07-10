({
    doInit: function (component, helper) {


        var action1 = component.get("c.isFilesAndCorrespondingOfPS_PACDA");
        action1.setParams({
            recordID: component.get("v.recordId"),
        });

        action1.setCallback(this, function (response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                var result = response.getReturnValue();
                if (result != null && result != undefined) {
                    if (!result) {
                        var action = component.get("c.generateURL");
                        action.setParams({
                            recordID: component.get("v.recordId"),
                            strObjectType: component.get("v.sobjecttype")
                            //mainRecord: component.get('v.recordId'),
                            //parameters
                        });
                        console.log(component.get('v.recordId'));

                        action.setCallback(this, function (response) {
                            var state = response.getState(); //Checking response status
                            if (state === 'SUCCESS') {
                                var urlEventt = $A.get("e.force:navigateToURL");
                                var strUrl = response.getReturnValue();
                                console.log(strUrl);
                                urlEventt.setParams({
                                    "url": response.getReturnValue()
                                });
                                urlEventt.fire();
                                //$A.get('e.force:closeQuickAction').fire();
                            }
                            else {
                                //error handling
                            }
                        });
                        $A.enqueueAction(action);
                    } else {

                        var dateBlank;
                        var actioncheckisIETRSCorrespondenceDatebalnk = component.get("c.checkisIETRSCorrespondenceDatebalnk");
                        actioncheckisIETRSCorrespondenceDatebalnk.setParams({
                            recordID: component.get("v.recordId"),
                        });
                        debugger;
                        actioncheckisIETRSCorrespondenceDatebalnk.setCallback(this, function (response) {
                            var state = response.getState(); //Checking response status
                            if (state === 'SUCCESS') {
                                dateBlank = response.getReturnValue();
                                console.log(dateBlank);
                                if (dateBlank !== undefined) {
                                    if (!dateBlank) {
                                        var actionch = component.get("c.generateURL");
                                        actionch.setParams({
                                            recordID: component.get("v.recordId"),
                                            strObjectType: component.get("v.sobjecttype")
                                            //mainRecord: component.get('v.recordId'),
                                            //parameters
                                        });
                                        console.log(component.get('v.recordId'));

                                        actionch.setCallback(this, function (response) {
                                            var state = response.getState(); //Checking response status
                                            if (state === 'SUCCESS') {
                                                var urlEvent = $A.get("e.force:navigateToURL");
                                                var strUrl = response.getReturnValue();
                                                console.log(strUrl);
                                                urlEvent.setParams({
                                                    "url": response.getReturnValue()
                                                });
                                                urlEvent.fire();
                                                //$A.get('e.force:closeQuickAction').fire();
                                            }
                                            else {
                                                //error handling
                                            }
                                        });
                                        $A.enqueueAction(actionch);
                                    } else {

                                        var toastEvent = $A.get("e.force:showToast");
                                        toastEvent.setParams({
                                            title: 'Error',
                                            message: 'Please enter a date in the Operator Letter record before generating this document.',
                                            duration: ' 5000',
                                            key: 'info_alt',
                                            type: 'error',
                                            mode: 'pester'
                                        });
                                        toastEvent.fire();
                                        $A.get("e.force:closeQuickAction").fire();

                                    }
                                } else {
                                    var actionch1 = component.get("c.generateURL");
                                    actionch1.setParams({
                                        recordID: component.get("v.recordId"),
                                        strObjectType: component.get("v.sobjecttype")
                                        
                                        
                                    });
                                    console.log(component.get('v.recordId'));

                                    actionch1.setCallback(this, function (response) {
                                        var state = response.getState(); 
                                        if (state === 'SUCCESS') {
                                            var urlEvent = $A.get("e.force:navigateToURL");
                                            var strUrl = response.getReturnValue();
                                            console.log(strUrl);
                                            urlEvent.setParams({
                                                "url": response.getReturnValue()
                                            });
                                            urlEvent.fire();
                                            
                                        }
                                        else {
                                            
                                        }
                                    });
                                    $A.enqueueAction(actionch1);
                                }

                                debugger;
                            }
                        });
                        $A.enqueueAction(actioncheckisIETRSCorrespondenceDatebalnk);
                    }
                }
            }else if(state==='ERROR'){
                console.log(JSON.stringify(error));
            }
        });
        $A.enqueueAction(action1);



    }


})