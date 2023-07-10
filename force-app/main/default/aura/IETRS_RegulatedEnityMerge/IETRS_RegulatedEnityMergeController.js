({
    doInit: function(component, event, helper) {
        console.log('=======inside=====');
        helper.getAccontRecord(component, component.get('v.recordId')); // Calling Helper method
        component.set('v.isFirstPage', true);

        console.log('=======inside=====', component.get('v.isFirstPage'));
    },

    showFlag: function(component, event, helper) {
        console.log('============');
        component.set('v.isSecondPage', true);
        component.set('v.isFirstPage', false);
        component.set('v.isThirdPage', false);
        
        var sourceAccount = JSON.parse(JSON.stringify(component.get('v.selectedSourceRegulatedEntity')));
        var targetAccount = JSON.parse(JSON.stringify(component.get('v.selectedTargetRegulatedEntity')));        
        
        console.log('SourceAccount'+sourceAccount);
        console.log('targetAccount'+targetAccount);
    },
    backFlag: function(component, event, helper) {
        console.log('============');
        component.set('v.isFirstPage', true);
        component.set('v.isSecondPage', false);
        component.set('v.isThirdPage', false);
    },
    backFlagSecond: function(component, event, helper) {
        console.log('============');
        component.set('v.isFirstPage', false);
        component.set('v.isSecondPage', true);
        component.set('v.isThirdPage', false);
    },
    continueFlag: function(component, event, helper) {
        console.log('======inside==continue====');
        component.set('v.isFirstPage', false);
        component.set('v.isSecondPage', false);
        component.set('v.isThirdPage', true);
        var sourceAccount = JSON.parse(JSON.stringify(component.get('v.selectedSourceRegulatedEntity')));
        var targetAccount = JSON.parse(JSON.stringify(component.get('v.selectedTargetRegulatedEntity')));
		console.log('sourceAccount**** '+JSON.stringify(sourceAccount));
        console.log('targetAccount**** '+targetAccount.Id);
        
        if (sourceAccount == null || sourceAccount.Id == null || sourceAccount.Id == undefined) {
            helper.showToast(component, event, helper, 'Error', 'Error', 'Please select a source account to proceed');
            //console.log('--inside merge-1111--');
            return;
        }
        if (targetAccount == null || targetAccount.Id == null || targetAccount.Id == undefined) {
            helper.showToast(component, event, helper, 'Error', 'Error', 'Please select a target account to proceed');
            // console.log('--inside merge-1111--');
            return;
        }

        // console.log('--sourceAccount.Inspections__r-'+sourceAccount.Inspections__r.length);

        if (sourceAccount.Inspections__r != undefined) {
            //console.log('--sourceAccount.Inspections__r1111-'+sourceAccount.Inspections__r.length);
            component.set('v.totalInspec', sourceAccount.Inspections__r.length);
        }
        console.log('--targetAccount.IETRS_Total_Miles__c-' + targetAccount.IETRS_Total_Miles__c);
        console.log('--sourceAccount.IETRS_Total_Miles__c-' + sourceAccount.IETRS_Total_Miles__c);

        if (sourceAccount.IETRS_Total_Miles__c == undefined) sourceAccount.IETRS_Total_Miles__c = 0;
        if (targetAccount.IETRS_Total_Miles__c == undefined) targetAccount.IETRS_Total_Miles__c = 0;

        var totalMiles = Number(sourceAccount.IETRS_Total_Miles__c) + Number(targetAccount.IETRS_Total_Miles__c);

        console.log('--totalMiles---' + totalMiles);
        component.set('v.totalMiles', totalMiles);
    },
    getSelectedsourceRegRecord: function(component, event, helper) {
        var recordSelected = event.getParam('recordId');
        var SelectedObj = event.getParam('selectedObject');
        var conId = event.getParam('recordIdValue');

        SelectedObj = JSON.parse(SelectedObj);

        if (SelectedObj != undefined) {
            component.set('v.selectedSourceRegulatedEntity', SelectedObj);
        }

        var counties = 0;
        if (SelectedObj.Miles_by_County__r != undefined) {
            counties = SelectedObj.Miles_by_County__r.length;
        }
        component.set('v.countiNumber', counties);

        console.log('---SelectedObj---', SelectedObj);
        console.log('--miles-SelectedObj', SelectedObj.Miles_by_County__r);
        //console.log('---SelectedObj---',SelectedObj.Parent.IETRS_Unit_ID__c);
        console.log('---SelectedObj---' + SelectedObj['Id']);
        component.set('v.selectedSourceRegulatedEntity', SelectedObj);
        if (SelectedObj.Parent != undefined) component.set('v.sourceUnit', SelectedObj.Parent.IETRS_Unit_ID__c);
    },
    getSelectedsourceUnitRecord: function(component, event, helper) {
        var recordSelected = event.getParam('recordId');
        var SelectedObj = event.getParam('selectedObject');
        var conId = event.getParam('recordIdValue');

        SelectedObj = JSON.parse(SelectedObj);
        component.set('v.selectedSourceUnitRegulatedEntity', SelectedObj);
        console.log('---SelectedObj---', SelectedObj);
        //console.log('---SelectedObj',SelectedObj.Parent);
        //console.log('---SelectedObj---',SelectedObj.Parent.IETRS_Unit_ID__c);
        console.log('---SelectedObj---' + SelectedObj['Id']);
        if (SelectedObj.Parent != undefined) {
            component.set('v.sourceUnit', SelectedObj.Parent.IETRS_Unit_ID__c);
            component.set('v.selectedSourceUnitRegulatedEntity', SelectedObj);
        }
    },
    getSelectedtargetRegRecord: function(component, event, helper) {
        var recordSelected = event.getParam('recordId');
        var SelectedObj = event.getParam('selectedObject');
        var conId = event.getParam('recordIdValue');

        SelectedObj = JSON.parse(SelectedObj);
        console.log('---SelectedObj---', SelectedObj);
        //console.log('---SelectedObj',SelectedObj.Parent);
        //console.log('---SelectedObj---',SelectedObj.Parent.IETRS_Unit_ID__c);
        console.log('---SelectedObj---' + SelectedObj['Id']);
        component.set('v.selectedTargetRegulatedEntity', SelectedObj);
        if (SelectedObj.Parent != undefined) component.set('v.targetUnit', SelectedObj.Parent.IETRS_Unit_ID__c);
    },
    getSelectedtargetUnitRecord: function(component, event, helper) {
        var recordSelected = event.getParam('recordId');
        var SelectedObj = event.getParam('selectedObject');
        var conId = event.getParam('recordIdValue');

        SelectedObj = JSON.parse(SelectedObj);
        console.log('---SelectedObj---', SelectedObj);
        //console.log('---SelectedObj',SelectedObj.Parent);
        //console.log('---SelectedObj---',SelectedObj.Parent.IETRS_Unit_ID__c);
        console.log('---SelectedObj---' + SelectedObj['Id']);
        component.set('v.selectedTargetUnitRegulatedEntity', SelectedObj);
        if (SelectedObj.Parent != undefined) component.set('v.targetUnit', SelectedObj.Parent.IETRS_Unit_ID__c);
    },
    setSelectedContact: function(component, event, helper) {
        var con = JSON.parse(event.getParam('selectedObject'));
        var recordId = event.getParam('recordIdValue');
        var conId = con['Id'];
        console.log('-----heer remove', recordId);
        console.log('-----heer remove', con.Id);
        console.log('-----heer remove', con);
    },
    handleChange: function(component, event, helper) {
        var val = event.getSource().get('v.value');
        console.log('val', val);
        //component.set('v.regulatedEntityCheck',true);
        var accounts = component.get('v.accountVar');
        if (val === 'Regulated Entities') {
            component.set('v.accountsList', accounts.regulatedAccounts);
        } else if (val === 'Units') {
            component.set('v.accountsList', accounts.unitAccounts);
        }
        component.set('v.recordTypName', val);
        component.find('selectAll').set('v.value', false);
        component.set('v.showButton', false);
    },

    continue: function(component) {},

    doMerge: function(component, event, helper) {
        //Validation message before merge
        var sourceAccount = JSON.parse(JSON.stringify(component.get('v.selectedSourceRegulatedEntity')));
        var targetAccount = JSON.parse(JSON.stringify(component.get('v.selectedTargetRegulatedEntity')));

        console.log('--sourceAccount-', sourceAccount);
        console.log('--targetAccount-', targetAccount);
        console.log('--inside merge---', sourceAccount.Parent);
        console.log('--inside merge-1111--', sourceAccount.Parent.IETRS_Unit_ID__c);

        if (sourceAccount == null || sourceAccount.Id == null || sourceAccount.Id == undefined) {
            helper.showToast(component, event, helper, 'Error', 'Error', 'Please select a source account to proceed');
            //console.log('--inside merge-1111--');
            return;
        }
        if (targetAccount == null || targetAccount.Id == null || targetAccount.Id == undefined) {
            helper.showToast(component, event, helper, 'Error', 'Error', 'Please select a target account to proceed');
            // console.log('--inside merge-1111--');
            return;
        }

        if (sourceAccount.Parent.IETRS_Unit_ID__c != targetAccount.Parent.IETRS_Unit_ID__c) {
            helper.showToast(
                component,
                event,
                helper,
                'Error',
                'Error',
                'Please select a target entity with the same unit'
            );
            console.log('--inside merge-1111--');
            return;
        }
        if (sourceAccount.IETRS_Entity_Code__c != targetAccount.IETRS_Entity_Code__c) {
            helper.showToast(
                component,
                event,
                helper,
                'Error',
                'Error',
                'Please select a target entity with the same system code'
            );
            console.log('--inside merge-2222--');
            return;
        }
        if (sourceAccount.IETRS_Status__c != targetAccount.IETRS_Status__c) {
            console.log('--inside merge-3333--');
            helper.showToast(
                component,
                event,
                helper,
                'Error',
                'Error',
                'Please select a target entity with the same status'
            );
            return;
        }
        if (sourceAccount.IETRS_Jurisdiction__c != targetAccount.IETRS_Jurisdiction__c) {
            console.log('--inside merge-4444--');
            helper.showToast(
                component,
                event,
                helper,
                'Error',
                'Error',
                'Please select a target entity with the same Jurisdiction'
            );
            return;
        }
        if (sourceAccount.IETRS_T4_Permit__c != targetAccount.IETRS_T4_Permit__c) {
            console.log('--inside merge-5555--');
            helper.showToast(
                component,
                event,
                helper,
                'Error',
                'Error',
                'Please select a target entity with the T4 permit number'
            );
            return;
        }
        var issourcepkvalidate = false;
        var istargetvalidate = false;
        //checking inspection package for source
        if (sourceAccount.Inspections__r != undefined && sourceAccount.Inspections__r.length > 0) {
            for (var i; i < sourceAccount.Inspections__r.length; i++) {
                if (
                    sourceAccount.Inspections__r[0].IETRS_Inspection_Package__r.IETRS_Status__c == 'Initial' ||
                    sourceAccount.Inspections__r[0].IETRS_Inspection_Package__r.IETRS_Status__c == 'System Changes'
                ) {
                    issourcepkvalidate = true;
                    break;
                }
            }
        }
        //Checking inspection package for target
        if (targetAccount.Inspections__r != undefined && targetAccount.Inspections__r.length > 0) {
            for (var i; i < targetAccount.Inspections__r.length; i++) {
                if (
                    targetAccount.Inspections__r[0].IETRS_Inspection_Package__r.IETRS_Status__c == 'Initial' ||
                    targetAccount.Inspections__r[0].IETRS_Inspection_Package__r.IETRS_Status__c == 'System Changes'
                ) {
                    istargetvalidate = true;
                    break;
                }
            }
        }

        console.log('--inside merge6665--' + issourcepkvalidate);
        console.log('--inside merg77-' + istargetvalidate);

        if (issourcepkvalidate != istargetvalidate) {
            helper.showToast(
                component,
                event,
                helper,
                'Error',
                'Error',
                'The source or target regulated entity related inspection package is not associatedwith an Inspection package with initial or system change status'
            );
            return;
        }

        helper.doMerge(component, event, sourceAccount, targetAccount, helper);
    }    
        
});