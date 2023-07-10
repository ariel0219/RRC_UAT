trigger IETRS_FilesCorrespTrigger on IETRS_Files_Correspondence__c (before delete) {
    
    if(Trigger.isDelete){
        if(Trigger.isBefore){
            if (IETRS_FilesCorrespTriggerHelper.stopNonWorkInProgressIPDeletes(Trigger.oldMap) == false){
                IETRS_FilesCorrespTriggerHelper.createActivityForDeletedFilesCorresp(Trigger.oldMap);
            }
        }
    }

}