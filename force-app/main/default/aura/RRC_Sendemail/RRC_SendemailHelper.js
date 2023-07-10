({
    getUserList: function(component) {
        var action = component.get('c.sendEmail');
        action.setParams({
            RecordId: component.get('v.recordId'),
            OriginalSender: $A.get('$SObjectType.CurrentUser.Id')
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            var toastEvent = $A.get('e.force:showToast');
            if (state === 'SUCCESS') {
                //component.set("v.userList", response.getReturnValue());
                var resp = response.getReturnValue();
                if (resp === 'SUCCESS') {
                    toastEvent.setParams({
                        title: 'Success',
                        message: 'Email Sent Successfully',
                        type: 'success'
                    });
                    $A.get('e.force:refreshView').fire();
                } else {
                    toastEvent.setParams({
                        title: 'Error!',
                        message: resp,
                        type: 'error'
                    });
                }
            } else {
                var errors = response.getError();
                var errorMsg = 'Unknown error';
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        errorMsg = errors[0].message;
                    }
                }
                toastEvent.setParams({
                    title: 'Error',
                    message: errorMsg,
                    type: 'error'
                });
                console.log('Failed with state: ' + state);
            }
            component.set('v.showSpinner', false);
            toastEvent.fire();

            $A.get('e.force:closeQuickAction').fire();
        });
        $A.enqueueAction(action);
    }
});