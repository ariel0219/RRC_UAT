/**
 * @File Name          : IETRS_BoxUpload_Test.cls
 * @Description        :
 * @Author             : Mark Frizzell
 * @Group              :
 * @Last Modified By   : Mark Frizzell
 * @Last Modified On   : 8/20/2019, 6:42:11 PM
 * @Modification Log   :
 *==============================================================================
 * Ver         Date                     Author      		      Modification
 *==============================================================================
 * 1.0    7/10/2019, 1:16:04 AM   Mark Frizzell     Initial Version
 **/
@IsTest
private class IETRS_BoxUpload_Test {
    static void setupRecords(String parentType) {
        System.debug('setupRecords(' + parentType + ')');
        Profile testProfile = [SELECT Id FROM Profile WHERE Name = 'IETRS Case - Docket Services' LIMIT 1];

        // User
        User testUser = new User(
            Alias = 'testu',
            Email = 'ajnvndhdf@lksdjfkl.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Testing',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = testProfile.Id,
            TimeZoneSidKey = 'America/Chicago',
            UserName = 'ajnvndhdf@lksdjfkl.com'
        );
        insert testUser;
        System.debug('testUser: ' + testUser);

        // Account (Regulated Entity)
        Id entityRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Regulated_Entity_OG')
            .getRecordTypeId();
        Account testAcct = new Account(RecordTypeId = entityRecordTypeId, Name = 'Test RE Account');
        insert testAcct;

        // Case
        Case testCase = new Case();
        insert testCase;
        System.debug('testCase: ' + [SELECT Id, CaseNumber FROM Case WHERE Id = :testCase.Id LIMIT 1]);

        // Violation
        IETRS_Violation__c testViolation = new IETRS_Violation__c(IETRS_Regulated_Entity__c = testAcct.Id);
        insert testViolation;

        // AG Referral
        IETRS_Attorney_General_Referral__c testAGRef = new IETRS_Attorney_General_Referral__c();
        insert testAGRef;

        // F&C
        IETRS_Files_Correspondence__c testFC = new IETRS_Files_Correspondence__c();
        switch on parentType {
            when 'Case' {
                testFC.IETRS_Case__c = testCase.Id;
            }
            when 'Violation' {
                testFC.IETRS_Violation__c = testViolation.Id;
            }
            when 'AGRef' {
                testFC.IETRS_Attorney_General_Referral__c = testAGRef.Id;
            }
        }
        insert testFC;
        System.debug(
            'testFC: ' +
            [SELECT Id, Name, IETRS_Case__c FROM IETRS_Files_Correspondence__c WHERE Id = :testFC.Id LIMIT 1]
        );
    }

    static void setupFiles(Boolean largeFile) {
        System.debug('setupFiles()');
        Id fcId = [SELECT Id FROM IETRS_Files_Correspondence__c LIMIT 1].Id;

        ContentVersion testCV = new ContentVersion(
            Title = 'Test',
            PathOnClient = 'Test.txt',
            VersionData = largeFile ? Blob.valueOf('a'.repeat(4001)) : Blob.valueOf('test data'),
            IsMajorVersion = true
        );
        insert testCV;
        System.debug(
            'testCV: ' +
            [SELECT Id, Title, PathOnClient, FileType, FileExtension FROM ContentVersion WHERE Id = :testCV.Id LIMIT 1]
        );

        ContentDocumentLink testCDL = new ContentDocumentLink(
            LinkedEntityId = fcId,
            ContentDocumentId = [SELECT Id FROM ContentDocument LIMIT 1]
            .Id,
            ShareType = 'V'
        );
        insert testCDL;
        System.debug(
            'testCDL: ' +
            [
                SELECT Id, LinkedEntityId, ContentDocumentId, ShareType
                FROM ContentDocumentLink
                WHERE Id = :testCDL.Id
                LIMIT 1
            ]
        );
    }

    @IsTest
    static void testUpload_CaseParent_Positive() {
        setupRecords('Case');
        setupFiles(false);

        String authResponse = BoxTestJsonResponseFactory.AUTH_USER_TOKEN;
        Test.setMock(HttpCalloutMock.class, new BoxTestMockCallout(authResponse, 'OK', 200));

        List<Id> fcIds = new List<Id>{ [SELECT Id FROM IETRS_Files_Correspondence__c LIMIT 1].Id };

        Test.startTest();
        IETRS_BoxUpload.init(fcIds);
        Test.stopTest();
    }

    @IsTest
    static void testUpload_ViolationParent_Positive() {
        setupRecords('Violation');
        setupFiles(false);

        String authResponse = BoxTestJsonResponseFactory.AUTH_USER_TOKEN;
        Test.setMock(HttpCalloutMock.class, new BoxTestMockCallout(authResponse, 'OK', 200));

        List<Id> fcIds = new List<Id>{ [SELECT Id FROM IETRS_Files_Correspondence__c LIMIT 1].Id };

        Test.startTest();
        IETRS_BoxUpload.init(fcIds);
        Test.stopTest();
    }

    @IsTest
    static void testUpload_AGRefParent_Positive() {
        setupRecords('AGRef');
        setupFiles(false);

        String authResponse = BoxTestJsonResponseFactory.AUTH_USER_TOKEN;
        Test.setMock(HttpCalloutMock.class, new BoxTestMockCallout(authResponse, 'OK', 200));

        List<Id> fcIds = new List<Id>{ [SELECT Id FROM IETRS_Files_Correspondence__c LIMIT 1].Id };

        Test.startTest();
        IETRS_BoxUpload.init(fcIds);
        Test.stopTest();
    }

    @IsTest
    static void testUpload_NoParent_Positive() {
        setupRecords('None');
        setupFiles(false);

        String authResponse = BoxTestJsonResponseFactory.AUTH_USER_TOKEN;
        Test.setMock(HttpCalloutMock.class, new BoxTestMockCallout(authResponse, 'OK', 200));

        List<Id> fcIds = new List<Id>{ [SELECT Id FROM IETRS_Files_Correspondence__c LIMIT 1].Id };

        Test.startTest();
        IETRS_BoxUpload.init(fcIds);
        Test.stopTest();
    }

    @IsTest
    static void testUpload_LargeFile_Negative() {
        setupRecords('Case');
        setupFiles(true);

        String authResponse = BoxTestJsonResponseFactory.AUTH_USER_TOKEN;
        Test.setMock(HttpCalloutMock.class, new BoxTestMockCallout(authResponse, 'OK', 200));

        List<Id> fcIds = new List<Id>{ [SELECT Id FROM IETRS_Files_Correspondence__c LIMIT 1].Id };

        Test.startTest();
        IETRS_BoxUpload.init(fcIds);
        Test.stopTest();
    }

    @IsTest
    static void testSendEmail() {
        Test.startTest();
        IETRS_BoxUpload.sendEmail('message');
        Test.stopTest();
    }
}