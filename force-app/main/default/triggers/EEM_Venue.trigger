trigger EEM_Venue on EEM_Venue__c (before update,after update,before insert) {
    switch on Trigger.operationType{
        when BEFORE_INSERT{
            EEM_VenueTriggerHelper.preventDuplicate(Trigger.new);
        }
        when BEFORE_UPDATE{
            EEM_VenueTriggerHelper.validateTotalCapacityField(Trigger.newMap, Trigger.oldMap);
        }
        when AFTER_UPDATE{
            EEM_VenueTriggerHelper.validateTotalCapacityField(Trigger.newMap, Trigger.oldMap);
        }
    } 
}