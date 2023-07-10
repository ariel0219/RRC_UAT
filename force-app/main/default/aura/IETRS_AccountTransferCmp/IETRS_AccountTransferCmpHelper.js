({

	getAccontRecord : function( component , recordId) {
		var action = component.get("c.getAccountRecord"); 
		action.setParams({
            "accountId" : recordId
		});
		action.setCallback(this, function(response) {
            var state = response.getState(); //Checking response status
            var result = JSON.stringify(response.getReturnValue());
            var resObj = JSON.parse(result);
            console.log('result = '+result);
            if (component.isValid() && state === "SUCCESS") {
                var records =  response.getReturnValue()
                component.set("v.accountVar",records);
                component.set("v.accountsList", records.unitAccounts);
                component.find("radioGrp").set("v.value","Units");
                component.set("v.recordTypName","Units");
                component.set("v.regulatedEntityCheck",true);
                component.set("v.paramTypes",records.paramTypes);
                component.set("v.regulatedAccount", resObj.regulatedAccounts);
                component.set("v.unitAccount", resObj.unitAccounts); 
            }
        });
		$A.enqueueAction(action);
	},
	searchAccountModel : function(component) {
		var filterStr,recordType;
        recordType = component.get("v.recordTypName");
        if(recordType == 'Regulated Entities') {
            filterStr = ' RecordType.Name = \'Unit\' AND Name ';
        }
        else if(recordType == 'Units'){
            filterStr = ' RecordType.Name = \'Organization\' AND Name ';
        }
        component.set("v.filterString",filterStr);
        component.set("v.isOpen", true);
	}
})