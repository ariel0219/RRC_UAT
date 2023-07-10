({
    getValueShowFromLwc: function (component, event, helper) {
        var showHeaderCmp = event.getParam('value');

        if (typeof showHeaderCmp === 'boolean') {
            if (showHeaderCmp) {
                component.set('v.showSummaryComponent', showHeaderCmp);
                component.set('v.showRepairedLeaksComponent', showHeaderCmp);
            } else {
                component.set('v.showRepairedLeaksComponent', showHeaderCmp);
                component.set('v.showSummaryComponent', true);
            }
            //component.set("v.isdisplayPS95Status",false);

            //helper.showPS95Status(component, event, helper);
        } else {
            if (showHeaderCmp === 'Yes') {
                helper.showPS95Status(component, event, helper);
            }
        }
    },
    getValueRepairedLeaksFromLwc: function (component, event, helper) {
        var stringValue = '';
        if (
            event.getParam('value') !== undefined &&
            event.getParam('value') !== null
        ) {
            stringValue = event.getParam('value');
        }

        var downloadPath = '/IETRS_RepairedLeaksCsv?id=' + stringValue;
        var isCommunity = window.location.href.indexOf('/s/') > -1;
        var downloadUrl = isCommunity
            ? window.document.location.origin + downloadPath
            : window.document.location.origin + '/apex' + downloadPath;
        component.set('v.notificationId', stringValue);
        component.set('v.downloadUrl', downloadUrl);
        // component.set("v.isdisplayPS95Status", true);
        var notificationIns = component.get('v.notificationId');

        if (
            notificationIns != null &&
            notificationIns != undefined &&
            notificationIns != ''
        ) {
            component.set('v.showRepairedLeaksComponent', true);
            component.set('v.isdisplayPS95Status', true);
            var childComp = component.find('childStatusComponent');
            childComp.getPS95SubmittedStatus(true);
            helper.showdetailsNotification(component, event, helper);
        } else {
            component.set('v.isdisplayPS95Status', false);

            component.set('v.showRepairedLeaksComponent', false);
        }
    },
    /*showdetailsNotification : function(component,event,helper){
        component.set("v.showRepairedLeaksComponent", event.getParam('value'));
    },*/
    getValueSRCcmp: function (component, event, helper) {
        var showHeaderCmp = event.getParam('value');
        if (showHeaderCmp) {
            component.set('v.showSRCSearchCmp', showHeaderCmp);
            component.set('v.showIMPSearchCmp', false);
        } else {
            component.set('v.showSRCSearchCmp', true);
            component.set('v.showIMPSearchCmp', false);
        }
    },
    getshowReportDetailssMethod: function (component, event, helper) {
        var showHeaderCmp = event.getParam('value');
        var notiId = event.getParam('notiId');

        if (showHeaderCmp) {
            component.set('v.showRepairedSRCsearchCmp', showHeaderCmp);
            if (component.get('v.showIMPSearchCmp'))
                helper.onUploadButton(component, event, helper, notiId);
            else helper.onUploadButtonv2(component, event, helper, notiId);
        } else component.set('v.showRepairedSRCsearchCmp', showHeaderCmp);
    },
    handlerefresh: function (component, event, helper) {
        if (event.getParam('status') === 'FINISHED') {
            helper.closeModel(component, event, helper);
        }
    },
    handleImpFlow: function (component, event, helper) {
        if (event.getParam('status') === 'FINISHED') {
            helper.closeModel(component, event, helper);
        }
    },
    //Added by Ayesha for disabling the data-table
    getValueIMPcmp: function (component, event, helper) {
        var showHeaderCmp = event.getParam('value');
        if (showHeaderCmp) {
            component.set('v.showIMPSearchCmp', showHeaderCmp);
            component.set('v.showSRCSearchCmp', false);
        } else {
            component.set('v.showIMPSearchCmp', true);
            component.set('v.showSRCSearchCmp', false);
        }
    },
    /*onChangeOfSRCTab :function(component, event, helper){
    },
    onChangeOfIMPTab :function(component, event, helper){
    }*/

    //On close modal
    closeModel: function (component, event) {
        component.set('v.showRepairedSRCsearchCmp', false);
        //$A.get('e.force:refreshView').fire();
    }
});