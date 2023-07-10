/**
 * @File Name          : IETRS_SecondaryAccountAssignmentTrigger.trigger
 * @Description        : Trigger for Secondary Account Assignments
 * @Author             : Kevin Lu
 * @Group              : 
 * @Last Modified By   : Kevin Lu
 * @Last Modified On   : 9/20/2019, 3:00:33 PM
 * @Modification Log   : 
 * Ver      Date        Author          Modification
 * 1.0      9/20/2019   Kevin Lu        Initial Version
**/
trigger IETRS_SecondaryAccountAssignmentTrigger on IETRS_Case_Secondary_Account_Assignment__c (after delete) {
    //IETRS_SecondaryAcctAsgmtTriggerHelper.processDeletes(trigger.old);
}