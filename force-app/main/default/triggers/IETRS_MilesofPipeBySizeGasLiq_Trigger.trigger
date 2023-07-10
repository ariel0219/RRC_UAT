trigger IETRS_MilesofPipeBySizeGasLiq_Trigger on IETRS_Miles_of_Pipe_by_Size_Gas_Liq__c (before delete) {
    if(Trigger.isDelete){
        if(Trigger.isBefore){
            IETRS_MilesOfPipeBySize_TriggerHelper.stopNonWorkInProgressIPDeletesGL(Trigger.old);
        }
    }
}