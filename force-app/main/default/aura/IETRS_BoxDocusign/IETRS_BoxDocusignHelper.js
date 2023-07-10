({

    download : function(cmp) {
        var action = cmp.get('c.downloadFile');
        action.setParams({
            'recordId' : cmp.get('v.recordId')
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS') {
                let result = response.getReturnValue();
                if(result === 'Success') {
                    console.log('download complete');
                    cmp.set('v.step', '2');
                } else { 
                    console.log('download error');
                    this.showToast(cmp, 'error', 'Server Error', result + ' Please refresh the page and try again.');
                }
            } else {
                console.log('unknown error');
                this.showToast(cmp, 'error', 'Unknown Error', 'Please refresh the page and try again.');
            }
            cmp.set('v.isLoading', false);
        });
        $A.enqueueAction(action);
    },

    send : function(cmp) {
        var action = cmp.get('c.buildURL');
        action.setParams({
            'recordId' : cmp.get('v.recordId')
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS') {
                let result = response.getReturnValue();
                if(result) {
                    console.log('docusign url: ' + result);
                    window.open(result, '_blank', 'width=1200,height=850');
                } else { 
                    console.log('unknown error');
                    this.showToast(cmp, 'error', 'Server Error', result + ' Please refresh the page and try again.');                    
                }
            } else {
                this.showToast(cmp, 'error', 'Unknown Error', 'Please refresh the page and try again.');
            }
            cmp.set('v.isLoading', false);
            $A.get('e.force:closeQuickAction').fire();
        });
        $A.enqueueAction(action);
    },

    cleanup : function(cmp) {

    },

    showToast : function(cmp, type, title, message) {
        var toastEvent = $A.get('e.force:showToast');
        toastEvent.setParams({
            'type'    : type, 
            'title'   : title,
            'message' : message
        });
        toastEvent.fire();
    },

})