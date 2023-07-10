/**
 * @author Greg Lovelidge - Sense Corp
 * @date 6/1/2020
 *
 * @description Trigger handler class for the Inspection object.
 */
trigger IETRS_I_Inspection_Trigger on IETRS_Inspection__c(before insert, after delete) {
    if (Trigger.isBefore) {
        if (Trigger.isInsert) {
            IETRS_I_Inspection_TriggerHandler.handleBeforeInsert();
        }
    }
    if (Trigger.isAfter) {
        if (Trigger.isDelete) {
            IETRS_I_Inspection_TriggerHandler.handleAfterDelete();
        }
    }
}