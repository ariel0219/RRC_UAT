trigger IETRS_InspectionPkgTrigger on IETRS_Inspection_Package__c(
    before insert,
    before delete,
    after insert,
    after update
) {
    if (Trigger.isBefore) {
        if (Trigger.isInsert) {
            IETRS_InspectionPkgTrigHelper.handleBeforeInsert();
        }
        if (Trigger.isDelete) {
            IETRS_InspectionPkgTrigHelper.createActivityForDeletedInspPkg(Trigger.oldMap);
        }
    } else if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            IETRS_InspectionPkgTrigHelper.handleAfterInsert();
        } else if (Trigger.isUpdate) {
            IETRS_InspectionPkgTrigHelper.handleAfterUpdate();
        }
    }

}