@isTest
public class IETRS_AccountTriggerTest {
    @testSetup
    static void prepareData(){
        Id accOrgRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Organization').getRecordTypeId();
        Id accRegEntPSRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Regulated_Entity_PS').getRecordTypeId();
        Id accUnitRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Unit').getRecordTypeId();
        List<Account> lstAcc = new List<Account>();
        Account orgAcc = new Account(Name = 'Org', RecordTypeId = accOrgRecordTypeId, Type = 'Distribution');
        insert orgAcc;
        Account unitAcc = new Account(Name = 'Unit',RecordTypeId = accUnitRecordTypeId,Type = 'Distribution', IETRS_Organization_Parent__c = orgAcc.Id, 
        ParentId = orgAcc.Id);
        insert unitAcc;
        Account reAcc = new Account(Name = 'Regulated Entity PS',RecordTypeId = accRegEntPSRecordTypeId,Type = 'Distribution', 
        IETRS_OrganizationofRegEntity__c = orgAcc.Id, ParentId = unitAcc.Id, IETRS_Unit_Parent__c = unitAcc.Id);
        insert reAcc;
    }
    
    static testMethod void testDeleteAcc(){
        delete [SELECT Id FROM Account WHERE (RecordType.Name = 'Regulated Entity PS' OR RecordType.Name = 'Unit')];
    }
    
    static testMethod void testUpdate(){
    Id accFieldRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Field').getRecordTypeId();
        Account objParent = new Account(Name = 'Test Acc Field', RecordTypeId = accFieldRecordTypeId,Type = 'Permitted Field');
        insert objParent;
        
        Account objChild = new Account(Name = 'Test Acc Field', RecordTypeId = accFieldRecordTypeId,Type = 'Permitted Field');
        insert objChild;
        
        objChild.parentId = objParent.Id;
        update objChild;
        
        Account objUnit = [SELECT Id FROM Account WHERE Name ='Unit' LIMIT 1];
        objUnit.parentId = objParent.Id;
        update objUnit;
    }
}