({
    doInit : function(component, event, helper) {
        var messageListener = function(eventMessage) {
            //Got a message, so remove the listener
            window.removeEventListener("message", messageListener, false);
            console.log('Message Received');
            console.log(eventMessage);
            //console.log(typeof eventMessage.data);
            //object for files
            if(eventMessage.data === 'CLOSE') { //If they clicked 'close'
                console.log('Close Message Received');
                component.set("v.message", eventMessage.data);
            } else if (typeof eventMessage.data === 'string') { //If there was an error in the file upload
                console.log('Box Upload - Error Message Received');
                if(eventMessage.data === 'Request failed with status code 401' || eventMessage.data === 'Unauthorized') {
                    console.log('401');
                    component.set("v.message", 'UNAUTHORIZED');
                } else {
                    component.set("v.message", eventMessage.data);
                }
            } else if(typeof eventMessage.data === 'object' && 'type' in eventMessage.data && eventMessage.data.type === 'file') { //If the upload was successful
                console.log('Upload Message Received');
                component.set("v.fileId", eventMessage.data.id);
                component.set("v.message", 'SUCCESS');
                helper.processUpload(component, eventMessage.data.id, component.get("v.fcRecordId"), eventMessage.data.name, eventMessage.data.size);
            }
            
            //Move to the next screen in the flow
            var navigate = component.get("v.navigateFlow");
            navigate("NEXT");
        };
        window.addEventListener("message", messageListener, false);
        //console.log('Added event listener');
    },

    vFrameLoaded : function(component, event, helper) {
        //console.log("iFrame is loaded");
        var message = component.get("v.accessToken") + "|" + component.get("v.folderId") + "|" + component.get("v.auraSourceURL");
        //console.log(message);
        var vfWindow = component.find("vFrame").getElement().contentWindow;
        vfWindow.postMessage(message, component.get("v.VFSourceURL"));
    }
})