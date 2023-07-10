/**
 * Utility class for working with Supply Chain Types in the CIIS application.
 * @author CGI
 */
public inherited sharing class CIIS_SupplyChainType {
    /**
     * The supply chain type.
     */
    public String supplyChainType { get; private set; }

    /**
     * Map of lightning input type by field type from schema.
     */
    private final Map<String, String> INPUT_TYPE_BY_FIELD_TYPE = new Map<String, String>{
        'Boolean' => 'checkbox',
        'Currency' => 'number',
        'Date' => 'date',
        'DateTime' => 'datetime',
        'Double' => 'number',
        'Email' => 'email',
        'Integer' => 'number',
        'Location' => 'number',
        'Long' => 'number',
        'Percent' => 'number',
        'Phone' => 'tel',
        'URL' => 'url'
    };

    /**
     * Map of lightning formatter by field type from schema.
     */
    private final Map<String, String> FORMATTER_BY_FIELD_TYPE = new Map<String, String>{
        'Currency' => 'currency',
        'Double' => 'number',
        'Integer' => 'number',
        'Location' => 'number',
        'Long' => 'number',
        'Percent' => 'percent'
    };

    /**
     * Map of lightning step by field type from schema.
     */
    private final Map<String, String> STEP_BY_FIELD_TYPE = new Map<String, String>{
        'Currency' => '0.01',
        'Integer' => '1',
        'Location' => '0.000001',
        'Long' => '1',
        'Percent' => '0.01'
    };

    /**
     * The setting for this supply chain type.
     */
    private CIIS_Supply_Chain_Facility_Type_Setting__mdt supplyChainTypeSetting {
        get {
            if (supplyChainTypeSetting == null) {
                CIIS_Supply_Chain_Facility_Type_Setting__mdt result;
                try {
                    result = [
                        SELECT
                            MasterLabel,
                            CIIS_External_Source_of_Truth__c,
                            CIIS_Fields_to_Show__c,
                            CIIS_Input_Fields__c,
                            CIIS_SOQL_Where_Clause__c,
                            CIIS_Unique_Id_Field_Name__c,
                            CIIS_Unique_Id_Label__c,
                            CIIS_Operator_Relationship_Field_Name__c,
                            CIIS_Default_Field_Values__c,
                            CIIS_Record_Type_API_Name__c
                        FROM CIIS_Supply_Chain_Facility_Type_Setting__mdt
                        WHERE MasterLabel = :supplyChainType
                        LIMIT 1
                    ];
                } catch (Exception e) {
                    throw new CIIS_SupplyChainTypeException(
                        'Supply Chain Type ' + supplyChainType + ' not found.'
                    );
                }
                supplyChainTypeSetting = result;
            }
            return supplyChainTypeSetting;
        }
        set;
    }

    /**
     * The default owner id on the account record.
     */
    private Id defaultOwnerId {
        get {
            if (defaultOwnerId == null) {
                Id result;
                // get the default record owner from the supply chain setting metadata
                CIIS_Supply_Chain_Settings__mdt defaultSettings = [
                    SELECT CIIS_Default_Record_Owner__c
                    FROM CIIS_Supply_Chain_Settings__mdt
                    WHERE DeveloperName = 'Default'
                    LIMIT 1
                ];

                if (defaultSettings.CIIS_Default_Record_Owner__c != null) {
                    result = Id.valueOf(
                        defaultSettings.CIIS_Default_Record_Owner__c
                    );
                }

                // if no user in the supply chain group, set the default owner to the system administrator
                if (result == null) {
                    Id adminProfileId = [
                        SELECT Id
                        FROM Profile
                        WHERE Name = 'System Administrator'
                        LIMIT 1
                    ]
                    .Id;
                    result = [
                        SELECT Id
                        FROM User
                        WHERE ProfileId = :adminProfileId AND IsActive = TRUE
                        LIMIT 1
                    ]
                    .Id;
                }
                defaultOwnerId = result;
            }
            return defaultOwnerId;
        }
        set;
    }

    /**
     * A map of lookup picklist config options by allowed lookup field.
     */
    private final Map<String, LookupToPicklistConfig> CONFIG_BY_ALLOWED_LOOKUP = new Map<String, LookupToPicklistConfig>{
        'IETRS_County__c' => new LookupToPicklistConfig(
            'IETRS_County__c',
            'Id',
            new List<String>{ 'Name', 'IETRS_Oil_Gas_County_Code__c' },
            null
        ),
        'IETRS_District__c' => new LookupToPicklistConfig(
            'IETRS_County_Group__c',
            'Id',
            new List<String>{ 'Name', 'IETRS_County_Group_External_Id__c' },
            'IETRS_Group_Type__c = \'District\''
        ),
        'CIIS_CID_Region__c' => new LookupToPicklistConfig(
            'IETRS_County_Group__c',
            'Id',
            new List<String>{ 'Name' },
            'IETRS_Group_Type__c = \'Region\' AND CIIS_Critical_Infrastructure__c = TRUE'
        )
    };

    /**
     * Default constructor for the class.
     */
    public CIIS_SupplyChainType(String supplyChainType) {
        this.supplyChainType = supplyChainType;
    }

    /**
     * Returns a soql string that can be used to retrieve the records.
     * @param operatorId The operator id to filter by.
     * @param whereSuffix The where clause suffix to append.
     */
    public String getSOQLString(String operatorId, String whereSuffix) {
        String result =
            'SELECT ' +
            supplyChainTypeSetting.CIIS_Fields_to_Show__c +
            ' FROM Account';
        result += getWhereClause(operatorId, whereSuffix);
        return result;
    }

    /**
     * Returns the where clause for the SOQL query.
     * @param operatorId The operator id to filter by.
     * @param whereSuffix The where clause suffix to append.
     */
    private String getWhereClause(String operatorId, String whereSuffix) {
        String result = '';
        if (supplyChainTypeSetting.CIIS_SOQL_Where_Clause__c != null) {
            result += supplyChainTypeSetting.CIIS_SOQL_Where_Clause__c;
        }
        if (
            supplyChainTypeSetting.CIIS_Operator_Relationship_Field_Name__c !=
            null &&
            operatorId != null
        ) {
            result +=
                ' AND ' +
                supplyChainTypeSetting.CIIS_Operator_Relationship_Field_Name__c +
                ' = \'' +
                operatorId +
                '\'';
        }
        if (whereSuffix != null) {
            result += ' AND ' + whereSuffix;
        }
        result = ' WHERE ' + result;
        return result;
    }

    /**
     * Returns an instance of the Account object with the default values set.
     * @param operatorId The operator id to set on the account.
     */
    public Account getEntityWithDefaultValues(Id operatorId) {
        Account result = CIIS_SupplyChainUtils.jsonToAccount(
            supplyChainTypeSetting.CIIS_Default_Field_Values__c
        );
        // set the operator relationship field
        if (
            supplyChainTypeSetting.CIIS_Operator_Relationship_Field_Name__c !=
            null &&
            operatorId != null
        ) {
            result.put(
                supplyChainTypeSetting.CIIS_Operator_Relationship_Field_Name__c,
                operatorId
            );
        }

        // set the record type
        if (supplyChainTypeSetting.CIIS_Record_Type_API_Name__c != null) {
            // get the record type id using the developer name provided in supplyChainTypeSetting.CIIS_Record_Type_API_Name__c
            String recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
                .get(supplyChainTypeSetting.CIIS_Record_Type_API_Name__c)
                .getRecordTypeId();
            result.RecordTypeId = recordTypeId;
        }
        result.OwnerId = defaultOwnerId;
        return result;
    }

    /**
     * Returns the columns to display for the supply type.
     */
    public List<Column> getColumns() {
        return getColumnsFromFieldList(
            supplyChainTypeSetting.CIIS_Fields_to_Show__c
        );
    }

    /**
     * Returns the columns to display for the supply type input form.
     */
    public List<Column> getInputFields() {
        return getColumnsFromFieldList(
            supplyChainTypeSetting.CIIS_Input_Fields__c
        );
    }

    /**
     * Returns the column details for the given field list.
     * @param fieldList The field list to parse.
     */
    private List<Column> getColumnsFromFieldList(String fieldList) {
        if (fieldList == null) {
            return new List<Column>();
        }
        List<Column> result = new List<Column>();
        Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe()
            .get('Account')
            .getDescribe()
            .fields.getMap();
        String[] fields = fieldList.deleteWhitespace().split(',');
        for (String field : fields) {
            Schema.DescribeFieldResult fieldDescribe = fieldMap.get(field)
                .getDescribe();
            Column col = getColumnFromField(field, fieldDescribe);

            // set the options property for combobox type
            if (fieldDescribe.getType() == DisplayType.Reference) {
                if (!CONFIG_BY_ALLOWED_LOOKUP.containsKey(field)) {
                    throw new CIIS_SupplyChainTypeException(
                        'Field ' +
                            field +
                            ' has not been configured for lookup to picklist.'
                    );
                }
                col.type = 'combobox';
                col.options = CONFIG_BY_ALLOWED_LOOKUP.get(field).getOptions();
            }
            result.add(col);
        }
        return result;
    }

    /**
     * Returns the column details for the given field.
     * @param field The field to parse.
     * @param fieldDescribe The field describe result.
     */
    private Column getColumnFromField(
        String field,
        Schema.DescribeFieldResult fieldDescribe
    ) {
        String label = fieldDescribe.getLabel();
        if (
            field ==
            supplyChainTypeSetting.CIIS_Unique_Id_Field_Name__c?.toLowercase()
        ) {
            label = supplyChainTypeSetting.CIIS_Unique_Id_Label__c;
        }
        String fieldType = fieldDescribe.getType().name();
        String type = 'text';
        // set the input type property from INPUT_TYPE_BY_FIELD_TYPE if keys contain fieldType
        if (INPUT_TYPE_BY_FIELD_TYPE.containsKey(fieldType)) {
            type = INPUT_TYPE_BY_FIELD_TYPE.get(fieldType);
        }
        Column col = new Column(field, label, type);
        // set formatter property from FORMATTER_BY_FIELD_TYPE if keys contain fieldType
        if (FORMATTER_BY_FIELD_TYPE.containsKey(fieldType)) {
            col.formatter = FORMATTER_BY_FIELD_TYPE.get(fieldType);
        }
        // set step property from STEP_BY_FIELD_TYPE if keys contain fieldType
        if (STEP_BY_FIELD_TYPE.containsKey(fieldType)) {
            col.step = STEP_BY_FIELD_TYPE.get(fieldType);
        }
        // if fieldType === Decimal, set the step value based on the scale
        if (fieldType == 'Decimal' && fieldDescribe.getScale() > 0) {
            //  if scale is 1, set step to 0.1; if scale is 2, set step to 0.01; etc.
            Integer scale = fieldDescribe.getScale();
            col.step = '0.' + String.valueOf('0'.repeat(scale - 1)) + '1';
        }
        return col;
    }

    /**
     * Returns the account geolocations assocaited with the provided account ids.
     * @param accountIds The account ids to get geolocations for.
     */
    public Map<Id, List<CIIS_Account_Geolocation__c>> getAccountGeolocations(
        List<Id> accountIds
    ) {
        return new ElevatedContext().getAccountGeolocations(accountIds);
    }

    /**
     * Inner class that represents the configuration for a lookup to picklist field.
     */
    private class LookupToPicklistConfig {
        public String sobjectName { get; set; }
        public String valueField { get; set; }
        public List<String> labelFields { get; set; }
        public String whereClause { get; set; }

        String soqlQuery {
            get {
                String result = 'SELECT ';
                result += valueField + ',';
                result += String.join(labelFields, ',');
                result += ' FROM ' + sobjectName;
                if (whereClause != null) {
                    result += ' WHERE ' + whereClause;
                }
                result += ' ORDER BY ' + labelFields[0];
                return result;
            }
        }

        public LookupToPicklistConfig(
            String sobjectName,
            String valueField,
            List<String> labelFields,
            String whereClause
        ) {
            this.sobjectName = sobjectName;
            this.valueField = valueField;
            this.labelFields = labelFields;
            this.whereClause = whereClause;
        }

        public List<Option> getOptions() {
            List<Option> result = new List<Option>();
            for (SObject sobj : Database.query(soqlQuery)) {
                String label = '';
                for (Integer i = 0; i < labelFields.size(); i++) {
                    String labelField = labelFields[i];
                    label += (String) sobj.get(labelField);
                    if (i < labelFields.size() - 1) {
                        label += ' - ';
                    }
                }
                result.add(new Option((String) sobj.get(valueField), label));
            }
            return result;
        }
    }

    /**
     * Inner class that represents an option for a combobox.
     */
    public class Option {
        @AuraEnabled
        public String value { get; private set; }
        @AuraEnabled
        public String label { get; private set; }

        public Option(String value, String label) {
            this.value = value;
            this.label = label;
        }
    }

    /**
     * Inner class that represents a column in the table.
     */
    public class Column {
        @AuraEnabled
        public String fieldName { get; private set; }
        @AuraEnabled
        public String label { get; private set; }
        @AuraEnabled
        public String type { get; private set; }
        @AuraEnabled
        public String formatter { get; set; }
        @AuraEnabled
        public String step { get; set; }
        @AuraEnabled
        public List<Option> options { get; set; }

        public Column(String fieldName, String label, String type) {
            this.fieldName = fieldName;
            this.label = label;
            this.type = type;
        }
    }

    /**
     * Inner class used for executing privileged methods in an elevated context.
     */
    public without sharing class ElevatedContext {
        public Map<Id, List<CIIS_Account_Geolocation__c>> getAccountGeolocations(
            List<Id> accountIds
        ) {
            Map<Id, List<CIIS_Account_Geolocation__c>> result = new Map<Id, List<CIIS_Account_Geolocation__c>>();
            try {
                for (CIIS_Account_Geolocation__c accGeo : [
                    SELECT
                        Id,
                        CIIS_Account__c,
                        CIIS_Status__c,
                        CIIS_Geolocations__r.CIIS_Primary_Geolocation_Type__c,
                        CIIS_Geolocations__r.CIIS_Geolocation__latitude__s,
                        CIIS_Geolocations__r.CIIS_Geolocation__longitude__s
                    FROM CIIS_Account_Geolocation__c
                    WHERE
                        CIIS_Account__c IN :accountIds
                        AND CIIS_Is_Primary_Supply_Chain_Geolocation__c = TRUE
                ]) {
                    if (!result.containsKey(accGeo.CIIS_Account__c)) {
                        result.put(
                            accGeo.CIIS_Account__c,
                            new List<CIIS_Account_Geolocation__c>{ accGeo }
                        );
                    }
                    result.get(accGeo.CIIS_Account__c).add(accGeo);
                }
            } catch (Exception e) {
                throw new AuraHandledException(e.getMessage());
            }
            return result;
        }
    }

    /**
     * Exception class for supply chain type errors.
     */
    public class CIIS_SupplyChainTypeException extends Exception {
    }
}