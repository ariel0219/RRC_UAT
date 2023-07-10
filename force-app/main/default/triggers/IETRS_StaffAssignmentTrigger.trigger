/**
 * @File Name          : IETRS_StaffAssignmentTrigger.trigger
 * @Description        : 
 * @Author             : Ayesha Sana
 * @Group              : 
 * @Last Modified By   : Ayesha Sana
 * @Last Modified On   : 02/09/2022
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author                    Modification
 *==============================================================================
 * 1.0        02/09/2022               Ayesha Sana             Initial Version
**/
trigger IETRS_StaffAssignmentTrigger on IETRS_Case_Staff_Assignment__c (before insert,before update) {
    if(Trigger.isBefore){
        if(Trigger.isInsert){
            IETRS_StaffAssignmentTriggerHandler.checkFirstChairAvailibilityforInsert(Trigger.new,Trigger.old); 
        }
        else if(Trigger.isUpdate){
            IETRS_StaffAssignmentTriggerHandler.checkFirstChairAvailibilityforUpdate(Trigger.new,Trigger.old,Trigger.newMap,Trigger.oldMap); 
        }
    }
}