({
    processUpload : function(component, fileId, recordId, originalFileName, fileSize) {
        var action = component.get("c.processFileUpload");
        action.setParams({
            "boxFileId": fileId,
            "fcRecordId": recordId,
            "originalFileName": originalFileName,
            "fileSize": fileSize
        });
        action.setCallback(this, function(response) {
            //console.log("Made it to callback");
            //console.log(response);
            var state = response.getState();
            if(state === "SUCCESS") {
                console.log("Callback successful");
            }
        });
        $A.enqueueAction(action);
    }
})