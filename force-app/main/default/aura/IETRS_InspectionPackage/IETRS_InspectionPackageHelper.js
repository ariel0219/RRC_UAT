({
	getInspection : function(component, recId, recNumber) {
      var recNo = recNumber; 
      component.set("v.recordNumber",recNo);
      var action = component.get("c.getInpections");
        action.setParams({
            recordId : component.get("v.recordId"),
            recordNumber : recNo
        });
        action.setCallback(this, function(response){
            if (response.getState() === "SUCCESS") {
            var data = response.getReturnValue();
            component.set("v.inspectionId", data.Id);
            component.set("v.InspectionRecordType", data.RecordType.Name);
            this.getinspectionsettings(component);
        }
            else{
             component.set("v.showNext",false);   
            }});
        $A.enqueueAction(action);	
	},
        
    getRecordName : function(component, recId){
      var action = component.get("c.getRecName");
        action.setParams({
          recordId : component.get("v.recordId")  
        });  
      action.setCallback(this, function(response){
            var data = response.getReturnValue();
            component.set("v.InspkgName", data.Name);
        });
        $A.enqueueAction(action);	  
        
    },
    getallinspections : function(component, recId){
      var action = component.get("c.getallInpections");
        action.setParams({
          recordId : component.get("v.recordId") 
        });  
      action.setCallback(this, function(response){
            component.set("v.recordsize", response.getReturnValue()-1);
        });
        $A.enqueueAction(action);	  
        
    },
    getinspectionsettings : function(component){
      var action = component.get("c.getinspectionsettings");  
      action.setCallback(this, function(response){
           var allsettings = response.getReturnValue();
            if(component.get("v.InspectionRecordType") == 'PS Inspection - Distribution Systems'){
                this.setstructure(component,allsettings,'PS Inspection - Distribution Systems');
            }
            if(component.get("v.InspectionRecordType") == 'PS Inspection - Gas Transmission Systems'){
                this.setstructure(component,allsettings,'PS Inspection - Gas Transmission Systems');
            }
            if(component.get("v.InspectionRecordType") == 'PS Inspection - Hazardous Liquid Systems'){
                this.setstructure(component,allsettings,'PS Inspection - Hazardous Liquid Systems');
            }
            if(component.get("v.InspectionRecordType") == 'PS Inspection - Master Meter Systems'){
                this.setstructure(component,allsettings,'PS Inspection - Master Meter Systems');
            }
        });
        $A.enqueueAction(action);	  
        
    },
    setstructure: function(component,allsettings,recordtype){
        var fields = [];
        let desiredrecord = allsettings.find(element => element.Label == recordtype);
        fields = desiredrecord.Fields__c.split(',');
        component.set("v.Fieldlist1",fields.slice(0,fields.length/2));
        component.set("v.Fieldlist2",fields.slice(fields.length/2));
        var result;
        var relatedfields = desiredrecord.Relationship_Names__c.split(';');
        var relateddataactions = component.get("c.getrelateddata");
          relateddataactions.setParams({
          recordId : component.get("v.inspectionId"),
          recordtype : recordtype  
        });  
     	 relateddataactions.setCallback(this, function(response){
            result = response.getReturnValue();
          var finaldata = [];
          for(let i=0;i<desiredrecord.DataList__c.split(';').length;i++){
          let datalist = desiredrecord.DataList__c.split(';'); 
          let input= {};
          let data = JSON.parse(datalist[i]);
          input.columns = data.columns;
          input.Tablename = data.Tablename;
          var test = result[relatedfields[i]];
          input.data = result.hasOwnProperty(relatedfields[i]) ? result[relatedfields[i]]: null;
          finaldata.push(input);
        }
        component.set("v.RelatedlistData",finaldata);
        });
        $A.enqueueAction(relateddataactions);
    }
})