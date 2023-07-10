({
    //Function that refreshes the page, called when the Aura Component receives a bubble up Custom Event refreshevent from the child LWC: iETRS_BrokerLWC
    forceRefreshView: function(component, event, helper) {
        console.log('Aura Event Handled');
        let refresh = $A.get('e.force:refreshView');
        if (refresh) refresh.fire();
    }
})