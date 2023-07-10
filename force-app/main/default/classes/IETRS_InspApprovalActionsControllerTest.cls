@isTest
private class IETRS_InspApprovalActionsControllerTest {
    @TestSetup
    static void makeData() {
        IETRS_I_TestUtils testUtils = new IETRS_I_TestUtils();
        testUtils.createData(1, 2);
        // create a IETRS_Inspection_Schedule_Config__c record
        Id scheduleGenerationRecordTypeId = Schema.SObjectType.IETRS_InspSchedConfig__c.getRecordTypeInfosByDeveloperName()
            .get('Schedule_Generation')
            .getRecordTypeId();
        IETRS_InspSchedConfig__c config = new IETRS_InspSchedConfig__c(
            IETRS_Business_Area__c = 'Pipeline Safety',
            IETRS_Year__c = String.valueOf(System.today().year()),
            IETRS_Schedule_Type__c = 'Pipeline Routine Schedule',
            RecordTypeId = scheduleGenerationRecordTypeId
        );
        insert config;
        // set the record id on the existing IETRS_InspSchedule__c records
        List<IETRS_InspSchedule__c> schedules = new List<IETRS_InspSchedule__c>();
        for (IETRS_InspSchedule__c schedule : [SELECT Id FROM IETRS_InspSchedule__c]) {
            schedule.IETRS_Inspection_Schedule_Config__c = config.Id;
            schedules.add(schedule);
        }
        update schedules;
    }

    @isTest
    static void itShouldApproveSchedules() {
        IETRS_InspSchedConfig__c config = [SELECT Id FROM IETRS_InspSchedConfig__c LIMIT 1];
        Integer scheduleCount = [SELECT COUNT() FROM IETRS_InspSchedule__c];
        Test.startTest();
        IETRS_InspApprovalActionsController.approve(config.Id);
        Test.stopTest();
        Integer approvedScheduleCount = [SELECT COUNT() FROM IETRS_InspSchedule__c WHERE IETRS_Approved__c = true];
        System.assertEquals(scheduleCount, approvedScheduleCount, 'All schedules should have been approved');
    }

    @isTest
    static void itShouldUnapproveSchedules() {
        IETRS_InspSchedConfig__c config = [SELECT Id FROM IETRS_InspSchedConfig__c LIMIT 1];
        Integer scheduleCount = [SELECT COUNT() FROM IETRS_InspSchedule__c];
        // set approved to true on all
        List<IETRS_InspSchedule__c> schedules = new List<IETRS_InspSchedule__c>();
        for (IETRS_InspSchedule__c schedule : [SELECT Id FROM IETRS_InspSchedule__c]) {
            schedule.IETRS_Approved__c = true;
            schedules.add(schedule);
        }
        update schedules;
        Test.startTest();
        IETRS_InspApprovalActionsController.unapprove(config.Id);
        Test.stopTest();
        Integer unapprovedScheduleCount = [SELECT COUNT() FROM IETRS_InspSchedule__c WHERE IETRS_Approved__c = false];
        System.assertEquals(scheduleCount, unapprovedScheduleCount, 'All schedules should have been approved');
    }
}