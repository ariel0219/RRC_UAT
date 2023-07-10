trigger IETRS_RepairedLeaks_Trigger on IETRS_Repaired_Leaks__c (before delete) {

    if(Trigger.isDelete){
        if(Trigger.isBefore){
            IETRS_RepairedLeaks_TriggerHelper.stopNonWorkInProgressIPDeletes(Trigger.old);
        }
    }

}