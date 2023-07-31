/**
 * @File Name          : IETRS_InspScheduleBatch.cls
 * @Description        : Batch handler for generating inspection schedules (workplan)
 * @Author             : Mark Frizzell
 * @Group              : IETRS Inspection
 * @Last Modified By   : Sebastian Wittenstein
 * @Last Modified On   : 02/14/2023 
 * @Modification Log   :
 *==============================================================================
 * Ver      Date            Author                  Modification
 *==============================================================================
 * 1.0      08/24/2019      Mark Frizzell           Initial Version
 * 1.1      06/06/2022      Sebastian Wittenstein   Altered query to include child inspection records to support finding most recent matching type/subtype
 * 1.2      02/14/2023      Sebastian Wittenstein   Added CIIS specific logic to modify query string.
 **/
global class IETRS_InspScheduleBatch implements Database.Batchable<SObject> {
    global IETRS_InspSchedConfig__c genRecord;
    global Map<String, List<IETRS_InspSchedConfig__c>> riskMap;
    global Map<Id, IETRS_Inspection__c> inspMap;
    global Map<Id, IETRS_InspSchedule__c> schedMap;
    global String errors;
    List<Account> excludedOrgs;
    private final String cI = 'Critical Infrastructure';

    global IETRS_InspScheduleBatch(IETRS_InspSchedConfig__c configRec) {
        genRecord = configRec;
        riskMap = IETRS_InspScheduleServices.buildRiskMap();
        schedMap = IETRS_InspScheduleServices.buildScheduleMap(genRecord.Id);
        excludedOrgs = IETRS_InspScheduleServices.getExcludedOrgs();
        errors = '';
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        List<String> recTypes = IETRS_InspScheduleServices.RECTYPES_REG_ENTITY;
        String inspType = IETRS_InspScheduleServices.INSP_TYPE;
        String isnpSubType = IETRS_InspScheduleServices.INSP_SUB_TYPE;
        Set<String> excludedJurisdictionTypes = IETRS_InspScheduleServices.EXCLUDED_JURISDICTION_TYPES;
        Set<String> excludedStatuses = IETRS_InspScheduleServices.EXCLUDED_STATUSES;
        List<String> reType = IETRS_InspScheduleServices.RE_TYPE_MAP.values();
        String busArea = genRecord.IETRS_Business_Area__c,
            acctQuery =
                'SELECT Id, Name, RecordType.DeveloperName, Type, IETRS_Entity_Sub_Type__c, ' +
                'IETRS_Allowed_Inspection_Record_Type__c, IETRS_Regulated_Entity_Business_Area__c, ' +
                'Latest_Inspection_Date__c, IETRS_Latest_Inspection__c, ' +
                'IETRS_Organization_Parent__c, IETRS_OrganizationofRegEntity__c, ' +
                'IETRS_County__c, IETRS_District__c, IETRS_Region__c, IETRS_Status__c, IETRS_PHMSA_Inspection_Year__c, ' +
                'IETRS_On_Offshore__c, IETRS_Latest_Inspection__r.IETRS_Inspection_Package__r.IETRS_Inspection_Sub_Type__c, ' +
                '(SELECT Id FROM Inspections__r ' +
                    'WHERE IETRS_Inspection_Package__r.IETRS_Inspection_Type__c = \''+inspType+'\' ' +
                    'AND IETRS_Inspection_Package__r.IETRS_Inspection_Sub_Type__c = \''+isnpSubType+'\' ' +
                'ORDER BY IETRS_Inspection_Package__r.IETRS_Begin_Date__c LIMIT 100)';
        if (busArea==cI) {
            acctQuery += 
                ', CIIS_Commercial_Disposal__c, CIIS_Direct_Serve__c, CIIS_Reg_Entity_MCF_day__c, CIIS_Meets_CID__c ';
        }
        acctQuery += 
            'FROM Account ' +
            'WHERE RecordType.DeveloperName IN :recTypes ' +
            'AND IETRS_Jurisdiction__c NOT IN :excludedJurisdictionTypes ' +
            'AND IETRS_OrganizationofRegEntity__c != null ' +
            'AND IETRS_OrganizationofRegEntity__c NOT IN:excludedOrgs ' +
            'AND IETRS_Status__c NOT IN:excludedStatuses';
        if (busArea!=cI){
            acctQuery += 
                ' AND IETRS_Regulated_Entity_Business_Area__c = :busArea ' +
                'AND IETRS_Allowed_Inspection_Record_Type__c IN :reType';
        }
        if (busArea==cI) {
            acctQuery += 
                ' AND CIIS_Meets_CID__c = true ' +
                'AND IETRS_Intra_Interstate__c != \'Interstate\'';
        }

        System.debug(acctQuery.left(500));
        if (acctQuery.length()>500){
            System.debug(acctQuery.mid(500, 500));
        }
        if (acctQuery.length()>1000){
            System.debug(acctQuery.mid(1000, 500));
        }
        if (acctQuery.length()>1500){
            System.debug(acctQuery.mid(1500, 500));
        }
        return Database.getQueryLocator(acctQuery);
    }

    global void execute(Database.BatchableContext bc, List<SObject> records) {
        List<IETRS_InspSchedule__c> schedules = new List<IETRS_InspSchedule__c>();
        Map<Id, Account> regEntMap = IETRS_InspScheduleServices.buildRegEntityMap(
            records
        );
        Set<Id> carryOverEntityIds = IETRS_InspScheduleServices.getCarryOverEntityIds(
            records, 
            genRecord
        );
        inspMap = IETRS_InspScheduleServices.buildInspectionMap(regEntMap);
        for (SObject regEntity : records) {
            // Verify the account doesn't already have a schedule with an inspection package attached
            if (schedMap.containsKey(regEntity.Id)) {
                IETRS_InspSchedule__c tempSched = schedMap.get(regEntity.Id);
                if (tempSched.IETRS_Inspection_Package__c != null) {
                    continue;
                }
            }

            // Build schedule for this R.E. account
            IETRS_InspSchedule__c sched = IETRS_InspScheduleServices.buildRegEntSchedule(
                genRecord,
                (Account) regEntity,
                inspMap.get(regEntity.Id),
                schedMap.get(regEntity.Id),
                riskMap,
                carryOverEntityIds.contains(regEntity.Id)
            );
            if (sched.IETRS_Regulated_Entity__c != null) {
                schedules.add(sched);
            }
        }

        // Upsert schedule records
        try {
            upsert schedules;
        } catch (Exception ex) {
            System.debug(
                'Error: ' + 
                ex.getMessage() + 
                ' @ ' + 
                ex.getLineNumber()
            );
            errors += 'Error: ' + ex.getMessage() + '\n';
        }
    }

    global void finish(Database.BatchableContext bc) {
        AsyncApexJob job = [
            SELECT 
                Id, 
                Status, 
                NumberOfErrors, 
                JobItemsProcessed, 
                TotalJobItems, 
                CreatedBy.Email
            FROM AsyncApexJob
            WHERE Id = :bc.getJobId()
        ];
        System.debug(job);

        // Send results email
        String subject = 'IETRS Inspection Schedule Generation ' + job.Status;
        String body =
            'The schedule generation process is complete.' +
            '\nYou may view the generated schedule records here:\n' +
            URL.getSalesforceBaseUrl().toExternalForm() +
            '/' +
            genRecord.Id;
        if (errors != '') {
            body += 
            '\n\nThere were ' + 
            job.NumberOfErrors + 
            ' errors generating the records.\n' + 
            errors;
        }
        try {
            IETRS_InspScheduleServices.sendEmail(subject, body);            
        } catch (Exception e) {
            System.debug('Error sending email: '+e);
        }
    }
}