@isTest
public class IETRS_UpdateInspectionResultsTest {
    @testSetup
    static void createData() {
        Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Regulated_Entity_PS')
            .getRecordTypeId();
        Account objAcc = new Account(Name = 'Regulated Entity PS');
        objAcc.RecordTypeId = accRecordTypeId;
        objAcc.Type = 'Distribution';
        insert objAcc;

        IETRS_Inspection_Package__c objInspPkg = new IETRS_Inspection_Package__c();
        objInspPkg.IETRS_Inspection_Type__c = 'Standard';
        insert objInspPkg;

        Id inspRecordTypeId = Schema.SObjectType.IETRS_Inspection__c.getRecordTypeInfosByDeveloperName()
            .get('PS_Inspection_Distribution_Systems')
            .getRecordTypeId();
        IETRS_Inspection__c objInsp = new IETRS_Inspection__c();
        objInsp.IETRS_Inspection_Package__c = objInspPkg.Id;
        objInsp.IETRS_Inspection_Status__c = 'Incomplete';
        objInsp.IETRS_Regulated_Entity__c = objAcc.Id;
        objInsp.RecordTypeId = inspRecordTypeId;
        insert objInsp;

        IETRS_Insp_Inspection_Result__c objInspResult = new IETRS_Insp_Inspection_Result__c();
        objInspResult.IETRS_Inspection__c = objInsp.Id;
        objInspResult.IETRS_Inspection_Package__c = objInspPkg.Id;
        objInspResult.IETRS_Tab__c = 'Field Inspection';
        insert objInspResult;
    }

    @isTest
    static void testGetInspectionResults() {
        IETRS_Insp_Inspection_Result__c objInspResult = [
            SELECT Id, IETRS_Tab__c
            FROM IETRS_Insp_Inspection_Result__c
            LIMIT 1
        ];
        IETRS_Inspection__c objInsp = [SELECT Id FROM IETRS_Inspection__c LIMIT 1];
        IETRS_Inspection_Package__c objInspPkg = [SELECT Id FROM IETRS_Inspection_Package__c LIMIT 1];
        IETRS_UpdateInspectionResults.getInspectionResults(objInsp.Id, 'Field Inspection');
        IETRS_UpdateInspectionResults.getInspectionResults(objInspPkg.Id, 'Field Inspection');
        objInspResult.IETRS_Tab__c = 'Records Review';
        IETRS_UpdateInspectionResults.saveRecords(new List<IETRS_Insp_Inspection_Result__c>{ objInspResult });
    }
}