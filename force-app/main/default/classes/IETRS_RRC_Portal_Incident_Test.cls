@isTest
public inherited sharing class IETRS_RRC_Portal_Incident_Test {
    @TestSetup
    static void makeData(){

        IETRS_County_Group__c objCounty = new IETRS_County_Group__c();
        objCounty.Name = 'Test County';
        objCounty.IETRS_Group_Type__c = 'Region';
        objCounty.IETRS_Business_Area__c = 'Pipeline Safety';
        insert objCounty;

        String strRecordType = [SELECT Id FROM RecordType WHERE Name='Regulated Entity - PS' Limit 1].Id;
        Account objRegulatedEnt = new Account();
        objRegulatedEnt.Name = 'Test RE';
        objRegulatedEnt.RecordTypeId = strRecordType;
        objRegulatedEnt.IETRS_Region__c = objCounty.Id;
        insert objRegulatedEnt;

        strRecordType = [SELECT Id FROM RecordType WHERE Name='Organization' Limit 1].Id;
        Account objAccount = new Account();
        objAccount.Name = 'Test Acct';
        objAccount.RecordTypeId = strRecordType;
        insert objAccount;

        IETRS_Incident__c objIncident = new IETRS_Incident__c();
        objIncident.IETRS_Organization__c = objAccount.Id;
        insert objIncident;

        Contact objContact = new Contact();
        objContact.AccountId = objAccount.Id;
        objContact.LastName = 'test';
        insert objContact;

    }

    @IsTest
    static void returnListofIncidentsAsGuestUser(){
        String strUserName = 'User' + DateTime.now().getTime() + '@testorg.com';

        Profile p = [SELECT Id FROM Profile WHERE Name='RRC Portal Profile'];
        User uTest = new User(Alias = 'insptest', Email='standarduser@testorg.com',
                              EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                              LocaleSidKey='en_US', ProfileId = p.Id,
                              TimeZoneSidKey='America/Los_Angeles',
                              UserName=strUserName
                              );

        strUserName = 'User1' + DateTime.now().getTime() + '@testorg.com';
        


        Test.startTest();
        System.runAs(uTest){
            IETRS_RRC_Portal_Incidents.IncidentWrapper compareDate = new IETRS_RRC_Portal_Incidents.IncidentWrapper();
            Integer pageNumber = null;
            Integer pageSize = null;
            String sortingField = null;
            String sortDirection = null;

            compareDate.pageSize = 10;
            compareDate.pageNumber = 1;
            compareDate.totalPages = 1;
            compareDate.totalRows = 0;
            compareDate.recordStart = 1;
            compareDate.recordEnd = 0;
            compareDate.incidents = [SELECT Name, IETRS_Incident_Date__c, IETRS_Incident_Status__c, IETRS_Business_Area__c, IETRS_Organization__r.Name, IETRS_Organization_ID__c, IETRS_Nearest_City__c, IETRS_County_Name_For_Search__c, IETRS_Incident_Description__c 
            FROM IETRS_Incident__c
            ORDER BY CreatedDate DESC ];
            String expResult = JSON.serialize(compareDate);
            String actResult= IETRS_RRC_Portal_Incidents.getIncidentsList(pageNumber, pageSize, sortingField, sortDirection);

            system.assert(expResult == actResult);
            
        }
        Test.stopTest();


        
    }

    @IsTest
    static void returnListofIncidentsAsAuthUser(){

        String strUserName = 'User' + DateTime.now().getTime() + '@testorg.com';

        Profile p = [SELECT Id FROM Profile WHERE Name='IETRS Authenticated Community User'];
        User uTest1 = new User(Alias = 'insptest', Email='standarduser@testorg.com',
                            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                            LocaleSidKey='en_US', ProfileId = p.Id,
                            TimeZoneSidKey='America/Los_Angeles',
                            UserName=strUserName,
                            ContactId = [SELECT Id FROM Contact LIMIT 1].Id
                            );
        
        Test.startTest();
        System.runAs(uTest1){
            
            IETRS_RRC_Portal_Incidents.IncidentWrapper compareDate = new IETRS_RRC_Portal_Incidents.IncidentWrapper();
            Integer pageNumber = 1;
            Integer pageSize = 50;
            String sortingField = 'Name';
            String sortDirection = 'ASC';

            compareDate.pageSize = pageSize;
            compareDate.pageNumber = pageNumber;
            compareDate.totalPages = 1;
            compareDate.totalRows = 0;
            compareDate.recordStart = 1;
            compareDate.recordEnd = 0;
            compareDate.incidents = [SELECT Name, IETRS_Incident_Date__c, IETRS_Incident_Status__c, IETRS_Business_Area__c, IETRS_Organization__r.Name, IETRS_Organization_ID__c, IETRS_Nearest_City__c, IETRS_County_Name_For_Search__c, IETRS_Incident_Description__c 
            FROM IETRS_Incident__c
            ORDER BY CreatedDate DESC ];
            String expResult = JSON.serialize(compareDate);
            system.debug(expResult);

            String actResult= IETRS_RRC_Portal_Incidents.getIncidentsList(pageNumber, pageSize, sortingField, sortDirection);
            system.debug(actResult);
            system.assert(expResult == actResult);
        }
        Test.stopTest();
        
    }
}