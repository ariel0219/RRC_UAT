/**
 * @File Name          : IETRS_BoxTriggerServices_Test.cls
 * @Description        : 
 * @Author             : Mark Frizzell
 * @Group              : 
 * @Last Modified By   : Mark Frizzell
 * @Last Modified On   : 8/20/2019, 11:06:49 PM
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author      		      Modification
 *==============================================================================
 * 1.0    7/10/2019, 1:16:17 AM   Mark Frizzell     Initial Version
**/
@IsTest
private class IETRS_BoxTriggerServices_Test {
    
    
    static void setup() {
        // Case
        Case testCase = new Case();
        insert testCase;
        System.debug('testCase: ' + [SELECT Id, CaseNumber FROM Case WHERE Id = :testCase.Id LIMIT 1]);

        // F&C
        IETRS_Files_Correspondence__c testFC = new IETRS_Files_Correspondence__c(
            IETRS_Case__c = testCase.Id
        );
        insert testFC;
        System.debug('testFC: ' + [SELECT Id, Name, IETRS_Case__c FROM IETRS_Files_Correspondence__c WHERE Id = :testFC.Id LIMIT 1]);
    }


    static void setup2() {
        Id fcId = [SELECT Id FROM IETRS_Files_Correspondence__c LIMIT 1].Id;
        
        // DS Status
        dsfs__DocuSign_Status__c dsStatus = new dsfs__DocuSign_Status__c(
            IETRS_Files_Correspondence__c = fcId
        );
        insert dsStatus;
        System.debug('dsStatus: ' + [SELECT Id, IETRS_Files_Correspondence__r.IETRS_Box_File_Folder__c FROM dsfs__DocuSign_Status__c LIMIT 1]);

        // Content Version
        ContentVersion testCV = new ContentVersion(
            Title           = 'Test',
            PathOnClient    = 'Test.txt',
            VersionData     = Blob.valueOf('test data'),
            IsMajorVersion  = true
        );
        insert testCV;
    }


    @IsTest
    static void testStatusTrigger_Insert_Positive() {
        setup();
        Id fcId = [SELECT Id FROM IETRS_Files_Correspondence__c LIMIT 1].Id;
        dsfs__DocuSign_Status__c dsStatus = new dsfs__DocuSign_Status__c(
            IETRS_Files_Correspondence__c = fcId,
            dsfs__Envelope_Status__c = 'Sent'
        );

        Test.startTest();
            insert dsStatus;
        Test.stopTest();
    }
    

    @IsTest
    static void testStatusTrigger_Update_Positive() {
        setup();
        setup2();
        Id fcId = [SELECT Id FROM IETRS_Files_Correspondence__c LIMIT 1].Id;
        dsfs__DocuSign_Status__c dsStatus = [SELECT Id, dsfs__Envelope_Status__c FROM dsfs__DocuSign_Status__c LIMIT 1];

        Test.startTest();
            dsStatus.dsfs__Envelope_Status__c = 'Sent';
            update dsStatus;
        Test.stopTest();
    }


    @IsTest
    static void testCdlTrigger_Positive() {
        setup();
        setup2();
        Id fcId = [SELECT Id FROM IETRS_Files_Correspondence__c LIMIT 1].Id;
        
        dsfs__DocuSign_Status__c dsStatus = [SELECT Id, dsfs__Envelope_Status__c FROM dsfs__DocuSign_Status__c LIMIT 1];
        dsStatus.dsfs__Envelope_Status__c = 'Completed';
        update dsStatus;

        ContentDocumentLink testCDL = new ContentDocumentLink(
            LinkedEntityId = dsStatus.Id,
            ContentDocumentId = [SELECT Id FROM ContentDocument LIMIT 1].Id,
            ShareType = 'V'
        );

        Test.startTest();
            insert testCDL;
        Test.stopTest();
    }


    @IsTest
    static void testUpload_Positive() {
        setup();
        setup2();
        dsfs__DocuSign_Status__c dsStatus = [SELECT Id FROM dsfs__DocuSign_Status__c LIMIT 1];
        ContentDocumentLink testCDL = new ContentDocumentLink(
            LinkedEntityId = dsStatus.Id,
            ContentDocumentId = [SELECT Id FROM ContentDocument LIMIT 1].Id,
            ShareType = 'V'
        );
        insert testCDL;

        Test.startTest();
            IETRS_BoxTriggerServices.uploadFiles(new Set<Id> { dsStatus.Id });
        Test.stopTest();
    }

}