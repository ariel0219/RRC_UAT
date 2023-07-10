trigger AFSExemptionTrigger on AFS_Exemption__c (before insert, before update) {

    if (Trigger.isInsert) {
        AFSExemptionTriggerHandler.beforeInsertLogic(Trigger.new);
    }
    
    if (Trigger.isUpdate) {
        AFSExemptionTriggerHandler.updateExemptionFields(Trigger.new, Trigger.oldMap);
    }

}