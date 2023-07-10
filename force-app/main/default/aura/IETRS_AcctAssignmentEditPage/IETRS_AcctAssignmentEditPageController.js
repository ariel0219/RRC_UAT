({

    handleInit : function(cmp, evt, h) {
        console.log('handleInit()', cmp.get('v.recordId'));
    },

    handleDataLoaded : function(cmp, evt, h) {
        console.log('handleDataLoaded()');
        h.loadCustomFields(cmp, evt);
    },

    handleSubmit : function(cmp, evt, h) {
        evt.preventDefault();
        console.log('handleSubmit()');
        cmp.set('v.isLoading', true);

        let relatedCase = cmp.get('v.relatedCase'),
            relatedAcct = cmp.get('v.relatedAccount');

        let fields = evt.getParam('fields');
        console.log('fields', JSON.stringify(fields, null, 4));
        fields['IETRS_Case__c'] = relatedCase;
        fields['IETRS_Account__c'] = relatedAcct;
        // fields['RecordTypeId'] = cmp.get('v.recordTypeId');
        console.log('fields new', JSON.stringify(fields, null, 4));
        cmp.find('editForm').submit(fields);
    },

    handleSuccess : function(cmp, evt, h) {
        console.log('handleSuccess()');
        let toastEvent = $A.get('e.force:showToast');
        toastEvent.setParams({
            'title': 'Success!',
            'message': 'The record was updated.',
            'type': 'success'
        });
        toastEvent.fire();
        
        h.closeTab(cmp);
    },

    handleError : function(cmp, evt, h) {
        cmp.set('v.isLoading', false);
    },

    cancelClick : function(cmp, evt, h) {
        console.log('cancelClick()');
        h.closeTab(cmp);
    },

})