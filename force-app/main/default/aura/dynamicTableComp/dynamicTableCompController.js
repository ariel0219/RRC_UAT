({
    handleSort: function(cmp, evt, h) {
        h.handleSort(cmp, evt);
    },
    
    downloadCsv: function(component, event, helper){
        var stockData = component.get("v.dataList");
        console.log('####stockDataHeader', JSON.parse(JSON.stringify(stockData)));
        
        var csv = helper.convertArrayOfObjectsToCSV(component,stockData);   
        if (csv == null){return;}
        
        var record;
        if(component.get("v.sObjText") === 'IETRS_Complaint__c')
            record = 'ComplaintRecord';
        if(component.get("v.sObjText") === 'IETRS_Incident__c')
            record = 'IncidentRecord';
        if(component.get("v.sObjText") === 'IETRS_Inspection_Package__c')
            record = 'InspectionPackageRecord';
        if(component.get("v.sObjText") === 'IETRS_Inspection__c')
            record = 'InspectionRecord';
        
        /*var hiddenElement = document.createElement('a');
          hiddenElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(csv);
          hiddenElement.target = '_self';
          hiddenElement.download = record+'.csv'; 
          document.body.appendChild(hiddenElement); 
    	  hiddenElement.click();
         */
        var blob = new Blob([csv]);
        if (window.navigator.msSaveOrOpenBlob) 
            window.navigator.msSaveBlob(blob, "filename.csv");
        else
        {
            var a = window.document.createElement("a");
            a.href = window.URL.createObjectURL(blob, {type: "text/csv;charset=utf-8"});
            a.download = record+'.csv';
            document.body.appendChild(a);
            a.click();  
            document.body.removeChild(a);
        }
        
        
    },
    generatePDF : function(component, event, helper){
        var sObjText=component.get('v.sObjText');
        var objectName = component.get('v.sObjectName');
        // add the start date api name if only an end date is provided
        for (let prop in objectName) {
            // ends with _E
            console.log('prop'+prop);
            if (prop.lastIndexOf('_E') === prop.length - 2) {
                // if the start date is not provided
                let startDateName = prop.slice(0, prop.lastIndexOf('_E'));
                if (!objectName[startDateName]) {
                    objectName[startDateName] = '';
                }
            }
        }
        
        var filterJSON=JSON.stringify(objectName);
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": '/apex/ITRS_Inspection_Search_PDF?sObj='+ sObjText+'&filterJSON='+filterJSON,
            "isredirect": "true"
        });
        urlEvent.fire();
    }
});