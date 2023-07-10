/**
 * @File Name          : IETRS_ContentDocumentLinkTrigger.trigger
 * @Description        :
 * @Author             : Mark Frizzell
 * @Group              :
 * @Last Modified By   : Mark Frizzell
 * @Last Modified On   : 8/20/2019, 9:04:43 PM
 * @Modification Log   :
 *==============================================================================
 * Ver         Date                     Author                    Modification
 *==============================================================================
 * 1.0    7/25/2019, 3:43:49 PM   Mark Frizzell     Initial Version
 * 1.1    7/26/2019               Mark Frizzell     Ignore status on DocuSign Status record, just upload doc to Box
 **/
trigger IETRS_ContentDocumentLinkTrigger on ContentDocumentLink(
    before insert,
    before update,
    after insert,
    after update
) {
    if (Trigger.isBefore) {
        if (Trigger.isInsert || Trigger.isUpdate) {
            List<IETRS_Files_Correspondence__c> fileCorrespondences = new List<IETRS_Files_Correspondence__c>();
            for (ContentDocumentLink cdl : Trigger.new) {
                // check if the parent is IETRS_Files_Correspondence__c
                if (cdl.LinkedEntityId.getSObjectType() == Schema.IETRS_Files_Correspondence__c.SObjectType) {
                    fileCorrespondences.add(
                        new IETRS_Files_Correspondence__c(Id = cdl.LinkedEntityId, IETRS_Is_Uploading__c = true)
                    );
                }
            }
            if (!fileCorrespondences.isEmpty()) {
                update fileCorrespondences;
            }
        }
    }

    if (Trigger.isAfter) {
        if (Trigger.isInsert || Trigger.isUpdate) {
            // If document is added to a DocuSign Status record, upload it to Box
            Set<Id> statusIds = new Set<Id>();
            Set<Id> contIds = new Set<Id>();
            for (ContentDocumentLink cdl : Trigger.new) {
                System.debug('cdl: ' + cdl);
                if (cdl.LinkedEntityId.getSObjectType() == Schema.dsfs__DocuSign_Status__c.SObjectType) {
                    try {
                        dsfs__DocuSign_Status__c statusRec = [
                            SELECT Id, dsfs__Envelope_Status__c
                            FROM dsfs__DocuSign_Status__c
                            WHERE Id = :cdl.LinkedEntityId
                            LIMIT 1
                        ];
                        System.debug('statusRec: ' + statusRec);
                        if (statusRec != null && statusRec.dsfs__Envelope_Status__c == 'Completed') {
                            statusIds.add(statusRec.Id);
                        }
                    } catch (Exception ex) {
                        System.debug('ex: ' + ex);
                        cdl.addError(ex.getMessage());
                    }
                } else if (cdl.LinkedEntityId.getSObjectType() == Schema.IETRS_Files_Correspondence__c.SObjectType) {
                    System.debug('cdl: ' + cdl.LinkedEntityId.getSObjectType());
                    contIds.add(cdl.LinkedEntityId);
                }
            }
            if (statusIds.size() > 0 && !Test.isRunningTest()) {
                IETRS_BoxTriggerServices.uploadFiles(statusIds);
            }
            if (contIds.size() > 0 && !Test.isRunningTest()) {
                //upload file to BOX on F&C
                IETRS_UploadDocument.prepareUploadAsync(contIds);
                // fire the box upload event to indicate an upload is queued
                EventBus.publish(new List<Box_Upload__e>{ new Box_Upload__e() });
            }
        }
    }

}