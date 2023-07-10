@isTest
public with sharing class IETRS_Refer_To_LE_From_Pipes_Test {
    @testSetup
    static void testData(){
        Account acct = new Account(Name = 'Test');
        insert acct;
        String strPSRecTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName()
            .get('Pipeline Safety')
            .getRecordTypeId();

        Case c = new Case(
            IETRS_Primary_Account_Assignment__c = acct.Id,
            IETRS_Business_Area__c = 'Pipeline Safety',
            Type = 'PSE',
            RecordTypeId = strPSRecTypeId
        );
        insert c;
        List<String> lstCaseIds = new List<String>{ c.Id };

        IETRS_Files_Correspondence__c fc = new IETRS_Files_Correspondence__c(IETRS_Case__c = c.id);
        insert fc;

        IETRS_File_Correspondence_Assignment__c rfc = new IETRS_File_Correspondence_Assignment__c(
            IETRS_Case__c = c.Id,
            IETRS_File_and_Correspondence__c = fc.Id
        );
        insert rfc;

    }
    public static testMethod void IETRS_Refer_To_LE_From_Pipes_Test() {
        List<String> lstCaseIds = new List<String>();
        lstCaseIds.add([SELECT ID FROM Case].Id);
        Test.StartTest();
        IETRS_Refer_To_LE_From_Pipes.IETRS_Refer_To_LE_From_Pipes(lstCaseIds);
        Case caseReturned = [
            SELECT
                RecordTypeId,
                IETRS_Refer_to_Legal_Enforcement__c,
                IETRS_Pending_Legal_Acceptance__c,
                IETRS_PS_Compliance_Status__c
            FROM Case
            WHERE Id = :lstCaseIds[0]
        ];
        String strLERecTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName()
            .get('Legal Enforcement')
            .getRecordTypeId();
        //Assert that the Case Record Type has changed to Legal Enforcement
        system.assertEquals(strLERecTypeId, caseReturned.RecordTypeId);
        //Assert that the Case is Pending Legal Acceptance
        system.assertEquals(true, caseReturned.IETRS_Pending_Legal_Acceptance__c);
        //Assert that the Pipeline Compliance Status is set to the
        system.assertEquals(System.Label.IETRS_Assigned_to_Legal_Pick_Val, caseReturned.IETRS_PS_Compliance_Status__c);

        Test.StopTest();
    }
    public static testMethod void CIIS_Refer_To_Hearings_Test(){
        List<String> lstCaseIds = new List<String>();
        lstCaseIds.add([SELECT ID FROM Case].Id);
        Test.StartTest();
		CIIS_Refer_To_Hearings.CIIS_Refer_To_Hearings(lstCaseIds);
        Case caseReturned = [
            SELECT
                RecordTypeId,
                IETRS_Refer_to_Legal_Enforcement__c,
                IETRS_Pending_Legal_Acceptance__c,
                IETRS_PS_Compliance_Status__c
            FROM Case
            WHERE Id IN :lstCaseIds
        ];
        String strLERecTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName()
            .get('Hearings')
            .getRecordTypeId();
        //Assert that the Case Record Type has changed to Legal Enforcement
        system.assertEquals(strLERecTypeId, caseReturned.RecordTypeId);
        Test.StopTest();
    }
}