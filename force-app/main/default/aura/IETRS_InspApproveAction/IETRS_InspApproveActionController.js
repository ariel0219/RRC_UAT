({
    
    handleInit : function(cmp, evt, h) {
        var action = cmp.get('c.approve');
        action.setParams({
            'recordId'  : cmp.get('v.recordId')
        });
        action.setCallback(this, function(response){
            let state = response.getState();
            if(state === 'SUCCESS') {
                h.showToast('success', 'Approval Process Started', 'The approval process is running now. You will receive an email if there are any errors. Please wait a moment and refresh page to see updated result. This may take a moment');      
                cmp.destroy();
                $A.get('e.force:closeQuickAction').fire();
            } else {
                h.showToast('error', 'Unknown Error', 'There was an unknown error. Please refresh the page and try again.');
            }
        });
        $A.enqueueAction(action);
    }

})