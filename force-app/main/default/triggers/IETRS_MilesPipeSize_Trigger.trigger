trigger IETRS_MilesPipeSize_Trigger on IETRS_Miles_of_Pipe_by_Size__c (before delete) {
    if(Trigger.isDelete){
        if(Trigger.isBefore){
            IETRS_MilesOfPipeBySize_TriggerHelper.stopNonWorkInProgressIPDeletes(Trigger.old);
        }
    }
}