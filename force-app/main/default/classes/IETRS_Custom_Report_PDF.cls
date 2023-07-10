/**
 * @File Name          : IETRS_Custom_Report_PDF.cls
 * @Last Modified By   : Madhuri Parvathreddy
 * @Last Modified On   : 6/5/2023
 * @Modification Log   :
 *==============================================================================
 * Ver         Date                     Author                Modification
 *==============================================================================
 * 1.0    6/10/2019, 10:07:01 AM   cmckee@sensecorp.com     Initial Version
 * 2.0    6/05/2023,  5:00:00 PM   Madhuri P                IN00097159--Changes made to remove balnk page and duplicate row on last page.
 **/
public class IETRS_Custom_Report_PDF {
    public Map<String, Map<String, Eastern_Coastline_Wrapper>> County_ECW_Map {
        get;
        set;
    }
    public List<Operator_Address_Wrapper> OAWList { get; set; }
    public Map<String, List<Operator_Address_Wrapper>> OAWListMap { get; set; }
    public Map<String, String> operatorCountMap { get; set; }
    public List<String> operatorKeys { get; set; }
    public Map<String, List<Summary_Sch_Wrapper>> systemTypeMap { get; set; }
    public Integer systemTypeMapSize { get; set; }
    public Boolean SummarySch { get; set; }
    public Boolean CoastlineAddr { get; set; }
    public Boolean PerfomanceQtr { get; set; }
    public Boolean AddressReport { get; set; }
    public Boolean SystemMiles { get; set; }
    public Boolean SystemUnits { get; set; }
    public String selectedYear { get; set; }
    public String selectedAddr { get; set; }
    public String selectedQtr { get; set; }
    public String selectedQtrYr { get; set; }
    public String selectedCtry { get; set; }
    public String selectedReg { get; set; }
    public String selectedUnit { get; set; }
    public String selectedMile { get; set; }
    public String selectedSystemType { get; set; }
    public String selectedSType { get; set; }
    public String QtrVFEndDate { get; set; }
    public String classficationKey { get; set; }
    public Integer totalOperators { get; set; }
    Map<Integer, String> monthNameMap = new Map<Integer, String>{
        1 => 'January',
        2 => 'February',
        3 => 'March',
        4 => 'April',
        5 => 'May',
        6 => 'June',
        7 => 'July',
        8 => 'August',
        9 => 'September',
        10 => 'October',
        11 => 'November',
        12 => 'December'
    };
    public List<String> regionNames { get; set; }
    public Map<String, Map<String, Map<String, Map<String, Map<String, Integer>>>>> prodMap {
        get;
        set;
    }
    public Map<String, Map<String, Map<String, Map<String, Integer>>>> prodMapSubClassTotalMiles {
        get;
        set;
    }
    public Map<String, Map<String, Map<String, Integer>>> prodMapTypeTotalMiles {
        get;
        set;
    }
    public Map<String, Map<String, Integer>> prodMapClassTotalMiles {
        get;
        set;
    }
    public Map<String, Integer> TotalMiles { get; set; }
    public Map<String, Map<String, Map<String, Map<String, Map<String, Integer>>>>> prodMapUnits {
        get;
        set;
    }
    public Map<String, Map<String, Map<String, Map<String, Integer>>>> prodMapSubClassTotalUnits {
        get;
        set;
    }
    public Map<String, Map<String, Map<String, Integer>>> prodMapTypeTotalUnits {
        get;
        set;
    }
    public Map<String, Map<String, Integer>> prodMapClassTotalUnits {
        get;
        set;
    }
    public Map<String, Map<String, Inspection_Wrapper>> Inspection_WrapperMap {
        get;
        set;
    }

    public Map<String, Integer> TotalUnits { get; set; }
    public Map<String, List<List<Inspection_PKG_Wrapper>>> Inspection_PKG_ActivityMap {
        get;
        set;
    }
    public Map<String, Inspection_PKG_Classification_Wrapper> INS_PKG_WrapClassificationMap {
        get;
        set;
    }
    public Map<String, Inspection_PKG_Type_Wrapper> INS_PKG_WrapTypeMap {
        get;
        set;
    }
    public Map<String, Inspection_Wrapper> milesTypeWrapperMap { get; set; }
    public List<Inspection_PKG_Total_Wrapper> totals { get; set; }
    Map<String, String> conMap;
    public Decimal leadInspectorsCount { get; set; }
    public Datetime loggedInUserDateTime { get; set; }
    public IETRS_Custom_Report_PDF() {
        Datetime gmt = System.now();
        Integer offset = UserInfo.getTimezone().getOffset(gmt);
        loggedInUserDateTime = gmt.addSeconds(offset / 1000);
        String selectedReport = system.currentpagereference()
            .getparameters()
            .get('selectedReport');
        selectedYear = system.currentpagereference()
            .getparameters()
            .get('Year');
        selectedAddr = system.currentpagereference()
            .getparameters()
            .get('addr');
        selectedQtr = system.currentpagereference().getparameters().get('Qtr');
        selectedQtrYr = system.currentpagereference()
            .getparameters()
            .get('QtrYr');
        selectedCtry = system.currentpagereference()
            .getparameters()
            .get('Ctry');
        selectedReg = system.currentpagereference().getparameters().get('Reg');
        selectedUnit = system.currentpagereference()
            .getparameters()
            .get('Unit');
        selectedMile = system.currentpagereference()
            .getparameters()
            .get('Mile');
        selectedSystemType = system.currentpagereference()
            .getparameters()
            .get('typ');
        selectedSType = system.currentpagereference()
            .getparameters()
            .get('sTyp');
        SummarySch = false;
        CoastlineAddr = false;
        PerfomanceQtr = false;
        AddressReport = false;
        SystemMiles = false;
        SystemUnits = false;
        conMap = new Map<String, String>();
        classficationKey = 'Comprehensive';
        regionNames = new List<String>();
        systemTypeMap = new Map<String, List<Summary_Sch_Wrapper>>();
        County_ECW_Map = new Map<String, Map<String, Eastern_Coastline_Wrapper>>();
        OAWList = new List<Operator_Address_Wrapper>();

        if (selectedReport != null) {
            if (selectedYear != null) {
                System.debug('##1');
                SummarySch = true;
                CoastlineAddr = false;
                PerfomanceQtr = false;
                AddressReport = false;
                SystemMiles = false;
                SystemUnits = false;
                generateSummayScheduleReportPdf();
            }
            if (selectedAddr == 'None') {
                System.debug('##2');
                SummarySch = false;
                CoastlineAddr = true;
                PerfomanceQtr = false;
                AddressReport = false;
                SystemMiles = false;
                SystemUnits = false;
                generateEasternCoastReportPdf();
            }
            if (selectedMile != null) {
                System.debug('##5');
                SummarySch = false;
                CoastlineAddr = false;
                PerfomanceQtr = false;
                AddressReport = false;
                SystemMiles = true;
                SystemUnits = false;
                generateSystemMilesByRegionReportPdf();
            }
            if (selectedUnit != null) {
                System.debug('##6');
                SummarySch = false;
                CoastlineAddr = false;
                PerfomanceQtr = false;
                AddressReport = false;
                SystemMiles = false;
                SystemUnits = true;
                generateSystemUnitsByRegionReportPdf();
            }
            if (selectedCtry != null) {
                System.debug('##4');
                SummarySch = false;
                CoastlineAddr = false;
                PerfomanceQtr = false;
                AddressReport = true;
                SystemMiles = false;
                SystemUnits = false;
                generateOperatorAddressReportPdf();
            }
            if (selectedQtr != null) {
                System.debug('##3');
                SummarySch = false;
                CoastlineAddr = false;
                PerfomanceQtr = true;
                AddressReport = false;
                SystemMiles = false;
                SystemUnits = false;
                generatePerfomanceQuarterReportPdf();
            }
        }
    }
    public void generateSummayScheduleReportPdf() {
        Set<String> systemType = new Set<String>();
        systemTypeMap = new Map<String, List<Summary_Sch_Wrapper>>();
        systemType.add('Gas Transmission');
        systemType.add('Distribution');
        systemType.add('Master Meter');
        systemType.add('Hazardous Liquid');

        for (String typ : systemType) {
            Map<id, IETRS_County_Group__c> regionsMap = new Map<id, IETRS_County_Group__c>(
                [SELECT id, Name FROM IETRS_County_Group__c]
            );
            Map<id, List<IETRS_InspSchedule__c>> regionFilterMap = new Map<id, List<IETRS_InspSchedule__c>>();
            Map<id, Priority_Wrapper> priorityFilterMap = new Map<id, Priority_Wrapper>();
            Map<id, Schedule_Wrapper> scheduleFilterMap = new Map<id, Schedule_Wrapper>();
            List<Summary_Sch_Wrapper> SSWList = new List<Summary_Sch_Wrapper>();

            for (IETRS_InspSchedule__c InspSch : [
                SELECT
                    id,
                    IETRS_Regulated_Entity__r.IETRS_Unit_Type_from_Regulated_Entity__c,
                    IETRS_Region__c,
                    IETRS_Scheduled2__c,
                    IETRS_Scheduled__c,
                    IETRS_Priority__c
                FROM IETRS_InspSchedule__c
                WHERE
                    IETRS_Inspection_Year__c = :selectedYear
                    AND IETRS_Regulated_Entity__r.IETRS_Unit_Type_from_Regulated_Entity__c = :typ
                    AND IETRS_Organization_ID__c != '1582'
                    AND IETRS_Approved__c = TRUE
            ]) {
                if (InspSch.IETRS_Region__c != null) {
                    if (regionFilterMap.containsKey(InspSch.IETRS_Region__c)) {
                        List<IETRS_InspSchedule__c> temp = regionFilterMap.get(
                            InspSch.IETRS_Region__c
                        );
                        temp.add(InspSch);
                        regionFilterMap.put(InspSch.IETRS_Region__c, temp);
                        Priority_Wrapper tempPRWrap = priorityFilterMap.get(
                            InspSch.IETRS_Region__c
                        );
                        if (InspSch.IETRS_Priority__c == '1') {
                            tempPRWrap.priority1 = tempPRWrap.priority1 + 1;
                        } else if (InspSch.IETRS_Priority__c == '2') {
                            tempPRWrap.priority2 = tempPRWrap.priority2 + 1;
                        } else if (InspSch.IETRS_Priority__c == '3') {
                            tempPRWrap.priority3 = tempPRWrap.priority3 + 1;
                        }
                        priorityFilterMap.put(
                            InspSch.IETRS_Region__c,
                            tempPRWrap
                        );
                        Schedule_Wrapper schWrapTemp = scheduleFilterMap.get(
                            InspSch.IETRS_Region__c
                        );
                        if (InspSch.IETRS_Scheduled__c) {
                            schWrapTemp.sch = schWrapTemp.sch + 1;
                            if (InspSch.IETRS_Priority__c == '1') {
                                schWrapTemp.priority1Sch =
                                    schWrapTemp.priority1Sch + 1;
                            } else if (InspSch.IETRS_Priority__c == '2') {
                                schWrapTemp.priority2Sch =
                                    schWrapTemp.priority2Sch + 1;
                            } else if (InspSch.IETRS_Priority__c == '3') {
                                schWrapTemp.priority3Sch =
                                    schWrapTemp.priority3Sch + 1;
                            }
                        } else {
                            schWrapTemp.NotSch = schWrapTemp.NotSch + 1;
                            if (InspSch.IETRS_Priority__c == '1') {
                                schWrapTemp.priority1NotSch =
                                    schWrapTemp.priority1NotSch + 1;
                            } else if (InspSch.IETRS_Priority__c == '2') {
                                schWrapTemp.priority2NotSch =
                                    schWrapTemp.priority2NotSch + 1;
                            } else if (InspSch.IETRS_Priority__c == '3') {
                                schWrapTemp.priority3NotSch =
                                    schWrapTemp.priority3NotSch + 1;
                            }
                        }
                        scheduleFilterMap.put(
                            InspSch.IETRS_Region__c,
                            schWrapTemp
                        );
                    } else {
                        List<IETRS_InspSchedule__c> temp = new List<IETRS_InspSchedule__c>();
                        temp.add(InspSch);
                        regionFilterMap.put(InspSch.IETRS_Region__c, temp);
                        Priority_Wrapper PWrap = new Priority_Wrapper();
                        if (InspSch.IETRS_Priority__c == '1') {
                            PWrap.priority1 = 1;
                            PWrap.priority2 = 0;
                            PWrap.priority3 = 0;
                        } else if (InspSch.IETRS_Priority__c == '2') {
                            PWrap.priority1 = 0;
                            PWrap.priority2 = 1;
                            PWrap.priority3 = 0;
                        } else if (InspSch.IETRS_Priority__c == '3') {
                            PWrap.priority1 = 0;
                            PWrap.priority2 = 0;
                            PWrap.priority3 = 1;
                        } else {
                            PWrap.priority1 = 0;
                            PWrap.priority2 = 0;
                            PWrap.priority3 = 0;
                        }
                        priorityFilterMap.put(InspSch.IETRS_Region__c, PWrap);
                        Schedule_Wrapper schWrap = new Schedule_Wrapper();
                        if (InspSch.IETRS_Scheduled__c) {
                            if (InspSch.IETRS_Priority__c == '1') {
                                schWrap.priority1Sch = 1;
                                schWrap.priority1NotSch = 0;
                                schWrap.priority2Sch = 0;
                                schWrap.priority2NotSch = 0;
                                schWrap.priority3Sch = 0;
                                schWrap.priority3NotSch = 0;
                            } else if (InspSch.IETRS_Priority__c == '2') {
                                schWrap.priority1Sch = 0;
                                schWrap.priority1NotSch = 0;
                                schWrap.priority2Sch = 1;
                                schWrap.priority2NotSch = 0;
                                schWrap.priority3Sch = 0;
                                schWrap.priority3NotSch = 0;
                            } else if (InspSch.IETRS_Priority__c == '3') {
                                schWrap.priority1Sch = 0;
                                schWrap.priority1NotSch = 0;
                                schWrap.priority2Sch = 0;
                                schWrap.priority2NotSch = 0;
                                schWrap.priority3Sch = 1;
                                schWrap.priority3NotSch = 0;
                            } else {
                                schWrap.priority1Sch = 0;
                                schWrap.priority1NotSch = 0;
                                schWrap.priority2Sch = 0;
                                schWrap.priority2NotSch = 0;
                                schWrap.priority3Sch = 0;
                                schWrap.priority3NotSch = 0;
                            }
                            schWrap.sch = 1;
                            schWrap.NotSch = 0;
                        } else {
                            if (InspSch.IETRS_Priority__c == '1') {
                                schWrap.priority1Sch = 0;
                                schWrap.priority1NotSch = 1;
                                schWrap.priority2Sch = 0;
                                schWrap.priority2NotSch = 0;
                                schWrap.priority3Sch = 0;
                                schWrap.priority3NotSch = 0;
                            } else if (InspSch.IETRS_Priority__c == '2') {
                                schWrap.priority1Sch = 0;
                                schWrap.priority1NotSch = 0;
                                schWrap.priority2Sch = 0;
                                schWrap.priority2NotSch = 1;
                                schWrap.priority3Sch = 0;
                                schWrap.priority3NotSch = 0;
                            } else if (InspSch.IETRS_Priority__c == '3') {
                                schWrap.priority1Sch = 0;
                                schWrap.priority1NotSch = 0;
                                schWrap.priority2Sch = 0;
                                schWrap.priority2NotSch = 0;
                                schWrap.priority3Sch = 0;
                                schWrap.priority3NotSch = 1;
                            } else {
                                schWrap.priority1Sch = 0;
                                schWrap.priority1NotSch = 0;
                                schWrap.priority2Sch = 0;
                                schWrap.priority2NotSch = 0;
                                schWrap.priority3Sch = 0;
                                schWrap.priority3NotSch = 0;
                            }
                            schWrap.sch = 0;
                            schWrap.NotSch = 1;
                        }
                        scheduleFilterMap.put(InspSch.IETRS_Region__c, schWrap);
                    }
                }
            }
            Map<String, Id> regionNameIDMap = new Map<String, Id>();
            List<string> regionNamesList = new List<String>();
            for (Id regionId : regionFilterMap.keySet()) {
                regionNamesList.add(regionsMap.get(regionId).Name);
                regionNameIDMap.put(regionsMap.get(regionId).Name, regionId);
            }
            regionNamesList.sort();
            for (String regionName : regionNamesList) {
                Summary_Sch_Wrapper CRW = new Summary_Sch_Wrapper();
                CRW.regionName = regionName;
                CRW.regionRecCount = regionFilterMap.get(
                        regionNameIDMap.get(regionName)
                    )
                    .size();
                CRW.priWrap = priorityFilterMap.get(
                    regionNameIDMap.get(regionName)
                );
                CRW.schWrap = scheduleFilterMap.get(
                    regionNameIDMap.get(regionName)
                );
                SSWList.add(CRW);
            }
            systemTypeMap.put(typ, SSWList);
        }
        system.debug('##SYSTYP' + systemTypeMap);
        systemTypeMapSize = systemTypeMap.size();
    }
    // ************************** GENERATE EASTERN COASTLINE REPORT PDF *****************************
    public void generateEasternCoastReportPdf() {
        Map<String, String> addressMap = new Map<String, String>();
        Map<String, String> companyIDMap = new Map<String, String>();
        Map<String, String> addressWithCountyMap = new Map<string, String>();
        County_ECW_Map = new Map<String, Map<String, Eastern_Coastline_Wrapper>>();
        Set<String> custom_county_sets = new Set<String>();

        classficationKey = 'Comprehensive';
        Map<String, String> checkAddrDuplicateMap = new Map<String, String>();
        Set<String> acctIds = new Set<String>();

        for (
            String custom_Setting_county_name : [
                    SELECT id, County_Names__c
                    FROM IETRS_Counties__c
                    LIMIT 1
                ]
                .County_Names__c.split(';')
        ) {
            custom_county_sets.add(custom_Setting_county_name);
        }

        for (IETRS_Insp_Miles_by_County__c relCounties : [
            SELECT
                id,
                IETRS_County_Name__c,
                IETRS_Regulated_Entity__c,
                IETRS_Regulated_Entity__r.RecordType.Name,
                IETRS_Regulated_Entity__r.IETRS_Counties_List__c,
                IETRS_Regulated_Entity__r.IETRS_OrganizationofRegEntity__r.Name,
                IETRS_Regulated_Entity__r.IETRS_OrganizationofRegEntity__r.IETRS_Representative__r.MailingStreet,
                IETRS_Regulated_Entity__r.IETRS_OrganizationofRegEntity__r.IETRS_Representative__r.MailingCity,
                IETRS_Regulated_Entity__r.IETRS_OrganizationofRegEntity__r.IETRS_Representative__r.MailingState,
                IETRS_Regulated_Entity__r.IETRS_OrganizationofRegEntity__r.IETRS_Representative__r.MailingPostalCode,
                IETRS_Regulated_Entity__r.IETRS_OrganizationofRegEntity__r.Org_P5_Number__c,
                IETRS_Regulated_Entity__r.IETRS_OrganizationofRegEntity__r.IETRS_Representative_Phone__c,
                IETRS_Regulated_Entity__r.IETRS_OrganizationofRegEntity__r.IETRS_RepresentativeFax__c,
                IETRS_Regulated_Entity__r.IETRS_OrganizationofRegEntity__r.IETRS_Representative_24_Phone__c,
                IETRS_Regulated_Entity__r.IETRS_OrganizationofRegEntity__r.IETRS_Total_Miles__c,
                IETRS_Regulated_Entity__r.IETRS_OrganizationofRegEntity__r.IETRS_Company_ID__c,
                IETRS_Regulated_Entity__r.IETRS_OrganizationofRegEntity__r.IETRS_Representative__r.FirstName,
                IETRS_Regulated_Entity__r.IETRS_OrganizationofRegEntity__r.IETRS_Representative__r.LastName,
                IETRS_Regulated_Entity__r.IETRS_OrganizationofRegEntity__r.IETRS_Representative__r.Title
            FROM IETRS_Insp_Miles_by_County__c
            WHERE
                IETRS_County_Name__c IN :custom_county_sets
                AND IETRS_Regulated_Entity__r.IETRS_Status__c != 'Abandoned'
                AND IETRS_Regulated_Entity__r.IETRS_Jurisdiction__c = 'Jurisdictional'
                AND IETRS_Regulated_Entity__r.IETRS_OrganizationofRegEntity__r.IETRS_Company_ID__c != '1582'
                AND IETRS_Regulated_Entity__r.RecordType.Name = 'Regulated Entity - PS'
            ORDER BY
                IETRS_Regulated_Entity__r.IETRS_OrganizationofRegEntity__r.Name DESC
        ]) {
            if (County_ECW_Map.containsKey(relCounties.IETRS_County_Name__c)) {
                Eastern_Coastline_Wrapper ECW = new Eastern_Coastline_Wrapper();
                Map<String, Eastern_Coastline_Wrapper> acccountNameMap = County_ECW_Map.get(
                    relCounties.IETRS_County_Name__c
                );
                if (
                    relCounties.IETRS_Regulated_Entity__r.RecordType.Name ==
                    'Regulated Entity - PS'
                ) {
                    ECW.companyId = relCounties.IETRS_Regulated_Entity__r.IETRS_OrganizationofRegEntity__r.IETRS_Company_ID__c;
                    ECW.operator =
                        relCounties.IETRS_Regulated_Entity__r.IETRS_OrganizationofRegEntity__r.Name +
                        '\n' +
                        (relCounties.IETRS_Regulated_Entity__r.IETRS_OrganizationofRegEntity__r.IETRS_Representative__r.MailingStreet ==
                            null
                            ? ' '
                            : relCounties.IETRS_Regulated_Entity__r.IETRS_OrganizationofRegEntity__r.IETRS_Representative__r.MailingStreet) +
                        '\n' +
                        (relCounties.IETRS_Regulated_Entity__r.IETRS_OrganizationofRegEntity__r.IETRS_Representative__r.MailingCity ==
                            null
                            ? ' '
                            : relCounties.IETRS_Regulated_Entity__r.IETRS_OrganizationofRegEntity__r.IETRS_Representative__r.MailingCity) +
                        ', ' +
                        (relCounties.IETRS_Regulated_Entity__r.IETRS_OrganizationofRegEntity__r.IETRS_Representative__r.MailingState ==
                            null
                            ? ' '
                            : relCounties.IETRS_Regulated_Entity__r.IETRS_OrganizationofRegEntity__r.IETRS_Representative__r.MailingState) +
                        ' ' +
                        (relCounties.IETRS_Regulated_Entity__r.IETRS_OrganizationofRegEntity__r.IETRS_Representative__r.MailingPostalCode ==
                            null
                            ? ' '
                            : relCounties.IETRS_Regulated_Entity__r.IETRS_OrganizationofRegEntity__r.IETRS_Representative__r.MailingPostalCode);
                    ECW.contactPerson =
                        (relCounties.IETRS_Regulated_Entity__r.IETRS_OrganizationofRegEntity__r.IETRS_Representative__r.FirstName ==
                            null
                            ? ' '
                            : relCounties.IETRS_Regulated_Entity__r.IETRS_OrganizationofRegEntity__r.IETRS_Representative__r.FirstName) +
                        ' ' +
                        (relCounties.IETRS_Regulated_Entity__r.IETRS_OrganizationofRegEntity__r.IETRS_Representative__r.LastName ==
                            null
                            ? ' '
                            : relCounties.IETRS_Regulated_Entity__r.IETRS_OrganizationofRegEntity__r.IETRS_Representative__r.LastName) +
                        ', ' +
                        (relCounties.IETRS_Regulated_Entity__r.IETRS_OrganizationofRegEntity__r.IETRS_Representative__r.Title ==
                            null
                            ? ' '
                            : relCounties.IETRS_Regulated_Entity__r.IETRS_OrganizationofRegEntity__r.IETRS_Representative__r.Title);
                    ECW.phone =
                        'Phone: ' +
                        (relCounties.IETRS_Regulated_Entity__r.IETRS_OrganizationofRegEntity__r.IETRS_Representative_Phone__c ==
                            null
                            ? ' '
                            : relCounties.IETRS_Regulated_Entity__r.IETRS_OrganizationofRegEntity__r.IETRS_Representative_Phone__c);
                    ECW.fax =
                        'Fax: ' +
                        (relCounties.IETRS_Regulated_Entity__r.IETRS_OrganizationofRegEntity__r.IETRS_RepresentativeFax__c ==
                            null
                            ? ' '
                            : relCounties.IETRS_Regulated_Entity__r.IETRS_OrganizationofRegEntity__r.IETRS_RepresentativeFax__c);
                    ECW.Hour_Phone =
                        '24 Hour: ' +
                        (relCounties.IETRS_Regulated_Entity__r.IETRS_OrganizationofRegEntity__r.IETRS_Representative_24_Phone__c ==
                            null
                            ? ' '
                            : relCounties.IETRS_Regulated_Entity__r.IETRS_OrganizationofRegEntity__r.IETRS_Representative_24_Phone__c);
                    acccountNameMap.put(
                        relCounties.IETRS_Regulated_Entity__r.IETRS_OrganizationofRegEntity__r.Name,
                        ECW
                    );
                }

                County_ECW_Map.put(
                    relCounties.IETRS_County_Name__c,
                    acccountNameMap
                );
            } else {
                Eastern_Coastline_Wrapper ECW = new Eastern_Coastline_Wrapper();
                Map<String, Eastern_Coastline_Wrapper> acccountNameMap = new Map<String, Eastern_Coastline_Wrapper>();
                if (
                    relCounties.IETRS_Regulated_Entity__r.RecordType.Name ==
                    'Regulated Entity - PS'
                ) {
                    ECW.companyId = relCounties.IETRS_Regulated_Entity__r.IETRS_OrganizationofRegEntity__r.IETRS_Company_ID__c;
                    ECW.operator =
                        relCounties.IETRS_Regulated_Entity__r.IETRS_OrganizationofRegEntity__r.Name +
                        '\n' +
                        (relCounties.IETRS_Regulated_Entity__r.IETRS_OrganizationofRegEntity__r.IETRS_Representative__r.MailingStreet ==
                            null
                            ? ' '
                            : relCounties.IETRS_Regulated_Entity__r.IETRS_OrganizationofRegEntity__r.IETRS_Representative__r.MailingStreet) +
                        '\n' +
                        (relCounties.IETRS_Regulated_Entity__r.IETRS_OrganizationofRegEntity__r.IETRS_Representative__r.MailingCity ==
                            null
                            ? ' '
                            : relCounties.IETRS_Regulated_Entity__r.IETRS_OrganizationofRegEntity__r.IETRS_Representative__r.MailingCity) +
                        ', ' +
                        (relCounties.IETRS_Regulated_Entity__r.IETRS_OrganizationofRegEntity__r.IETRS_Representative__r.MailingState ==
                            null
                            ? ' '
                            : relCounties.IETRS_Regulated_Entity__r.IETRS_OrganizationofRegEntity__r.IETRS_Representative__r.MailingState) +
                        ' ' +
                        (relCounties.IETRS_Regulated_Entity__r.IETRS_OrganizationofRegEntity__r.IETRS_Representative__r.MailingPostalCode ==
                            null
                            ? ' '
                            : relCounties.IETRS_Regulated_Entity__r.IETRS_OrganizationofRegEntity__r.IETRS_Representative__r.MailingPostalCode);
                    ECW.contactPerson =
                        (relCounties.IETRS_Regulated_Entity__r.IETRS_OrganizationofRegEntity__r.IETRS_Representative__r.FirstName ==
                            null
                            ? ' '
                            : relCounties.IETRS_Regulated_Entity__r.IETRS_OrganizationofRegEntity__r.IETRS_Representative__r.FirstName) +
                        ' ' +
                        (relCounties.IETRS_Regulated_Entity__r.IETRS_OrganizationofRegEntity__r.IETRS_Representative__r.LastName ==
                            null
                            ? ' '
                            : relCounties.IETRS_Regulated_Entity__r.IETRS_OrganizationofRegEntity__r.IETRS_Representative__r.LastName) +
                        ', ' +
                        (relCounties.IETRS_Regulated_Entity__r.IETRS_OrganizationofRegEntity__r.IETRS_Representative__r.Title ==
                            null
                            ? ' '
                            : relCounties.IETRS_Regulated_Entity__r.IETRS_OrganizationofRegEntity__r.IETRS_Representative__r.Title);
                    ECW.phone =
                        'Phone: ' +
                        (relCounties.IETRS_Regulated_Entity__r.IETRS_OrganizationofRegEntity__r.IETRS_Representative_Phone__c ==
                            null
                            ? ' '
                            : relCounties.IETRS_Regulated_Entity__r.IETRS_OrganizationofRegEntity__r.IETRS_Representative_Phone__c);
                    ECW.fax =
                        'Fax: ' +
                        (relCounties.IETRS_Regulated_Entity__r.IETRS_OrganizationofRegEntity__r.IETRS_RepresentativeFax__c ==
                            null
                            ? ' '
                            : relCounties.IETRS_Regulated_Entity__r.IETRS_OrganizationofRegEntity__r.IETRS_RepresentativeFax__c);
                    ECW.Hour_Phone =
                        '24 Hour: ' +
                        (relCounties.IETRS_Regulated_Entity__r.IETRS_OrganizationofRegEntity__r.IETRS_Representative_24_Phone__c ==
                            null
                            ? ' '
                            : relCounties.IETRS_Regulated_Entity__r.IETRS_OrganizationofRegEntity__r.IETRS_Representative_24_Phone__c);
                    acccountNameMap.put(
                        relCounties.IETRS_Regulated_Entity__r.IETRS_OrganizationofRegEntity__r.Name,
                        ECW
                    );
                }

                County_ECW_Map.put(
                    relCounties.IETRS_County_Name__c,
                    acccountNameMap
                );
            }
        }
        System.debug('ecw key size: ' + County_ECW_Map.keyset());
    }

    public class Inspection_PKG_Wrapper {
        public String package_ID { get; set; }
        public String evalution_ID { get; set; }
        public Date begin_Date { get; set; }
        public Date end_Date { get; set; }
        public String Activity_Classification { get; set; }
        public String System_Type { get; set; }
        public String Lead_Inspector { get; set; }
        public Decimal Miles_Evaluated { get; set; }
        public Decimal Violations { get; set; }
    }
    public class Inspection_PKG_Classification_Wrapper {
        public String Activity { get; set; }
        public String Classification { get; set; }
        public Decimal Inspections_performed { get; set; }
        public Decimal Miles_Evaluated { get; set; }
        public Decimal TotalViolations { get; set; }
    }
    public class Inspection_PKG_Type_Wrapper {
        public String SystemType { get; set; }
        public Decimal Inspections_performed { get; set; }
        public Decimal Miles_Evaluated { get; set; }
        public Decimal TotalViolations { get; set; }
        public Decimal AverageViolations { get; set; }
    }
    public class Inspection_PKG_Total_Wrapper {
        public Decimal Inspections_performed_total { get; set; }
        public Decimal Miles_Evaluated_total { get; set; }
        public Decimal TotalViolations_total { get; set; }
    }
    // **************** GENERATE PERFORMANCE QUARTER REPORT PDF *********************
    public void generatePerfomanceQuarterReportPdf() {
        Integer qtrYear = Integer.valueOf(selectedQtrYr);
        //selectedQtr string format is: '9-11' or '12-2', etc.
        List<String> qtrMonths = selectedQtr.split('-');
        /*
        Q1: 9-11 PREVIOUS YEAR
        Q2: 12-2 BEGIN PREVIOUS YEAR, END PARAMETER YEAR
        Q3: 3-5 PARAMETER YEAR
        Q4: 6-8 PARAMTER YEAR
        */
        Integer intStartYear = (qtrMonths[0] == '9' ||
            qtrMonths[0] == '12')
            ? qtrYear - 1
            : qtrYear;
        Integer intEndYear = qtrMonths[1] == '11' ? qtrYear - 1 : qtrYear;

        Date qtrStartDate = Date.newInstance(
            intStartYear,
            Integer.valueOf(qtrMonths[0]),
            1
        );
        Integer noOfDays;
        Date qtrEndDate;

        //Days in month for the ending month of the quarter
        noOfDays = Date.daysInMonth(intEndYear, Integer.valueOf(qtrMonths[1]));
        //Last Day of the month for the ending month of the quarter
        qtrEndDate = Date.newInstance(
            intEndYear,
            Integer.valueOf(qtrMonths[1]),
            noOfDays
        );
        //Formated End Date String for VF Page
        QtrVFEndDate =
            monthNameMap.get(Integer.valueOf(qtrMonths[1])) +
            ' ' +
            String.valueOf(noOfDays) +
            ', ' +
            String.valueOf(intEndYear);

        System.debug('qtrStartDate:' + qtrStartDate);
        System.debug('qtrEndDate:' + qtrEndDate);
        Set<String> systemType = new Set<String>();
        systemTypeMap = new Map<String, List<Summary_Sch_Wrapper>>();
        systemType.add('Gas Transmission');
        systemType.add('Distribution');
        systemType.add('Master Meter');
        systemType.add('Hazardous Liquid');
        systemType.add('Non-Physical System'); //added by Shailend
        Inspection_WrapperMap = new Map<String, Map<String, Inspection_Wrapper>>();
        Map<String, List<Inspection_PKG_Wrapper>> Inspection_PKG_WrapperMap = new Map<String, List<Inspection_PKG_Wrapper>>();
        Inspection_PKG_ActivityMap = new Map<String, List<List<Inspection_PKG_Wrapper>>>();

        //Map<id,IETRS_Inspection_Package__c> inspecPkgMap=new Map<id,IETRS_Inspection_Package__c>([SELECT id,Name,IETRS_Begin_Date__c,IETRS_End_Date__c from IETRS_Inspection_Package__c where IETRS_Begin_Date__c>=:qtrStartDate and IETRS_End_Date__c<=:qtrEndDate ORDER BY IETRS_Inspection_Package__c.IETRS_Begin_Date__c DESC]);
        INS_PKG_WrapTypeMap = new Map<String, Inspection_PKG_Type_Wrapper>();
        milesTypeWrapperMap = new Map<String, Inspection_Wrapper>();
        Set<String> leadInspectors = new Set<String>();

        for (IETRS_Inspection__c InsPec : [
            SELECT
                id,
                Name,
                IETRS_Inspection_Package__r.Name,
                IETRS_Inspection_Package__r.IETRS_Begin_Date__c,
                IETRS_Inspection_Package__r.IETRS_End_Date__c,
                IETRS_Activity_Classification__c,
                IETRS_Regulated_Entity_Type__c,
                IETRS_Inspection_Package__r.IETRS_Lead_Inspector_Name__c,
                IETRS_Total_Miles_of_Pipes__c,
                IETRS_Status_Date__c,
                IETRS_TotalViolations__c
            FROM IETRS_Inspection__c
            WHERE
                IETRS_Regulated_Entity_Type__c IN :systemType
                AND IETRS_Status_Date__c >= :qtrStartDate
                AND IETRS_Status_Date__c <= :qtrEndDate
                AND IETRS_Inspection_Status__c = 'Approved'
            ORDER BY
                IETRS_Activity_Classification__c DESC,
                IETRS_Inspection_Package__R.IETRS_Begin_Date__c ASC
        ]) {
            //if(InsPec.IETRS_Status_Date__c>=InsPec.IETRS_Inspection_Package__r.IETRS_Begin_Date__c && InsPec.IETRS_Status_Date__c<=InsPec.IETRS_Inspection_Package__r.IETRS_End_Date__c)
            //{
            List<String> tempActivityClassificationList = InsPec.IETRS_Activity_Classification__c.split(
                '/'
            );
            if (
                Inspection_PKG_WrapperMap.containsKey(
                    InsPec.IETRS_Inspection_Package__r.Name
                )
            ) {
                List<Inspection_PKG_Wrapper> wrapperPkgList = Inspection_PKG_WrapperMap.get(
                    InsPec.IETRS_Inspection_Package__r.Name
                );
                Inspection_PKG_Wrapper wrapperPkg = new Inspection_PKG_Wrapper();
                wrapperPkg.package_ID = InsPec.IETRS_Inspection_Package__r.Name;
                wrapperPkg.evalution_ID = InsPec.Name;
                wrapperPkg.begin_Date = InsPec.IETRS_Inspection_Package__r.IETRS_Begin_Date__c;
                wrapperPkg.end_Date = InsPec.IETRS_Inspection_Package__r.IETRS_End_Date__c;
                wrapperPkg.Activity_Classification = InsPec.IETRS_Activity_Classification__c;
                wrapperPkg.System_Type = InsPec.IETRS_Regulated_Entity_Type__c;
                wrapperPkg.Lead_Inspector = InsPec.IETRS_Inspection_Package__r.IETRS_Lead_Inspector_Name__c;
                if (InsPec.IETRS_Total_Miles_of_Pipes__c != null) {
                    wrapperPkg.Miles_Evaluated = InsPec.IETRS_Total_Miles_of_Pipes__c;
                } else {
                    wrapperPkg.Miles_Evaluated = 0;
                }
                if (InsPec.IETRS_TotalViolations__c != null) {
                    wrapperPkg.Violations = InsPec.IETRS_TotalViolations__c;
                } else {
                    wrapperPkg.Violations = 0;
                }
                wrapperPkgList.add(wrapperPkg);

                Inspection_PKG_WrapperMap.put(
                    InsPec.IETRS_Inspection_Package__r.Name,
                    wrapperPkgList
                );
            } else {
                List<Inspection_PKG_Wrapper> IPWList = new List<Inspection_PKG_Wrapper>();
                Inspection_PKG_Wrapper wrapperPkg = new Inspection_PKG_Wrapper();
                wrapperPkg.package_ID = InsPec.IETRS_Inspection_Package__r.Name;
                wrapperPkg.evalution_ID = InsPec.Name;
                wrapperPkg.begin_Date = InsPec.IETRS_Inspection_Package__r.IETRS_Begin_Date__c;
                wrapperPkg.end_Date = InsPec.IETRS_Inspection_Package__r.IETRS_End_Date__c;
                wrapperPkg.Activity_Classification = InsPec.IETRS_Activity_Classification__c;
                wrapperPkg.System_Type = InsPec.IETRS_Regulated_Entity_Type__c;
                wrapperPkg.Lead_Inspector = InsPec.IETRS_Inspection_Package__r.IETRS_Lead_Inspector_Name__c;
                if (InsPec.IETRS_Total_Miles_of_Pipes__c != null) {
                    wrapperPkg.Miles_Evaluated = InsPec.IETRS_Total_Miles_of_Pipes__c;
                } else {
                    wrapperPkg.Miles_Evaluated = 0;
                }
                if (InsPec.IETRS_TotalViolations__c != null) {
                    wrapperPkg.Violations = InsPec.IETRS_TotalViolations__c;
                } else {
                    wrapperPkg.Violations = 0;
                }
                IPWList.add(wrapperPkg);

                Inspection_PKG_WrapperMap.put(
                    InsPec.IETRS_Inspection_Package__r.Name,
                    IPWList
                );
            }
            if (
                Inspection_WrapperMap.containsKey(
                    tempActivityClassificationList[1]
                )
            ) {
                Map<String, Inspection_Wrapper> tempMap = Inspection_WrapperMap.get(
                    tempActivityClassificationList[1]
                );

                if (tempMap.containsKey(tempActivityClassificationList[0])) {
                    Inspection_Wrapper wrap = tempMap.get(
                        tempActivityClassificationList[0]
                    );
                    wrap.total_Insp_Performed = wrap.total_Insp_Performed + 1;
                    if (InsPec.IETRS_Total_Miles_of_Pipes__c != null) {
                        wrap.total_Miles_Evaluated =
                            wrap.total_Miles_Evaluated +
                            InsPec.IETRS_Total_Miles_of_Pipes__c;
                    }
                    if (InsPec.IETRS_TotalViolations__c != null) {
                        wrap.total_Voilations =
                            wrap.total_Voilations +
                            InsPec.IETRS_TotalViolations__c;
                    }

                    tempMap.put(tempActivityClassificationList[0], wrap);
                } else {
                    Inspection_Wrapper insp_wrap = new Inspection_Wrapper();
                    insp_wrap.total_Insp_Performed = 1;
                    if (InsPec.IETRS_Total_Miles_of_Pipes__c == null) {
                        insp_wrap.total_Miles_Evaluated = 0;
                    } else {
                        insp_wrap.total_Miles_Evaluated = InsPec.IETRS_Total_Miles_of_Pipes__c;
                    }
                    if (InsPec.IETRS_TotalViolations__c == null) {
                        insp_wrap.total_Voilations = 0;
                    } else {
                        insp_wrap.total_Voilations = InsPec.IETRS_TotalViolations__c;
                    }
                    tempMap.put(tempActivityClassificationList[0], insp_wrap);
                }
                Inspection_WrapperMap.put(
                    tempActivityClassificationList[1],
                    tempMap
                );
            } else {
                Map<String, Inspection_Wrapper> tempMap = new Map<String, Inspection_Wrapper>();
                if (tempMap.containsKey(tempActivityClassificationList[0])) {
                } else {
                    Inspection_Wrapper insp_wrap = new Inspection_Wrapper();
                    insp_wrap.total_Insp_Performed = 1;
                    if (InsPec.IETRS_Total_Miles_of_Pipes__c == null) {
                        insp_wrap.total_Miles_Evaluated = 0;
                    } else {
                        insp_wrap.total_Miles_Evaluated = InsPec.IETRS_Total_Miles_of_Pipes__c;
                    }
                    if (InsPec.IETRS_TotalViolations__c == null) {
                        insp_wrap.total_Voilations = 0;
                    } else {
                        insp_wrap.total_Voilations = InsPec.IETRS_TotalViolations__c;
                    }
                    tempMap.put(tempActivityClassificationList[0], insp_wrap);
                }
                Inspection_WrapperMap.put(
                    tempActivityClassificationList[1],
                    tempMap
                );
            }
            if (
                InsPec.IETRS_Regulated_Entity_Type__c != 'Non-Physical System'
            ) {
                if (
                    milesTypeWrapperMap.containsKey(
                        InsPec.IETRS_Regulated_Entity_Type__c
                    )
                ) {
                    Inspection_Wrapper tempWrap = milesTypeWrapperMap.get(
                        InsPec.IETRS_Regulated_Entity_Type__c
                    );
                    System.debug('##tempWrap' + tempWrap);
                    tempWrap.total_Insp_Performed =
                        tempWrap.total_Insp_Performed + 1;
                    if (InsPec.IETRS_Total_Miles_of_Pipes__c != null) {
                        tempWrap.total_Miles_Evaluated =
                            tempWrap.total_Miles_Evaluated +
                            InsPec.IETRS_Total_Miles_of_Pipes__c;
                    }
                    if (InsPec.IETRS_TotalViolations__c != null) {
                        tempWrap.total_Voilations =
                            tempWrap.total_Voilations +
                            InsPec.IETRS_TotalViolations__c;
                    }

                    milesTypeWrapperMap.put(
                        InsPec.IETRS_Regulated_Entity_Type__c,
                        tempWrap
                    );
                } else {
                    Inspection_Wrapper tempWrap = new Inspection_Wrapper();
                    tempWrap.total_Insp_Performed = 1;

                    if (InsPec.IETRS_Total_Miles_of_Pipes__c == null) {
                        tempWrap.total_Miles_Evaluated = 0;
                    } else {
                        tempWrap.total_Miles_Evaluated = InsPec.IETRS_Total_Miles_of_Pipes__c;
                    }
                    if (InsPec.IETRS_TotalViolations__c == null) {
                        tempWrap.total_Voilations = 0;
                    } else {
                        tempWrap.total_Voilations = InsPec.IETRS_TotalViolations__c;
                    }
                    milesTypeWrapperMap.put(
                        InsPec.IETRS_Regulated_Entity_Type__c,
                        tempWrap
                    );
                }
            }
            leadInspectors.add(
                InsPec.IETRS_Inspection_Package__r.IETRS_Lead_Inspector_Name__c
            );
            //}
        }
        leadInspectorsCount = Decimal.valueOf(leadInspectors.size());
        system.debug('Inspection_PKG_WrapperMap' + Inspection_PKG_WrapperMap);
        for (String pkgId : Inspection_PKG_WrapperMap.keySet()) {
            for (
                Inspection_PKG_Wrapper inspWrap : Inspection_PKG_WrapperMap.get(
                    pkgId
                )
            ) {
                List<String> tempList = inspWrap.Activity_Classification.split(
                    '/'
                );
                if (Inspection_PKG_ActivityMap.containskey(tempList[0])) {
                    List<List<Inspection_PKG_Wrapper>> temp_PKG_Wrapper_List = Inspection_PKG_ActivityMap.get(
                        tempList[0]
                    );
                    Boolean addNewList = false;
                    for (Integer i = 0; i < temp_PKG_Wrapper_List.size(); i++) {
                        List<Inspection_PKG_Wrapper> wrpList = temp_PKG_Wrapper_List[
                            i
                        ];
                        Boolean isLast = i + 1 == temp_PKG_Wrapper_List.size();
                        if (wrpList.size() < 1000) {
                            // still room in this list
                            wrpList.add(inspWrap);
                        } else if (wrpList.size() == 1000 && !isLast) {
                            // this list is maxed out, continue to the next list
                            continue;
                        } else {
                            // all lists are maxed out, add a new one after this for loop
                            addNewList = true;
                        }
                    }
                    if (addNewList) {
                        temp_PKG_Wrapper_List.add(
                            new List<Inspection_PKG_Wrapper>{ inspWrap }
                        );
                    }
                    Inspection_PKG_ActivityMap.put(
                        tempList[0],
                        temp_PKG_Wrapper_List
                    );
                } else {
                    List<List<Inspection_PKG_Wrapper>> temp_PKG_Wrapper_List = new List<List<Inspection_PKG_Wrapper>>();
                    temp_PKG_Wrapper_List.add(
                        new List<Inspection_PKG_Wrapper>{ inspWrap }
                    );
                    Inspection_PKG_ActivityMap.put(
                        tempList[0],
                        temp_PKG_Wrapper_List
                    );
                }
            }
        }
        system.debug('Inspection_PKG_ActivityMap' + Inspection_PKG_ActivityMap);
    }
    public void generateOperatorAddressReportPdf() {
        Map<String, String> addressMap = new Map<String, String>();
        Map<String, Decimal> P5NumberAndMilesMap = new Map<String, Decimal>();
        Map<String, String> OrgRepaddrAndP5NumberMap = new Map<String, String>();
        List<Account> accounts;

        if (selectedCtry == 'All' && selectedSystemType == 'All') {
            accounts = [
                SELECT
                    id,
                    name,
                    RecordType.developername,
                    IETRS_Company_ID__c,
                    Org_P5_Number__c,
                    IETRS_Total_Org_Miles__c,
                    IETRS_Counties_List__c,
                    IETRS_OrganizationofRegEntity__r.Name,
                    IETRS_OrganizationofRegEntity__r.IETRS_Total_Org_Miles__c,
                    IETRS_OrganizationofRegEntity__r.IETRS_Representative__r.MailingStreet,
                    IETRS_OrganizationofRegEntity__r.IETRS_Representative__r.MailingCity,
                    IETRS_OrganizationofRegEntity__r.IETRS_Representative__r.MailingState,
                    IETRS_OrganizationofRegEntity__r.IETRS_Representative__r.MailingPostalCode,
                    IETRS_OrganizationofRegEntity__r.Org_P5_Number__c,
                    IETRS_OrganizationofRegEntity__r.IETRS_Representative_Phone__c,
                    IETRS_OrganizationofRegEntity__r.IETRS_RepresentativeFax__c,
                    IETRS_OrganizationofRegEntity__r.IETRS_Representative_24_Phone__c,
                    IETRS_OrganizationofRegEntity__r.IETRS_Total_Miles__c,
                    IETRS_OrganizationofRegEntity__r.IETRS_Company_ID__c,
                    IETRS_OrganizationofRegEntity__r.IETRS_Representative__r.FirstName,
                    IETRS_OrganizationofRegEntity__r.IETRS_Representative__r.LastName,
                    IETRS_OrganizationofRegEntity__r.IETRS_Representative__r.Title,
                    IETRS_Representative__r.MailingStreet,
                    IETRS_Representative__r.MailingCity,
                    IETRS_Representative__r.MailingState,
                    IETRS_Representative__r.MailingPostalCode,
                    IETRS_Organization_Rep_Address__c,
                    IETRS_Organization_Contact_Details__c,
                    IETRS_Representative__r.FirstName,
                    IETRS_Representative__r.LastName,
                    IETRS_Representative__r.Title,
                    IETRS_Representative_Phone__c,
                    IETRS_RepresentativeFax__c,
                    IETRS_Representative_24_Phone__c
                FROM account
                WHERE
                    IETRS_Status__c != 'Abandoned'
                    AND IETRS_Jurisdiction__c = 'Jurisdictional'
                    AND parent.parent.IETRS_Company_ID__c != '1582'
                    AND RecordType.developername !='IETRS_Archived_Account'
                ORDER BY Account.Name DESC
            ];
        } else if (selectedCtry != 'All' && selectedSystemType == 'All') {
            accounts = [
                SELECT
                    id,
                    name,
                    RecordType.developername,
                    IETRS_Company_ID__c,
                    Org_P5_Number__c,
                    IETRS_Total_Org_Miles__c,
                    IETRS_Counties_List__c,
                    IETRS_OrganizationofRegEntity__r.Name,
                    IETRS_OrganizationofRegEntity__r.IETRS_Total_Org_Miles__c,
                    IETRS_OrganizationofRegEntity__r.IETRS_Representative__r.MailingStreet,
                    IETRS_OrganizationofRegEntity__r.IETRS_Representative__r.MailingCity,
                    IETRS_OrganizationofRegEntity__r.IETRS_Representative__r.MailingState,
                    IETRS_OrganizationofRegEntity__r.IETRS_Representative__r.MailingPostalCode,
                    IETRS_OrganizationofRegEntity__r.Org_P5_Number__c,
                    IETRS_OrganizationofRegEntity__r.IETRS_Representative_Phone__c,
                    IETRS_OrganizationofRegEntity__r.IETRS_RepresentativeFax__c,
                    IETRS_OrganizationofRegEntity__r.IETRS_Representative_24_Phone__c,
                    IETRS_OrganizationofRegEntity__r.IETRS_Total_Miles__c,
                    IETRS_OrganizationofRegEntity__r.IETRS_Company_ID__c,
                    IETRS_OrganizationofRegEntity__r.IETRS_Representative__r.FirstName,
                    IETRS_OrganizationofRegEntity__r.IETRS_Representative__r.LastName,
                    IETRS_OrganizationofRegEntity__r.IETRS_Representative__r.Title,
                    IETRS_Representative__r.MailingStreet,
                    IETRS_Representative__r.MailingCity,
                    IETRS_Representative__r.MailingState,
                    IETRS_Representative__r.MailingPostalCode,
                    IETRS_Organization_Rep_Address__c,
                    IETRS_Organization_Contact_Details__c,
                    IETRS_Representative__r.FirstName,
                    IETRS_Representative__r.LastName,
                    IETRS_Representative__r.Title,
                    IETRS_Representative_Phone__c,
                    IETRS_RepresentativeFax__c,
                    IETRS_Representative_24_Phone__c
                FROM account
                WHERE
                    IETRS_Counties_List__c = :selectedCtry
                    AND IETRS_Status__c != 'Abandoned'
                    AND IETRS_Jurisdiction__c = 'Jurisdictional'
                    AND parent.parent.IETRS_Company_ID__c != '1582'
                    AND RecordType.developername !='IETRS_Archived_Account'
                ORDER BY Account.Name DESC
            ];
        } else if (selectedCtry == 'All' && selectedSystemType != 'All') {
            accounts = [
                SELECT
                    id,
                    name,
                    RecordType.developername,
                    IETRS_Company_ID__c,
                    Org_P5_Number__c,
                    IETRS_Total_Org_Miles__c,
                    IETRS_Counties_List__c,
                    IETRS_OrganizationofRegEntity__r.Name,
                    IETRS_OrganizationofRegEntity__r.IETRS_Total_Org_Miles__c,
                    IETRS_OrganizationofRegEntity__r.IETRS_Representative__r.MailingStreet,
                    IETRS_OrganizationofRegEntity__r.IETRS_Representative__r.MailingCity,
                    IETRS_OrganizationofRegEntity__r.IETRS_Representative__r.MailingState,
                    IETRS_OrganizationofRegEntity__r.IETRS_Representative__r.MailingPostalCode,
                    IETRS_OrganizationofRegEntity__r.Org_P5_Number__c,
                    IETRS_OrganizationofRegEntity__r.IETRS_Representative_Phone__c,
                    IETRS_OrganizationofRegEntity__r.IETRS_RepresentativeFax__c,
                    IETRS_OrganizationofRegEntity__r.IETRS_Representative_24_Phone__c,
                    IETRS_OrganizationofRegEntity__r.IETRS_Total_Miles__c,
                    IETRS_OrganizationofRegEntity__r.IETRS_Company_ID__c,
                    IETRS_OrganizationofRegEntity__r.IETRS_Representative__r.FirstName,
                    IETRS_OrganizationofRegEntity__r.IETRS_Representative__r.LastName,
                    IETRS_OrganizationofRegEntity__r.IETRS_Representative__r.Title,
                    IETRS_Representative__r.MailingStreet,
                    IETRS_Representative__r.MailingCity,
                    IETRS_Representative__r.MailingState,
                    IETRS_Representative__r.MailingPostalCode,
                    IETRS_Organization_Rep_Address__c,
                    IETRS_Organization_Contact_Details__c,
                    IETRS_Representative__r.FirstName,
                    IETRS_Representative__r.LastName,
                    IETRS_Representative__r.Title,
                    IETRS_Representative_Phone__c,
                    IETRS_RepresentativeFax__c,
                    IETRS_Representative_24_Phone__c
                FROM account
                WHERE
                    IETRS_Unit_Type_from_Regulated_entity__c = :selectedSystemType
                    AND IETRS_Status__c != 'Abandoned'
                    AND IETRS_Jurisdiction__c = 'Jurisdictional'
                    AND parent.parent.IETRS_Company_ID__c != '1582'
                    AND RecordType.developername !='IETRS_Archived_Account'
                ORDER BY Account.Name DESC
            ];
        } else {
            accounts = [
                SELECT
                    id,
                    name,
                    RecordType.developername,
                    IETRS_Company_ID__c,
                    Org_P5_Number__c,
                    IETRS_Total_Org_Miles__c,
                    IETRS_Counties_List__c,
                    IETRS_OrganizationofRegEntity__r.Name,
                    IETRS_OrganizationofRegEntity__r.IETRS_Total_Org_Miles__c,
                    IETRS_OrganizationofRegEntity__r.IETRS_Representative__r.MailingStreet,
                    IETRS_OrganizationofRegEntity__r.IETRS_Representative__r.MailingCity,
                    IETRS_OrganizationofRegEntity__r.IETRS_Representative__r.MailingState,
                    IETRS_OrganizationofRegEntity__r.IETRS_Representative__r.MailingPostalCode,
                    IETRS_OrganizationofRegEntity__r.Org_P5_Number__c,
                    IETRS_OrganizationofRegEntity__r.IETRS_Representative_Phone__c,
                    IETRS_OrganizationofRegEntity__r.IETRS_RepresentativeFax__c,
                    IETRS_OrganizationofRegEntity__r.IETRS_Representative_24_Phone__c,
                    IETRS_OrganizationofRegEntity__r.IETRS_Total_Miles__c,
                    IETRS_OrganizationofRegEntity__r.IETRS_Company_ID__c,
                    IETRS_OrganizationofRegEntity__r.IETRS_Representative__r.FirstName,
                    IETRS_OrganizationofRegEntity__r.IETRS_Representative__r.LastName,
                    IETRS_OrganizationofRegEntity__r.IETRS_Representative__r.Title,
                    IETRS_Representative__r.MailingStreet,
                    IETRS_Representative__r.MailingCity,
                    IETRS_Representative__r.MailingState,
                    IETRS_Representative__r.MailingPostalCode,
                    IETRS_Organization_Rep_Address__c,
                    IETRS_Organization_Contact_Details__c,
                    IETRS_Representative__r.FirstName,
                    IETRS_Representative__r.LastName,
                    IETRS_Representative__r.Title,
                    IETRS_Representative_Phone__c,
                    IETRS_RepresentativeFax__c,
                    IETRS_Representative_24_Phone__c
                FROM account
                WHERE
                    IETRS_Counties_List__c = :selectedCtry
                    AND IETRS_Unit_Type_from_Regulated_entity__c = :selectedSystemType
                    AND IETRS_Status__c != 'Abandoned'
                    AND IETRS_Jurisdiction__c = 'Jurisdictional'
                    AND parent.parent.IETRS_Company_ID__c != '1582'
                    AND RecordType.developername !='IETRS_Archived_Account'
                ORDER BY Account.Name DESC
            ];
        }
        Map<String, String> companyIDMap = new Map<String, String>();
        Map<String, Operator_Address_Wrapper> acccountNameMap = new Map<String, Operator_Address_Wrapper>();

        for (Account acct : accounts) {
            Operator_Address_Wrapper OAW = new Operator_Address_Wrapper();
            if (acct.RecordType.developername == 'Organization') {
                if (!acccountNameMap.containskey(acct.Name)) {
                    OAW.companyId = acct.IETRS_Company_ID__c;
                    OAW.operator =
                        acct.Name +
                        '\n' +
                        (acct.IETRS_Representative__r.MailingStreet == null
                            ? ' '
                            : acct.IETRS_Representative__r.MailingStreet) +
                        '\n' +
                        (acct.IETRS_Representative__r.MailingCity == null
                            ? ' '
                            : acct.IETRS_Representative__r.MailingCity) +
                        ', ' +
                        (acct.IETRS_Representative__r.MailingState == null
                            ? ' '
                            : acct.IETRS_Representative__r.MailingState) +
                        ' ' +
                        (acct.IETRS_Representative__r.MailingPostalCode == null
                            ? ' '
                            : acct.IETRS_Representative__r.MailingPostalCode);
                    OAW.p5Number = acct.Org_P5_Number__c;
                    OAW.contactPerson =
                        (acct.IETRS_Representative__r.FirstName == null
                            ? ' '
                            : acct.IETRS_Representative__r.FirstName) +
                        ' ' +
                        (acct.IETRS_Representative__r.LastName == null
                            ? ' '
                            : acct.IETRS_Representative__r.LastName) +
                        ', ' +
                        (acct.IETRS_Representative__r.Title == null
                            ? ' '
                            : acct.IETRS_Representative__r.Title);
                    OAW.phone =
                        'Phone:' +
                        (acct.IETRS_Representative_Phone__c == null
                            ? ' '
                            : acct.IETRS_Representative_Phone__c);
                    OAW.fax =
                        'Fax:' +
                        (acct.IETRS_RepresentativeFax__c == null
                            ? ' '
                            : acct.IETRS_RepresentativeFax__c);
                    OAW.Hour_Phone =
                        '24 Hour:' +
                        (acct.IETRS_Representative_24_Phone__c == null
                            ? ' '
                            : acct.IETRS_Representative_24_Phone__c);
                    OAW.totalMiles = acct.IETRS_Total_Org_Miles__c;
                    acccountNameMap.put(acct.Name, OAW);
                } else {
                    if (acct.IETRS_Total_Org_Miles__c != null) {
                        Operator_Address_Wrapper tempOAW = acccountNameMap.get(
                            acct.IETRS_OrganizationofRegEntity__r.Name
                        );
                        tempOAW.totalMiles = tempOAW.totalMiles; //+acct.IETRS_Total_Org_Miles__c;
                        acccountNameMap.put(acct.Name, tempOAW);
                    }
                }
            } else {
                if (
                    !acccountNameMap.containskey(
                        acct.IETRS_OrganizationofRegEntity__r.Name
                    )
                ) {
                    OAW.companyId = acct.IETRS_OrganizationofRegEntity__r.IETRS_Company_ID__c;
                    OAW.operator =
                        acct.IETRS_OrganizationofRegEntity__r.Name +
                        '\n' +
                        (acct.IETRS_OrganizationofRegEntity__r.IETRS_Representative__r.MailingStreet ==
                            null
                            ? ' '
                            : acct.IETRS_OrganizationofRegEntity__r.IETRS_Representative__r.MailingStreet) +
                        '\n' +
                        (acct.IETRS_OrganizationofRegEntity__r.IETRS_Representative__r.MailingCity ==
                            null
                            ? ' '
                            : acct.IETRS_OrganizationofRegEntity__r.IETRS_Representative__r.MailingCity) +
                        ', ' +
                        (acct.IETRS_OrganizationofRegEntity__r.IETRS_Representative__r.MailingState ==
                            null
                            ? ' '
                            : acct.IETRS_OrganizationofRegEntity__r.IETRS_Representative__r.MailingState) +
                        ' ' +
                        (acct.IETRS_OrganizationofRegEntity__r.IETRS_Representative__r.MailingPostalCode ==
                            null
                            ? ' '
                            : acct.IETRS_OrganizationofRegEntity__r.IETRS_Representative__r.MailingPostalCode);
                    OAW.p5Number = (acct.IETRS_OrganizationofRegEntity__r.Org_P5_Number__c ==
                        null
                        ? ' '
                        : acct.IETRS_OrganizationofRegEntity__r.Org_P5_Number__c);
                    OAW.contactPerson =
                        (acct.IETRS_OrganizationofRegEntity__r.IETRS_Representative__r.FirstName ==
                            null
                            ? ' '
                            : acct.IETRS_OrganizationofRegEntity__r.IETRS_Representative__r.FirstName) +
                        ' ' +
                        (acct.IETRS_OrganizationofRegEntity__r.IETRS_Representative__r.LastName ==
                            null
                            ? ' '
                            : acct.IETRS_OrganizationofRegEntity__r.IETRS_Representative__r.LastName) +
                        ', ' +
                        (acct.IETRS_OrganizationofRegEntity__r.IETRS_Representative__r.Title ==
                            null
                            ? ' '
                            : acct.IETRS_OrganizationofRegEntity__r.IETRS_Representative__r.Title);
                    OAW.phone =
                        'Phone:' +
                        (acct.IETRS_OrganizationofRegEntity__r.IETRS_Representative_Phone__c ==
                            null
                            ? ' '
                            : acct.IETRS_OrganizationofRegEntity__r.IETRS_Representative_Phone__c);
                    OAW.fax =
                        'Fax:' +
                        (acct.IETRS_OrganizationofRegEntity__r.IETRS_RepresentativeFax__c ==
                            null
                            ? ' '
                            : acct.IETRS_OrganizationofRegEntity__r.IETRS_RepresentativeFax__c);
                    OAW.Hour_Phone =
                        '24 Hour:' +
                        (acct.IETRS_OrganizationofRegEntity__r.IETRS_Representative_24_Phone__c ==
                            null
                            ? ' '
                            : acct.IETRS_OrganizationofRegEntity__r.IETRS_Representative_24_Phone__c);
                    OAW.totalMiles = acct.IETRS_OrganizationofRegEntity__r.IETRS_Total_Org_Miles__c;
                    acccountNameMap.put(
                        acct.IETRS_OrganizationofRegEntity__r.Name,
                        OAW
                    );
                } else {
                    if (
                        acct.IETRS_OrganizationofRegEntity__r.IETRS_Total_Org_Miles__c !=
                        null
                    ) {
                        Operator_Address_Wrapper tempOAW = acccountNameMap.get(
                            acct.IETRS_OrganizationofRegEntity__r.Name
                        );
                        tempOAW.totalMiles = tempOAW.totalMiles; //+acct.IETRS_OrganizationofRegEntity__r.IETRS_Total_Org_Miles__c;
                        acccountNameMap.put(
                            acct.IETRS_OrganizationofRegEntity__r.Name,
                            tempOAW
                        );
                    }
                }
            }
        }

        List<Operator_Address_Wrapper> OAWList = acccountNameMap.values();
        List<String> OAWListKeys = new List<String>();
        OAWListKeys.addAll(acccountNameMap.keySet());
        OAWListKeys.sort();
        totalOperators = OAWListKeys.size();
        Integer EachPageRows = 11;
        OAWListMap = new Map<String, List<Operator_Address_Wrapper>>();
        operatorCountMap = new Map<String, String>();
        operatorKeys = new List<String>();
        if (OAWListKeys.size() > EachPageRows) {
            Integer OAWListKeysSize = OAWListKeys.size();
            Integer OAWListKeyDevide = OAWListKeysSize / EachPageRows;
            Integer remainingList =
                OAWListKeysSize - (EachPageRows) * OAWListKeyDevide;
            for (Integer z = 1; z <= OAWListKeyDevide; z++) {
                List<Operator_Address_Wrapper> temp = new List<Operator_Address_Wrapper>();
                for (
                    integer x = (z - 1) * EachPageRows;
                    x <= (EachPageRows * z) - 1;
                    x++
                ) {
                    temp.add(acccountNameMap.get(OAWListKeys[x]));
                }

                OAWListMap.put(
                    String.valueOf((z - 1) * EachPageRows) +
                    '-' +
                    String.valueOf((EachPageRows * z) - 1),
                    temp
                );
                operatorKeys.add(
                    String.valueOf((z - 1) * EachPageRows) +
                    '-' +
                    String.valueOf((EachPageRows * z) - 1)
                );
                operatorCountMap.put(
                    String.valueOf((z - 1) * EachPageRows) +
                    '-' +
                    String.valueOf((EachPageRows * z) - 1),
                    ''
                );
            }
            List<Operator_Address_Wrapper> temp1 = new List<Operator_Address_Wrapper>();
            for (
                integer y = (EachPageRows * OAWListKeyDevide) ;
                y < OAWListKeysSize;
                y++
            ) {
                temp1.add(acccountNameMap.get(OAWListKeys[y]));
            }
            OAWListMap.put(
                String.valueOf((EachPageRows * OAWListKeyDevide) - 1) +
                '-' +
                String.valueOf(OAWListKeysSize),
                temp1
            );
            operatorKeys.add(
                String.valueOf((EachPageRows * OAWListKeyDevide) - 1) +
                '-' +
                String.valueOf(OAWListKeysSize)
            );
            operatorCountMap.put(
                String.valueOf((EachPageRows * OAWListKeyDevide) - 1) +
                '-' +
                String.valueOf(OAWListKeysSize),
                'Total Operators: ' + String.valueOf(totalOperators)
            );
        } else {
            OAWListMap.put(
                String.valueOf(0) +
                '-' +
                String.valueOf(OAWListKeys.size() - 1),
                OAWList
            );
            operatorKeys.add(
                String.valueOf(0) +
                '-' +
                String.valueOf(OAWListKeys.size() - 1)
            );
            operatorCountMap.put(
                String.valueOf(0) +
                '-' +
                String.valueOf(OAWListKeys.size() - 1),
                'Total Operators: ' + String.valueOf(totalOperators)
            );
        }
    }
    public void generateSystemMilesByRegionReportPdf() {
        List<IETRS_County_Group__c> ICGList;
        List<Account> accounts;
        IETRS_Coutries__c Regions = [
            SELECT id, Country_Names__c
            FROM IETRS_Coutries__c
            LIMIT 1
        ];

        //if(selectedReg=='All')
        //{
        // ICGList=[SELECT id, name, IETRS_Group_Type__c from IETRS_County_Group__c where IETRS_Group_Type__c='Region'];
        regionNames = Regions.Country_Names__c.split(';');
        //}
        //else
        //{
        // ICGList=[SELECT id, name, IETRS_Group_Type__c from IETRS_County_Group__c where IETRS_Group_Type__c='Region' and name=:selectedReg];
        // regionNames.add(selectedReg);
        //}

        // for(IETRS_County_Group__c ICG:ICGList)
        // {
        //     regionNames.add(ICG.name);
        regionNames.sort();
        // }
        system.debug('##Regions' + regionNames);

        if (selectedMile == 'Jurisdictional') {
            accounts = [
                SELECT
                    id,
                    ParentId,
                    name,
                    IETRS_Product_Class__c,
                    IETRS_Product_Sub_Class__c,
                    Type,
                    IETRS_Entity_Sub_Type__c,
                    IETRS_Intra_Interstate__c,
                    IETRS_Total_Miles__c,
                    IETRS_Region__r.name
                FROM Account
                WHERE
                    IETRS_OrganizationofRegEntity__c != NULL
                    AND IETRS_Unit_Parent__c != NULL
                    AND IETRS_Product_Class__c != NULL
                    AND IETRS_Product_Sub_Class__c != NULL
                    AND IETRS_Jurisdiction__c = :selectedMile
                    AND Parent.IETRS_Unit_ID__c != '4728'
                    AND IETRS_Status__c IN ('Active', 'Idle')
                    AND IETRS_Entity_Code__c != 'Y-Company System (Non-Physical)'
                    AND IETRS_Region__r.name != '10-EL Paso (RETIRED)'
                    AND RecordType.DeveloperName != 'IETRS_Archived_Account'
            ];
        } else if (selectedMile == 'Non-jurisdictional') {
            accounts = [
                SELECT
                    id,
                    ParentId,
                    name,
                    IETRS_Product_Class__c,
                    IETRS_Product_Sub_Class__c,
                    Type,
                    IETRS_Entity_Sub_Type__c,
                    IETRS_Intra_Interstate__c,
                    IETRS_Total_Miles__c,
                    IETRS_Region__r.name
                FROM Account
                WHERE
                    IETRS_OrganizationofRegEntity__c != NULL
                    AND IETRS_Unit_Parent__c != NULL
                    AND IETRS_Product_Class__c != NULL
                    AND IETRS_Product_Sub_Class__c != NULL
                    AND Parent.IETRS_Unit_ID__c != '4728'
                    AND IETRS_Status__c IN ('Active', 'Idle')
                    AND IETRS_Entity_Code__c != 'Y-Company System (Non-Physical)'
                    AND IETRS_Region__r.name != '10-EL Paso (RETIRED)'
                    AND RecordType.DeveloperName != 'IETRS_Archived_Account'
            ];
        }
        /* if(test.isRunningTest()){
             accounts=[SELECT id,ParentId,name,IETRS_Product_Class__c,IETRS_Product_Sub_Class__c,Type,IETRS_Entity_Sub_Type__c,IETRS_Intra_Interstate__c,IETRS_Total_Miles__c,IETRS_Region__r.name FROM Account ];
        }*/
        prodMap = new Map<String, Map<String, Map<String, Map<String, Map<String, Integer>>>>>();
        Map<String, Map<String, Map<String, Map<String, Map<String, Map<String, Decimal>>>>>> prodMapTemp = new Map<String, Map<String, Map<String, Map<String, Map<String, Map<String, Decimal>>>>>>();
        for (Account acct : accounts) {
            String subTypekey;
            //if(acct.IETRS_Intra_Interstate__c !=null /*&& acct.IETRS_Intra_Interstate__c == 'Intrastate'*/)
            if (acct.IETRS_Intra_Interstate__c == 'Intrastate') {
                subTypekey = acct.IETRS_Entity_Sub_Type__c;
            } else {
                if (selectedMile != 'Jurisdictional')
                    subTypekey =
                        'Interstate' +
                        ' ' +
                        acct.IETRS_Entity_Sub_Type__c;
                system.debug('line1117');
                system.debug(subTypekey);
            }

            /* if(acct.IETRS_Intra_Interstate__c !=null && acct.IETRS_Intra_Interstate__c == 'Interstate')
            {
                subTypekey='Interstate'+' '+acct.IETRS_Entity_Sub_Type__c;
            }*/

            if (
                subTypekey == 'Interstate Municipal' ||
                subTypekey == 'Interstate Private Rural Extension' ||
                subTypekey == 'Interstate Apartment' ||
                subTypekey == 'Interstate Housing Authority' ||
                subTypekey == 'Interstate Mobile Home Park' ||
                subTypekey == 'Interstate null'
            ) {
            } else {
                if (subTypekey != null) {
                    system.debug(
                        '#####Added acct.IETRS_Product_Class__c  ' +
                        acct.IETRS_Product_Class__c
                    );
                    system.debug('#####Added prodMapTemp  ' + prodMapTemp);
                    system.debug(
                        '#####Added prodMapTemp keyset ' + prodMapTemp.KeySet()
                    );
                    //Product Class
                    if (prodMapTemp.containskey(acct.IETRS_Product_Class__c)) {
                        //Account Type
                        Map<String, Map<String, Map<String, Map<String, Map<String, Decimal>>>>> temptypeMap = prodMapTemp.get(
                            acct.IETRS_Product_Class__c
                        );
                        if (temptypeMap.containskey(acct.Type)) {
                            //Product Sub Class
                            Map<String, Map<String, Map<String, Map<String, Decimal>>>> TempPrdSubClassMap = temptypeMap.get(
                                acct.Type
                            );
                            if (
                                TempPrdSubClassMap.containskey(
                                    acct.IETRS_Product_Sub_Class__c
                                )
                            ) {
                                //Sub Type i.e. Entity Sub Type. See subTypekey assignment logic above
                                Map<String, Map<String, Map<String, Decimal>>> TempsubTypeMap = TempPrdSubClassMap.get(
                                    acct.IETRS_Product_Sub_Class__c
                                );
                                if (TempsubTypeMap.containskey(subTypekey)) {
                                    //Region Name
                                    Map<String, Map<String, Decimal>> tempregionMap = TempsubTypeMap.get(
                                        subTypekey
                                    );
                                    if (
                                        tempregionMap.containskey(
                                            acct.IETRS_Region__r.name
                                        )
                                    ) {
                                        //Parent ID
                                        Map<String, Decimal> accParentMap = tempregionMap.get(
                                            acct.IETRS_Region__r.name
                                        );
                                        if (
                                            !accParentMap.containskey(
                                                acct.ParentId
                                            )
                                        ) {
                                            if (
                                                acct.IETRS_Total_Miles__c ==
                                                null
                                            ) {
                                                accParentMap.put(
                                                    acct.ParentId,
                                                    0
                                                );
                                            } else {
                                                accParentMap.put(
                                                    acct.ParentId,
                                                    acct.IETRS_Total_Miles__c
                                                );
                                            }
                                            //Region
                                            tempregionMap.put(
                                                acct.IETRS_Region__r.name,
                                                accParentMap
                                            );
                                            //Sub Type i.e. Entity Sub Type
                                            system.debug('line1166');
                                            system.debug(subTypekey);
                                            system.debug(
                                                acct.IETRS_Total_Miles__c
                                            );
                                            TempsubTypeMap.put(
                                                subTypekey,
                                                tempregionMap
                                            );
                                            //Product Sub Class
                                            TempPrdSubClassMap.put(
                                                acct.IETRS_Product_Sub_Class__c,
                                                TempsubTypeMap
                                            );
                                            //Acount Type
                                            temptypeMap.put(
                                                acct.Type,
                                                TempPrdSubClassMap
                                            );
                                            //Product Class
                                            prodMapTemp.put(
                                                acct.IETRS_Product_Class__c,
                                                temptypeMap
                                            );
                                        } else {
                                            //Parent ID ELSE - Not in Map already
                                            Decimal miles = accParentMap.get(
                                                acct.ParentId
                                            );
                                            if (
                                                acct.IETRS_Total_Miles__c !=
                                                null
                                            ) {
                                                accParentMap.put(
                                                    acct.ParentId,
                                                    miles +
                                                    acct.IETRS_Total_Miles__c
                                                );
                                            }
                                            tempregionMap.put(
                                                acct.IETRS_Region__r.name,
                                                accParentMap
                                            );
                                            TempsubTypeMap.put(
                                                subTypekey,
                                                tempregionMap
                                            );
                                            TempPrdSubClassMap.put(
                                                acct.IETRS_Product_Sub_Class__c,
                                                TempsubTypeMap
                                            );
                                            temptypeMap.put(
                                                acct.Type,
                                                TempPrdSubClassMap
                                            );
                                            prodMapTemp.put(
                                                acct.IETRS_Product_Class__c,
                                                temptypeMap
                                            );
                                        }
                                        //Region Name ELSE - Not in Map already
                                    } else {
                                        Map<String, Decimal> accParentMap1 = new Map<String, Decimal>();
                                        if (acct.IETRS_Total_Miles__c == null) {
                                            accParentMap1.put(acct.ParentId, 0);
                                        } else {
                                            accParentMap1.put(
                                                acct.ParentId,
                                                acct.IETRS_Total_Miles__c
                                            );
                                        }

                                        tempregionMap.put(
                                            acct.IETRS_Region__r.name,
                                            accParentMap1
                                        );
                                        TempsubTypeMap.put(
                                            subTypekey,
                                            tempregionMap
                                        );
                                        TempPrdSubClassMap.put(
                                            acct.IETRS_Product_Sub_Class__c,
                                            TempsubTypeMap
                                        );
                                        temptypeMap.put(
                                            acct.Type,
                                            TempPrdSubClassMap
                                        );
                                        prodMapTemp.put(
                                            acct.IETRS_Product_Class__c,
                                            temptypeMap
                                        );
                                    }
                                } else {
                                    //Sub Type ELSE - Not in Map already
                                    Map<String, Map<String, Decimal>> regionMap = new Map<String, Map<String, Decimal>>();
                                    Map<String, Decimal> accParentMap2 = new Map<String, Decimal>();

                                    if (acct.IETRS_Total_Miles__c == null) {
                                        accParentMap2.put(acct.ParentId, 0);
                                    } else {
                                        accParentMap2.put(
                                            acct.ParentId,
                                            acct.IETRS_Total_Miles__c
                                        );
                                    }
                                    system.debug('line1220');
                                    system.debug(subTypekey);
                                    system.debug(acct.IETRS_Total_Miles__c);

                                    regionMap.put(
                                        acct.IETRS_Region__r.name,
                                        accParentMap2
                                    );
                                    TempsubTypeMap.put(subTypekey, regionMap);
                                    TempPrdSubClassMap.put(
                                        acct.IETRS_Product_Sub_Class__c,
                                        TempsubTypeMap
                                    );
                                    temptypeMap.put(
                                        acct.Type,
                                        TempPrdSubClassMap
                                    );
                                    prodMapTemp.put(
                                        acct.IETRS_Product_Class__c,
                                        temptypeMap
                                    );
                                }
                            } else {
                                //Product Sub Class ELSE - Not in Map already
                                Map<String, Map<String, Map<String, Decimal>>> subTypeMap = new Map<String, Map<String, Map<String, Decimal>>>();
                                Map<String, Map<String, Decimal>> regionMap = new Map<String, Map<String, Decimal>>();
                                Map<String, Decimal> accParentMap3 = new Map<String, Decimal>();

                                if (acct.IETRS_Total_Miles__c == null) {
                                    accParentMap3.put(acct.ParentId, 0);
                                } else {
                                    accParentMap3.put(
                                        acct.ParentId,
                                        acct.IETRS_Total_Miles__c
                                    );
                                }

                                regionMap.put(
                                    acct.IETRS_Region__r.name,
                                    accParentMap3
                                );
                                subTypeMap.put(subTypekey, regionMap);
                                TempPrdSubClassMap.put(
                                    acct.IETRS_Product_Sub_Class__c,
                                    subTypeMap
                                );
                                temptypeMap.put(acct.Type, TempPrdSubClassMap);
                                prodMapTemp.put(
                                    acct.IETRS_Product_Class__c,
                                    temptypeMap
                                );
                            }
                        } else {
                            //Account Type ELSE - Not in Map already
                            Map<String, Map<String, Map<String, Map<String, Decimal>>>> prdSubClassMap = new Map<String, Map<String, Map<String, Map<String, Decimal>>>>();
                            Map<String, Map<String, Map<String, Decimal>>> subTypeMap = new Map<String, Map<String, Map<String, Decimal>>>();
                            Map<String, Map<String, Decimal>> regionMap = new Map<String, Map<String, Decimal>>();
                            Map<String, Decimal> accParentMap4 = new Map<String, Decimal>();
                            if (acct.IETRS_Total_Miles__c == null) {
                                accParentMap4.put(acct.ParentId, 0);
                            } else {
                                accParentMap4.put(
                                    acct.ParentId,
                                    acct.IETRS_Total_Miles__c
                                );
                            }

                            regionMap.put(
                                acct.IETRS_Region__r.name,
                                accParentMap4
                            );
                            subTypeMap.put(subTypekey, regionMap);
                            prdSubClassMap.put(
                                acct.IETRS_Product_Sub_Class__c,
                                subTypeMap
                            );
                            temptypeMap.put(acct.Type, prdSubClassMap);
                            prodMapTemp.put(
                                acct.IETRS_Product_Class__c,
                                temptypeMap
                            );
                        }
                    } else {
                        //Product Class ELSE - Not in Map already
                        Map<String, Map<String, Map<String, Map<String, Map<String, Decimal>>>>> typeMap = new Map<String, Map<String, Map<String, Map<String, Map<String, Decimal>>>>>();
                        Map<String, Map<String, Map<String, Map<String, Decimal>>>> prdSubClassMap = new Map<String, Map<String, Map<String, Map<String, Decimal>>>>();
                        Map<String, Map<String, Map<String, Decimal>>> subTypeMap = new Map<String, Map<String, Map<String, Decimal>>>();
                        Map<String, Map<String, Decimal>> regionMap = new Map<String, Map<String, Decimal>>();
                        Map<String, Decimal> parentIDMap = new Map<String, Decimal>();
                        if (acct.IETRS_Total_Miles__c == null) {
                            parentIDMap.put(acct.ParentId, 0);
                        } else {
                            parentIDMap.put(
                                acct.ParentId,
                                acct.IETRS_Total_Miles__c
                            );
                        }

                        regionMap.put(acct.IETRS_Region__r.name, parentIDMap);
                        subTypeMap.put(subTypekey, regionMap);
                        prdSubClassMap.put(
                            acct.IETRS_Product_Sub_Class__c,
                            subTypeMap
                        );
                        typeMap.put(acct.Type, prdSubClassMap);
                        prodMapTemp.put(acct.IETRS_Product_Class__c, typeMap);
                    }
                }
            }
        }
        //System.debug('#prodMap.keySet()'+prodMapTemp);
        //Product Class
        for (String prodClass : prodMapTemp.keySet()) {
            Map<String, Map<String, Map<String, Map<String, Map<String, Decimal>>>>> type_Map = prodMapTemp.get(
                prodClass
            );
            Map<String, Map<String, Map<String, Map<String, Integer>>>> tyMap = new Map<String, Map<String, Map<String, Map<String, Integer>>>>();
            //Account Type
            for (String typ : type_Map.keySet()) {
                Map<String, Map<String, Map<String, Map<String, Decimal>>>> prdSubClass_Map = type_Map.get(
                    typ
                );
                Map<String, Map<String, Map<String, Integer>>> prSClassMap = new Map<String, Map<String, Map<String, Integer>>>();
                //Product Sub Class
                for (String prdSubClass : prdSubClass_Map.keySet()) {
                    Map<String, Map<String, Map<String, Decimal>>> subType_Map = prdSubClass_Map.get(
                        prdSubClass
                    );
                    Map<String, Map<String, Integer>> sTypeMap = new Map<String, Map<String, Integer>>();
                    //Entity Sub Type
                    for (String subType : subType_Map.keySet()) {
                        Map<string, Map<String, Decimal>> region_Map = subType_Map.get(
                            subType
                        );
                        Map<String, Integer> rgMap = new Map<String, Integer>();
                        Map<String, Integer> rgMapDummy = new Map<String, Integer>();
                        //Region
                        for (String reg : region_Map.keySet()) {
                            rgMapDummy.put(reg, 0);
                        }

                        for (String reg : region_Map.keySet()) {
                            Decimal miles = 0;
                            //Total Miles
                            for (Decimal mile : region_Map.get(reg).values()) {
                                if (mile != null) {
                                    miles = miles + mile;
                                }
                            }
                            rgMap.put(reg, Integer.valueOf(miles));
                        }
                        sTypeMap.put(subType, rgMap);
                        /* if(prodClass=='Gas' && typ=='Transmission' && prdSubClass=='Natural')
                        {
                            
                            sTypeMap.put('Municipal Supply',rgMapDummy);
                        }
                        /* //commented by because as raised bug to remove the row 14508 client
                        if(prodClass=='Gas' && typ=='Storage' && prdSubClass=='Natural')
                        {
                            
                            sTypeMap.put('Aboveground',rgMapDummy);
                        }*/ //commented by because as raised bug to remove the row 14508 client
                        /* if(prodClass=='Liquid' && typ=='Storage' && prdSubClass=='HVL')
                        {
                            
                            sTypeMap.put('Interstate Belowground',rgMapDummy);
                        }
                        // if(prodClass=='Liquid' && typ=='Transmission' && prdSubClass=='Carbon Dioxide')
                        // {
                            
                        //     sTypeMap.put('Interstate Transmission',rgMapDummy);
                        // }
                        if(prodClass=='Liquid' && typ=='Transmission' && prdSubClass=='Non-HVL')
                        {
                            
                            sTypeMap.put('Interstate Transmission',rgMapDummy);
                        }
                        if(prodClass=='Liquid' && typ=='Transmission' && prdSubClass=='Crude')
                        {
                            
                            sTypeMap.put('Interstate Transmission',rgMapDummy);
                        }*/
                    }
                    prSClassMap.put(prdSubClass, sTypeMap);
                }
                tyMap.put(typ, prSClassMap);
            }
            prodMap.put(prodClass, tyMap);
        }
        //system.debug('#prodMap'+prodMap);
        for (String prodClass : prodMap.keySet()) {
            Map<String, Map<String, Map<String, Map<String, Integer>>>> type_Map = prodMap.get(
                prodClass
            );
            for (String typ : type_Map.keySet()) {
                Map<String, Map<String, Map<String, Integer>>> prdSubClass_Map = prodMap.get(
                        prodClass
                    )
                    .get(typ);
                for (String prdSubClass : prdSubClass_Map.keySet()) {
                    Map<String, Map<String, Integer>> subType_Map = prodMap.get(
                            prodClass
                        )
                        .get(typ)
                        .get(prdSubClass);
                    for (String subType : subType_Map.keySet()) {
                        Map<String, Integer> region_Map = new Map<String, Integer>();
                        system.debug(
                            '#subType:' +
                            subType +
                            ':' +
                            subType_Map.get(subType).keySet()
                        );
                        for (String reg : subType_Map.get(subType).keySet()) {
                            region_Map.put(
                                reg,
                                prodMap.get(prodClass)
                                    .get(typ)
                                    .get(prdSubClass)
                                    .get(subType)
                                    .get(reg)
                            );

                            System.debug('#region_Map' + region_Map);
                        }
                        for (String regionName : regionNames) {
                            if (!region_Map.containskey(regionName)) {
                                region_Map.put(regionName, 0);
                            }
                        }
                        subType_Map.put(subType, region_Map);
                    }
                    prdSubClass_Map.put(prdSubClass, subType_Map);
                }
                type_Map.put(typ, prdSubClass_Map);
            }
            prodMap.put(prodClass, type_Map);
        }
        prodMapSubClassTotalMiles = new Map<String, Map<String, Map<String, Map<String, Integer>>>>();
        for (String prodClass : prodMap.keySet()) {
            Map<String, Map<String, Map<String, Map<String, Integer>>>> type = prodMap.get(
                prodClass
            );
            Map<String, Map<String, Map<String, Integer>>> TempType = new Map<String, Map<String, Map<String, Integer>>>();
            for (String typ : type.keySet()) {
                Map<String, Map<String, Map<String, Integer>>> prodSubClass = type.get(
                    typ
                );
                Map<String, Map<String, Integer>> TempProdClass = new Map<String, Map<String, Integer>>();
                for (String pSc : prodSubClass.keySet()) {
                    Map<String, Map<String, Integer>> subType = prodSubClass.get(
                        pSc
                    );

                    Map<String, Integer> regMap = new Map<String, Integer>();
                    for (String sType : subType.keySet()) {
                        Map<String, Integer> TempReg = subType.get(sType);
                        for (String reg : TempReg.keySet()) {
                            if (regMap.containsKey(reg)) {
                                Integer miles = regMap.get(reg);
                                regMap.put(reg, miles + TempReg.get(reg));
                            } else {
                                regMap.put(reg, TempReg.get(reg));
                            }
                        }
                    }
                    TempProdClass.put(pSc, regMap);
                }
                TempType.put(typ, TempProdClass);
            }
            prodMapSubClassTotalMiles.put(prodClass, TempType);
        }
        prodMapTypeTotalMiles = new Map<String, Map<String, Map<String, Integer>>>();
        for (String PMCTU : prodMapSubClassTotalMiles.keySet()) {
            Map<String, Map<String, Map<String, Integer>>> prodClass = prodMapSubClassTotalMiles.get(
                PMCTU
            );
            Map<String, Map<String, Integer>> tempTypeMap = new Map<String, Map<String, Integer>>();

            for (String pcKey : prodClass.keySet()) {
                Map<String, Map<String, Integer>> type = prodClass.get(pcKey);
                Map<String, Integer> TempRegMap = new Map<String, Integer>();
                for (String typ : type.keySet()) {
                    Map<String, Integer> regMap = type.get(typ);
                    for (String reg : regMap.keySet()) {
                        if (TempRegMap.containsKey(reg)) {
                            Integer miles = TempRegMap.get(reg);
                            TempRegMap.put(reg, miles + regMap.get(reg));
                        } else {
                            TempRegMap.put(reg, regMap.get(reg));
                        }
                    }
                }
                tempTypeMap.put(pcKey, TempRegMap);
            }
            prodMapTypeTotalMiles.put(PMCTU, tempTypeMap);
        }
        prodMapClassTotalMiles = new Map<String, Map<String, Integer>>();
        for (String prodClass : prodMap.keySet()) {
            Map<String, Integer> regMap = new Map<String, Integer>();
            Map<String, Map<String, Map<String, Map<String, Integer>>>> type = prodMap.get(
                prodClass
            );

            for (String typ : type.keySet()) {
                Map<String, Map<String, Map<String, Integer>>> prodSubClass = type.get(
                    typ
                );

                for (String pSc : prodSubClass.keySet()) {
                    Map<String, Map<String, Integer>> subType = prodSubClass.get(
                        pSc
                    );

                    for (String sType : subType.keySet()) {
                        Map<String, Integer> TempReg = subType.get(sType);
                        for (String reg : TempReg.keySet()) {
                            if (regMap.containsKey(reg)) {
                                Integer miles = regMap.get(reg);
                                regMap.put(reg, miles + TempReg.get(reg));
                            } else {
                                regMap.put(reg, TempReg.get(reg));
                            }
                        }
                    }
                }
            }
            prodMapClassTotalMiles.put(prodClass, regMap);
        }
        TotalMiles = new Map<String, Integer>();
        for (String prodClass : prodMapClassTotalMiles.keySet()) {
            Map<String, Integer> regMap = prodMapClassTotalMiles.get(prodClass);
            for (String reg : regMap.keySet()) {
                if (TotalMiles.containsKey(reg)) {
                    Integer miles = TotalMiles.get(reg);
                    TotalMiles.put(reg, miles + regMap.get(reg));
                } else {
                    TotalMiles.put(reg, regMap.get(reg));
                }
            }
        }
    }
    public void generateSystemUnitsByRegionReportPdf() {
        List<Account> accounts;
        IETRS_Coutries__c Regions = [
            SELECT id, Country_Names__c
            FROM IETRS_Coutries__c
            LIMIT 1
        ];
        //for(IETRS_County_Group__c ICG:[SELECT id, name, IETRS_Group_Type__c from IETRS_County_Group__c where IETRS_Group_Type__c='Region'])
        //{
        //   regionNames.add(ICG.name);
        regionNames = Regions.Country_Names__c.split(';');
        regionNames.sort();
        //}
        if (selectedUnit == 'Jurisdictional') {
            accounts = [
                SELECT
                    id,
                    name,
                    ParentId,
                    IETRS_Jurisdiction__c,
                    IETRS_Product_Class__c,
                    IETRS_Product_Sub_Class__c,
                    Type,
                    IETRS_Entity_Sub_Type__c,
                    IETRS_Intra_Interstate__c,
                    IETRS_Total_Miles__c,
                    IETRS_Region__r.name
                FROM Account
                WHERE
                    IETRS_OrganizationofRegEntity__c != NULL
                    AND IETRS_Unit_Parent__c != NULL
                    AND IETRS_Product_Class__c != NULL
                    AND IETRS_Product_Sub_Class__c != NULL
                    AND IETRS_Entity_Sub_Type__c != NULL
                    AND IETRS_Jurisdiction__c = :selectedUnit
                    AND Parent.IETRS_Unit_ID__c != '4728'
                    AND IETRS_Status__c IN ('Active', 'Idle')
                    AND IETRS_Entity_Code__c != 'Y-Company System (Non-Physical)'
                    AND IETRS_Region__r.Name != '10-El Paso (RETIRED)'
            ];
        } else if (selectedUnit == 'Non-jurisdictional') {
            accounts = [
                SELECT
                    id,
                    name,
                    ParentId,
                    IETRS_Jurisdiction__c,
                    IETRS_Product_Class__c,
                    IETRS_Product_Sub_Class__c,
                    Type,
                    IETRS_Entity_Sub_Type__c,
                    IETRS_Intra_Interstate__c,
                    IETRS_Total_Miles__c,
                    IETRS_Region__r.name
                FROM Account
                WHERE
                    IETRS_OrganizationofRegEntity__c != NULL
                    AND IETRS_Unit_Parent__c != NULL
                    AND IETRS_Product_Class__c != NULL
                    AND IETRS_Product_Sub_Class__c != NULL
                    AND IETRS_Entity_Sub_Type__c != NULL
                    AND Parent.IETRS_Unit_ID__c != '4728'
                    AND IETRS_Status__c IN ('Active', 'Idle')
                    AND IETRS_Entity_Code__c != 'Y-Company System (Non-Physical)'
                    AND IETRS_Region__r.Name != '10-El Paso (RETIRED)'
            ];
        }
        prodMapUnits = new Map<String, Map<String, Map<String, Map<String, Map<String, Integer>>>>>();
        Map<String, Map<String, Map<String, Map<String, Map<String, Map<String, Integer>>>>>> prodMapUnitsTemp = new Map<String, Map<String, Map<String, Map<String, Map<String, Map<String, Integer>>>>>>();
        for (Account acct : accounts) {
            String subTypekey;
            if (
                acct.IETRS_Intra_Interstate__c != null // && acct.IETRS_Intra_Interstate__c!='Interstate' added by ayesha
            ) {
                subTypekey = acct.IETRS_Entity_Sub_Type__c;
            } else {
                if (selectedUnit != 'Jurisdictional')
                    subTypekey =
                        'Interstate' +
                        ' ' +
                        acct.IETRS_Entity_Sub_Type__c;
            }
            if (
                subTypekey == 'Interstate Municipal' ||
                subTypekey == 'Interstate Private Rural Extension' ||
                subTypekey == 'Interstate Apartment' ||
                subTypekey == 'Interstate Housing Authority' ||
                subTypekey == 'Interstate Mobile Home Park' ||
                subTypekey == 'Interstate null'
            ) {
            } else {
                if (subTypekey != null) {
                    if (
                        prodMapUnitsTemp.containskey(
                            acct.IETRS_Product_Class__c
                        )
                    ) {
                        Map<String, Map<String, Map<String, Map<String, Map<String, Integer>>>>> temptypeMap = prodMapUnitsTemp.get(
                            acct.IETRS_Product_Class__c
                        );
                        if (temptypeMap.containskey(acct.Type)) {
                            Map<String, Map<String, Map<String, Map<String, Integer>>>> TempPrdSubClassMap = temptypeMap.get(
                                acct.Type
                            );
                            if (
                                TempPrdSubClassMap.containskey(
                                    acct.IETRS_Product_Sub_Class__c
                                )
                            ) {
                                Map<String, Map<String, Map<String, Integer>>> TempsubTypeMap = TempPrdSubClassMap.get(
                                    acct.IETRS_Product_Sub_Class__c
                                );
                                if (TempsubTypeMap.containskey(subTypekey)) {
                                    Map<String, Map<String, Integer>> tempregionMap = TempsubTypeMap.get(
                                        subTypekey
                                    );
                                    if (
                                        tempregionMap.containskey(
                                            acct.IETRS_Region__r.name
                                        )
                                    ) {
                                        Map<String, Integer> accParentMap = tempregionMap.get(
                                            acct.IETRS_Region__r.name
                                        );
                                        if (
                                            !accParentMap.containskey(
                                                acct.ParentId
                                            )
                                        ) {
                                            accParentMap.put(acct.ParentId, 1);
                                            tempregionMap.put(
                                                acct.IETRS_Region__r.name,
                                                accParentMap
                                            );
                                            TempsubTypeMap.put(
                                                subTypekey,
                                                tempregionMap
                                            );
                                            TempPrdSubClassMap.put(
                                                acct.IETRS_Product_Sub_Class__c,
                                                TempsubTypeMap
                                            );
                                            temptypeMap.put(
                                                acct.Type,
                                                TempPrdSubClassMap
                                            );
                                            prodMapUnitsTemp.put(
                                                acct.IETRS_Product_Class__c,
                                                temptypeMap
                                            );
                                        }
                                    } else {
                                        Map<String, Integer> accParentMap1 = new Map<String, Integer>();
                                        accParentMap1.put(acct.ParentId, 1);
                                        tempregionMap.put(
                                            acct.IETRS_Region__r.name,
                                            accParentMap1
                                        );
                                        TempsubTypeMap.put(
                                            subTypekey,
                                            tempregionMap
                                        );
                                        TempPrdSubClassMap.put(
                                            acct.IETRS_Product_Sub_Class__c,
                                            TempsubTypeMap
                                        );
                                        temptypeMap.put(
                                            acct.Type,
                                            TempPrdSubClassMap
                                        );
                                        prodMapUnitsTemp.put(
                                            acct.IETRS_Product_Class__c,
                                            temptypeMap
                                        );
                                    }
                                } else {
                                    Map<String, Map<String, Integer>> regionMap = new Map<String, Map<String, Integer>>();
                                    Map<String, Integer> accParentMap2 = new Map<String, Integer>();
                                    accParentMap2.put(acct.ParentId, 1);
                                    regionMap.put(
                                        acct.IETRS_Region__r.name,
                                        accParentMap2
                                    );
                                    TempsubTypeMap.put(subTypekey, regionMap);
                                    TempPrdSubClassMap.put(
                                        acct.IETRS_Product_Sub_Class__c,
                                        TempsubTypeMap
                                    );
                                    temptypeMap.put(
                                        acct.Type,
                                        TempPrdSubClassMap
                                    );
                                    prodMapUnitsTemp.put(
                                        acct.IETRS_Product_Class__c,
                                        temptypeMap
                                    );
                                }
                            } else {
                                Map<String, Map<String, Map<String, Integer>>> subTypeMap = new Map<String, Map<String, Map<String, Integer>>>();
                                Map<String, Map<String, Integer>> regionMap = new Map<String, Map<String, Integer>>();
                                Map<String, Integer> accParentMap3 = new Map<String, Integer>();
                                accParentMap3.put(acct.ParentId, 1);
                                regionMap.put(
                                    acct.IETRS_Region__r.name,
                                    accParentMap3
                                );
                                subTypeMap.put(subTypekey, regionMap);
                                TempPrdSubClassMap.put(
                                    acct.IETRS_Product_Sub_Class__c,
                                    subTypeMap
                                );
                                temptypeMap.put(acct.Type, TempPrdSubClassMap);
                                prodMapUnitsTemp.put(
                                    acct.IETRS_Product_Class__c,
                                    temptypeMap
                                );
                            }
                        } else {
                            Map<String, Map<String, Map<String, Map<String, Integer>>>> prdSubClassMap = new Map<String, Map<String, Map<String, Map<String, Integer>>>>();
                            Map<String, Map<String, Map<String, Integer>>> subTypeMap = new Map<String, Map<String, Map<String, Integer>>>();
                            Map<String, Map<String, Integer>> regionMap = new Map<String, Map<String, Integer>>();
                            Map<String, Integer> accParentMap4 = new Map<String, Integer>();
                            accParentMap4.put(acct.ParentId, 1);
                            regionMap.put(
                                acct.IETRS_Region__r.name,
                                accParentMap4
                            );
                            subTypeMap.put(subTypekey, regionMap);
                            prdSubClassMap.put(
                                acct.IETRS_Product_Sub_Class__c,
                                subTypeMap
                            );
                            temptypeMap.put(acct.Type, prdSubClassMap);
                            prodMapUnitsTemp.put(
                                acct.IETRS_Product_Class__c,
                                temptypeMap
                            );
                        }
                    } else {
                        Map<String, Map<String, Map<String, Map<String, Map<String, Integer>>>>> typeMap = new Map<String, Map<String, Map<String, Map<String, Map<String, Integer>>>>>();
                        Map<String, Map<String, Map<String, Map<String, Integer>>>> prdSubClassMap = new Map<String, Map<String, Map<String, Map<String, Integer>>>>();
                        Map<String, Map<String, Map<String, Integer>>> subTypeMap = new Map<String, Map<String, Map<String, Integer>>>();
                        Map<String, Map<String, Integer>> regionMap = new Map<String, Map<String, Integer>>();
                        Map<String, Integer> parentIDMap = new Map<String, Integer>();
                        parentIDMap.put(acct.ParentId, 1);
                        regionMap.put(acct.IETRS_Region__r.name, parentIDMap);
                        subTypeMap.put(subTypekey, regionMap);
                        prdSubClassMap.put(
                            acct.IETRS_Product_Sub_Class__c,
                            subTypeMap
                        );
                        typeMap.put(acct.Type, prdSubClassMap);
                        prodMapUnitsTemp.put(
                            acct.IETRS_Product_Class__c,
                            typeMap
                        );
                    }
                }
            }
        }
        System.debug('#prodMap.keySet()' + prodMapUnitsTemp.keySet());
        for (String prodClass : prodMapUnitsTemp.keySet()) {
            Map<String, Map<String, Map<String, Map<String, Map<String, Integer>>>>> type_Map = prodMapUnitsTemp.get(
                prodClass
            );
            Map<String, Map<String, Map<String, Map<String, Integer>>>> tyMap = new Map<String, Map<String, Map<String, Map<String, Integer>>>>();
            for (String typ : type_Map.keySet()) {
                Map<String, Map<String, Map<String, Map<String, Integer>>>> prdSubClass_Map = type_Map.get(
                    typ
                );
                Map<String, Map<String, Map<String, Integer>>> prSClassMap = new Map<String, Map<String, Map<String, Integer>>>();
                for (String prdSubClass : prdSubClass_Map.keySet()) {
                    Map<String, Map<String, Map<String, Integer>>> subType_Map = prdSubClass_Map.get(
                        prdSubClass
                    );
                    Map<String, Map<String, Integer>> sTypeMap = new Map<String, Map<String, Integer>>();
                    for (String subType : subType_Map.keySet()) {
                        Map<string, Map<String, Integer>> region_Map = subType_Map.get(
                            subType
                        );
                        Map<String, Integer> rgMap = new Map<String, Integer>();
                        Map<String, Integer> rgMapDummy = new Map<String, Integer>();
                        for (String reg : region_Map.keySet()) {
                            rgMapDummy.put(reg, 0);
                        }

                        for (String reg : region_Map.keySet()) {
                            Integer regionMapCount = region_Map.get(reg).size();
                            rgMap.put(reg, regionMapCount);
                        }
                        sTypeMap.put(subType, rgMap);
                        /*if(prodClass=='Gas' && typ=='Transmission' && prdSubClass=='Natural')
                        {
                            
                            sTypeMap.put('Municipal Supply',rgMapDummy);
                        }*/
                        /*if(prodClass=='Gas' && typ=='Storage' && prdSubClass=='Natural')
                        {
                            
                            sTypeMap.put('Aboveground',rgMapDummy);
                        }*/
                        /*if(prodClass=='Liquid' && typ=='Storage' && prdSubClass=='HVL')
                        {
                            
                            sTypeMap.put('Interstate Belowground',rgMapDummy);
                        }
                        if(prodClass=='Liquid' && typ=='Transmission' && prdSubClass=='Carbon Dioxide')
                        {
                            
                            sTypeMap.put('Interstate Transmission',rgMapDummy);
                            System.debug('rgMapDummy====>'+rgMapDummy);
                        }
                        if(prodClass=='Liquid' && typ=='Transmission' && prdSubClass=='Non-HVL')
                        {
                            
                            sTypeMap.put('Interstate Transmission',rgMapDummy);
                        }
                        if(prodClass=='Liquid' && typ=='Transmission' && prdSubClass=='Crude')
                        {
                            
                            sTypeMap.put('Interstate Transmission',rgMapDummy);
                        }*/
                    }
                    prSClassMap.put(prdSubClass, sTypeMap);
                }
                tyMap.put(typ, prSClassMap);
            }
            prodMapUnits.put(prodClass, tyMap);
        }

        for (String prodClass : prodMapUnits.keySet()) {
            Map<String, Map<String, Map<String, Map<String, Integer>>>> type_Map = prodMapUnits.get(
                prodClass
            );
            for (String typ : type_Map.keySet()) {
                Map<String, Map<String, Map<String, Integer>>> prdSubClass_Map = prodMapUnits.get(
                        prodClass
                    )
                    .get(typ);
                for (String prdSubClass : prdSubClass_Map.keySet()) {
                    Map<String, Map<String, Integer>> subType_Map = prodMapUnits.get(
                            prodClass
                        )
                        .get(typ)
                        .get(prdSubClass);
                    for (String subType : subType_Map.keySet()) {
                        Map<String, Integer> region_Map = new Map<String, Integer>();
                        system.debug(
                            '#subType:' +
                            subType +
                            ':' +
                            subType_Map.get(subType).keySet()
                        );
                        for (String reg : subType_Map.get(subType).keySet()) {
                            region_Map.put(
                                reg,
                                prodMapUnits.get(prodClass)
                                    .get(typ)
                                    .get(prdSubClass)
                                    .get(subType)
                                    .get(reg)
                            );

                            System.debug('#region_Map' + region_Map);
                        }
                        for (String regionName : regionNames) {
                            if (!region_Map.containskey(regionName)) {
                                region_Map.put(regionName, 0);
                            }
                        }
                        subType_Map.put(subType, region_Map);
                    }
                    prdSubClass_Map.put(prdSubClass, subType_Map);
                }
                type_Map.put(typ, prdSubClass_Map);
            }
            prodMapUnits.put(prodClass, type_Map);
        }
        prodMapSubClassTotalUnits = new Map<String, Map<String, Map<String, Map<String, Integer>>>>();
        for (String prodClass : prodMapUnits.keySet()) {
            Map<String, Map<String, Map<String, Map<String, Integer>>>> type = prodMapUnits.get(
                prodClass
            );
            Map<String, Map<String, Map<String, Integer>>> TempType = new Map<String, Map<String, Map<String, Integer>>>();
            for (String typ : type.keySet()) {
                Map<String, Map<String, Map<String, Integer>>> prodSubClass = type.get(
                    typ
                );
                Map<String, Map<String, Integer>> TempProdClass = new Map<String, Map<String, Integer>>();
                for (String pSc : prodSubClass.keySet()) {
                    Map<String, Map<String, Integer>> subType = prodSubClass.get(
                        pSc
                    );

                    Map<String, Integer> regMap = new Map<String, Integer>();
                    for (String sType : subType.keySet()) {
                        Map<String, Integer> TempReg = subType.get(sType);
                        for (String reg : TempReg.keySet()) {
                            if (regMap.containsKey(reg)) {
                                Integer units = regMap.get(reg);
                                regMap.put(reg, units + TempReg.get(reg));
                            } else {
                                regMap.put(reg, TempReg.get(reg));
                            }
                        }
                    }
                    TempProdClass.put(pSc, regMap);
                }
                TempType.put(typ, TempProdClass);
            }
            prodMapSubClassTotalUnits.put(prodClass, TempType);
        }
        prodMapTypeTotalUnits = new Map<String, Map<String, Map<String, Integer>>>();
        for (String PMCTU : prodMapSubClassTotalUnits.keySet()) {
            Map<String, Map<String, Map<String, Integer>>> prodClass = prodMapSubClassTotalUnits.get(
                PMCTU
            );
            Map<String, Map<String, Integer>> tempTypeMap = new Map<String, Map<String, Integer>>();

            for (String pcKey : prodClass.keySet()) {
                Map<String, Map<String, Integer>> type = prodClass.get(pcKey);
                Map<String, Integer> TempRegMap = new Map<String, Integer>();
                for (String typ : type.keySet()) {
                    Map<String, Integer> regMap = type.get(typ);
                    for (String reg : regMap.keySet()) {
                        if (TempRegMap.containsKey(reg)) {
                            Integer units = TempRegMap.get(reg);
                            TempRegMap.put(reg, units + regMap.get(reg));
                        } else {
                            TempRegMap.put(reg, regMap.get(reg));
                        }
                    }
                }
                tempTypeMap.put(pcKey, TempRegMap);
            }
            prodMapTypeTotalUnits.put(PMCTU, tempTypeMap);
        }
        prodMapClassTotalUnits = new Map<String, Map<String, Integer>>();
        for (String prodClass : prodMapUnits.keySet()) {
            Map<String, Integer> regMap = new Map<String, Integer>();
            Map<String, Map<String, Map<String, Map<String, Integer>>>> type = prodMapUnits.get(
                prodClass
            );

            for (String typ : type.keySet()) {
                Map<String, Map<String, Map<String, Integer>>> prodSubClass = type.get(
                    typ
                );

                for (String pSc : prodSubClass.keySet()) {
                    Map<String, Map<String, Integer>> subType = prodSubClass.get(
                        pSc
                    );

                    for (String sType : subType.keySet()) {
                        Map<String, Integer> TempReg = subType.get(sType);
                        for (String reg : TempReg.keySet()) {
                            if (regMap.containsKey(reg)) {
                                Integer units = regMap.get(reg);
                                regMap.put(reg, units + TempReg.get(reg));
                            } else {
                                regMap.put(reg, TempReg.get(reg));
                            }
                        }
                    }
                }
            }
            prodMapClassTotalUnits.put(prodClass, regMap);
        }
        TotalUnits = new Map<String, Integer>();
        for (String prodClass : prodMapClassTotalUnits.keySet()) {
            Map<String, integer> regMap = prodMapClassTotalUnits.get(prodClass);
            for (String reg : regMap.keySet()) {
                if (TotalUnits.containsKey(reg)) {
                    Integer units = TotalUnits.get(reg);
                    TotalUnits.put(reg, units + regMap.get(reg));
                } else {
                    TotalUnits.put(reg, regMap.get(reg));
                }
            }
        }
    }
    public Integer SizeOfprodMap {
        get {
            if (prodMap != null) {
                return prodMap.size();
            } else {
                return 0;
            }
        }
    }
    public class Summary_Sch_Wrapper {
        public String regionName { get; set; }
        public Integer regionRecCount { get; set; }
        public Priority_Wrapper priWrap { get; set; }
        public Schedule_Wrapper schWrap { get; set; }
    }
    public class Priority_Wrapper {
        public Integer priority1 { get; set; }
        public Integer priority2 { get; set; }
        public Integer priority3 { get; set; }
    }
    public class Schedule_Wrapper {
        public Integer sch { get; set; }
        public Integer NotSch { get; set; }
        public Integer priority1Sch { get; set; }
        public Integer priority1NotSch { get; set; }
        public Integer priority2Sch { get; set; }
        public Integer priority2NotSch { get; set; }
        public Integer priority3Sch { get; set; }
        public Integer priority3NotSch { get; set; }
    }
    public class Eastern_Coastline_Wrapper {
        public String operator { get; set; }
        public String contactPerson { get; set; }
        public String contactDetails { get; set; }
        public String phone { get; set; }
        public String Hour_Phone { get; set; }
        public String fax { get; set; }
        public String companyId { get; set; }
    }
    public class Operator_Address_Wrapper {
        public String operator { get; set; }
        public String contactPerson { get; set; }
        public String contactDetails { get; set; }
        public String phone { get; set; }
        public String fax { get; set; }
        public String Hour_Phone { get; set; }
        public String companyId { get; set; }
        public String p5Number { get; set; }
        public Decimal totalMiles { get; set; }
    }
    public class Inspection_Wrapper {
        public integer total_Insp_Performed { get; set; }
        public Decimal total_Miles_Evaluated { get; set; }
        public Decimal total_Voilations { get; set; }
    }
}