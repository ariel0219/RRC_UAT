({
    getRegions : function(component, event, helper) {
        var action = component.get('c.getRegionNames');
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                var result = response.getReturnValue();
                console.log(result);
                component.set("v.Regions",result);
            }
        });
        $A.enqueueAction(action);
    },
    getCounty : function(component, event, helper) {
        var action = component.get('c.getCountyNames');
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                var result = response.getReturnValue();
                console.log(result);
                component.set("v.Countys",result);
            }
        });
        $A.enqueueAction(action);
    },
    getSystemType : function(component, event, helper) {
        var action = component.get('c.getSystemTypes');
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                var result = response.getReturnValue();
                console.log(result);
              //  component.set("v.SystemTypes",result);
                component.set("v.sTypes",result);
            }
        });
        $A.enqueueAction(action);
    }
})