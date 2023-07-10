/*
 * @Class: IETRS_Send_PS95_Delinquent_Email
 * @Description: Batch Apex Class that sends emails to Operators with unsubmitted PS95 reports for the previous filing period.
 *               Runs twice a year scheduled in January and July.
 *               January run should send email for previous year's July - December period.
 *               July run should send email for this year's January - June period.
 * @Created Date:
 * @Created By:
 */
public class IETRS_Send_PS95_Delinquent_Email implements System.Schedulable, DataBase.Batchable<Sobject>, Database.Stateful {
    public Boolean isTestMode = false;
    public String overrideFilingPeriod = null;
    private String strFilingPeriod;
    private String testEmailAttachment = '';

    /*
     * @Method:
     * @Description:
     * Param:
     * Return:
     */
    public void execute(SchedulableContext sctxt) {
        IETRS_Send_PS95_Delinquent_Email instance = new IETRS_Send_PS95_Delinquent_Email();
        DataBase.executeBatch(instance, 200);
    }

    /*
     * @Method: Start
     * @Description: Standard Start method for Batch Apex. Defines the Query String to be used by the Execute method.
     * Param: batch - Database.BatchableContext
     * Return: QueryLocator for execute
     */
    public DataBase.QueryLocator start(DataBase.BatchableContext batch) {
        String submittedNo = 'No';
        strFilingPeriod = IETRS_PS95Helper.getReportPeriod(
            System.today().addMonths(-6)
        );

        // use the override value if provided
        if (overrideFilingPeriod != null) {
            strFilingPeriod = overrideFilingPeriod;
        }
        System.debug(strFilingPeriod);
        String query =
            IETRS_PS95Helper.getQueryString('IETRS_Insp_Notification__c') +
            ', IETRS_PS95_Organization__r.Name, IETRS_PS95_Organization__r.IETRS_Representative__r.Email, IETRS_Organization__r.IETRS_Representative__r.Id FROM IETRS_Insp_Notification__c ' +
            'WHERE IETRS_Submitted__c = :submittedNo ' +
            'AND IETRS_PS95_Organization__r.IETRS_Representative__r.Email != NULL ' +
            'AND IETRS_Report_Period__c = :strFilingPeriod';
        System.debug(query);
        return dataBase.getQueryLocator(query);
    }

    /*
     * @Method: execute
     * @Description:
     * Param:
     * Return:
     */
    public void execute(
        DataBase.BatchableContext batch,
        List<IETRS_Insp_Notification__c> listOfNotificationRecords
    ) {
        Map<Id, Integer> activeEntityCountByOrgId = IETRS_PS95Helper.getActiveEntityCountyByOrgId(
            listOfNotificationRecords
        );
        Map<String, List<IETRS_Insp_Notification__c>> mapOfEmailWithFilingPeriods = new Map<String, List<IETRS_Insp_Notification__c>>();
        if (listOfNotificationRecords.size() > 0) {
            for (
                IETRS_Insp_Notification__c notificationInstance : listOfNotificationRecords
            ) {
                // skip this notification record if the org doesn't have any active entities
                Integer activeEntities = activeEntityCountByOrgId.get(
                    notificationInstance.IETRS_PS95_Organization__c
                );
                if (activeEntities == null || activeEntities == 0) {
                    continue;
                }
                if (
                    notificationInstance.IETRS_PS95_Organization__r.IETRS_Representative__r
                        ?.Email != null
                ) {
                    if (
                        !mapOfEmailWithFilingPeriods.containsKey(
                            notificationInstance.IETRS_PS95_Organization__r.IETRS_Representative__r
                                ?.Email
                        )
                    ) {
                        mapOfEmailWithFilingPeriods.put(
                            notificationInstance.IETRS_PS95_Organization__r.IETRS_Representative__r
                                ?.Email,
                            new List<IETRS_Insp_Notification__c>{
                                notificationInstance
                            }
                        );
                    } else {
                        mapOfEmailWithFilingPeriods.get(
                                notificationInstance.IETRS_PS95_Organization__r.IETRS_Representative__r
                                    ?.Email
                            )
                            .add(notificationInstance);
                    }

                    if (isTestMode) {
                        testEmailAttachment +=
                            notificationInstance.IETRS_PS95_Organization__c +
                            ',' +
                            notificationInstance.IETRS_PS95_Organization__r.Name.escapeCsv() +
                            '\r';
                    }
                }
            }
        }

        List<EmailParam> listOfEmailParams = new List<EmailParam>();
        if (!mapOfEmailWithFilingPeriods.isEmpty()) {
            for (String emailkey : mapOfEmailWithFilingPeriods.keySet()) {
                EmailParam emailParaminstance = new EmailParam();
                emailParaminstance.emailRecepints = emailkey;
                emailParaminstance.orgwideEmailId = Label.orgwideEmailId;
                if (mapOfEmailWithFilingPeriods.get(emailkey).size() > 0) {
                    emailParaminstance.recordId = mapOfEmailWithFilingPeriods.get(
                            emailkey
                        )
                        .get(0)
                        .Id;
                }
                emailParaminstance.emailTemplateId = Label.emailTemplateId;
                if (mapOfEmailWithFilingPeriods.get(emailkey).size() > 0) {
                    if (
                        mapOfEmailWithFilingPeriods.get(emailkey)
                            .get(0)
                            ?.IETRS_PS95_Organization__r
                            ?.IETRS_Representative__r.Id != null
                    ) {
                        emailParaminstance.targetObjectId = mapOfEmailWithFilingPeriods.get(
                                emailkey
                            )
                            .get(0)
                            .IETRS_PS95_Organization__r.IETRS_Representative__r.Id;
                    }
                }
                emailParaminstance.replyToAddress = Label.ReplyToAddress;
                listOfEmailParams.add(emailParaminstance);
            }
        }

        if (listOfEmailParams.size() > 0) {
            //System.debug(listOfEmailParams);
            if (!isTestMode) {
                sendEmails(listOfEmailParams);
            }
        }
    }

    /*
     * @Method: Finish
     * @Description: Required on finish behavior for Batch Apex. Not used for this class.
     * Param: batch - Database.BatchableContext
     */
    public void finish(DataBase.BatchableContext batch) {
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        // set the current user as the recipient
        email.setToAddresses(new List<String>{ UserInfo.getUserEmail() });
        email.setReplyTo(UserInfo.getUserEmail());
        email.setSubject('PS95 Delinquent Emails');
        email.setSaveAsActivity(false);
        email.setPlainTextBody(
            'The attached file contains a list of PS95 delinquent organizations for the filing period: ' +
            strFilingPeriod +
            '.'
        );
        // create the attachment and add it to the email
        Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
        testEmailAttachment =
            'Organization Id,Organization Name\r' + testEmailAttachment;
        attachment.setBody(Blob.valueOf(testEmailAttachment));
        attachment.setFileName('ps95-delinquent-organizations.csv');
        attachment.setContentType('text/csv');
        email.setFileAttachments(
            new List<Messaging.EmailFileAttachment>{ attachment }
        );
        if (
            !Test.isRunningTest() &&
            isTestMode &&
            String.isNotBlank(testEmailAttachment)
        ) {
            Messaging.sendEmail(
                new List<Messaging.SingleEmailMessage>{ email },
                false
            );
        }
    }

    /*
     * @Method:
     * @Description:
     * Param:
     * Return:
     */
    public static void sendEmails(List<EmailParam> listOfEmailParams) {
        //String orgwideEmailId;String emailTemplateId;String emailRecepints;String targetObjectId;
        List<Messaging.SingleEmailMessage> listOfSingleEmailMessages = new List<Messaging.SingleEmailMessage>();

        if (listOfEmailParams.size() > 0) {
            for (EmailParam emailParamInstance : listOfEmailParams) {
                Messaging.SingleEmailMessage singleEmailMessageInstance = new Messaging.SingleEmailMessage();
                List<String> sendTo = new List<String>();
                sendTo.add(emailParamInstance.emailRecepints);
                singleEmailMessageInstance.setToAddresses(sendTo);
                singleEmailMessageInstance.setOrgWideEmailAddressId(
                    emailParamInstance.orgwideEmailId
                );
                singleEmailMessageInstance.setTargetObjectId(
                    emailParamInstance.targetObjectId
                );
                singleEmailMessageInstance.setWhatId(
                    emailParamInstance.recordid
                );
                singleEmailMessageInstance.setTemplateId(
                    emailParamInstance.emailTemplateId
                );
                singleEmailMessageInstance.setReplyTo(
                    emailParamInstance.replyToAddress
                ); //need to know What will be the setReplyTo Email Address
                //singleEmailMessageInstance.setSenderDisplayName('');//need to know What will be the Display Name
                listOfSingleEmailMessages.add(singleEmailMessageInstance);
            }
        }

        List<Messaging.SendEmailResult> results = new List<Messaging.SendEmailResult>();

        if (listOfSingleEmailMessages.size() > 0) {
            results = Messaging.sendEmail(listOfSingleEmailMessages, false);
        }

        if (results.size() > 0) {
            if (results[0].success) {
                System.debug('The email was sent successfully.');
            } else {
                System.debug(
                    'The email failed to send: ' + results[0].errors[0].message
                );
            }
        }
    }

    /*
     * @Class: EmailParam
     * @Description:
     */
    public class EmailParam {
        public String orgwideEmailId;
        public String recordid;
        public String emailTemplateId;
        public String emailRecepints;
        public String targetObjectId;
        public String replyToAddress;
        public String orgName;
        public String orgId;
    }
}