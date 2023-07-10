@isTest
public class IETRS_InpectionControllerTest {
   
    static testMethod void testInpectionController(){
        Account a = new Account(name='test account');
        insert a;
        
        IETRS_Inspection_Package__c inspPkg = new IETRS_Inspection_Package__c();
        inspPkg.IETRS_Inspection_Type__c = 'Standard';
        inspPkg.IETRS_Uncorrected_Status__c = 'Waiting for POC' ;
        inspPkg.IETRS_Status__c = 'Waiting for Response';
        insert inspPkg;
        
        Id inspRecordTypeId = Schema.SObjectType.IETRS_Inspection__c.getRecordTypeInfosByDeveloperName().get('PS_Inspection_Distribution_Systems').getRecordTypeId();
        IETRS_Inspection__c objInsp = new IETRS_Inspection__c();
        objInsp.IETRS_Inspection_Package__c = inspPkg.Id;
        objInsp.IETRS_Inspection_Status__c = 'Incomplete';
        objInsp.IETRS_Regulated_Entity__c = a.Id;
        objInsp.RecordTypeId = inspRecordTypeId;
        insert objInsp;
        
        Integer recCounter = 0;
        Id inppkgId = [SELECT Id, Name from IETRS_Inspection_Package__c WHERE Id = :inspPkg.Id limit 1].Id;
        Id inspId = [SELECT Id FROM IETRS_Inspection__c WHERE Id = :objInsp.Id limit 1].Id;
        String recordType = [SELECT RecordType.Name FROM IETRS_Inspection__c WHERE Id = :objInsp.Id limit 1].RecordType.Name;
        test.startTest();
        IETRS_InpectionController.getInpections(inppkgId, recCounter);
        IETRS_InpectionController.getRecName(inppkgId);
        IETRS_InpectionController.getallInpections(inppkgId);
        IETRS_InpectionController.getinspectionsettings();
        IETRS_InpectionController.getrelateddata(inspId, recordType);
        test.stopTest();
        
    }
}