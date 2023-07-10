@isTest
public class IETRS_Custom_Report_PDFTest {
 
    @testSetup
    static void prepareData() {
        IETRS_I_TestUtils testUtils = new IETRS_I_TestUtils();
        testUtils.entityFieldValuesByField.put(
            Account.IETRS_Product_Class__c,
            new List<String>{ 'Gas', 'Gas' }
        );
        testUtils.entityFieldValuesByField.put(
            Account.Type,
            new List<String>{ 'Distribution', 'Distribution' }
        );
        testUtils.entityFieldValuesByField.put(
            Account.IETRS_Entity_Sub_Type__c,
            new List<String>{ 'Private Main System', 'Private Main System' }
        );
        testUtils.entityFieldValuesByField.put(
            Account.IETRS_Product_Sub_Class__c,
            new List<String>{ 'Natural', 'Natural' }
        );
        testUtils.entityFieldValuesByField.put(
            Account.IETRS_Business_Area__c,
            new List<String>{ 'Pipeline Safety' }
        );
        testUtils.entityFieldValuesByField.put(
            Account.IETRS_Status__c,
            new List<String>{ 'Active', 'Active' }
        );
        testUtils.createData(2, 5);

        
        // set search param values on an org
        Account org = [
            SELECT Id
            FROM Account
            WHERE RecordType.DeveloperName = 'Organization'
            LIMIT 1
        ];
        org.BillingStreet = 'Street 1';
        org.BillingCity = 'Dallas';
        org.BillingState = 'TX';
        org.BillingPostalCode = 'USA';
        org.BillingCountry = '75039';
        update org;
       IETRS_Counties__c countys=new IETRS_Counties__c();
        countys.County_Names__c='County1;County2';
        insert countys;
        IETRS_InspSchedule__c existingInspectionSchedule = [
            select id,IETRS_Regulated_Entity__r.IETRS_Unit_Type_from_Regulated_Entity__c,IETRS_Regulated_Entity__r.ParentId,
            IETRS_Region__c,
            IETRS_Scheduled2__c,
            IETRS_Scheduled__c,
            IETRS_Inspection_Year__c,
            IETRS_Priority__c from IETRS_InspSchedule__c LIMIT 1
        ];
        
        
        List<IETRS_Inspection_Package__c> existingInspectionPkg=[select id,Name,IETRS_First_Inspection_Class__c,IETRS_Begin_Date__c,IETRS_End_Date__c from IETRS_Inspection_Package__c where IETRS_Shared_Public_Record_Account__c != null];
        if(existingInspectionPkg != null && !existingInspectionPkg.isEmpty()){
            existingInspectionPkg[0].IETRS_Begin_Date__c=system.today();
            existingInspectionPkg[0].IETRS_End_Date__c=system.today();
            existingInspectionPkg[0].IETRS_Business_Area__c='Pipeline Safety';
            existingInspectionPkg[0].IETRS_Status__c='Closed';
            update existingInspectionPkg;
            
            
            
            List<IETRS_Inspection__c> existingInspection=[select id,Name,IETRS_Inspection_Package__r.Name,
                                                          IETRS_Inspection_Package__r.IETRS_Begin_Date__c,
                                                          IETRS_Inspection_Package__r.IETRS_End_Date__c,
                                                          IETRS_Activity_Classification__c,
                                                          IETRS_Regulated_Entity_Type__c,
                                                          IETRS_Regulated_Entity__c,
                                                          IETRS_Inspection_Package__r.IETRS_Lead_Inspector_Name__c,
                                                          IETRS_Inspection_Package__r.IETRS_First_Inspection_Class__c,
                                                          IETRS_Inspection_Package__r.IETRS_Business_Area__c,
                                                          IETRS_Regulated_Entity__r.IETRS_Allowed_Inspection_Record_Type__c,
                                                          RecordType.Name,
                                                          IETRS_Inspection_Package__r.IETRS_Num_Inspections__c,
                                                          IETRS_Inspection_Package__r.IETRS_Status__c,
                                                          IETRS_TotalMilesAtEval__c,
                                                          IETRS_TotalViolations__c from IETRS_Inspection__c where IETRS_Inspection_Package__c=:existingInspectionPkg[0].id];
            system.debug('existingInspection'+existingInspection);
            system.debug('inspkg'+existingInspectionPkg);
        }
        Id distributionInspRecordTypeId = Schema.SObjectType.IETRS_Inspection__c.getRecordTypeInfosByDeveloperName()
            .get('PS_Inspection_Distribution_Systems')
            .getRecordTypeId();
        Id masterMeterInspRecordTypeId = Schema.SObjectType.IETRS_Inspection__c.getRecordTypeInfosByDeveloperName()
            .get('PS_Inspection_Master_Meter_Systems')
            .getRecordTypeId();
        Id inspPackageRecordTypeId = Schema.SObjectType.IETRS_Inspection_Package__c.getRecordTypeInfosByDeveloperName()
            .get('IETRS_Inspection_Package_Standard_Pipeline_Safety')
            .getRecordTypeId();
        
        
        IETRS_County_Group__c ctryGroup=[select id,Name from IETRS_County_Group__c limit 1];
        existingInspectionSchedule.IETRS_Region__c=ctryGroup.id;
        update existingInspectionSchedule;
        Account parentAcctTypeUpdate=[select id,Type,ParentId from Account where id=:existingInspectionSchedule.IETRS_Regulated_Entity__r.ParentId];
        parentAcctTypeUpdate.Type='Distribution';
        update parentAcctTypeUpdate;
        
        List<Account> childAccs=[select id,name,recordtype.name,IETRS_Counties_List__c,ParentId,IETRS_Representative_Phone__c from Account where ParentId!=null];
        List<Account> parentAccs=[select id,name,recordtype.name,IETRS_Counties_List__c,ParentId,IETRS_Representative__c from Account where id=:childAccs[0].ParentId];
        childAccs[0].IETRS_Counties_List__c='County1';
        childAccs[0].IETRS_OrganizationofRegEntity__c=parentAccs[0].id;
        childAccs[0].IETRS_Jurisdiction__c='Jurisdictional';
        update childAccs[0];
        system.debug('childAccs'+childAccs[0]);
        system.debug('parentAccs'+parentAccs);
        List<Account> parentAccs1=[select id,name,recordtype.name,IETRS_Counties_List__c,ParentId,IETRS_Representative__c from Account where id=:childAccs[1].ParentId];
        system.debug('childAccs'+childAccs[1]);
        system.debug('parentAccs'+parentAccs1);
        parentAccs1[0].recordtypeId=parentAccs[0].recordtypeId;
        parentAccs1[0].IETRS_Jurisdiction__c='Jurisdictional';
        update parentAccs1[0];
        childAccs[1].IETRS_Counties_List__c='County1';
        childAccs[1].IETRS_OrganizationofRegEntity__c=parentAccs1[0].id;
        childAccs[1].IETRS_Jurisdiction__c='Jurisdictional';
        update childAccs[1];
        Contact con1=new Contact();
        con1.FirstName='Test1 FName';
        con1.LastName='Test1 LName';
        con1.Title='Test1 Title';
        con1.AccountID=childAccs[0].id;
        con1.MailingStreet='Test1 Street';
        con1.MailingCity='Test1 City';
        con1.MailingState='Test1 City';
        con1.MailingPostalCode='Test1 PCode';
        con1.MailingCountry='Test1 Country';
        con1.Phone='(832) 886-4420';
        con1.Fax='(832) 930-4455';
        insert con1;
        Contact con2=new Contact();
        con2.FirstName='Test2 FName';
        con2.LastName='Test2 LName';
        con2.Title='Test2 Title';
        con2.AccountID=parentAccs[0].id;
        con2.MailingStreet='Test2 Street';
        con2.MailingCity='Test2 City';
        con2.MailingState='Test2 City';
        con2.MailingPostalCode='Test2 PCode';
        con2.MailingCountry='Test2 Country';
        con2.Phone='(833) 886-4420';
        con2.Fax='(833) 930-4455';
        insert con2;
        parentAccs[0].IETRS_Representative__c=con2.Id;
        update parentAccs[0];
        parentAccs1[0].IETRS_Representative__c=con1.Id;
        update parentAccs1[0];
     
    }

    @isTest
    private static void scheduleReportPdfTest() {
        Test.startTest();
        IETRS_Coutries__c cout = new IETRS_Coutries__c(Name='Testing',
                                                       Country_Names__c='01-Lubbock;02-Midland;03-Kilgore;04-Austin;05-Houston;06-Fort Worth;07-Corpus Christi;08-San Antonio;09-Multi-Regional (RETIRED);10-El Paso (RETIRED)');
        
        insert cout;
        IETRS_InspSchedule__c existingInspectionSchedule = [
            select id,IETRS_Regulated_Entity__r.IETRS_Unit_Type_from_Regulated_Entity__c,
            IETRS_Region__c,
            IETRS_Regulated_Entity__r.IETRS_OrganizationofRegEntity__c,
            IETRS_Scheduled2__c,
            IETRS_Scheduled__c,
            IETRS_Inspection_Year__c,
            IETRS_Priority__c from IETRS_InspSchedule__c LIMIT 1
        ];
        
        PageReference pageRef = Page.IETRS_Custom_Report_PDF;
        Test.setCurrentPage(pageRef);
        
        ApexPages.currentPage().getParameters().put('selectedReport','Summary System Scheduling');
        ApexPages.currentPage().getParameters().put('Mile','Jurisdictional');
        // ApexPages.currentPage().getParameters().put('Mile','Non-jurisdictional');
        
        ApexPages.currentPage().getParameters().put('Year',String.valueOf(Date.today().year()));
        
        For(Account objAcc : [Select Id, IETRS_OrganizationofRegEntity__c, IETRS_Unit_Parent__c,IETRS_Product_Class__c,
                              IETRS_Product_Sub_Class__c,IETRS_Jurisdiction__c,Parent.IETRS_Unit_ID__c,
                              IETRS_Status__c,IETRS_Entity_Code__c,IETRS_Region__r.name FROM Account WHERE IETRS_Unit_Parent__c <> NULL]){
                                  System.debug(objAcc.IETRS_Status__c);
                                  System.debug(objAcc.IETRS_Entity_Code__c);
                                  System.debug(objAcc.IETRS_OrganizationofRegEntity__c);
                                  System.debug(objAcc.IETRS_Unit_Parent__c);
                                  system.debug(objAcc.IETRS_Product_Class__c);
                                  System.debug(objAcc.IETRS_Product_Sub_Class__c);
                                  system.debug(objAcc.IETRS_Jurisdiction__c);
                                  System.debug(objAcc.Parent.IETRS_Unit_ID__c);
                                  System.debug(objAcc.IETRS_Region__r.name);
                              }
        
        IETRS_Custom_Report_PDF  testPDF = new IETRS_Custom_Report_PDF();
        existingInspectionSchedule.IETRS_Priority__c='1';
        existingInspectionSchedule.IETRS_Organization__c = existingInspectionSchedule.IETRS_Regulated_Entity__r.IETRS_OrganizationofRegEntity__c;
        update existingInspectionSchedule;
        IETRS_Custom_Report_PDF  testPDF41 = new IETRS_Custom_Report_PDF();
        
        testPDF41.generateSystemMilesByRegionReportPdf();
        IETRS_County_Group__c countryGroup = new IETRS_County_Group__c();
        countryGroup.Name = '10-Ee';
        insert countryGroup;
        
        Account acc = new Account();
        acc.name = 'testData';
        acc.IETRS_Jurisdiction__c = 'Jurisdictional';
        acc.IETRS_Product_Class__c  = 'Gas';
        acc.IETRS_Product_Sub_Class__c = 'Hydrogen';
        acc.Type='Gathering';
        acc.IETRS_Entity_Sub_Type__c = 'Regulated';//juris -@@
        acc.IETRS_Intra_Interstate__c = 'Interstate';
        acc.IETRS_Total_Miles__c =123;
        Id OrganizationID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Organization').getRecordTypeId();
        
        acc.recordtypeid = 	OrganizationID;
        //acc.IETRS_OrganizationofRegEntity__c = OrganizationID;
        acc.IETRS_Entity_Code__c = 'A-Off Shore - Liquid';
        acc.IETRS_Unit_ID__c = '898';
        insert acc;        
        IETRS_Custom_Report_PDF.Priority_Wrapper de= new IETRS_Custom_Report_PDF.Priority_Wrapper();
        
        IETRS_Custom_Report_PDF.Summary_Sch_Wrapper sd = new IETRS_Custom_Report_PDF.Summary_Sch_Wrapper();
        sd.regionName='re';
        sd.regionRecCount = 0;
        sd.priWrap = de;
        
        //added to improve the coverage
        List<Account> childAccs=[select id,name,recordtype.name,IETRS_Counties_List__c,ParentId,IETRS_Intra_Interstate__c,IETRS_Entity_Sub_Type__c,Type,
                                 IETRS_OrganizationofRegEntity__c,IETRS_Unit_Parent__c,IETRS_Product_Class__c,IETRS_Product_Sub_Class__c,IETRS_Jurisdiction__c,Parent.IETRS_Unit_ID__c,IETRS_Status__c,IETRS_Entity_Code__c,IETRS_Region__r.name ,RecordType.DeveloperName,
                                 IETRS_Representative_Phone__c from Account where ParentId!=null and IETRS_Unit_Parent__c != null and IETRS_OrganizationofRegEntity__c !=null];
        System.debug('#####Added '+childAccs);
        System.debug('#####Added IETRS_Unit_ID__c '+childAccs[0].Parent.IETRS_Unit_ID__c);
        System.debug('#####Added IETRS_Status__c '+childAccs[0].IETRS_Status__c);
        System.debug('#####Added IETRS_Product_Class__c '+childAccs[0].IETRS_Product_Class__c);
        System.debug('#####Added IETRS_Product_Sub_Class__c '+childAccs[0].IETRS_Product_Sub_Class__c);
        System.debug('#####Added IETRS_Entity_Code__c  '+childAccs[0].IETRS_Entity_Code__c );
        System.debug('#####Added IETRS_Region__r.name  '+childAccs[0].IETRS_Region__r.name ); 
        System.debug('#####Added RecordType.DeveloperName  '+childAccs[0].RecordType.DeveloperName );
        System.debug('#####Added IETRS_Intra_Interstate__c  '+childAccs[0].IETRS_Intra_Interstate__c );
        System.debug('#####Added IETRS_Entity_Sub_Type__c  '+childAccs[0].IETRS_Entity_Sub_Type__c );
        childAccs[0].IETRS_Product_Class__c ='Gas';
        childAccs[0].Type ='Gathering';
        childAccs[0].IETRS_Entity_Sub_Type__c ='Regulated';
        childAccs[0].IETRS_Intra_Interstate__c ='Intrastate';
        childAccs[0].IETRS_Product_Sub_Class__c ='LPG';
        childAccs[0].IETRS_Entity_Code__c ='G-Gas Gathering';
        childAccs[0].IETRS_Jurisdiction__c ='Jurisdictional';
        update childAccs[0];
        IETRS_Custom_Report_PDF  testPDF2 = new IETRS_Custom_Report_PDF();
        
        String parentIdOld = childAccs[1].ParentId;
        String regionIdOld = childAccs[1].IETRS_Region__c;
        
        childAccs[1].IETRS_Product_Class__c ='Gas';
        childAccs[1].IETRS_Region__c =childAccs[0].IETRS_Region__c;
        childAccs[1].Type ='Gathering';
        childAccs[1].IETRS_Entity_Sub_Type__c ='Regulated';
        childAccs[1].IETRS_Intra_Interstate__c ='Intrastate';
        childAccs[1].IETRS_Product_Sub_Class__c ='LPG';
        childAccs[1].IETRS_Entity_Code__c ='G-Gas Gathering';
        childAccs[1].IETRS_Jurisdiction__c ='Jurisdictional';
        update childAccs[1];
        IETRS_Custom_Report_PDF  testPDF3 = new IETRS_Custom_Report_PDF();
        
        childAccs[1].IETRS_Entity_Sub_Type__c ='Aboveground';
        update childAccs[1];
        IETRS_Custom_Report_PDF  testPDF4 = new IETRS_Custom_Report_PDF();
        
        childAccs[1].IETRS_Product_Sub_Class__c ='Natural';
        update childAccs[1];
        IETRS_Custom_Report_PDF  testPDF5 = new IETRS_Custom_Report_PDF();
        
        //childAccs[1].parentId =childAccs[0].parentId;
        childAccs[1].IETRS_Entity_Sub_Type__c =childAccs[0].IETRS_Entity_Sub_Type__c;
        update childAccs[1];
        IETRS_Custom_Report_PDF  testPDF6 = new IETRS_Custom_Report_PDF();
        Test.stopTest();
    }
    
    
    
    @isTest
    private static void scheduleReportPdfExistRegionTest() {
        Test.startTest();
        IETRS_InspSchedule__c existingInspectionSchedule = [
            select id,IETRS_Regulated_Entity__r.IETRS_Unit_Type_from_Regulated_Entity__c,
            IETRS_Regulated_Entity__r.recordType.Name,
            IETRS_Regulated_Entity__r.IETRS_OrganizationofRegEntity__c,
            IETRS_Organization__c,
            IETRS_Region__c,
            IETRS_Scheduled2__c,
            IETRS_Scheduled__c,
            IETRS_Inspection_Year__c,
            IETRS_Priority__c from IETRS_InspSchedule__c LIMIT 1
        ];
        
        existingInspectionSchedule.IETRS_Organization__c = existingInspectionSchedule.IETRS_Regulated_Entity__r.IETRS_OrganizationofRegEntity__c;
        update existingInspectionSchedule;
        
        PageReference pageRef = Page.IETRS_Custom_Report_PDF;
        Test.setCurrentPage(pageRef);
        
        ApexPages.currentPage().getParameters().put('selectedReport','Summary System Scheduling');
        ApexPages.currentPage().getParameters().put('Year',String.valueOf(Date.today().year()));
        IETRS_Custom_Report_PDF  testPDF = new IETRS_Custom_Report_PDF();
        IETRS_InspSchedule__c newInspectionsch = existingInspectionSchedule.clone(false, false, false, false);
        
        try {
            insert newInspectionsch;
        } catch (Exception e) {}
        List<IETRS_InspSchedule__c> schedules = new List<IETRS_InspSchedule__c>();
        for (IETRS_InspSchedule__c schedule : [SELECT Id FROM IETRS_InspSchedule__c]) {
            schedule.IETRS_Approved__c = true;
            schedules.add(schedule);
        }
        update schedules;
        
        IETRS_Custom_Report_PDF  testPDF1 = new IETRS_Custom_Report_PDF();
        newInspectionsch.IETRS_Priority__c='1';
        update newInspectionsch;
        IETRS_Custom_Report_PDF  testPDF2 = new IETRS_Custom_Report_PDF();
        newInspectionsch.IETRS_Priority__c='2';
        update newInspectionsch;
        IETRS_Custom_Report_PDF  testPDF3 = new IETRS_Custom_Report_PDF();
        newInspectionsch.IETRS_Priority__c='3';
        update newInspectionsch;
        IETRS_Custom_Report_PDF  testPDF4 = new IETRS_Custom_Report_PDF();
        newInspectionsch.IETRS_Priority__c='1';
        newInspectionsch.IETRS_Selected__c=false;
        update newInspectionsch;
        IETRS_Custom_Report_PDF  testPDF11 = new IETRS_Custom_Report_PDF();
        newInspectionsch.IETRS_Priority__c='2';
        newInspectionsch.IETRS_Selected__c=false;
        update newInspectionsch;
        IETRS_Custom_Report_PDF  testPDF21 = new IETRS_Custom_Report_PDF();
        newInspectionsch.IETRS_Priority__c='3';
        newInspectionsch.IETRS_Selected__c=false;
        update newInspectionsch;
        IETRS_Custom_Report_PDF  testPDF31 = new IETRS_Custom_Report_PDF();
        newInspectionsch.IETRS_Priority__c='1';
        newInspectionsch.IETRS_Selected__c=true;
        update newInspectionsch;
        IETRS_Custom_Report_PDF  testPDF41 = new IETRS_Custom_Report_PDF();
        newInspectionsch.IETRS_Priority__c='2';
        newInspectionsch.IETRS_Selected__c=true;
        update newInspectionsch;
        IETRS_Custom_Report_PDF  testPDF51 = new IETRS_Custom_Report_PDF();
        newInspectionsch.IETRS_Priority__c='3';
        newInspectionsch.IETRS_Selected__c=true;
        update newInspectionsch;
        IETRS_Custom_Report_PDF  testPDF61 = new IETRS_Custom_Report_PDF();
        
        Test.stopTest();
    }
    
    @isTest
    private static void easternCoastPdfTest() {
        Test.startTest();        
        Id accRegEntPSRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Regulated_Entity_PS')
            .getRecordTypeId();
        Account objAcc = [SELECT Id FROM Account WHERE RecordtypeId = :accRegEntPSRecordTypeId LIMIT 1];
        IETRS_County__c objCounty = new IETRS_County__c(Name = 'County1');        
        insert objCounty;
        
        IETRS_Insp_Miles_by_County__c objMilesCounty = new IETRS_Insp_Miles_by_County__c();
        objMilesCounty.IETRS_Regulated_Entity__c = objAcc.Id;
        objMilesCounty.IETRS_Miles__c = 10;
        objMilesCounty.IETRS_County__c = objCounty.Id;
        insert objMilesCounty;
        
        For(IETRS_Insp_Miles_by_County__c objMilesCounty2 : [SELECT IETRS_County_Name__c , IETRS_Regulated_Entity__r.IETRS_Status__c,
                                                             IETRS_Regulated_Entity__r.IETRS_Jurisdiction__c, 
                                                             IETRS_Regulated_Entity__r.IETRS_OrganizationofRegEntity__r.IETRS_Company_ID__c,
                                                             IETRS_Regulated_Entity__r.RecordType.Name FROM IETRS_Insp_Miles_by_County__c]){
                                                                 System.debug(objMilesCounty2.IETRS_County_Name__c);
                                                                 System.debug(objMilesCounty2.IETRS_Regulated_Entity__r.IETRS_Status__c);
                                                                 System.debug(objMilesCounty2.IETRS_Regulated_Entity__r.IETRS_Jurisdiction__c);
                                                                 System.debug(objMilesCounty2.IETRS_Regulated_Entity__r.IETRS_OrganizationofRegEntity__r.IETRS_Company_ID__c);
                                                                 System.debug(objMilesCounty2.IETRS_Regulated_Entity__r.RecordType.Name);
                                                                 
                                                             }
        
        PageReference pageRef = Page.IETRS_Custom_Report_PDF;
        Test.setCurrentPage(pageRef);
        
        ApexPages.currentPage().getParameters().put('selectedReport','Eastern Coastline Addresses');
        ApexPages.currentPage().getParameters().put('addr','None');
        IETRS_Custom_Report_PDF  testPDF = new IETRS_Custom_Report_PDF();
        IETRS_Insp_Miles_by_County__c objMilesCounty2 = new IETRS_Insp_Miles_by_County__c();
        objMilesCounty2.IETRS_Regulated_Entity__c = objAcc.Id;
        objMilesCounty2.IETRS_Miles__c = 20;
        objMilesCounty2.IETRS_County__c = objCounty.Id;
        insert objMilesCounty2;
        testPDF = new IETRS_Custom_Report_PDF();
        Test.stopTest();
    }
    
    @isTest
    private static void performanceQtrPdfTest() {
        Test.startTest();
        
        PageReference pageRef = Page.IETRS_Custom_Report_PDF;
        Test.setCurrentPage(pageRef);
        
        ApexPages.currentPage().getParameters().put('selectedReport','Performance Quarters report');
        ApexPages.currentPage().getParameters().put('Qtr','12-9');
        ApexPages.currentPage().getParameters().put('QtrYr',String.valueOf(Date.today().year()));
        
        
        List<IETRS_Inspection__c> lstInsp = new List<IETRS_Inspection__c>();
        List<IETRS_Inspection_Package__c> ipList = new List<IETRS_Inspection_Package__c>();
        for(IETRS_Inspection__c InsPec: [select id,IETRS_Regulated_Entity_Type__c,IETRS_Inspection_Package__c, IETRS_Regulated_Entity__r.IETRS_OrganizationofRegEntity__c , IETRS_Status_Date__c,IETRS_Inspection_Status__c 
                                         from IETRS_Inspection__c] ){
                                             System.debug(InsPec);
                                             InsPec.IETRS_Inspection_Status__c = 'Approved';
                                             lstInsp.add(InsPec);
                                         }
        
        update lstInsp;
        
        for(IETRS_Inspection__c InsPec: [select id,IETRS_Regulated_Entity_Type__c,IETRS_Status_Date__c,IETRS_Inspection_Status__c 
                                         from IETRS_Inspection__c] ){
                                             System.debug(InsPec);            
                                         }
        IETRS_Custom_Report_PDF  testPDF = new IETRS_Custom_Report_PDF();
        
        Test.stopTest();
    }
    @isTest
    private static void addressReportPdfTest() {
        Test.startTest();
        
        PageReference pageRef = Page.IETRS_Custom_Report_PDF;
        Test.setCurrentPage(pageRef);
        
        ApexPages.currentPage().getParameters().put('selectedReport','Operator Address');
        ApexPages.currentPage().getParameters().put('Ctry','All');
        ApexPages.currentPage().getParameters().put('typ','All');
        //IETRS_Custom_Report_PDF  testPDF = new IETRS_Custom_Report_PDF();
        
        ApexPages.currentPage().getParameters().put('Ctry','Travis');
        ApexPages.currentPage().getParameters().put('typ','All');
        IETRS_Custom_Report_PDF  testPDF2 = new IETRS_Custom_Report_PDF();
        
        ApexPages.currentPage().getParameters().put('Ctry','All');
        ApexPages.currentPage().getParameters().put('typ','Distribution');
        IETRS_Custom_Report_PDF  testPDF3 = new IETRS_Custom_Report_PDF();
        
        ApexPages.currentPage().getParameters().put('Ctry','Travis');
        ApexPages.currentPage().getParameters().put('typ','Distribution');
        IETRS_Custom_Report_PDF  testPDF4 = new IETRS_Custom_Report_PDF();
        
        Test.stopTest();
    }
    @isTest
    private static void systemMilesPdfTest() {
        Test.startTest();
        IETRS_Coutries__c cout = new IETRS_Coutries__c(Name='Testing',
                                                       Country_Names__c='01-Lubbock;02-Midland;03-Kilgore;04-Austin;05-Houston;06-Fort Worth;07-Corpus Christi;08-San Antonio;09-Multi-Regional (RETIRED);10-El Paso (RETIRED)');
        
        insert cout;
        
        PageReference pageRef = Page.IETRS_Custom_Report_PDF;
        Test.setCurrentPage(pageRef);
        
        ApexPages.currentPage().getParameters().put('selectedReport','System Miles by Region');
        ApexPages.currentPage().getParameters().put('Reg','All');
        ApexPages.currentPage().getParameters().put('sTyp','All');
        IETRS_Custom_Report_PDF  testPDF = new IETRS_Custom_Report_PDF();
        
        Test.stopTest();
    }
    @isTest
    private static void unitByRegionPdfTest() {
        Test.startTest();
        IETRS_Coutries__c cout = new IETRS_Coutries__c(Name='Testing',
                                                       Country_Names__c='01-Lubbock;02-Midland;03-Kilgore;04-Austin;05-Houston;06-Fort Worth;07-Corpus Christi;08-San Antonio;09-Multi-Regional (RETIRED);10-El Paso (RETIRED)');
        
        insert cout;
        
        PageReference pageRef = Page.IETRS_Custom_Report_PDF;
        Test.setCurrentPage(pageRef);
        
        ApexPages.currentPage().getParameters().put('selectedReport','Number of Units by Region');
        ApexPages.currentPage().getParameters().put('Unit','Jurisdictional');
        IETRS_Custom_Report_PDF  testPDF = new IETRS_Custom_Report_PDF();
		
		List<Account> childAccs=[select id,name,recordtype.name,IETRS_Counties_List__c,ParentId,IETRS_Intra_Interstate__c,IETRS_Entity_Sub_Type__c,Type,
                                 IETRS_OrganizationofRegEntity__c,IETRS_Unit_Parent__c,IETRS_Product_Class__c,IETRS_Product_Sub_Class__c,IETRS_Jurisdiction__c,Parent.IETRS_Unit_ID__c,IETRS_Status__c,IETRS_Entity_Code__c,IETRS_Region__r.name ,RecordType.DeveloperName,
                                 IETRS_Representative_Phone__c from Account where ParentId!=null and IETRS_Unit_Parent__c != null and IETRS_OrganizationofRegEntity__c !=null];
        System.debug('#####Added '+childAccs);
        System.debug('#####Added IETRS_Unit_ID__c '+childAccs[0].Parent.IETRS_Unit_ID__c);
        System.debug('#####Added IETRS_Status__c '+childAccs[0].IETRS_Status__c);
        System.debug('#####Added IETRS_Product_Class__c '+childAccs[0].IETRS_Product_Class__c);
        System.debug('#####Added IETRS_Product_Sub_Class__c '+childAccs[0].IETRS_Product_Sub_Class__c);
        System.debug('#####Added IETRS_Entity_Code__c  '+childAccs[0].IETRS_Entity_Code__c );
        System.debug('#####Added IETRS_Region__r.name  '+childAccs[0].IETRS_Region__r.name ); 
        System.debug('#####Added RecordType.DeveloperName  '+childAccs[0].RecordType.DeveloperName );
        System.debug('#####Added IETRS_Intra_Interstate__c  '+childAccs[0].IETRS_Intra_Interstate__c );
        System.debug('#####Added IETRS_Entity_Sub_Type__c  '+childAccs[0].IETRS_Entity_Sub_Type__c );
        childAccs[0].IETRS_Product_Class__c ='Gas';
        childAccs[0].Type ='Gathering';
        childAccs[0].IETRS_Entity_Sub_Type__c ='Regulated';
        childAccs[0].IETRS_Intra_Interstate__c ='Intrastate';
        childAccs[0].IETRS_Product_Sub_Class__c ='LPG';
        childAccs[0].IETRS_Entity_Code__c ='G-Gas Gathering';
        childAccs[0].IETRS_Jurisdiction__c ='Jurisdictional';
        update childAccs[0];
        IETRS_Custom_Report_PDF  testPDF2 = new IETRS_Custom_Report_PDF();
        
        String parentIdOld = childAccs[1].ParentId;
        String regionIdOld = childAccs[1].IETRS_Region__c;
        
        childAccs[1].IETRS_Product_Class__c ='Gas';
        childAccs[1].IETRS_Region__c =childAccs[0].IETRS_Region__c;
        childAccs[1].Type ='Gathering';
        childAccs[1].IETRS_Entity_Sub_Type__c ='Regulated';
        childAccs[1].IETRS_Intra_Interstate__c ='Intrastate';
        childAccs[1].IETRS_Product_Sub_Class__c ='LPG';
        childAccs[1].IETRS_Entity_Code__c ='G-Gas Gathering';
        childAccs[1].IETRS_Jurisdiction__c ='Jurisdictional';
        update childAccs[1];
        IETRS_Custom_Report_PDF  testPDF3 = new IETRS_Custom_Report_PDF();
        
        childAccs[1].IETRS_Entity_Sub_Type__c ='Aboveground';
        update childAccs[1];
        IETRS_Custom_Report_PDF  testPDF4 = new IETRS_Custom_Report_PDF();
        
        childAccs[1].IETRS_Product_Sub_Class__c ='Natural';
        update childAccs[1];
        IETRS_Custom_Report_PDF  testPDF5 = new IETRS_Custom_Report_PDF();
        
        //childAccs[1].parentId =childAccs[0].parentId;
        childAccs[1].IETRS_Entity_Sub_Type__c =childAccs[0].IETRS_Entity_Sub_Type__c;
        update childAccs[1];
        IETRS_Custom_Report_PDF  testPDF6 = new IETRS_Custom_Report_PDF();
        
        Test.stopTest();
    }
    
    @isTest
    private static void scheduleReportPdfExistRegionTest2() {
        Test.startTest();
        PageReference pageRef = Page.IETRS_Custom_Report_PDF;
        Test.setCurrentPage(pageRef);        
        ApexPages.currentPage().getParameters().put('selectedReport','Summary System Scheduling');
        ApexPages.currentPage().getParameters().put('Year',String.valueOf(Date.today().year()));
        
        List<IETRS_InspSchedule__c> schedules = new List<IETRS_InspSchedule__c>();
        IETRS_InspSchedule__c newInspectionsch = new IETRS_InspSchedule__c();
        for (IETRS_InspSchedule__c schedule : [SELECT Id,IETRS_Inspection_Year__c, IETRS_Organization__c, IETRS_Regulated_Entity__r.IETRS_OrganizationofRegEntity__c ,IETRS_Regulated_Entity__r.IETRS_Unit_Type_from_Regulated_Entity__c,
                                               IETRS_Organization_ID__c, IETRS_Approved__c FROM IETRS_InspSchedule__c]) {
                                                   schedule.IETRS_Approved__c = true;
                                                   schedule.IETRS_Organization__c = schedule.IETRS_Regulated_Entity__r.IETRS_OrganizationofRegEntity__c;
                                                   schedules.add(schedule);
                                                   system.debug(schedule.IETRS_Inspection_Year__c);
                                                   system.debug(schedule.IETRS_Regulated_Entity__r.IETRS_Unit_Type_from_Regulated_Entity__c);
                                                   system.debug(schedule.IETRS_Organization_ID__c);
                                                   system.debug(schedule.IETRS_Approved__c);
                                                   newInspectionsch = schedule;
                                                   
                                               }
        update schedules;
        
        IETRS_Custom_Report_PDF  testPDF1 = new IETRS_Custom_Report_PDF();
        newInspectionsch.IETRS_Priority__c='1';
        update newInspectionsch;
        IETRS_Custom_Report_PDF  testPDF2 = new IETRS_Custom_Report_PDF();
        newInspectionsch.IETRS_Priority__c='2';
        update newInspectionsch;
        IETRS_Custom_Report_PDF  testPDF3 = new IETRS_Custom_Report_PDF();
        newInspectionsch.IETRS_Priority__c='3';
        update newInspectionsch;
        IETRS_Custom_Report_PDF  testPDF4 = new IETRS_Custom_Report_PDF();
        newInspectionsch.IETRS_Priority__c='1';
        newInspectionsch.IETRS_Selected__c=false;
        update newInspectionsch;
        IETRS_Custom_Report_PDF  testPDF11 = new IETRS_Custom_Report_PDF();
        newInspectionsch.IETRS_Priority__c='2';
        newInspectionsch.IETRS_Selected__c=false;
        update newInspectionsch;
        IETRS_Custom_Report_PDF  testPDF21 = new IETRS_Custom_Report_PDF();
        newInspectionsch.IETRS_Priority__c='3';
        newInspectionsch.IETRS_Selected__c=false;
        update newInspectionsch;
        IETRS_Custom_Report_PDF  testPDF31 = new IETRS_Custom_Report_PDF();
        newInspectionsch.IETRS_Priority__c='1';
        newInspectionsch.IETRS_Selected__c=true;
        update newInspectionsch;
        IETRS_Custom_Report_PDF  testPDF41 = new IETRS_Custom_Report_PDF();
        newInspectionsch.IETRS_Priority__c='2';
        newInspectionsch.IETRS_Selected__c=true;
        update newInspectionsch;
        IETRS_Custom_Report_PDF  testPDF51 = new IETRS_Custom_Report_PDF();
        newInspectionsch.IETRS_Priority__c='3';
        newInspectionsch.IETRS_Selected__c=true;
        update newInspectionsch;
        IETRS_Custom_Report_PDF  testPDF61 = new IETRS_Custom_Report_PDF();
    }
    @IsTest
    public static void wrapperConstructors(){
        
        Test.startTest();
        IETRS_Custom_Report_PDF.Inspection_PKG_Classification_Wrapper ipcw = new IETRS_Custom_Report_PDF.Inspection_PKG_Classification_Wrapper();
        ipcw.Activity = 'test';
        ipcw.Classification = 'test';
        ipcw.Inspections_performed = 1;
        ipcw.Miles_Evaluated = 1;
        ipcw.TotalViolations = 1;
        
        IETRS_Custom_Report_PDF.Inspection_PKG_Type_Wrapper iptw = new IETRS_Custom_Report_PDF.Inspection_PKG_Type_Wrapper();
        iptw.AverageViolations = 1;
        iptw.Inspections_performed = 1;
        iptw.Miles_Evaluated = 1;
        iptw.SystemType = 'test';
        iptw.TotalViolations = 1;
        IETRS_Custom_Report_PDF.Inspection_PKG_Total_Wrapper iptotw = new IETRS_Custom_Report_PDF.Inspection_PKG_Total_Wrapper();
        iptotw.Inspections_performed_total = 1;
        iptotw.Miles_Evaluated_total = 1;
        iptotw.TotalViolations_total = 1;
        Test.stopTest();
    }
    
}