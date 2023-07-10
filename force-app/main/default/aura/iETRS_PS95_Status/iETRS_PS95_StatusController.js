({
    doInit: function (component, event, helper) {
        var notificationId = component.get("v.currentNotificationId");
        console.log('****NotificationId****' + notificationId);

        var action = component.get("c.getSubmittedValueByNotificationId");
        action.setParams({
            "notificationId": notificationId
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var isSubmitted = response.getReturnValue();
                if (isSubmitted) {
                    component.set("v.SubmitionStatus", true);
                } else {
                    component.set("v.SubmitionStatus", false);
                }
            }
        });
        $A.enqueueAction(action);


        var action1 = component.get("c.getPS95AccessCheckForProfile");
        action1.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                if (response.getReturnValue() === true) {
                    component.set("v.isdisplayPS95Status", true);
                }
            }
        });
        $A.enqueueAction(action1);

    }, showStatusonTrue: function (component, event, helper) {
        var params = event.getParam("arguments");
        var notificationId = component.get("v.currentNotificationId");
        console.log('CurrentNotificationId' + notificationId);
        var param1 = false;
        if (params) {
            param1 = params.onshowPS95Staus;
        }
        console.log('param1' + param1);
        console.log(notificationId);
        if (notificationId !== null && notificationId!="" && notificationId!= undefined) {
            if (param1 === true) {
                var action = component.get("c.getSubmittedValueByNotificationId");
                action.setParams({
                    "notificationId": notificationId
                });
                action.setCallback(this, function (response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        var isSubmitted = response.getReturnValue();
                        if (isSubmitted) {
                            component.set("v.SubmitionStatus", true);
                        } else {
                            component.set("v.SubmitionStatus", false);
                        }
                    }
                });
                $A.enqueueAction(action);
            }
        }else{
            component.set("v.SubmitionStatus", false);
        }
    }
    , onSubmit: function (component, event, helper) {
        //component.set("v.isdisabled", true);
       
        var notificationId = component.get("v.currentNotificationId");
        var action = component.get("c.onSubmitPS95UpdateStatusYes");
        console.log('NotificationId*****' + notificationId);
        if (notificationId !== null && notificationId != '') {
            action.setParams({
                "notificationId": notificationId
            });
            action.setCallback(this, function (response) {
                var state = response.getState();
                console.log('*****'+state);
                console.log('**'+response.getReturnValue());
                if (state === "SUCCESS") {
                    if(response.getReturnValue()==true){
                    component.set("v.SubmitionStatus", true);
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title: 'Success',
                        message: 'Submitted Successfully !!',
                        duration: ' 5000',
                        key: 'info_alt',
                        type: 'success',
                        mode: 'pester'
                    });
                    toastEvent.fire();
                }else{
                    component.set("v.SubmitionStatus", false);
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title: 'Error!',
                        message: 'Your user does not belong to the Organization listed on the PS-95 record(s). Your user cannot create or delete the record.',
                        duration: ' 5000',
                        key: 'info_alt',
                        type: 'error',
                        mode: 'pester'
                    });
                    toastEvent.fire();
                }
            }
            });
            $A.enqueueAction(action);
        } else {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title: 'Error',
                message: 'Oops!! there is no Notification Record Exist ',
                duration: ' 5000',
                key: 'info_alt',
                type: 'error',
                mode: 'pester'
            });
            toastEvent.fire();
        }


    }
})