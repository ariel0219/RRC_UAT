trigger IETRS_MAOP_Trigger on IETRS_Insp_MAOP__c (before delete) {
    if(Trigger.isDelete){
        if(Trigger.isBefore){
            IETRS_MAOP_TriggerHelper.stopNonWorkInProgressIPDeletes(Trigger.old);
        }
    }

}