({

    fetchSections : function(cmp, evt) {
        console.log('fetchSections()');

        let action = cmp.get('c.loadPageLayoutFields'),
            recordId = cmp.get('v.recordId'),
            pageRef = cmp.get('v.pageReference'),
            recordTypeId = pageRef.state.recordTypeId;

        // Send either recordId or recordTypeId
        if(recordId) {
            action.setParams(
                { 'recordId' : recordId }
            );
        } else if(recordTypeId) {
            cmp.set('v.recordTypeId', recordTypeId);
            action.setParams(
                { 'recordTypeId' : recordTypeId }
            );
        } else { 
            action.setParams(
                { 'objectName' : 'Case' }
            );
        }

        console.log('recordId', recordId);
        console.log('recordTypeId', recordTypeId);

		action.setCallback(this, function(response) {
        	let state = response.getState();
			if (state === 'SUCCESS') {
                let results = response.getReturnValue();
                cmp.set('v.layoutSections', results);
                console.log('sections', JSON.stringify(results, null, 2));
                cmp.set('v.fieldsLoaded', true);
            }
            else if (state === 'INCOMPLETE') {
            }
            else if (state === 'ERROR') {
                let errors = response.getError();
				console.log(errors);
            }
        });
        
        $A.enqueueAction(action);
    },

    loadCustomFields : function(cmp, evt) { 
        console.log('loadCustomFields()');
        let recordUi = evt.getParam('recordUi');
        //console.log('recordUi', JSON.stringify(recordUi, null, 4));
        let parentAccount = recordUi.record.fields['IETRS_Primary_Account_Assignment__c'] == undefined ? '' : recordUi.record.fields['IETRS_Primary_Account_Assignment__c'].value;
        let relatedCase = recordUi.record.fields['ParentId'] == undefined ? '' : recordUi.record.fields['ParentId'].value;
        
        // let parentAccount = recordUi.record.fields['IETRS_Primary_Account_Assignment__c'].value,
        //     relatedCase = recordUi.record.fields['ParentId'].value;

        //console.log('recordUi', JSON.stringify(recordUi, null, 4));

        cmp.set('v.relatedAccount', parentAccount);
        cmp.set('v.relatedCase', relatedCase);

        let fieldsLoaded = cmp.get('v.fieldsLoaded'),
            customFieldsLoaded = cmp.get('v.customFieldsLoaded');
        
        // Find lookup field placeholders and create components
        if(fieldsLoaded && !customFieldsLoaded) {
            console.log('loading lookup fields');
            let lookupDivs = cmp.find('lookupFieldPlaceholder') || [];
            lookupDivs.forEach(div => {
                let attributes = div.get('v.HTMLAttributes');

                console.log('attributes', JSON.stringify(attributes, null, 4));
                
                $A.createComponent(
                    'c:IETRS_LookupField',
                    {   // Set up component - convert necessary strings to boolean, get reference to field value
                        'aura:id'       : attributes['data-fieldName'],
                        'label'         : attributes['data-label'],
                        'objectName'    : attributes['data-objectName'],
                        'recordType'    : attributes['data-recordType'],
                        'allowMultiple' : (attributes['data-allowMultiple'] === 'true' || attributes['data-allowMultiple'] === true),
                        'allowImport'   : (attributes['data-allowImport'] === 'true' || attributes['data-allowImport'] === true),
                        'iconName'      : attributes['data-iconName'],
                        'required'      : (attributes['data-required'] === 'true' || attributes['data-required'] === true),
                        'value'         : cmp.getReference(attributes['data-value'])
                    },
                    function(newCmp, status, error) {
                        if(status === 'SUCCESS') {
                            let body = div.get('v.body');
                            // console.log('body', body);
                            
                            body.push(newCmp);
                            div.set('v.body', body);
                            // console.log('newCmp', newCmp);
                        } else if (status === 'INCOMPLETE') {
                            console.log('No response from server or client is offline.')
                        }
                        else if (status === 'ERROR') {
                            console.log('Error: ' + error);
                        }
                    }
                );
            });
            cmp.set('v.customFieldsLoaded', true);
        }
        cmp.set('v.isLoading', false);
    },

    closeTab : function(cmp, showNewRecord, recordId) {
        console.log('close()');
        
        let workspaceAPI = cmp.find('recordEditCustomWorkspace');
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            let focusedTabId = response.tabId;
            console.log('previous tab', focusedTabId);

            // Close tab
            workspaceAPI.closeTab({ tabId: focusedTabId });
            $A.get('e.force:refreshView').fire();

            // Open tab with new record
            if(showNewRecord) {
                workspaceAPI.openTab({
                    url: '#/sObject/' + recordId + '/view'
                }).then(function(response) {
                    console.log('new tab', response);
                    workspaceAPI.focusTab({ tabId : response });
                })
                .catch(function(error) {
                    console.log(error);
                });
            }
        })
        .catch(function(error) {
            console.log(error);
        });
    },

    showToast : function(cmp, type, title, message) {
        let toastEvent = $A.get('e.force:showToast');
        toastEvent.setParams({
            'type'    : type, 
            'title'   : title,
            'message' : message
        });
        toastEvent.fire();
    },

})