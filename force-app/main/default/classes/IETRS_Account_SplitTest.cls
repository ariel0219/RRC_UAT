@isTest
public class IETRS_Account_SplitTest {
    @testSetup
    static void prepareData() {
        IETRS_County_Group__c objCountyGrp = new IETRS_County_Group__c();
        objCountyGrp.Name = '00-Statewide';
        objCountyGrp.IETRS_Group_Type__c = 'Region';
        objCountyGrp.IETRS_Business_Area__c = 'Pipeline Safety';
        insert objCountyGrp;

        Id accRegEntPSRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Regulated_Entity_PS')
            .getRecordTypeId();
        Id accOrgRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Organization')
            .getRecordTypeId();

        Account objAcc1 = new Account(
            Name = 'Regulated Entity PS Parent',
            RecordTypeId = accOrgRecordTypeId,
            IETRS_Company_ID__c = '12345'
        );
        insert objAcc1;

        Account objAcc = new Account(
            Name = 'Regulated Entity PS',
            RecordTypeId = accRegEntPSRecordTypeId,
            Type = 'Distribution',
            IETRS_OrganizationofRegEntity__c = objAcc1.Id
        );
        insert objAcc;

        Account objAcc11 = new Account(
            Name = 'Regulated Entity PS 2',
            RecordTypeId = accRegEntPSRecordTypeId,
            Type = 'Distribution',
            IETRS_OrganizationofRegEntity__c = objAcc1.Id
        );

        insert objAcc11;

        IETRS_Insp_Miles_by_County__c objMilesCounty = new IETRS_Insp_Miles_by_County__c();
        objMilesCounty.IETRS_Regulated_Entity__c = objAcc.Id;
        objMilesCounty.IETRS_Miles__c = 10;
        insert objMilesCounty;

        IETRS_Insp_Miles_by_County__c objMilesCounty2 = new IETRS_Insp_Miles_by_County__c();
        objMilesCounty2.IETRS_Regulated_Entity__c = objAcc.Id;
        objMilesCounty2.IETRS_Miles__c = 10;
        insert objMilesCounty2;

        IETRS_Insp_Miles_by_County__c objMilesCounty3 = new IETRS_Insp_Miles_by_County__c();
        objMilesCounty3.IETRS_Regulated_Entity__c = objAcc.Id;
        objMilesCounty3.IETRS_Miles__c = 8;
        insert objMilesCounty3;

        IETRS_Insp_Miles_by_County__c objMilesCounty4 = new IETRS_Insp_Miles_by_County__c();
        objMilesCounty4.IETRS_Regulated_Entity__c = objAcc11.Id;
        objMilesCounty4.IETRS_Miles__c = 10;
        insert objMilesCounty4;

        // merged from greg's update
        IETRS_I_TestUtils testUtils = new IETRS_I_TestUtils();
        testUtils.createData(1, 2);
        List<IETRS_Insp_Miles_by_County__c> milesByCountyRecords = new List<IETRS_Insp_Miles_by_County__c>();
        List<Account> entities = [SELECT Id FROM Account WHERE RecordType.DeveloperName = 'Regulated_Entity_PS'];
        IETRS_County__c county = new IETRS_County__c(Name = 'Travis');
        insert county;
        // create some IETRS_Insp_Miles_by_County__c records for the entity
        for (Integer i = 0; i < 10; i++) {
            milesByCountyRecords.add(
                new IETRS_Insp_Miles_by_County__c(
                    IETRS_County__c = county.Id,
                    IETRS_Miles__c = i + 1 * 100,
                    IETRS_Regulated_Entity__c = entities[Math.mod(i, entities.size())].Id
                )
            );
        }
        insert milesByCountyRecords;
    }

    @isTest
    static void testLoadAcc() {
        String sourceAccId = string.valueOf([SELECT Id FROM Account WHERE Name = 'Regulated Entity PS' LIMIT 1].Id);
        IETRS_Account_Split.LoadRespWrapper objLoadREsp = IETRS_Account_Split.getAccount(sourceAccId);

        List<IETRS_Insp_Miles_by_County__c> lstDelCounty = [
            SELECT Id, IETRS_Regulated_Entity__c, Name
            FROM IETRS_Insp_Miles_by_County__c
            WHERE IETRS_Miles__c = 8
        ];
        List<IETRS_Insp_Miles_by_County__c> lstUpdateCount = [
            SELECT Id, Name, IETRS_Regulated_Entity__c, IETRS_Miles__c, IETRS_County__c
            FROM IETRS_Insp_Miles_by_County__c
            WHERE IETRS_Miles__c != 8
        ];
        lstUpdateCount[0].IETRS_Miles__c = 5;

        Account accDetails = new Account();
        accDetails.IETRS_Status__c = 'Active';

        IETRS_Account_Split.splitRecord(
            sourceAccId,
            null,
            'Event Note',
            lstDelCounty,
            lstUpdateCount,
            'New Account 2',
            accDetails,
            '12.1',
            '210.1'
        );
        IETRS_Account_Split.splitRecord(
            sourceAccId,
            null,
            'Event Note1',
            lstDelCounty,
            lstUpdateCount,
            'New Account 212',
            accDetails
        );
    }

    // merged from greg's test update
    @isTest
    static void itShouldSplitEntity() {
        Account entityToSplit = [
            SELECT Name, Id
            FROM Account
            WHERE RecordType.DeveloperName = 'Regulated_Entity_PS'
            LIMIT 1
        ];
        Integer originalEntitySize = [
            SELECT COUNT()
            FROM Account
            WHERE RecordType.DeveloperName = 'Regulated_Entity_PS'
        ];
        List<IETRS_Insp_Miles_by_County__c> countiesToBeDeleted = new List<IETRS_Insp_Miles_by_County__c>();
        List<IETRS_Insp_Miles_by_County__c> updatedCounties = new List<IETRS_Insp_Miles_by_County__c>();
        for (IETRS_Insp_Miles_by_County__c milesByCounty : [
            SELECT Id, Name, IETRS_Regulated_Entity__c, IETRS_Miles__c, IETRS_County__c
            FROM IETRS_Insp_Miles_by_County__c
        ]) {
            if (countiesToBeDeleted.size() < 6) {
                countiesToBeDeleted.add(milesByCounty);
            } else {
                milesByCounty.IETRS_Miles__c = milesByCounty.IETRS_Miles__c - 1;
                updatedCounties.add(milesByCounty);
            }
        }
        Test.startTest();
        IETRS_Account_Split.getAccount(entityToSplit.Id);
        // return early because the provided name is the same
        IETRS_Account_Split.splitRecord(
            entityToSplit.Id,
            '',
            'test note',
            countiesToBeDeleted,
            updatedCounties,
            entityToSplit.Name,
            new Account(),
            '12.1',
            '210.1'
        ); IETRS_Account_Split.splitRecord(
            entityToSplit.Id,
            '',
            'test note1',
            countiesToBeDeleted,
            updatedCounties,
            entityToSplit.Name,
            new Account()
        );
        // Provide a valid new name
        IETRS_Account_Split.splitRecord(
            entityToSplit.Id,
            '',
            'test note',
            countiesToBeDeleted,
            updatedCounties,
            'New Entity Name',
            new Account(),
            '12.1',
            '210.1'
        );
        IETRS_Account_Split.splitRecord(
            entityToSplit.Id,
            '',
            'test note1',
            countiesToBeDeleted,
            updatedCounties,
            'New Entity Name12',
            new Account()
            
        );
        Test.stopTest();
        Integer newEntitySize = [SELECT COUNT() FROM Account WHERE RecordType.DeveloperName = 'Regulated_Entity_PS'];
        System.assert(originalEntitySize < newEntitySize, 'There should be more entities after splitting.');
    }
}