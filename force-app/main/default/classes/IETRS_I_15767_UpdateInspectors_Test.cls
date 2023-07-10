@isTest
public with sharing class IETRS_I_15767_UpdateInspectors_Test {
    static TestMethod void IETRS_I_15767_UpdateInspectors_Test() {
        
        UserRole ur = [SELECT Id FROM UserRole WHERE Name like '%Inspection%' Limit 1];
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', FirstName='John',LastName='Doe', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, UserRoleId = ur.Id,
            TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testorg.com');
        
        IETRS_Inspection_Package__c ip = new IETRS_Inspection_Package__c(IETRS_Total_Penalty_Amount__c =  NULL);
        insert ip;
        IETRS_Insp_Inspection_Package_Inspector__c ins = new IETRS_Insp_Inspection_Package_Inspector__c(	IETRS_Inspection_Package__c=ip.Id,IETRS_Inspector_Fullname_Legacy__c = 'John Doe');        
        insert ins;
       
        Test.startTest();
        IETRS_I_15767_UpdateInspectors batchJob = new IETRS_I_15767_UpdateInspectors();
        ID jobID = Database.executeBatch(batchJob,70);
        Test.stopTest();
    }
}