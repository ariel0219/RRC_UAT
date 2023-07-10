/**
 * @File Name          : IETRS_AccountTrigger.trigger
 * @Description        :
 * @Author             : Kevin Lu
 * @Group              :
 * @Last Modified By   : Kevin Lu
 * @Last Modified On   : 6/19/2020, 9:03:45 AM
 * @Modification Log   :
 * Ver          Date            Author          Modification
 * 1.0          10/31/2019      Kevin Lu        Initial Version
 * 2.0          01/06/2020      Kevin Lu        Updated to pass a set of Id's to accomodate new future Apex calls
 * 3.0          02/18/2020      Kevin Lu        Updated to only process non future/batch inserts and updates (to avoid errors)
 * 4.0          03/19/2020      Kevin Lu        Deactivated and moved logic to IETRS_Oil_And_Gas_Controller
 * 5.0          06/19/2020      Kevin Lu        Reactivatd for PIPES logic - unit event history upon deletion and update
 **/
trigger IETRS_AccountTrigger on Account(after update, after insert, after delete, after undelete) {
    if (Trigger.isAfter) {
        if (Trigger.isUpdate) {
            IETRS_AccountTriggerHelper.handleAfterUpdate();
        } else if (Trigger.isInsert) {
            IETRS_AccountTriggerHelper.handleAfterInsert();
        } else if (Trigger.isDelete) {
            IETRS_AccountTriggerHelper.handleAfterDelete();
        } else if (Trigger.isUndelete) {
            IETRS_AccountTriggerHelper.handleAfterUndelete();
        }
    }
}