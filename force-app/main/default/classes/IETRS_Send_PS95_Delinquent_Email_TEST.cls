@isTest
public class IETRS_Send_PS95_Delinquent_Email_TEST {
    @testSetup
    public static void testDataSetup() {
        Id accOrgRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Organization')
            .getRecordTypeId();
        Id ps95RecordTypeId = Schema.SObjectType.IETRS_Insp_Notification__c.getRecordTypeInfosByName()
            .get('PS-95')
            .getRecordTypeId();
        IETRS_I_TestUtils testUtils = new IETRS_I_TestUtils();
        testUtils.entityFieldValuesByField.put(
            Account.IETRS_Product_Class__c,
            new List<String>{ 'Gas', 'Gas' }
        );
        testUtils.entityFieldValuesByField.put(
            Account.Type,
            new List<String>{ 'Distribution', 'Distribution' }
        );
        testUtils.entityFieldValuesByField.put(
            Account.IETRS_Entity_Code__c,
            new List<String>{
                IETRS_PS95Helper.DISTRIBUTION_CODE,
                IETRS_PS95Helper.DISTRIBUTION_CODE
            }
        );
        testUtils.entityFieldValuesByField.put(
            Account.IETRS_Entity_Sub_Type__c,
            new List<String>{ 'Private Main System', 'Private Main System' }
        );
        testUtils.entityFieldValuesByField.put(
            Account.IETRS_Product_Sub_Class__c,
            new List<String>{ 'Natural', 'Natural' }
        );
        testUtils.entityFieldValuesByField.put(
            Account.IETRS_Business_Area__c,
            new List<String>{ 'Pipeline Safety' }
        );
        testUtils.entityFieldValuesByField.put(
            Account.IETRS_Status__c,
            new List<String>{ 'Active', 'Abandoned' }
        );
        testUtils.createData(2, 2);

        List<Contact> contacts = new List<Contact>();
        List<IETRS_Insp_Notification__c> notifications = new List<IETRS_Insp_Notification__c>();
        String reportPeriod = IETRS_PS95Helper.getReportPeriod(
            System.today().addMonths(-6)
        );
        Integer i = 0;
        List<Account> orgAccs = [
            SELECT Id
            FROM Account
            WHERE RecordTypeId = :accOrgRecordTypeId
        ];
        // create test contacts and notifications
        for (Account orgAcc : orgAccs) {
            contacts.add(
                new Contact(
                    LastName = 'test' + i,
                    Phone = '191292100120000' + i,
                    IETRS_24_Hour_Phone__c = '1912821001000' + i,
                    FAX = '12121212' + i,
                    Email = 'test' + i + '@gmail.com',
                    Title = 'test Rep',
                    AccountId = orgAcc.Id
                )
            );

            notifications.add(
                new IETRS_Insp_Notification__c(
                    IETRS_PS95_Organization__c = orgAcc.Id,
                    RecordTypeId = ps95RecordTypeId,
                    IETRS_Submitted__c = 'No',
                    IETRS_Report_Period__c = reportPeriod
                )
            );
            i++;
        }

        insert contacts;
        insert notifications;

        // Set contact as org representative to receive delinquent email
        i = 0;
        for (Account orgAcc : orgAccs) {
            orgAcc.IETRS_Representative__c = contacts[i].Id;
            i++;
        }
        update orgAccs;
    }

    @isTest
    public static void testMethod1() {
        Test.startTest();

        String jobId = System.schedule(
            'testBatchScheduler',
            '0 0 22 * * ? *',
            new IETRS_Send_PS95_Delinquent_Email()
        );
        Test.stopTest();

        System.assert(jobId != null, 'The job should have been scheduled.');
    }
}