@isTest
public class IETRS_InspMilesCountyTrigTest {
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

        IETRS_Insp_Miles_by_County__c objMilesCounty = new IETRS_Insp_Miles_by_County__c();
        objMilesCounty.IETRS_Regulated_Entity__c = objAcc.Id;
        objMilesCounty.IETRS_Miles__c = 10;
        insert objMilesCounty;
    }

    static testMethod void testDeleteInsp() {
        delete [SELECT Id FROM IETRS_Insp_Miles_by_County__c];
    }
}