/**
 * @author Greg Lovelidge
 * @date 7/16/2020
 *
 * @description Violation object trigger
 */
trigger IETRS_ViolationTrigger on IETRS_Violation__c(before insert, before delete, after delete, after undelete) {
    if (Trigger.isBefore) {
        if (Trigger.isInsert) {
            IETRS_ViolationTriggerHandler.handleBeforeInsert();
        } else if (Trigger.isDelete) {
            IETRS_ViolationTriggerHandler.handleBeforeDelete();
            IETRS_ViolationTriggerHandler.stopNonWorkInProgressIPDeletes(Trigger.oldMap);
        }
    }
    if (Trigger.isAfter) {
        if (Trigger.isDelete) {
            IETRS_ViolationTriggerHandler.handleAfterDelete();
            IETRS_ViolationTriggerHandler.triggerViolationCountRecalculations(Trigger.old);
        } else if (Trigger.isUndelete) {
            IETRS_ViolationTriggerHandler.handleAfterUndelete();
        }
    }
}