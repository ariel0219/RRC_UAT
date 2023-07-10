/**
 * Test class for IETRS_CaseDocumentsController.
 * @author CGI
 */
@IsTest
private with sharing class IETRS_CaseDocumentsControllerTest {
    @TestSetup
    static void makeData() {
        Account acct = new Account(Name = 'Test');
        insert acct;
        String recTypeId = Schema.Sobjecttype.Case.getRecordTypeInfosByName()
            .get('AFS')
            .getRecordTypeId();

        Case c = new Case(
            IETRS_Primary_Account_Assignment__c = acct.Id,
            IETRS_Business_Area__c = 'Alternative Fuels',
            Type = 'AFS',
            RecordTypeId = recTypeId
        );
        insert c;

        IETRS_Files_Correspondence__c fc = new IETRS_Files_Correspondence__c(
            IETRS_Case__c = c.id,
            IETRS_Public__c = true,
            IETRS_Public_Inspection_Document_Created__c = true
        );
        insert fc;

        IETRS_File_Correspondence_Assignment__c rfc = new IETRS_File_Correspondence_Assignment__c(
            IETRS_Case__c = c.Id,
            IETRS_File_and_Correspondence__c = fc.Id
        );
        insert rfc;

        IETRS_Public_File_Correspondence__c caseDoc = new IETRS_Public_File_Correspondence__c(
            IETRS_Case__c = c.Id,
            IETRS_Related_File_Correspondence__c = rfc.Id
        );
        insert caseDoc;
    }

    @IsTest
    static void itShouldGetCaseDocuments() {
        // given - current user is subscribed
        insert new IETRS_Case_Subscription__c(
            IETRS_Case__c = [SELECT Id FROM Case LIMIT 1]
            ?.Id
        );

        // when - get new case documents user is subscribed to
        Test.startTest();
        IETRS_CaseDocumentsController cdCntrl = new IETRS_CaseDocumentsController();
        cdCntrl.cntrlUserId = UserInfo.getUserId();
        cdCntrl.cntrlDocumentDate = System.now().format('yyyy-MM-dd');
        cdCntrl.cntrlDuration = 1;
        List<IETRS_Public_File_Correspondence__c> files = cdCntrl.caseDocuments;
        String siteUrl = cdCntrl.siteUrl;
        Test.stopTest();

        // then - subscribed user can see new
        System.assert(
            files.size() > 0,
            'It should have retrieved case documents.'
        );
    }
}