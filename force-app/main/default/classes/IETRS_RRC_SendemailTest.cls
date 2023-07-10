@isTest
public class IETRS_RRC_SendemailTest {
    @TestSetup
    static void prepareData() {
        IETRS_I_TestUtils testUtils = new IETRS_I_TestUtils();
        // configure a test PS entity, unit and org
        testUtils.entityFieldValuesByField.put(
            Account.IETRS_Product_Class__c,
            new List<String>{ 'Gas' }
        );
        testUtils.entityFieldValuesByField.put(
            Account.Type,
            new List<String>{ 'Distribution' }
        );
        testUtils.entityFieldValuesByField.put(
            Account.IETRS_Entity_Sub_Type__c,
            new List<String>{ 'Private Main System' }
        );
        testUtils.entityFieldValuesByField.put(
            Account.IETRS_Product_Sub_Class__c,
            new List<String>{ 'Natural' }
        );
        testUtils.entityFieldValuesByField.put(
            Account.IETRS_Business_Area__c,
            new List<String>{ 'Pipeline Safety' }
        );
        testUtils.entityFieldValuesByField.put(
            Account.IETRS_Status__c,
            new List<String>{ 'Active' }
        );
        testUtils.createData(1, 1);

        IETRS_Files_Correspondence__c testFC = new IETRS_Files_Correspondence__c(
            IETRS_File_Name__c = 'test.txt',
            IETRS_Email_Body__c = 'this is email body',
            IETRS_Subject__c = 'This is email subject'
        );
        insert testFC;

        ContentVersion testCV = new ContentVersion(
            Title = 'Test',
            PathOnClient = 'Test.txt',
            VersionData = Blob.valueOf('test data'),
            IsMajorVersion = true
        );
        insert testCV;

        ContentDocumentLink testCDL = new ContentDocumentLink(
            LinkedEntityId = testFC.Id,
            ContentDocumentId = [SELECT Id FROM ContentDocument LIMIT 1]
            .Id,
            ShareType = 'V'
        );
        insert testCDL;

        List<Contact> lstContToInsert = new List<Contact>();
        Id accId = [SELECT Id FROM Account WHERE Type = 'Distribution' LIMIT 1].Id;
        lstContToInsert.add(new Contact(LastName = 'Test1', Email = 'test1@gmail.com', AccountId = accId));
        lstContToInsert.add(new Contact(LastName = 'Test2', Email = 'test2@gmail.com', AccountId = accId));

        insert lstContToInsert;

        List<IETRS_Insp_Correspondence_Mailing_List__c> mailingList = new List<IETRS_Insp_Correspondence_Mailing_List__c>();
        mailingList.add(
            new IETRS_Insp_Correspondence_Mailing_List__c(
                IETRS_Contact__c = lstContToInsert[0].Id,
                IETRS_Files_and_Correspondence__c = testFC.Id,
                IETRS_To_or_CC__c = 'To'
            )
        );
        mailingList.add(
            new IETRS_Insp_Correspondence_Mailing_List__c(
                IETRS_Contact__c = lstContToInsert[1].Id,
                IETRS_Files_and_Correspondence__c = testFC.Id,
                IETRS_To_or_CC__c = 'CC'
            )
        );
        insert mailingList;
    }

    @isTest
    static void testSendEmail() {
        String recordId = String.valueOf([SELECT Id FROM IETRS_Files_Correspondence__c LIMIT 1].Id);
        String emailAddress;
        for (OrgWideEmailAddress owa : [SELECT Address FROM OrgWideEmailAddress LIMIT 1]) {
            emailAddress = owa.Address;
        }
        IETRS_RRC_Sendemail.sendEmail(recordId, emailAddress);
        try {
            IETRS_RRC_Sendemail.sendEmail(recordId, 'fakeaddress@test.test');
        } catch (Exception e) {
            // cover failing if the org wide address isn't in the system
        }
    }
    
    @isTest
    static void itShouldFailWithBadEmail() {
        String recordId = String.valueOf([SELECT Id FROM IETRS_Files_Correspondence__c LIMIT 1].Id);
        insert new IETRS_RRC_Settings__c(IETRS_FC_Email_From_Address__c = 'badorgwideemail@test.test');
        Test.startTest();
        Boolean isFailed = false;
        try {
            IETRS_RRC_Sendemail.sendEmail(recordId, '');
        } catch (Exception e) {
            isFailed = true;
        }
        Test.stopTest();
        System.assertEquals(true, isFailed);
    }
}