({
    invoke : function(component, event, helper) {
        var externalURLRedirect = $A.get("e.force:navigateToURL");
        externalURLRedirect.setParams({
            "url": component.get("v.externalURL")
        });
        externalURLRedirect.fire();
    }
})