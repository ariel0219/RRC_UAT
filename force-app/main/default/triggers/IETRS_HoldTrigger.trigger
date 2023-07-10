/**
 * @description       : Trigger to run Holds are changed to set GFC flag on Account
 * @author            : Kevin Lu
 * @group             : 
 * @last modified on  : 2020-07-20
 * @last modified by  : Kevin Lu
 * Modifications Log 
 * Ver   Date         Author     Modification
 * 1.0   2020-07-20   Kevin Lu   Initial Version
**/
trigger IETRS_HoldTrigger on IETRS_Hold__c (after insert, after update, after delete) {
    if(trigger.isAfter) {
        if(trigger.isDelete) {
            IETRS_HoldTriggerHelper.handleAfter(trigger.old);
        } else if(trigger.isInsert || trigger.isUpdate) {
            IETRS_HoldTriggerHelper.handleAfter(trigger.new);
        }
    }
}