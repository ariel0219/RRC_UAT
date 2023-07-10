@isTest
private class IETRS_I_SObjectLookupControllerTest {
    @TestSetup
    static void makeData() {
        insert new IETRS_Regulatory_Codes__c(
            IETRS_Business_Area__c = 'Alternative Fuels',
            IETRS_Description__c = 'test',
            IETRS_Rulebook_Source__c = 'LP-Gas Safety Rule',
            IETRS_Business_Area_Text__c = 'AF',
            Name = '9.103(c)',
            IETRS_Active__c = true
        );
    }

    @isTest
    private static void itShouldSearchRegCodes() {
        List<IETRS_Regulatory_Codes__c> results = new List<IETRS_Regulatory_Codes__c>();
        Test.startTest();
        results = (List<IETRS_Regulatory_Codes__c>) IETRS_I_SObjectLookupController.searchRecords(
            'IETRS_Regulatory_Codes__c',
            '9.103'
        );
        Test.stopTest();
        System.assert(results.size() > 0, 'The search should have returned results');
    }
}