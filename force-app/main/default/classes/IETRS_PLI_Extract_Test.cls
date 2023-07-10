/**
 * @description       : Test class for PLI batches
 * @author            : Kevin Lu
 * @group             : 
 * @last modified on  : 2020-09-01
 * @last modified by  : Kevin Lu
 * Modifications Log 
 * Ver      Date            Author                  Modification
 * 1.0      2020-07-06      Kevin Lu                Initial Version
 * 2.0      2020-09-01      Kevin Lu                Changed to Delete batch classes
 * 3.0      2021-06-14      Sebastian Wittenstein   Added fields to system account records and contact records to improve code coverage, modified system assert statement
 * 4.0      2022-09-23      Sarabpreet Singh        Increased length to 6 for IETRS_Company_ID__c
**/
@IsTest
private class IETRS_PLI_Extract_Test {
    @TestSetup
    static void makeData(){
        RecordType orgRecordType = [SELECT Id FROM RecordType WHERE Name = 'Organization' AND SObjectType = 'Account' LIMIT 1];
        RecordType unitRecordType = [SELECT Id FROM RecordType WHERE Name = 'Unit' AND SObjectType = 'Account' LIMIT 1];
        RecordType regulatedEntityRecordType = [SELECT Id FROM RecordType WHERE Name = 'Regulated Entity - PS' AND SObjectType = 'Account' LIMIT 1];
        //Accounts and contacts for Company and TDR testing
        Account a = new Account();
        a.Name = 'APEXTESTTest Organization 1';
        a.IETRS_P5_Number__c = '123456';
        a.IETRS_Company_ID__c = '123456';
        a.RecordTypeId = orgRecordType.Id;
        insert a;

        Account b = new Account();
        b.Name = 'APEXTESTTest Organization 2';
        b.IETRS_P5_Number__c = '234567';
        b.IETRS_Company_ID__c = '234567';
        b.RecordTypeId = orgRecordType.Id;
        insert b;

        Contact c = new Contact();
        c.LastName = 'Contact 1';
        c.FirstName = 'Test';
        c.AccountId = a.Id;
        c.IETRS_Contact_Type__c = 'Company Representative';
        c.MailingCity = 'Austin';
        c.MailingState = 'TX';
        c.MailingCountry = 'USA';
        c.MailingPostalCode = '78701';
        c.MailingStreet = '1700 congress';
        c.IETRS_24_Hour_Phone__c = '1234567890';
        c.Phone = '9871234560';
        insert c;

        Contact d = new Contact();
        d.LastName = 'Contact 2';
        d.FirstName = 'Test';
        d.AccountId = a.Id;
        d.IETRS_Contact_Type__c = 'TPD Representative';
        insert d;

        Contact e = new Contact();
        e.LastName = 'Contact 3';
        e.FirstName = 'Test';
        e.AccountId = b.Id;
        e.IETRS_Contact_Type__c = 'Company Representative';
        e.MailingStreet = '123 Street \\n Suite 100';
        e.Salutation = 'Sir';
        e.MailingCity = 'Austin';
        e.MailingState = 'TX';
        e.MailingCountry = 'USA';
        e.MailingPostalCode = '78701';
        e.IETRS_24_Hour_Phone__c = '1234567890';
        e.Phone = '9871234560';
        insert e;

        Contact f = new Contact();
        f.LastName = 'Contact 2';
        f.FirstName = 'Test';
        f.AccountId = b.Id;
        f.IETRS_Contact_Type__c = 'TPD Representative';
        f.MailingStreet = '123 Street \\n Suite 100';
        f.Salutation = 'Sir';
        insert f;

        //Units for unit extract test
        Account unitA = new Account();
        unitA.Name = 'Test Unit 1';
        unitA.ParentId = a.Id;
        unitA.RecordTypeId = unitRecordType.Id;
        insert unitA;

        Account unitB = new Account();
        unitB.Name = 'Test Unit 2';
        unitB.ParentId = b.Id;
        unitB.RecordTypeId = unitRecordType.Id;
        insert unitB;

        //Systems for system extract test
        Account systemA = new Account();
        systemA.Name = 'Test System 1';
        systemA.IETRS_Status__c = 'Active';
        systemA.IETRS_Jurisdiction__c = 'Jurisdictional';
        systemA.IETRS_Entity_Code__c = 'B-Apartments';
        systemA.IETRS_Product_Class__c = 'Gas';
        systemA.IETRS_Product_Sub_Class__c = 'LNG';
        systemA.Type = 'Gathering';
        systemA.IETRS_Entity_Sub_Type__c = 'Regulated';
        systemA.IETRS_OrganizationofRegEntity__c = a.Id;
        systemA.ParentId = unitA.Id;
        systemA.RecordTypeId = regulatedEntityRecordType.Id;
        systemA.IETRS_Intra_Interstate__c = 'Intrastate';
        systemA.IETRS_On_Offshore__c = 'Onshore';
        systemA.IETRS_Total_Miles__c = 10.00;
        systemA.IETRS_Install_Year__c = '0000';
        systemA.IETRS_T4_Permit__c = '1234';
        insert systemA;

        Account systemB = new Account();
        systemB.Name = 'Test System 2';
        systemB.IETRS_Status__c = 'Active';
        systemB.IETRS_Jurisdiction__c = 'Non-jurisdictional';
        systemB.IETRS_Entity_Code__c = 'B-Apartments';
        systemB.IETRS_Product_Class__c = 'Gas';
        systemB.IETRS_Product_Sub_Class__c = 'LNG';
        systemB.Type = 'Gathering';
        systemB.IETRS_Entity_Sub_Type__c = 'Regulated';
        systemB.IETRS_OrganizationofRegEntity__c = b.Id;
        systemB.ParentId = unitB.Id;
        systemB.RecordTypeId = regulatedEntityRecordType.Id;
        systemB.IETRS_Intra_Interstate__c = 'Interstate';
        systemB.IETRS_On_Offshore__c = 'Onshore';
        systemB.IETRS_Total_Miles__c = 10.00;
        systemB.IETRS_Install_Year__c = '0000';
        systemB.IETRS_T4_Permit__c = '1234';
        insert systemB;

        Account systemC = new Account();
        systemC.Name = 'Test System 3';
        systemC.IETRS_Status__c = 'Idle';
        systemC.IETRS_Jurisdiction__c = 'Interstate';
        systemC.IETRS_Entity_Code__c = 'B-Apartments';
        systemC.IETRS_Product_Class__c = 'Gas';
        systemC.IETRS_Product_Sub_Class__c = 'LNG';
        systemC.Type = 'Gathering';
        systemC.IETRS_Entity_Sub_Type__c = 'Regulated';
        systemC.IETRS_OrganizationofRegEntity__c = a.Id;
        systemC.ParentId = unitA.Id;
        systemC.RecordTypeId = regulatedEntityRecordType.Id;
        systemC.IETRS_Intra_Interstate__c = 'Interstate Agent';
        systemC.IETRS_On_Offshore__c = 'Onshore';
        systemC.IETRS_Total_Miles__c = 10.00;
        systemC.IETRS_Install_Year__c = '0000';
        systemC.IETRS_T4_Permit__c = '1234';
        insert systemC;

        Account systemD = new Account();
        systemD.Name = 'Test System 4';
        systemD.IETRS_Status__c = 'Abandoned';
        systemD.IETRS_Jurisdiction__c = 'Odorization';
        systemD.IETRS_Entity_Code__c = 'B-Apartments';
        systemD.IETRS_Product_Class__c = 'Gas';
        systemD.IETRS_Product_Sub_Class__c = 'LNG';
        systemD.Type = 'Gathering';
        systemD.IETRS_Entity_Sub_Type__c = 'Regulated';
        systemD.IETRS_OrganizationofRegEntity__c = b.Id;
        systemD.IETRS_Total_Miles__c  = 0;
        systemD.ParentId = unitB.Id;
        systemD.RecordTypeId = regulatedEntityRecordType.Id;
        systemD.IETRS_On_Offshore__c = 'Onshore';
        systemD.IETRS_Total_Miles__c = 10.00;
        systemD.IETRS_Install_Year__c = '0000';
        systemD.IETRS_T4_Permit__c = '1234';
        insert systemD;

        Account systemE = new Account();
        systemE.Name = 'Test System 5';
        systemE.IETRS_Status__c = '';
        systemE.IETRS_Jurisdiction__c = '';
        systemE.IETRS_Entity_Code__c = 'B-Apartments';
        systemE.IETRS_Product_Class__c = 'Gas';
        systemE.IETRS_Product_Sub_Class__c = 'LNG';
        systemE.Type = 'Gathering';
        systemE.IETRS_Entity_Sub_Type__c = 'Regulated';
        systemE.IETRS_OrganizationofRegEntity__c = b.Id;
        systemE.IETRS_Total_Miles__c  = -1;
        systemE.ParentId = unitB.Id;
        systemE.RecordTypeId = regulatedEntityRecordType.Id;
        systemE.IETRS_On_Offshore__c = 'Onshore';
        systemE.IETRS_Total_Miles__c = 10.00;
        systemE.IETRS_Install_Year__c = '0000';
        systemE.IETRS_T4_Permit__c = '1234';
        insert systemE;
    }

    @IsTest
    static void testPLICompanyExtract(){

        IETRS_PLI_Extract_Company__c delComp = new IETRS_PLI_Extract_Company__c();
        insert delComp;

        Test.startTest();
        Database.executeBatch(new IETRS_PLI_Company_Extract_Delete());
        Test.stopTest();
        
        List<IETRS_PLI_Extract_Company__c> lstExtract = [
            SELECT Id 
            FROM IETRS_PLI_Extract_Company__c
            WHERE RecordType.Name = 'Company Extract'
        ];

        System.assertEquals(2, lstExtract.size(), 'Company extract failed to load correct number of records');
    }

    @IsTest
    static void testPLITDRExtract(){

        RecordType tdr = new RecordType();
        tdr = [SELECT Id FROM RecordType WHERE Name = 'TDR Extract'];
        
        IETRS_PLI_Extract_Company__c delComp = new IETRS_PLI_Extract_Company__c(RecordTypeId = tdr.Id);
        insert delComp;

        Test.startTest();
        Database.executeBatch(new IETRS_PLI_TDR_Extract_Delete());
        Test.stopTest();
        
        List<IETRS_PLI_Extract_Company__c> lstExtract = [
            SELECT Id 
            FROM IETRS_PLI_Extract_Company__c
            WHERE RecordType.Name = 'TDR Extract'
        ];

        System.assertEquals(2, lstExtract.size(), 'TDR extract failed to load correct number of records');
    }

    @IsTest
    static void testPLIUnitExtract(){

        IETRS_PLI_Extract_Unit__c delUnit = new IETRS_PLI_Extract_Unit__c();
        insert delUnit;

        Test.startTest();
        Database.executeBatch(new IETRS_PLI_Unit_Extract_Delete());
        Test.stopTest();
        
        List<IETRS_PLI_Extract_Unit__c> lstExtract = [
            SELECT Id 
            FROM IETRS_PLI_Extract_Unit__c
        ];

        System.assertEquals(2, lstExtract.size(), 'Unit extract failed to load correct number of records');
    }

    @IsTest
    static void testPLISystemExtract(){

        IETRS_PLI_Extract_System__c delSys = new IETRS_PLI_Extract_System__c();
        insert delSys;

        Test.startTest();
        Database.executeBatch(new IETRS_PLI_System_Extract_Delete());
        Test.stopTest();
        
        List<IETRS_PLI_Extract_System__c> lstExtract = [
            SELECT Id 
            FROM IETRS_PLI_Extract_System__c
        ];

        System.assertEquals(4, lstExtract.size(), 'System extract failed to load correct number of records');
    }
}