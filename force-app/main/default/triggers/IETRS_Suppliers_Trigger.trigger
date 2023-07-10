trigger IETRS_Suppliers_Trigger on IETRS_Insp_Supplier__c (before delete) {

    if(Trigger.isDelete){
        if(Trigger.isBefore){
            IETRS_Suppliers_TriggerHelper.stopNonWorkInProgressIPDeletes(Trigger.old);
        }
    }

}