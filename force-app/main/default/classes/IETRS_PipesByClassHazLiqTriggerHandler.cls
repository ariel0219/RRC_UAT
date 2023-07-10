public with sharing class IETRS_PipesByClassHazLiqTriggerHandler {
    public static void handleAfterUpdate() {
        updateSummaryValuesOnParentRecords(Trigger.new);
    }

    public static void handleAfterInsert() {
        updateSummaryValuesOnParentRecords(Trigger.new);
    }

    public static void handleAfterDelete() {
        updateSummaryValuesOnParentRecords(Trigger.old);
    }

    public static void handleAfterUndelete() {
        updateSummaryValuesOnParentRecords(Trigger.new);
    }

    public static void handleBeforeDelete(){
        stopNonWorkInProgressIPDeletes(Trigger.old);
    }

    /**
     * @description Get the eligible org ids and update the total miles
     */
    private static void updateSummaryValuesOnParentRecords(List<IETRS_Pipes_by_Class_Haz_Liq__c> records) {
        Set<Id> inspectionIds = new Set<Id>();
        for (IETRS_Pipes_by_Class_Haz_Liq__c record : records) {
            if (Trigger.isUpdate) {
                //check if miles changed
                IETRS_Pipes_by_Class_Haz_Liq__c oldRecord = (IETRS_Pipes_by_Class_Haz_Liq__c) Trigger.oldMap
                    .get(record.Id);
                if (oldRecord.IETRS_Miles_of_HCA__c != record.IETRS_Miles_of_HCA__c) {
                    inspectionIds.add(record.IETRS_Inspection__c);
                }
            } else {
                inspectionIds.add(record.IETRS_Inspection__c);
            }
        }

        if (inspectionIds.isEmpty()) {
            return;
        }

        Set<Id> orgIds = new Set<Id>();
        Id psEntityRecordTypeId = IETRS_I_InspectionsService.getRegulatedEntityPSRecordTypeId();
        for (Account acc : [
            SELECT Id, IETRS_OrganizationofRegEntity__c
            FROM Account
            WHERE
                IETRS_Latest_Inspection__c IN :inspectionIds
                AND IETRS_OrganizationofRegEntity__c != null
                AND RecordTypeId = :psEntityRecordTypeId
        ]) {
            orgIds.add(acc.IETRS_OrganizationofRegEntity__c);
        }

        if (!orgIds.isEmpty()) {
            IETRS_I_InspectionsService.updateMilesOfHighConsequenceLiquidOnOrgs(orgIds);
        }
    }

    public static void stopNonWorkInProgressIPDeletes(List<IETRS_Pipes_by_Class_Haz_Liq__c> lstPipesByClass) {
        String strProfileName;

        strProfileName = [SELECT Name FROM Profile WHERE Id = :UserInfo.getProfileId() LIMIT 1].Name;
        if (strProfileName == 'IETRS Inspections - Inspector' || strProfileName == 'IETRS Inspections - Inspection Manager'){
            for(Integer i=0; i<lstPipesByClass.size(); i++){
                IETRS_Inspection__c inspQueried = [SELECT IETRS_Inspection_Package__c, IETRS_Inspection_Package__r.IETRS_Status__c FROM IETRS_Inspection__c WHERE Id = :lstPipesByClass[i].IETRS_Inspection__c LIMIT 1];
                if(inspQueried.IETRS_Inspection_Package__c != null){
                    if(inspQueried.IETRS_Inspection_Package__r.IETRS_Status__c != 'Work in Progress' &&
                      inspQueried.IETRS_Inspection_Package__r.IETRS_Status__c != 'WIP/Rejected'){
                        lstPipesByClass[i].addError('Associated Inspection Package is not in state: "Work in Progress" or "WIP/Rejected" - You do not have permission to delete this record.');
                    }
                }
            }
        }

    }
}