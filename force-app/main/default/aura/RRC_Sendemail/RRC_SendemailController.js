({
    doInit : function(component, event, helper) {
        component.set("v.showSpinner",true);
        helper.getUserList(component);
    },
    
       handleClose : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire() 
    },
})