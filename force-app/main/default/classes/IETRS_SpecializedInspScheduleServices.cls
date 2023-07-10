public class IETRS_SpecializedInspScheduleServices {
    /*******************************************************************************************************
     * Class Constants
     */
    public static final String INSP_TYPE = 'Specialized';
    public static final String RECTYPE_RISK_FACTOR = 'Risk_Factors_Setting';
    public static final String PIPELINE_SPCL_SCH = 'Pipeline Specialized Schedule';
    public static final String PIPELINE_ROUTINE_SCH = 'Pipeline Routine Schedule';
    public static final String CONSTRUCTION = 'Construction';
    public static final List<String> RECTYPES_REG_ENTITY = new List<String>{
        'Regulated_Entity_AFS',
        'Regulated_Entity_OG',
        'Regulated_Entity_PS',
        'Regulated_Entity_SMRD'
    };
    public static final Set<String> EXCLUDED_JURISDICTION_TYPES = new Set<String>{
        'TAC Regulated Gathering',
        'Non-jurisdictional'
    };

    /**
     * list of specialized subtypes: 'Complaint', 'Compliance Agreement', 'DIMP', 'ECDA Request', 'Gas Control Room', 'Gas Damage Prevention Activities',
     * 'Gas Design, Testing, Constr', 'Gas Drug and Alcohol', 'Gas Integrity Mgmt', 'Gas O and M Proc', 'Gas Operator Qual', 'Gas Public Awareness',
     * 'Incident', 'Liquid Control Room', 'Liquid Damage Prevention Activities', 'Liquid Design, Testing, Constr', 'Liquid Drug and Alcohol',
     * 'Liquid Integrity Mgmt', 'Liquid O and M Proc', 'Liquid Operator Qual', 'Liquid Public Awareness', 'New Construction', 'On Site Oper. Trng',
     * 'Selected Topics', 'Waiver', 'Extension Request', 'Waiver Request', 'Field IM'
     */
    // Exclude the inactive systems/evaluations org
    public static final Set<String> EXCLUDED_ORG_IDS = new Set<String>{
        '1582'
    };
    public static final Set<String> EXCLUDED_STATUSES = new Set<String>{
        'Abandoned'
    };

    public static final String GCR = 'Gas Control Room';
    public static final String GDPA = 'Gas Damage Prevention Activities';
    public static final String GDTC = 'Gas Design, Testing, Constr';
    public static final String GDA = 'Gas Drug and Alcohol';
    public static final String GIM = 'Gas Integrity Mgmt';
    public static final String GOQ = 'Gas Operator Qual';
    public static final String GPA = 'Gas Public Awareness';
    public static final String GOMP = 'Gas O and M Proc';
    public static final String LCR = 'Liquid Control Room';
    public static final String LDPA = 'Liquid Damage Prevention Activities';
    public static final String LDTC = 'Liquid Design, Testing, Constr';
    public static final String LDA = 'Liquid Drug and Alcohol';
    public static final String LIM = 'Liquid Integrity Mgmt';
    public static final String LOQ = 'Liquid Operator Qual';
    public static final String LPA = 'Liquid Public Awareness';
    public static final String LOMP = 'Liquid O and M Proc';
    public static final String DIMP = 'DIMP';
    public static final String ENTITY_CODE = 'Y-Company System (Non-Physical)';

    public static final String GAS_TRANS = 'GasTransmission';
    public static final String GAS_DIS = 'GasDistribution';
    public static final String LIQUID = 'Liquid';
    public static final String LNG = 'GasLiquifiedNaturalGas';

    public static final Map<String, set<String>> SUBTYPE_BY_PRODUCT = new Map<String, set<String>>{
        GAS_TRANS => new Set<String>{ GCR, GDPA, GDA, GIM, GOQ, GPA, GOMP },
        GAS_DIS => new Set<String>{ DIMP, GCR, GDPA, GDA, GOQ, GPA, GOMP },
        LIQUID => new Set<String>{ LCR, LDPA, LDA, LIM, LOQ, LPA, LOMP },
        LNG => new Set<String>{ GOMP, GDA, GOQ }
    };

    public static final String O = 'O-Outside Inspection Frequency';
    public static final String Y = 'Y-Carry-Over Inspection from Last Year';
    public static final String F = 'F-HCAs';
    public static final String T = 'T-Total Miles of PIpe';
    public static final String N = 'N-NEW CONSTRUCTION';
    public static final String U_RISK = 'U-Unevaluated System';

    final Set<String> COMPLETE_STATUSES = new Set<String>{
        'Complete',
        'Closed',
        'Approved'
    };

    /*******************************************************************************************************
     * Class Properties
     */

    Map<String, String> subtypeByKey {
        get {
            if (this.subtypeByKey == null) {
                Map<String, String> result = new Map<String, String>();
                for (String productKey : SUBTYPE_BY_PRODUCT.keySet()) {
                    for (String subtype : SUBTYPE_BY_PRODUCT.get(productKey)) {
                        result.put(subType.deleteWhitespace(), subType);
                    }
                }
                this.subtypeByKey = result;
            }
            return this.subtypeByKey;
        }
        set;
    }

    /*
     * @description List of organizations to check
     */
    List<Account> organizations;

    /*
     * @description List of organizations in scope that meet the criteria for potentially
     *  creating inspection service records
     */
    List<Account> validOrganizations {
        get {
            if (this.validOrganizations == null) {
                List<Account> result = new List<Account>();
                for (Account acc : organizations) {
                    if (
                        productTypesByOrgId.containsKey(acc.Id) &&
                        nonPhysicalEntityByOrgId.containsKey(acc.Id) // has matching product type // has a non physical entity
                    ) {
                        result.add(acc);
                    }
                }
                this.validOrganizations = result;
            }
            return this.validOrganizations;
        }
        set;
    }

    /*
     * @description Total miles of pipe grouped by product type and org id
     */
    Map<Id, Map<String, Decimal>> totalMilesByProductTypeByOrgId = new Map<Id, Map<String, Decimal>>();

    /*
     * @description Latest inspection date by product type and org id
     */
    Map<Id, Map<String, Map<String, IETRS_Inspection__c>>> lastInspBySubtypeByTypeByOrgId = new Map<Id, Map<String, Map<String, IETRS_Inspection__c>>>();

    /*
     * @description Prior year schedule subtypes and new priority for schedules
     *  that weren't inspected last year. Used to determine if the Y risk factor
     *  should be applied.
     */
    Map<Id, Map<String, Map<String, Integer>>> carryOverScheduleMapByOrgId;

    /*
     * @description Prior year new carryover priority values for construction entities.
     */
    Map<Id, Integer> constructionCarryOverPriorityByEntityId = new Map<Id, Integer>();

    /*
     * @description Map of product types found on entities by org id
     */
    Map<Id, Set<String>> productTypesByOrgId = new Map<Id, Set<String>>();

    /*
     * @description Map of non-physical entity by org id
     */
    Map<Id, Account> nonPhysicalEntityByOrgId;

    /*
     * @description Map of risk map by org id
     * @example { orgId => { 'GasTransmission' => 'O', 'GasDistribution' => 'T', 'Liquid' => 'T'} }
     */
    Map<Id, Map<String, Map<String, String>>> riskCodesBySubtypeByTypeByOrgId = new Map<Id, Map<String, Map<String, String>>>();

    /*
     * @description Map of org by lowest risk priority for all found risk factors
     */
    Map<Id, Map<String, Integer>> lowestRiskPriorityBySubtypeByOrgId = new Map<Id, Map<String, Integer>>();

    /*
     * @description The inspection config record that triggers this process
     */
    IETRS_InspSchedConfig__c configRecord;

    /**
     * @description List of risk config records grouped by code
     */
    Map<String, List<IETRS_InspSchedConfig__c>> risksByCode;

    /*
     * @description The country group id to assign to the inspection schedule
     */
    Id countryGroupId {
        get {
            if (this.countryGroupId == null) {
                this.countryGroupId = [
                    SELECT Id, name
                    FROM IETRS_County_Group__c
                    WHERE Name = '00-Statewide'
                ]
                .Id;
            }
            return this.countryGroupId;
        }
        set;
    }

    /*
     * @description Map of existing schedule sub-types with related packages by product type by org or entity id.
     */
    Map<Id, Map<String, Set<String>>> existingSubtypesByProductTypeByAccountId = new Map<Id, Map<String, Set<String>>>();

    /*
     * @description List of existing schedule sub-types with related packages by org.
     */
    List<IETRS_InspSchedule__c> schedulesToDelete = new List<IETRS_InspSchedule__c>();

    Map<Id, String> entityIdByProductType = new Map<Id, String>();

    /*******************************************************************************************************
     * Class Methods
     */

    /**
     * @description Default Constructor
     * @param organizations List of organizations to check
     * @param configRecord The inspection config record that triggered this process
     */
    public IETRS_SpecializedInspScheduleServices(
        List<Account> organizations,
        IETRS_InspSchedConfig__c configRecord
    ) {
        // set config and orgs
        this.configRecord = configRecord;
        this.organizations = organizations;

        // get relevant product types and find the non-physical entity for each org
        setProductTypeMaps(organizations, configRecord.IETRS_Business_Area__c);
        nonPhysicalEntityByOrgId = getNonPhysicalEntityByOrgId(
            productTypesByOrgId.keySet()
        );
        setInspectionMaps();

        risksByCode = buildRiskMap(this.configRecord.IETRS_Business_Area__c);
        // continue only if there are valid orgs
        if (!validOrganizations.isEmpty()) {
            // Determine if any existing schedules should be deleted and recreated, or if they exist and should be ignored
            buildScheduleMap();
            // List of organization ids who have not had 'Pipeline Routine Schedule' inspection this year
            carryOverScheduleMapByOrgId = getCarryOverScheduleMapByOrgId(
                productTypesByOrgId.keySet(),
                Integer.valueOf(configRecord.IETRS_Year__c)
            );
            // Determine which risk factors are relevant for each valid org
            setRiskFactors();
        }
    }

    /*
     * @description Create the inspection schedule records for the organizations that meet
     *  the criteria
     */
    public void createInspectionSchedules() {
        Map<String, IETRS_InspSchedule__c> scheduleByOrgSubType = new Map<String, IETRS_InspSchedule__c>();
        List<IETRS_InspSchedule__c> newSchedules = new List<IETRS_InspSchedule__c>();
        // Create schedules for all risk codes besides New Construction
        for (Account org : this.validOrganizations) {
            // only create schedules if the organization has a risk code associated with it
            Boolean hasCurrentRiskCodes = riskCodesBySubtypeByTypeByOrgId.containsKey(
                org.Id
            );
            Boolean hasCarryOverSchedules = carryOverScheduleMapByOrgId.containsKey(
                org.Id
            );
            System.debug('hasCurrentRiskCodes ' + hasCurrentRiskCodes);
            System.debug('hasCarryOverSchedules ' + hasCarryOverSchedules);
            if (hasCurrentRiskCodes || hasCarryOverSchedules) {
                // The product types associated with this org
                Set<String> productTypes = new Set<String>();
                if (hasCurrentRiskCodes) {
                    productTypes.addAll(
                        riskCodesBySubtypeByTypeByOrgId.get(org.Id).keySet()
                    );
                }
                if (hasCarryOverSchedules) {
                    productTypes.addAll(
                        carryOverScheduleMapByOrgId.get(org.Id).keySet()
                    );
                }
                Account nonPhysicalEntity = nonPhysicalEntityByOrgId.get(
                    org.Id
                );

                for (String productType : productTypes) {
                    Set<String> subTypes = new Set<String>();
                    // Set an initial value of 99. If there are only current year risk codes,
                    //  the value is overwritten by the lowest priority for the applicable factors.
                    //  If there are carryover schedules, set the priority to the lowest value.
                    if (hasCurrentRiskCodes) {
                        // if there are current year risk codes to add, include all sub-types
                        // whether there are carryover schedules or not
                        subTypes = SUBTYPE_BY_PRODUCT.get(productType);
                    } else {
                        // if there are only carryover schedules and no current year risk codes,
                        // only create new schedules for sub-types on the carryover schedules
                        subTypes = carryOverScheduleMapByOrgId.get(org.Id)
                            .get(productType)
                            .keySet();
                    }
                    System.debug(subTypes);
                    for (String subType : subTypes) {
                        Integer newPriority = 99;
                        if (
                            lowestRiskPriorityBySubtypeByOrgId.containsKey(
                                org.Id
                            ) &&
                            lowestRiskPriorityBySubtypeByOrgId.get(org.Id)
                                .containsKey(subType)
                        ) {
                            newPriority = lowestRiskPriorityBySubtypeByOrgId.get(
                                    org.Id
                                )
                                .get(subType);
                        }
                        // check for specific conditions when a schedule should not be created
                        Boolean createSchedule = shouldCreateSchedule(
                            org,
                            productType,
                            subType
                        );
                        if (createSchedule) {
                            String subtypeKey = subType.deleteWhitespace();
                            IETRS_InspSchedule__c schedule = new IETRS_InspSchedule__c();
                            IETRS_Inspection__c lastInspection = lastInspBySubtypeByTypeByOrgId.get(
                                    org.Id
                                )
                                ?.get(productType)
                                ?.get(subType);
                            schedule.IETRS_Inspection_Business_Area__c = configRecord.IETRS_Business_Area__c;
                            schedule.IETRS_Inspection_Sub_Type__c = subtypeByKey.containsKey(
                                    subType
                                )
                                ? subtypeByKey.get(subType)
                                : subType;
                            schedule.IETRS_Risk_Factors__c = '';
                            schedule.IETRS_Type__c = PIPELINE_SPCL_SCH;
                            schedule.IETRS_Inspection_Year__c = configRecord.IETRS_Year__c;
                            System.debug('inspection map has key?');
                            System.debug(
                                lastInspBySubtypeByTypeByOrgId.containsKey(
                                    org.Id
                                )
                            );
                            System.debug(
                                'inspection map has key and product type? ' +
                                subType
                            );

                            schedule.IETRS_Last_Inspection__c = lastInspection
                                ?.Id;
                            schedule.IETRS_Last_Inspection_Status__c = lastInspection
                                ?.IETRS_Inspection_Status__c;
                            schedule.IETRS_Last_Inspection_Date__c = lastInspection
                                ?.IETRS_Inspection_Start_Date_and_Time__c.date();
                            // Apply the current year risk codes and lowest priority among applicable codes
                            if (
                                hasCurrentRiskCodes &&
                                riskCodesBySubtypeByTypeByOrgId.get(org.Id)
                                    .containsKey(productType) &&
                                riskCodesBySubtypeByTypeByOrgId.get(org.Id)
                                    .get(productType)
                                    .containsKey(subType)
                            ) {
                                schedule.IETRS_Risk_Factors__c += riskCodesBySubtypeByTypeByOrgId.get(
                                        org.Id
                                    )
                                    .get(productType)
                                    .get(subType);
                                schedule.IETRS_Priority__c = String.valueOf(
                                    newPriority
                                );
                            }
                            // If there's a carryover schedule for this sub-type, append the Y risk factor
                            //  and set the priority to the lowest value.
                            if (
                                hasCarryOverSchedules &&
                                carryOverScheduleMapByOrgId.get(org.Id)
                                    .containsKey(productType) &&
                                carryOverScheduleMapByOrgId.get(org.Id)
                                    .get(productType)
                                    .containsKey(subtypeKey)
                            ) {
                                schedule.IETRS_Risk_Factors__c += 'Y';
                                schedule.IETRS_Priority__c = String.valueOf(
                                    Math.min(
                                        newPriority,
                                        carryOverScheduleMapByOrgId.get(org.Id)
                                            .get(productType)
                                            .get(subtypeKey)
                                    )
                                );
                            }
                            schedule.IETRS_Organization__c = org.Id;
                            schedule.IETRS_Regulated_Entity__c = nonPhysicalEntity.Id;
                            schedule.IETRS_Region__c = countryGroupId;
                            schedule.IETRS_Inspection_Schedule_Config__c = configRecord.Id;
                            schedule.IETRS_Specialized_Schedule_Business_Type__c = productType;
                            newSchedules.add(schedule);
                        }
                    }
                }
            }
        }

        // Create the New Construction schedules for each matching regulated entity
        // This is handled differently - the schedule is related to each physical entity with
        // the Construction status, as opposed to the non-physical entity for the org.
        List<IETRS_InspSchedule__c> newConstructionSchedules = getNewConstructionSchedules();
        newSchedules.addAll(newConstructionSchedules);
        System.debug('newSchedules size' + newSchedules.size());
        if (!schedulesToDelete.isEmpty()) {
            delete schedulesToDelete;
        }
        if (!newSchedules.isEmpty()) {
            //special handling for the strange error that Liquid Public Awareness drops one white space in some circumstances
            for (IETRS_InspSchedule__c nS : newSchedules) {
                if (
                    nS.IETRS_Inspection_Sub_Type__c == 'LiquidPublic Awareness'
                ) {
                    nS.IETRS_Inspection_Sub_Type__c = 'Liquid Public Awareness';
                }
                System.debug(
                    'risk factors right before insert: ' +
                    nS.IETRS_Risk_Factors__c
                );
            }
            insert newSchedules;
        }
    }

    /**
     * @description Set up the inspection maps grouped by organization
     */
    private void setInspectionMaps() {
        for (IETRS_Inspection__c ins : [
            SELECT
                Id,
                IETRS_Regulated_Entity__c,
                IETRS_Regulated_Entity__r.IETRS_OrganizationofRegEntity__c,
                IETRS_Regulated_Entity__r.IETRS_Entity_Code__c,
                IETRS_Inspection_Start_Date_And_Time__c,
                IETRS_Inspection_Status__c,
                IETRS_Inspection_Package__r.IETRS_Inspection_Sub_Type__c
            FROM IETRS_Inspection__c
            WHERE
                IETRS_Inspection_Start_Date_And_Time__c != NULL
                AND IETRS_Inspection_Status__c IN :COMPLETE_STATUSES
                AND IETRS_Inspection_Package__r.IETRS_Inspection_Type__c = :INSP_TYPE
                AND ((IETRS_Inspection_Package__r.IETRS_Inspection_Sub_Type__c IN (
                    :LDTC,
                    :GDTC
                )
                AND IETRS_Regulated_Entity__c IN :entityIdByProductType.keySet())
                OR IETRS_Regulated_Entity__c IN :nonPhysicalEntityByOrgId.values())
            ORDER BY IETRS_Inspection_Start_Date_And_Time__c ASC
        ]) {
            Id orgId = ins.IETRS_Regulated_Entity__r
                ?.IETRS_OrganizationofRegEntity__c;
            String subType = ins.IETRS_Inspection_Package__r
                ?.IETRS_Inspection_Sub_Type__c;
            if (orgId == null || subType == null) {
                continue;
            }
            System.debug('=== INSPECTION ITERATION ===');
            if (
                ins.IETRS_Regulated_Entity__r.IETRS_Entity_Code__c ==
                ENTITY_CODE && productTypesByOrgId.containsKey(orgId)
            ) {
                // if this is a system, check product categories associated with the org.
                // then iterate over each category and check if the subtype belongs
                // in the category.
                for (String productKey : productTypesByOrgId.get(orgId)) {
                    setLastInspectionMap(orgId, productKey, subType, ins);
                }
            } else {
                // if it's not a system entity, get the product category from the existing map
                String productKey = entityIdByProductType.get(
                    ins.IETRS_Regulated_Entity__c
                );
                setLastInspectionMap(orgId, productKey, subType, ins);
            }
        }
    }

    private void setLastInspectionMap(
        Id orgId,
        String productKey,
        String subType,
        IETRS_Inspection__c ins
    ) {
        System.debug(orgId);
        System.debug(productKey);
        System.debug(subType);
        if (productKey == null) {
            // exit early if no productKey is passed in
            return;
        }
        if (!SUBTYPE_BY_PRODUCT.get(productKey).contains(subType)) {
            // exit early if this subtype doesn't belong to this product category
            return;
        }

        // set org id as outermost key
        if (!lastInspBySubtypeByTypeByOrgId.containsKey(orgId)) {
            lastInspBySubtypeByTypeByOrgId.put(
                orgId,
                new Map<String, Map<String, IETRS_Inspection__c>>()
            );
        }

        // set productKey as key under orgId
        if (
            !lastInspBySubtypeByTypeByOrgId.get(orgId).containsKey(productKey)
        ) {
            lastInspBySubtypeByTypeByOrgId.get(orgId)
                .put(productKey, new Map<String, IETRS_Inspection__c>());
        }

        // set subtype as key under productKey
        lastInspBySubtypeByTypeByOrgId.get(orgId)
            .get(productKey)
            .put(subType, ins);
    }

    /**
     * @description Check if the schedule for a given org, product type and sub
     *   type should be created
     * @param The organization the schedule is related to
     * @param The product type (GasTransmission, GasDistribution, Liquid)
     * @param The sub type of the schedule
     * @return True if the schedule should be created
     */
    private Boolean shouldCreateSchedule(
        Account org,
        String productType,
        String subType
    ) {
        // schedule with this product type and subtype and a related IP already exists
        Boolean alreadyExists =
            existingSubtypesByProductTypeByAccountId.containsKey(org.Id) &&
            existingSubtypesByProductTypeByAccountId.get(org.Id)
                .containsKey(productType) &&
            existingSubtypesByProductTypeByAccountId.get(org.Id)
                .get(productType)
                .contains(subType);
        if (alreadyExists) {
            return false;
        }
        // don't create a schedule if there are risk factors assocaited with the subtype
        Boolean noRiskFactors = !(riskCodesBySubtypeByTypeByOrgId.containsKey(
            org.Id
        ) &&
        riskCodesBySubtypeByTypeByOrgId.get(org.Id).containsKey(productType) &&
        riskCodesBySubtypeByTypeByOrgId.get(org.Id)
            .get(productType)
            .containsKey(subType));
        if (noRiskFactors) {
            return false;
        }
        // don't create schedule if subType is GCR or LCR and IETRS_Jurisdictional_Control_Room__c is false
        Boolean noControlRoom =
            (subType == GCR || subType == LCR) &&
            !org.IETRS_Jurisdictional_Control_Room__c;
        if (noControlRoom) {
            return false;
        }
        // If none of the above conditions are met, return true
        return true;
    }

    private List<IETRS_InspSchedule__c> getNewConstructionSchedules() {
        List<IETRS_InspSchedule__c> result = new List<IETRS_InspSchedule__c>();
        // Check if there's a new construction risk factor
        if (risksByCode.containsKey(N) && !risksByCode.get(N).isEmpty()) {
            // Get the highest priority
            String riskPriority = risksByCode.get(N)[0].IETRS_Priority__c;
            for (
                Account entity : [
                    SELECT
                        Id,
                        Type,
                        IETRS_Organization_Parent__c,
                        IETRS_OrganizationofRegEntity__c,
                        IETRS_Region__c,
                        IETRS_Product_Class__c,
                        IETRS_Latest_Inspection__c,
                        IETRS_Latest_Inspection__r.IETRS_Inspection_Status__c,
                        IETRS_Latest_Inspection__r.IETRS_Inspection_Start_Date_and_Time__c,
                        IETRS_Latest_Inspection__r.CreatedDate
                    FROM Account
                    WHERE
                        RecordType.DeveloperName IN :RECTYPES_REG_ENTITY
                        AND IETRS_OrganizationofRegEntity__c IN :organizations
                        AND Id NOT IN :existingSubtypesByProductTypeByAccountId.keySet()
                        AND IETRS_Jurisdiction__c NOT IN :EXCLUDED_JURISDICTION_TYPES
                        AND IETRS_Product_Class__c != NULL
                        // current status is construction or last year's new construction schedule wasn't started
                        AND (IETRS_Status__c = :CONSTRUCTION
                        OR Id IN :constructionCarryOverPriorityByEntityId.keySet())
                ]
            ) {
                String productType = entity.IETRS_Product_Class__c;
                String subType;
                if (entity.IETRS_Product_Class__c == 'Gas') {
                    subType = GDTC;
                    productType += entity.Type?.deleteWhiteSpace();
                } else if (entity.IETRS_Product_Class__c == 'Liquid') {
                    subType = LDTC;
                } else {
                    continue;
                }
                IETRS_InspSchedule__c schedule = new IETRS_InspSchedule__c();
                IETRS_Inspection__c lastInspection = lastInspBySubtypeByTypeByOrgId.get(
                        entity.IETRS_OrganizationofRegEntity__c
                    )
                    ?.get(productType)
                    ?.get(subType);
                schedule.IETRS_Inspection_Business_Area__c = configRecord.IETRS_Business_Area__c;
                schedule.IETRS_Inspection_Sub_Type__c = subType;
                schedule.IETRS_Risk_Factors__c = N.left(1);
                schedule.IETRS_Priority__c = riskPriority;
                // if there's a carryover N schedule, append Y and use the lowest priority
                if (
                    constructionCarryOverPriorityByEntityId.containsKey(
                        entity.Id
                    )
                ) {
                    schedule.IETRS_Risk_Factors__c += 'Y';
                    schedule.IETRS_Priority__c = String.valueOf(
                        Math.min(
                            Integer.valueOf(riskPriority),
                            constructionCarryOverPriorityByEntityId.get(
                                entity.Id
                            )
                        )
                    );
                }
                schedule.IETRS_Type__c = PIPELINE_SPCL_SCH;
                schedule.IETRS_Inspection_Year__c = configRecord.IETRS_Year__c;
                schedule.IETRS_Organization__c = entity.IETRS_OrganizationofRegEntity__c;
                schedule.IETRS_Regulated_Entity__c = entity.Id;
                schedule.IETRS_Region__c = entity.IETRS_Region__c;
                schedule.IETRS_Last_Inspection__c = lastInspection?.Id;
                schedule.IETRS_Last_Inspection_Status__c = lastInspection
                    ?.IETRS_Inspection_Status__c;
                schedule.IETRS_Last_Inspection_Date__c = lastInspection
                    ?.IETRS_Inspection_Start_Date_and_Time__c.date();
                schedule.IETRS_Inspection_Schedule_Config__c = configRecord.Id;
                schedule.IETRS_Specialized_Schedule_Business_Type__c = productType;
                result.add(schedule);
            }
        }
        return result;
    }

    private void setProductTypeMaps(
        List<Account> organizations,
        String businessArea
    ) {
        // find organizations where related entities meet conditions for evaluation
        Map<Id, Set<String>> result = new Map<Id, Set<String>>();
        for (Account entity : [
            SELECT
                Id,
                IETRS_OrganizationofRegEntity__c,
                IETRS_Product_Class__c,
                Type,
                IETRS_Total_Miles__c
            FROM Account
            WHERE
                IETRS_OrganizationofRegEntity__c IN :organizations
                AND IETRS_Business_Area__c = :businessArea
                AND IETRS_Jurisdiction__c NOT IN :EXCLUDED_JURISDICTION_TYPES
                AND IETRS_Status__c NOT IN :EXCLUDED_STATUSES
                AND ((IETRS_Product_Class__c = 'Gas'
                AND Type IN (
                    'Transmission',
                    'Distribution',
                    'Liquified Natural Gas'
                ))
                OR IETRS_Product_Class__c = 'Liquid')
        ]) {
            Id orgId = entity.IETRS_OrganizationofRegEntity__c;
            String productKey = entity.IETRS_Product_Class__c == 'Liquid'
                ? entity.IETRS_Product_Class__c
                : entity.IETRS_Product_Class__c +
                  entity.Type?.deleteWhitespace();

            // set the entityIdByProductType map
            entityIdByProductType.put(entity.Id, productKey);

            // set the productTypesByOrgId map
            if (!productTypesByOrgId.containsKey(orgId)) {
                productTypesByOrgId.put(orgId, new Set<String>());
            }
            productTypesByOrgId.get(orgId).add(productKey);

            // set the totalMilesByProductTypeByOrgId map
            Decimal miles = entity.IETRS_Total_Miles__c != null
                ? entity.IETRS_Total_Miles__c
                : 0;
            if (!totalMilesByProductTypeByOrgId.containsKey(orgId)) {
                totalMilesByProductTypeByOrgId.put(
                    orgId,
                    new Map<String, Decimal>()
                );
            }
            Map<String, Decimal> milesByProductType = totalMilesByProductTypeByOrgId.get(
                orgId
            );
            if (!milesByProductType.containsKey(productKey)) {
                milesByProductType.put(productKey, miles);
            } else {
                milesByProductType.put(
                    productKey,
                    miles + milesByProductType.get(productKey)
                );
            }
        }
    }

    private Map<Id, Account> getNonPhysicalEntityByOrgId(Set<Id> orgIds) {
        Map<Id, Account> result = new Map<Id, Account>();
        for (Account entity : [
            SELECT
                Id,
                Latest_Inspection_Date__c,
                IETRS_OrganizationofRegEntity__c,
                IETRS_Latest_Inspection__r.IETRS_Inspection_Start_Date_and_Time__c,
                IETRS_Latest_Inspection__r.IETRS_Inspection_Status__c
            FROM Account
            WHERE
                IETRS_OrganizationofRegEntity__c IN :organizations
                AND IETRS_Entity_Code__c = :ENTITY_CODE
                AND IETRS_Jurisdiction__c NOT IN :EXCLUDED_JURISDICTION_TYPES
            ORDER BY CreatedDate
        ]) {
            result.put(entity.IETRS_OrganizationofRegEntity__c, entity);
        }
        return result;
    }

    private void setRiskFactors() {
        for (Account org : validOrganizations) {
            Set<String> orgProductTypes = productTypesByOrgId.get(org.Id);
            for (String productType : orgProductTypes) {
                System.debug('productType: ' + productType);
                for (String subType : SUBTYPE_BY_PRODUCT.get(productType)) {
                    System.debug('    -subType: ' + subType);
                    String riskCodes = getEligibleRiskCodes(
                        org,
                        productType,
                        subType
                    );
                    System.debug('    -riskCodes: ' + riskCodes);
                    if (String.isBlank(riskCodes)) {
                        continue;
                    }
                    if (!riskCodesBySubtypeByTypeByOrgId.containsKey(org.Id)) {
                        riskCodesBySubtypeByTypeByOrgId.put(
                            org.Id,
                            new Map<String, Map<String, String>>()
                        );
                    }
                    if (
                        !riskCodesBySubtypeByTypeByOrgId.get(org.Id)
                            .containsKey(productType)
                    ) {
                        riskCodesBySubtypeByTypeByOrgId.get(org.Id)
                            .put(productType, new Map<String, String>());
                    }
                    riskCodesBySubtypeByTypeByOrgId.get(org.Id)
                        .get(productType)
                        .put(subType, riskCodes);
                }
            }
        }
    }

    private String getEligibleRiskCodes(
        Account organization,
        String productType,
        String subtype
    ) {
        String result = '';
        // Loop over the relevant risk codes
        for (String riskCode : risksByCode.keySet()) {
            // Get the list of config records associated with the risk code
            // This will almost always be one, but it handles the remote possibility where
            //  there are multiple risks per code. If at least one config record
            //  indicates eligibility, the code will be included.
            List<IETRS_InspSchedConfig__c> risks = risksByCode.get(riskCode);

            for (IETRS_InspSchedConfig__c risk : risks) {
                // don't check subsequent records if already found a match
                Boolean isEligible = false;
                if (!isEligible) {
                    if (riskCode == O.toUpperCase()) {
                        isEligible = checkORiskFactor(
                            organization.Id,
                            risk,
                            productType,
                            subtype
                        );
                    } else if (riskCode == F.toUpperCase()) {
                        isEligible = checkFRiskFactor(
                            organization,
                            risk,
                            productType
                        );
                    } else if (riskCode == T.toUpperCase()) {
                        isEligible = checkTRiskFactor(
                            organization,
                            risk,
                            productType
                        );
                    } else if (riskCode == U_RISK.toUpperCase()) {
                        isEligible = checkURiskFactor(
                            organization.Id,
                            productType,
                            subtype
                        );
                    }

                    if (isEligible) {
                        result += riskCode.left(1);
                        Integer priority = Integer.valueOf(
                            risk.IETRS_Priority__c
                        );
                        if (
                            !lowestRiskPriorityBySubtypeByOrgId.containsKey(
                                organization.Id
                            )
                        ) {
                            lowestRiskPriorityBySubtypeByOrgId.put(
                                organization.Id,
                                new Map<String, Integer>()
                            );
                        }
                        Map<String, Integer> lowestRiskPriorityBySubtype = lowestRiskPriorityBySubtypeByOrgId.get(
                            organization.Id
                        );
                        if (lowestRiskPriorityBySubtype.containsKey(subtype)) {
                            lowestRiskPriorityBySubtype.put(
                                subtype,
                                Math.min(
                                    lowestRiskPriorityBySubtype.get(subtype),
                                    priority
                                )
                            );
                        }
                        lowestRiskPriorityBySubtype.put(subtype, priority);
                    }
                }
            }
        }
        return result;
    }

    /**
     * @description Maps configured risk factors for each business area (Master Meter, Transmission, etc.)
     * @author Srilu
     * @return Map<String, List<IETRS_Insp_InspSchedConfig__c>> - Map of business areas to risk factors
     */
    public static Map<String, List<IETRS_InspSchedConfig__c>> buildRiskMap(
        string businessArea
    ) {
        Map<String, List<IETRS_InspSchedConfig__c>> riskMap = new Map<String, List<IETRS_InspSchedConfig__c>>();
        try {
            for (IETRS_InspSchedConfig__c insp : [
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
                WHERE
                    RecordType.DeveloperName = :RECTYPE_RISK_FACTOR
                    AND IETRS_Schedule_Type__c = :PIPELINE_SPCL_SCH
                    AND IETRS_Business_Area__c = :businessArea
                ORDER BY IETRS_Priority__c DESC NULLS LAST
            ]) {
                String riskCode = insp.IETRS_Priority_Code__c.toUpperCase();
                if (!riskMap.containsKey(riskCode)) {
                    riskMap.put(riskCode, new List<IETRS_InspSchedConfig__c>());
                }
                riskMap.get(riskCode).add(insp);
            }
            return riskMap;
        } catch (exception e) {
            return null;
        }
    }

    /**
     * @description - Builds a map of existing schedule records for this schedule generation record
     * @author Srilu
     * @param genRecordId - Schedule config generation record to retrieve schedule records for
     * @return Map<Id, IETRS_Insp_InspSchedule__c> - Map of schedule records to Regulated Entity account Id
     * { systemEntityId1 => sheduleRecord}
     **/
    private void buildScheduleMap() {
        for (IETRS_InspSchedule__c sched : [
            SELECT
                Id,
                Name,
                IETRS_Inspection_Package__c,
                IETRS_Organization__c,
                IETRS_Regulated_Entity__c,
                IETRS_Inspection_Sub_Type__c,
                IETRS_Specialized_Schedule_Business_Type__c
            FROM IETRS_InspSchedule__c
            WHERE
                IETRS_Inspection_Schedule_Config__c = :configRecord.Id
                AND IETRS_Organization__c IN :organizations
        ]) {
            // add to existing schedules map so these don't get recreated
            if (sched.IETRS_Inspection_Package__c != null) {
                // check if the schedule record includes the product type
                if (sched.IETRS_Specialized_Schedule_Business_Type__c == null) {
                    Boolean isGasDistribution = SUBTYPE_BY_PRODUCT.get(GAS_DIS)
                        .contains(sched.IETRS_Inspection_Sub_Type__c);
                    Boolean isGasTransmission = SUBTYPE_BY_PRODUCT.get(
                            GAS_TRANS
                        )
                        .contains(sched.IETRS_Inspection_Sub_Type__c);
                    Boolean isLiquid = SUBTYPE_BY_PRODUCT.get(LIQUID)
                        .contains(sched.IETRS_Inspection_Sub_Type__c);
                    if (isGasDistribution && isGasTransmission) {
                        // if sub type is in both, we can't determine what the schedule product type is
                        // so the system won't be able to prevent creating a duplicate. In this case we'll throw
                        // an exception and indicate that the IETRS_Specialized_Schedule_Business_Type__c should be set
                        throw new ScheduleGenerationException(
                            'The inspection schedule "' +
                            sched.Name +
                            '" is related to an IP and the system ' +
                            'could not determine if the schedule was generated by Gas Distribution or Gas Transmission entites, which ' +
                            'could result in generating duplicate schedules. Please set the Specialized Schedule Business Type field on ' +
                            'the schedule record to "' +
                            GAS_DIS +
                            '" or "' +
                            GAS_TRANS +
                            '" and try again.'
                        );
                    } else if (isGasDistribution) {
                        sched.IETRS_Specialized_Schedule_Business_Type__c = GAS_DIS;
                    } else if (isGasTransmission) {
                        sched.IETRS_Specialized_Schedule_Business_Type__c = GAS_TRANS;
                    } else if (isLiquid) {
                        sched.IETRS_Specialized_Schedule_Business_Type__c = LIQUID;
                    } else {
                        // ignore this record if the sub type isn't recognized
                        continue;
                    }
                }
                Id key = sched.IETRS_Organization__c;
                // use the regulated entity as the key if new construction
                if (
                    sched.IETRS_Inspection_Sub_type__c == LDTC ||
                    sched.IETRS_Inspection_Sub_type__c == GDTC
                ) {
                    key = sched.IETRS_Regulated_Entity__c;
                }
                if (
                    !existingSubtypesByProductTypeByAccountId.containsKey(key)
                ) {
                    existingSubtypesByProductTypeByAccountId.put(
                        key,
                        new Map<String, Set<String>>()
                    );
                }
                Map<String, Set<String>> existingSubtypesByProductType = existingSubtypesByProductTypeByAccountId.get(
                    key
                );
                if (
                    !existingSubtypesByProductType.containsKey(
                        sched.IETRS_Specialized_Schedule_Business_Type__c
                    )
                ) {
                    existingSubtypesByProductType.put(
                        sched.IETRS_Specialized_Schedule_Business_Type__c,
                        new Set<String>()
                    );
                }
                existingSubtypesByProductType.get(
                        sched.IETRS_Specialized_Schedule_Business_Type__c
                    )
                    .add(sched.IETRS_Inspection_Sub_Type__c);
            } else {
                schedulesToDelete.add(sched);
            }
        }
    }

    /*
     * @description Get alist of organization ids who have not had 'Pipeline Routine Schedule' inspection this year
     */
    private Map<Id, Map<String, Map<String, Integer>>> getCarryOverScheduleMapByOrgId(
        set<id> orgAccountIds,
        Integer schYear
    ) {
        carryOverScheduleMapByOrgId = new Map<Id, Map<String, Map<String, Integer>>>();
        // orgId => { productType => { subType => priority }}
        String priorYear = String.valueOf(schYear - 1);
        for (IETRS_InspSchedule__c sched : [
            SELECT
                Id,
                IETRS_Organization__c,
                IETRS_Inspection_Year__c,
                IETRS_Inspection_Sub_Type__c,
                IETRS_Risk_Factors__c,
                IETRS_Priority__c,
                IETRS_Regulated_Entity__c,
                IETRS_Specialized_Schedule_Business_Type__c
            FROM IETRS_InspSchedule__c
            WHERE
                IETRS_Organization__c IN :organizations
                AND IETRS_Type__c = :PIPELINE_SPCL_SCH
                AND IETRS_Inspection_Year__c = :priorYear
                AND IETRS_Inspection_Package__c = NULL
                AND IETRS_Inspection_Sub_Type__c != NULL
                AND IETRS_Regulated_Entity__c != NULL
        ]) {
            // if there isn't a priority, assume it should be 1
            Integer newPriority = 1;
            if (sched.IETRS_Priority__c != null) {
                newPriority = Math.max(
                    Integer.valueOf(sched.IETRS_Priority__c) - 1,
                    1
                );
            }

            // keep carryover new construction schedules in a separate map
            if (sched.IETRS_Risk_Factors__c == 'N') {
                constructionCarryOverPriorityByEntityId.put(
                    sched.IETRS_Regulated_Entity__c,
                    newPriority
                );
                continue;
            }

            // handle other carryover schedules
            if (sched.IETRS_Specialized_Schedule_Business_Type__c != null) {
                String productKey = sched.IETRS_Specialized_Schedule_Business_Type__c;
                if (!SUBTYPE_BY_PRODUCT.containsKey(productKey)) {
                    // ignore this schedule if the entity is not one of the product types
                    // we're creating schedules for
                    continue;
                }
                Map<String, Map<String, Integer>> carryOverScheduleMap;
                if (
                    !carryOverScheduleMapByOrgId.containsKey(
                        sched.IETRS_Organization__c
                    )
                ) {
                    carryOverScheduleMapByOrgId.put(
                        sched.IETRS_Organization__c,
                        new Map<String, Map<String, Integer>>()
                    );
                }
                carryOverScheduleMap = carryOverScheduleMapByOrgId.get(
                    sched.IETRS_Organization__c
                );
                if (!carryOverScheduleMap.containsKey(productKey)) {
                    carryOverScheduleMap.put(
                        productKey,
                        new Map<String, Integer>()
                    );
                }
                carryOverScheduleMap.get(productKey)
                    //the delete whitespace seems to be causing an error if the subtype is specifically Liquid Public Awareness => LiquidPublic Awareness
                    .put(
                        sched.IETRS_Inspection_Sub_Type__c.deleteWhitespace(),
                        newPriority
                    );
            }
        }
        return carryOverScheduleMapByOrgId;
    }

    /*
     * @description Check if outside range risk factor applies for the given organization
     * @param orgId The org id
     * @param productType   The classification to check (GT, GD or L)
     * @param subType   The subtype to check
     */
    public Boolean checkORiskFactor(
        Id orgId,
        IETRS_InspSchedConfig__c risk,
        String productType,
        String subtype
    ) {
        Boolean result = false;
        if (
            lastInspBySubtypeByTypeByOrgId.containsKey(orgId) &&
            lastInspBySubtypeByTypeByOrgId.get(orgId)
                .containsKey(productType) &&
            lastInspBySubtypeByTypeByOrgId.get(orgId)
                .get(productType)
                .containsKey(subtype)
        ) {
            Date lastDayOfScheduleYear = Date.newInstance(
                Integer.valueOf(configRecord.IETRS_Year__c),
                12,
                31
            ); // 12/31/2022
            Integer frequencyYears = risk != null &&
                risk.IETRS_Value_One__c != null
                ? Integer.valueOf(risk.IETRS_Value_One__c)
                : 0; // 4
            Date lastInspectionDate = lastInspBySubtypeByTypeByOrgId.get(orgId)
                .get(productType)
                .get(subtype)
                .IETRS_Inspection_Start_Date_And_Time__c.date(); // 5/7/2018
            result =
                lastInspectionDate.addYears(frequencyYears) <=
                lastDayOfScheduleYear;
        }
        return result;
    }

    /*
     * @description Check if unevaluated system risk factor applies
     * @param orgId The org id
     * @param productType   The classification to check (GT, GD or L)
     * @param subType   The subtype to check
     */
    public Boolean checkURiskFactor(
        Id orgId,
        String productType,
        String subtype
    ) {
        Boolean result = true;
        if (
            lastInspBySubtypeByTypeByOrgId.containsKey(orgId) &&
            lastInspBySubtypeByTypeByOrgId.get(orgId)
                .containsKey(productType) &&
            lastInspBySubtypeByTypeByOrgId.get(orgId)
                .get(productType)
                .containsKey(subtype)
        ) {
            // an inspection exists for org, product and subtype so don't apply the U code
            result = false;
        }
        return result;
    }

    /*
     * @description Check if miles risk factor applies for the given organization and product type.
     *  It will never apply for the Gas Distribution product type.
     * risk,
     * @param orgAcc The organization
     * @param risk The config record to compare against
     * @param risk The product type - liquid, gas dist or gas trans
     */
    public static Boolean checkFRiskFactor(
        Account org,
        IETRS_InspSchedConfig__c risk,
        String productType
    ) {
        Boolean result = false;
        if (
            productType == LIQUID &&
            org.Total_Miles_of_High_Consequence_Liq__c != null
        ) {
            result =
                org.Total_Miles_of_High_Consequence_Liq__c >
                risk.IETRS_Value_One__c;
        } else if (
            productType == GAS_TRANS &&
            org.Total_Miles_of_High_Consequence_Gas__c != null
        ) {
            result =
                org.Total_Miles_of_High_Consequence_Gas__c >
                risk.IETRS_Value_One__c;
        }
        return result;
    }

    /*
     * @description Check if the T risk factor applies for the provided org and product type.
     * @param orgAcc The organization
     * @param risk The config record to compare against
     * @param risk The product type - liquid, gas dist or gas trans
     */
    private Boolean checkTRiskFactor(
        Account org,
        IETRS_InspSchedConfig__c risk,
        String productType
    ) {
        Decimal totalMiles = totalMilesByProductTypeByOrgId.get(org.Id)
            .get(productType);
        return totalMiles > risk.IETRS_Value_One__c;
    }

    /**
     * @description - Send email to user on success or error
     * @author Srilu
     * @param String subject - Email subject
     * @param String body - Body of the email
     * @return String - Send result
     */
    public static String sendEmail(String subject, String body) {
        try {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(new List<String>{ UserInfo.getUserEmail() });
            mail.setSubject(subject);
            mail.setPlainTextBody(body);

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
        } catch (Exception e) {
            // fail gracefully if email is turned off
        }
        return 'Success';
    }
    public class ScheduleGenerationException extends Exception {
    }
}