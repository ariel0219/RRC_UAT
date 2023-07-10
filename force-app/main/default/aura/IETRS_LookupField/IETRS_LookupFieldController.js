({

    handleInit : function(cmp, evt, h) {
        let selectedIds = cmp.get('v.value');
        console.log('handleInit()', selectedIds);
        
        if(selectedIds) {
            h.fetchRecords(cmp);
        }
    },

    // Show results component on focus
    handleOnfocus : function(cmp, evt, h) {
        cmp.set('v.isLoading', true);
        let searchRes = cmp.find('searchRes');
        $A.util.addClass(searchRes, 'slds-is-open');

        let searchString = '';
        h.doSearch(cmp, searchString);
    },

    // Hide results component when mouse leaves search input
    handleOnblur : function(cmp, evt, h) {       
        cmp.set('v.results', null);
        let searchRes = cmp.find('searchRes');
        $A.util.removeClass(searchRes, 'slds-is-open');
    },
    
    // Listen for enter key in search input area
    handleKeyup : function(cmp, evt, h) {
        let searchString = cmp.get('v.search'),
            resultsCmp = cmp.find('searchRes');

        if(searchString && searchString.length > 0) {
            $A.util.addClass(resultsCmp, 'slds-is-open');
            h.doSearch(cmp, searchString);
        }
        else {  
            cmp.set('v.results', null); 
            $A.util.removeClass(resultsCmp, 'slds-is-open');
        }
    },
    
    // Remove button clicked for a selected record
    handleRemove : function(cmp, evt, h) {
        let recordName = evt.getSource().get('v.name'),
            selectedRecords = cmp.get('v.selectedRecords'),
            objectName = cmp.get('v.objectName'),
            record = {};
        
        console.log('handleRemove', recordName);

        cmp.set('v.search', null);
        cmp.set('v.results', null);

        // Get record object
        if(objectName === 'Case') {
            record = selectedRecords.find(o => o.CaseNumber === recordName);
        } else {
            record = selectedRecords.find(o => o.Name === recordName);
        }

        // Remove selected record object
        selectedRecords.splice(selectedRecords.findIndex(item => item.Id === record.Id), 1);

        cmp.set('v.selectedRecords', selectedRecords);
        cmp.set('v.search', '');
        console.log('selectedRecords', JSON.stringify(selectedRecords, null, 4));
    },
    
    // Row selected event received from child component
    handleSelect : function(cmp, evt, h) {
        let record = evt.getParam('selectedRecord'),
            selectedRecords = cmp.get('v.selectedRecords'),
            searchRes = cmp.find('searchRes');

        console.log('handleSelect()', JSON.stringify(record, null, 4));
        
        $A.util.removeClass(searchRes, 'slds-is-open');
        
        selectedRecords.push(record);
        cmp.set('v.selectedRecords', selectedRecords);
        cmp.set('v.search', '');
        console.log('selectedRecords', JSON.stringify(selectedRecords, null, 4));
    },

    // Convert selected record objects to a string of selected IDs
    handleSelectChange : function(cmp) { 
        let records = cmp.get('v.selectedRecords') || [],
            recordIds = '';

        records.forEach(rec => {
            if(recordIds != '') { 
                recordIds += ',' + rec.Id;
            } else {
                recordIds = rec.Id;
            }
        });
        cmp.set('v.value', recordIds);
    },

    // Validate the field input (TODO)
    handleValidation : function(cmp, evt, h) {
        console.log('handleValidation()');
        let params = evt.getParam('arguments');
        console.log('params', JSON.stringify(params, null, 4));
        if (params) {
            var cmp = params.cmp,
                msg = h.validate(cmp, parent);
        }
        return msg;
    },

    // Import button clicked
    handleImportClick : function(cmp, evt, h) {
        $A.createComponent(
            'c:IETRS_RecordImportModal', 
            { }, 
            function(modal, status, errorMessage) {
                if (status === 'SUCCESS') {
                    let body = cmp.find('recordImportModal').get('v.body');
                    body.push(modal);
                    cmp.find('recordImportModal').set('v.body', body);
                } else {
                    console.log(status);
                    console.log("Error: " + errorMessage);
                }
            }
        );
    },

})