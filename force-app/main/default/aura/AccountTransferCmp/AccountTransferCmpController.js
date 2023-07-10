({
        doInit : function(component, event, helper) {
             helper.getAccontRecord(component); // Calling Helper method
         },
    
        handleChange : function(component, event, helper) {
        var val = event.getSource().get("v.value");
        console.log('val',val);
        if(val = 'Regulated Entities') {
            component.set('v.regulatedEntityCheck',true);
        }
    }
})