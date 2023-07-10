@isTest
public inherited sharing class IETRS_RRC_Portal_PipelineFees_Test {

    @TestSetup
    static void makeData(){

        String strRecordType = [SELECT Id FROM RecordType WHERE Name='Organization' Limit 1].Id;
        Account objAccount = new Account();
        objAccount.Name = 'Test Acct';
        objAccount.RecordTypeId = strRecordType;
        insert objAccount;

        IETRS_Insp_Regulated_Fee__c objRegFee = new IETRS_Insp_Regulated_Fee__c();
        objRegFee.IETRS_Organization__c = objAccount.Id;
        insert objRegFee;

        Contact objContact = new Contact();
        objContact.AccountId = objAccount.Id;
        objContact.LastName = 'test';
        insert objContact;

    }



    @IsTest
    static void returnListofRegFeesAsAuthUser(){

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
            List<IETRS_Insp_Regulated_Fee__c> expResult = [SELECT Name, IETRS_Fee_Date__c, IETRS_Fee_Type__c, IETRS_Total_Regulated_Fee_Amount_Due__c, IETRS_Status__c 
                                                            FROM IETRS_Insp_Regulated_Fee__c];
            system.debug(expResult);

            List<IETRS_Insp_Regulated_Fee__c> actResult= IETRS_RRC_Portal_PipelineFees.getPipelineFeesList();
            system.debug(actResult);
            system.assert(expResult == actResult);
        }
        Test.stopTest();
        
    }
    

}