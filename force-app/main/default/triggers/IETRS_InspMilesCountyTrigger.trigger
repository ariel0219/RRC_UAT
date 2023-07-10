trigger IETRS_InspMilesCountyTrigger on IETRS_Insp_Miles_by_County__c(
    after update,
    after insert,
    before delete,
    after delete,
    after undelete
) {
    if (Trigger.isBefore) {
        if (Trigger.isDelete) {
            IETRS_InspMilesCountyTrigHelper.createActivityForDeletedInspMile(Trigger.oldMap);
        }
    } else if (Trigger.isAfter) {
        if (Trigger.isUpdate) {
            IETRS_InspMilesCountyTrigHelper.handleAfterUpdate();
        } else if (Trigger.isInsert) {
            IETRS_InspMilesCountyTrigHelper.handleAfterInsert();
        } else if (Trigger.isDelete) {
            IETRS_InspMilesCountyTrigHelper.handleAfterDelete();
        } else if (Trigger.isUndelete) {
            IETRS_InspMilesCountyTrigHelper.handleAfterUndelete();
        }
    }

}