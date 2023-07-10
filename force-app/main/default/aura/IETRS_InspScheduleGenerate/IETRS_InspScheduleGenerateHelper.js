({
    checkSchedules: function(cmp) {
        var action = cmp.get('c.isGenerated');
        action.setParams({
            recId: cmp.get('v.recordId')
        });
        action.setCallback(this, function(response) {
            let state = response.getState();
            if (state === 'SUCCESS') {
                let result = response.getReturnValue();
                if (result === true) {
                    // if(confirm(
                    //     '-------------------- WARNING --------------------\n' +
                    //     'Schedules have already been generated!\n' +
                    //     'If you continue, all related schedules without an\n' +
                    //     'Inspection Package will be REPLACED.\n' +
                    //     'THIS CANNOT BE UNDONE.'
                    // )) {
                    //     this.generate(cmp);
                    // } else {
                    //     console.log('cancelled');
                    //     cmp.destroy();
                    //     $A.get('e.force:closeQuickAction').fire();
                    // }
                    cmp.set('v.showWarning', true);
                } else {
                    this.generate(cmp);
                }
            } else {
                this.showToast(
                    'error',
                    'Unknown Error',
                    'There was an unknown error. Please refresh the page and try again.'
                );
            }
        });
        $A.enqueueAction(action);
    },

    generate: function(cmp) {
        var action = cmp.get('c.generateSchedules');
        action.setParams({
            recId: cmp.get('v.recordId')
        });
        action.setCallback(this, function(response) {
            let state = response.getState();
            if (state === 'SUCCESS') {
                let result = response.getReturnValue();
                if (result === 'Success') {
                    this.showToast(
                        'success',
                        'Schedule Generation Started',
                        'You will receive an email when the process is complete.'
                    );
                    $A.get('e.force:refreshView').fire();
                    $A.get('e.force:closeQuickAction').fire();
                } else {
                    this.showToast('error', 'Error', result, 'sticky');
                }
            } else {
                this.showToast(
                    'error',
                    'Unknown Error',
                    'There was an unknown error. Please refresh the page and try again.'
                );
            }
        });
        $A.enqueueAction(action);
    },

    showToast: function(type, title, message, mode) {
        mode = mode === null ? 'dismissible' : mode;
        let toastEvent = $A.get('e.force:showToast');
        toastEvent.setParams({
            type: type,
            title: title,
            message: message,
            mode: mode
        });
        toastEvent.fire();
    }
});