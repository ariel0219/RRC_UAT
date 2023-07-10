/**
* @author Greg Lovelidge - Sense Corp
* @date 6/1/2020
*
* @description Tests for the late fees functionality
*/
@isTest
private class IETRS_InspScheduleGenerateControllerTest {
    @TestSetup
    static void makeData() {
        // Create test data
        final String BUSINESS_AREA = 'Critical Infrastructure';
        IETRS_I_TestUtils testUtils = new IETRS_I_TestUtils();
        testUtils.entityFieldValuesByField.put(
            Account.IETRS_Product_Class__c,
            new List<String>{ 'Gas', 'Gas', 'Gas', 'Liquid', '' }
        );
        testUtils.entityFieldValuesByField.put(
            Account.Type,
            new List<String>{
                'Transmission',
                    'Distribution',
                    'Master Meter',
                    'Transmission',
                    ''
                    }
        );
        testUtils.entityFieldValuesByField.put(
            Account.IETRS_Entity_Sub_Type__c,
            new List<String>{
                'Transmission',
                    'Private Main System',
                    'Apartment',
                    'Transmission',
                    ''
                    }
        );
        testUtils.entityFieldValuesByField.put(
            Account.IETRS_Product_Sub_Class__c,
            new List<String>{ 'Natural', 'Natural', 'Natural', 'Crude', '' }
        );
        testUtils.entityFieldValuesByField.put(
            Account.IETRS_Business_Area__c,
            new List<String>{ BUSINESS_AREA }
        );
        testUtils.entityFieldValuesByField.put(
            Account.IETRS_Entity_Code__c,
            new List<String>{
                '',
                    '',
                    '',
                    '',
                    'Y-Company System (Non-Physical)'
                    }
        );
        testUtils.entityFieldValuesByField.put(
            Account.IETRS_Status__c,
            new List<String>{
                'Active',
                    'Active',
                    IETRS_SpecializedInspScheduleServices.CONSTRUCTION,
                    'Active',
                    'Active'
                    }
        );
        
        testUtils.createData(2, 5);
        testUtils.creatScheduleConfigData();
        
        
    }
    
    @isTest
    private static void itShouldGenerateSpecializedSchedules() {
        IETRS_I_TestUtils testUtils = new IETRS_I_TestUtils();
        List<Account> testEntityAccs = [
            SELECT
            Name,
            RecordTypeId,
            IETRS_OrganizationofRegEntity__c,
            IETRS_Unit_Parent__c,
            IETRS_Allowed_Inspection_Record_Type__c,
            ParentId,
            IETRS_Product_Class__c,
            IETRS_Jurisdiction__c,
            IETRS_Intra_Interstate__c,
            Type
            FROM Account
            WHERE
            RecordTypeId = :testUtils.accRegEntPSRecordTypeId
            AND IETRS_Business_Area__c = 'Pipeline Safety'
            AND IETRS_Jurisdiction__c NOT IN :IETRS_SpecializedInspScheduleServices.EXCLUDED_JURISDICTION_TYPES
            AND IETRS_Status__c NOT IN :IETRS_SpecializedInspScheduleServices.EXCLUDED_STATUSES
            AND ((IETRS_Product_Class__c = 'Gas'
                  AND Type = 'Transmission')
                 OR (IETRS_Product_Class__c = 'Gas'
                     AND Type = 'Distribution')
                 OR IETRS_Product_Class__c = 'Liquid')
        ];
        
        system.debug('testEntityAccs ' + testEntityAccs);
        testUtils.createSpecializedInspections(testEntityAccs);
        IETRS_InspSchedConfig__c configRecord = [
            SELECT Id, IETRS_Schedule_Type__c
            FROM IETRS_InspSchedConfig__c
            WHERE
            RecordType.DeveloperName = 'Schedule_Generation'
            AND IETRS_Schedule_Type__c = 'Pipeline Specialized Schedule'
            LIMIT 1
        ];
        Test.StartTest();
        IETRS_InspScheduleGenerateController.generateSchedules(configRecord.Id);
        Test.StopTest();
    }
    
    @isTest
    private static void itShouldGenerateRoutineSchedules() {
        IETRS_InspSchedConfig__c configRecord = [
            SELECT Id, IETRS_Schedule_Type__c
            FROM IETRS_InspSchedConfig__c
            WHERE
            RecordType.DeveloperName = 'Schedule_Generation'
            AND IETRS_Schedule_Type__c = 'Pipeline Routine Schedule'
            LIMIT 1
        ];
        Test.StartTest();
        IETRS_InspScheduleGenerateController.generateSchedules(configRecord.Id);
        IETRS_InspScheduleGenerateController.isGenerated(configRecord.Id);
       
        
        List<IETRS_InspSchedConfig__c> configList = new List<IETRS_InspSchedConfig__c>();
        IETRS_InspSchedConfig__c config = new IETRS_InspSchedConfig__c(); 
        config.IETRS_Priority__c ='1';
        config.IETRS_Business_Area__c ='Critical Infrastructure';
        config.IETRS_Priority_Code__c ='Storage';
        configList.add(config);
        IETRS_InspSchedConfig__c config1 = new IETRS_InspSchedConfig__c();
        config1.IETRS_Priority__c ='1';
        config1.IETRS_Business_Area__c ='Critical Infrastructure';
        config1.IETRS_Priority_Code__c ='Gas Processing Plants';
        configList.add(config1);
        IETRS_InspSchedConfig__c config2 = new IETRS_InspSchedConfig__c();
        config2.IETRS_Priority__c ='1';
        config2.IETRS_Business_Area__c ='Critical Infrastructure';
        config2.IETRS_Priority_Code__c ='Direct Compressor';
        configList.add(config2);
        IETRS_InspSchedConfig__c config3 = new IETRS_InspSchedConfig__c();
        config3.IETRS_Priority__c ='2';
        config3.IETRS_Business_Area__c ='Critical Infrastructure';
        config3.IETRS_Priority_Code__c ='Indirect Transmission';
        configList.add(config3);
        IETRS_InspSchedConfig__c config4 = new IETRS_InspSchedConfig__c();
        config4.IETRS_Priority__c ='1';
        config4.IETRS_Business_Area__c ='Critical Infrastructure';
        config4.IETRS_Priority_Code__c ='Direct Transmission';
        configList.add(config4);
        IETRS_InspSchedConfig__c config5 = new IETRS_InspSchedConfig__c();
        config5.IETRS_Priority__c ='2';
        config5.IETRS_Business_Area__c ='Critical Infrastructure';
        config5.IETRS_Priority_Code__c ='Indirect Transmission';
        configList.add(config5);
        IETRS_InspSchedConfig__c config6 = new IETRS_InspSchedConfig__c();
        config6.IETRS_Priority__c ='1';
        config6.IETRS_Condition_Operator__c = 'Greater Than';
        config6.IETRS_Business_Area__c ='Critical Infrastructure';
        config6.IETRS_Priority_Code__c ='Lease > 5000 mcf/day';
        config6.IETRS_Value_One__c = 5000;
        configList.add(config6);
        
        
        IETRS_InspSchedConfig__c config7 = new IETRS_InspSchedConfig__c();
        config7.IETRS_Priority__c ='2';
        config7.IETRS_Business_Area__c ='Critical Infrastructure';
        config7.IETRS_Condition_Operator__c = 'Between';
        config7.IETRS_Priority_Code__c ='Lease > 1000 mcf/day';
        config7.IETRS_Value_One__c = 1000;
        config7.IETRS_Value_Two__c = 5000;
        configList.add(config7);
        
        IETRS_InspSchedConfig__c config8 = new IETRS_InspSchedConfig__c();
        config8.IETRS_Priority__c ='2';
        config8.IETRS_Business_Area__c ='Critical Infrastructure';
        config8.IETRS_Priority_Code__c ='UIC Commercial';
        configList.add(config8);
        
        IETRS_InspSchedConfig__c config9 = new IETRS_InspSchedConfig__c();
        config9.IETRS_Priority__c ='3';
        config9.IETRS_Business_Area__c ='Critical Infrastructure';
        config9.IETRS_Priority_Code__c ='UIC Commercial';
        configList.add(config9);
        
        IETRS_InspSchedConfig__c config10 = new IETRS_InspSchedConfig__c();
        config10.IETRS_Priority__c ='3';
        config10.IETRS_Business_Area__c ='Critical Infrastructure';
        config10.IETRS_Priority_Code__c ='Non-Priority';
        config10.IETRS_Value_One__c = 5000;
        configList.add(config10);
        
		IETRS_InspSchedConfig__c config11 = new IETRS_InspSchedConfig__c();
        config11.IETRS_Priority__c ='2';
        config11.IETRS_Business_Area__c ='Critical Infrastructure';
        config11.IETRS_Priority_Code__c ='Indirect Compressor';
        configList.add(config11);
        
        insert configList;
        
        Account regEntity = new Account();
        regEntity.Name = 'Test Org';
        regEntity.CIIS_Direct_Serve__c = false;
        regEntity.CIIS_Reg_Entity_MCF_day__c = 1500;
        regEntity.Type = 'UIC Permit';
        regEntity.CIIS_Meets_CID__c = true;
        regEntity.CIIS_Commercial_Disposal__c = true;
        
        Account regEntity4 = new Account();
        regEntity4.Name = 'Test Org';
        regEntity4.CIIS_Direct_Serve__c = false;
        regEntity4.CIIS_Reg_Entity_MCF_day__c = 1500;
        regEntity4.Type = 'UIC Permit';
        regEntity4.CIIS_Meets_CID__c = true;
        regEntity4.CIIS_Commercial_Disposal__c = false;
        
        Account regEntity2 = new Account();
        regEntity2.Name = 'Test Org 2';
        regEntity2.CIIS_Direct_Serve__c = false;
        regEntity2.CIIS_Reg_Entity_MCF_day__c = 1500;
        regEntity2.Type = 'Compressor Station';
        regEntity2.CIIS_Meets_CID__c = true;
        regEntity2.CIIS_Commercial_Disposal__c = true;
        
        Account regEntity5 = new Account();
        regEntity5.Name = 'Test Org 2';
        regEntity5.CIIS_Direct_Serve__c = true;
        regEntity5.CIIS_Reg_Entity_MCF_day__c = 1500;
        regEntity5.Type = 'Compressor Station';
        regEntity5.CIIS_Meets_CID__c = true;
        regEntity5.CIIS_Commercial_Disposal__c = true;
        
        Account regEntity3 = new Account();
        regEntity3.Name = 'Test Org 2';
        regEntity3.CIIS_Direct_Serve__c = true;
        regEntity3.CIIS_Reg_Entity_MCF_day__c = 1500;
        regEntity3.Type = 'Lease';
        regEntity3.CIIS_Meets_CID__c = true;
        regEntity3.CIIS_Commercial_Disposal__c = true;
        
        Account regEntity6 = new Account();
        regEntity6.Name = 'Test Org 2';
        regEntity6.CIIS_Direct_Serve__c = true;
        regEntity6.CIIS_Reg_Entity_MCF_day__c = 1500;
        regEntity6.Type = 'Transmission';
        regEntity6.CIIS_Meets_CID__c = true;
        regEntity6.CIIS_Commercial_Disposal__c = true;
        
        Account regEntity7 = new Account();
        regEntity7.Type = 'Gas Processing Facility';
        
        for(IETRS_InspSchedConfig__c con: configList){
            CIIS_InspScheduleServices.RiskFactorRequest rfr = new CIIS_InspScheduleServices.RiskFactorRequest();
            rfr.risk=con;
            if(con.IETRS_Priority_Code__c == 'Indirect Compressor')
            	rfr.regEntity=regEntity2;
            else if(con.IETRS_Priority_Code__c.contains('Lease'))
                rfr.regEntity=regEntity3;
            else if(con.IETRS_Priority__c == '3' && con.IETRS_Priority_Code__c == 'UIC Commercial')
                rfr.regEntity=regEntity4;
            else if(con.IETRS_Priority_Code__c == 'Direct Compressor')
                rfr.regEntity = regEntity5;
            else if(con.IETRS_Priority_Code__c == 'Direct Transmission')
                rfr.regEntity = regEntity6;
            else if(con.IETRS_Priority_Code__c == 'Gas Processing Plants')
                rfr.regEntity = regEntity7;
            else if(con.IETRS_Priority_Code__c == 'Non-Priority')
                rfr.regEntity = regEntity4;
            else
                rfr.regEntity=regEntity;
            CIIS_InspScheduleServices.checkRiskFactor(rFR);
        }
        
        //CIIS_InspScheduleServices.RiskFactorRequest rfr1 = new CIIS_InspScheduleServices.RiskFactorRequest();
        // rfr.risk=configList[1];
        // rfr.regEntity=regEntity;
        
        //CIIS_InspScheduleServices.checkRiskFactor(rFR);
       
        Test.StopTest();
    }
    
    @isTest
    private static void itShouldGenerateRoutineSchedulesCIIS() {
        final Map<String, String> riskCodeByCode = new Map<String, String>{
            'A' => 'Gas Processing Plants',
                'B' => 'Storage',
                'C' => 'Direct Compressor',
                'D' => 'Direct Transmission',
                'E' => 'Lease > 5000 mcf/day',
                'F' => 'Indirect Compressor',
                'G' => 'Indirect Transmission',
                'I' => 'Lease > 1000 mcf/day',
                'L' => 'UIC Commercial',
                'M' => 'Non-Priority'
                };
                    IETRS_InspSchedConfig__c configRecord = [
                        SELECT Id, IETRS_Schedule_Type__c,IETRS_Business_Area__c,
                        IETRS_Regulated_Entity_Type__c,
                        IETRS_Priority_Code__c,
                        IETRS_Condition_Operator__c,
                        IETRS_Value_One__c,
                        IETRS_Value_Two__c,
                        IETRS_Priority__c
                        FROM IETRS_InspSchedConfig__c
                        WHERE
                        RecordType.DeveloperName = 'Schedule_Generation'
                        AND IETRS_Schedule_Type__c = 'Pipeline Routine Schedule'
                        LIMIT 1
                    ];
        configRecord.IETRS_Business_Area__c = 'Critical Infrastructure';
        Update configRecord;
        Test.StartTest();
        IETRS_InspScheduleGenerateController.generateSchedules(configRecord.Id);
         
        IETRS_InspScheduleGenerateController.isGenerated(configRecord.Id);
        
         IETRS_InspScheduleGenerateController.isGenerated(null);
        IETRS_InspScheduleGenerateController.generateSchedules(null);
        Test.StopTest();
    }
}