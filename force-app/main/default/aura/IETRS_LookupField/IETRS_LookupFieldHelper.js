({

    // Get details for selected records from parent
    fetchRecords : function(cmp) {
        console.log('fetchRecords()');
        
        let action = cmp.get('c.loadRecordDetails'),
            recordIds = cmp.get('v.value');

        action.setParams({
            'recordIds' : recordIds
        });
        action.setCallback(this, function(response) {
            let state = response.getState();
            if(state === 'SUCCESS') {
                let result = response.getReturnValue();
                console.log('result', result);
                cmp.set('v.selectedRecords', result);
            } else {
                console.log('state: ' + state);
            }
            cmp.set('v.isLoading', false);
        });
        $A.enqueueAction(action);
    },
    
    // Search for records as the user types
    doSearch : function(cmp, searchString) {      
        let action = cmp.get('c.searchSObject'),
            recordType = cmp.get('v.recordType');

        action.setParams({
            'searchString'  : searchString,
            'objectName'    : cmp.get('v.objectName'),
            'recordType'    : recordType ? recordType : '',
            'excludeItems'  : cmp.get('v.selectedRecords')
        });
        action.setCallback(this, function(response) {
            let state = response.getState();
            if(state === 'SUCCESS') {
                let result = response.getReturnValue();
            
                if (result && result.length == 0) {
                    console.log('no results');
                    cmp.set('v.message', 'No records found.');
                } else if(result) {
                    console.log('results: ' + JSON.stringify(result, null, 2));
                    cmp.set('v.message', '');
                } else {
                    console.log('state', state);
                }
                cmp.set('v.results', result);
            } else {
                console.log('state', state);
            }
            cmp.set('v.isLoading', false);
        });
        $A.enqueueAction(action);
    },

    // Validate input
    validate : function(cmp) {
        console.log('validate()');
        
    },

})