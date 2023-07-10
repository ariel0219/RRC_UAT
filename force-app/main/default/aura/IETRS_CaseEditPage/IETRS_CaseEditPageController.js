({
    
    handleInit: function(cmp, evt, h) {
        console.log('handleInit() - edit page');
        cmp.set('v.isLoading', true);
        h.fetchSections(cmp, evt);
    },

    cancelClick : function(cmp, evt, h) {
        console.log('cancelClick()');
        h.closeTab(cmp, false, null);
    },

    handleDataLoaded : function(cmp, evt, h) {
        console.log('handleDataLoaded()');
        h.loadCustomFields(cmp, evt);
    },

    handleSubmit : function(cmp, evt, h) {
        evt.preventDefault();
        console.log('handleSubmit()');
        cmp.set('v.isLoading', true);
        window.scrollTo(top);

        let relatedCase = cmp.get('v.relatedCase'),
            relatedAcct = cmp.get('v.relatedAccount');

        let fields = evt.getParam('fields');
        console.log('fields', JSON.stringify(fields, null, 4));
        fields['ParentId'] = relatedCase;
        fields['IETRS_Primary_Account_Assignment__c'] = relatedAcct;
        console.log('fields new', JSON.stringify(fields, null, 4));

        // Basic field validation - TODO: make this more dynamic in phase 2
        if(fields['Status'] == null || fields['Status'] == '') {
            h.showToast(cmp, 'error', 'Error Saving Record', 'Missing required value in field "Status"');
            cmp.set('v.isLoading', false);
        } else if(fields['Type'] == null || fields['Type'] == '') {
            h.showToast(cmp, 'error', 'Error Saving Record', 'Missing required value in field "Case Type"');
            cmp.set('v.isLoading', false);
        } else if(fields['IETRS_Primary_Account_Assignment__c'] == null || fields['IETRS_Primary_Account_Assignment__c'] == '') {
            h.showToast(cmp, 'error', 'Error Saving Record', 'Missing required value in field "Primary Account Assignment"');
            cmp.set('v.isLoading', false);
        } else {
            // No errors, so submit the form
            cmp.find('editForm').submit(fields);
        }
    },

    handleSuccess : function(cmp, evt, h) {
        console.log('handleSuccess()');
        let recId = evt.getParam('response').id;
        
        let toastEvent = $A.get('e.force:showToast');
        toastEvent.setParams({
            'title': 'Success!',
            'message': 'The record was updated.',
            'type': 'success'
        });
        toastEvent.fire();

        h.closeTab(cmp, true, recId);
    },

    handleError : function(cmp, evt, h) {
        cmp.set('v.isLoading', false);
    },

    keycheck : function(cmp, evt) { 
        console.log('keycheck()');
        if(evt.keyCode === 13) {
            evt.preventDefault();
        }    
    },

})