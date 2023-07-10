trigger IETRS_LostUnacctGas_Trigger on IETRS_Lost_and_Unaccountable_Gas__c (before delete) {
    if(Trigger.isDelete){
        if(Trigger.isBefore){
            IETRS_LostUnacctGas_TriggerHelper.stopNonWorkInProgressIPDeletes(Trigger.old);
        }
    }
}