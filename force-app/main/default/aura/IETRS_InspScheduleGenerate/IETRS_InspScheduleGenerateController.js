({

    handleInit : function(cmp, evt, h) {
        h.checkSchedules(cmp);
    },

    cancelClick : function(cmp) {
        console.log('cancelled');
        cmp.destroy();
        $A.get('e.force:closeQuickAction').fire();
    }, 

    generateClick : function(cmp, evt, h) {
        cmp.set('v.showWarning', false);
        h.generate(cmp);
    },

})