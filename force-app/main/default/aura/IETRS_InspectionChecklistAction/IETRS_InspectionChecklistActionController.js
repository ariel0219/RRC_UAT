({
    handleInit: function(cmp) {
        var workspaceAPI = cmp.find('workspace');
        cmp.set('v.loading', true);
        workspaceAPI
            .openTab({
                pageReference: {
                    type: 'standard__component',
                    attributes: {
                        componentName: 'c__IETRS_RelatedInspectionResultList'
                    },
                    state: {
                        c__recordId: cmp.get('v.recordId')
                    }
                },
                focus: true
            })
            .then(response => {
                workspaceAPI.setTabLabel({
                    tabId: response,
                    label: 'Inspection Checklist'
                });
                cmp.set('v.loading', false);
                $A.get('e.force:closeQuickAction').fire();
            })
            .catch(function(error) {
                console.log(error);
                cmp.set('v.loading', false);
            });
    }
});