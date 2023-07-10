/**
 * Test class for IETRS_RepairedLeaksCsvController
 * @author CGI
 */
@IsTest
public with sharing class IETRS_RepairedLeaksCsvController_Test {
    @TestSetup
    static void makeData() {
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

        // create notification and notification details
        Integer x = 10;
        Id accOrgRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Organization')
            .getRecordTypeId();
        Id ps95RecordTypeId = Schema.SObjectType.IETRS_Insp_Notification__c.getRecordTypeInfosByDeveloperName()
            .get('IETRS_PS_95')
            .getRecordTypeId();
        Id orgId = [
            SELECT Id
            FROM Account
            WHERE RecordTypeId = :accOrgRecordTypeId
            LIMIT 1
        ]
        ?.Id;
        Id reId = [
            SELECT Id
            FROM Account
            WHERE IETRS_OrganizationofRegEntity__c = :orgId
            LIMIT 1
        ]
        ?.Id;
        Integer reportYear = 2020;
        IETRS_Insp_Notification__c notification = new IETRS_Insp_Notification__c(
            RecordTypeId = ps95RecordTypeId,
            IETRS_PS95_Organization__c = orgId,
            IETRS_Report_Period__c = String.valueOf(reportYear) + ' Jan-Jun'
        );
        insert notification;

        List<IETRS_Insp_Notification_Detail__c> detailRecords = new List<IETRS_Insp_Notification_Detail__c>();
        for (Integer i = 0; i < x; i++) {
            detailRecords.add(
                new IETRS_Insp_Notification_Detail__c(
                    IETRS_Notification__c = notification.Id,
                    IETRS_Pipelines_System_ID__c = reId,
                    IETRS_Leak_Cause__c = 'Corrosion',
                    IETRS_Repair_Date__c = Date.newInstance(reportYear, 1, 1),
                    IETRS_Leak_Repair_Method__c = 'Clamp Installed',
                    IETRS_Leak_Location__c = 'Above Ground Piping',
                    IETRS_Pipe_Size__c = '2 inch (IPS)',
                    IETRS_Pipe_Type__c = 'Poly-Vinyl-Chloride',
                    IETRS_Leak_Classification__c = 'Grade 3'
                )
            );
        }
        insert detailRecords;
    }

    @IsTest
    static void itShouldFindNotificationDetail() {
        // Given...
        Id notificationId = [SELECT Id FROM IETRS_Insp_Notification__c LIMIT 1]
        ?.Id;
        Test.setCurrentPage(Page.IETRS_RepairedLeaksCsv);
        ApexPages.currentPage().getParameters().put('id', notificationId);

        // When...
        Test.startTest();
        IETRS_RepairedLeaksCsvController controllerClass = new IETRS_RepairedLeaksCsvController();
        Test.stopTest();

        // Then...
        System.assert(
            controllerClass.notificationDetail != null,
            'The notification record should have been set in the constructor.'
        );
    }

    @IsTest
    static void itShouldFailWithoutIdParam() {
        // Given...
        Id notificationId = [SELECT Id FROM IETRS_Insp_Notification__c LIMIT 1]
        ?.Id;
        Test.setCurrentPage(Page.IETRS_RepairedLeaksCsv);

        // When...
        Test.startTest();
        Boolean itFailed = false;
        try {
            IETRS_RepairedLeaksCsvController controllerClass = new IETRS_RepairedLeaksCsvController();
        } catch (IETRS_RepairedLeaksCsvController.IETRS_RepairedLeaksCsvControllerException e) {
            itFailed = true;
        }
        Test.stopTest();

        // Then...
        System.assert(
            itFailed,
            'The controller should have thrown an exception if no id was found.'
        );
    }

    @IsTest
    static void itShouldSetFileName() {
        // Given...
        Id notificationId = [SELECT Id FROM IETRS_Insp_Notification__c LIMIT 1]
        ?.Id;
        Test.setCurrentPage(Page.IETRS_RepairedLeaksCsv);
        ApexPages.currentPage().getParameters().put('id', notificationId);

        // When...
        Test.startTest();
        IETRS_RepairedLeaksCsvController controllerClass = new IETRS_RepairedLeaksCsvController();
        String fileName = controllerClass.getFileName();
        Test.stopTest();

        // Then...
        System.assert(fileName != null, 'The file name should have been set.');
    }

    @IsTest
    static void itShouldGetCsvColumns() {
        // When...
        Test.startTest();
        List<Map<String, String>> csvColumns = IETRS_RepairedLeaksCsvController.getCsvColumns();
        Test.stopTest();

        // Then...
        System.assert(
            csvColumns.size() > 0,
            'It should have retrieved columns for the csv file.'
        );
    }

    @IsTest
    static void itShouldGetRecordsAsMap() {
        // Given...
        Id notificationId = [SELECT Id FROM IETRS_Insp_Notification__c LIMIT 1]
        ?.Id;
        Integer rowCount = [
            SELECT COUNT()
            FROM IETRS_Insp_Notification_Detail__c
            WHERE IETRS_Notification__c = :notificationId
        ];
        // When...
        Test.startTest();
        List<Map<Integer, String>> dataAsJson = IETRS_RepairedLeaksCsvController.getJsonData(
            notificationId
        );
        Test.stopTest();

        // Then...
        System.assertEquals(
            rowCount,
            dataAsJson.size(),
            'The number of rows should match.'
        );
    }

    @IsTest
    static void itShouldGetRegEntities() {
        // Given...
        Set<Id> accIds = new Set<Id>();
        Id notificationId = [SELECT Id FROM IETRS_Insp_Notification__c LIMIT 1]
        ?.Id;
        for (IETRS_Insp_Notification_Detail__c nd : [
            SELECT IETRS_Pipelines_System_ID__c
            FROM IETRS_Insp_Notification_Detail__c
            WHERE IETRS_Notification__c = :notificationId
        ]) {
            if (nd.IETRS_Pipelines_System_ID__c != null) {
                accIds.add(nd.IETRS_Pipelines_System_ID__c);
            }
        }
        // When...
        Test.startTest();
        Map<Id, Account> relatedEntityMap = IETRS_RepairedLeaksCsvController.getRegEntities(
            new List<Id>(accIds)
        );
        Test.stopTest();

        System.assert(
            relatedEntityMap != null,
            'The result should include the entities associated with the detail records.'
        );
    }
}