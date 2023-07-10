/**
 * @description       : Test class for PLI EDI File Handler
 * @author            : Steve Villanueva
 * @group             :
 * @last modified on  : 2021-01-11
 * @last modified by  : Steve Villanueva
 * Modifications Log
 * Ver   Date         Author             Modification
 * 1.0   2021-01-11   Steve Villanueva   Initial Version
 **/

@isTest
private class IETRS_PLI_EDI_FileHandler_Test {
    @testSetup
    public static void makeData() {
        List<Account> listOfAccounts = new List<Account>();
        List<Account> listChildAccounts = new List<Account>();
        List<IETRS_Insp_Notification__c> listOfNotifications = new List<IETRS_Insp_Notification__c>();

        Account parentAccount = new Account();
        parentAccount.Name = 'DistributionTestParentAccount';
        parentAccount.recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get('Organization')
            .getRecordTypeId();
        insert parentAccount;

        Contact contactInstance = new Contact();
        contactInstance.LastName = 'test';
        contactInstance.Phone = '191292100120000';
        contactInstance.IETRS_24_Hour_Phone__c = '1912821001000';
        contactInstance.FAX = '12121212';
        contactInstance.Email = 'test@gmail.com';
        contactInstance.Title = 'test Rep';
        contactInstance.AccountId = parentAccount.Id;
        insert contactInstance;

        Account accountUnit = new Account();
        accountUnit.recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get('Unit')
            .getRecordTypeId();
        accountUnit.ParentId = parentAccount.Id;
        accountUnit.Type = 'Distribution';
        accountUnit.IETRS_Representative__c = contactInstance.Id;
        accountUnit.Name = 'DistributionTestAccountUnit';
        insert accountUnit;

        for (Integer i = 0; i < 5; i++) {
            Account accountRE = new Account();
            accountRE.ParentId = accountUnit.Id;
            accountRE.recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
                .get('Regulated Entity - PS')
                .getRecordTypeId();
            accountRE.Name = 'DistributionTestAccountRE' + i;
            accountRe.Type = 'Distribution';
            accountRe.IETRS_Product_Class__c = 'Gas';
            accountRe.IETRS_Entity_Sub_Type__c = 'Private Main System';
            accountRe.IETRS_Product_Sub_Class__c = 'Natural';
            accountRe.IETRS_Business_Area__c = 'Pipeline Safety';
            accountRe.IETRS_Status__c = 'Active';
            accountRe.IETRS_T4_Permit__c = '12345';
            accountRe.IETRS_Install_Year__c = '2000';
            accountRe.IETRS_Total_Miles__c = 1;
            accountRe.IETRS_On_Offshore__c = 'Onshore';
            listChildAccounts.add(accountRE);
        }

        if (listChildAccounts.size() > 0) {
            insert listChildAccounts;
            for (Account acctRE : listChildAccounts) {
                String reportPeriod = '';
                Date dt = System.today();
                Integer year = dt.Year();
                if (dt.month() == 12) {
                    year += 1;
                    reportPeriod = String.valueOf(year) + ' ' + 'Jan-Jun';
                } else {
                    reportPeriod = String.valueOf(year) + ' ' + 'Jul-Dec';
                }
                IETRS_Insp_Notification__c notificationRecord = new IETRS_Insp_Notification__c();
                notificationRecord.IETRS_PS95_Organization__c = parentAccount.Id;
                notificationRecord.RecordTypeId = Schema.SObjectType.IETRS_Insp_Notification__c.getRecordTypeInfosByName()
                    .get('PS-95')
                    .getRecordTypeId();
                notificationRecord.IETRS_Submitted__c = 'No';
                notificationRecord.IETRS_Report_Period__c = reportPeriod;
                listOfNotifications.add(notificationRecord);
            }
        }

        if (listOfNotifications.size() > 0) {
            insert listOfNotifications;
            System.debug('listOfNotifications: ' + listOfNotifications);
        }
    }
    //saveEDIRepairedLeaks(List<IETRS_Insp_Notification_Detail__c> eDISavedRpredLeak)
    @isTest
    static void testSaveEDIRepairedLeaks() {
        Account acctRE = [
            SELECT id
            FROM Account
            WHERE RecordType.Name = 'Regulated Entity - PS'
            LIMIT 1
        ];
        List<IETRS_Insp_Notification__c> listofNotificationDetails = new List<IETRS_Insp_Notification__c>();
        listofNotificationDetails = [
            SELECT
                id,
                IETRS_PS95_Organization__r.ParentId,
                IETRS_PS95_Organization__c
            FROM IETRS_Insp_Notification__c
        ];
        Id listofContacts = [SELECT id FROM Contact LIMIT 1].id;
        List<IETRS_Insp_Notification_Detail__c> listOfNotificationDetails1 = new List<IETRS_Insp_Notification_Detail__c>();
        String strJobId;

        for (
            IETRS_Insp_Notification__c notification : listofNotificationDetails
        ) {
            IETRS_Insp_Notification_Detail__c notificationDetails = new IETRS_Insp_Notification_Detail__c();
            notificationDetails.IETRS_Notification__c = notification.Id;
            notificationDetails.IETRS_Operator_Leak_ID__c = '1233';
            notificationDetails.IETRS_Pipelines_System_ID__c = acctRE.Id;
            notificationDetails.IETRS_Repair_Date__c = System.today();
            notificationDetails.IETRS_Leak_Cause__c = 'Static Electricity';
            notificationDetails.IETRS_Leak_Location__c = 'Above Ground Piping';
            listOfNotificationDetails1.add(notificationDetails);
        }
        try {
            strJobId = IETRS_PLI_EDI_FileHandler.saveEDIRepairedLeaks(
                listOfNotificationDetails1,
                false
            );
            strJobId = IETRS_PLI_EDI_FileHandler.saveEDIRepairedLeaks(
                listOfNotificationDetails1,
                true
            );
            IETRS_PLI_EDI_FileHandler.getBatchStatus(strJobId);
        } catch (Exception ex) {
            System.assertEquals(
                'Insert failed. First exception on row 0; first error: FIELD_CUSTOM_VALIDATION_EXCEPTION, The Regulated Entity you have selected is not related to the Organization for which this PS-95 is being filed.: [IETRS_Pipelines_System_ID__c]',
                ex.getMessage()
            );
        }
    }

    @isTest
    static void testDeleteDocument() {
        try {
            String document = IETRS_PLI_EDI_FileHandler.deleteDocument(
                '123456789abc'
            );
        } catch (Exception ex) {
            System.debug('deleteDocument: ' + ex.getMessage());
            System.assertEquals(
                'Insert failed. First exception on row 0; first error: FIELD_CUSTOM_VALIDATION_EXCEPTION, The Regulated Entity you have selected is not related to the Organization for which this PS-95 is being filed.: [IETRS_Pipelines_System_ID__c]',
                ex.getMessage()
            );
        }
    }

    @isTest
    static void testGetEDICustomMetadata() {
        //IETRS_PLI_EDI_FileHandler edifh = new IETRS_PLI_EDI_FileHandler();
        List<IETRS_PLI_PS95_EDI_Code_Mappings__mdt> eDIcmd = IETRS_PLI_EDI_FileHandler.getEDICustomMetadata();
        System.assert(eDIcmd != null);
    }

    @isTest
    static void testGetCountyCode() {
        //IETRS_PLI_EDI_FileHandler edifh = new IETRS_PLI_EDI_FileHandler();
        List<IETRS_County__c> countyCode = IETRS_PLI_EDI_FileHandler.getCountyCode();

        System.assert(countyCode != null);
    }
    @isTest
    static void testGetOperLeakId() {
        //IETRS_PLI_EDI_FileHandler edifh = new IETRS_PLI_EDI_FileHandler();
        IETRS_Insp_Notification__c notifRec = [
            SELECT Id
            FROM IETRS_Insp_Notification__c
            LIMIT 1
        ];
        List<IETRS_Insp_Notification_Detail__c> opLeakId = IETRS_PLI_EDI_FileHandler.getOperLeakId(
            notifRec.Id
        );

        System.assert(opLeakId != null);
    }
    @isTest
    static void testGetRegEntIdList() {
        List<Account> listOfAcct = [
            SELECT id, IETRS_Regulated_Entity_ID__c
            FROM Account
            WHERE Name LIKE 'DistributionTestParentAccount'
            LIMIT 1
        ];
        String myAccount = listOfAcct[0].IETRS_Regulated_Entity_ID__c;
        List<Account> reil = IETRS_PLI_EDI_FileHandler.getRegEntIdList(
            myAccount
        );
        System.debug('testGetRegEntIdList: ' + reil);
        System.assert(reil != null);
    }
    //isn't touching the thrown exception
    @isTest
    static void testNegativeGetRegEntIdList() {
        List<Account> listOfAcct = [
            SELECT id, IETRS_Regulated_Entity_ID__c
            FROM Account
            WHERE Name LIKE 'DistributionTestParentAccount'
            LIMIT 1
        ];
        String myAccount = listOfAcct[0].IETRS_Regulated_Entity_ID__c;
        try {
            List<Account> reil = IETRS_PLI_EDI_FileHandler.getRegEntIdList('');
        } catch (Exception ex) {
            System.assertEquals('Script-thrown exception', ex.getMessage());
        }
    }

    @isTest
    static void testGetIdOfNotDetRecType() {
        List<RecordType> rt = IETRS_PLI_EDI_FileHandler.getIdOfNotDetRecType();
        System.assert(rt != null);
    }
    @IsTest
    public static void testGetContent() {
        ContentVersion cv = createTestFile();

        ContentVersion cv2 = [
            SELECT Id, ContentDocumentId
            FROM ContentVersion
            WHERE Id = :cv.Id
            LIMIT 1
        ];

        Test.startTest();
        String strEDIReturn = IETRS_PLI_EDI_FileHandler.readEDIFile(
            cv2.ContentDocumentId
        );
        Test.stopTest();
    }

    @IsTest
    private static void itShouldCreateAndUpdateFCRecord() {
        // given...
        ContentVersion cv = createTestFile();
        Id notificationId = [SELECT Id FROM IETRS_Insp_Notification__c LIMIT 1]
        ?.Id;
        Id fileId = [
            SELECT ContentDocumentId
            FROM ContentVersion
            WHERE Id = :cv.Id
            LIMIT 1
        ]
        ?.ContentDocumentId;

        // when...
        Test.startTest();
        Id fcRecordId = IETRS_PLI_EDI_FileHandler.createFCRecord(
            notificationId,
            fileId
        );
        IETRS_Files_Correspondence__c fcRecord = IETRS_PLI_EDI_FileHandler.createBoxFile(
            notificationId,
            fileId
        );
        fcRecord.Id = fcRecordId;
        IETRS_PLI_EDI_FileHandler.updateFCRecord(fcRecord);
        Test.stopTest();

        // then...
        System.assert(
            fcRecordId != null,
            'It should have created a new F&C record.'
        );

        System.assert(
            fcRecord.IETRS_Box_File_ID__c != null,
            'It should have returned an F&C record with a box id.'
        );
    }

    private static ContentVersion createTestFile() {
        Blob bodyBlob = Blob.valueOf(
            'Unit Test ContentVersion Body to be insert in test class.'
        );

        ContentVersion cv = new ContentVersion(
            Title = 'SampleTitle',
            PathOnClient = 'SampleTitle.jpg',
            VersionData = bodyBlob,
            origin = 'H'
        );
        insert cv;
        return cv;
    }
}