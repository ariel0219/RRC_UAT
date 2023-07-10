/**
 * @author Greg Lovelidge - Sense Corp
 * @date 5/28/2020
 *
 * @description Tests for the generate fees functionality
 */

@isTest
private class IETRS_I_GenerateFees_Test {
    @testSetup
    static void makeData() {
        IETRS_I_TestUtils testUtils = new IETRS_I_TestUtils();
        testUtils.createData(2, 2);
    }

    @isTest
    private static void itShouldGenerateNewDistributionFees() {
        Test.startTest();
        IETRS_I_GenerateFeesController c = new IETRS_I_GenerateFeesController();
        c.selectedYear = '2020';
        c.selectedFeeType = 'Distribution';
        c.save();
        Test.stopTest();
        Integer feesCount = [SELECT COUNT() FROM IETRS_Insp_Regulated_Fee__c];
        System.assert(feesCount > 0, 'Distribution fees should have been generated.');
    }

    @isTest
    private static void itShouldGenerateNewMMFees() {
        Test.startTest();
        IETRS_I_GenerateFeesController c = new IETRS_I_GenerateFeesController();
        c.selectedYear = '2020';
        c.selectedFeeType = 'Master Meter';
        c.save();
        Test.stopTest();
        Integer feesCount = [SELECT COUNT() FROM IETRS_Insp_Regulated_Fee__c];
        System.assert(feesCount > 0, 'Master Meter fees should have been generated.');
    }

    @isTest
    private static void itShouldReplaceExistingFees() {
        // Create new fees so they exist
        IETRS_I_GenerateFeesController c = new IETRS_I_GenerateFeesController();
        c.selectedYear = String.valueof(System.Today().year());
        c.selectedFeeType = 'Master Meter';
        c.save();
        // store the fee ids
        Set<Id> feeIds = new Set<Id>();
        for (IETRS_Insp_Regulated_Fee__c fee : [
            SELECT Id
            FROM IETRS_Insp_Regulated_Fee__c
            ORDER BY CreatedDate DESC
            LIMIT 1
        ]) {
            feeIds.add(fee.Id);
        }
        Test.startTest();
        IETRS_I_GenerateFeesController c2 = new IETRS_I_GenerateFeesController();
        // Attempt to save...
        c2.selectedYear = String.valueof(System.Today().year());
        c2.selectedFeeType = 'Master Meter';
        c2.save();
        // Then save and remove existing
        c2.saveAndRemoveExisting();
        Test.stopTest();

        Integer oldFeesCount = [SELECT COUNT() FROM IETRS_Insp_Regulated_Fee__c WHERE Id IN :feeIds];
        System.assert(!feeIds.isEmpty() && oldFeesCount == 0, 'The old fees should have been removed.');
    }

    @isTest
    private static void itShouldAddToExistingFees() {
        Test.startTest();
        Integer initialFeesCount = [SELECT COUNT() FROM IETRS_Insp_Regulated_Fee__c];
        // Create new fees so they exist
        IETRS_I_GenerateFeesController c = new IETRS_I_GenerateFeesController();
        c.selectedYear = '2020';
        c.selectedFeeType = 'Distribution';
        c.save();
        // store the initial fees count
        // Add more data
        IETRS_I_TestUtils testUtils = new IETRS_I_TestUtils();
        testUtils.createData(2, 2);
        Test.stopTest();

        Integer newFeesCount = [SELECT COUNT() FROM IETRS_Insp_Regulated_Fee__c];
        System.assert(initialFeesCount != newFeesCount, 'New fees should have been added.');
    }
    
    @isTest
    private static void itShouldAddToExistingFees2() {
        Integer initialFeesCount = [SELECT COUNT() FROM IETRS_Insp_Regulated_Fee__c];
        Test.startTest();
        IETRS_I_GenerateFeesController c2 = new IETRS_I_GenerateFeesController();
        // Attempt to save...
        c2.selectedYear = '2020';
        c2.selectedFeeType = 'Distribution';
        c2.save();
        // Then save and keep existing
        c2.saveAndKeepExisting();
        Test.stopTest();
        Integer newFeesCount = [SELECT COUNT() FROM IETRS_Insp_Regulated_Fee__c];
        System.assert(initialFeesCount != newFeesCount, 'New fees should have been added.');
    }

    @isTest
    private static void itShouldFail() {
        Test.startTest();
        IETRS_I_GenerateFeesController c = new IETRS_I_GenerateFeesController();
        c.getFeeTypeOptions();
        // Attempt to save with  no selected fee type
        c.save();
        // Then save with an invalid selected fee type
        c.selectedFeeType = 'blahblahblah';
        c.save();
        // Then pass in a bad selected year
        c.selectedFeeType = 'Distribution';
        c.selectedYear = '9999';
        c.save();
        Test.stopTest();
        Integer newFeesCount = [SELECT COUNT() FROM IETRS_Insp_Regulated_Fee__c];
        System.assert(newFeesCount == 0, 'No fees should have been generated.');
    }
}