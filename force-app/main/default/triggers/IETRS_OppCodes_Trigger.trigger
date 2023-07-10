trigger IETRS_OppCodes_Trigger on IETRS_Insp_OPP_Codes__c (before delete) {

    if(Trigger.isDelete){
        if(Trigger.isBefore){
            IETRS_OppCodes_TriggerHelper.stopNonWorkInProgressIPDeletes(Trigger.old);
        }
    }

}