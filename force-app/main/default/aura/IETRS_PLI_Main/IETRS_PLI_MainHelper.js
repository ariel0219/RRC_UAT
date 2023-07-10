({
    //To fire the flow "IETRS_I_Upload_Notification_File"
    onUploadButton: function (component, event, helper, notiId) {
        var flow = component.find("flowData");
        //Put input variable values
        var inputVariables = [
            {
                name: "varInputNotificationID",
                type: "String",
                value: notiId//component.get("v.recordId")

            }, {
                name: "blnUploadComplete",
                type: "Boolean",
                value: false
            }
        ];
        // In that component, start your flow. Reference the flow's API Name.
        flow.startFlow("IETRS_I_Upload_Notification_File", inputVariables);
    },
    onUploadButtonv2: function (component, event, helper, notiId) {
        //var flow = component.find("flowDatav2");
        var flow = component.find("flowDatav1");
        //Put input variable values
        var inputVariables = [
            {
                name: "varInputNotificationID",
                type: "String",
                value: notiId//component.get("v.recordId")
            }, {
                name: "blnUploadComplete",
                type: "Boolean",
                value: false
            }
        ];
        // In that component, start your flow. Reference the flow's API Name.
        flow.startFlow("IETRS_I_Upload_Notification_File_v1", inputVariables);
        
    },

    showPS95Status: function (component, event, helper) {
        console.log('successfully Enter showPs95 methods' + event.getParam('value'));
        if (event.getParam('value') !== 'Yes') {
            component.set("v.isdisplayPS95Status", true);
        }
        else {
            component.set("v.isdisplayPS95Status", false);
        }
        //component.set("v.notificationId", event.getParam('value'));
    },
    showdetailsNotification: function (component, event, helper) {
        console.log('Log Info: ' + event.getParam('value'));
        component.set("v.notificationId", event.getParam('value'));
        //FC: Commenting out refreshNotificationDetail because refresh is called from detail display component instead on event handled
        //component.find("detailDisplay").refreshNotificationDetailsLst();
        // component.set("v.showRepairedLeaksComponent", event.getParam('value'));
    }, closeModel: function (component, event,helper) {
        component.set("v.showRepairedSRCsearchCmp", false);
        if (component.get("v.showIMPSearchCmp")) {
            console.log('reached to imp');
            helper.handleduplicates(component,event,"IETRS_I_Upload_Notification_File","flowData");
            window.setTimeout(() => {
                component.find("impDetailsList").refreshNotificationDetailsLst();
            }, 2500);

        } else {
            console.log('reached to src');
            helper.handleduplicates(component,event,"IETRS_I_Upload_Notification_File_v1","flowDatav1");
            window.setTimeout(() => {
                component.find("srcdetailReport").refreshNotificationDetailsLst();
            }, 2500);

        }
        //$A.get('e.force:refreshView').fire();
        
    },
    handleduplicates : function(component,event,nameofFlow,cmpfind){

        var outputVariables = event.getParam("outputVariables");
        var outputVar;
        for(var i = 0; i < outputVariables.length; i++) {
           outputVar = outputVariables[i];
           console.log(outputVar);
           if(outputVar.name === "blnUploadComplete") {
            var flow = component.find(cmpfind);
            //Put input variable values
            var inputVariables = [
                {
                    name: "varInputNotificationID",
                    type: "String",
                    value: null//component.get("v.recordId")
                }, {
                    name: "blnUploadComplete",
                    type: "Boolean",
                    value: outputVar.value,
                }
            ];
            // In that component, start your flow. Reference the flow's API Name.
            flow.startFlow(nameofFlow, inputVariables);
              
           }
        }


    }
})