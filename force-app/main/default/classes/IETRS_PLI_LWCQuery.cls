global without sharing class IETRS_PLI_LWCQuery {
    //GET THE ACCOUNT RECORDS USING OPERATOR NAME AND P5 NUMBER
    @AuraEnabled(cacheable=true)
    public static Schema.Account getAccountRecords(
        String operatorNamestr,
        String p5Numberstr
    ) {
        List<string> conditions = new List<String>();

        if (String.isNotBlank(operatorNamestr))
            conditions.add('Name =:operatorNamestr');

        if (String.isNotBlank(p5Numberstr))
            conditions.add('IETRS_P5_Number__c =:p5Numberstr');

        String soqlAssign = 'SELECT id,Name,IETRS_Company_ID__c,IETRS_P5_Number__c,IETRS_Regulated_Entity_ID__c From Account';

        if (conditions.size() > 0) {
            soqlAssign += '  WHERE ' + conditions[0];
            for (Integer i = 1; i < conditions.size(); i++) {
                soqlAssign += '  AND ' + conditions[i];
            }
        }
        soqlAssign += ' LIMIT 1';

        return DataBase.Query(soqlAssign);
    }

    //GET THE RECORD TYPE ID USING NOTIFICATION OBJECT
    public static String getNotificationRecordTypeId(String RecordTypeName) {
        String NotificationRecordTypeId = Schema.SObjectType.IETRS_Insp_Notification__c.getRecordTypeInfosByName()
            .get(RecordTypeName)
            .getRecordTypeId();
        return NotificationRecordTypeId;
    }

    //GET THE RECORDS USING NOTIFICATION OBJECT BASED ON THE RECORD TYPES(LIKE "PS-95","SRC","IMP")
    @AuraEnabled //(cacheable = true)
    public static List<IETRS_Insp_Notification__c> fetchNotificationSRCRecods(
        String operatorName,
        String psNumber,
        String systemName,
        String RecordTypeName
    ) {
        System.debug('operatorName' + operatorName);
        System.debug('psNumber' + psNumber);
        System.debug('systemName' + systemName);
        System.debug('RecordTypeName' + RecordTypeName);

        String NotificationRecordTypeId = getNotificationRecordTypeId(
            RecordTypeName
        );
        System.debug('NotificationRecordTypeId' + NotificationRecordTypeId);
        List<IETRS_Insp_Notification__c> notificationLst = new List<IETRS_Insp_Notification__c>();
        List<string> conditions = new List<String>();

        if (String.isNotBlank(operatorName))
            conditions.add('IETRS_Organization__r.Name =:operatorName');

        if (String.isNotBlank(psNumber))
            conditions.add('IETRS_P5_Number_Formula__c =:psNumber');

        if (String.isNotBlank(systemName))
            conditions.add('IETRS_Regulated_Entity__r.Name =:systemName'); //IETRS_Pipeline_System_ID__r.Name replced as a part of bug 12332

        if (String.isNotBlank(NotificationRecordTypeId))
            conditions.add('RecordTypeId=:NotificationRecordTypeId');

        String soqlAssign =
            'SELECT ID,IETRS_Organization__r.Name,IETRS_P5_Number_Formula__c,IETRS_Pipeline_System_ID__c,IETRS_Pipeline_System_ID__r.Name,' +
            'IETRS_PHMSA_SRC_ID__c,IETRS_Date_of_Discovery__c,Createddate,CreatedBy.Name,IETRS_Regulated_Entity__r.Name,IETRS_Regulated_Entity_ID__c,' +
            'IETRS_Inspector__r.Name,IETRS_Status__c,IETRS_PHMSA_IMP_ID__c,IETRS_Regulated_Entity__c,IETRS_Attached_File__c,IETRS_Attached_File_Correspondence__r.Name, ' +
            'IETRS_Attached_File_Correspondence__r.IETRS_File_Name__c  ' +
            'FROM IETRS_Insp_Notification__c';

        if (conditions.size() > 0) {
            soqlAssign += '  WHERE ' + conditions[0];
            for (Integer i = 1; i < conditions.size(); i++) {
                soqlAssign += '  AND ' + conditions[i];
            }
        }
        //Added by Ayesha for Sorting
        soqlAssign += ' ORDER BY ID';
        System.debug('soqlAssign==>' + soqlAssign);
        for (IETRS_Insp_Notification__c notifObj : Database.query(soqlAssign)) {
            notificationLst.add(notifObj);
        }
        System.debug('notificationLst==>' + notificationLst);
        return notificationLst;
    }

    //Added by Ayesha on 8th DEC 2020
    //PURPOSE: TO refresh the data table of Notification on edit or delete

    @AuraEnabled //(cacheable = true)
    public static List<IETRS_Insp_Notification__c> fetchNotificationSRCRecodsOnRefresh(
        List<Id> recordSet
    ) {
        System.debug('recordSet==>' + recordSet);
        List<IETRS_Insp_Notification__c> returnNotification = [
            SELECT
                ID,
                IETRS_Organization__r.Name,
                IETRS_P5_Number_Formula__c,
                IETRS_Pipeline_System_ID__c,
                IETRS_Pipeline_System_ID__r.Name,
                IETRS_PHMSA_SRC_ID__c,
                IETRS_Date_of_Discovery__c,
                Createddate,
                CreatedBy.Name,
                IETRS_Regulated_Entity__r.Name,
                IETRS_Regulated_Entity_ID__c,
                IETRS_Inspector__r.Name,
                IETRS_Status__c,
                IETRS_PHMSA_IMP_ID__c,
                IETRS_Regulated_Entity__c,
                IETRS_Attached_File__c,
                IETRS_Attached_File_Correspondence__r.Name,
                IETRS_Attached_File_Correspondence__r.IETRS_File_Name__c
            FROM IETRS_Insp_Notification__c
            WHERE Id IN :recordSet
            ORDER BY ID
        ];
        System.debug('==>final result');
        System.debug(returnNotification);
        return returnNotification;
    }
    //GET THE RECORDS ONLY "P5-95"(RECORD TYPE) IN NOTIFICATION OBJECT
    @AuraEnabled /*(cacheable = true)*/
    public static IETRS_Insp_Notification__c fetchNotificationDetailRecs(
        String operatorName,
        String p5Number,
        String reportingPeriod
    ) {
        String RecordTypeName = 'PS-95';
        String NotificationRecordTypeId = getNotificationRecordTypeId(
            RecordTypeName
        );

        List<string> conditions = new List<String>();

        if (String.isNotBlank(operatorName))
            conditions.add('IETRS_PS95_Organization__r.Name =:operatorName');

        if (String.isNotBlank(p5Number))
            conditions.add('IETRS_P5_Number_Formula__c =:p5Number');

        if (String.isNotBlank(reportingPeriod))
            conditions.add('IETRS_Report_Period__c =:reportingPeriod');

        if (String.isNotBlank(NotificationRecordTypeId))
            conditions.add('RecordTypeId=:NotificationRecordTypeId');

        String soqlAssign = 'SELECT ID,IETRS_Organization_Name__c,IETRS_P5_Number_Formula__c,IETRS_Regulated_Entity_Id__c,IETRS_PS95_Organization__r.Name,IETRS_PS95_Organization__r.IETRS_Company_ID__c,IETRS_Organization_Name__r.Name,IETRS_Organization_Name__r.IETRS_Company_ID__c,IETRS_Repaired_Leak_Count__c,IETRS_Report_Period__c,IETRS_Total_Grade_1_Unrepaired__c,IETRS_Total_Grade_2_Unrepaired__c,IETRS_Total_Grade_3_Unrepaired__c,IETRS_Total_Unrepaired_Leaks__c,IETRS_Submitted_Date__c FROM IETRS_Insp_Notification__c';

        if (conditions.size() > 0) {
            soqlAssign += '  WHERE ' + conditions[0];
            for (Integer i = 1; i < conditions.size(); i++) {
                soqlAssign += '  AND ' + conditions[i];
            }
        }
        System.debug('final query String' + soqlAssign);
        soqlAssign += ' LIMIT 1';

        IETRS_Insp_Notification__c getnotificationObj;
        for (
            IETRS_Insp_Notification__c cpynotObj : Database.query(soqlAssign)
        ) {
            getnotificationObj = cpynotObj;
        }

        return getnotificationObj;
    }

    //GET THE ANY PICKLIST VALUES USING SOBJECT AND FIELD NAME
    public static Map<String, String> picklistValues(
        String objectName,
        String fieldName
    ) {
        Map<String, String> values = new Map<String, String>{};
        List<Schema.DescribeSobjectResult> results = Schema.describeSObjects(
            new List<String>{ objectName }
        );
        for (Schema.DescribeSobjectResult res : results) {
            for (
                Schema.PicklistEntry entry : res.fields.getMap()
                    .get(fieldName)
                    .getDescribe()
                    .getPicklistValues()
            ) {
                if (entry.isActive())
                    values.put(entry.getValue(), entry.getLabel());
            }
        }
        return values;
    }

    //GET THE PICKLIST VALUES (REPORT PERIOD) FROM NOTIFICATION OBJECT
    @AuraEnabled(cacheable=true)
    public static List<String> getReportPeriodValues() {
        List<String> setReportPeriodValues = new List<String>();
        Map<String, String> CustomerPriorityValueLabels = picklistValues(
            'IETRS_Insp_Notification__c',
            'IETRS_Report_Period__c'
        );
        for (String value : CustomerPriorityValueLabels.keySet()) {
            setReportPeriodValues.add(CustomerPriorityValueLabels.get(value));
        }
        return setReportPeriodValues;
    }

    //GET THE PICKLIST VALUES (LEAK CAUSE) NOTIFICATION DETAIL OBJECT
    @AuraEnabled(cacheable=true)
    public static List<String> getLeakCauseValues() {
        List<String> setLeakCause = new List<String>();
        Map<String, String> setLeakCauseMapObj = picklistValues(
            'IETRS_Insp_Notification_Detail__c',
            'IETRS_Leak_Cause__c'
        );
        for (String value : setLeakCauseMapObj.keySet()) {
            setLeakCause.add(setLeakCauseMapObj.get(value));
        }
        return setLeakCause;
    }

    //GET THE PICKLIST VALUES (LEAK CLASSIFICATION) NOTIFICATION DETAIL OBJECT
    @AuraEnabled(cacheable=true)
    public static List<String> getLeakClassificationValues() {
        List<String> setLeakeClassificationLst = new List<String>();
        Map<String, String> setLeakeClassificationLstMap = picklistValues(
            'IETRS_Insp_Notification_Detail__c',
            'IETRS_Leak_Classification__c'
        );
        for (String value : setLeakeClassificationLstMap.keySet()) {
            setLeakeClassificationLst.add(
                setLeakeClassificationLstMap.get(value)
            );
        }
        return setLeakeClassificationLst;
    }

    //GET THE PICKLIST VALUES (LEAK LOCATION) NOTIFICATION DETAIL OBJECT
    @AuraEnabled(cacheable=true)
    public static List<String> getLeakLocationValues() {
        List<String> setLeakeLocationlst = new List<String>();
        Map<String, String> setLeakLocationMap = picklistValues(
            'IETRS_Insp_Notification_Detail__c',
            'IETRS_Leak_Location__c'
        );
        for (String value : setLeakLocationMap.keySet()) {
            setLeakeLocationlst.add(setLeakLocationMap.get(value));
        }
        return setLeakeLocationlst;
    }

    //GET THE PICKLIST VALUES (LEAK REPAIR METHOD) NOTIFICATION DETAIL OBJECT
    @AuraEnabled(cacheable=true)
    public static List<String> getLeakRepairMethodValues() {
        List<String> setLeakeRepairMethodLst = new List<String>();
        Map<String, String> setLeakeRepairMethodMap = picklistValues(
            'IETRS_Insp_Notification_Detail__c',
            'IETRS_Leak_Repair_Method__c'
        );
        for (String value : setLeakeRepairMethodMap.keySet()) {
            setLeakeRepairMethodLst.add(setLeakeRepairMethodMap.get(value));
        }
        return setLeakeRepairMethodLst;
    }

    //GET THE PICKLIST VALUES (PIPE TYPE) FROM NOTIFICATION DETAIL OBJECT
    @AuraEnabled(cacheable=true)
    public static List<String> getPipeTypeValues() {
        List<String> setPipeTypelst = new List<String>();
        Map<String, String> setPipeTypeMap = picklistValues(
            'IETRS_Insp_Notification_Detail__c',
            'IETRS_Pipe_Type__c'
        );
        for (String value : setPipeTypeMap.keySet()) {
            setPipeTypelst.add(setPipeTypeMap.get(value));
        }
        return setPipeTypelst;
    }

    //GET THE PICKLIST VALUES (PIPE SIZE) FROM NOTIFICATION DETAIL OBJECT
    @AuraEnabled(cacheable=true)
    public static List<String> getPipeSizeValues() {
        List<String> setPipeSizelst = new List<String>();
        Map<String, String> setPipeSizeMap = picklistValues(
            'IETRS_Insp_Notification_Detail__c',
            'IETRS_Pipe_Size__c'
        );
        for (String value : setPipeSizeMap.keyset()) {
            setPipeSizelst.add(setPipeSizeMap.get(value));
        }
        return setPipeSizelst;
    }

    //GET THE PICKLIST VALUES (LEAK LOCATION ON) FROM NOTIFICATION DETAIL OBJECT
    @AuraEnabled(cacheable=true)
    public static List<String> getleaveLocaitonOn() {
        List<String> setleaveLocaitonOnLst = new List<String>();
        Map<String, String> getleaveLocaitonOnMap = picklistValues(
            'IETRS_Insp_Notification_Detail__c',
            'IETRS_Leak_Located_On__c'
        );
        for (String value : getleaveLocaitonOnMap.keyset()) {
            setleaveLocaitonOnLst.add(getleaveLocaitonOnMap.get(value));
        }
        return setleaveLocaitonOnLst;
    }

    //GET THE PICKLIST VALUES (FACILITY TYPE) FROM NOTIFICATION DETAIL OBJECT
    @AuraEnabled(cacheable=true)
    public static List<String> getFacilityTypeValues() {
        List<String> setFacilityTypeLst = new List<String>();
        Map<String, String> getfacilityTypeMap = picklistValues(
            'IETRS_Insp_Notification_Detail__c',
            'IETRS_Facility_Type__c'
        );
        for (String value : getfacilityTypeMap.keyset()) {
            setFacilityTypeLst.add(getfacilityTypeMap.get(value));
        }
        return setFacilityTypeLst;
    }

    //SET ALL PICKLIST VALUES OF NOTIFICATION DETAIL OBJECT
    @AuraEnabled(cacheable=true)
    public static picklistWrap getallPicklistWrap() {
        picklistWrap pWrp = new picklistWrap();
        pWrp.LeakLocationlst.addall(getLeakLocationValues());
        pWrp.LeakClassificationlst.addall(getLeakClassificationValues());
        pWrp.PipeTypelst.addall(getPipeTypeValues());
        pWrp.LeakCauselst.addall(getLeakCauseValues());
        pWrp.LeakRepairLst.addall(getLeakRepairMethodValues());
        pWrp.pipeSizeLst.addall(getPipeSizeValues());
        pWrp.LeakLocatedOnLst.addall(getleaveLocaitonOn());
        pWrp.FacilityTypeLst.addall(getFacilityTypeValues());
        return pWrp;
    }

    // FETCHING RECORDS BASED ON THE NOTIFICATION DETAILS OBJECT
    @AuraEnabled /*(cacheable = true)*/
    public static List<notificationDetailWrap> fetchNotificationDetailReccords(
        String RecordId
    ) {
        List<notificationDetailWrap> nDetailsWrpLst = new List<notificationDetailWrap>();

        for (IETRS_Insp_Notification_Detail__c noDetail : [
            SELECT
                ID,
                IETRS_Date_Leak_Reported__c,
                IETRS_Notification__r.IETRS_Pipeline_System_ID__r.Name,
                IETRS_Leak_Repair_Method__c,
                IETRS_Repair_Date__c,
                IETRS_Leak_Cause__c,
                IETRS_Leak_Location__c,
                IETRS_Leak_Located_On__c,
                IETRS_Regulated_Entity_Id__c,
                IETRS_Facility_Type__c,
                IETRS_Pipe_Size__c,
                IETRS_Pipe_Type__c,
                IETRS_Leak_Classification__c,
                IETRS_Pipelines_System_ID__r.Name
            FROM IETRS_Insp_Notification_Detail__c
            WHERE IETRS_Notification__c = :RecordId
            LIMIT 49999
        ]) {
            notificationDetailWrap ndWrpObj = new notificationDetailWrap();
            ndWrpObj.isCheck = false;
            System.debug(
                'noDetail.IETRS_Pipelines_System_ID__r.Name' +
                noDetail.IETRS_Pipelines_System_ID__r.Name
            );
            /*Replaced with IETRS_Repair_Date__c
if(noDetail.IETRS_Date_Leak_Reported__c != null)
ndWrpObj.dateStr = noDetail.IETRS_Date_Leak_Reported__c.format();
*/
            if (noDetail.IETRS_Repair_Date__c != null) {
                ndWrpObj.dateStr = noDetail.IETRS_Repair_Date__c.format();
            }
            if (noDetail.IETRS_Pipelines_System_ID__r.Name != null)
                ndWrpObj.systemnameStr = noDetail.IETRS_Pipelines_System_ID__r.Name;
            ndWrpObj.LeakCuase = noDetail.IETRS_Leak_Cause__c;
            ndWrpObj.LeakRepairMethod = noDetail.IETRS_Leak_Repair_Method__c;
            ndWrpObj.LeakLocation = noDetail.IETRS_Leak_Location__c;
            ndWrpObj.PipeSize = noDetail.IETRS_Pipe_Size__c;
            ndWrpObj.LeakClassification = noDetail.IETRS_Leak_Classification__c;
            ndWrpObj.pipeType = noDetail.IETRS_Pipe_Type__c;
            ndWrpObj.Id = noDetail.Id;
            ndWrpObj.RegulatedEntityId = noDetail.IETRS_Regulated_Entity_Id__c;
            ndWrpObj.noDetailObj = noDetail;
            nDetailsWrpLst.add(ndWrpObj);
        }

        return nDetailsWrpLst;
    }

    public static Map<String, String> getSortFldApiByName() {
        return new Map<String, String>{
            'dateStr' => 'IETRS_Repair_Date__c',
            'systemnameStr' => 'IETRS_Pipelines_System_ID__r.Name',
            'LeakCuase' => 'IETRS_Leak_Cause__c',
            'LeakRepairMethod' => 'IETRS_Leak_Repair_Method__c',
            'LeakLocation' => 'IETRS_Leak_Location__c',
            'PipeSize' => 'IETRS_Pipe_Size__c',
            'pipeType' => 'IETRS_Pipe_Type__c',
            'LeakClassification' => 'IETRS_Leak_Classification__c',
            'RegulatedEntityId' => 'IETRS_Regulated_Entity_Id__c'
        };
    }

    // FETCHING RECORDS BASED ON THE NOTIFICATION DETAILS OBJECT on EDIT or CREATE and Refresh
    @AuraEnabled //(cacheable = true)
    public static List<notificationDetailWrap> fetchNotificationDetailReccordsForRefresh(
        String RecordId,
        String searchRENKey,
        String searchREIKey,
        String searchCountyKey,
        String sortBy,
        String sortDirection
    ) {
        List<notificationDetailWrap> nDetailsWrpLst = new List<notificationDetailWrap>();
        String query = 'SELECT ID,IETRS_Date_Leak_Reported__c,IETRS_Notification__r.IETRS_Pipeline_System_ID__r.Name,IETRS_Leak_Repair_Method__c,IETRS_Repair_Date__c,IETRS_Leak_Cause__c,IETRS_Notification__r.IETRS_Pipeline_System_ID__c,IETRS_Leak_Location__c,IETRS_Leak_Located_On__c,IETRS_Pipelines_System_ID__r.Name,IETRS_Facility_Type__c,IETRS_Pipe_Size__c,IETRS_Pipe_Type__c,IETRS_Leak_Classification__c,IETRS_Regulated_Entity_Id__c,IETRS_County__r.Name FROM IETRS_Insp_Notification_Detail__c WHERE IETRS_Notification__c=:RecordId';
        if (searchRENKey != null && searchRENKey != '') {
            String renKey = '%' + searchRENKey + '%';
            query += ' AND IETRS_Pipelines_System_ID__r.Name LIKE :renKey';
        }
        if (searchREIKey != null && searchREIKey != '') {
            String reiKey = '%' + searchREIKey + '%';
            query += ' AND IETRS_Regulated_Entity_Id__c LIKE :reiKey';
        }
        if (searchCountyKey != null && searchCountyKey != '') {
            String countyKey = '%' + searchCountyKey + '%';
            query += ' AND IETRS_County__r.Name LIKE :countyKey';
        }
        if (sortBy != null && sortDirection != null) {
            String sortByFldAPI = getSortFldApiByName().get(sortBy);
            query += ' ORDER BY ' + sortByFldAPI + ' ' + sortDirection;
            System.debug('sortByFldAPI:>>>>> ' + sortByFldAPI);
        }
        query += ' LIMIT 49999';

        System.debug('query:>>>>> ' + query);
        System.debug('RecordId:>>>>> ' + RecordId);
        System.debug('searchRENKey:>>>>> ' + searchRENKey);
        System.debug('searchREIKey:>>>>> ' + searchREIKey);
        System.debug('searchCountyKey:>>>>> ' + searchCountyKey);
        System.debug('sortBy:>>>>> ' + sortBy);
        System.debug('sortDirection:>>>>> ' + sortDirection);

        for (
            IETRS_Insp_Notification_Detail__c noDetail : Database.query(query)
        ) {
            notificationDetailWrap ndWrpObj = new notificationDetailWrap();
            ndWrpObj.isCheck = false;
            /*Replaced with IETRS_Repair_Date__c
if(noDetail.IETRS_Date_Leak_Reported__c != null)
ndWrpObj.dateStr = noDetail.IETRS_Date_Leak_Reported__c.format();
*/
            if (noDetail.IETRS_Repair_Date__c != null)
                ndWrpObj.dateStr = noDetail.IETRS_Repair_Date__c.format();
            if (noDetail.IETRS_Pipelines_System_ID__r.Name != null)
                ndWrpObj.systemnameStr = noDetail.IETRS_Pipelines_System_ID__r.Name; //IETRS_Notification__r.IETRS_Pipeline_System_ID__r.Name
            ndWrpObj.LeakCuase = noDetail.IETRS_Leak_Cause__c;
            ndWrpObj.LeakRepairMethod = noDetail.IETRS_Leak_Repair_Method__c;
            ndWrpObj.LeakLocation = noDetail.IETRS_Leak_Location__c;
            ndWrpObj.PipeSize = noDetail.IETRS_Pipe_Size__c;
            ndWrpObj.LeakClassification = noDetail.IETRS_Leak_Classification__c;
            ndWrpObj.pipeType = noDetail.IETRS_Pipe_Type__c;
            ndWrpObj.Id = noDetail.Id;
            ndWrpObj.RegulatedEntityId = noDetail.IETRS_Regulated_Entity_Id__c;
            ndWrpObj.noDetailObj = noDetail;
            nDetailsWrpLst.add(ndWrpObj);
        }

        return nDetailsWrpLst;
    }

   

    @AuraEnabled
    public static void deleteContacts(list<Id> lstConIds) {
        try {
            list<IETRS_Insp_Notification_Detail__c> lstConsToDelete = new List<IETRS_Insp_Notification_Detail__c>();
            System.debug('lstConIds ====> ' + lstConIds);
            for (Id idCon : lstConIds) {
                lstConsToDelete.add(
                    new IETRS_Insp_Notification_Detail__c(Id = idCon)
                );
            }
            if (!lstConsToDelete.isEmpty()) {
                delete lstConsToDelete;
            }
        } catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
    }
    //UPDATE "NOTIFICATION DETAIL OBJECT" BASED ON THE RECORD ID
    @AuraEnabled
    public static void updateNotifcationDetailObject(
        IETRS_Insp_Notification_Detail__c nwDataNoDetailObj
    ) {
        List<IETRS_Insp_Notification_Detail__c> updatenDetailLst = new List<IETRS_Insp_Notification_Detail__c>();

        updatenDetailLst.add(nwDataNoDetailObj);

        if (updatenDetailLst.size() > 0)
            update updatenDetailLst;
    }

    //UPDATE THE RECORD IN NOTIFICATION P5-95 RECORD TYPE.
    @AuraEnabled
    public static void updateNotificationRecord(
        String notificationRecordID,
        String grade1,
        String grade2,
        String grade3
    ) {
        List<IETRS_Insp_Notification__c> notficationLstObj = new List<IETRS_Insp_Notification__c>();

        for (IETRS_Insp_Notification__c notificatObj : [
            SELECT
                ID,
                IETRS_Total_Grade_1_Unrepaired__c,
                IETRS_Total_Grade_2_Unrepaired__c,
                IETRS_Total_Grade_3_Unrepaired__c
            FROM IETRS_Insp_Notification__c
            WHERE id = :notificationRecordID
        ]) {
            notificatObj.IETRS_Total_Grade_1_Unrepaired__c = decimal.valueOf(
                grade1
            );
            notificatObj.IETRS_Total_Grade_2_Unrepaired__c = decimal.valueOf(
                grade2
            );
            notificatObj.IETRS_Total_Grade_3_Unrepaired__c = decimal.valueOf(
                grade3
            );
            if (grade1 != null && grade2 != null && grade3 != null) {
                if (
                    Integer.valueOf(grade1) != 0 &&
                    Integer.valueOf(grade1) != 0 &&
                    Integer.valueOf(grade1) != 0
                ) {
                    notificatObj.IETRS_Submitted__c = 'In Progress';
                }
            }
            notficationLstObj.add(notificatObj);
        }
        try {
            if (notficationLstObj.size() > 0)
                update notficationLstObj;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /*
     * @Method: getRepairedLeakCount
     * @Description: Used to return the Total Repaired Leaks field from the active Notification. Used to refresh the Header PLI component after the Detail component adds or deletes a Repaired Leak.
     * @Param: String - strNotificationID - ID of the PS95 Notification Header record to return.
     * @Return: Decimal - Total Number of Repaired Leaks
     */
    @AuraEnabled
    public static Decimal getRepairedLeakCount(String strNotificationID) {
        return [
            SELECT IETRS_Total_Repaired_Leaks__c
            FROM IETRS_Insp_Notification__c
            WHERE Id = :strNotificationID
            LIMIT 1
        ]
        .IETRS_Total_Repaired_Leaks__c;
    }

    @AuraEnabled
    public static IETRS_Insp_Notification__c updatenotificationTonullRecords(
        String notificationRecordID,
        String grade1,
        String grade2,
        String grade3
    ) {
        List<IETRS_Insp_Notification__c> notficationLstObj = new List<IETRS_Insp_Notification__c>();
        List<String> listOfNotificationDetaislIds = new List<String>();
        for (IETRS_Insp_Notification__c notificatObj : [
            SELECT
                ID,
                IETRS_Total_Grade_1_Unrepaired__c,
                IETRS_Total_Grade_2_Unrepaired__c,
                IETRS_Total_Grade_3_Unrepaired__c,
                IETRS_Submitted__c,
                IETRS_Submitted_Date__c,
                IETRS_Report_Period__c,
                (SELECT id FROM Notifications_Details__r)
            FROM IETRS_Insp_Notification__c
            WHERE id = :notificationRecordID
        ]) {
            notificatObj.IETRS_Total_Grade_1_Unrepaired__c = decimal.valueOf(
                grade1
            );
            notificatObj.IETRS_Total_Grade_2_Unrepaired__c = decimal.valueOf(
                grade2
            );
            notificatObj.IETRS_Total_Grade_3_Unrepaired__c = decimal.valueOf(
                grade3
            );
            if (grade1 != null && grade2 != null && grade3 != null) {
                if (
                    Integer.valueOf(grade1) != 0 &&
                    Integer.valueOf(grade1) != 0 &&
                    Integer.valueOf(grade1) != 0
                ) {
                    notificatObj.IETRS_Submitted__c = 'In Progress';
                } else {
                    notificatObj.IETRS_Submitted__c = 'Yes';
                    notificatObj.IETRS_Submitted_Date__c = System.now();
                    Date dtDueDate = null;
                    switch on notificatObj.IETRS_Report_Period__c.right(3) {
                        when 'Jun' {
                            dtDueDate = date.NewInstance(
                                integer.valueof(
                                    notificatObj.IETRS_Report_Period__c.left(4)
                                ),
                                7,
                                16
                            );
                        }
                        when 'Dec' {
                            dtDueDate = date.NewInstance(
                                integer.valueof(
                                    notificatObj.IETRS_Report_Period__c.left(4)
                                ) + 1,
                                1,
                                16
                            );
                        }
                    }

                    notificatObj.IETRS_Filing_Status__c = notificatObj.IETRS_Submitted_Date__c >=
                        dtDueDate
                        ? 'Late'
                        : 'On Time';
                }
            }
            notficationLstObj.add(notificatObj);

            for (
                IETRS_Insp_Notification_Detail__c notiDetails : notificatObj.Notifications_Details__r
            ) {
                listOfNotificationDetaislIds.add(notiDetails.id);
            }
        }
        if (notficationLstObj.size() > 0)
            update notficationLstObj;

        System.debug(
            'listOfNotificationDetaislIds***' + listOfNotificationDetaislIds
        );
        if (listOfNotificationDetaislIds.size() > 0) {
            delete [
                SELECT id
                FROM IETRS_Insp_Notification_Detail__c
                WHERE id IN :listOfNotificationDetaislIds
            ];
        }
        if (notficationLstObj.size() > 0) {
            return notficationLstObj[0];
        } else {
            return null;
        }
    }

    //INSERT THE RECORD, WHEN THE NO RECORDS FOUND ON THE SEARCH RESULT OF P5-95.
    @AuraEnabled
    public static IETRS_Insp_Notification__c insertNewNotificationObject(
        IETRS_Insp_Notification__c newnotificationObj
    ) {
        newnotificationObj.IETRS_Submitted__c = 'In Progress';
        String RecordTypeName = 'PS-95';
        String NotificationRecordTypeId = getNotificationRecordTypeId(
            RecordTypeName
        );
        newnotificationObj.RecordTypeId = NotificationRecordTypeId;
        insert newnotificationObj;
        return newnotificationObj;
    }

    @AuraEnabled
    public static void createnotificationDetailRecord(
        IETRS_Insp_Notification_Detail__c newNotifiDetailObj
    ) {
        insert newNotifiDetailObj;
    }

    //FETCHING ADDRESS OF NOTIFICATION DETAIL OBJECT USING SYSTEM NAME(PIPE LINE SYSTEM)
    @AuraEnabled(cacheable=true)
    public static AddressWrp fetchAddressUsingSystemName(String accID) {
        AddressWrp adWrp;
        for (Schema.Account accObj : [
            SELECT
                id,
                parent.BillingStreet,
                parent.BillingState,
                parent.BillingCity,
                parent.BillingCountry,
                parent.BillingPostalCode
            FROM Account
            WHERE id = :accID
            LIMIT 1
        ]) {
            adWrp = new AddressWrp();
            adWrp.accountID = accobj.ParentId;

            if (accObj.parent.BillingStreet != null)
                adWrp.addressline1 = accObj.parent.BillingStreet;
            else
                adWrp.addressline1 = null;

            if (accObj.parent.BillingState != null)
                adWrp.addressline2 = accObj.parent.BillingState;
            else
                adWrp.addressline2 = null;

            if (accObj.parent.BillingCity != null)
                adWrp.City = accObj.parent.BillingCity;
            else
                adWrp.City = null;

            if (accObj.parent.BillingCountry != null)
                adWrp.Country = accObj.parent.BillingCountry;
            else
                adWrp.Country = null;

            if (accObj.parent.BillingPostalCode != null)
                adWrp.ZipCode = accObj.parent.BillingPostalCode;
            else
                adWrp.ZipCode = null;
        }

        return adWrp;
    }

    //This method used to delete the NotificationDetail record on DELETE
    @AuraEnabled
    public static void deleteNotificationDetailRecordById(Id recordId) {
        try {
            delete [
                SELECT Id
                FROM IETRS_Insp_Notification_Detail__c
                WHERE id = :recordId
                LIMIT 1
            ];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static void deleteNotificationDetailsRecordById(
        List<String> listofrecordIdsToDelet
    ) {
        System.debug(listofrecordIdsToDelet);

        try {
            delete [
                SELECT Id
                FROM IETRS_Insp_Notification_Detail__c
                WHERE id IN :listofrecordIdsToDelet
            ];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    //Added by Ayesha on 11th DEC 2020 to Notification
    //This method used to delete the NotificationDetail record on DELETE
    @AuraEnabled
    public static void deleteNotificationRecordById(Id recordId) {
        try {
            delete [
                SELECT Id
                FROM IETRS_Insp_Notification__c
                WHERE id = :recordId
                LIMIT 1
            ];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    //NEW FEATURE TEST
    //STANDBY FEATURE
    @AuraEnabled
    public static void removeDuplicatesRecord(
        String RecordId,
        String searchRENKey,
        String searchREIKey,
        String searchCountyKey,
        String sortBy,
        String sortDirection
    ){
        List<notificationDetailWrap> allObj = fetchNotificationDetailReccordsForRefresh
        (RecordId, searchRENKey, searchREIKey, searchCountyKey, sortBy, sortDirection);
        List<String> duplicateIds = extractDuplicateIds(allObj);
        deleteNotificationDetailsRecordById(duplicateIds);
    }

    //NEW FEATURE TEST
    //STANDBY FEATURE
    @AuraEnabled
    public static List<String> extractDuplicateIds(List<notificationDetailWrap> objs){
        Set<String> seenIds = new Set<String>();
        Set<String> duplicateIds = new Set<String>();
        for(notificationDetailWrap o : objs){
            if(seenIds.contains(o.Id)){
                system.debug('seen Ids: ' + o.Id);
                duplicateIds.add(o.Id);
            }else {
                seenIds.add(o.Id);
            }
        }
        return new List<String>(duplicateIds);
    }

    //For Check needs to be removed
    @AuraEnabled(cacheable=true)
    public static List<Account> getAccountList() {
        return [
            SELECT Id, Name, Type, Rating, Phone, Website, AnnualRevenue
            FROM Account
            LIMIT 10
        ];
    }

    @AuraEnabled
    public static boolean getPS95AccessCheckForProfile() {
        boolean isUserAccessToPS95_Status = false;
        try {
            if (featureManagement.checkPermission('Create_Edit_PS95_Reports')) {
                isUserAccessToPS95_Status = true;
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return isUserAccessToPS95_Status;
    }

    @AuraEnabled(cacheable=true)
    public static boolean isCurrentUserPortalUser() {
        boolean isCurrentUserIfPortalUserB = false;
        try {
            /* Id currentUserId =Userinfo.getUserId();
            List<User> listOfUsers=[SELECT id,UserType,UserName,Name,ContactId,Contact.Name,AccountId,IsActive FROM User WHERE IsActive=true AND UserType =:'CspLitePortal' AND Id=:currentUserId];
            if(listOfUsers.size()>0){

            }*/
            if (UserInfo.getUserType() == 'CspLitePortal') {
                isCurrentUserIfPortalUserB = true;
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return isCurrentUserIfPortalUserB;
    }

    /**
     * Description : This methods helps to identify the
     */
    @AuraEnabled
    public static boolean identifyPortalUserAcessOrganization(
        Id organizationId
    ) {
        boolean createAndEditAcess = false;
        try {
            Id currentUserId = Userinfo.getUserId();
            // FC Note: Replace all code in Try with the following and retest:
            Id idContactID = [
                SELECT ContactId
                FROM User
                WHERE
                    IsActive = TRUE
                    AND UserType = 'CspLitePortal'
                    AND Id = :currentUserId
            ]
            ?.ContactID;
            if (
                [
                    SELECT id, ContactId, AccountId, Account.Name, Contact.Name
                    FROM AccountContactRelation
                    WHERE
                        ContactId = :idContactID
                        AND AccountId = :organizationId
                ]
                ?.size() > 0
            ) {
                createAndEditAcess = true;
            } else {
                createAndEditAcess = false;
            }

            //FC NOTE: REPLACED THE FOLLOWING CODE WITH THE ABOVE ^^^^^^^^^

            // List<User> listOfUsers=[SELECT id,UserType,UserName,Name,ContactId,Contact.Name,AccountId,IsActive FROM User WHERE IsActive=true AND UserType ='CspLitePortal' AND Id=:currentUserId];
            // Id  contactId;
            // if(listOfUsers.size()>0){
            //     contactId =listOfUsers[0].ContactId;
            // }

            // List<AccountContactRelation> listOfAccountContactRelationships=new List<AccountContactRelation >();
            // Map<Id,Set<Id>> mapofContactIdWithSetOfAccountIds=new Map<Id,Set<Id>>();
            // if(contactId!=null){
            //     listOfAccountContactRelationships = [SELECT id,ContactId,AccountId,Account.Name,Contact.Name from AccountContactRelation WHERE ContactId=:contactId];
            //         if(listOfAccountContactRelationships.size()>0){
            //             for(AccountContactRelation  accountContactRelationInstance:listOfAccountContactRelationships){
            //                 if(!mapofContactIdWithSetOfAccountIds.ContainsKey(accountContactRelationInstance.ContactId)){
            //                     mapofContactIdWithSetOfAccountIds.put(accountContactRelationInstance.ContactId,new Set<Id>{accountContactRelationInstance.AccountId});
            //                 }else{
            //                     mapofContactIdWithSetOfAccountIds.get(accountContactRelationInstance.ContactId).add(accountContactRelationInstance.AccountId);
            //                 }
            //             }
            //         }
            // }
            // // [SELECT id,RecordType.Name,IETRS_PS95_Organization__c, FROM IETRS_Insp_Notification__c WHERE Id=:notificationId ];
            // if(mapofContactIdWithSetOfAccountIds.containsKey(contactId)){
            //     if(mapofContactIdWithSetOfAccountIds.get(contactId).contains(organizationId)){
            //      createAndEditAcess = true;
            //      }
            // }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }

        return createAndEditAcess;
    }

    @AuraEnabled
    public static String getAccountIdByNotificationIdForPS95(
        String notificationId
    ) {
        String accountId = '';
        system.debug(notificationId);
        try {
            accountId = [
                SELECT id, IETRS_PS95_Organization__c
                FROM IETRS_Insp_Notification__c
                WHERE Id = :notificationId
            ]
            .IETRS_PS95_Organization__c;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return accountId;
    }

    @AuraEnabled
    public static string getOrgofRegEnt(String regEntId) {
        try {
            return [SELECT parent.parent.Id FROM Account WHERE ID = :regEntId]
            .parent.parent.Id;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static String getAccountIdByNotificationIdForSRCAndImp(
        String operatorName
    ) {
        String accountId = '';
        try {
            accountId = [
                SELECT id
                FROM Account
                WHERE Name = :operatorName
                LIMIT 1
            ]
            .Id;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return accountId;
    }

    @AuraEnabled
    public static List<IETRS_Inspection_Public_FC_Document__c> getUploadedPS95Documents(
        Id notificationId
    ) {
        List<IETRS_Inspection_Public_FC_Document__c> result;
        try {
            result = [
                SELECT
                    Id,
                    IETRS_Original_File_Name__c,
                    IETRS_Related_File_Correspondence__c
                FROM IETRS_Inspection_Public_FC_Document__c
                WHERE
                    IETRS_Notification__c = :notificationId
                    AND IETRS_Document_Type__c = 'PS-95 Submission'
            ];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return result;
    }

    //ALL PICKLIST VALUES TOGETHER IN SINGLE OBJECT
    public class picklistWrap {
        @AuraEnabled
        public List<String> LeakLocationlst;
        @AuraEnabled
        public List<String> LeakClassificationlst;
        @AuraEnabled
        public List<String> PipeTypelst;
        @AuraEnabled
        public List<String> LeakCauselst;
        @AuraEnabled
        public List<String> LeakRepairLst;
        @AuraEnabled
        public List<String> pipeSizeLst;
        @AuraEnabled
        public List<String> LeakLocatedOnLst;
        @AuraEnabled
        public List<String> FacilityTypeLst;

        public picklistWrap() {
            LeakLocationlst = new List<String>();
            LeakClassificationlst = new List<String>();
            PipeTypelst = new List<String>();
            LeakCauselst = new List<String>();
            LeakRepairLst = new List<String>();
            pipeSizeLst = new List<String>();
            LeakLocatedOnLst = new List<String>();
            FacilityTypeLst = new List<String>();
        }
    }

    //NOTIFICATION DETAIL OBJECT WRAPPER LIST
    public class notificationDetailWrap {
        @AuraEnabled
        public Boolean isCheck;
        @AuraEnabled
        public String dateStr;
        @AuraEnabled
        public String systemnameStr;
        @AuraEnabled
        public String LeakCuase;
        @AuraEnabled
        public String LeakRepairMethod;
        @AuraEnabled
        public String LeakLocation;
        @AuraEnabled
        public String PipeSize;
        @AuraEnabled
        public String pipeType;
        @AuraEnabled
        public String LeakClassification;
        @AuraEnabled
        public IETRS_Insp_Notification_Detail__c noDetailObj;
        @AuraEnabled
        public String Id;
        @AuraEnabled
        public String RegulatedEntityId;
    }

    //NOTIFICATION ADDRESS WRAPPER
    public class AddressWrp {
        @AuraEnabled
        public String addressline1;
        @AuraEnabled
        public String addressline2;
        @AuraEnabled
        public String City;
        @AuraEnabled
        public String Country;
        @AuraEnabled
        public String ZipCode;
        @AuraEnabled
        public String accountID;
    }
}