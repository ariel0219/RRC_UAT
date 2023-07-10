trigger AFSCertificationTrigger on AFS_Certification__c (before insert, before update) {

    if (Trigger.isInsert) {
        AFSCertificationTriggerHandler.beforeInsertLogic(Trigger.new);
    }
    
    if (Trigger.isUpdate) {
        AFSCertificationTriggerHandler.updateCertificationFields(Trigger.new, Trigger.oldMap);
    }

}