@isTest
public class CIIS_MassSubmitUpdateAction_Test {
    
    @testSetup
    static void makeData(){
        User runningUser = [
            SELECT
            Id,
            TimeZoneSidKey,
            LocaleSidKey,
            EmailEncodingKey,
            LanguageLocaleKey,
            ProfileId
            FROM User
            WHERE Id = :UserInfo.getUserId()
        ];
        System.runAs(runningUser) {
            RecordType accOrgRT = new RecordType();
            accOrgRT = [
                SELECT Id
                FROM RecordType
                WHERE SobjectType = 'Account' AND DeveloperName = 'Organization'
                LIMIT 1
            ][0];
            Account org = new Account(
                Name = 'Test Org',
                RecordTypeId = accOrgRT.Id
            );
            insert org;
            Account unitAcct = new Account(
                Name = 'Unit',
                RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Unit').getRecordTypeId(),
                ParentId = org.Id,
                Type = 'Distribution');
            Insert unitAcct;
            Account entity = new Account(
                Name = 'Regulated Entity PS ',
                RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Regulated_Entity_PS').getRecordTypeId(),
                IETRS_OrganizationofRegEntity__c = org.Id,
                IETRS_Unit_Parent__c = unitAcct.Id,
                ParentId = unitAcct.Id,
                IETRS_Product_Class__c = 'Gas',
                IETRS_Jurisdiction__c = 'Jurisdictional',
                IETRS_Intra_Interstate__c = 'Intrastate',
                Type = 'Distribution',
                IETRS_Entity_Sub_Type__c = 'Private Main System',
                IETRS_Total_Miles__c = 1,
                IETRS_On_Offshore__c = 'Onshore',
                IETRS_Product_Sub_Class__c = 'Natural',
                IETRS_Install_Year__c = '2000',
                IETRS_T4_Permit__c = '12345',
                CIIS_PL_Classification__c = 'PL Compressor Station');
            Insert entity;
            CIDX_Filing_Period__c cfp = new CIDX_Filing_Period__c(CIDX_Filing_Year__c = 2023, CIDX_Filing_Session__c = 'March');
            Insert cfp;
            CIDX_Critical_Indication__c cfi = new CIDX_Critical_Indication__c(CIDX_Filing_Period__c = cfp.Id);
            cfi.CIDX_Regulated_Entity__c = entity.Id;
            Insert cfi;
            CIDx_Filing__c  cf = new CIDx_Filing__c ();
            cf.CIDX_Filing_Period__c = cfp.Id;
            cf.CIDX_Critical_Indication__c  = cfi.Id;
            cf.CIDX_Organization__c = org.Id;
            cf.CIDX_Filing_Status__c  = 'Validation Failed';
            cf.CIDX_Regulated_Entity_Backup_Power__c = 'Yes';
            cf.CIDX_Reliant_on_Electricity_to_Operate__c = 'Yes';
            Insert cf;
        }
    }
    
    @isTest
    static void testMethod1(){
        CIIS_MassSubmitAction.massSubmitRequest req = new CIIS_MassSubmitAction.massSubmitRequest();
        req.filingSession = 'March';
        req.filingYear = 2023;
        req.filingStatus = 'Validation Failed';
        req.Organization = [SELECT ID FROM Account WHERE Name = 'Test Org'].Id;
        req.Submitted_Date = system.today();
        List<CIIS_MassSubmitAction.massSubmitRequest> reqsts = new List<CIIS_MassSubmitAction.massSubmitRequest>{req};
            CIIS_MassSubmitAction.CIIS_PerformMassSubmit(reqsts);
    }
    
    @isTest
    static void testMethod2(){
        CIIS_MassUpdateAction.massUpdateRequest req = new CIIS_MassUpdateAction.massUpdateRequest();
        req.filingSession = 'March';
        req.filingYear = 2023;
        req.filingStatus = 'Validation Failed';
        req.Organization = [SELECT ID FROM Account WHERE Name = 'Test Org'].Id;
        req.filingRecordUpdatedValues = new CIDx_Filing__c();
        req.selectedFilteredFilings = new List<String>{[SELECT ID FROM CIDx_Filing__c LIMIT 1].Id};
        req.updateAll = true;
        req.electricityReliance = 'Yes';
        req.BackupPower = 'Yes';
        req.fieldChoices = 'Emergency Contact,Onsite Contact,Backup Power,Comp Utility Information,Non Comp Utility Information';
        List<CIIS_MassUpdateAction.massUpdateRequest> reqsts = new List<CIIS_MassUpdateAction.massUpdateRequest>{req};
            CIIS_MassUpdateAction.CIIS_PerformMassUpdate(reqsts);
    }
}