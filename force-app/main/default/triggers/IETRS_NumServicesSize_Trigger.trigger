trigger IETRS_NumServicesSize_Trigger on IETRS_Insp_Number_of_Services_by_Size__c (before delete) {
    if(Trigger.isDelete){
        if(Trigger.isBefore){
            IETRS_NumServicesSize_TriggerHelper.stopNonWorkInProgressIPDeletes(Trigger.old);
        }
    }
}