trigger IETRS_PipesByClassTrigger on IETRS_Pipes_by_Class__c(after insert, after update, after delete, after undelete, before delete) {
    if (Trigger.isAfter) {
        if (Trigger.isUpdate) {
            IETRS_PipesByClassTriggerHandler.handleAfterUpdate();
        } else if (Trigger.isInsert) {
            IETRS_PipesByClassTriggerHandler.handleAfterInsert();
        } else if (Trigger.isDelete) {
            IETRS_PipesByClassTriggerHandler.handleAfterDelete();
        } else if (Trigger.isUndelete) {
            IETRS_PipesByClassTriggerHandler.handleAfterUndelete();
        }
    }
    if(Trigger.isDelete){
        if(Trigger.isBefore){
            IETRS_PipesByClassTriggerHandler.handleBeforeDelete();
        }
    }
}