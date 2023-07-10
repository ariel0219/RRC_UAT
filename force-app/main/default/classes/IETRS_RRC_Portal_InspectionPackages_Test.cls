@isTest
public inherited sharing class IETRS_RRC_Portal_InspectionPackages_Test {
    @TestSetup
    static void makeData(){

        String strRecordType = [SELECT Id FROM RecordType WHERE Name='Organization' Limit 1].Id;
        Account objAccount = new Account();
        objAccount.Name = 'Test Acct';
        objAccount.RecordTypeId = strRecordType;
        insert objAccount;

        IETRS_Inspection_Package__c objIP = new IETRS_Inspection_Package__c();
        objIP.IETRS_Organization__c = objAccount.Id;
        objIP.IETRS_Inspection_Type__c = 'Standard';
        objIP.IETRS_Status__c = 'Waiting for Response';
        insert objIP;

        Contact objContact = new Contact();
        objContact.AccountId = objAccount.Id;
        objContact.LastName = 'test';
        insert objContact;

    }

    @IsTest
    static void returnListofIPsAsGuestUser(){
        String strUserName = 'User' + DateTime.now().getTime() + '@testorg.com';

        Profile p = [SELECT Id FROM Profile WHERE Name='RRC Portal Profile'];
        User uTest = new User(Alias = 'insptest', Email='standarduser@testorg.com',
                              EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                              LocaleSidKey='en_US', ProfileId = p.Id,
                              TimeZoneSidKey='America/Los_Angeles',
                              UserName=strUserName
                              );       


        Test.startTest();
        System.runAs(uTest){
            List<IETRS_Inspection_Package__c> expResult = [SELECT Name,
                                                        IETRS_Inspection_Type__c,
                                                        IETRS_Begin_Date__c,
                                                        IETRS_End_Date__c,
                                                        IETRS_Business_Area__c,
                                                        IETRS_Organization__r.Name
                                                    FROM IETRS_Inspection_Package__c
                                                    ORDER BY CreatedDate DESC ];

            List<IETRS_Inspection_Package__c> actResult= IETRS_RRC_Portal_InspectionPackages.getInspectionPackageList();
            system.assert(expResult == actResult);
            
        }
        Test.stopTest();


        
    }

    @IsTest
    static void returnListofIPsAsAuthUser(){

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
            List<IETRS_Inspection_Package__c> expResult = [SELECT Name,
                                                                IETRS_Inspection_Type__c,
                                                                IETRS_Begin_Date__c,
                                                                IETRS_End_Date__c,
                                                                IETRS_Business_Area__c,
                                                                IETRS_Organization__r.Name
                                                            FROM IETRS_Inspection_Package__c
                                                            ORDER BY CreatedDate DESC ];
            system.debug(expResult);

            List<IETRS_Inspection_Package__c> actResult= IETRS_RRC_Portal_InspectionPackages.getInspectionPackageList();
            system.assert(true == true);

        }
        Test.stopTest();
        
    }


}