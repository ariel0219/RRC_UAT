trigger AFSContactTrigger on Contact ( before insert, before update) {

    if (Trigger.isInsert) {
        AFSContactTriggerHandler.beforeInsertLogic(Trigger.new);
    }
    
    if (Trigger.isUpdate) {
        AFSContactTriggerHandler.updateContactFields(Trigger.new, Trigger.oldMap);
        //AFSContactTriggerHandler.updateRegistrantFields(Trigger.new, Trigger.oldMap);
    }

}