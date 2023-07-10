/**
 * @author Greg Lovelidge - Sense Corp
 * @date 5/28/2020
 *
 * @description Utility methods for making test data for test classes.
 */
@isTest
public class IETRS_I_TestUtils {
    final List<String> accountTypes = new List<String>{
        'Distribution',
        'Master Meter'
    };
    final List<String> accountStatuses = new List<String>{ 'Active' };
    public Set<String> testCounties = new Set<String>{ 'Travis', 'Williamson' };
    public Map<Schema.SObjectField, List<Object>> entityFieldValuesByField = new Map<Schema.SObjectField, List<Object>>{
        Account.Type => accountTypes,
        Account.IETRS_Status__c => accountStatuses
    };

    public Id accRegEntPSRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
        .get('Regulated_Entity_PS')
        .getRecordTypeId();

    Id inspPackageRecordTypeId = Schema.SObjectType.IETRS_Inspection_Package__c.getRecordTypeInfosByDeveloperName()
        .get('IETRS_Inspection_Package_Standard_Pipeline_Safety')
        .getRecordTypeId();
    Id distributionInspRecordTypeId = Schema.SObjectType.IETRS_Inspection__c.getRecordTypeInfosByDeveloperName()
        .get('PS_Inspection_Distribution_Systems')
        .getRecordTypeId();
    Id masterMeterInspRecordTypeId = Schema.SObjectType.IETRS_Inspection__c.getRecordTypeInfosByDeveloperName()
        .get('PS_Inspection_Master_Meter_Systems')
        .getRecordTypeId();
    Id transmissionInspRecordTypeId = Schema.SObjectType.IETRS_Inspection__c.getRecordTypeInfosByDeveloperName()
        .get('PS_Inspection_Gas_Transmission_Systems')
        .getRecordTypeId();
    Map<String, Id> inspectionRecordTypeByAccountType = new Map<String, Id>{
        'Distribution' => distributionInspRecordTypeId,
        'Master Meter' => masterMeterInspRecordTypeId,
        'Transmission' => transmissionInspRecordTypeId
    };

    public void createData(Integer numberOfOrgs, Integer numberEntitiesPerOrg) {
        String uniqueId = String.valueOf(Math.random()).right(5);
        Id accOrgRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Organization')
            .getRecordTypeId();
        Id accUnitRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('Unit')
            .getRecordTypeId();

        if (
            !entityFieldValuesByField.containsKey(Account.IETRS_Entity_Code__c)
        ) {
            List<String> codeOptions = new List<String>();
            for (
                Schema.PicklistEntry ple : getPicklistValues(
                    'Account',
                    'IETRS_Entity_Code__c'
                )
            ) {
                codeOptions.add(ple.getValue());
            }
            entityFieldValuesByField.put(
                Account.IETRS_Entity_Code__c,
                codeOptions
            );
        }

        // create statewide region
        IETRS_County_Group__c objRegion = new IETRS_County_Group__c(
            Name = '00-Statewide',
            IETRS_Group_Type__c = 'Region',
            IETRS_Business_Area__c = 'Pipeline Safety'
        );
        insert objRegion;

        // Create test organizations
        List<Account> testOrgAccts = new List<Account>();
        for (Integer i = 0; i < numberOfOrgs; i++) {
            testOrgAccts.add(
                new Account(
                    Name = 'Organization ' + uniqueId + i,
                    RecordTypeId = accOrgRecordTypeId,
                    IETRS_Company_ID__c = uniqueId + i,
                    IETRS_Total_Miles__c = 1
                )
            );
        }
        insert testOrgAccts;

        // Create a test unit for each entity
        Map<Id, List<Account>> testUnitAcctsByOrgId = new Map<Id, List<Account>>();
        List<Account> testUnitAccts = new List<Account>();
        for (Integer i = 0; i < testOrgAccts.size(); i++) {
            testUnitAcctsByOrgId.put(testOrgAccts[i].Id, new List<Account>());
            for (Integer x = 0; x < numberEntitiesPerOrg; x++) {
                Account unitAcct = new Account(
                    Name = 'Unit ' + uniqueId + x,
                    RecordTypeId = accUnitRecordTypeId,
                    ParentId = testOrgAccts[i].Id,
                    Type = 'Distribution',
                    IETRS_Unit_ID__c = 'Unit' + uniqueId + x
                );
                testUnitAccts.add(unitAcct);
                testUnitAcctsByOrgId.get(testOrgAccts[i].Id).add(unitAcct);
            }
        }
        insert testUnitAccts;

        // Create test regulated entities
        List<Account> testEntityAccts = new List<Account>();
        for (Integer i = 0; i < testOrgAccts.size(); i++) {
            Id orgId = testOrgAccts[i].Id;
            for (Integer x = 0; x < numberEntitiesPerOrg; x++) {
                Id unitId = testUnitAcctsByOrgId.get(orgId)[x].Id;
                Account entity = new Account(
                    Name = i + 'Regulated Entity PS ' + uniqueId + x,
                    RecordTypeId = accRegEntPSRecordTypeId,
                    IETRS_OrganizationofRegEntity__c = orgId,
                    IETRS_Unit_Parent__c = unitId,
                    ParentId = unitId,
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
                    CIIS_Meets_CID__c = true
                );
                for (
                    Schema.SObjectField field : entityFieldValuesByField.keySet()
                ) {
                    String val = (String) getFieldValue(
                        x,
                        entityFieldValuesByField.get(field)
                    );
                    if (val != null) {
                        entity.put(field, val);
                    }
                }
                if (
                    entity.IETRS_Entity_Code__c ==
                    'Y-Company System (Non-Physical)'
                ) {
                    entity.IETRS_Install_Year__c = null;
                    entity.IETRS_T4_Permit__c = null;
                    entity.Type = null;
                    entity.IETRS_Entity_Sub_Type__c = null;
                    entity.IETRS_Total_Miles__c = null;
                    entity.IETRS_On_Offshore__c = null;
                    entity.IETRS_Product_Sub_Class__c = null;
                }
                testEntityAccts.add(entity);
            }
        }
        insert testEntityAccts;

        // Create inspections

        Map<Id, IETRS_Inspection_Package__c> inspectionPackageByEntityId = new Map<Id, IETRS_Inspection_Package__c>();
        for (Account entity : testEntityAccts) {
            inspectionPackageByEntityId.put(
                entity.Id,
                new IETRS_Inspection_Package__c(
                    IETRS_Inspection_Type__c = 'Standard',
                    IETRS_Inspection_Sub_Type__c = 'Comprehensive',
                    IETRS_Organization__c = entity.IETRS_OrganizationofRegEntity__c,
                    IETRS_Unit_Name__c = entity.IETRS_Unit_Parent__c,
                    IETRS_Begin_Date__c = System.today().addYears(-1),
                    RecordTypeId = inspPackageRecordTypeId
                )
            );
        }
        insert inspectionPackageByEntityId.values();

        List<IETRS_Inspection__c> inspections = new List<IETRS_Inspection__c>();
        for (Account acc : testEntityAccts) {
            if (inspectionRecordTypeByAccountType.containsKey(acc.Type)) {
                inspections.add(
                    new IETRS_Inspection__c(
                        IETRS_Inspection_Package__c = inspectionPackageByEntityId.get(
                                acc.Id
                            )
                            .Id,
                        IETRS_Inspection_Start_Date_And_Time__c = System.now()
                            .addYears(-1),
                        IETRS_Inspection_Status__c = 'Approved',
                        IETRS_Regulated_Entity__c = acc.Id,
                        RecordTypeId = inspectionRecordTypeByAccountType.get(
                            acc.Type
                        )
                    )
                );
            }
        }
        insert inspections;

        // create IETRS_Miles_of_Pipe_by_Size_Gas_Liq__c records
        List<IETRS_Miles_of_Pipe_by_Size_Gas_Liq__c> milesOfPipe = new List<IETRS_Miles_of_Pipe_by_Size_Gas_Liq__c>();
        List<IETRS_Pipes_by_Class__c> pipesByClass = new List<IETRS_Pipes_by_Class__c>();
        List<IETRS_Pipes_by_Class_Haz_Liq__c> pipesByClassHazLiq = new List<IETRS_Pipes_by_Class_Haz_Liq__c>();
        for (IETRS_Inspection__c insp : inspections) {
            milesOfPipe.add(
                new IETRS_Miles_of_Pipe_by_Size_Gas_Liq__c(
                    IETRS_Inspection__c = insp.Id,
                    IETRS_Miles__c = 1000,
                    IETRS_Pipe_Location__c = 'Transmission/Onshore',
                    IETRS_Pipe_Size__c = 'Over 28"',
                    IETRS_Pipe_Type_Material__c = 'Steel Protected Bare'
                )
            );
            pipesByClass.add(
                new IETRS_Pipes_by_Class__c(
                    IETRS_Inspection__c = insp.Id,
                    IETRS_Location__c = 'Class 1',
                    IETRS_MAOP__c = 450,
                    IETRS_Miles_Odorized__c = 1000,
                    IETRS_Miles_of_HCA__c = 1000,
                    IETRS_Miles_of_Pipe__c = 1000,
                    IETRS_Miles_of_Smart_Piggable__c = 1000,
                    IETRS_Outside_Diameter__c = 3,
                    IETS_Pipe_Grade__c = 30000,
                    IETRS_Pressure_Tested__c = true,
                    IETRS_Wall_Thickness__c = .154
                )
            );
            pipesByClassHazLiq.add(
                new IETRS_Pipes_by_Class_Haz_Liq__c(
                    IETRS_Inspection__c = insp.Id,
                    IETRS_Location__c = 'Non-Rural',
                    IETRS_MAOP__c = 450,
                    IETRS_Miles_Odorized__c = 1000,
                    IETRS_Miles_of_HCA__c = 1000,
                    IETRS_Miles_of_Pipe__c = 1000,
                    IETRS_Miles_of_Smart_Piggable__c = 1000,
                    IETRS_Outside_Diameter__c = 3,
                    IETRS_Pressure_Tested__c = true,
                    IETRS_Wall_Thickness__c = .154
                )
            );
        }
        insert milesOfPipe;
        insert pipesByClass;
        insert pipesByClassHazLiq;
        // IETRS_Inspection__c
        // IETRS_Miles__c number
        /// IETRS_Pipe_Location__c - Transmission/Onshore, Gathering/Onshore, Transmission/Offshore, Gathering/Offshore
        // IETRS_Pipe_Size__c - Above50
        // IETRS_Pipe_Type_Material__c - Cast/Wrought Iron

        // create IETRS_Insp_Number_of_Services_by_Size__c records
        List<IETRS_Insp_Number_of_Services_by_Size__c> sizeRecords = new List<IETRS_Insp_Number_of_Services_by_Size__c>();
        // and set each inspection to the latest inspection for the account
        List<Account> updateAccounts = new List<Account>();
        for (IETRS_Inspection__c inspection : inspections) {
            sizeRecords.add(
                new IETRS_Insp_Number_of_Services_by_Size__c(
                    IETRS_Pipe_Size__c = '20"',
                    IETRS_Pipe_Type__c = 'ABS',
                    IETRS_Services__c = 10,
                    IETRS_Inspection__c = inspection.Id
                )
            );
            updateAccounts.add(
                new Account(
                    Id = inspection.IETRS_Regulated_Entity__c,
                    IETRS_Latest_Inspection__c = inspection.Id
                )
            );
        }
        insert sizeRecords;
        update updateAccounts;

        // create IETRS_Miles_of_Pipe_by_Size__c  records
        List<IETRS_Miles_of_Pipe_by_Size__c> mileRecords = new List<IETRS_Miles_of_Pipe_by_Size__c>();
        for (IETRS_Inspection__c inspection : inspections) {
            mileRecords.add(
                new IETRS_Miles_of_Pipe_by_Size__c(
                    IETRS_Pipe_Type_Material__c = 'Steel Unprotected Bare',
                    IETRS_Inspection__c = inspection.Id
                )
            );
        }
        insert mileRecords;

        // create IETRS_Miles_of_Pipe_by_Size_Gas_Liq__c  records
        List<IETRS_Miles_of_Pipe_by_Size_Gas_Liq__c> mileLiquidRecords = new List<IETRS_Miles_of_Pipe_by_Size_Gas_Liq__c>();
        for (IETRS_Inspection__c inspection : inspections) {
            mileLiquidRecords.add(
                new IETRS_Miles_of_Pipe_by_Size_Gas_Liq__c(
                    IETRS_Miles__c = 1000,
                    IETRS_Inspection__c = inspection.Id
                )
            );
        }
        insert mileLiquidRecords;

        // create IETRS_Miles_of_Pipe_by_Size_MM__c  records
        List<IETRS_Miles_of_Pipe_by_Size_MM__c> mmRecords = new List<IETRS_Miles_of_Pipe_by_Size_MM__c>();
        for (IETRS_Inspection__c inspection : inspections) {
            mmRecords.add(
                new IETRS_Miles_of_Pipe_by_Size_MM__c(
                    IETRS_Pipe_Type_Material__c = 'Cast/Wrought Iron',
                    IETRS_Inspection__c = inspection.Id
                )
            );
        }
        insert mmRecords;

        // add some schedules
        List<IETRS_InspSchedule__c> inspectionSchedules = new List<IETRS_InspSchedule__c>();
        for (Account entity : testEntityAccts) {
            inspectionSchedules.add(
                new IETRS_InspSchedule__c(
                    IETRS_Regulated_Entity__c = entity.Id,
                    IETRS_Organization__c = entity.IETRS_OrganizationofRegEntity__c,
                    IETRS_Type__c = 'Pipeline Routine Schedule',
                    IETRS_Inspection_Sub_Type__c = 'Comprehensive',
                    IETRS_Inspection_Year__c = String.valueOf(
                        Date.today().year()
                    )
                )
            );
        }
        insert inspectionSchedules;
    }

    public void createSpecializedInspections(List<Account> testEntityAccts) {
        Map<Id, List<Account>> entitiesByOrgId = new Map<Id, List<Account>>();
        Map<Id, Set<String>> classificationsByOrgId = new Map<Id, Set<String>>();
        Map<Id, Account> entityByUnitId = new Map<Id, Account>();
        Id countryGroupId = [
            SELECT Id, name
            FROM IETRS_County_Group__c
            WHERE Name = '00-Statewide'
        ]
        .Id;
        // create org id map
        for (Account acc : testEntityAccts) {
            String entityClassification = getEntityClassification(
                acc.IETRS_Product_Class__c,
                acc.Type
            );
            // set unit map
            entityByUnitId.put(acc.ParentId, acc);
            if (
                !entitiesByOrgId.containsKey(
                    acc.IETRS_OrganizationofRegEntity__c
                )
            ) {
                entitiesByOrgId.put(
                    acc.IETRS_OrganizationofRegEntity__c,
                    new List<Account>()
                );
            }
            entitiesByOrgId.get(acc.IETRS_OrganizationofRegEntity__c).add(acc);
            if (String.isBlank(entityClassification)) {
                continue;
            }
            if (
                !classificationsByOrgId.containsKey(
                    acc.IETRS_OrganizationofRegEntity__c
                )
            ) {
                classificationsByOrgId.put(
                    acc.IETRS_OrganizationofRegEntity__c,
                    new Set<String>()
                );
            }
            classificationsByOrgId.get(acc.IETRS_OrganizationofRegEntity__c)
                .add(entityClassification);
        }

        Map<Id, Id> nonPhysicalEntityIdByOrgId = new Map<Id, Id>();
        for (Account nonPhysicalEntity : [
            SELECT Id, IETRS_OrganizationofRegEntity__c
            FROM Account
            WHERE
                IETRS_OrganizationofRegEntity__c IN :entitiesByOrgId.keySet()
                AND IETRS_Entity_Code__c = :IETRS_SpecializedInspScheduleServices.ENTITY_CODE
                AND IETRS_Jurisdiction__c NOT IN :IETRS_SpecializedInspScheduleServices.EXCLUDED_JURISDICTION_TYPES
        ]) {
            nonPhysicalEntityIdByOrgId.put(
                nonPhysicalEntity.IETRS_OrganizationofRegEntity__c,
                nonPhysicalEntity.Id
            );
        }

        // create speciazlied inspection packages
        List<IETRS_Inspection_Package__c> specializedIPs = new List<IETRS_Inspection_Package__c>();
        for (Account entity : testEntityAccts) {
            Set<String> orgClassifications = classificationsByOrgId.get(
                entity.IETRS_OrganizationofRegEntity__c
            );
            for (String orgClassification : orgClassifications) {
                if (
                    !IETRS_SpecializedInspScheduleServices.SUBTYPE_BY_PRODUCT.containsKey(
                        orgClassification
                    )
                ) {
                    continue;
                }
                for (
                    String subtype : IETRS_SpecializedInspScheduleServices.SUBTYPE_BY_PRODUCT.get(
                        orgClassification
                    )
                ) {
                    if (specializedIPs.size() > 1) {
                        break;
                    }
                    specializedIPs.add(
                        new IETRS_Inspection_Package__c(
                            IETRS_Inspection_Type__c = 'Specialized',
                            IETRS_Inspection_Sub_Type__c = subtype,
                            IETRS_Organization__c = entity.IETRS_OrganizationofRegEntity__c,
                            IETRS_Unit_Name__c = entity.ParentId,
                            RecordTypeId = inspPackageRecordTypeId
                        )
                    );
                }
            }
        }

        insert specializedIPs;

        // for each new Ip, create inspection for all entities associated with org
        List<IETRS_Inspection__c> specializedInspections = new List<IETRS_Inspection__c>();
        List<IETRS_InspSchedule__c> carryoverSchedules = new List<IETRS_InspSchedule__c>();
        for (IETRS_Inspection_Package__c ip : specializedIPs) {
            Account entity = entityByUnitId.get(ip.IETRS_Unit_Name__c);
            Id entityIdToUse = nonPhysicalEntityIdByOrgId.get(
                entity.IETRS_OrganizationofRegEntity__c
            );
            System.debug(inspectionRecordTypeByAccountType.get(entity.Type));
            if (!inspectionRecordTypeByAccountType.containsKey(entity.Type)) {
                continue;
            }
            // use the regulated entity if LDTC or GDTC
            if (
                ip.IETRS_Inspection_Sub_Type__c ==
                IETRS_SpecializedInspScheduleServices.LDTC ||
                ip.IETRS_Inspection_Sub_Type__c ==
                IETRS_SpecializedInspScheduleServices.GDTC
            ) {
                entityIdToUse = entity.Id;
            }
            specializedInspections.add(
                new IETRS_Inspection__c(
                    IETRS_Inspection_Package__c = ip.Id,
                    IETRS_Inspection_Start_Date_And_Time__c = System.now()
                        .addYears(-1),
                    IETRS_Regulated_Entity__c = entityIdToUse,
                    IETRS_Inspection_Status__c = 'Approved',
                    RecordTypeId = inspectionRecordTypeByAccountType.get(
                        entity.Type
                    )
                )
            );
            carryoverSchedules.add(
                new IETRS_InspSchedule__c(
                    IETRS_Inspection_Business_Area__c = 'Pipeline Safety',
                    IETRS_Inspection_Sub_Type__c = ip.IETRS_Inspection_Sub_Type__c,
                    IETRS_Risk_Factors__c = 'F',
                    IETRS_Type__c = IETRS_SpecializedInspScheduleServices.PIPELINE_SPCL_SCH,
                    IETRS_Inspection_Year__c = String.valueOf(
                        System.today().addYears(-1).year()
                    ),
                    IETRS_Organization__c = entity.IETRS_OrganizationofRegEntity__c,
                    IETRS_Regulated_Entity__c = entityIdToUse,
                    IETRS_Region__c = countryGroupId,
                    IETRS_Specialized_Schedule_Business_Type__c = getEntityClassification(
                        entity.IETRS_Product_Class__c,
                        entity.Type
                    )
                )
            );
        }
        system.debug('specializedInspections ' + specializedInspections.size());
        insert specializedInspections;
        insert carryoverSchedules;
    }

    public List<IETRS_County__c> createCounties() {
        List<IETRS_County__c> result = new List<IETRS_County__c>();
        for (String countyName : testCounties) {
            result.add(new IETRS_County__c(Name = countyName));
        }
        insert result;
        return result;
    }

    @future
    public static void createUsers(
        String profileName,
        String roleName,
        Integer numberOfUsers
    ) {
        Profile p = [SELECT Id FROM Profile WHERE Name = :profileName LIMIT 1];
        UserRole r;
        if (roleName != null) {
            r = [SELECT Id FROM UserRole WHERE Name = :roleName LIMIT 1];
        }
        List<User> users = new List<User>();
        while (users.size() < numberOfUsers) {
            Blob b = Crypto.GenerateAESKey(128);
            String h = EncodingUtil.ConvertTohex(b);
            String uid = h.SubString(0, 8);
            User u = new User(
                Alias = uid,
                Email = uid + '@testuser.com',
                EmailEncodingKey = 'UTF-8',
                LastName = 'Testing',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                ProfileId = p.Id,
                TimeZoneSidKey = 'America/Chicago',
                UserName = uid + '@testuser.com'
            );
            if (r != null) {
                u.UserRoleId = r.Id;
            }
            users.add(u);
        }
        insert users;
    }

    public static List<Schema.PicklistEntry> getPicklistValues(
        String objectName,
        String fieldName
    ) {
        Schema.DescribeSObjectResult objectDescribe = Schema.getGlobalDescribe()
            .get(objectName)
            .getDescribe();
        Map<String, Schema.SObjectField> fields = objectDescribe.fields.getMap();
        Schema.DescribeFieldResult fieldDescribe = fields.get(fieldName)
            .getDescribe();
        return fieldDescribe.getPicklistValues();
    }

    private Object getFieldValue(Integer x, List<Object> fieldOptions) {
        if (fieldOptions == null)
            return null;
        return fieldOptions[Math.mod(x, fieldOptions.size())];
    }

    private String getEntityClassification(String productClass, String type) {
        String result = productClass == 'Liquid'
            ? productClass
            : productClass + type;
        return result;
    }

    public void creatScheduleConfigData() {
        final Map<String, List<String>> riskTypesByCode = new Map<String, List<String>>{
            'A' => new List<String>{ 'Distribution', 'Master Meter' },
            'B' => new List<String>{
                'Distribution',
                'Master Meter',
                'Gas Transmission'
            },
            'C' => new List<String>{ 'Distribution' },
            'D' => new List<String>{ 'Distribution' },
            'E' => new List<String>{ 'Distribution' },
            'F' => new List<String>{ 'Gas Transmission', 'Hazardous Liquid' },
            'G' => new List<String>{ 'Distribution' },
            'I' => new List<String>{ 'Distribution', 'Master Meter' },
            'L' => new List<String>{ 'Distribution' },
            'M' => new List<String>{ 'Distribution' },
            'N' => new List<String>{ 'Distribution' },
            'O' => new List<String>{ 'Distribution' },
            'P' => new List<String>{ 'Distribution' },
            'U' => new List<String>{ 'Distribution' },
            'V' => new List<String>{ 'Distribution' },
            'Y' => new List<String>{ 'Distribution' },
            'Z' => new List<String>{ 'Distribution' }
        };
        final Map<String, String> riskCodeByCode = new Map<String, String>{
            'A' => 'A-PVC Pipe',
            'B' => 'B-Bare Pipe',
            'C' => 'C-Customer Count',
            'D' => 'D-Unrepaired Leaks',
            'E' => 'E-Incidents',
            'F' => 'F-HCAs',
            'G' => 'G-Pipe Size',
            'I' => 'I-Cast Iron',
            'L' => 'L-Leakage',
            'M' => 'M-System Type Municipal',
            'N' => 'N-New Construction',
            'O' => 'O-Outside Inspection Frequency',
            'P' => 'P-Location',
            'U' => 'U-Unevaluated System',
            'V' => 'V-Violation Count',
            'Y' => 'Y-Carry-Over Inspection from Last Year',
            'Z' => 'Z-Off Shore'
        };

        Id scheduleGenerationRecordTypeId = Schema.SObjectType.IETRS_InspSchedConfig__c.getRecordTypeInfosByDeveloperName()
            .get('Schedule_Generation')
            .getRecordTypeId();
        Id riskFactorRecordTypeId = Schema.SObjectType.IETRS_InspSchedConfig__c.getRecordTypeInfosByDeveloperName()
            .get(IETRS_SpecializedInspScheduleServices.RECTYPE_RISK_FACTOR)
            .getRecordTypeId();
        final String BUSINESS_AREA = 'Pipeline Safety';
        // create risk factors and schedule generation inspection schedule config records
        List<IETRS_InspSchedConfig__c> scheduleConfigs = new List<IETRS_InspSchedConfig__c>{
            new IETRS_InspSchedConfig__c(
                IETRS_Priority_Code__c = IETRS_SpecializedInspScheduleServices.O,
                IETRS_Business_Area__c = BUSINESS_AREA,
                IETRS_Regulated_Entity_Type__c = 'All (for Specialized)',
                IETRS_Schedule_Type__c = IETRS_SpecializedInspScheduleServices.PIPELINE_SPCL_SCH,
                IETRS_Condition_Operator__c = 'Greater Than',
                IETRS_Value_One__c = 1,
                IETRS_Value_Two__c = 0,
                IETRS_Priority__c = '1',
                RecordTypeId = riskFactorRecordTypeId
            ),
            new IETRS_InspSchedConfig__c(
                IETRS_Priority_Code__c = IETRS_SpecializedInspScheduleServices.Y,
                IETRS_Business_Area__c = BUSINESS_AREA,
                IETRS_Regulated_Entity_Type__c = 'All (for Specialized)',
                IETRS_Schedule_Type__c = IETRS_SpecializedInspScheduleServices.PIPELINE_SPCL_SCH,
                IETRS_Condition_Operator__c = 'Less Than',
                IETRS_Value_One__c = 10000,
                IETRS_Value_Two__c = 0,
                IETRS_Priority__c = '3',
                RecordTypeId = riskFactorRecordTypeId
            ),
            new IETRS_InspSchedConfig__c(
                IETRS_Priority_Code__c = IETRS_SpecializedInspScheduleServices.F,
                IETRS_Business_Area__c = BUSINESS_AREA,
                IETRS_Regulated_Entity_Type__c = 'All (for Specialized)',
                IETRS_Schedule_Type__c = IETRS_SpecializedInspScheduleServices.PIPELINE_SPCL_SCH,
                IETRS_Condition_Operator__c = 'Less Than',
                IETRS_Value_One__c = 2000,
                IETRS_Value_Two__c = 0,
                IETRS_Priority__c = '3',
                RecordTypeId = riskFactorRecordTypeId
            ),
            new IETRS_InspSchedConfig__c(
                IETRS_Priority_Code__c = IETRS_SpecializedInspScheduleServices.T,
                IETRS_Business_Area__c = BUSINESS_AREA,
                IETRS_Regulated_Entity_Type__c = 'All (for Specialized)',
                IETRS_Schedule_Type__c = IETRS_SpecializedInspScheduleServices.PIPELINE_SPCL_SCH,
                IETRS_Condition_Operator__c = 'Less Than',
                IETRS_Value_One__c = 10000,
                IETRS_Value_Two__c = 0,
                IETRS_Priority__c = '1',
                RecordTypeId = riskFactorRecordTypeId
            ),
            new IETRS_InspSchedConfig__c(
                IETRS_Priority_Code__c = IETRS_SpecializedInspScheduleServices.N,
                IETRS_Business_Area__c = BUSINESS_AREA,
                IETRS_Regulated_Entity_Type__c = 'All (for Specialized)',
                IETRS_Schedule_Type__c = IETRS_SpecializedInspScheduleServices.PIPELINE_SPCL_SCH,
                IETRS_Condition_Operator__c = 'Less Than',
                IETRS_Value_One__c = 2000,
                IETRS_Value_Two__c = 0,
                IETRS_Priority__c = '1',
                RecordTypeId = riskFactorRecordTypeId
            ),
            new IETRS_InspSchedConfig__c(
                IETRS_Priority_Code__c = IETRS_SpecializedInspScheduleServices.U_RISK,
                IETRS_Business_Area__c = BUSINESS_AREA,
                IETRS_Regulated_Entity_Type__c = 'All (for Specialized)',
                IETRS_Schedule_Type__c = IETRS_SpecializedInspScheduleServices.PIPELINE_SPCL_SCH,
                IETRS_Condition_Operator__c = 'Greater Than',
                IETRS_Value_One__c = 0,
                IETRS_Value_Two__c = 0,
                IETRS_Priority__c = '1',
                RecordTypeId = riskFactorRecordTypeId
            ),
            new IETRS_InspSchedConfig__c(
                IETRS_Business_Area__c = BUSINESS_AREA,
                IETRS_Year__c = String.valueOf(System.today().year()),
                IETRS_Schedule_Type__c = 'Pipeline Specialized Schedule',
                IETRS_Regulated_Entity_Type__c = 'All (for Specialized)',
                RecordTypeId = scheduleGenerationRecordTypeId
            ),
            new IETRS_InspSchedConfig__c(
                IETRS_Business_Area__c = BUSINESS_AREA,
                IETRS_Year__c = String.valueOf(System.today().year()),
                IETRS_Schedule_Type__c = 'Pipeline Routine Schedule',
                RecordTypeId = scheduleGenerationRecordTypeId
            )
        };
        for (String code : riskCodeByCode.keySet()) {
            for (String riskType : riskTypesByCode.get(code)) {
                scheduleConfigs.add(
                    new IETRS_InspSchedConfig__c(
                        RecordTypeId = riskFactorRecordTypeId,
                        IETRS_Schedule_Type__c = 'Pipeline Routine Schedule',
                        IETRS_Regulated_Entity_Type__c = riskType,
                        IETRS_Priority_Code__c = riskCodeByCode.get(code),
                        IETRS_Business_Area__c = BUSINESS_AREA,
                        IETRS_Condition_Operator__c = 'Less Than',
                        IETRS_Value_One__c = 10000,
                        IETRS_Value_Two__c = 0,
                        IETRS_Priority__c = '1'
                    )
                );
            }
        }
        insert scheduleConfigs;
    }
}