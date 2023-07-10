@isTest
public class IETRS_IncidentTrigHelperTest {
    
    @testSetup
    static void prepareData(){
        
        Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Regulated_Entity_PS').getRecordTypeId();
        Account objAcc = new Account(Name = 'Regulated Entity PS');
        objAcc.RecordTypeId = accRecordTypeId;
        objAcc.Type = 'Distribution';
        insert objAcc;
        
        IETRS_Incident__c objIncident = new IETRS_Incident__c();
        objIncident.IETRS_Regulated_Entity__c = objAcc.Id;
        insert objIncident;
    }
    
    @isTest
    static void testDeleteIncident(){
        delete [SELECT Id FROM IETRS_Incident__c];
    }
}