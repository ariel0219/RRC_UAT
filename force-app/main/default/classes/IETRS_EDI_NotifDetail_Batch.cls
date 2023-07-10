/**
 * @File Name          : IETRS_EDI_NotificationDetail_Insert_Batch.cls
 * @Description        : Batch class to be called during the PLI EDI process to insert Notification Detail records.
 * @Author             : Forrest Chang
 * @Group              :
 * @Last Modified By   : Forrest Chang
 * @Last Modified On   : 7/16/2021
 * @Modification Log   :
 *==============================================================================
 * Ver         Date                     Author                    Modification
 *==============================================================================
 * 1.0      7/16/2021               Forrest Chang     			Initial Version
 **/
global with sharing class IETRS_EDI_NotifDetail_Batch implements Database.Batchable<sObject>{
    List<IETRS_Insp_Notification_Detail__c> lstNotificationDetails;
    boolean blnSendEventOnFinish = false;
    
    global IETRS_EDI_NotifDetail_Batch(List<IETRS_Insp_Notification_Detail__c> lstNotifDetails, Boolean blnSendEventOnFinish) {
       this.lstNotificationDetails = lstNotifDetails != null ? lstNotifDetails : new List<IETRS_Insp_Notification_Detail__c>();
       this.blnSendEventOnFinish = blnSendEventOnFinish;
    }

    global Iterable<sObject> start(Database.BatchableContext BC){ 
        return this.lstNotificationDetails; 
    }     
    global void execute(Database.BatchableContext BC, List<IETRS_Insp_Notification_Detail__c> scope){
        if(scope.size() > 0){
            insert scope;    
        }
    }     
    global void finish(Database.BatchableContext BC){
        system.debug('vlnFinalBatch ' + blnSendEventOnFinish);
        if(blnSendEventOnFinish){
            system.debug('Batch Complete');
            IETRS_EDI_Save_Complete__e evtSaveComplete = new IETRS_EDI_Save_Complete__e(IETRS_Job_Id__c = BC.getJobId());
            // Call method to publish events
            Database.SaveResult result = EventBus.publish(evtSaveComplete);
            system.debug('Result: ' + result);
        }
        
    } 
 }