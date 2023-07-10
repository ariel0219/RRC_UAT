({
    getAccontRecord: function(component, recordId, helper) {
        var action = component.get('c.getAccount');
        action.setParams({
            accountId: recordId
        });
        action.setCallback(this, function(response) {
            var state = response.getState(); //Checking response status
            if (component.isValid() && state === 'SUCCESS') {
                var records = response.getReturnValue();
                console.log(records.hasSplitPermission);
                if (!records.hasSplitPermission) {
                    //alert('');
                    helper.showToast(
                        component,
                        null,
                        null,
                        'ERROR',
                        'error',
                        'Please contact your System or Application Administrator to perform an Account Split action.'
                    );
                    $A.get('e.force:closeQuickAction').fire();
                } else {
                    console.log('==records--', records);
                    component.set('v.accountDetails', records.objAcc);
                    component.set('v.sourceAccountId', records.objAcc.Id);
                    component.set('v.statusList', records.statusValues);
                    component.set('v.judList', records.judValues);
                    component.set('v.intStateList', records.intStateValues);
                    component.set('v.entCodeList', records.entCodeValues);

                    //component.set("v.counties", records.Miles_by_County__r);
                    var countydisplay = [];
                    var countiesRetrived = records.objAcc.Miles_by_County__r;
                    
                    if (countiesRetrived) {
                        var countRec;
                        try{
                            /*commented as a part of 16432
                             * for (var i = 0; i < countiesRetrived.length; i++) {
                                countRec = {
                                    sobjectType: 'IETRS_Insp_Miles_by_County__c',
                                    Id: countiesRetrived[i].Id,
                                    Name: countiesRetrived[i].Name,
                                    countyName: countiesRetrived[i].IETRS_County__r.Name !=null && countiesRetrived[i].IETRS_County__r.Name != undefined ? countiesRetrived[i].IETRS_County__r.Name : '' ,
                                    account: countiesRetrived[i].IETRS_Regulated_Entity__r.Name!=null &&  countiesRetrived[i].IETRS_Regulated_Entity__r.Name!= undefined?countiesRetrived[i].IETRS_Regulated_Entity__r.Name:'',
                                    IETRS_Miles__c: countiesRetrived[i].IETRS_Miles__c,
                                    IETRS_Regulated_Entity__c: countiesRetrived[i].IETRS_Regulated_Entity__c,
                                    IETRS_County__c: countiesRetrived[i].IETRS_County__c!= undefined &&  countiesRetrived[i].IETRS_County__c!= null ? countiesRetrived[i].IETRS_County__c : ''
                                };
                                countydisplay.push(countRec);
                            }*/
                        }catch(error){
                            console.error(error);
                        }

                        component.set('v.counties', countydisplay);
                    }
                }
            }
        });
        $A.enqueueAction(action);
    },

    doSplit: function(component, event, helper) {
        var note = component.find('notesid').get('v.value');
        component.set('v.isLoading', true);
        console.log('===note==', note);

        var accName = component.find('accName').get('v.value');

        if (accName == '' || accName == undefined) {
            helper.showToast(
                component,
                event,
                helper,
                'Error',
                'Error',
                'Please enter the split account name before proceed'
            );
            component.set('v.isLoading', false); // added this  becuase the Page loading and not ending
            return;
        }

          if (note == '' || note == undefined) {
            component.set('v.isLoading',false);
            helper.showToast(
                component,
                event,
                helper,
                'Error',
                'Error',
                'Please enter Event Note'
            );
            
            return;
        }
        console.log('==accName===' + accName);
        console.log('===component.get("v.countiesToDelete")==', component.get('v.countiesToDelete'));
        var countiesToUpsert = [];
        var countiesToUpDelete = [];

        var allCounties = JSON.parse(JSON.stringify(component.get('v.counties')));
        var countRec;
        for (var i = 0; i < allCounties.length; i++) {
            countRec = {
                sobjectType: 'IETRS_Insp_Miles_by_County__c',
                Id: allCounties[i].Id,
                Name: allCounties[i].Name,
                IETRS_Miles__c: allCounties[i].IETRS_Miles__c,
                IETRS_County__c: allCounties[i].IETRS_County__c
            };

            countiesToUpsert.push(countRec);
        }
        allCounties = JSON.parse(JSON.stringify(component.get('v.countiesToDelete')));

        for (var i = 0; i < allCounties.length; i++) {
            countRec = {
                sobjectType: 'IETRS_Insp_Miles_by_County__c',
                Id: allCounties[i].Id,
                Name: allCounties[i].Name,
                IETRS_Miles__c: allCounties[i].IETRS_Miles__c,
                IETRS_Regulated_Entity__c: allCounties[i].IETRS_Regulated_Entity__c
            };

            countiesToUpDelete.push(countRec);
        }

        var action = component.get('c.splitRecord');
        action.setParams({
            sourceAccId: component.get('v.accountDetails').Id,
            targetAccId: '',
            note: note,
            countiesToBeDeleted: countiesToUpDelete,
            updatedCounties: countiesToUpsert,
            accName: accName,
            accDetails: component.get('v.accountDetails'),
            oldInputMiles : component.get('v.oldInputMiles'),
            newInputMiles : component.get('v.newInputMiles')
        });
        action.setCallback(this, function(response) {
            var state = response.getState(); //Checking response status
            console.log('=========response=111=====', response.getReturnValue());
            component.set('v.isLoading', false);
            if (state === 'SUCCESS') {
               
                if (response.getReturnValue() != 'error') {
                    if (response.getReturnValue() == 'isExist')
                        helper.showToast(
                            component,
                            event,
                            helper,
                            'info',
                            'info',
                            'Account name already exist. Please enter some other name for the split Account'
                        );
                    else if (response.getReturnValue() == 'noaction')
                        helper.showToast(
                            component,
                            event,
                            helper,
                            'info',
                            'info',
                            'Please add at least one county to split...'
                        );
                    else {
                        helper.showToast(component, event, helper, 'Success', 'success', response.getReturnValue());
                        $A.get('e.force:refreshView').fire();
                        $A.get('e.force:closeQuickAction').fire();
                    }
                } else {
                    helper.showToast(component, event, helper, 'Error', 'Error', 'Split account could not be created');
                }

            } else {
                helper.showToast(component, event, helper, 'Error', 'Error', 'Split account could not be created');
            }
        });
        $A.enqueueAction(action);
    },

    showToast: function(component, event, helper, title, type, message) {
        var toastEvent = $A.get('e.force:showToast');
        toastEvent.setParams({
            title: title,
            type: type,
            message: message
        });
        toastEvent.fire();
    }
});