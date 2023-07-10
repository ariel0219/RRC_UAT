trigger IETRS_MilesofPipeBySizeMM_Trigger on IETRS_Miles_of_Pipe_by_Size_MM__c (before delete) {
    if(Trigger.isDelete){
        if(Trigger.isBefore){
            IETRS_MilesOfPipeBySize_TriggerHelper.stopNonWorkInProgressIPDeletesMM(Trigger.old);
        }
    }
}