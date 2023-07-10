@isTest
public class IETRS_ViolationTrigTest {
    @testSetup
    static void prepareData() {
        Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Regulated_Entity_PS')
            .getRecordTypeId();
        Account objAcc = new Account(Name = 'Regulated Entity PS');
        objAcc.RecordTypeId = accRecordTypeId;
        objAcc.Type = 'Distribution';
        insert objAcc;

        IETRS_Inspection_Package__c objInspPkg = new IETRS_Inspection_Package__c();
        objInspPkg.IETRS_Inspection_Type__c = 'Standard';
        insert objInspPkg;

        Id inspRecordTypeId = Schema.SObjectType.IETRS_Inspection__c.getRecordTypeInfosByDeveloperName()
            .get('PS_Inspection_Distribution_Systems')
            .getRecordTypeId();
        IETRS_Inspection__c objInsp = new IETRS_Inspection__c();
        objInsp.IETRS_Inspection_Package__c = objInspPkg.Id;
        objInsp.IETRS_Inspection_Status__c = 'Incomplete';
        objInsp.IETRS_Regulated_Entity__c = objAcc.Id;
        objInsp.RecordTypeId = inspRecordTypeId;
        insert objInsp;

        List<IETRS_Violation__c> violations = new List<IETRS_Violation__c>();
        IETRS_Violation__c objViolation = new IETRS_Violation__c();
        objViolation.IETRS_Regulated_Entity__c = objAcc.Id;
        objViolation.IETRS_Inspection_Package__c = objInspPkg.Id;
        objViolation.IETRS_Inspection__c = objInsp.Id;
        violations.add(objViolation);
        IETRS_Violation__c objViolation2 = new IETRS_Violation__c();
        objViolation2.IETRS_Regulated_Entity__c = objAcc.Id;
        objViolation2.IETRS_Inspection_Package__c = objInspPkg.Id;
        objViolation2.IETRS_Inspection__c = objInsp.Id;
        violations.add(objViolation2);
        insert violations;
    }

    static testMethod void testDeleteInsp() {
        Test.startTest();
        delete [SELECT Id FROM IETRS_Violation__c];
        Test.stopTest();
    }
    static testMethod void testDeleteInspector() {

        String strUserName = 'inspector' + DateTime.now().getTime() + '@testorg.com';
        // This code runs as the system user
        Profile p = [SELECT Id FROM Profile WHERE Name='IETRS Inspections - Inspector'];
        User uTest = new User(Alias = 'insptest', Email='standarduser@testorg.com',
                              EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                              LocaleSidKey='en_US', ProfileId = p.Id,
                              TimeZoneSidKey='America/Los_Angeles',
                              UserName=strUserName
                              );
        delete [SELECT Id FROM IETRS_Files_Correspondence__c];

        Test.startTest();
        System.runAs(uTest) {
            Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
                .get('Regulated_Entity_PS')
                .getRecordTypeId();
            Account objAcc = new Account(Name = 'Regulated Entity PS');
            objAcc.RecordTypeId = accRecordTypeId;
            objAcc.Type = 'Distribution';
            insert objAcc;

            IETRS_Inspection_Package__c objInspPkg = new IETRS_Inspection_Package__c();
            objInspPkg.IETRS_Inspection_Type__c = 'Standard';
            insert objInspPkg;

            Id inspRecordTypeId = Schema.SObjectType.IETRS_Inspection__c.getRecordTypeInfosByDeveloperName()
                .get('PS_Inspection_Distribution_Systems')
                .getRecordTypeId();
            IETRS_Inspection__c objInsp = new IETRS_Inspection__c();
            objInsp.IETRS_Inspection_Package__c = objInspPkg.Id;
            objInsp.IETRS_Inspection_Status__c = 'Incomplete';
            objInsp.IETRS_Regulated_Entity__c = objAcc.Id;
            objInsp.RecordTypeId = inspRecordTypeId;
            insert objInsp;

            List<IETRS_Violation__c> violations = new List<IETRS_Violation__c>();
            IETRS_Violation__c objViolation = new IETRS_Violation__c();
            objViolation.IETRS_Regulated_Entity__c = objAcc.Id;
            objViolation.IETRS_Inspection_Package__c = objInspPkg.Id;
            objViolation.IETRS_Inspection__c = objInsp.Id;
            insert objViolation;
            //violations.add(objViolation);
            //IETRS_Violation__c objViolation2 = new IETRS_Violation__c();
            //objViolation2.IETRS_Regulated_Entity__c = objAcc.Id;
            //objViolation2.IETRS_Inspection_Package__c = objInspPkg.Id;
            //objViolation2.IETRS_Inspection__c = objInsp.Id;
            //violations.add(objViolation2);
            //insert violations;

            try{
                delete objViolation;
                //delete [SELECT Id FROM IETRS_Violation__c];
            }
            catch(DMLException excp){
                System.assert(excp.getMessage().contains('Associated Inspection Package is not in state: "Work in Progress" or "WIP/Rejected" - You do not have permission to delete this record.'));
            }
              
          }
          Test.stopTest();
        
    }

    @IsTest
    static void itShouldSetViolationNumber() {
        List<IETRS_Violation__c> violations = [
            SELECT Id, IETRS_Violation_Num__c
            FROM IETRS_Violation__c
            WHERE IETRS_Violation_Num__c != null
        ];
        Integer violationsCount = violations.size();

        Test.startTest();
        delete violations;
        undelete violations;
        Test.stopTest();

        List<IETRS_Violation__c> undeletedViolations = [
            SELECT Id, IETRS_Violation_Num__c
            FROM IETRS_Violation__c
            WHERE IETRS_Violation_Num__c != null
        ];
        System.assertEquals(violationsCount > 0, true, 'The violation trigger should have set the violation number');
        System.assertEquals(
            violationsCount,
            undeletedViolations.size(),
            'The violation trigger should have set the violation number'
        );
    }
}