trigger IETRS_RepairedLeaksGasLiq_Trigger on IETRS_Repaired_Leaks_Gas_Liq__c (before delete) {

    if(Trigger.isDelete){
        if(Trigger.isBefore){
            IETRS_RepairedLeaksGasLiq_TriggerHelper.stopNonWorkInProgressIPDeletes(Trigger.old);
        }
    }

}