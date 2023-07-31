/**
 * @File Name          : IETRS_InspScheduleServices.cls
 * @Description        : Generates Inspection schedules (workplan)
 * @Author             : Mark Frizzell
 * @Group              : IETRS Inspection
 * @Last Modified By   : Sebastian Wittenstein
 * @Last Modified On   : 06/06/2022
 * @Modification Log   :
 *==============================================================================
 * Ver      Date            Author                  Modification
 *==============================================================================
 * 1.0      07/10/2019      Mark Frizzell           Initial Version
 * 1.1      08/24/2019      Mark Frizzell           Convert to batch process
 * 1.2      01/10/2022      Krissy Rachner          Incorporated frequency in O risk
 * 1.3      06/06/2022      Sebastian Wittenstein   Altered functionaility to handle included  child inspection records to support finding 
 * most recent matching type/subtype, and therefore return the correct risk factor assignments. There is an exception for the E risk factor 
 * which depends on the most recent inspection on the RE.
 * 1.4      02/09/2023      Sebastian Wittenstein   Added CIIS specific schedule generation functionality in the form of if statement before 
 * checkRiskFactor call.
 **/

public with sharing class IETRS_InspScheduleServices {
    public static final String INSP_TYPE = 'Standard';
    public static final String INSP_SUB_TYPE = 'Comprehensive';
    public static final String STATUS_GENERATED = 'Generated';
    public static final String STATUS_IN_PROG = 'In Progress';

    private static final String OP_GREATER_THAN = 'Greater Than';
    private static final String OP_LESS_THAN = 'Less Than';
    private static final String OP_BETWEEN = 'Between';
    private static final String CIISBA = 'Critical Infrastructure'; //CIISBA => Critical Infrastructure Business Area

    public static final String RECTYPE_RISK_FACTOR = 'Risk_Factors_Setting';
    public static final List<String> RECTYPES_REG_ENTITY = new List<String>{
        'Regulated_Entity_AFS',
        'Regulated_Entity_OG',
        'Regulated_Entity_PS',
        'Regulated_Entity_SMRD'
    };

    //map for the IETRS_InspSchedule__c record type Ids to create the correct kind of record type for the new records 
    public static final Map<String, Id> INSP_SCHEDULE_RECTYPE_MAP = new Map<String, Id>{
        'Critical Infrastructure' => Schema.SObjectType.IETRS_InspSchedule__c.getRecordTypeInfosByName()
        .get('Critical Infrastructure').getRecordTypeId(),
        'Pipeline Safety' => Schema.SObjectType.IETRS_InspSchedule__c.getRecordTypeInfosByName()
        .get('Pipeline Safety').getRecordTypeId()
    };

    public static final String RE_TYPE_MM = 'PS Inspection - Master Meter Systems';
    public static final String RE_TYPE_DIST = 'PS Inspection - Distribution Systems';
    public static final String RE_TYPE_GAS = 'PS Inspection - Gas Transmission Systems';
    public static final String RE_TYPE_HAZ = 'PS Inspection - Hazardous Liquid Systems';
    public static final String RE_TYPE_LNG = 'PS Inspection - LNG Systems';
    public static final String RE_TYPE_UNGS = 'PS Inspection - UNGS Systems';
    public static final String RE_TYPE_CI_GPF = 'Gas Processing Facility';
    public static final String RE_TYPE_CI_S = 'Storage';
    public static final String RE_TYPE_CI_L = 'Lease';
    public static final String RE_TYPE_CI_CS = 'Compressor Station';
    public static final String RE_TYPE_CI_T = 'Transmission';
    public static final String RE_TYPE_CI_G = 'Gathering';
    public static final String RE_TYPE_CI_UICP = 'UIC Permit';
    public static final String RE_TYPE_CI_W = 'Well';
    public static final String RE_TYPE_CI_PF = 'Permitted Field';
   
    public static final String RE_TYPE_CI_CC = 'Control Center';
    public static final String RE_TYPE_CI_MS = 'Meter Station';
    public static final String RE_TYPE_CI_RS = 'Regulator Station';
    public static final String RE_TYPE_CI_NGLS = 'Natural Gas Liquid Storage';
    
    
    public static final Map<String, String> RECTYPE_BUSAREA_MAP = new Map<String, String>{
        // Map of account record types to business areas
        'Regulated_Entity_AFS' => 'Alternative Fuels',
        'Regulated_Entity_OG' => 'Oil and Gas',
        'Regulated_Entity_PS' => 'Pipeline Safety',
        'Regulated_Entity_SMRD' => 'Surface Mining'
    };
    
    public static final Map<String, String> RE_TYPE_MAP = new Map<String, String>{
        // Map of inspection config IETRS_Insp_Regulated_Entity_Type__c
        // to RE account IETRS_I_Allowed_Inspection_Record_Type__c
        'Master Meter' => RE_TYPE_MM,
        'Distribution' => RE_TYPE_DIST,
        'Gas Transmission' => RE_TYPE_GAS,
        'Hazardous Liquid' => RE_TYPE_HAZ,
        'Liquified Natural Gas' => RE_TYPE_LNG,
        'Underground Natural Gas Storage' => RE_TYPE_UNGS,
        'Gas Processing Plants' => RE_TYPE_CI_GPF,
        'Gas Processing Facility' => RE_TYPE_CI_GPF,
        'Storage' => RE_TYPE_CI_S,
        'Lease' => RE_TYPE_CI_L,
        'Compressor Station' => RE_TYPE_CI_CS,
        'Transmission' => RE_TYPE_CI_T,
        'Gathering' => RE_TYPE_CI_G,
        'UIC Permit' => RE_TYPE_CI_UICP,
        'Well' => RE_TYPE_CI_W,
        'Permitted Field' => RE_TYPE_CI_PF,
   
        'Control Center' => RE_TYPE_CI_CC,
        'Meter Station' => RE_TYPE_CI_MS,
        'Regulator Station' => RE_TYPE_CI_RS,
        'Natural Gas Liquid Storage' => RE_TYPE_CI_NGLS
        
    };

    public static final Set<String> EXCLUDED_JURISDICTION_TYPES = new Set<String>{
        'TAC Regulated Gathering',
        'Non-jurisdictional'
    };
    public static final Set<String> EXCLUDED_STATUSES = new Set<String>{
        'Abandoned'
    };
    public static final Set<String> EXCLUDED_ORG_IDS = new Set<String>{
        '1582'
    };
    final static Set<String> COMPLETE_STATUSES = new Set<String>{
        'Complete',
        'Closed',
        'Approved'
    };

    /**
     * @description - Checks risk factors for this RE and creates the appropriate schedule record
     * @author Mark Frizzell | 8/24/2019
     * @param Account re - Regulated Entity account record
     * @param IETRS_Insp_InspSchedConfig__c config - Schedule generation record
     * @param Map<String, List<IETRS_Insp_InspSchedConfig__c>> riskFactors - Map of risk factors to check
     * @param Map<Id, IETRS_Inspection__c> inspMap - Related inspection records for the RE
     * @return IETRS_Insp_InspSchedule__c - Resulting schedule record for this RE
     **/
    public static IETRS_InspSchedule__c buildRegEntSchedule(
        IETRS_InspSchedConfig__c config,
        Account regEntity,
        IETRS_Inspection__c inspection,
        IETRS_InspSchedule__c schedule,
        Map<String, List<IETRS_InspSchedConfig__c>> riskFactors,
        Boolean hasCarryoverSchedule
    ) {
        inspection = inspection != null
            ? inspection
            : new IETRS_Inspection__c();
        schedule = schedule != null ? schedule : new IETRS_InspSchedule__c();
        schedule.IETRS_Risk_Factors__c = '';

        System.debug('config: ' + config.Name);
        System.debug('acct: ' + regEntity.Name);
        System.debug('insp: ' + inspection.Name);
        System.debug('sched: ' + schedule.Name);

        // Find the record type to business area conversion for this R.E.
        for (String recType : RECTYPE_BUSAREA_MAP.keySet()) {
            System.debug('recType xzxz: '  + recType);
            System.debug('regEntity.RecordType.DeveloperName xzxz: ' + regEntity.RecordType.DeveloperName);
            if (
                regEntity.RecordType.DeveloperName == recType ||
                config.IETRS_Business_Area__c == CIISBA 
            ) {
                String businessArea;
                System.debug('businessArea xzxz: ' + businessArea);
                if (
                    regEntity.RecordType.DeveloperName == recType
                ) {
                    businessArea = RECTYPE_BUSAREA_MAP.get(recType);
                } else if (
                    config.IETRS_Business_Area__c == CIISBA
                ) {
                    businessArea = CIISBA;
                }

                System.debug('final businessArea xzxz: ' + businessArea);

                System.debug('recType: ' + recType);
                System.debug('businessArea: ' + businessArea);

                // Loop through all risk factors (if any) for this business area
                if (riskFactors.get(businessArea) != null) {
                    System.debug(
                        'risk factors found xzxz: ' + 
                        riskFactors.get(businessArea).size()
                        );
                    for (
                        IETRS_InspSchedConfig__c risk : riskFactors.get(
                            businessArea
                            )
                        ) {
                            System.debug(                                
                                'risk Reg Entity Type: ' + RE_TYPE_MAP.get(
                                risk.IETRS_Regulated_Entity_Type__c
                                )
                            );
                            System.debug(                                
                                'risk: ' + risk
                            );
                            System.debug(                                
                                'reg Entity Allowed Inspection Type:' + regEntity.IETRS_Allowed_Inspection_Record_Type__c
                            );
                            
                            if (RE_TYPE_MAP.get(risk.IETRS_Regulated_Entity_Type__c) != NULL){
                            if (
                            regEntity.IETRS_Allowed_Inspection_Record_Type__c.contains(
                                RE_TYPE_MAP.get(
                                    risk.IETRS_Regulated_Entity_Type__c
                                )
                            )
                        ) {
                            Boolean riskResult = false;
                            // Decimal frequencyYears = frequency.get(
                            //     risk.IETRS_Regulated_Entity_Type__c
                            // );

                            // Check this risk factor
                            switch on config.IETRS_Business_Area__c {
                                when 'Critical Infrastructure' {
                                    System.debug('Risk Factors 44070219- Critical Infrastructure');
                                    CIIS_InspScheduleServices.RiskFactorRequest rfr = new CIIS_InspScheduleServices.RiskFactorRequest();
                                    rfr.risk=risk;
                                    System.debug('rfr.risk pass in value: ' + rfr.risk);
                                    rfr.regEntity=regEntity;
                                    riskResult = CIIS_InspScheduleServices.checkRiskFactor(rfr);
                                }
                                when 'Pipeline Safety' {
                                    System.debug('Risk Factors 44070219 - Pipeline Safety');
                                    riskResult = checkRiskFactor(
                                        risk, 
                                        regEntity, 
                                        inspection, 
                                        hasCarryoverSchedule,
                                        Integer.valueOf(config.IETRS_Year__c)
                                        );
                               }
                            }
                            System.debug('riskResult 44070219: ' + riskResult);
                            
                            // If R.E. matches risk criteria, add a schedule record, or update the
                            // priority and risk factors of the existing schedule
                            if (riskResult == true) { System.debug('riskResult[44070219] in if: ' + riskResult);
                                if (
                                    schedule.IETRS_Regulated_Entity__c == null
                                ) { System.debug('schedule.IETRS_Regulated_Entity__c[44070219] is null in if');
                                    schedule = new IETRS_InspSchedule__c(
                                        IETRS_Regulated_Entity__c = regEntity.Id,
                                        IETRS_Organization__c = regEntity.IETRS_OrganizationofRegEntity__c,
                                        IETRS_Inspection_Business_Area__c = risk.IETRS_Business_Area__c,
                                        IETRS_Inspection_Sub_Type__c = INSP_SUB_TYPE,
                                        RecordTypeId = INSP_SCHEDULE_RECTYPE_MAP.get(config.IETRS_Business_Area__c),
                                        //IETRS_Last_Inspection_Date__c = regEntity.Latest_Inspection_Date__c,
                                        IETRS_Last_Inspection__c = inspection.Id != 
                                            null
                                            ? inspection.Id
                                            : null,
                                        IETRS_Last_Inspection_Date__c = inspection.IETRS_Inspection_Package__r.IETRS_Begin_Date__c != 
                                            null 
                                            ? inspection.IETRS_Inspection_Package__r.IETRS_Begin_Date__c 
                                            : null,
                                        IETRS_Last_Inspection_Status__c = inspection.IETRS_Inspection_Status__c != 
                                            null
                                            ? inspection.IETRS_Inspection_Status__c
                                            : '',
                                        IETRS_Inspection_Year__c = config.IETRS_Year__c,
                                        IETRS_Inspection_Schedule_Config__c = config.Id,
                                        IETRS_County__c = regEntity.IETRS_County__c,
                                        IETRS_Region__c = regEntity.IETRS_Region__c,
                                        IETRS_Type__c = config.IETRS_Schedule_Type__c != 
                                            null
                                            ? config.IETRS_Schedule_Type__c
                                            : '',
                                        IETRS_Inspection_Schedule_Reason__c = config.IETRS_Schedule_Type__c != 
                                            null
                                            ? config.IETRS_Schedule_Type__c
                                            : ''
                                    );
                                }

                                // Add risk factors
                                if (
                                    schedule.IETRS_Risk_Factors__c == null
                                ) {
                                    schedule.IETRS_Risk_Factors__c = risk.IETRS_Priority_Code__c.left(
                                        1
                                    );
                                } else {
                                    schedule.IETRS_Risk_Factors__c += risk.IETRS_Priority_Code__c.left(
                                        1
                                    );
                                }

                                // Update priority if necessary
                                System.debug(
                                    'current priority: ' + 
                                    schedule.IETRS_Priority__c
                                );
                                System.debug(
                                    'risk priority: ' + risk.IETRS_Priority__c
                                );
                                if (schedule.IETRS_Priority__c == null) {
                                    schedule.IETRS_Priority__c = risk.IETRS_Priority__c;
                                } else {
                                    schedule.IETRS_Priority__c = risk.IETRS_Priority__c <
                                        schedule.IETRS_Priority__c
                                        ? risk.IETRS_Priority__c
                                        : schedule.IETRS_Priority__c;
                                }
                            }
                            else{
                                system.debug('Faulted Reg Entity ' + regEntity);
                                system.debug('Risk Factor ' + riskResult);
                            }
                        }
                            }
                    }
                }
            }
        }
        System.debug('result:' + schedule);
        return schedule;
    }

    public static List<Account> getExcludedOrgs() {
        List<Account> result;
        try {
            result = [
                SELECT Id
                FROM Account
                WHERE IETRS_Company_Id__c IN :EXCLUDED_ORG_IDS
            ];
        } catch (Exception e) {
            result = new List<Account>();
        }
        System.debug('xz IETRS_InspScheduleServices.getExcludedOrgs executed, with List of <Account> size of: ' + result.size());
        return result;
    }

    /**
     * @description Maps configured risk factors for each business area (Master Meter, Transmission, etc.)
     * @author Mark Frizzell | 7/16/2019
     * @return Map<String, List<IETRS_Insp_InspSchedConfig__c>> - Map of business areas to risk factors
     */
    public static Map<String, List<IETRS_InspSchedConfig__c>> buildRiskMap() {
        Map<String, List<IETRS_InspSchedConfig__c>> riskFactors = new Map<String, List<IETRS_InspSchedConfig__c>>();

        for (IETRS_InspSchedConfig__c config : [
            SELECT
                Id,
                IETRS_Business_Area__c,
                IETRS_Regulated_Entity_Type__c,
                IETRS_Priority_Code__c,
                IETRS_Condition_Operator__c,
                IETRS_Value_One__c,
                IETRS_Value_Two__c,
                IETRS_Priority__c
            FROM IETRS_InspSchedConfig__c
            WHERE RecordType.DeveloperName = :RECTYPE_RISK_FACTOR
            ORDER BY IETRS_Priority__c, IETRS_Priority_Code__c, IETRS_Regulated_Entity_Type__c
        ]) {
            List<IETRS_InspSchedConfig__c> risks = new List<IETRS_InspSchedConfig__c>();
            if (riskFactors.containsKey(config.IETRS_Business_Area__c)) {
                risks = riskFactors.get(config.IETRS_Business_Area__c);
            }
            risks.add(config);
            riskFactors.put(config.IETRS_Business_Area__c, risks);
        }

        System.debug('IETRS_InspScheduleService.buildRiskMap yields riskFactors: ' + riskFactors);
        return riskFactors;
    }

    /**
     * @description - Get map of Regulated Entity accounts
     * @author Mark Frizzell | 7/19/2019
     * @return Map<Id, Account>
     */
    public static Map<Id, Account> buildRegEntityMap(List<Account> entities) {
        Map<Id, Account> resultsMap = new Map<Id, Account>();

        for (Account re : entities) {
            resultsMap.put(re.Id, re);
        }
        return resultsMap;
    }
    /**
     * @description - Get ids of entities with inspection schedules from the previous year
     *  that are not related to an IP.
     */
    public static Set<Id> getCarryOverEntityIds(
        List<Account> entities,
        IETRS_InspSchedConfig__c configRecord
        ) {
        Set<Id> result = new Set<Id>();
        if (configRecord.IETRS_Year__c == NULL) {
            return result;
        }
        String priorYear = String.valueOf(
            Integer.valueOf(configRecord.IETRS_Year__c) - 1
        );
        for (IETRS_InspSchedule__c sched : [
            SELECT Id, IETRS_Regulated_Entity__c
            FROM IETRS_InspSchedule__c
            WHERE
                IETRS_Regulated_Entity__c IN :entities
                AND IETRS_Type__c = :configRecord.IETRS_Schedule_Type__c
                AND IETRS_Inspection_Year__c = :priorYear
                AND IETRS_Inspection_Package__c = NULL
        ]) {
            result.add(sched.IETRS_Regulated_Entity__c);
        }
        return result;
    }

    /**
     * @description - Map related inspection records to RE accounts
     * @author Mark Frizzell | 7/19/2019
     * @param Map<Id, Account> regEntMap - Map of RE accounts to use
     * @return Map<Id, Account> - Map of inspections to RE accounts
     * added check for Comprehensive inspection subtype per jira ticket TXBUSUPP-40 notes from Krissy.
     */
    // Previously this always grabbed the IETRS_Latest_Inspection__c from the regulated entity
    // The updated code intends to look at all related inspections and find the last inspection
    // of the same type and business area to allow functionality with mutiple active busienss areas
    // in production
    public static Map<Id, IETRS_Inspection__c> buildInspectionMap(
        Map<Id, Account> regEntMap
    ) {
        Map<Id, IETRS_Inspection__c> resultsMap = new Map<Id, IETRS_Inspection__c>();
        
        // Get Ids for Latest Inspection from each RE account
        Set<Id> inspIds = new Set<Id>();
        Map<Id, List<Id>> inspIdMap = new Map<Id, List<Id>>();
        for (Id reID : regEntMap.keyset()){
            Account re = regEntMap.get(reId);
            if (!re.Inspections__r.isEmpty()){
                List<Id> reInspIds = new List<Id>();
                for(IETRS_Inspection__c insp : re.Inspections__r){
                    reInspIds.add(insp.id);
                }
                inspIdMap.put(re.Id, reInspIds);
                inspIds.addAll(reInspIds);
            }
        }

        for (IETRS_Inspection__c insp : [
            SELECT
                Id,
                Name,
                IETRS_Regulated_Entity__c,
                IETRS_Regulated_Entity_Type__c,
                IETRS_Customers__c,
                IETRS_TotalViolations__c,
                IETRS_UnrepairedLeaks__c,
                IETRS_Inspection_Status__c,
                IETRS_TotalMilesAtEval__c,
                IETRS_Total_Miles_of_Pipes__c,
                RecordType.Name,
                IETRS_Regulated_Entity__r.IETRS_Allowed_Inspection_Record_Type__c,
                IETRS_Inspection_Package__r.IETRS_Inspection_Type__c,
                IETRS_Inspection_Package__r.IETRS_Inspection_Sub_Type__c,
                IETRS_Inspection_Package__r.IETRS_Begin_Date__c,
                IETRS_UnrepairedGrade2Leaks__c,
                IETRS_UnrepairedGrade3Leaks__c,
                IETRS_ServiceAvgLength__c,
                IETRS_Inspection_Start_Date_and_Time__c,
                IETRS_EndDateTime__c,
                (SELECT Id FROM Violations__r),
                (
                    SELECT 
                        Id, 
                        IETRS_Miles__c, 
                        IETRS_Pipe_Size__c, 
                        IETRS_Pipe_Type_Material__c
                    FROM Miles_of_Pipe_by_Size__r
                ),
                (
                    SELECT 
                        Id, 
                        IETRS_Miles__c, 
                        IETRS_Pipe_Size__c, 
                        IETRS_Pipe_Type_Material__c
                    FROM Miles_of_Pipe_by_Size_MM__r
                ),
                (
                    SELECT 
                        Id, 
                        IETRS_Miles__c, 
                        IETRS_Pipe_Size__c, 
                        IETRS_Pipe_Type_Material__c
                    FROM Miles_of_Pipe_by_Size_Gas_Liq__r
                ),
                (
                    SELECT Id, IETRS_MCF_Purchased__c, IETRS_MCF_Sold__c 
                    FROM Lost_and_Unaccountable_Gas__r
                ),
                (
                    SELECT Id, IETRS_Services_Leaks__c 
                    FROM Repaired_Leaks__r
                ),
                (
                    SELECT Id 
                    FROM Repaired_Leaks_Gas_Liq__r
                ),
                (
                    SELECT Id, IETRS_Miles_of_HCA__c, IETRS_Location__c 
                    FROM Pipes_by_Class__r
                ),
                (
                    SELECT Id, IETRS_Miles_of_HCA__c, IETRS_Location__c 
                    FROM Pipes_by_Class_Haz_Liq__r
                )
            FROM IETRS_Inspection__c
            WHERE 
                Id IN :inspIds
                AND IETRS_Inspection_Status__c IN :COMPLETE_STATUSES
                AND IETRS_Inspection_Package__r.IETRS_Inspection_Sub_Type__c = :INSP_SUB_TYPE
                AND IETRS_Inspection_Package__r.IETRS_Inspection_Type__c = :INSP_TYPE
            ORDER BY IETRS_Begin_Date__c
        ]) 
        {
            if(
                !(resultsMap.containsKey(insp.IETRS_Regulated_Entity__c)) || 
                resultsMap.get(insp.IETRS_Regulated_Entity__c).IETRS_Inspection_Package__r.IETRS_Begin_Date__c < 
                insp.IETRS_Inspection_Package__r.IETRS_Begin_Date__c
            ){
                resultsMap.put(insp.IETRS_Regulated_Entity__c, insp);
            }
        }
        return resultsMap;
    }

    /**
     * @description - Builds a map of existing schedule records for this schedule generation record
     * @author Mark Frizzell | 9/6/2019
     * @param genRecordId - Schedule config generation record to retrieve schedule records for
     * @return Map<Id, IETRS_Insp_InspSchedule__c> - Map of schedule records to Regulated Entity account Id
     **/
    public static Map<Id, IETRS_InspSchedule__c> buildScheduleMap(
        Id genRecordId
    ) {
        System.debug('xz IETRS_InspScheduleServices.buildScheduleMap, genRecordId(AKA Config.Id): ' + genRecordId);
        Map<Id, IETRS_InspSchedule__c> resultsMap = new Map<Id, IETRS_InspSchedule__c>();
        for (IETRS_InspSchedule__c sched : [
            SELECT
                Id,
                Name,
                IETRS_Regulated_Entity__c,
                IETRS_Inspection_Package__c,
                IETRS_Priority__c,
                IETRS_Inspection_Schedule_Config__c,
                IETRS_Approved__c,
                IETRS_Risk_Factors__c
            FROM IETRS_InspSchedule__c
            WHERE IETRS_Inspection_Schedule_Config__c = :genRecordId
        ]) {
            resultsMap.put(sched.IETRS_Regulated_Entity__c, sched);
        }
        System.debug('xz IETRS_InspScheduleServices.buidScheduleMap yields: map created with size of: ' + resultsMap.size());
        return resultsMap;
    }

    /**
     * @description - Check risk factor logic against this account
     * @author Mark Frizzell | 8/26/2019
     * @param IETRS_Insp_InspSchedConfig__c risk - Risk factor details
     * @param Account re - Regulated Entity account to check
     * @param IETRS_Inspection__c insp - Related inspection records for the Regulated Entity
     * @param IETRS_InspSchedConfig__c frequency - The Frequency Config record related to the business area and RE Type
     * @return Boolean - Was risk factor applied?
     */
    private static Boolean checkRiskFactor(
        IETRS_InspSchedConfig__c risk,
        Account re,
        IETRS_Inspection__c insp,
        Boolean hasCarryoverSchedule,
        Integer scheduleYear
    ) {
        String code = risk.IETRS_Priority_Code__c,
            operator = risk.IETRS_Condition_Operator__c,
            reType = re.IETRS_Allowed_Inspection_Record_Type__c;
        Decimal value1 = risk.IETRS_Value_One__c, 
            value2 = risk.IETRS_Value_Two__c;

        System.debug('## code: ' + code);
        System.debug('-- operator: ' + operator);
        System.debug('-- value1: ' + value1);
        System.debug('-- value2: ' + value2);
        System.debug('--- hasCarryoverSchedule ' + hasCarryoverSchedule);
        System.debug('--- Priority ' + risk.IETRS_Priority__c);
        System.debug('--- ID: ' + risk.Id);
        System.debug('--- Regulated Entity: ' + re.Name);

        switch on code {
            // A-PVC
            // if regulated entity has type 'Master Meter' or 'Distribution', and total miles of pipe != 0;
            // use IETRS_InspSchedConfig__c.Operator to compare Sum(miles of pipe) to IETRS_InspSchedConfig__c.Value1 and IETRS_InspSchedConfig__c.Value2 if applicable
            when 'A-PVC Pipe' {
                Decimal miles = 0;
                if (reType == RE_TYPE_MM) {
                    for (
                        IETRS_Miles_of_Pipe_by_Size_MM__c rec : insp.Miles_of_Pipe_by_Size_MM__r
                    ) {
                        System.debug(
                            '---- material: ' + rec.IETRS_Pipe_Type_Material__c
                        );
                        if (rec.IETRS_Pipe_Type_Material__c == 'PVC') {
                            miles += rec.IETRS_Miles__c != null 
                                ? rec.IETRS_Miles__c 
                                : 0;
                        }
                    }
                } else if (reType == RE_TYPE_DIST) {
                    for (
                        IETRS_Miles_of_Pipe_by_Size__c rec : insp.Miles_of_Pipe_by_Size__r
                    ) {
                        System.debug(
                            '---- material: ' + rec.IETRS_Pipe_Type_Material__c
                        );
                        if (rec.IETRS_Pipe_Type_Material__c == 'PVC') {
                            miles += rec.IETRS_Miles__c != null 
                                ? rec.IETRS_Miles__c 
                                : 0;
                        }
                    }
                } else {
                    return false;
                }
                Decimal totalMiles = insp.IETRS_TotalMilesAtEval__c != null 
                    ? insp.IETRS_TotalMilesAtEval__c 
                    : 0;
                Decimal ratio = totalMiles != 0 ? miles / totalMiles : 0;
                System.debug('---- miles: ' + miles);
                System.debug('---- totalMiles: ' + totalMiles);
                System.debug('---- ratio: ' + ratio);

                if (operator == OP_GREATER_THAN) {
                    return ratio > value1;
                } else if (operator == OP_LESS_THAN) {
                    return ratio < value1;
                } else if (operator == OP_BETWEEN) {
                    return ratio >= value1 && ratio <= value2;
                }
            }
            // B-Bare Pipe
            // if regulated entity has type 'Master Meter', 'Distribution', or 'Gas Transmission', 
            // IETRS_Pipe_Type_Material__c IN ('Steel Unprotected Bare','Steel Protected Bare') and total miles of pipe != 0;
            // use IETRS_InspSchedConfig__c.Operator to compare Sum(miles of pipe) to IETRS_InspSchedConfig__c.Value1 and IETRS_InspSchedConfig__c.Value2 if applicable
            when 'B-Bare Pipe' {
                Decimal miles = 0;
                if (reType == RE_TYPE_MM) {
                    for (
                        IETRS_Miles_of_Pipe_by_Size_MM__c rec : insp.Miles_of_Pipe_by_Size_MM__r
                    ) {
                        String pipeMaterial = rec.IETRS_Pipe_Type_Material__c;
                        if (
                            pipeMaterial == 'Steel Unprotected Bare' || 
                            pipeMaterial == 'Steel Protected Bare'
                        ) {
                            miles += rec.IETRS_Miles__c != null 
                                ? rec.IETRS_Miles__c 
                                : 0;
                        }
                    }
                } else if (reType == RE_TYPE_DIST) {
                    for (
                        IETRS_Miles_of_Pipe_by_Size__c rec : insp.Miles_of_Pipe_by_Size__r
                    ) {
                        String pipeMaterial = rec.IETRS_Pipe_Type_Material__c;
                        if (
                            pipeMaterial == 'Steel Unprotected Bare' || 
                            pipeMaterial == 'Steel Protected Bare'
                        ) {
                            miles += rec.IETRS_Miles__c != null 
                                ? rec.IETRS_Miles__c 
                                : 0;
                        }
                    }
                } else if (reType == RE_TYPE_GAS || reType == RE_TYPE_HAZ) {
                    for (
                        IETRS_Miles_of_Pipe_by_Size_Gas_Liq__c rec : insp.Miles_of_Pipe_by_Size_Gas_Liq__r
                    ) {
                        String pipeMaterial = rec.IETRS_Pipe_Type_Material__c;
                        if (
                            pipeMaterial == 'Steel Unprotected Bare' || 
                            pipeMaterial == 'Steel Protected Bare'
                        ) {
                            miles += rec.IETRS_Miles__c != null 
                                ? rec.IETRS_Miles__c 
                                : 0;
                        }
                    }
                } else {
                    return false;
                }
                Decimal totalMiles = insp.IETRS_TotalMilesAtEval__c != null 
                    ? insp.IETRS_TotalMilesAtEval__c 
                    : 0;
                Decimal ratio = totalMiles != 0 ? miles / totalMiles : 0;
                System.debug('---- miles: ' + miles);
                System.debug('---- totalMiles: ' + totalMiles);
                System.debug('---- ratio: ' + ratio);

                if (operator == OP_GREATER_THAN) {
                    return ratio > value1;
                } else if (operator == OP_LESS_THAN) {
                    return ratio < value1;
                } else if (operator == OP_BETWEEN) {
                    return ratio >= value1 && ratio <= value2;
                }
            }
            // C-Customer Count
            // if inspection.customers != null/0;
            // use IETRS_InspSchedConfig__c.Operator to compare Count(customers) to IETRS_InspSchedConfig__c.Value1 and IETRS_InspSchedConfig__c.Value2 if applicable
            when 'C-Customer Count' {
                Decimal customers = insp.IETRS_Customers__c != null 
                    ? insp.IETRS_Customers__c 
                    : 0;
                System.debug('---- customerCount: ' + customers);
                if (operator == OP_GREATER_THAN) {
                    return customers > value1;
                } else if (operator == OP_LESS_THAN) {
                    return customers < value1;
                } else if (operator == OP_BETWEEN) {
                    return customers >= value1 && customers <= value2;
                }
            }
            // D-Unrepaired Leaks
            // using the number of unrepaired leaks and average length of pipe, all from the inspection, with the total miles of pipe and number of repaired leaks
            // calculates the % of unrepaired pipe,
            // use IETRS_InspSchedConfig__c.Operator to compare  % of unrepaired pipe to IETRS_InspSchedConfig__c.Value1 and IETRS_InspSchedConfig__c.Value2 if applicable
            when 'D-Unrepaired Leaks' {
                Decimal grade2 = insp.IETRS_UnrepairedGrade2Leaks__c != null 
                        ? insp.IETRS_UnrepairedGrade2Leaks__c 
                        : 0,
                    grade3 = insp.IETRS_UnrepairedGrade3Leaks__c != null 
                        ? insp.IETRS_UnrepairedGrade3Leaks__c 
                        : 0,
                    avgLength = insp.IETRS_ServiceAvgLength__c != null 
                        ? insp.IETRS_ServiceAvgLength__c 
                        : 0,
                    services = 0,
                    miles = 0,
                    unrepairedPct = 0;

                for (
                    IETRS_Miles_of_Pipe_by_Size__c rec : insp.Miles_of_Pipe_by_Size__r
                ) {
                    miles += rec.IETRS_Miles__c != null 
                    ? rec.IETRS_Miles__c 
                    : 0;
                }
                for (IETRS_Repaired_Leaks__c rec : insp.Repaired_Leaks__r) {
                    services += rec.IETRS_Services_Leaks__c != null 
                    ? rec.IETRS_Services_Leaks__c 
                    : 0;
                }

                try {
                    unrepairedPct = 
                        ((grade2 + grade3) / 
                        (((avgLength * services) / 5280) + miles)) * 100;
                } catch (System.MathException mEx) {
                    unrepairedPct = 0;
                }

                System.debug('---- unrepairedPct: ' + unrepairedPct);
                if (operator == OP_GREATER_THAN) {
                    return unrepairedPct > value1;
                } else if (operator == OP_LESS_THAN) {
                    return unrepairedPct < value1;
                } else if (operator == OP_BETWEEN) {
                    return unrepairedPct >= value1 && unrepairedPct <= value2;
                }
            }
            // E-Incidents
            // if the inspection subtype is 'Incident'
            // returns true
            when 'E-Incidents' {
                if (
                    re.IETRS_Latest_Inspection__r.IETRS_Inspection_Package__r.IETRS_Inspection_Sub_Type__c == 
                    'Incident'
                ) {
                    return true;
                } else {
                    return false;
                }
            }
            // F-HCAs
            // if regulated entity has type 'Gas Transmission' or 'Hazardous Liquid' calculate Sum(specified miles of pipe) from the inspection.pipes_by_class
            // calculate % of total pipe,
            // use IETRS_InspSchedConfig__c.Operator to compare  % of total pipe to IETRS_InspSchedConfig__c.Value1 and IETRS_InspSchedConfig__c.Value2 if applicable
            when 'F-HCAs' {
                Decimal hca = 0;
                Decimal miles = 0;
                if (reType == RE_TYPE_GAS) {
                    for (IETRS_Pipes_by_Class__c rec : insp.Pipes_by_Class__r) {
                        hca += rec.IETRS_Miles_of_HCA__c != null 
                            ? rec.IETRS_Miles_of_HCA__c 
                            : 0;
                    }
                }
                if (reType == RE_TYPE_HAZ) {
                    for (
                        IETRS_Pipes_by_Class_Haz_Liq__c rec : insp.Pipes_by_Class_Haz_Liq__r
                    ) {
                        hca += rec.IETRS_Miles_of_HCA__c != null 
                        ? rec.IETRS_Miles_of_HCA__c 
                        : 0;
                    }
                }
                for (
                    IETRS_Miles_of_Pipe_by_Size_Gas_Liq__c rec : insp.Miles_of_Pipe_by_Size_Gas_Liq__r
                ) {
                    miles += rec.IETRS_Miles__c != null 
                    ? rec.IETRS_Miles__c 
                    : 0;
                }
                Decimal hcaPct = miles != 0 ? (hca / miles) * 100 : 0;
                System.debug('---- hca: ' + hca);
                System.debug('---- miles: ' + miles);
                System.debug('---- hcaPct: ' + hcaPct);

                if (operator == OP_GREATER_THAN) {
                    return hcaPct > value1;
                } else if (operator == OP_LESS_THAN) {
                    return hcaPct < value1;
                } else if (operator == OP_BETWEEN) {
                    return hcaPct >= value1 && hcaPct <= value2;
                }
            }
            // G-Pipe Size
            // if miles of pipe >0 & pipesize !=null, extracts the numeric value from IETRS_Pipe_Size__c, stores as pipeSize & gets max value of pipe size
            // use IETRS_InspSchedConfig__c.Operator to comparemax value of pipe size to IETRS_InspSchedConfig__c.Value1 and IETRS_InspSchedConfig__c.Value2 if applicable
            when 'G-Pipe Size' {
                Decimal maxSize = 0;
                
                for (
                    IETRS_Miles_of_Pipe_by_Size_Gas_Liq__c rec : insp.Miles_of_Pipe_by_Size_Gas_Liq__r
                ) {
                    if (rec.IETRS_Miles__c > 0) {
                        string fieldPipeSize = '';
                        if (rec.IETRS_Pipe_Size__c != null) {
                            if (rec.IETRS_Pipe_Size__c.contains(' ')) {
                                integer strLength = rec.IETRS_Pipe_Size__c.length();
                                for (
                                    integer i = 0;
                                    i < rec.IETRS_Pipe_Size__c.length();
                                    i++
                                ) {
                                    String s = rec.IETRS_Pipe_Size__c.mid(i, 1);
                                    if (s.isNumeric()) { 
                                        fieldPipeSize += s;
                                    } else if (
                                        fieldPipeSize != '' && 
                                        (s == ' ' || 
                                        s == '"')
                                    ) {
                                        break;
                                    }
                                }
                            } else {
                                fieldPipeSize = rec.IETRS_Pipe_Size__c;
                            }
                            
                            fieldPipeSize = fieldPipeSize == '' 
                            ? '0' 
                            : fieldPipeSize;
                            Decimal pipeSize = Decimal.valueOf(fieldPipeSize);
                            if (pipeSize > maxSize) {
                                maxSize = pipeSize; // get max pipe size for all mile records
                            }
                        }
                    }
                }
                System.debug('---- maxSize: ' + maxSize);

                if (operator == OP_GREATER_THAN) {
                    return maxSize > value1;
                } else if (operator == OP_LESS_THAN) {
                    return maxSize < value1;
                } else if (operator == OP_BETWEEN) {
                    return maxSize >= value1 && maxSize <= value2;
                }
            }
            // I-Cast Iron
            // 
            // 
            when 'I-Cast Iron' {
                Decimal miles = 0;
                if (reType == RE_TYPE_MM) {
                    for (
                        IETRS_Miles_of_Pipe_by_Size_MM__c rec : insp.Miles_of_Pipe_by_Size_MM__r
                    ) {
                        if (
                            rec.IETRS_Pipe_Type_Material__c == 
                            'Cast/Wrought Iron'
                        ) {
                            miles += rec.IETRS_Miles__c != null 
                            ? rec.IETRS_Miles__c 
                            : 0;
                        }
                    }
                } else if (reType == RE_TYPE_DIST) {
                    for (
                            IETRS_Miles_of_Pipe_by_Size__c rec : insp.Miles_of_Pipe_by_Size__r
                        ) {
                            if (
                                rec.IETRS_Pipe_Type_Material__c == 
                                'Cast/Wrought Iron'
                            ) {
                                miles += rec.IETRS_Miles__c != null 
                                ? rec.IETRS_Miles__c 
                                : 0;
                        }
                    }
                } else {
                    return false;
                }
                System.debug('---- miles: ' + miles);

                if (operator == OP_GREATER_THAN) {
                    return miles > value1;
                } else if (operator == OP_LESS_THAN) {
                    return miles < value1;
                } else if (operator == OP_BETWEEN) {
                    return miles >= value1 && miles <= value2;
                }
            }
            // L-Leakage
            // 
            // 
            when 'L-Leakage' {
                Decimal mfcPurchased = 0;
                Decimal mfcSold = 0;
                /*                for(IETRS_Lost_and_Unaccountable_Gas__c rec : insp.Lost_and_Unaccountable_Gas__r) {
                    mfcPurchased += rec.IETRS_Insp_MCF_Purchased__c != null ? rec.IETRS_Insp_MCF_Purchased__c : 0;
                    mfcSold += rec.IETRS_Insp_MCF_Sold__c != null ? rec.IETRS_Insp_MCF_Sold__c : 0;
                }
                */ 
                Decimal value = 
                    mfcPurchased - mfcSold;
                System.debug('---- mfcPurchased: ' + mfcPurchased);
                System.debug('---- mfcSold: ' + mfcSold);
                System.debug('---- value: ' + value);

                if (operator == OP_GREATER_THAN) {
                    return value > value1;
                } else if (operator == OP_LESS_THAN) {
                    return value < value1;
                } else if (operator == OP_BETWEEN) {
                    return value >= value1 && value <= value2;
                }
            }
            // M-System Type Municipal
            // 
            // 
            when 'M-System Type Municipal' {
                if (re.IETRS_Entity_Sub_Type__c == 'Municipal') {
                    System.debug('---- municipal: true');
                    return true;
                } else {
                    System.debug('---- municipal: false');
                    return false;
                }
            }
            // N-New Construction
            // 
            // 
            when 'N-New Construction' {
                if (re.IETRS_Status__c == 'Construction') {
                    System.debug('---- construction: true');
                    return true;
                } else {
                    System.debug('---- construction: false');
                    return false;
                }
            }
            // O-Outside Inspection Frequency
            // 
            // 
            when 'O-Outside Inspection Frequency' {
                    Date lastInspectionDate;
                if (insp.IETRS_Inspection_Start_Date_and_Time__c != null) {
                    lastInspectionDate = insp.IETRS_Inspection_Start_Date_And_Time__c.date();
                }
                // if a PHMSA inspection year was set and if the RE type is UNGS
                if (
                    String.isNotBlank(re.IETRS_PHMSA_Inspection_Year__c) &&
                    reType == RE_TYPE_UNGS
                ) {
                    Date phmsaDate;
                    try {
                        // parse the date in a try/catch and fall back to using last inspection
                        Integer phmsaYear = Integer.valueOf(
                            re.IETRS_PHMSA_Inspection_Year__c
                        );
                        phmsaDate = Date.newInstance(phmsaYear, 1, 1);
                    } catch (Exception e) {
                        phmsaDate = null;
                    }
                    // Use the most recent date if PHMSA inspection year is later than the
                    // last inspection date
                    if (lastInspectionDate == null || phmsaDate > lastInspectionDate) {
                        lastInspectionDate = phmsaDate;
                    }
                }
                if (lastInspectionDate != null) {
                    Date lastDayOfScheduleYear = Date.newInstance(
                        scheduleYear,
                        12,
                        31
                    );

                    return lastInspectionDate.addYears(
                            Integer.valueOf(value1)
                        ) <= lastDayOfScheduleYear;
                }
                    return false;
            }
            // P-Location
            // 
            // 
            when 'P-Location' {
                for (IETRS_Pipes_by_Class__c rec : insp.Pipes_by_Class__r) {
                    if (
                        rec.IETRS_Location__c != null &&
                        rec.IETRS_Location__c.right(1) == String.valueOf(value1) // ex. "Class 1" == "1"
                    ) {
                        System.debug('---- location: ' + rec.Id);
                        return true;
                    }
                }
                return false;
            }
            // U-Unevaluated System
            // 
            // 
            when 'U-Unevaluated System' {
                if (insp.Name == null) {
                    System.debug('---- uneval: true');
                    return true;
                } else {
                    System.debug('---- uneval: false');
                    return false;
                }
            }
            // V-Violation Count
            // 
            // 
            when 'V-Violation Count' {
                Integer violationCount = insp.Violations__r != null 
                    ? insp.Violations__r.size() 
                    : 0;
                System.debug('---- violationCount: ' + violationCount);

                if (operator == OP_GREATER_THAN) {
                    return violationCount > value1;
                } else if (operator == OP_LESS_THAN) {
                    return violationCount < value1;
                } else if (operator == OP_BETWEEN) {
                    return violationCount >= value1 && violationCount <= value2;
                }
            }
            // Z-Off Shore
            // 
            // 
            when 'Z-Off Shore' {
                Integer violationCount = 0;
                if (
                        re.IETRS_On_Offshore__c != null && 
                        re.IETRS_On_Offshore__c != 'Onshore'
                ) {
                    if (insp.Violations__r != null) {
                        violationCount = insp.Violations__r.size();
                    }
                } else {
                    return false;
                }
                System.debug('---- violationCount: ' + violationCount);

                if (operator == OP_GREATER_THAN) {
                    return violationCount > value1;
                } else if (operator == OP_LESS_THAN) {
                    return violationCount < value1;
                } else if (operator == OP_BETWEEN) {
                    return violationCount >= value1 && violationCount <= value2;
                }
            }
            // Y-Carry-Over Inspection from Last Year 
            // 
            // 
            when 'Y-Carry-Over Inspection from Last Year' {
                return hasCarryoverSchedule;
            }
        }
        return false;
    }

    /**
     * @description - Send email to user on success or error
     * @author Mark Frizzell | 8/26/2019
     * @param String subject - Email subject
     * @param String body - Body of the email
     * @return String - Send result
     */
    public static String sendEmail(String subject, String body) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new List<String>{ UserInfo.getUserEmail() });
        mail.setSubject(subject);
        mail.setPlainTextBody(body);

        System.debug('email: ' + mail);

        if (!Test.isRunningTest()) {
            for (
                Messaging.SendEmailResult res : Messaging.sendEmail(
                    new List<Messaging.Email>{ mail }
                )
            ) {
                if (res.isSuccess() != true) {
                    return res.getErrors()[0].getMessage();
                }
            }
        }
        return 'Success';
    }
}