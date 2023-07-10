/**
 * @File Name          : IETRS_AccountTrigger_Test.cls
 * @Description        : 
 * @Author             : Kevin Lu
 * @Group              : 
 * @Last Modified By   : Kevin Lu
 * @Last Modified On   : 3/19/2020, 11:20:44 AM
 * @Modification Log   : 
 * Ver      Date            Author          Modification
 * 1.0      10/31/2019      Kevin Lu        Initial Version
 * 2.0      03/19/2020      Kevin Lu        Trigger logic removed from trigger, tested by IETRS_Oil_And_Gas_Controller
**/
@isTest
private class IETRS_AccountTrigger_Test {
    /*private static Id RECORD_TYPE_OIL_GAS = [Select Id From RecordType Where Name = 'Regulated Entity - OG' And sObjectType = 'Account' Limit 1].Id;
    private static Id RECORD_TYPE_FIELD = [Select Id From RecordType Where Name = 'Field' And sObjectType = 'Account' Limit 1].Id;
    
    @TestSetup
    static void makeData() {
        Account acctPermit = new Account();
        acctPermit.type = 'Drilling Permit';
        acctPermit.RecordTypeId = RECORD_TYPE_OIL_GAS;
        acctPermit.Name = 'Test Drilling Permit';
        acctPermit.IETRS_Permit_Field_Exception__c = true;
        insert acctPermit;

        Account acctPermittedField = new Account();
        acctPermittedField.Type = 'Permitted Field';
        acctPermittedField.RecordTypeId = RECORD_TYPE_FIELD;
        acctPermittedField.Name = 'Test Permitted Field';
        acctPermittedField.IETRS_Permitted_Field_SWR37L__c = true;
        acctPermittedField.ParentId = acctPermit.Id;
        insert acctPermittedField;

        Account acctPermitFalse = new Account();
        acctPermitFalse.type = 'Drilling Permit';
        acctPermitFalse.RecordTypeId = RECORD_TYPE_OIL_GAS;
        acctPermitFalse.Name = 'False Drilling Permit';
        acctPermitFalse.IETRS_Permit_Field_Exception__c = false;
        insert acctPermitFalse;

        Account acctPermittedFieldFalse = new Account();
        acctPermittedFieldFalse.Type = 'Permitted Field';
        acctPermittedFieldFalse.RecordTypeId = RECORD_TYPE_FIELD;
        acctPermittedFieldFalse.Name = 'Test Permitted Field False';
        acctPermittedFieldFalse.ParentId = acctPermitFalse.Id;
        insert acctPermittedFieldFalse;

        System.debug(acctPermit);
        System.debug(acctPermittedField);
        System.debug(acctPermitFalse);
        System.debug(acctPermittedFieldFalse);
    }

    @isTest
    static void testImpactfulUpdateFlagChange() {
        Account permit = [Select Id, Name, IETRS_Permit_Field_Exception__c, IETRS_Field_Exception__c From Account Where Name = 'Test Drilling Permit'].get(0);
        System.assertEquals(true, permit.IETRS_Permit_Field_Exception__c, 'Permit exception flag is incorrect');

        Test.startTest();
        Account permittedField = [Select Id, Name, IETRS_Permit_Field_Exception__c, IETRS_Field_Exception__c From Account Where Name = 'Test Permitted Field'].get(0);
        permittedField.IETRS_Permitted_Field_SWR37L__c = false;
        update permittedField;
        Test.stopTest();

        permit = [Select Id, Name, IETRS_Permit_Field_Exception__c, IETRS_Field_Exception__c From Account Where Name = 'Test Drilling Permit'].get(0);
        System.assertEquals(false, permit.IETRS_Permit_Field_Exception__c, 'Permit exception flag not updated');
    }

    @isTest
    static void testImpactfulUpdateParentChange() {
        Account permit = [Select Id, Name, IETRS_Permit_Field_Exception__c, IETRS_Field_Exception__c From Account Where Name = 'Test Drilling Permit'].get(0);
        System.assertEquals(true, permit.IETRS_Permit_Field_Exception__c, 'Permit exception flag is incorrect');

        Test.startTest();
        Account newPermit = new Account();
        newPermit.type = 'Drilling Permit';
        newPermit.RecordTypeId = RECORD_TYPE_OIL_GAS;
        newPermit.Name = 'New Drilling Permit';
        insert newPermit;

        Account permittedField = [Select Id, Name, IETRS_Permit_Field_Exception__c, IETRS_Field_Exception__c From Account Where Name = 'Test Permitted Field'].get(0);
        permittedField.ParentId = newPermit.Id;
        update permittedField;
        Test.stopTest();

        permit = [Select Id, Name, IETRS_Permit_Field_Exception__c, IETRS_Field_Exception__c From Account Where Name = 'Test Drilling Permit'].get(0);
        newPermit = [Select Id, Name, IETRS_Permit_Field_Exception__c, IETRS_Field_Exception__c From Account Where Name = 'New Drilling Permit'].get(0);
        System.assertEquals(false, permit.IETRS_Permit_Field_Exception__c, 'Old permit not updated');
        System.assertEquals(true, newPermit.IETRS_Permit_Field_Exception__c, 'New permit not updated');
    }

    @isTest
    static void testUnimpactfulUpdate() {
        Account permit = [Select Id, Name, IETRS_Permit_Field_Exception__c, IETRS_Field_Exception__c From Account Where Name = 'Test Drilling Permit'].get(0);
        System.assertEquals(true, permit.IETRS_Permit_Field_Exception__c, 'Permit exception flag is incorrect');

        Test.startTest();
        Account permittedField = [Select Id, Name, IETRS_Permit_Field_Exception__c, IETRS_Field_Exception__c From Account Where Name = 'Test Permitted Field'].get(0);
        permittedField.Name = 'Changed Name';
        update permittedField;
        Test.stopTest();

        permit = [Select Id, Name, IETRS_Permit_Field_Exception__c, IETRS_Field_Exception__c From Account Where Name = 'Test Drilling Permit'].get(0);
        System.assertEquals(true, permit.IETRS_Permit_Field_Exception__c, 'Permit exception flag unexpectedly pdated');
    }

    @isTest
    static void testUnimpactfulInsert() {
        Account permit = [Select Id, Name, IETRS_Permit_Field_Exception__c, IETRS_Field_Exception__c From Account Where Name = 'Test Drilling Permit'].get(0);
        System.assertEquals(true, permit.IETRS_Permit_Field_Exception__c, 'Permit exception flag is incorrect');

        Test.startTest();
        Account newDrillingPermit = new Account();
        newDrillingPermit.Type = 'Permitted Field';
        newDrillingPermit.RecordTypeId = RECORD_TYPE_FIELD;
        newDrillingPermit.Name = 'New Permitted Field';
        newDrillingPermit.ParentId = permit.Id;
        insert newDrillingPermit;
        Test.stopTest();

        permit = [Select Id, Name, IETRS_Permit_Field_Exception__c, IETRS_Field_Exception__c From Account Where Name = 'Test Drilling Permit'].get(0);
        System.assertEquals(true, permit.IETRS_Permit_Field_Exception__c, 'Permit exception flag changed unexpectedly');
    }

    @isTest
    static void testImpactfulInsert() {
        Account permit = [Select Id, Name, IETRS_Permit_Field_Exception__c, IETRS_Field_Exception__c From Account Where Name = 'False Drilling Permit'].get(0);
        System.assertEquals(false, permit.IETRS_Permit_Field_Exception__c, 'Permit exception flag is incorrect');

        Test.startTest();
        Account newDrillingPermit = new Account();
        newDrillingPermit.Type = 'Permitted Field';
        newDrillingPermit.RecordTypeId = RECORD_TYPE_FIELD;
        newDrillingPermit.Name = 'New Permitted Field';
        newDrillingPermit.IETRS_Permitted_Field_SWR37B__c = true;
        newDrillingPermit.ParentId = permit.Id;
        insert newDrillingPermit;
        Test.stopTest();

        permit = [Select Id, Name, IETRS_Permit_Field_Exception__c, IETRS_Field_Exception__c From Account Where Name = 'False Drilling Permit'].get(0);
        System.assertEquals(true, permit.IETRS_Permit_Field_Exception__c, 'Permit exception flag not updated');
    }
    */
}