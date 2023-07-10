/**
 * @File Name          : IETRS_BoxDocusignController_Test.cls
 * @Description        : 
 * @Author             : Mark Frizzell
 * @Group              : 
 * @Last Modified By   : Mark Frizzell
 * @Last Modified On   : 8/20/2019, 7:48:17 PM
 * @Modification Log   : 
 *==============================================================================
 * Ver         Date                     Author      		      Modification
 *==============================================================================
 * 1.0    7/10/2019, 1:20:01 AM   Mark Frizzell     Initial Version
**/
@IsTest
private class IETRS_BoxDocusignController_Test {
    

    static void setupRecords() {
        System.debug('setupRecords()');
        Profile testProfile = [SELECT Id FROM Profile WHERE Name = 'IETRS Case - Docket Services' LIMIT 1]; 
        
        // User
        User testUser = new User(
            Alias = 'testu', Email='ajnvndhdf@lksdjfkl.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = testProfile.Id, 
            TimeZoneSidKey='America/Chicago', UserName='ajnvndhdf@lksdjfkl.com'
        );
        insert testUser;
        System.debug('testUser: ' + testUser);

        // F&C
        IETRS_Files_Correspondence__c testFC = new IETRS_Files_Correspondence__c(
            IETRS_File_Name__c = 'test.txt'
        );
        insert testFC;
        System.debug('testFC: ' + [SELECT Id, Name FROM IETRS_Files_Correspondence__c WHERE Id = :testFC.Id LIMIT 1]);

        // String authResponse = BoxTestJsonResponseFactory.AUTH_USER_TOKEN;
        // Test.setMock(HttpCalloutMock.class, new BoxTestMockCallout(authResponse, 'OK', 200));
    }


    static void setupFiles() {
        System.debug('setupFiles()');
        Id fcId = [SELECT Id FROM IETRS_Files_Correspondence__c LIMIT 1].Id;
        
        ContentVersion testCV = new ContentVersion(
            Title           = 'Test',
            PathOnClient    = 'Test.txt',
            VersionData     = Blob.valueOf('test data'),
            IsMajorVersion  = true
        );
        insert testCV;
        System.debug('testCV: ' + [SELECT Id, Title, PathOnClient, FileType, FileExtension FROM ContentVersion WHERE Id = :testCV.Id LIMIT 1]);

        ContentDocumentLink testCDL = new ContentDocumentLink(
            LinkedEntityId = fcId,
            ContentDocumentId = [SELECT Id FROM ContentDocument LIMIT 1].Id,
            ShareType = 'V'
        );
        insert testCDL;
        System.debug('testCDL: ' + [SELECT Id, LinkedEntityId, ContentDocumentId, ShareType FROM ContentDocumentLink WHERE Id = :testCDL.Id LIMIT 1]);
    }


    @IsTest
    static void testDownload_Positive() {
        setupRecords();
        setupFiles();
        Id fcId = [SELECT Id FROM IETRS_Files_Correspondence__c LIMIT 1].Id;

        Test.startTest();
            IETRS_BoxDocusignController.downloadFile(fcId);
        Test.stopTest();
    }


    @IsTest
    static void testDownload_Negative_NoFnC() {
        Test.startTest();
            IETRS_BoxDocusignController.downloadFile(null);
        Test.stopTest();
    }


    @IsTest
    static void testDownload_Negative_NoDoc() {
        setupRecords();
        
        Test.startTest();
            IETRS_BoxDocusignController.downloadFile(null);
        Test.stopTest();
    }


    @IsTest
    static void testBuildUrl_Positive() {
        setupRecords();
        Id fcId = [SELECT Id FROM IETRS_Files_Correspondence__c LIMIT 1].Id;
        
        Test.startTest();
            IETRS_BoxDocusignController.buildURL(fcId);
        Test.stopTest();
    }
}