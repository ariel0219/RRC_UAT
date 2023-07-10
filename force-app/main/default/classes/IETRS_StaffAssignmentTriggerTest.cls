@isTest
public class IETRS_StaffAssignmentTriggerTest {
    @testSetup static void setup(){
        Id idCaseRecordType = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Hearings').getRecordTypeId();
        Id idAccountRecordType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Organization').getRecordTypeId();
        
        //Create a Org Account to assign as a Primary Account to Case
        Account acctTest = new Account(Name='Test Account', RecordTypeId=idAccountRecordType);
        insert acctTest;
        
        //Create a Case to which Staff Assignments will be assigned
        Case caseTest = new Case(RecordTypeId=idCaseRecordType,
                                 IETRS_Primary_Account_Assignment__c=acctTest.Id,
                                 Status='Active',
                                 Type='AFR');
        insert caseTest;
        
        Profile p = [SELECT Id FROM Profile WHERE Name='IETRS Case - Hearings'];
        User u = new User(Alias = 'hearing',
                          Email='hearinguser@testorg.com',
                          EmailEncodingKey='UTF-8', 
                          LastName='Testing', 
                          LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', 
                          ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles',
                          UserName='hearinguser1@testorg.com');
        Insert u;

        String strHearingsRecTypeId = Schema.Sobjecttype.IETRS_Case_Staff_Assignment__c.getRecordTypeInfosByDeveloperName().get('Hearings').getRecordTypeId();
        IETRS_Case_Staff_Assignment__c sa = new IETRS_Case_Staff_Assignment__c(IETRS_Case__c = caseTest.Id,
                                                                               IETRS_Assigned_Staff_Member__c = u.Id,
                                                                               IETRS_Role__c = 'Hearings Legal Assistant',
                                                                               IETRS_Lead__c = true,
                                                                               RecordTypeId = strHearingsRecTypeId,
                                                                               IETRS_First_Second_Chair__c = 'First Chair');
        insert sa;
    }
    
    @isTest
    static void checkFirstChairAvailibilitytest1(){
        Case objCase = [Select Id from Case limit 1];
        
        Profile p = [SELECT Id FROM Profile WHERE Name='IETRS Case - Hearings'];
        User u = new User(Alias = 'hearing',
                          Email='hearinguser@testorg.com',
                          EmailEncodingKey='UTF-8', 
                          LastName='Testing', 
                          LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', 
                          ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles',
                          UserName='hearinguser2@testorg.com');
        Insert u;

        String strHearingsRecTypeId = Schema.Sobjecttype.IETRS_Case_Staff_Assignment__c.getRecordTypeInfosByDeveloperName().get('Hearings').getRecordTypeId();
        IETRS_Case_Staff_Assignment__c sa = new IETRS_Case_Staff_Assignment__c(IETRS_Case__c = objCase.Id,
                                                                               IETRS_Assigned_Staff_Member__c = u.Id,
                                                                               IETRS_Role__c = 'Hearings Legal Assistant',
                                                                               IETRS_Lead__c = false,
                                                                               RecordTypeId = strHearingsRecTypeId,
                                                                               IETRS_First_Second_Chair__c = 'First Chair');
        try{
            insert sa;
        }
        catch(Exception e){
            system.debug('Error-->'+e.getMessage());
        }
    }
    
    @isTest
    static void checkFirstChairAvailibilitytest2(){
        Case objCase = [Select Id from Case limit 1];
        
        Profile p = [SELECT Id FROM Profile WHERE Name='IETRS Case - Hearings'];
        User u = new User(Alias = 'hearing',
                          Email='hearinguser@testorg.com',
                          EmailEncodingKey='UTF-8', 
                          LastName='Testing', 
                          LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', 
                          ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles',
                          UserName='hearinguser2@testorg.com');
        Insert u;

        String strHearingsRecTypeId = Schema.Sobjecttype.IETRS_Case_Staff_Assignment__c.getRecordTypeInfosByDeveloperName().get('Hearings').getRecordTypeId();
        IETRS_Case_Staff_Assignment__c sa = new IETRS_Case_Staff_Assignment__c(IETRS_Case__c = objCase.Id,
                                                                               IETRS_Assigned_Staff_Member__c = u.Id,
                                                                               IETRS_Role__c = 'Hearings Legal Assistant',
                                                                               IETRS_Lead__c = false,
                                                                               RecordTypeId = strHearingsRecTypeId,
                                                                               IETRS_First_Second_Chair__c = 'Second Chair');
        insert sa;
        
        sa.IETRS_First_Second_Chair__c = 'First Chair';
        try{
            update sa;
        }
        catch(Exception e){
            system.debug('Error-->'+e.getMessage());
        }
    }
}