/**
 * @author Greg Lovelidge - Sense Corp
 * @date 6/2/2020
 *
 * @description Tests for the create inspection schedule vf page extension class
 */
@isTest
private class IETRS_I_CreateInspScheduleExtensionTest {
    @TestSetup
    static void makeData() {
        IETRS_I_TestUtils testUtils = new IETRS_I_TestUtils();
        testUtils.createData(2, 1);
    }

    @isTest
    private static void isShouldNotHaveValidSelection() {
        // This will include two schedules for different entities, which is invalid
        List<IETRS_InspSchedule__c> schedules = [SELECT Id FROM IETRS_InspSchedule__c];
        Test.startTest();
        PageReference pageRef = Page.IETRS_I_InspSchedule_To_IandIP;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardSetController ssc = new ApexPages.StandardSetController(schedules);
        ssc.setSelected(schedules);
        // Initialize the controller extension
        IETRS_I_CreateInspScheduleExtension ext = new IETRS_I_CreateInspScheduleExtension(ssc);
        Test.stopTest();
        System.assert(!ext.getIsValidSelection(), 'The provided schedule records should not be valid');
    }

    @isTest
    private static void isShouldHaveValidSelection() {
        // Get one schedule
        IETRS_InspSchedule__c schedule = [
            SELECT
                Id,
                IETRS_Organization__c,
                Unit__c,
                IETRS_Type__c,
                IETRS_Inspection_Sub_Type__c,
                IETRS_Inspection_Business_Area__c,
                IETRS_Regulated_Entity__c,
                IETRS_Inspection_Year__c
            FROM IETRS_InspSchedule__c
            LIMIT 1
        ];
        // Clone it
        IETRS_InspSchedule__c matchingSchedule = schedule.clone(false, false, false, false);
        insert matchingSchedule;
        List<IETRS_InspSchedule__c> validSchedules = new List<IETRS_InspSchedule__c>{ schedule, matchingSchedule };
        Test.startTest();
        PageReference pageRef = Page.IETRS_I_InspSchedule_To_IandIP;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardSetController ssc = new ApexPages.StandardSetController(validSchedules);
        ssc.setSelected(validSchedules);
        // Initialize the controller extension
        IETRS_I_CreateInspScheduleExtension ext = new IETRS_I_CreateInspScheduleExtension(ssc);
        Boolean value = ext.getInspectionAlreadyExists();
        Boolean value2 = ext.getIsEmpty();
        String value3 = ext.getInspectionsJson();
        Test.stopTest();
        System.assert(ext.getIsValidSelection(), 'The provided schedule records should not be valid');
    }
}