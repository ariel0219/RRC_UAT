@isTest
public class IETRS_Create_PS95_Notification_TEST {
    @testSetup
    public static void testDataSetUp() {
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
    }

    @isTest
    private static void testMethod1() {
        Test.startTest();
        DataBase.executeBatch(new IETRS_Create_PS95_Notification_Shells());
        String jobId = System.schedule(
            '123TestjobName',
            '0 0 22 * * ? *',
            new IETRS_Create_PS95_Notification_Shells()
        );
        Test.stopTest();

        System.assert(jobId != null, 'The job should have been scheduled.');
    }
}