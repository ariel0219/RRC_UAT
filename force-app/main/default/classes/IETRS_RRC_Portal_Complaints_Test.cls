@isTest
public inherited sharing class IETRS_RRC_Portal_Complaints_Test {
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

        IETRS_Complaint__c objComplaint = new IETRS_Complaint__c();
        objComplaint.IETRS_Regulated_Entity_Name__c = objRegulatedEnt.Id;
        objComplaint.ITRES_Complaint_Received__c = System.today();
        objComplaint.IETRS_Complaint_Resolution_Status__c = 'Closed';
        objComplaint.IETRS_Public_Portal_Record_Visible__c = true;
        insert objComplaint;

        Contact objContact = new Contact();
        objContact.AccountId = objRegulatedEnt.Id;
        objContact.LastName = 'test';
        insert objContact;

    }

    @IsTest
    static void returnListofComplaintsAsGuestUser(){
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

            IETRS_RRC_Portal_Complaints.ComplaintWrapper expResultWrapper = new IETRS_RRC_Portal_Complaints.ComplaintWrapper();
            expResultWrapper.pageSize = 10;
            expResultWrapper.pageNumber = 1;
            expResultWrapper.totalPages = 1; 
            expResultWrapper.totalRows = 0;
            expResultWrapper.recordStart = 1; 
            expResultWrapper.recordEnd = 0;

            expResultWrapper.complaints = [SELECT Name, IETRS_Complaint_Reported_Date_Time__c, ITRES_Complaint_Received__c, 
                IETRS_Complaint_Resolution_Status__c, IETRS_City__c, IETRS_I_Regulated_Entity_Name_for_Search__c, 
                IETRS_Organization__r.Name, IETRS_Business_Area__c, IETRS_Complaint_Description__c 
            FROM IETRS_Complaint__c
            ORDER BY IETRS_Organization__r.Name DESC LIMIT 0];

            String expResult = JSON.serialize(expResultWrapper);

            Integer pageNumber;
            Integer pageSize;
            String sortingField;
            String sortDirection;
            
            String actResult= IETRS_RRC_Portal_Complaints.getComplaintsList(pageNumber, pageSize, sortingField, sortDirection);

            //System.assertEquals(expResult, actResult, 'guest users should see all completed complaints');
            
        }
        Test.stopTest();


        
    }

    @IsTest
    static void returnListofComplaintsAsAuthUser(){

        String strUserName = 'User' + DateTime.now().getTime() + '@testorg.com';

        Profile p = [SELECT Id FROM Profile WHERE Name='IETRS Authenticated Community User'];
        User uTest1 = new User(Alias = 'insptest', Email='standarduser@testorg.com',
                            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                            LocaleSidKey='en_US', ProfileId = p.Id,
                            TimeZoneSidKey='America/Los_Angeles',
                            UserName=strUserName,
                            ContactId = [SELECT Id FROM Contact WHERE LastName ='test' LIMIT 1].Id
                            );
        
        Test.startTest();
        System.runAs(uTest1){
            
            IETRS_RRC_Portal_Complaints.ComplaintWrapper expResultWrapper = new IETRS_RRC_Portal_Complaints.ComplaintWrapper();
            expResultWrapper.pageSize = 1;
            expResultWrapper.pageNumber = 1;
            expResultWrapper.totalPages = 1; 
            expResultWrapper.totalRows = 0;
            expResultWrapper.recordStart = 1; 
            expResultWrapper.recordEnd = 0;

            expResultWrapper.complaints = [SELECT Name, IETRS_Complaint_Reported_Date_Time__c, ITRES_Complaint_Received__c, 
                IETRS_Complaint_Resolution_Status__c, IETRS_City__c, IETRS_I_Regulated_Entity_Name_for_Search__c, 
                IETRS_Organization__r.Name, IETRS_Business_Area__c, IETRS_Complaint_Description__c 
            FROM IETRS_Complaint__c
            ORDER BY CreatedDate DESC LIMIT 0];
            
            String expResult = JSON.serialize(expResultWrapper);

            Integer pageNumber = 1;
            Integer pageSize = 1;
            String sortingField = 'IETRS_Organization__r.Name';
            String sortDirection = 'ASC';
            
            String actResult= IETRS_RRC_Portal_Complaints.getComplaintsList(pageNumber, pageSize, sortingField, sortDirection);
            //System.assertEquals(expResult, actResult, 'authenticated users should see all complaints related to them');
        }
        Test.stopTest();
        
    }
}