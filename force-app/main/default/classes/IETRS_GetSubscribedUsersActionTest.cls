/**
 * Test class for the IETRS_GetSubscribedUsersAction class.
 * @author CGI
 */
@IsTest
private with sharing class IETRS_GetSubscribedUsersActionTest {
    @TestSetup
    static void makeData() {
        // create test data
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
    static void itShouldGetSubscribedUsersFromCaseDocs() {
        // given - a user is subscribed to a case with a case document
        IETRS_Case_Subscription__c cs = new IETRS_Case_Subscription__c(
            IETRS_Case__c = [SELECT Id FROM Case LIMIT 1]
            ?.Id
        );
        insert cs;
        Test.setCreatedDate(
            [SELECT Id FROM IETRS_Public_File_Correspondence__c]
            ?.Id,
            Datetime.now().addDays(-1)
        );
        System.debug(
            [SELECT format(CreatedDate) FROM IETRS_Case_Subscription__c LIMIT 1]
        );
        // when - request subscribed users
        Test.startTest();
        List<String> userIds = IETRS_GetSubscribedUsersAction.execute()[0];
        Test.stopTest();

        // then - the subscribed user is included in the result
        System.assertEquals(
            String.valueOf(UserInfo.getUserId()),
            userIds[0],
            'The result should have included the subscribed user\'s id'
        );
    }
}