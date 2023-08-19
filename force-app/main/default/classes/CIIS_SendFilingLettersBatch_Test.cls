@isTest
public class CIIS_SendFilingLettersBatch_Test {
    
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
                billingStreet = '100 Test Blvd; Suite 400',
                RecordTypeId = accOrgRT.Id
            );
            insert org;
            Contact con = new Contact(FirstName='Test', LastName= 'Rep', Email='Test@test.com', MailingStreet = 'Test', MailingCity='test', MailingState='OH', MailingPostalCode='78946', MailingCountry='USA', IETRS_24_Hour_Phone__c ='789-789-7899', IETRS_Contact_Type__c ='Company Representative', Phone='7897897890', accountId = org.ID);
            Insert con;
            Org.IETRS_Representative__c = con.ID;
            Update org;
            Account unitAcct = new Account(
                Name = 'Unit',
                RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Unit').getRecordTypeId(),
                ParentId = org.Id,
                Type = 'Distribution');
            Insert unitAcct;
            Account entity = new Account(
                Name = 'Entity',
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
                CIIS_Reg_Entity_MCF_day__c = 600,
                IETRS_Install_Year__c = '2000',
                IETRS_T4_Permit__c = '12345');
            Insert entity;
        }
    }
    
    public static testMethod void testschedule() {
        ID entity = [SELECT ID FROM Account WHERE Name = 'Entity'].ID;
        Id orgId = [SELECT ID FROM Account WHERE Name = 'Test Org'].ID;
        
        ID cfpRecTypeID = Schema.SObjectType.CIDX_Filing_Period__c.getRecordTypeInfosByName().get('CID/CIX')?.getRecordTypeId();	
        CIDX_Filing_Period__c cfp = new CIDX_Filing_Period__c(CIDX_Filing_Year__c = 2023, RecordTypeId = cfpRecTypeID, CIDX_Filing_Session__c = 'March',CIDX_Due_Date__c = System.today(), CIDX_Apex_Start_Date__c = System.today());
        Insert cfp;

        CIDX_Critical_Indication__c cfi = new CIDX_Critical_Indication__c(CIDX_Filing_Period__c = cfp.Id);
        cfi.CIDX_Regulated_Entity__c = entity;
        Insert cfi;
        
        ID cfID = Schema.SObjectType.CIDX_Filing__c.getRecordTypeInfosByName().get('Gas Well > 250 MCF/Day').getRecordTypeId();	      
        CIDX_Filing__c CF = new CIDX_Filing__c(CIDX_Organization__c = orgId, RecordTypeID = cfID, CIDX_Critical_Indication__c  = cfi.Id, CIDX_Filing_Status__c = 'Draft' ,CIDX_Filing_Period__c = cfp.ID);
        Insert CF;
        CIDX_Filing__c CF2 = new CIDX_Filing__c(CIDX_Organization__c = orgId, RecordTypeID = cfID, CIDX_Critical_Indication__c  = cfi.Id, CIDX_Filing_Status__c = 'Draft' ,CIDX_Filing_Period__c = cfp.ID);
        Insert CF2;
        
        Test.StartTest();
        
        CIIS_SendFilingLettersBatchScheduler sched = new CIIS_SendFilingLettersBatchScheduler();
        String sch = '0 0 23 * * ?'; 
        system.schedule('Test Audit Creation Check', sch, sched); 
        Test.stopTest(); 
    }
    
    public static testMethod void testschedule2() {
        ID entity = [SELECT ID FROM Account WHERE Name = 'Entity'].ID;
        
        Account org = [SELECT ID, BillingStreet, IETRS_Representative__c FROM Account WHERE Name = 'Test Org'];
        org.BillingStreet = 'Test BLVD';
        org.IETRS_Representative__c = NULL;
        Update org;
        
        ID cfpRecTypeID = Schema.SObjectType.CIDX_Filing_Period__c.getRecordTypeInfosByName().get('CID/CIX')?.getRecordTypeId();	
        CIDX_Filing_Period__c cfp = new CIDX_Filing_Period__c(CIDX_Filing_Year__c = 2023, RecordTypeId = cfpRecTypeID, CIDX_Filing_Session__c = 'March',CIDX_Due_Date__c = System.today(), CIDX_Apex_Start_Date__c = System.today());
        Insert cfp;
        CIDX_Critical_Indication__c cfi = new CIDX_Critical_Indication__c(CIDX_Filing_Period__c = cfp.Id);
        cfi.CIDX_Regulated_Entity__c = entity;
        Insert cfi;
        
        ID cfID = Schema.SObjectType.CIDX_Filing__c.getRecordTypeInfosByName().get('Gas Well > 250 MCF/Day').getRecordTypeId();	
        CIDX_Filing__c CF = new CIDX_Filing__c(CIDX_Organization__c = org.Id, RecordTypeID = cfID, CIDX_Critical_Indication__c  = cfi.Id, CIDX_Filing_Status__c = 'Draft' ,CIDX_Filing_Period__c = cfp.ID);
        Insert CF;
        CIDX_Filing__c CF2 = new CIDX_Filing__c(CIDX_Organization__c = org.Id, RecordTypeID = cfID, CIDX_Critical_Indication__c  = cfi.Id, CIDX_Filing_Status__c = 'Process Hearing' ,CIDX_Filing_Period__c = cfp.ID);
        Insert CF2;
        Test.StartTest();
        
        CIIS_SendFilingLettersBatchScheduler sched = new CIIS_SendFilingLettersBatchScheduler();
        String sch = '0 0 23 * * ?'; 
        system.schedule('Test Audit Creation Check', sch, sched); 
        Test.stopTest(); 
    }
}