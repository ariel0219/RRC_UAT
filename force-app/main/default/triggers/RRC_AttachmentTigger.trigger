trigger RRC_AttachmentTigger on Attachment (after insert) {
    switch on Trigger.operationType {
        when AFTER_INSERT {
            RRC_AttachmentTriggerHandler.HandleAttachments(Trigger.newMap);
        }
    }
}