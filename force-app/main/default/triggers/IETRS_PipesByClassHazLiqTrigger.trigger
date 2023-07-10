trigger IETRS_PipesByClassHazLiqTrigger on IETRS_Pipes_by_Class_Haz_Liq__c(
    after insert,
    after update,
    after delete,
    after undelete,
    before delete
) {
    if (Trigger.isAfter) {
        if (Trigger.isUpdate) {
            IETRS_PipesByClassHazLiqTriggerHandler.handleAfterUpdate();
        } else if (Trigger.isInsert) {
            IETRS_PipesByClassHazLiqTriggerHandler.handleAfterInsert();
        } else if (Trigger.isDelete) {
            IETRS_PipesByClassHazLiqTriggerHandler.handleAfterDelete();
        } else if (Trigger.isUndelete) {
            IETRS_PipesByClassHazLiqTriggerHandler.handleAfterUndelete();
        }
    }
    if(Trigger.isBefore){
        if(Trigger.isDelete){
            IETRS_PipesByClassHazLiqTriggerHandler.handleBeforeDelete();
        }
    }
}