/**
 * @author Greg Lovelidge - Sense Corp
 * @date 6/1/2020
 *
 * @description Test methods for the inspection trigger.
 */
@isTest
public class IETRS_I_Inspection_TriggerTest {
    @TestSetup
    static void makeData() {
        IETRS_I_TestUtils testUtils = new IETRS_I_TestUtils();
        testUtils.createData(1, 1);
    }
    @isTest
    static void itShouldPreventSavingTwoStandardInspections() {
        // clone the existing inspection
        Boolean testPassed = false;
        IETRS_Inspection__c existingInspection = [
            SELECT
                Id,
                Name,
                RecordTypeId,
                IETRS_Inspection_Package__c,
                IETRS_Inspection_Status__c,
                IETRS_Regulated_Entity__c
            FROM IETRS_Inspection__c
        ];
        IETRS_Inspection__c newInspection = existingInspection.clone(false, false, false, false);
        Test.startTest();
        try {
            insert newInspection;
        } catch (Exception e) {
            testPassed = true;
        }
        System.assert(testPassed, 'The Standard inspection should have been prevented from being created.');
        
        newInspection = existingInspection.clone(true, true, true, true);
        try {
            delete newInspection;
        } catch (Exception e) {
            testPassed = true;
        }
        System.assert(testPassed, 'The Standard inspection should have been prevented from being created.');
    }
}