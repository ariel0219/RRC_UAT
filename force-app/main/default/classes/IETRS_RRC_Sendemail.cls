/*
  @Class Name         : IETRS_RRC_SendEmail
  @Description        : Bounce Management on F&C Object
  @Author             : Srilu Mamillapalli
  @Group              : 
  @Last Modified By   : Srilu Mamillapalli
  @Last Modified On   : 3/20/2020
  @Modification Log   : 
  ==============================================================================
  Ver         Date                     Author                 Modification
  ==============================================================================
  1.0    3/20/2020,    Srilu Mamillapalli     Initial Version
*/
public class IETRS_RRC_Sendemail {
    @AuraEnabled
    public static string sendEmail(String RecordId, String fromAddress) {
        try {
            IETRS_RRC_Settings__c orgSettings = IETRS_RRC_Settings__c.getInstance();
            String fromEmailAddress = orgSettings.IETRS_FC_Email_From_Address__c;
            fromEmailAddress = fromEmailAddress == null ? 'safety@rrc.texas.gov' : fromEmailAddress;
            string response = 'SUCCESS';
            Boolean hasSendEmailPermission = FeatureManagement.checkPermission('RRC_Send_Email_Access');
            if (hasSendEmailPermission) {
                system.debug('Record id' + RecordId);
                //  system.debug('OriginalSender' + OriginalSender);

                List<Messaging.SingleEmailMessage> lstMail = new List<Messaging.SingleEmailMessage>();
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

                Map<String, List<String>> mapOfRecptTypeWithList = getEmailAddresses(RecordId);
                if (mapOfRecptTypeWithList.get('To') != null) {
                    String[] toAddresses = mapOfRecptTypeWithList.get('To');
                    String[] ccAddresses = mapOfRecptTypeWithList.get('CC');

                    // Set Org Wide Address as Sender id/From address
                    OrgWideEmailAddress owea = new OrgWideEmailAddress();

                    for (OrgWideEmailAddress address : [
                        SELECT Id, Address, DisplayName
                        FROM OrgWideEmailAddress
                        WHERE Address = :fromEmailAddress
                        LIMIT 1
                    ]) {
                        owea = address;
                    }

                    if (owea.Id == null) {
                        String errorMsg =
                            'You must add  ' +
                            fromEmailAddress +
                            ' as an organization wide email address before you can send this email.';
                        AuraHandledException ahe = new AuraHandledException(errorMsg);
                        ahe.setMessage(errorMsg);
                        throw ahe;
                    }
                    mail.setOrgWideEmailAddressId(owea.Id);

                    IETRS_Files_Correspondence__c FCRec = [
                        SELECT
                            Id,
                            IETRS_Box_File_ID__c,
                            IETRS_Email_Body__c,
                            IETRS_Subject__c,
                            IETRS_Delivery_Method__c,
                            IETRS_File_Name__c
                        FROM IETRS_Files_Correspondence__c
                        WHERE Id = :RecordId
                    ];
                    if (String.isBlank(FCRec.IETRS_Email_Body__c) || String.isBlank(FCRec.IETRS_Subject__c)) {
                        String errorMsg = 'Please add an Email Subject and Email Body then try again.';
                        AuraHandledException ahe = new AuraHandledException(errorMsg);
                        ahe.setMessage(errorMsg);
                        throw ahe;
                    }
                    Blob attachmentDoc;
                    if (Test.isRunningTest()) {
                        attachmentDoc = [SELECT Id, VersionData FROM ContentVersion LIMIT 1].VersionData;
                    } else {
                        IETRSBox helper = new IETRSBox();
                        attachmentDoc = helper.downloadFile(FCRec.IETRS_Box_File_ID__c);
                    }

                    List<Messaging.Emailfileattachment> fileAttachments = new List<Messaging.Emailfileattachment>();
                    Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();
                    efa.setFileName(FCRec.IETRS_File_Name__c);
                    efa.setBody(attachmentDoc);
                    fileAttachments.add(efa);
                    /*  for (Attachment a : [select Name, Body, BodyLength from Attachment where ParentId = :FCRec.Id])
                    {
                    // Add to attachment file list
                    Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();
                    efa.setFileName(a.Name);
                    efa.setBody(attachmentDoc);
                    fileAttachments.add(efa);
                    }*/
                    mail.setFileAttachments(fileAttachments);

                    mail.setToAddresses(toAddresses);
                    mail.setCCAddresses(ccAddresses);

                    mail.setSubject(FCRec.IETRS_Subject__c);
                    mail.setBccSender(false);
                    mail.setUseSignature(false);
                    mail.setHtmlBody(FCRec.IETRS_Email_Body__c.replaceAll('\r?\n', '<br/>'));
                    lstMail.add(mail);
                    if (lstMail.size() > 0) {
                        Boolean isSuccess;
                        String emailError;
                        if (!Test.isRunningTest()) {
                            Messaging.SendEmailResult[] results = Messaging.sendEmail(lstMail);
                            isSuccess = results[0].success;
                            emailError = !results[0].isSuccess() ? results[0].errors[0].message : '';
                        } else {
                            // simulate a successful email send
                            isSuccess = true;
                        }
                        IETRS_Files_Correspondence__c objFileCoresp = [
                            SELECT
                                Id,
                                IETRS_Inspection_Package__c,
                                IETRS_Delivery_Method__c,
                                IETRS_Sent_Date_Time__c,
                                IETRS_Regulated_Fee__c,
                                IETRS_Incident__c,
                                IETRS_Complaint__c,
                                IETRS_Case__c,
                                IETRS_Organization__c,
                                IETRS_Notification__c,
                                IETRS_Document_Type__c
                            FROM IETRS_Files_Correspondence__c
                            WHERE Id = :RecordId
                            LIMIT 1
                        ];
                        // code for Event History
                        Id WhatId = objFileCoresp.IETRS_Inspection_Package__c != null
                            ? objFileCoresp.IETRS_Inspection_Package__c
                            : objFileCoresp.IETRS_Regulated_Fee__c != null
                                    ? objFileCoresp.IETRS_Regulated_Fee__c
                                    : objFileCoresp.IETRS_Incident__c != null
                                            ? objFileCoresp.IETRS_Incident__c
                                            : objFileCoresp.IETRS_Complaint__c != null
                                                    ? objFileCoresp.IETRS_Complaint__c
                                                    : objFileCoresp.IETRS_Case__c != null
                                                            ? objFileCoresp.IETRS_Case__c
                                                            : objFileCoresp.IETRS_Organization__c != null
                                                                    ? objFileCoresp.IETRS_Organization__c
                                                                    : objFileCoresp.IETRS_Notification__c != null
                                                                            ? objFileCoresp.IETRS_Notification__c
                                                                            : null;

                        String comments =
                            objFileCoresp.IETRS_Document_Type__c +
                            ' / Email Sent To: ' +
                            string.join(mapOfRecptTypeWithList.get('To'), ',');
                        comments = mapOfRecptTypeWithList.get('CC') == null
                            ? comments
                            : comments + ' AND CC To: ' + string.join(mapOfRecptTypeWithList.get('CC'), ',');
                        Task objTask = IETRS_Utility.createActivityHistoryRecord(WhatId, comments);
                        objTask.Type = objTask.Subject = 'Sent Letter';
                        if (isSuccess) {
                            System.debug('The email was sent successfully.');
                            objTask.Description = comments;
                        } else {
                            System.debug('The email failed to send: ' + emailError);
                            response = 'Sending email failed with Error : results[0].errors[0].message';
                            //objTask.Description = ''; // add comments line here
                            //objTask.Subject = ''; // subject for failed email.
                            objTask.IETRS_Note__c = 'Sending email failed with Error : results[0].errors[0].message';
                        }
                        objFileCoresp.IETRS_Delivery_Method__c = 'Email';
                        objFileCoresp.IETRS_Sent_Date_Time__c = System.now();
                        update objFileCoresp;

                        insert objTask;
                    } else {
                        System.debug('No Record Found');
                    }
                } else {
                    response = 'Unable to send email as there are no recipients.';
                }
            } else {
                response = 'You are not authorized to send emails.';
            }

            return response;
        } catch (Exception e) {
            AuraHandledException ahe = new AuraHandledException(e.getMessage());
            ahe.setMessage(e.getMessage());
            throw ahe;
        }
    }

    /* *
     *  Get Email address of Public group members
     * */
     @AuraEnabled
    public static Map<String, List<String>> getEmailAddresses(String FCRecId) {
        Map<String, List<String>> mapOfRecptTypeWithList = new Map<String, List<String>>{
            'To' => new List<String>(),
            'CC' => new List<String>()
        };

        for (IETRS_Insp_Correspondence_Mailing_List__c fcRec : [
            SELECT
                Id,
                IETRS_Files_and_Correspondence__c,
                IETRS_Contact__r.Email,
                IETRS_To_or_CC__c,
                Name,
                IETRS_Email__c,
                IETRS_Other_Email_Recipients__c
            FROM IETRS_Insp_Correspondence_Mailing_List__c
            WHERE IETRS_Files_and_Correspondence__c = :FCRecId
        ]) {
            String[] mailToAddresses = mapOfRecptTypeWithList.get(fcRec.IETRS_To_or_CC__c);
            if (mailToAddresses == null) {
                continue;
            }
            if (fcRec.IETRS_Contact__r != null && string.isNotBlank(fcRec.IETRS_Contact__r.Email)) {
                mailToAddresses.add(fcRec.IETRS_Contact__r.Email);
            }
            if (String.isNotBlank(fcRec.IETRS_Email__c)) {
                mailToAddresses.add(fcRec.IETRS_Email__c);
            }
            if (String.isNotBlank(fcRec.IETRS_Other_Email_Recipients__c)) {
                mapOfRecptTypeWithList.get('CC').addAll(fcRec.IETRS_Other_Email_Recipients__c.split(';'));
            }
        }
        //system.debug('mailToAddresses'+mailToAddresses);
        return mapOfRecptTypeWithList;
    }
}