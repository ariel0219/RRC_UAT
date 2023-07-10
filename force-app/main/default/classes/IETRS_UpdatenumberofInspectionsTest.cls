@isTest
public class IETRS_UpdatenumberofInspectionsTest {
    
    @testSetup
    static void prepareData(){
        
        Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Regulated_Entity_PS').getRecordTypeId();
        Account objAcc = new Account(Name = 'Regulated Entity PS');
        objAcc.RecordTypeId = accRecordTypeId;
        objAcc.Type = 'Distribution';
        insert objAcc;
        
        IETRS_Inspection_Package__c objInspPkg = new IETRS_Inspection_Package__c();
        objInspPkg.IETRS_Inspection_Type__c = 'Standard';
        objInspPkg.IETRS_Inspection_Sub_Type__c = 'Comprehensive';
        insert objInspPkg;
        
        Id inspRecordTypeId = Schema.SObjectType.IETRS_Inspection__c.getRecordTypeInfosByDeveloperName().get('PS_Inspection_Distribution_Systems').getRecordTypeId();
        IETRS_Inspection__c objInsp = new IETRS_Inspection__c();
        objInsp.IETRS_Inspection_Package__c = objInspPkg.Id;
        objInsp.IETRS_Inspection_Status__c = 'Incomplete';
        objInsp.IETRS_Regulated_Entity__c = objAcc.Id;
        objInsp.RecordTypeId = inspRecordTypeId;
        insert objInsp;
        
        IETRS_InspSchedule__c objInspSchdule = new IETRS_InspSchedule__c();
        objInspSchdule.IETRS_Inspection_Package__c = objInspPkg.Id;
        insert objInspSchdule;
        
        
    }
    
    static testmethod void testDeleteInsp(){
        delete [SELECT Id FROM IETRS_Inspection__c];
    }

}