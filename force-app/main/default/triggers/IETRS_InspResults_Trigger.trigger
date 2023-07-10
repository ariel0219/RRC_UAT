trigger IETRS_InspResults_Trigger on IETRS_Insp_Inspection_Result__c (before delete) {
    
    if(Trigger.isDelete){
        if(Trigger.isBefore){
            IETRS_InspResultsTriggerHelper.stopNonWorkInProgressIPDeletes(Trigger.oldMap);
        }
    }

}