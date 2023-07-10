({
	onValueselect : function(component, event, helper) {
		var primaryDisplayField = component.get("v.primaryDisplayField");
	
		var objectList = JSON.parse(JSON.stringify(component.get('v.objectList')));;
		var selectedObjectIndex = component.get('v.selectedIndex');
        console.log('--selectedObjectIndex--'+selectedObjectIndex);
		if(selectedObjectIndex != undefined) {
		    
		   // console.log('======objectList[selectedObjectIndex]', objectList[selectedObjectIndex]);
             // console.log('======oname', objectList[selectedObjectIndex][primaryDisplayField]);
			component.set('v.selectedObject',JSON.stringify(objectList[selectedObjectIndex]));
			component.set('v.selectedObjectDisplayName',objectList[selectedObjectIndex][primaryDisplayField]);
			component.set('v.value',objectList[selectedObjectIndex]);
            component.set('v.lookupId',objectList[selectedObjectIndex]['Id']);
            component.set('v.objectList',[]);
            component.set('v.enteredValue','');
			component.set('v.lookupInputFocused',false);
            var lookupSelectedEvent = component.getEvent("lookupSelected");
         // console.log('=============selected',component.get('v.selectedObject') );
            
            lookupSelectedEvent.setParams({
                "selectedObject" : component.get('v.selectedObject'),
                "uniqueLookupIdentifier" : component.get('v.uniqueLookupIdentifier'),
                "recordId":objectList[selectedObjectIndex]['Id'],
                "selectedObjectDisplayName":component.get('v.selectedObjectDisplayName'),
                "recordIdValue":component.get('v.recordIdValue')
            });
            lookupSelectedEvent.fire();
		}
	}
})