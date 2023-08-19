@isTest
public class CIIS_CIBatchScheduler_Test {
    
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
                Name = 'Regulated Entity OG1 ',
                RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Regulated_Entity_OG').getRecordTypeId(),
                IETRS_OrganizationofRegEntity__c = org.Id,
                IETRS_Unit_Parent__c = unitAcct.Id,
                ParentId = unitAcct.Id,
                IETRS_Product_Class__c = 'Liquid',
                IETRS_Jurisdiction__c = 'Jurisdictional',
                IETRS_Intra_Interstate__c = 'Intrastate',
                Type = 'Lease',
                IETRS_Entity_Sub_Type__c = 'Oil',
                IETRS_Total_Miles__c = 1,
                IETRS_On_Offshore__c = 'Onshore',
                IETRS_Product_Sub_Class__c = 'Crude',
                CIIS_PL_Classification__c = 'Oil Lease',
                CIIS_Reg_Entity_MCF_day__c = 600,
                IETRS_Install_Year__c = '2000',
                IETRS_T4_Permit__c = '12345');
            Insert entity;
            Account entity2 = new Account(
                Name = 'Regulated Entity OG2 ',
                RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Regulated_Entity_OG').getRecordTypeId(),
                IETRS_OrganizationofRegEntity__c = org.Id,
                IETRS_Unit_Parent__c = unitAcct.Id,
                ParentId = unitAcct.Id,
                IETRS_Product_Class__c = 'Gas',
                IETRS_Jurisdiction__c = 'Jurisdictional',
                IETRS_Intra_Interstate__c = 'Intrastate',
                Type = 'Lease',
                IETRS_Entity_Sub_Type__c = 'Gas',
                IETRS_Total_Miles__c = 1,
                IETRS_On_Offshore__c = 'Onshore',
                IETRS_Product_Sub_Class__c = 'Natural',
                CIIS_PL_Classification__c = 'Gas Lease',
                CIIS_Reg_Entity_MCF_day__c = 0,
                IETRS_Install_Year__c = '2000',
                IETRS_T4_Permit__c = '12345');
            Insert entity2;

            CIDX_Filing_Period__c cfp = new CIDX_Filing_Period__c(CIDX_Filing_Year__c = 2023, CIDX_Filing_Session__c = 'March', CIDX_Apex_Start_Date__c = System.today());
            Insert cfp;
            CIDX_Filing_Period__c cfp2 = new CIDX_Filing_Period__c(CIDX_Filing_Year__c = 2023, CIDX_Filing_Session__c = 'March', CIDX_Apex_Start_Date__c = System.today().addDays(-1));
            Insert cfp2;
        }
    }
    
    
    
    public static testMethod void testschedule() {
        
        Test.StartTest();
        CIIS_CriticalIndicationsBatchScheduler sched = new CIIS_CriticalIndicationsBatchScheduler();
        
        String sch = '0 0 23 * * ?'; 
        system.schedule('Test Audit Creation Check', sch, sched); 
        Test.stopTest(); 
    }
}