@isTest
public with sharing class IIETRS_I_15843_Test {
    static TestMethod void IIETRS_I_15843_Test() {
        
        UserRole ur = [SELECT Id FROM UserRole WHERE Name like '%Inspection%' Limit 1];
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', FirstName='John',LastName='Doe', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, UserRoleId = ur.Id,
            TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testorg.com');
        
        IETRS_Incident__c ins = new IETRS_Incident__c(Lead_Inspector_Fullname__c = 'John Doe');        
        insert ins;
       
        Test.startTest();
        IIETRS_I_15843_UpdateIIncidentnspectors batchJob = new IIETRS_I_15843_UpdateIIncidentnspectors();
        ID jobID = Database.executeBatch(batchJob,70);
        Test.stopTest();
    }
}