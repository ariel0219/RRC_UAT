({
	doInit : function(component, event, helper) {
	 var recNumber = component.get("v.recordNumber");
     var recId = component.get("v.recordId");
     helper.getInspection(component, recId, recNumber);
     helper.getRecordName(component, recId);
     helper.getallinspections(component, recId);
	},
    handleNext : function(component, event, helper){
       var recordNumb = component.get("v.recordNumber");
       var recId = component.get("v.recordId"); 
       recordNumb++;
       helper.getInspection(component, recId, recordNumb); 
    },
    handlePrev : function(component, event, helper){
       var recordNumb = component.get("v.recordNumber");
       var recId = component.get("v.recordId"); 
       recordNumb--;
       helper.getInspection(component, recId, recordNumb); 
    }
})