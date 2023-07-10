/**
 * @author Vishwanath Kodgire - CGI
 * @date 5/28/2020
 *
 * @description Tests for IETRS_CongaDocGenBatch and IETRS_MMInvoiceGenerationService
 */

@IsTest
public class IETRS_CongaDocGenBatchTest {
    @testSetup
    static void prepareData() {
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
            new List<String>{ 'Active', 'Active' }
        );
        testUtils.createData(2, 5);

        // set up fees
        List<Account> regEnts = [
            SELECT Id, IETRS_OrganizationofRegEntity__c, ParentId
            FROM Account
            WHERE RecordType.DeveloperName = 'Regulated_Entity_PS'
        ];
        List<IETRS_Insp_Regulated_Fee__c> regFees = new List<IETRS_Insp_Regulated_Fee__c>();
        for (Account regEnt : regEnts) {
            regFees.add(
                new IETRS_Insp_Regulated_Fee__c(
                    IETRS_Fee_Type__c = 'Master Meter',
                    IETRS_Organization__c = regEnt.IETRS_OrganizationofRegEntity__c,
                    IETRS_Regulated_Entity__c = regEnt.Id,
                    IETRS_Unit__c = regEnt.ParentId,
                    IETRS_Fee_Date__c = system.today()
                )
            );
        }

        // set search param values on an org
        Account org = [
            SELECT Id
            FROM Account
            WHERE RecordType.DeveloperName = 'Organization'
            LIMIT 1
        ];
        org.BillingStreet = 'Street 1';
        org.BillingCity = 'Dallas';
        org.BillingState = 'TX';
        org.BillingPostalCode = 'USA';
        org.BillingCountry = '75039';
        update org;
        insert regFees;
    }

    
    @IsTest
    static void testExecute() {
        Test.startTest();
        IETRS_CongaDocGenBatch batchJob = new IETRS_CongaDocGenBatch('Master Meter Invoice', 2023);
        Database.executeBatch(batchJob, 100);
        Test.stopTest();
    }
}