@isTest
private class IETRS_UploadDocumentTest {
    @TestSetup
    static void makeData() {
        IETRS_Files_Correspondence__c fc = new IETRS_Files_Correspondence__c();
        insert fc;

        ContentVersion testCV = new ContentVersion(
            Title = 'Test File',
            PathOnClient = 'TestFile.txt',
            VersionData = Blob.valueOf('test data'),
            IsMajorVersion = true
        );
        insert testCV;

        ContentDocument newCD = [SELECT Id FROM ContentDocument LIMIT 1];

        ContentDocumentLink testCDL = new ContentDocumentLink(
            LinkedEntityId = fc.Id,
            ContentDocumentId = newCD.Id,
            ShareType = 'V'
        );
        insert testCDL;
    }

    @isTest
    static void itShouldUploadDocument() {
        IETRS_Files_Correspondence__c fc = [SELECT Id FROM IETRS_Files_Correspondence__c LIMIT 1];
        Test.startTest();
        IETRS_UploadDocument.prepareUploadAsync(new Set<Id>{ fc.Id });
        Test.stopTest();
    }
}