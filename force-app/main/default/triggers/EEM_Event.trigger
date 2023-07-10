trigger EEM_Event on EEM_Event__c (before insert, before update, after update) {
     if(Trigger.isBefore && Trigger.isInsert)
     {
    if(EEM_RecursiveHandler.isTriggerExecuted){
        
        EEM_RecursiveHandler.isTriggerExecuted = false;
       
            EEM_EventTriggerHelper.updateRegistrationCloseDate(Trigger.new, null);
            EEM_EventTriggerHelper.preventDuplicate(Trigger.new);
        }
    }
    
    if(Trigger.isBefore && Trigger.isUpdate)
    {
        EEM_EventTriggerHelper.updateRegistrationCloseDate(Trigger.new, null);
        //EEM_EventTriggerHelper.updateTotalCapacity(Trigger.new,null);
    }
    
    if(Trigger.isAfter && Trigger.isUpdate )
    {
        //if(RecursiveHandler.isTriggerExecuted){
        
        EEM_RecursiveHandler.isTriggerExecuted = false;
        EEM_EventTriggerHelper.updateRemainingCapacityAndSetStatusAsFullWhenNoSeatRemaning(Trigger.newMap, Trigger.oldMap);
   // }
        
    }
    /* switch on Trigger.operationType{
when BEFORE_INSERT{
EventTriggerHelper.updateRegistrationCloseDate(Trigger.new, null);
}
when BEFORE_UPDATE{
EventTriggerHelper.updateRegistrationCloseDate(Trigger.new, Trigger.oldMap);
}
when AFTER_UPDATE{
EventTriggerHelper.updateRemainingCapacityAndSetStatusAsFullWhenNoSeatRemaning(Trigger.newMap, Trigger.oldMap);
}
}*/
}