/**
 * @File Name          : IETRS_InspScheduleGenerateController.cls
 * @Description        :
 * @Author             : Mark Frizzell
 * @Group              :
 * @Last Modified By   : Sebastian Wittenstein
 * @Last Modified On   : 2/14/2023
 * @Modification Log   :
 *==============================================================================
 * Ver      Date        Author                  Modification
 *==============================================================================
 * 1.0      08/26/2019   Mark Frizzell           Initial Version
 * 1.1      02/14/2023   Sebastian Wittenstein   added IETRS_Regulated_Entity_Type__c to genRecord query
 **/
public with sharing class IETRS_InspScheduleGenerateController {
    /**
     * @description - Check if schedules have been generated for this record
     * @author Mark Frizzell | 8/26/2019
     * @param Id recId - Schedule generation record Id
     * @return Boolean
     */
    @AuraEnabled
    public static Boolean isGenerated(Id recId) {
        try {
            IETRS_InspSchedConfig__c rec = [
                SELECT IETRS_Status__c
                FROM IETRS_InspSchedConfig__c
                WHERE Id = :recId
                LIMIT 1
            ];
            return rec.IETRS_Status__c != IETRS_InspScheduleServices.STATUS_IN_PROG;
        } catch (QueryException qex) {
            return false;
        }
    }

    /**
     * @description - Entry point for the Lightning Quick Action component. Calls batch process to generate schedules
     * @author Mark Frizzell | 7/10/2019
     * @param Id recId - Schedule generation record Id
     * @return String - Result
     */
    @AuraEnabled
    public static String generateSchedules(Id recId) {
        IETRS_InspSchedConfig__c genRecord;

        // Get schedule generation record details
        try {
            genRecord = [
                SELECT
                    Id,
                    Name,
                    IETRS_Business_Area__c,
                    IETRS_Year__c,
                    IETRS_Schedule_Type__c,
                	IETRS_Regulated_Entity_Type__c,
                    RecordType.DeveloperName,
                    IETRS_Status__c,
                    IETRS_Generated_Date__c,
                    IETRS_Value_One__c
                FROM IETRS_InspSchedConfig__c
                WHERE Id = :recId
                LIMIT 1
            ];
        } catch (QueryException qex) {
            return 'Error: ' + qex.getMessage();
        }
        if (genRecord.IETRS_Year__c == null ) {
            return 'Error: Year is required.';
        }

        // Update schedule generation record status
        genRecord.IETRS_Status__c = IETRS_InspScheduleServices.STATUS_GENERATED;
        genRecord.IETRS_Generated_Date__c = Date.today();
        try {
            update genRecord;
        } catch (DmlException dex) {
            return 'Error: ' + dex.getMessage();
        }

        System.debug('Pre Batch genRecord.IETRS_Schedule_Type__c  xzxz:' + genRecord.IETRS_Schedule_Type__c + ' And Id is: ' + genRecord.Id);
        // Call batch class
        if (genRecord.IETRS_Schedule_Type__c == 'Pipeline Specialized Schedule') {
            System.debug('xz This Config going to Pipline Specialized Schedule batch route');
            IETRS_SpecializedInspScheduleBatch schedBatch = new IETRS_SpecializedInspScheduleBatch(genRecord);
            Database.executeBatch(schedBatch, 100);
        } else if (genRecord.IETRS_Schedule_Type__c == 'Pipeline Routine Schedule') {
            System.debug('xz This Config going to Pipeline Routine Schedule batch route');
            IETRS_InspScheduleBatch schedBatch = new IETRS_InspScheduleBatch(genRecord);
            Database.executeBatch(schedBatch, 100);
        }
        return 'Success';
    }
}