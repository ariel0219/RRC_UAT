({

    loadCustomFields : function(cmp, evt) {
        let recordUi = evt.getParam('recordUi'),
            relatedAcct = recordUi.record.fields['IETRS_Account__c'].value,
            relatedCase = recordUi.record.fields['IETRS_Case__c'].value;
        // console.log('recordUi', JSON.stringify(recordUi, null, 4));

        // Get Case Id when launched from related list "New" button
        let pageRef = cmp.get('v.pageReference');
        let state = pageRef.state;
        let base64Context = state.inContextOfRef;
        if (base64Context.startsWith('1\.')) {
            base64Context = base64Context.substring(2);
        }
        let addressableContext = JSON.parse(window.atob(base64Context));
        relatedCase = addressableContext.attributes.recordId;
        console.log('relatedCase', relatedCase);

        cmp.set('v.relatedAccount', relatedAcct);
        cmp.set('v.relatedCase', relatedCase);
        
        // Find lookup field placeholders and create components
        let fieldsLoaded = cmp.get('v.fieldsLoaded');
        if(!fieldsLoaded) {
            console.log('loading lookup fields');
            let lookupDivs = cmp.find('lookupFieldPlaceholder') || [];
            lookupDivs.forEach(div => {
                let attributes = div.get('v.HTMLAttributes');

                console.log('attributes', JSON.stringify(attributes, null, 4));
                
                $A.createComponent(
                    'c:IETRS_LookupField',
                    {   // Set up component - convert necessary strings to boolean, get ref for field value
                        'aura:id'       : attributes['data-fieldName'],
                        'label'         : attributes['data-label'],
                        'objectName'    : attributes['data-objectName'],
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
            cmp.set('v.fieldsLoaded', true);
        }

        cmp.set('v.isLoading', false);
    },

    closeTab : function(cmp) {
        console.log('close()');
        let workspaceAPI = cmp.find('recordEditCustomWorkspace');

        workspaceAPI.getFocusedTabInfo().then(function(response) {
            let focusedTabId = response.tabId;
            workspaceAPI.closeTab({ tabId: focusedTabId });
            $A.get('e.force:refreshView').fire();
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