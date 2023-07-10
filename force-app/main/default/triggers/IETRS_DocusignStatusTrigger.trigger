/**
 * @File Name          : IETRS_DocusignStatusTrigger.trigger
 * @Description        : Trigger actions for dsfs_DocuSign_Status__c object
 * @Author             : Mark Frizzell
 * @Group              : 
 * @Last Modified By   : Mark Frizzell
 * @Last Modified On   : 7/26/2019, 10:33:21 AM
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author                Modification
 *==============================================================================
 * 1.0    6/29/2019, 2:08:44 PM   Mark Frizzell     Initial Version
 * 1.1    7/25/2019               Mark Frizzell     Move status = completed logic to ContentDocumentLinkTrigger
**/
trigger IETRS_DocusignStatusTrigger on dsfs__DocuSign_Status__c (after insert, after update) {

    // private final String STATUS_SENT = 'Sent';
    // private final String STATUS_DELIVERED = 'Delivered';
    // private final String STATUS_COMPLETE = 'Completed';

    // if(Trigger.isAfter) {
    //     List<dsfs__DocuSign_Status__c> cleanupRecs = new List<dsfs__DocuSign_Status__c>();
    //     Set<Id> uploadRecs = new Set<Id>();
        
    //     // After update
    //     if(Trigger.isUpdate) {
    //         for(dsfs__DocuSign_Status__c newRec : Trigger.new) {
    //             dsfs__DocuSign_Status__c oldRec = Trigger.oldMap.get(newRec.Id);
    //             String newStatus = newRec.dsfs__Envelope_Status__c;
    //             String oldStatus = oldRec.dsfs__Envelope_Status__c;
                    
    //             if(newStatus != oldStatus) {
    //                 if(newStatus == STATUS_SENT || newStatus == STATUS_DELIVERED) {
    //                     cleanupRecs.add(newRec);
    //                 }
    //             }
    //         }
    //         if(cleanupRecs.size() > 0) {
    //             IETRS_BoxTriggerServices.cleanupFiles(cleanupRecs);
    //         }
    //     }

    //     // After insert
    //     if(Trigger.isInsert) {
    //         for(dsfs__DocuSign_Status__c newRec : Trigger.new) {                
    //             if(newRec.dsfs__Envelope_Status__c == STATUS_SENT|| newRec.dsfs__Envelope_Status__c == STATUS_DELIVERED) {
    //                 cleanupRecs.add(newRec);
    //             }
    //         }
    //         if(cleanupRecs.size() > 0) {
    //             IETRS_BoxTriggerServices.cleanupFiles(cleanupRecs);
    //         }
    //     }
        
    // }

}