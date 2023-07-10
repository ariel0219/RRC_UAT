trigger IETRS_IPInspectorTrigger on IETRS_Insp_Inspection_Package_Inspector__c(
    after insert,
    after update,
    after delete,
    after undelete
) {
    if (Trigger.isAfter) {
        if (Trigger.isUpdate) {
            IETRS_IPInspectorTriggerHandler.handleAfterUpdate();
        } else if (Trigger.isInsert) {
            IETRS_IPInspectorTriggerHandler.handleAfterInsert();
        } else if (Trigger.isDelete) {
            IETRS_IPInspectorTriggerHandler.handleAfterDelete();
        } else if (Trigger.isUndelete) {
            IETRS_IPInspectorTriggerHandler.handleAfterUndelete();
        }
    }
}