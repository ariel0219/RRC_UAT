/**
 * @File Name          : IETRS_CaseTrigger.trigger
 * @Description        : 
 * @Author             : Ronald Stewart
 * @Group              : 
 * @Last Modified By   : Ronald Stewart
 * @Last Modified On   : 10/15/2020
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author                    Modification
 *==============================================================================
 * 1.0        10/15/2020               Ronald Stewart             Initial Version
**/
trigger IETRS_CaseTrigger on Case (before update) {   
    if(Trigger.isBefore && Trigger.isUpdate){
        //Removing parent but check if child records exist for parent
        IETRS_CaseTriggerHandler.doesParentCaseHaveChildren(Trigger.new,Trigger.old); 
    }
}