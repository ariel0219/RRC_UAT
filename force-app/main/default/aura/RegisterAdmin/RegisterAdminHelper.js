({
	flowhelper : function(component,event) {
        var permission = component.get("v.permissionSet");
        var profile=component.get("v.profileName");
       // alert(permission);
        //alert(profile);
        
        var action = component.get("c.getEventStatus");
     
        action.setParams({
            "recdId": component.get("v.recordId")
        }); 
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                
                var result = response.getReturnValue();
               // alert(result);
                 

                   if((result == 'Full' && permission=='EEM_RRC_Event_Management_AFS_Admin')||(result == 'Open' && permission=='EEM_RRC_Event_Management_AFS_Admin')||(result == 'Closed For Registration' && permission=='EEM_RRC_Event_Management_AFS_Admin')||(result=='Open' && profile=='System Administrator')||(result == 'Full' && permission=='EEM_RRC_Events_Management_COP_Admin')||(result == 'Closed For Registration' && permission=='EEM_RRC_Events_Management_COP_Admin')||(result == 'Open' && permission=='EEM_RRC_Events_Management_COP_Admin')||(result=='Full' && profile=='System Administrator')||(result=='Closed For Registration' && profile=='System Administrator')){
                    
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
                }
                
                   else if((result == 'Open' && permission!='EEM_RRC_Event_Management_AFS_Admin')||(result=='Open' && profile!='System Administrator')||(result == 'Open' && permission!='EEM_RRC_Events_Management_COP_Admin')){

                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Info',
                        message: "You are not authorised to register for Events.",
                        duration:' 30000',
                        key: 'info_alt',
                        type: 'error',
                        mode: 'dismissible'
                    });
                    toastEvent.fire();
                    $A.get("e.force:closeQuickAction").fire();
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