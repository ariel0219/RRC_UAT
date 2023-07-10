({
    
    showToast : function(type, title, message, mode) {
        mode = mode === null ? 'dismissible' : mode;
        let toastEvent = $A.get('e.force:showToast');
        toastEvent.setParams({
            'type'      : type, 
            'title'     : title,
            'message'   : message,
            'mode'      : mode
        });
        toastEvent.fire();
    },
    
})