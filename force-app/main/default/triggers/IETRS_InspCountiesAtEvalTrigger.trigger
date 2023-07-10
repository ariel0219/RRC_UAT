trigger IETRS_InspCountiesAtEvalTrigger on IETRS_Insp_Inspection_Counties_at_Eval__c(
    after insert,
    after update,
    after delete,
    after undelete
) {
    if (Trigger.isAfter) {
        if (Trigger.isUpdate) {
            IETRS_InspCountiesAtEvalTriggerHandler.handleAfterUpdate();
        } else if (Trigger.isInsert) {
            IETRS_InspCountiesAtEvalTriggerHandler.handleAfterInsert();
        } else if (Trigger.isDelete) {
            IETRS_InspCountiesAtEvalTriggerHandler.handleAfterDelete();
        } else if (Trigger.isUndelete) {
            IETRS_InspCountiesAtEvalTriggerHandler.handleAfterUndelete();
        }
    }
}