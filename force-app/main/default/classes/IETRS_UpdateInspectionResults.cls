/*
  @Class Name         : IETRS_UpdateInspectionResult
  @Description        : Inspection Checklist
  @Author             : Srilu Mamillapalli
  @Group              : 
  @Last Modified By   : Srilu Mamillapalli
  @Last Modified On   : 3/22/2020
  @Modification Log   : 
  ==============================================================================
  Ver         Date                     Author                 Modification
  ==============================================================================
  1.0    3/22/2020,    Srilu Mamillapalli     Initial Version
*/
public class IETRS_UpdateInspectionResults {
    @AuraEnabled
    public static List<Inspection> getInspectionResults(Id recordId, String tabName) {
        Map<Id, Inspection> inspectionByInspectionId = new Map<Id, Inspection>();
        IETRS_Insp_Inspection_Result__c iP = new IETRS_Insp_Inspection_Result__c();
        Map<String, List<Map<String, String>>> resultOptionsByTab = new Map<String, List<Map<String, String>>>();
        resultOptionsByTab = getDependentMap(ip, 'IETRS_Tab__c', 'IETRS_Result__c');

        for (IETRS_Insp_Inspection_Result__c con : [
            SELECT
                Id,
                IETRS_Checklist_Item_text__c,
                IETRS_Inspection_Package__r.IETRS_Organization__c,
                IETRS_Inspection_Checklist_Config__c,
                IETRS_Tab__c,
                IETRS_Program_Code__c,
                IETRS_Note__c,
                IETRS_Create_Violation__c,
                IETRS_Comments__c,
                IETRS_Violation_Location__c,
                IETRS_Ending_Mileage__c,
                IETRS_Inspection__c,
                IETRS_Inspection_Package__c,
                IETRS_Inspection__r.Name,
                IETRS_Regulatory_Code__c,
                IETRS_Regulatory_Code__r.Name,
                IETRS_Result__c,
                Name,
                IETRS_Starting_Mileage__c,
                IETRS_Inspection__r.IETRS_Regulated_Entity__c,
                IETRS_Inspection__r.IETRS_Regulated_Entity__r.Name,
                IETRS_Inspection__r.IETRS_Regulated_Entity__r.IETRS_Product_Class__c
            FROM IETRS_Insp_Inspection_Result__c
            WHERE
                IETRS_Tab__c = :tabName
                AND (IETRS_Inspection_Package__c = :recordId
                OR IETRS_Inspection__c = :recordId)
            ORDER BY IETRS_Checklist_Item_Order__c ASC
        ]) {
            List<Map<String, String>> listOfDependentFields = new List<Map<String, String>>();
            if (con.IETRS_Tab__c != null) {
                listOfDependentFields.addAll(resultOptionsByTab.get(con.IETRS_Tab__c));
            }
            if (!inspectionByInspectionId.containsKey(con.IETRS_Inspection__c)) {
                Inspection i = new Inspection(
                    con.IETRS_Inspection__c,
                    con.IETRS_Inspection__r.Name,
                    con.IETRS_Inspection__r.IETRS_Regulated_Entity__c,
                    con.IETRS_Inspection__r.IETRS_Regulated_Entity__r.Name,
                    new List<InspectionResults>()
                );
                inspectionByInspectionId.put(con.IETRS_Inspection__c, i);
            }
            inspectionByInspectionId.get(con.IETRS_Inspection__c)
                .inspectionResults.add(
                    new InspectionResults(
                        con.IETRS_Create_Violation__c,
                        con,
                        new IETRS_Insp_Inspection_Result__c(),
                        listOfDependentFields
                    )
                );
        }
        System.debug('inspectionByInspectionId');
        System.debug(inspectionByInspectionId.values().size());
        System.debug(recordId);

        return inspectionByInspectionId.values();
    }

    @AuraEnabled
    public static void saveRecords(List<IETRS_Insp_Inspection_Result__c> inspectionResults) {
        try {
            system.debug('----inspectionResults---' + inspectionResults);
            update inspectionResults;
        } catch (Exception ex) {
            String msg = ex.getMessage();
            AuraHandledException ae = new AuraHandledException(msg);
            ae.setMessage(msg);
            throw ae;
        }
    }

    public static Map<String, List<Map<String, String>>> getDependentMap(
        sObject objDetail,
        string contrfieldApiName,
        string depfieldApiName
    ) {
        String controllingField = contrfieldApiName.toLowerCase();
        String dependentField = depfieldApiName.toLowerCase();

        Map<String, List<Map<String, String>>> objResults = new Map<String, List<Map<String, String>>>();

        Schema.sObjectType objType = objDetail.getSObjectType();
        if (objType == null) {
            return objResults;
        }

        Map<String, Schema.SObjectField> objFieldMap = objType.getDescribe().fields.getMap();

        if (!objFieldMap.containsKey(controllingField) || !objFieldMap.containsKey(dependentField)) {
            return objResults;
        }

        Schema.SObjectField theField = objFieldMap.get(dependentField);
        Schema.SObjectField ctrlField = objFieldMap.get(controllingField);

        List<Schema.PicklistEntry> contrEntries = ctrlField.getDescribe().getPicklistValues();
        List<PicklistEntryWrapper> depEntries = wrapPicklistEntries(theField.getDescribe().getPicklistValues());
        List<String> controllingValues = new List<String>();

        for (Schema.PicklistEntry ple : contrEntries) {
            String label = ple.getLabel();
            String value = ple.getValue();
            objResults.put(value, new List<Map<String, String>>());
            controllingValues.add(value);
        }

        for (PicklistEntryWrapper plew : depEntries) {
            String label = plew.label;
            String value = plew.value;
            String validForBits = base64ToBits(plew.validFor);
            for (Integer i = 0; i < validForBits.length(); i++) {
                String bit = validForBits.mid(i, 1);
                if (bit == '1') {
                    objResults.get(controllingValues.get(i))
                        .add(new Map<String, String>{ 'label' => label, 'value' => value });
                }
            }
        }
        return objResults;
    }

    public static String decimalToBinary(Integer val) {
        String bits = '';
        while (val > 0) {
            Integer remainder = Math.mod(val, 2);
            val = Integer.valueOf(Math.floor(val / 2));
            bits = String.valueOf(remainder) + bits;
        }
        return bits;
    }

    public static String base64ToBits(String validFor) {
        if (String.isEmpty(validFor))
            return '';

        String validForBits = '';

        for (Integer i = 0; i < validFor.length(); i++) {
            String thisChar = validFor.mid(i, 1);
            Integer val = base64Chars.indexOf(thisChar);
            String bits = decimalToBinary(val).leftPad(6, '0');
            validForBits += bits;
        }

        return validForBits;
    }

    private static final String base64Chars =
        '' +
        'ABCDEFGHIJKLMNOPQRSTUVWXYZ' +
        'abcdefghijklmnopqrstuvwxyz' +
        '0123456789+/';

    private static List<PicklistEntryWrapper> wrapPicklistEntries(List<Schema.PicklistEntry> PLEs) {
        return (List<PicklistEntryWrapper>) JSON.deserialize(JSON.serialize(PLEs), List<PicklistEntryWrapper>.class);
    }

    public class PicklistEntryWrapper {
        public String active { get; set; }
        public String defaultValue { get; set; }
        public String label { get; set; }
        public String value { get; set; }
        public String validFor { get; set; }
        public PicklistEntryWrapper() {
        }
    }

    public class Inspection {
        @AuraEnabled
        public String inspectionId { get; set; }
        @AuraEnabled
        public String inspectionName { get; set; }
        @AuraEnabled
        public String entityId { get; set; }
        @AuraEnabled
        public String entityName { get; set; }
        @AuraEnabled
        public List<InspectionResults> inspectionResults { get; set; }
        public Inspection(
            String inspectionId,
            String inspectionName,
            String entityId,
            String entityName,
            List<InspectionResults> inspectionResults
        ) {
            this.inspectionId = inspectionId;
            this.inspectionName = inspectionName;
            this.entityId = entityId;
            this.entityName = entityName;
            this.inspectionResults = inspectionResults;
        }
    }

    public class InspectionResults {
        @AuraEnabled
        public boolean isViolationReadOnly { get; set; }
        @AuraEnabled
        public IETRS_Insp_Inspection_Result__c inspRec { get; set; }
        @AuraEnabled
        public IETRS_Insp_Inspection_Result__c inspRecNew { get; set; }
        @AuraEnabled
        public List<Map<String, String>> resultOptions { get; set; }
        public InspectionResults(
            boolean isViolationReadOnly,
            IETRS_Insp_Inspection_Result__c objInsp,
            IETRS_Insp_Inspection_Result__c newInsp,
            List<Map<String, String>> resultOptions
        ) {
            this.isViolationReadOnly = isViolationReadOnly;
            this.inspRec = objInsp;
            this.inspRecNew = newInsp;
            this.resultOptions = resultOptions;
        }
    }
}