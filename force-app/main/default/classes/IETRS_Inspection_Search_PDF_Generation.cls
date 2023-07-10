public class IETRS_Inspection_Search_PDF_Generation {
    public DisplayResultWrapper DRW{get;set;}
    public List<Map<String, Object>> lstRecords { get; set; }
    public List<IETRS_Custom_Search_Page_Results_Config__mdt> fieldList;  
    public Map<String,String> fieldMap {get;set;}
    public List<String> mapColsLableList { get; set;}
    public Map<String,String> mapCols {get;set;}
    public IETRS_Inspection_Search_PDF_Generation()
    {
        String sObj=system.currentpagereference().getparameters().get('sObj');
        String filterJSON=system.currentpagereference().getparameters().get('filterJSON');
        system.debug('sObj :'+sObj);
        fieldList=new List<IETRS_Custom_Search_Page_Results_Config__mdt>();
        fieldMap=new Map<String,String>();
        DRW=new DisplayResultWrapper();
        DRW=displayObjResults(sObj,filterJSON);
        mapColsLableList=new List<String>();
        for(IETRS_Custom_Search_Page_Results_Config__mdt ICSPRC:fieldList)
        {
            mapColsLableList.add(ICSPRC.IETRS_Search_Result_Field_Label__c);
            fieldMap.put(ICSPRC.IETRS_Search_Result_Field_Label__c,ICSPRC.IETRS_Search_Result_Field_API_Name__c);
        }
    }
    public DisplayResultWrapper displayObjResults(string objName, string filterJSON) {
        system.debug('objName:'+objName);
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
                        system.debug('filterMap#'+filterMap);
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
            fieldList.addAll(searchResultFields);
            system.debug('##searchResultFields'+searchResultFields);
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
            List<List<Object>> setOfListObjects=new List<List<Object>>();
            List<Object> lstRecords=Database.query(query);
            Integer cnt=lstRecords.size()/1000;
            
            if(cnt==0)
            {
                setOfListObjects.add(lstRecords);
            }
            else
            {
                for(Integer i=0;i<cnt;i++)
                {
                    List<Object> tempList=new List<Object>();
                    for(integer j=1000*i;j<1000*(i+1);j++)
                    {
                        tempList.add(lstRecords[j]); 
                        
                    }
                    setOfListObjects.add(tempList);
                }
                Integer remaingCnt=lstRecords.size()-(cnt*1000);
                if(remaingCnt!=0)
                {
                    List<Object> tempList=new List<Object>();
                    for(integer k=(1000*cnt)-1;k<(1000*cnt)+remaingCnt;k++)
                    {
                        tempList.add(lstRecords[k]); 
                        
                    }
                    setOfListObjects.add(tempList);
                }
            }
            objWrap.lstRecords=setOfListObjects; 
            objWrap.mapCols=fieldsMap;
            return objWrap;    
            
        } catch (Exception e) {
            String errorMsg = e.getMessage();
            // throw new AuraHandledException(errorMsg);
            return null;
        }
    }
    
    public class DisplayResultWrapper {
        
        public List<List<Object>> lstRecords { get; set; }
        
        public Map<String, Map<String, String>> mapCols { get; set; }
    }
}