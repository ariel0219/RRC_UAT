/*
  @Class Name         : IETRS_AccountTransferTest
  @Description        : Test class for IETRS_AccountTransfer 
  @Author             : Sandhya Belur
  @Group              : 
  @Last Modified By   : Sandhya Belur
  @Last Modified On   : 5/28/2020
  @Modification Log   : 
  ==============================================================================
  Ver         Date                     Author                 Modification
  ==============================================================================
  1.0    5/28/2020                    Sandhya Belur           Initial Version
*/
@isTest
public class IETRS_AccountTransferTest {
    final static String SEARCH_COMPANY_ID = '12345';
    final static String SEARCH_BILLING_STREET = 'Street 1';
    final static String SEARCH_BILLING_CITY = 'Dallas';
    final static String SEARCH_BILLING_STATE = 'TX';
    final static String SEARCH_BILLING_COUNTRY = 'USA';
    final static String SEARCH_BILLING_POSTAL_CODE = '75039';

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
                    IETRS_Fee_Type__c = 'Distribution',
                    IETRS_Organization__c = regEnt.IETRS_OrganizationofRegEntity__c,
                    IETRS_Regulated_Entity__c = regEnt.Id,
                    IETRS_Unit__c = regEnt.ParentId
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
        org.BillingStreet = SEARCH_BILLING_STREET;
        org.BillingCity = SEARCH_BILLING_CITY;
        org.BillingState = SEARCH_BILLING_STATE;
        org.BillingPostalCode = SEARCH_BILLING_POSTAL_CODE;
        org.BillingCountry = SEARCH_BILLING_COUNTRY;

        update org;
        insert regFees;
    }

    static testMethod void testGetAccRecord() {
        IETRS_AccountTransfer.AccountTypes accType = IETRS_AccountTransfer.getAccountRecord(
            String.valueOf(
                [SELECT Id FROM Account WHERE RecordType.Name = 'Unit' LIMIT 1]
                .Id
            )
        );
        accType = IETRS_AccountTransfer.getAccountRecord(
            String.valueOf(
                [
                    SELECT Id
                    FROM Account
                    WHERE RecordType.Name = 'Organization'
                    LIMIT 1
                ]
                .Id
            )
        );
    }

    static testMethod void testTransferRegEntity() {
        Id oldParent = [
            SELECT Id
            FROM Account
            WHERE RecordType.DeveloperName = 'Organization'
            LIMIT 1
        ]
        .Id;
        Id newParent = [
            SELECT Id
            FROM Account
            WHERE RecordType.DeveloperName = 'Organization'
            LIMIT 1
            OFFSET 1
        ]
        .Id;
        Id childAcc = [
            SELECT Id
            FROM Account
            WHERE IETRS_OrganizationofRegEntity__c = :oldParent
            LIMIT 1
        ]
        .Id;

        IETRS_AccountTransfer.transferRecord(
            oldParent,
            newParent,
            new List<String>{ childAcc },
            'Custom Notes',
            'Regulated Entity'
        );
    }

    static testMethod void testTransferUnit() {
        Id oldParent = [
            SELECT Id
            FROM Account
            WHERE RecordType.DeveloperName = 'Organization'
            LIMIT 1
        ]
        .Id;
        Id newParent = [
            SELECT Id
            FROM Account
            WHERE RecordType.DeveloperName = 'Organization'
            LIMIT 1
            OFFSET 1
        ]
        .Id;
        Id childAcc = [
            SELECT Id
            FROM Account
            WHERE RecordType.DeveloperName = 'Unit' AND ParentId = :oldParent
            LIMIT 1
        ]
        .Id;

        IETRS_AccountTransfer.transferRecord(
            oldParent,
            newParent,
            new List<String>{ childAcc },
            'Custom Notes',
            'Unit'
        );
    }

    static testMethod void testSearchAcc() {
        IETRS_AccountTransfer.SearchParams params = new IETRS_AccountTransfer.SearchParams();
        params.accountName = 'Organization';
        params.address = SEARCH_BILLING_STREET;
        params.city = SEARCH_BILLING_CITY;
        params.state = SEARCH_BILLING_STATE;
        params.zip = SEARCH_BILLING_POSTAL_CODE;
        params.p5Number = '123';

        IETRS_AccountTransfer.searchAccounts(params, 'Unit');
    }

    static testMethod void testFindByName() {
        List<Id> acctId = new List<Id>();
        for (Account acct : [SELECT Id FROM Account LIMIT 10]) {
            acctId.add(acct.Id);
        }
        test.startTest();
        IETRS_AccountTransfer.findByName('Test Account', acctId);
        IETRS_AccountTransfer.findAccountByName('Test Account', acctId);
        test.stopTest();
    }
}