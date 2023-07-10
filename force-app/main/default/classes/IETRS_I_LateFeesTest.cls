/**
 * @author Greg Lovelidge - Sense Corp
 * @date 6/1/2020
 *
 * @description Tests for the late fees functionality
 */
@isTest
private class IETRS_I_LateFeesTest {
    @TestSetup
    static void makeData() {
        // Create test data
        IETRS_I_TestUtils testUtils = new IETRS_I_TestUtils();
        testUtils.createData(2, 2);
        // Create late fees
        IETRS_I_GenerateFeesController distC = new IETRS_I_GenerateFeesController();
        IETRS_I_GenerateFeesController mmC = new IETRS_I_GenerateFeesController();
        distC.selectedYear = '2020';
        distC.selectedFeeType = 'Distribution';
        mmC.selectedYear = '2020';
        mmC.selectedFeeType = 'Master Meter';
        distC.save();
        mmC.save();
    }

    @isTest
    static void itShouldScheduleLateFeesJob() {
        String CRON_EXP = '0 0 0 15 3 ? 2022';
        Test.startTest();
        String jobId = System.schedule('Apply Late Fees Test', CRON_EXP, new IETRS_I_LateFeesSchedulable());
        Test.stopTest();
        System.assert(String.isNotBlank(jobId), 'The job was not scheduled');
    }

    @isTest
    static void itShouldApplyLateFees() {
        // the 2020 metadata exists and should always exist, so safe to use for tests
        Integer testYear = 2020;
        Conga_Components__mdt penaltyDates = [
            SELECT IETRS_Distribution_Fees_Delinquency_Date__c, IETRS_Master_Meter_Fees_Delinquency_Date__c
            FROM Conga_Components__mdt
            LIMIT 1
        ];
        Date distributionLateFeeDate = Date.newInstance(
            testYear,
            penaltyDates.IETRS_Distribution_Fees_Delinquency_Date__c.month(),
            penaltyDates.IETRS_Distribution_Fees_Delinquency_Date__c.day()
        );
        Date mmLateFeeDate = Date.newInstance(
            testYear,
            penaltyDates.IETRS_Master_Meter_Fees_Delinquency_Date__c.month(),
            penaltyDates.IETRS_Master_Meter_Fees_Delinquency_Date__c.day()
        );

        Test.startTest();
        // Generate distribution late fees
        new IETRS_I_LateFees(distributionLateFeeDate);
        // Generate mm late fees
        new IETRS_I_LateFees(mmLateFeeDate);
        Test.stopTest();

        // Ensure that late fees were set
        IETRS_Insp_Regulated_Fee__c fee = [
            SELECT Id, IETRS_Late_Fee__c
            FROM IETRS_Insp_Regulated_Fee__c
            WHERE IETRS_Status__c = 'Not Paid'
            ORDER BY LastModifiedDate DESC
            LIMIT 1
        ];
        System.assert(fee.IETRS_Late_Fee__c > 0, 'The late fee was not set correctly');
    }

    @isTest
    static void itShouldNotApplyLateFees() {
        // the 2020 metadata exists and should always exist, so safe to use for tests
        Integer testYear = 2020;
        Conga_Components__mdt penaltyDates = [
            SELECT IETRS_Distribution_Fees_Delinquency_Date__c, IETRS_Master_Meter_Fees_Delinquency_Date__c
            FROM Conga_Components__mdt
            LIMIT 1
        ];
        Date distributionLateFeeDate = Date.newInstance(
            testYear,
            penaltyDates.IETRS_Distribution_Fees_Delinquency_Date__c.month(),
            penaltyDates.IETRS_Distribution_Fees_Delinquency_Date__c.day()
        );
        Date mmLateFeeDate = Date.newInstance(
            testYear,
            penaltyDates.IETRS_Master_Meter_Fees_Delinquency_Date__c.month(),
            penaltyDates.IETRS_Master_Meter_Fees_Delinquency_Date__c.day()
        );

        // Use a date when late fees should not be added
        Date noLateFeeDate = distributionLateFeeDate.addDays(1);
        if (noLateFeeDate == mmLateFeeDate)
            noLateFeeDate.addDays(1);

        Test.startTest();
        // Test sending a date when late fees should not be generated
        new IETRS_I_LateFees(noLateFeeDate);
        Test.stopTest();

        // Ensure that late fees were set
        IETRS_Insp_Regulated_Fee__c fee = [
            SELECT Id, IETRS_Late_Fee__c
            FROM IETRS_Insp_Regulated_Fee__c
            WHERE IETRS_Status__c = 'Not Paid'
            ORDER BY LastModifiedDate DESC
            LIMIT 1
        ];
        System.assert(
            fee.IETRS_Late_Fee__c == null ||
            fee.IETRS_Late_Fee__c == 0,
            'The late fee was set, but should not have been'
        );
    }
}