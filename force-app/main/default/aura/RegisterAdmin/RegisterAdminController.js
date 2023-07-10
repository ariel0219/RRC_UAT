({
    doInit : function(component, event, helper) {
       // helper.flowhelper(component, event);
        var action= component.get("c.getPermissionSetName");
        action.setCallback(this,function(response){
            var state= response.getState();
          // alert(state);
            if(state==="SUCCESS"){
                var result =response.getReturnValue();
                component.set("v.permissionSet",result);
                //helper.flowhelper(component, event);
               
            }
        });
        $A.enqueueAction(action);
        //helper.flowhelper(component, event);
		 var action2= component.get("c.getProfileName");
        
         action2.setCallback(this,function(response){
            var state= response.getState();
          // alert(state);
            if(state==="SUCCESS"){
                var result =response.getReturnValue();
                component.set("v.profileName",result);
                helper.flowhelper(component, event);
               
            }
        });
        $A.enqueueAction(action2);
         },
    
    handleClick : function(component, event, helper){
        
        component.set('v.isOpen', true);
        var flow = component.find("flowData");
        
        var inputVariables = [
            {
                name : "EventId",
                type : "String",
                value : component.get("v.recordId")
            }
        ];
        console.log('####'+JSON.stringify(inputVariables, null, " "));
        flow.startFlow("EEM_RegistrantNewAdmin",inputVariables);
    },
    closeFlowModal : function(component, event, helper) {
        component.set("v.isOpen", false);
        $A.get("e.force:closeQuickAction").fire();
    },
    
    closeModalOnFinish : function(component, event, helper) {
        if(event.getParam('status') === "FINISHED") {
            component.set("v.isOpen", false);
            $A.get("e.force:closeQuickAction").fire();
        }}
    
    
})