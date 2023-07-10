({
    
    handleInit : function(cmp, evt, h) {
        h.fetchRecord(cmp); // also loads MF data
    },

    updateClick : function(cmp, evt, h) {
        console.log('updateClick()');
        if(confirm('Are you sure you want to overwrite the data in Salesforce with data from Mainframe? This cannot be undone.')) {
            cmp.set('v.isLoading', true);
            h.updateRecord(cmp);
        } else {
            cmp.set('v.isLoading', false);
        }
    },

    cancelClick : function(cmp, evt, h) {
        console.log('cancelClick()');
        $A.get("e.force:closeQuickAction").fire();
    },

})