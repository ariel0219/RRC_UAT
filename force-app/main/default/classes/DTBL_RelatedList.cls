public with sharing class DTBL_RelatedList {
    private static Map<String, String> mapFieldToLwcDataType = new Map<String, String>{
        'datetime' => 'date',
        'date' => 'date-local'
    };
    public class ColumnJson {
        @AuraEnabled
        public String fieldName;
        @AuraEnabled
        public String label;
        @AuraEnabled
        public String type;
        @AuraEnabled
        public Boolean editable;
        @AuraEnabled
        public Boolean sortable;
        @AuraEnabled
        public Boolean wrapText = false;
        @AuraEnabled
        public TypeAttributes typeAttributes = null;
    }

    public virtual class TypeAttributes {
    }

    public class TypeAttributeColumnJsonWithPicklist extends TypeAttributes {
        @AuraEnabled
        public List<DTBL_PicklistColumnUtils.PicklistValue> options = new List<DTBL_PicklistColumnUtils.PicklistValue>();
        @AuraEnabled
        public TypeAttributeContext context = new TypeAttributeContext();
        @AuraEnabled
        public String fieldName;

        public TypeAttributeColumnJsonWithPicklist(
            List<DTBL_PicklistColumnUtils.PicklistValue> options,
            String fieldName
        ) {
            this.options = options;
            this.fieldName = fieldName;
        }
    }

    public class TypeAttributeContext {
        @AuraEnabled
        public string fieldName = 'Id';
    }

    public class TypeAttributeColumnLookup extends TypeAttributes {
        public String placeholder;
        public String objectApiName;
        public String fieldName;
        public String label;
        public TypeAttributeColumnLookupValue value = new TypeAttributeColumnLookupValue();
        public TypeAttributeContext context = new TypeAttributeContext();
        public String variant = 'label-hidden';
        public String name;
        public List<String> fields;
        public String target = '_self';
    }

    public class TypeAttributeColumnLookupValue {
        public String fieldName;
    }

    public class TypeAttributeColumnTextarea extends TypeAttributes {
        @AuraEnabled
        public TypeAttributeContext context = new TypeAttributeContext();
        @AuraEnabled
        public String fieldName;

        public TypeAttributeColumnTextarea(String fieldName) {
            this.fieldName = fieldName;
        }
    }

    public class ListResults {
        @AuraEnabled
        public List<SObject> records;
        @AuraEnabled
        public Map<String, ColumnJson> cols;
        @AuraEnabled
        public Integer count;
        @AuraEnabled
        public String iconName;
        public ListResults(
            List<SObject> records,
            Map<String, ColumnJson> cols,
            Integer count,
            String iconName
        ) {
            this.records = records;
            this.cols = cols;
            this.count = count;
            this.iconName = iconName;
        }
    }

    /**
     * Purpose : This method is used for building the Column JSON for data table
     */
    @AuraEnabled
    public static ListResults buildFieldJSON(
        String soql,
        String objectName,
        String whereClause,
        String colsJson,
        Boolean elevatedContext
    ) {
        try {
            Map<String, ColumnJson> mapPreCols = getDatatableColumns(
                colsJson,
                objectName
            );
            return new ListResults(
                getRecords(soql, elevatedContext),
                mapPreCols,
                countRecords(objectName, whereClause, elevatedContext),
                DTBL_IconUtils.getIconName(objectName)
            );
        } catch (Exception e) {
            AuraHandledException ahe = new AuraHandledException('');
            ahe.setMessage('Error: ' + e.getMessage());
            throw ahe;
        }
    }

    @AuraEnabled
    public static Map<String, ColumnJson> getDatatableColumns(
        String colsJson,
        String objectName
    ) {
        Map<String, ColumnJson> mapPreCols = (Map<String, ColumnJson>) Json.deserialize(
            colsJson,
            Map<String, ColumnJson>.class
        );
        SObjectType objType = Schema.getGlobalDescribe().get(objectName);
        Map<String, Schema.SObjectField> mfields = objType.getDescribe()
            .fields.getMap();
        List<ColumnJson> lstOfColumns = new List<ColumnJson>();
        for (String fieldName : mapPreCols.keySet()) {
            //continue;
            if (fieldName.contains('.')) {
                continue;
            }
            //Check if values predefined in LWC
            if (mapPreCols.containsKey(fieldName)) {
                switch on mapPreCols.get(fieldName).type {
                    when 'lookup' {
                        mapPreCols.get(fieldName)
                            .typeAttributes = new TypeAttributeColumnLookup();
                    }
                    when 'picklist' {
                        //set picklistValues for picklist type
                        DTBL_RelatedList.initPicklistColumn(
                            mapPreCols,
                            objectName,
                            fieldName
                        );
                    }
                    when 'textarea' {
                        mapPreCols.get(fieldName)
                            .typeAttributes = new TypeAttributeColumnTextarea(
                            fieldName
                        );
                    }
                }

                mapPreCols = checkOverride(mapPreCols, fieldName, mfields);
            }
        }
        return mapPreCols;
    }

    public static void initPicklistColumn(
        Map<String, ColumnJson> mapPreCols,
        String objectName,
        String fieldName
    ) {
        List<DTBL_PicklistColumnUtils.PicklistValue> picklistValues = DTBL_PicklistColumnUtils.getPicklistValues(
            objectName,
            fieldName
        );
        mapPreCols.get(fieldName).wrapText = true;
        mapPreCols.get(fieldName)
            .typeAttributes = new TypeAttributeColumnJsonWithPicklist(
            picklistValues,
            fieldName
        );
    }

    @AuraEnabled
    public static List<SObject> getRecords(
        String soql,
        Boolean elevatedContext
    ) {
        try {
            if (elevatedContext) {
                return new ElevatedContext().getRecords(soql);
            }
            return Database.query(soql);
        } catch (Exception e) {
            AuraHandledException ahe = new AuraHandledException('');
            ahe.setMessage('Error: ' + e.getMessage());
            throw ahe;
        }
    }

    @AuraEnabled
    public static List<SObject> onSearch(
        String searchTerm,
        String objectApiName,
        String searchFields,
        String whereClause
    ) {
        List<SObject> records = new List<SObject>();
        String sosl = 'FIND :searchTerm IN ALL FIELDS RETURNING {0}( {1} {2} ) ';
        List<String> condition = new List<String>{
            objectApiName,
            searchFields,
            String.isNotEmpty(whereClause) ? (' WHERE ' + whereClause) : ''
        };
        sosl = String.format(sosl, condition);
        List<List<SObject>> results = search.query(sosl);
        for (List<SObject> s : results) {
            records.addAll(s);
        }
        return records;
    }

    @AuraEnabled(cacheable=true)
    public static Integer countRecords(
        String objectName,
        String whereClause,
        Boolean elevatedContext
    ) {
        String formattedWhere = (String.isBlank(whereClause))
            ? ''
            : ' ' + whereClause;

        if (String.isNotEmpty(objectName)) {
            String soql = 'SELECT count() FROM ' + objectName + formattedWhere;
            if (elevatedContext) {
                return new ElevatedContext().countRecords(soql);
            }
            soql += ' WITH SECURITY_ENFORCED';
            return Database.countQuery(soql);
        }
        return 0;
    }

    private static Map<String, ColumnJson> checkOverride(
        Map<String, ColumnJson> mapPreCols,
        String fieldName,
        Map<String, Schema.SObjectField> mfields
    ) {
        String label = mapPreCols.get(fieldName).label != null
                ? mapPreCols.get(fieldName).label
                : mfields.get(fieldName).getDescribe().getLabel(),
            type = mapPreCols.get(fieldName).type != null
                ? mapPreCols.get(fieldName).type.toLowercase()
                : String.valueOf(mfields.get(fieldName).getDescribe().getType())
                      .toLowercase();
        // Boolean editable = mapPreCols.get(fieldName).editable != null
        //         ? mapPreCols.get(fieldName).editable
        //         : mfields.get(fieldName).getDescribe().isUpdateable();
        Boolean editable = false;
        Boolean sortable = true;
        //Update Map Json
        mapPreCols.get(fieldName).label = label;
        mapPreCols.get(fieldName).type = mapFieldToLwcDataType.containskey(type)
            ? mapFieldToLwcDataType.get(type)
            : type;
        mapPreCols.get(fieldName).editable = editable;
        mapPreCols.get(fieldName).sortable = sortable;
        return mapPreCols;
    }

    private without sharing class ElevatedContext {
        public List<SObject> getRecords(String soql) {
            return Database.query(soql);
        }

        public Integer countRecords(String soql) {
            return Database.countQuery(soql);
        }
    }
}