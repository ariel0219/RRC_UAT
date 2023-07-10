/**
 * @File Name          : RRC_AttachmentTriggerHandler.cls
 * @Description        : Trigger handler for new Attachments realted to an F&C record
 * @Author             : Sebastian Wittenstein
 * @Group              : 
 * @Last Modified By   : Sebastian Wittenstein
 * @Last Modified On   : 6/26/2023
 * @Modification Log   : 
 *==============================================================================
 * Ver      Date        Author      		      Modification
 *==============================================================================
 * 1.0      6/26/2023   Sebastian Wittenstein     Initial Version
**/
public with sharing class RRC_AttachmentTriggerHandler {
    public static void handleAttachments (
        Map<Id,Attachment> triggerMap
    ) {
        List<IETRS_Files_Correspondence__c> fcList = new List<IETRS_Files_Correspondence__c>();
        for (Attachment a : triggerMap.values()) {
            if(
                a.ParentId.getSObjectType() == Schema.IETRS_Files_Correspondence__c.SObjectType
            ){
                IETRS_Files_Correspondence__c fc = new IETRS_Files_Correspondence__c(Id = a.ParentId, rrc_Ready_to_upload__c = true);
                fcList.add(fc);
            }
        }
        update fcList;
    }
}