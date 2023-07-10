({
	flowhelper : function(component,event) {
        var permission = component.get("v.permissionSet");
       // alert(permission);
        
        var action = component.get("c.getEventStatus");
     
        action.setParams({
            "recdId": component.get("v.recordId")
        }); 
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                
                var result = response.getReturnValue();
               // alert(result);
                 var userId = $A.get("$SObjectType.CurrentUser.Id");
                if((result=='Open' && permission!='EEM_RRC_Event_Management_AFS_Admin')&&(result=='Open' && userId!='005t0000004HImVAAW')){
                    
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
                    if (window.location.href.includes("/events/s/eem-event/"))
                    {
                        flow.startFlow("EEM_RegisterConference",inputVariables);
                    }
                    else{
                        flow.startFlow("AFS_RegisterClassOrExam",inputVariables);
                    }
                    
                }
                  else if((result == 'Full' && permission=='EEM_RRC_Event_Management_AFS_Admin')||(result == 'Open' && permission=='EEM_RRC_Event_Management_AFS_Admin')||(result=='Open' && userId=='005t0000004HImVAAW')){
                    
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
                    flow.startFlow("EEM_RegisterConference",inputVariables);
                }
                
                 
              
                
                else  {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Info',
                        message: "This Event is "+ result+".  Registration is not available.",
                        duration:' 30000',
                        key: 'info_alt',
                        type: 'error',
                        mode: 'dismissible'
                    });
                    toastEvent.fire();
                    $A.get("e.force:closeQuickAction").fire();
                }
                    
                
            }else if(state=== 'ERROR'){
                console.log("ERRORs$$$$",response.getError());
            }
        });
        
        
       
        $A.enqueueAction(action);
	} 
})