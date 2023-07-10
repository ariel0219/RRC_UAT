({
    closeQuickAction : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },
    saveHandler : function(component,event,helper){
        var comp=component.find("contactDetailComp");
        comp.handleSaveClick();
        $A.get("e.force:closeQuickAction").fire();
        let refresh = $A.get('e.force:refreshView');
        if (refresh) refresh.fire();        
    }

})