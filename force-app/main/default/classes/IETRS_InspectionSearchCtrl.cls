/**
 * @File Name          : IETRS_InspectionSearchCtrl.cls
 * @Description        : Controller Class for Inspection Search lightning component
 * @Author             : Sandhya Belur
 * @Group              :
 * @Last Modified By   : Sandhya Belur
 * @Last Modified On   : 05/04/2020
 * @Modification Log   :
 * Ver      Date            Author              Modification
 * 1.0      05/04/2020      Sandhya Belur       Initial Version
 **/
public class IETRS_InspectionSearchCtrl {
    @AuraEnabled
    public static List<String> getsObjects() {
        Set<String> sObjectSet = new Set<String>();
        List<String> sObjectList = new List<String>();

        for (IETRS_Custom_Search_Page_Configuration__mdt obj : [
            SELECT
                MasterLabel,
                IETRS_Object_to_Search__c,
                IETRS_Field_to_Search_Label__c,
                IETRS_Field_to_Search_API_Name__c,
                IETRS_Search_Type__c
            FROM IETRS_Custom_Search_Page_Configuration__mdt
        ]) {
            DescribeSObjectResult res = Schema.getGlobalDescribe().get(obj.IETRS_Object_to_Search__c).getDescribe();
            sObjectSet.add(obj.IETRS_Object_to_Search__c + '####' + res.getLabel());
        }
        sObjectList = new List<String>(sObjectSet);
        return sObjectList;
    }

    @AuraEnabled
    public static String getFieldSetMember(String objectName) {
        List<FieldSetMemberWrapperClass> wrapperList = new List<FieldSetMemberWrapperClass>();
        Map<String, FieldSetMemberWrapperClass> lookupFieldsByAPIName = new Map<String, FieldSetMemberWrapperClass>();
        for (IETRS_Custom_Search_Page_Configuration__mdt obj : [
            SELECT
                MasterLabel,
                IETRS_Object_to_Search__c,
                IETRS_Field_to_Search_Label__c,
                IETRS_Field_to_Search_API_Name__c,
                IETRS_Search_Type__c,
                IETRS_Search_Field_Display_Order__c,
                IETRS_Lookup_Object_API_Name__c,
                IETRS_Lookup_Object_Filter__c,
                IETRS_Date_Search_Options__c
            FROM IETRS_Custom_Search_Page_Configuration__mdt
            WHERE IETRS_Object_to_Search__c = :objectName
            ORDER BY IETRS_Search_Field_Display_Order__c
        ]) {
            FieldSetMemberWrapperClass wrapper = new FieldSetMemberWrapperClass();
            wrapper.isDBRequired = false;
            wrapper.isRequired = false;
            wrapper.fieldType = obj.IETRS_Search_Type__c;
            wrapper.fieldLabel = obj.IETRS_Field_to_Search_Label__c;
            wrapper.fieldAPIName = obj.IETRS_Field_to_Search_API_Name__c;
            if (obj.IETRS_Date_Search_Options__c != null) {
                wrapper.showStartDate = obj.IETRS_Date_Search_Options__c == 'Only Show Start Date Input';
                wrapper.showEndDate = obj.IETRS_Date_Search_Options__c == 'Only Show End Date Input';
            }
            if (string.isNotBlank(obj.IETRS_Search_Type__c) && obj.IETRS_Search_Type__c.equalsIgnoreCase('Picklist')) {
                Map<String, String> picklistValues = new Map<String, String>();
                Schema.SObjectType sObj;
                String fieldName = '';
                if (obj.IETRS_Field_to_Search_API_Name__c.contains('.')) {
                    String[] splitData = obj.IETRS_Field_to_Search_API_Name__c.split('\\.');
                    string relatedObject = splitData[0].replace('__r', '__c');
                    sObj = Schema.getGlobalDescribe().get(relatedObject);
                    fieldName = splitData[1];
                } else {
                    sObj = Schema.getGlobalDescribe().get(obj.IETRS_Object_to_Search__c);
                    fieldName = obj.IETRS_Field_to_Search_API_Name__c;
                }

                Schema.DescribeSObjectResult desResObj = sObj.getDescribe();
                wrapper.pickListValues = sObj.getDescribe()
                    .fields.getMap()
                    .get(fieldName)
                    .getDescribe()
                    .getPicklistValues();
            } else if (obj.IETRS_Search_Type__c == 'Lookup') {
                wrapper.lookupOptions = new List<Map<String, String>>();
                wrapper.lookupOptions.add(new Map<String, String>{ 'value' => '', 'label' => 'All' });
                wrapper.lookupObjectAPIName = obj.IETRS_Lookup_Object_API_Name__c;
                wrapper.lookupSearchFilter = obj.IETRS_Lookup_Object_Filter__c;
                lookupFieldsByAPIName.put(wrapper.fieldAPIName, wrapper);
            }
            wrapperList.add(wrapper);
        }
        // get records for the lookup fields if there are any
        if (!lookupFieldsByAPIName.isEmpty()) {
            for (FieldSetMemberWrapperClass field : lookupFieldsByAPIName.values()) {
                String objectToQuery = field.lookupObjectAPIName;
                String query = 'SELECT Id, Name FROM ' + objectToQuery;
                if (field.lookupSearchFilter != null) {
                    query += ' WHERE ' + field.lookupSearchFilter;
                }
                query += ' ORDER BY Name';
                System.debug(query);
                try {
                    for (SObject obj : Database.query(query)) {
                        field.lookupOptions.add(
                            new Map<String, String>{
                                'value' => (String) obj.get('Name'),
                                'label' => (String) obj.get('Name')
                            }
                        );
                    }
                } catch (Exception e) {
                    // make the field a text input if the object can't be queried
                    field.fieldType = 'Text';
                }
            }
        }
        System.debug('#### wrapperList ' + wrapperList);
        return JSON.serialize(wrapperList);
    }

    public class FieldSetMemberWrapperClass {
        @AuraEnabled
        public Boolean isDBRequired { get; set; }
        @AuraEnabled
        public Boolean isRequired { get; set; }
        @AuraEnabled
        public String fieldType { get; set; }
        @AuraEnabled
        public String fieldLabel { get; set; }
        @AuraEnabled
        public String fieldAPIName { get; set; }
        @AuraEnabled
        public List<Map<String, String>> lookupOptions { get; set; }
        @AuraEnabled
        public Boolean showStartDate { get; set; }
        @AuraEnabled
        public Boolean showEndDate { get; set; }
        public String lookupObjectAPIName { get; set; }
        public String lookupSearchFilter { get; set; }
        @AuraEnabled
        public List<Schema.PicklistEntry> pickListValues { get; set; }
        public FieldSetMemberWrapperClass() {
            this.showStartDate = true;
            this.showEndDate = true;
        }
    }

    @AuraEnabled
    public static DisplayResultWrapper displayObjResults(string objName, string filterJSON) {
        try {
            string query = 'Select Id';
            string whereClause = '';
            Map<String, Object> filterMap = (Map<String, Object>) JSON.deserializeUntyped(filterJSON);
            final Map<String, String> columnTypeByFieldType = new Map<String, String>{
                'BOOLEAN' => 'boolean',
                'CURRENCY' => 'currency',
                'DATE' => 'date-local',
                'DATETIME' => 'date',
                'DOUBLE' => 'number',
                'INTEGER' => 'number',
                'LONG' => 'number',
                'PERCENT' => 'percent',
                'URL' => 'url'
            };
            Set<Id> filteredPrimaryObjectIds = new Set<Id>();
            Map<String, String> childObjectQueryBySearchField = new Map<String, String>();
            Map<String, String> primaryObjectFieldBySearchField = new Map<String, String>();
            List<IETRS_Custom_Search_Page_Configuration__mdt> searchPageConfigFields = [
                SELECT
                    MasterLabel,
                    IETRS_Object_to_Search__c,
                    IETRS_Field_to_Search_Label__c,
                    IETRS_Field_to_Search_API_Name__c,
                    IETRS_Search_Type__c,
                    IETRS_Filter_Result_Child_Object__c,
                    IETRS_Primary_Object_Field_on_Child_Obj__c
                FROM IETRS_Custom_Search_Page_Configuration__mdt
                WHERE IETRS_Object_to_Search__c = :objName
                ORDER BY IETRS_Search_Field_Display_Order__c
            ];
            List<IETRS_Custom_Search_Page_Results_Config__mdt> searchResultFields = [
                SELECT IETRS_Search_Result_Field_Label__c, IETRS_Search_Result_Field_API_Name__c, IETRS_Sort_Order__c
                FROM IETRS_Custom_Search_Page_Results_Config__mdt
                WHERE IETRS_Object_Searched__c = :objName
                ORDER BY IETRS_Sort_Order__c ASC
            ];
            for (IETRS_Custom_Search_Page_Configuration__mdt obj : searchPageConfigFields) {
                boolean isRelationshipField = obj.IETRS_Field_to_Search_API_Name__c.contains('__r');
                string relationShipField = isRelationshipField
                    ? obj.IETRS_Field_to_Search_API_Name__c.split('\\.')[0]
                    : '';
                if (
                    (filterMap.containsKey(relationShipField)) ||
                    (filterMap.containsKey(obj.IETRS_Field_to_Search_API_Name__c) &&
                    filterMap.get(obj.IETRS_Field_to_Search_API_Name__c) != null)
                ) {
                    // check if the config record indicates the value should be searched on a child object
                    if (
                        obj.IETRS_Filter_Result_Child_Object__c != null &&
                        obj.IETRS_Filter_Result_Child_Object__c != 'None'
                    ) {
                        String searchVal = String.valueOf(filterMap.get(obj.IETRS_Field_to_Search_API_Name__c));
                        if (String.isEmpty(searchVal)) {
                            continue;
                        }
                        String childQuery =
                            'SELECT ' +
                            obj.IETRS_Primary_Object_Field_on_Child_Obj__c +
                            ' FROM ' +
                            obj.IETRS_Filter_Result_Child_Object__c +
                            ' WHERE ' +
                            obj.IETRS_Field_to_Search_API_Name__c +
                            ' ';
                        String operator = '=';
                        searchVal = ' \'' + searchVal + '\'';
                        if (searchVal.contains('*')) {
                            operator = 'LIKE';
                            searchVal = ' \'%' + searchVal.replace('*', '') + '%\'';
                        }
                        childQuery += operator + searchVal;
                        childObjectQueryBySearchField.put(obj.IETRS_Field_to_Search_API_Name__c, childQuery);
                        primaryObjectFieldBySearchField.put(
                            obj.IETRS_Field_to_Search_API_Name__c,
                            obj.IETRS_Primary_Object_Field_on_Child_Obj__c
                        );
                        continue;
                    }
                    Map<String, Object> filterNestMap;
                    string nestChildVal = '';
                    string nestChildValE = '';
                    if (isRelationshipField) {
                        filterNestMap = (Map<String, Object>) filterMap.get(
                            obj.IETRS_Field_to_Search_API_Name__c.split('\\.')[0]
                        );
                        nestChildVal = String.valueOf(
                            filterNestMap.get(obj.IETRS_Field_to_Search_API_Name__c.split('\\.')[1])
                        );
                        nestChildValE = String.valueOf(
                            filterNestMap.get(obj.IETRS_Field_to_Search_API_Name__c.split('\\.')[1] + '_E')
                        );
                    }
                    if (obj.IETRS_Search_Type__c.equalsIgnoreCase('Date')) {
                        String strSDate = isRelationshipField
                            ? nestChildVal
                            : string.valueOf(filterMap.get(obj.IETRS_Field_to_Search_API_Name__c));
                        String strEDate = isRelationshipField
                            ? nestChildValE
                            : string.valueOf(
                                    string.valueOf(filterMap.get(obj.IETRS_Field_to_Search_API_Name__c + '_E'))
                                );
                        // don't add date filters if both are blank
                        if (String.isEmpty(strSDate) && String.isEmpty(strEDate)) {
                            continue;
                        }
                        Date sDate;
                        Date eDate;
                        // if only start date is provided, filter should be date >= start date
                        // if only end date is provided filter should be date <= end date
                        // if both are provided, filter sohuld date >= start date and date <= end date
                        if (!String.isEmpty(strSDate)) {
                            sDate = Date.valueOf(strSDate);
                            whereClause +=
                                obj.IETRS_Field_to_Search_API_Name__c +
                                ' >= ' +
                                sDate.year() +
                                '-' +
                                string.valueOf(sDate.month()).leftPad(2, '0') +
                                '-' +
                                string.valueOf(sDate.day()).leftPad(2, '0') +
                                ' AND ';
                        }
                        if (!String.isEmpty(strEDate)) {
                            eDate = Date.valueOf(strEDate);
                            whereClause +=
                                obj.IETRS_Field_to_Search_API_Name__c +
                                ' <= ' +
                                eDate.year() +
                                '-' +
                                string.valueOf(eDate.month()).leftPad(2, '0') +
                                '-' +
                                string.valueOf(eDate.day()).leftPad(2, '0') +
                                ' AND ';
                        }
                    } else {
                        String searchVal = isRelationshipField
                            ? nestChildVal
                            : string.valueOf(filterMap.get(obj.IETRS_Field_to_Search_API_Name__c));

                        if (string.isNotBlank(searchVal)) {
                            // if the field is configured to search all text fields
                            if (obj.IETRS_Field_to_Search_API_Name__c == '*') {
                                List<String> searchAllExpressions = new List<String>();
                                Schema.SObjectType searchObject = Schema.getGlobalDescribe().get(objName);
                                Schema.DescribeSObjectResult searchObjectDescribe = searchObject.getDescribe();
                                Map<String, Schema.SObjectField> fieldMap = searchObjectDescribe.fields.getMap();
                                // remove the fuzzy search indicator if provided since we're always doing a fuzzy
                                // search for this search field
                                searchVal = searchVal.remove('*');
                                for (String searchField : fieldMap.keySet()) {
                                    Schema.SObjectField fieldDef = fieldMap.get(searchField);
                                    if (String.valueOf(fieldDef.getDescribe().getType()) == 'STRING') {
                                        searchAllExpressions.add(searchField + ' LIKE \'%' + searchVal + '%\'');
                                    }
                                }
                                if (!searchAllExpressions.isEmpty()) {
                                    whereClause += '(' + String.join(searchAllExpressions, ' OR ') + ') AND ';
                                }
                            } else {
                                String sVal = '\'' + searchVal + '\'';
                                String operator = '=';

                                if (searchVal.contains('*')) {
                                    operator = 'LIKE';
                                    sVal = '\'%' + searchVal.replace('*', '') + '%\'';
                                }

                                whereClause =
                                    whereClause +
                                    obj.IETRS_Field_to_Search_API_Name__c +
                                    ' ' +
                                    operator +
                                    ' ' +
                                    sVal +
                                    ' AND ';
                            }
                        }
                    }
                }
            }

            if (!childObjectQueryBySearchField.isEmpty()) {
                for (String searchField : childObjectQueryBySearchField.keySet()) {
                    String childQuery = childObjectQueryBySearchField.get(searchField);
                    String primarySearchObjectField = primaryObjectFieldBySearchField.get(searchField);
                    if (primarySearchObjectField == null) {
                        continue;
                    }
                    Boolean isRelationshipField = primarySearchObjectField.contains('.');
                    String parentObjName;
                    String fieldName;
                    if (isRelationshipField) {
                        parentObjName = primarySearchObjectField.substringBefore('.');
                        fieldName = primarySearchObjectField.substringAfter('.');
                    }
                    for (Sobject obj : Database.query(childQuery)) {
                        Id primaryObjectId;
                        if (isRelationshipField) {
                            primaryObjectId = (Id) obj.getSObject(parentObjName).get(fieldName);
                        } else {
                            primaryObjectId = (Id) obj.get(primarySearchObjectField);
                        }
                        filteredPrimaryObjectIds.add(primaryObjectId);
                    }
                }
                whereClause += 'Id IN :filteredPrimaryObjectIds';
            }

            whereClause = whereClause.removeEnd('AND ');

            Map<String, Map<String, String>> fieldsMap = new Map<String, Map<String, String>>();
            DisplayResultWrapper objWrap = new DisplayResultWrapper();
            List<Map<String, Object>> lstRecords = new List<Map<String, Object>>();
            for (IETRS_Custom_Search_Page_Results_Config__mdt objRes : searchResultFields) {
                if (!objRes.IETRS_Search_Result_Field_API_Name__c.contains('&')) {
                    fieldsMap.put(
                        objRes.IETRS_Search_Result_Field_API_Name__c,
                        new Map<String, String>{
                            'label' => objRes.IETRS_Search_Result_Field_Label__c,
                            'type' => 'text'
                        }
                    );

                    query = query + ', ' + objRes.IETRS_Search_Result_Field_API_Name__c;
                }
            }
            whereClause = string.isNotBlank(whereClause) ? ' WHERE ' + whereClause : '';
            query = query + ' FROM ' + objName + whereClause;
            System.debug(query);
            Map<String, Schema.SObjectType> glbDescribe = Schema.getGlobalDescribe();

            // skip the query if the results are supposed to be filtered by searching a child object first
            // and the number of primary object ids to search for was empty
            if (
                childObjectQueryBySearchField.isEmpty() || // not searching for child objects
                (!childObjectQueryBySearchField.isEmpty() && !filteredPrimaryObjectIds.isEmpty()) // searching for child objects and found results
            ) {
                for (sObject obj : Database.query(query)) {
                    Map<String, Object> mpCurrentRec = new Map<String, Object>();
                    mpCurrentRec.put('Id', obj.get('Id'));
                    for (String fieldApi : fieldsMap.keySet()) {
                        if (!fieldApi.contains('&')) {
                            if (fieldAPI.contains('.')) {
                                String[] splitData = fieldAPI.split('\\.');
                                string relatedObject = splitData[0].replace('__r', '__c');
                                if (obj.getSObject(splitData[0]) != null) {
                                    Schema.DescribeFieldResult f = glbDescribe.get(objName)
                                        .getDescribe()
                                        .fields.getMap()
                                        .get(relatedObject)
                                        .getDescribe();
                                    Schema.SObjectType reference = f.getReferenceTo()[0];

                                    String fieldType = String.valueOf(
                                        glbDescribe.get(reference.getDescribe().getName())
                                            .getDescribe()
                                            .fields.getMap()
                                            .get(splitData[1])
                                            .getDescribe()
                                            .getType()
                                    );
                                    if (columnTypeByFieldType.containsKey(fieldType)) {
                                        fieldsMap.get(fieldApi).put('type', columnTypeByFieldType.get(fieldType));
                                    }
                                    if (fieldType.equalsIgnoreCase('Address')) {
                                        SObject relatObj = obj.getSObject(splitData[0]);
                                        Object relatedFieldData = relatObj.get(splitData[1]);
                                        if (relatedFieldData != null) {
                                            Address objAdd = (Address) relatedFieldData;
                                            mpCurrentRec.put(
                                                fieldAPI,
                                                objAdd.getStreet() +
                                                objAdd.getCity() +
                                                objAdd.getState() +
                                                objAdd.getPostalCode() +
                                                objAdd.getCountry()
                                            );
                                        }
                                    } else {
                                        mpCurrentRec.put(fieldAPI, obj.getSObject(splitData[0]).get(splitData[1]));
                                    }
                                }
                            } else {
                                String fType = String.valueOf(
                                    glbDescribe.get(objName)
                                        .getDescribe()
                                        .fields.getMap()
                                        .get(fieldAPI)
                                        .getDescribe()
                                        .getType()
                                );
                                if (columnTypeByFieldType.containsKey(fType)) {
                                    fieldsMap.get(fieldApi).put('type', columnTypeByFieldType.get(fType));
                                }
                                mpCurrentRec.put(fieldAPI, obj.get(fieldAPI));
                                // if (fType.equalsIgnoreCase('Date') && obj.get(fieldAPI) != null) {
                                //     Date dtValue = Date.valueOf(String.valueOf(obj.get(fieldAPI)));
                                //     String strDate = DateTime.newInstance(dtValue.year(), dtValue.month(), dtValue.day())
                                //         .format('MM-dd-yyyy');
                                //     mpCurrentRec.put(fieldAPI, strDate);
                                // } else {
                                //     mpCurrentRec.put(fieldAPI, obj.get(fieldAPI));
                                // }
                            }
                        }
                    }
                    lstRecords.add(mpCurrentRec);
                }
            }
            objWrap.mapCols = fieldsMap;
            //objWrap.lstRecords = lstData;
            objWrap.lstRecords = lstRecords;
            return objWrap;
        } catch (Exception e) {
            String errorMsg = e.getMessage();
            throw new AuraHandledException(errorMsg);
        }
    }

    public class DisplayResultWrapper {
        @AuraEnabled
        public List<Map<String, Object>> lstRecords { get; set; }
        @AuraEnabled
        public Map<String, Map<String, String>> mapCols { get; set; }
    }
}