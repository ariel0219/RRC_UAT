({
    
    handleInit : function(cmp, evt, h) {
        var action = cmp.get('c.unapprove');
        action.setParams({
            'recordId'  : cmp.get('v.recordId')
        });
        action.setCallback(this, function(response){
            let state = response.getState();
            if(state === 'SUCCESS') {
                h.showToast('success', 'Approval Process Started', 'The approval process is running now. You will receive an email if there are any errors.');      
                cmp.destroy();
                $A.get('e.force:closeQuickAction').fire();
            } else {
                h.showToast('error', 'Unknown Error', 'There was an unknown error. Please refresh the page and try again.');
            }
        });
        $A.enqueueAction(action);
    }

})