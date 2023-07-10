global with sharing class IETRS_SpecializedInspScheduleBatch implements Database.Batchable<SObject> {
    /*
     * @description Inspection config record that starts the process
     */
    IETRS_InspSchedConfig__c configRecord;

    /*
     * @description Class constructor
     * @param configRecord The config record used to create the schedules
     */
    global IETRS_SpecializedInspScheduleBatch(IETRS_InspSchedConfig__c configRecord) {
        this.configRecord = configRecord;
    }

    /*
     * @description Start method for the batch class
     * @param bc The batchable context for the batch class
     */
    global Database.QueryLocator start(Database.BatchableContext bc) {
        final String ORGANIZATION_RT = 'Organization';
        final Set<String> EXCLUDED_ORG_IDS = IETRS_SpecializedInspScheduleServices.EXCLUDED_ORG_IDS;
        // query all accounts with record type organization
        String query =
            'SELECT Id, Name, RecordType.DeveloperName, Type, IETRS_Entity_Sub_Type__c, ' +
            'IETRS_Allowed_Inspection_Record_Type__c, IETRS_Regulated_Entity_Business_Area__c, ' +
            'Latest_Inspection_Date__c, IETRS_Latest_Inspection__c,IETRS_Gas_Pipe_Total_Miles__c, ' +
            'IETRS_Organization_Parent__c, IETRS_OrganizationofRegEntity__c, ' +
            'IETRS_County__c, IETRS_District__c, IETRS_Region__c, IETRS_Status__c, ' +
            'Total_Miles_of_High_Consequence_Gas__c,Total_Miles_of_High_Consequence_Liq__c, ' +
            'IETRS_On_Offshore__c,IETRS_Product_Class__c,IETRS_Jurisdictional_Control_Room__c ' +
            'FROM Account ' +
            'WHERE IETRS_Company_Id__c NOT IN:EXCLUDED_ORG_IDS AND RecordType.DeveloperName = :ORGANIZATION_RT';
        return Database.getQueryLocator(query);
    }

    /*
     * @description Execute method
     * @param bc The batchable context for the batch class
     * @param records The organizations (Accounts) in scope for a given batch
     */
    global void execute(Database.BatchableContext bc, List<SObject> records) {
        // create inspection schedules for the organization records in this batch
        IETRS_SpecializedInspScheduleServices inspScheduledService = new IETRS_SpecializedInspScheduleServices(
            (List<Account>) records,
            configRecord
        );
        inspScheduledService.createInspectionSchedules();
    }

    /*
     * @description Finish method. Emails the result.
     * @param bc The batchable context for the batch class
     */
    global void finish(Database.BatchableContext bc) {
        AsyncApexJob job = [
            SELECT Id, Status, ExtendedStatus, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email
            FROM AsyncApexJob
            WHERE Id = :bc.getJobId()
        ];

        // Send results email
        String subject = 'IETRS Specialized Inspection Schedule Generation ' + job.Status;
        String body =
            'The schedule generation process is complete.' +
            '\nYou may view the generated schedule records here:\n' +
            URL.getSalesforceBaseUrl().toExternalForm() +
            '/' +
            configRecord.Id;

        if (job.NumberOfErrors > 0) {
            body += '\n\nThere were ' + job.NumberOfErrors + ' errors generating the records: ' + job.ExtendedStatus;
        }
        IETRS_SpecializedInspScheduleServices.sendEmail(subject, body);
    }
}