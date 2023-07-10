({
    doInit: function(component, event, helper) {
        component.set('v.loading', true);
        console.log(component.get('v.sectionObjects'));
        helper.onInit(component, event, helper);
    },

    doSelectChange: function(component, event, helper) {
        component.set('v.loading', true);
        component.set('v.resultList', null);
        component.set('v.hasSearched', false);
        helper.onFieldSetChange(component, event, helper);
    },
    searchClick: function(component, event, helper) {
        component.set('v.loading', true);
        component.set('v.resultList', []);
        var objectName = component.get('v.sObjectName');
        helper.onSearchData(component, event, helper);
    },
    resetClick: function(component, event, helper) {
        helper.onResetPage(component, event, helper);
    }
});