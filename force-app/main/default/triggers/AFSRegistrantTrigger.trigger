trigger AFSRegistrantTrigger on EEM_Registrant__c (before insert, before update) {

    if (Trigger.isInsert) {
        AFSRegistrantTriggerHandler.beforeInsertLogic(Trigger.new);
    }

    if (Trigger.isUpdate) {
        AFSRegistrantTriggerHandler.updateRegistrantFields(Trigger.new, Trigger.oldMap);
    }
}